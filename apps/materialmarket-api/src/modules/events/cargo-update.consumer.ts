import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { OrderStatus } from '@prisma/client';
import {
  Queues,
  RoutingKeys,
  type EventEnvelope,
  type CargoRequestMatched,
  type CargoRequestStatusChanged,
  type CargoRequestCompleted,
} from '@cargos/shared-contracts';
import { PrismaService } from '../../prisma/prisma.module';
import { RabbitMQService } from './rabbitmq.service';

const STATUS_MAP: Record<CargoRequestStatusChanged['status'], OrderStatus> = {
  created: OrderStatus.CREATED,
  matching: OrderStatus.CONFIRMED,
  assigned: OrderStatus.CONFIRMED,
  picked_up: OrderStatus.SHIPPING,
  in_transit: OrderStatus.SHIPPING,
  delivered: OrderStatus.DELIVERED,
  closed: OrderStatus.CLOSED,
  cancelled: OrderStatus.CANCELLED,
};

@Injectable()
export class CargoUpdateConsumer implements OnModuleInit {
  private readonly logger = new Logger(CargoUpdateConsumer.name);

  constructor(
    private readonly mq: RabbitMQService,
    private readonly prisma: PrismaService,
  ) {}

  async onModuleInit() {
    this.mq.on(RoutingKeys.CargoRequestMatched, (e) => this.onMatched(e));
    this.mq.on(RoutingKeys.CargoRequestStatusChanged, (e) => this.onStatus(e));
    this.mq.on(RoutingKeys.CargoRequestCompleted, (e) => this.onCompleted(e));

    setTimeout(
      () =>
        this.mq
          .bindQueue(Queues.MaterialmarketCargoUpdates, [
            RoutingKeys.CargoRequestMatched,
            RoutingKeys.CargoRequestStatusChanged,
            RoutingKeys.CargoRequestCompleted,
          ])
          .catch((err) => this.logger.error(`bindQueue failed: ${err.message}`)),
      2000,
    );
  }

  private async dedupe(env: EventEnvelope): Promise<boolean> {
    const exists = await this.prisma.inboxEvent.findUnique({ where: { eventId: env.eventId } });
    if (exists) return true;
    await this.prisma.inboxEvent.create({
      data: { eventId: env.eventId, routingKey: env.routingKey },
    });
    return false;
  }

  private async onMatched(env: EventEnvelope) {
    if (await this.dedupe(env)) return;
    const p = env.payload as CargoRequestMatched;
    await this.prisma.order
      .update({
        where: { id: p.orderId },
        data: {
          cargoRequestId: p.cargoRequestId,
          driverName: p.driverName,
          driverPhone: p.driverPhone,
          vehiclePlate: p.vehiclePlate,
        },
      })
      .catch((err) => this.logger.warn(`onMatched: ${err.message}`));
  }

  private async onStatus(env: EventEnvelope) {
    if (await this.dedupe(env)) return;
    const p = env.payload as CargoRequestStatusChanged;
    await this.prisma.order
      .update({
        where: { id: p.orderId },
        data: { status: STATUS_MAP[p.status] },
      })
      .catch((err) => this.logger.warn(`onStatus: ${err.message}`));
  }

  private async onCompleted(env: EventEnvelope) {
    if (await this.dedupe(env)) return;
    const p = env.payload as CargoRequestCompleted;
    await this.prisma.order
      .update({
        where: { id: p.orderId },
        data: { status: OrderStatus.DELIVERED, deliveredAt: new Date(p.deliveredAt) },
      })
      .catch((err) => this.logger.warn(`onCompleted: ${err.message}`));
  }
}
