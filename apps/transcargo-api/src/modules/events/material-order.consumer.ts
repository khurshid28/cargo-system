import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import {
  Queues,
  RoutingKeys,
  type EventEnvelope,
  type MaterialOrderCreated,
} from '@cargos/shared-contracts';
import { PrismaService } from '../../prisma/prisma.module';
import { CargoRequestsService } from '../cargo-requests/cargo-requests.service';
import { UserRole, UserStatus } from '@prisma/client';
import { RabbitMQService } from './rabbitmq.service';

/**
 * Consume `material_order.created` from MaterialMarket → create cargo request.
 * Idempotent via InboxEvent.eventId PK.
 */
@Injectable()
export class MaterialOrderConsumer implements OnModuleInit {
  private readonly logger = new Logger(MaterialOrderConsumer.name);

  constructor(
    private readonly mq: RabbitMQService,
    private readonly prisma: PrismaService,
    private readonly cargoRequests: CargoRequestsService,
  ) {}

  async onModuleInit() {
    this.mq.on(RoutingKeys.MaterialOrderCreated, (env) => this.handle(env));
    // Defer queue binding until channel ready; RabbitMQService ensures via async connect.
    // We attempt and rely on internal retry.
    setTimeout(
      () =>
        this.mq
          .bindQueue(Queues.TranscargoMaterialOrders, [RoutingKeys.MaterialOrderCreated])
          .catch((err) => this.logger.error(`bindQueue failed: ${err.message}`)),
      2000,
    );
  }

  private async handle(envelope: EventEnvelope): Promise<void> {
    const exists = await this.prisma.inboxEvent.findUnique({
      where: { eventId: envelope.eventId },
    });
    if (exists) {
      this.logger.log(`Duplicate event ignored: ${envelope.eventId}`);
      return;
    }
    const payload = envelope.payload as MaterialOrderCreated;
    this.logger.log(`Material order received: ${payload.orderId}`);

    // Ensure a synthetic "sender" user exists for the merchant (so FK is happy).
    const sender = await this.prisma.user.upsert({
      where: { phone: `merchant:${payload.merchantId}` },
      create: {
        phone: `merchant:${payload.merchantId}`,
        fullName: `Merchant ${payload.merchantId}`,
        role: UserRole.SENDER,
        status: UserStatus.ACTIVE,
      },
      update: {},
    });

    await this.prisma.$transaction([
      this.prisma.inboxEvent.create({
        data: { eventId: envelope.eventId, routingKey: envelope.routingKey },
      }),
    ]);

    await this.cargoRequests.create({
      senderId: sender.id,
      externalOrderId: payload.orderId,
      pickup: {
        address: payload.pickup.raw,
        lat: payload.pickup.point.lat,
        lng: payload.pickup.point.lng,
      },
      dropoff: {
        address: payload.dropoff.raw,
        lat: payload.dropoff.point.lat,
        lng: payload.dropoff.point.lng,
      },
      cargoType: payload.cargo.type,
      weightKg: payload.cargo.weightKg,
      volumeM3: payload.cargo.volumeM3,
      bodyKind: payload.cargo.bodyKind,
      notes: payload.cargo.notes,
      priceAmount: payload.budget?.amount,
      scheduledAt: payload.scheduledAt,
    });
  }
}
