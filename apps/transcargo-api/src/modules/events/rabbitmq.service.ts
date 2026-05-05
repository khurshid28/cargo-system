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

export type EventHandler<K extends RoutingKey = RoutingKey> = (
  envelope: EventEnvelope,
) => Promise<void>;

@Injectable()
export class RabbitMQService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(RabbitMQService.name);
  private connection?: amqp.Connection;
  private channel?: amqp.Channel;
  private readonly handlers = new Map<RoutingKey, EventHandler>();

  constructor(private readonly cfg: ConfigService) {}

  async onModuleInit(): Promise<void> {
    await this.connect();
  }

  async onModuleDestroy(): Promise<void> {
    await this.channel?.close().catch(() => undefined);
    await this.connection?.close().catch(() => undefined);
  }

  private async connect(): Promise<void> {
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

  /** Publish an event with validation by routing key. */
  async publish<K extends RoutingKey>(
    routingKey: K,
    payload: unknown,
    source: 'transcargo',
  ): Promise<void> {
    const schema = PayloadSchemas[routingKey];
    const validated = schema.parse(payload);
    const envelope: EventEnvelope = {
      eventId: uuid(),
      occurredAt: new Date().toISOString(),
      source,
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

  /** Bind a durable queue to one or more routing keys, dispatching to registered handlers. */
  async bindQueue(queueName: string, routingKeys: RoutingKey[]): Promise<void> {
    if (!this.channel) throw new Error('RabbitMQ channel not ready');
    await this.channel.assertQueue(queueName, { durable: true });
    for (const rk of routingKeys) {
      await this.channel.bindQueue(queueName, CARGOS_EXCHANGE, rk);
    }
    await this.channel.consume(queueName, async (msg) => {
      if (!msg) return;
      try {
        const envelope = JSON.parse(msg.content.toString()) as EventEnvelope;
        const handler = this.handlers.get(envelope.routingKey as RoutingKey);
        if (!handler) {
          this.logger.warn(`No handler for ${envelope.routingKey} — acking`);
          this.channel!.ack(msg);
          return;
        }
        await handler(envelope);
        this.channel!.ack(msg);
      } catch (err) {
        this.logger.error(`Handler failed: ${(err as Error).message}`);
        this.channel!.nack(msg, false, false);
      }
    });
    this.logger.log(`Bound queue "${queueName}" to [${routingKeys.join(', ')}]`);
  }

  on<K extends RoutingKey>(routingKey: K, handler: EventHandler<K>): void {
    this.handlers.set(routingKey, handler as EventHandler);
  }
}
