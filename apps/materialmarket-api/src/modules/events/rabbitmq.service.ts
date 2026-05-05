import { Injectable, Logger, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as amqp from 'amqplib';
import { v4 as uuid } from 'uuid';
import {
  CARGOS_EXCHANGE,
  type EventEnvelope,
  PayloadSchemas,
  type RoutingKey,
} from '@cargos/shared-contracts';
import type { AppConfig } from '../../config/app.config';

export type EventHandler = (envelope: EventEnvelope) => Promise<void>;

@Injectable()
export class RabbitMQService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(RabbitMQService.name);
  private connection?: amqp.Connection;
  private channel?: amqp.Channel;
  private readonly handlers = new Map<RoutingKey, EventHandler>();

  constructor(private readonly cfg: ConfigService) {}

  async onModuleInit() {
    await this.connect();
  }
  async onModuleDestroy() {
    await this.channel?.close().catch(() => undefined);
    await this.connection?.close().catch(() => undefined);
  }

  private async connect() {
    const url = this.cfg.get<AppConfig>('APP_CONFIG')!.rabbitmqUrl;
    try {
      this.connection = await amqp.connect(url);
      this.channel = await this.connection.createChannel();
      await this.channel.assertExchange(CARGOS_EXCHANGE, 'topic', { durable: true });
      this.logger.log(`Connected to RabbitMQ (${url})`);
    } catch (err) {
      this.logger.error(`RabbitMQ connect failed: ${(err as Error).message}. Retrying in 5s...`);
      setTimeout(() => this.connect(), 5000);
    }
  }

  async publish<K extends RoutingKey>(routingKey: K, payload: unknown): Promise<void> {
    const validated = PayloadSchemas[routingKey].parse(payload);
    const envelope: EventEnvelope = {
      eventId: uuid(),
      occurredAt: new Date().toISOString(),
      source: 'materialmarket',
      version: 1,
      routingKey,
      payload: validated,
    };
    if (!this.channel) throw new Error('RabbitMQ channel not ready');
    this.channel.publish(CARGOS_EXCHANGE, routingKey, Buffer.from(JSON.stringify(envelope)), {
      persistent: true,
      contentType: 'application/json',
      messageId: envelope.eventId,
    });
    this.logger.log(`Published ${routingKey} (eventId=${envelope.eventId})`);
  }

  async bindQueue(queueName: string, routingKeys: RoutingKey[]): Promise<void> {
    if (!this.channel) throw new Error('RabbitMQ channel not ready');
    await this.channel.assertQueue(queueName, { durable: true });
    for (const rk of routingKeys) await this.channel.bindQueue(queueName, CARGOS_EXCHANGE, rk);
    await this.channel.consume(queueName, async (msg) => {
      if (!msg) return;
      try {
        const env = JSON.parse(msg.content.toString()) as EventEnvelope;
        const handler = this.handlers.get(env.routingKey as RoutingKey);
        if (!handler) {
          this.channel!.ack(msg);
          return;
        }
        await handler(env);
        this.channel!.ack(msg);
      } catch (err) {
        this.logger.error(`Handler failed: ${(err as Error).message}`);
        this.channel!.nack(msg, false, false);
      }
    });
    this.logger.log(`Bound queue "${queueName}" to [${routingKeys.join(', ')}]`);
  }

  on(rk: RoutingKey, h: EventHandler): void {
    this.handlers.set(rk, h);
  }
}
