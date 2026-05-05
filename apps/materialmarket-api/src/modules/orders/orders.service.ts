import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { OrderStatus } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.module';
import { RabbitMQService } from '../events/rabbitmq.service';
import { RoutingKeys, type MaterialOrderCreated } from '@cargos/shared-contracts';
import { CreateOrderDto } from './dto';

@Injectable()
export class OrdersService {
  private readonly logger = new Logger(OrdersService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly mq: RabbitMQService,
  ) {}

  async create(customerId: string, dto: CreateOrderDto) {
    const products = await this.prisma.product.findMany({
      where: { id: { in: dto.items.map((i) => i.productId) }, active: true },
    });
    if (products.length !== dto.items.length)
      throw new NotFoundException('Some products not found');

    let total = 0;
    const itemsData = dto.items.map((i) => {
      const p = products.find((x) => x.id === i.productId)!;
      total += p.price * i.quantity;
      return { productId: p.id, quantity: i.quantity, unitPrice: p.price, unit: p.unit };
    });

    return this.prisma.order.create({
      data: {
        customerId,
        merchantId: dto.merchantId,
        status: OrderStatus.CREATED,
        deliveryAddress: dto.deliveryAddress,
        deliveryLat: dto.deliveryLat,
        deliveryLng: dto.deliveryLng,
        scheduledAt: dto.scheduledAt ? new Date(dto.scheduledAt) : null,
        totalAmount: total,
        items: { create: itemsData },
      },
      include: { items: true },
    });
  }

  /**
   * Merchant confirms an order. We:
   * 1) update status,
   * 2) publish `material_order.created` to TransCargo.
   *
   * For production correctness wrap (1) + outbox insert in a transaction and let
   * a relay worker publish from outbox.
   */
  async confirm(orderId: string) {
    const order = await this.prisma.order.findUniqueOrThrow({
      where: { id: orderId },
      include: { customer: true, merchant: true, items: { include: { product: true } } },
    });
    if (order.status !== OrderStatus.CREATED) {
      this.logger.warn(`Order ${orderId} not in CREATED state (was ${order.status})`);
      return order;
    }
    const updated = await this.prisma.order.update({
      where: { id: orderId },
      data: { status: OrderStatus.CONFIRMED, confirmedAt: new Date() },
    });

    // Aggregate cargo spec from items (sum of weights, dominant body kind).
    const totalWeightKg = order.items.reduce(
      (s, it) => s + (it.product.weightPerUnitKg ?? 0) * it.quantity,
      0,
    );
    const cargoType = order.items[0]?.product.nameUz ?? 'general';
    const bodyKind = order.items[0]?.product.bodyKind;

    const payload: MaterialOrderCreated = {
      orderId: order.id,
      merchantId: order.merchantId,
      customerId: order.customerId,
      customerPhone: order.customer.phone,
      pickup: {
        raw: order.merchant.warehouseAddress,
        point: { lat: order.merchant.warehouseLat, lng: order.merchant.warehouseLng },
      },
      dropoff: {
        raw: order.deliveryAddress,
        point: { lat: order.deliveryLat, lng: order.deliveryLng },
      },
      cargo: {
        type: cargoType,
        weightKg: Math.max(totalWeightKg, 1),
        bodyKind: bodyKind ?? undefined,
      },
      scheduledAt: order.scheduledAt?.toISOString(),
      budget: { amount: order.totalAmount, currency: order.currency },
    };

    await this.mq.publish(RoutingKeys.MaterialOrderCreated, payload);
    return updated;
  }

  list(filter: { customerId?: string; merchantId?: string; status?: OrderStatus }) {
    return this.prisma.order.findMany({ where: filter, orderBy: { createdAt: 'desc' }, take: 100 });
  }

  byId(id: string) {
    return this.prisma.order.findUnique({
      where: { id },
      include: { items: { include: { product: true } } },
    });
  }

  setCargoMatched(
    orderId: string,
    info: { cargoRequestId: string; driverName: string; driverPhone: string; vehiclePlate: string },
  ) {
    return this.prisma.order.update({ where: { id: orderId }, data: info });
  }

  setStatusFromCargo(orderId: string, status: OrderStatus, deliveredAt?: Date) {
    return this.prisma.order.update({
      where: { id: orderId },
      data: { status, ...(deliveredAt ? { deliveredAt } : {}) },
    });
  }
}
