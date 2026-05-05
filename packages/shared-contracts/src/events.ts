import { z } from 'zod';
import { AddressSchema, CargoSpecSchema, MoneySchema } from './common';
import { RoutingKeys, type RoutingKey } from './routing';

/** Common envelope wrapping every event for idempotency + tracing. */
export const EventEnvelopeSchema = z.object({
  eventId: z.string().uuid(),
  occurredAt: z.string().datetime(),
  source: z.enum(['transcargo', 'materialmarket']),
  version: z.literal(1),
  routingKey: z.string(),
  payload: z.unknown(),
});
export type EventEnvelope<T = unknown> = Omit<z.infer<typeof EventEnvelopeSchema>, 'payload'> & {
  payload: T;
};

// ---------- MaterialMarket -> TransCargo ----------

export const MaterialOrderCreatedSchema = z.object({
  orderId: z.string().uuid(),
  merchantId: z.string().uuid(),
  customerId: z.string().uuid(),
  customerPhone: z.string(),
  pickup: AddressSchema,
  dropoff: AddressSchema,
  cargo: CargoSpecSchema,
  scheduledAt: z.string().datetime().optional(),
  budget: MoneySchema.optional(),
});
export type MaterialOrderCreated = z.infer<typeof MaterialOrderCreatedSchema>;

export const MaterialOrderCancelledSchema = z.object({
  orderId: z.string().uuid(),
  reason: z.string().optional(),
});
export type MaterialOrderCancelled = z.infer<typeof MaterialOrderCancelledSchema>;

// ---------- TransCargo -> MaterialMarket ----------

export const CargoRequestMatchedSchema = z.object({
  /** original MaterialMarket order id (correlation) */
  orderId: z.string().uuid(),
  cargoRequestId: z.string().uuid(),
  driverId: z.string().uuid(),
  driverName: z.string(),
  driverPhone: z.string(),
  vehiclePlate: z.string(),
  etaMinutes: z.number().int().nonnegative().optional(),
});
export type CargoRequestMatched = z.infer<typeof CargoRequestMatchedSchema>;

export const CargoRequestStatusChangedSchema = z.object({
  orderId: z.string().uuid(),
  cargoRequestId: z.string().uuid(),
  status: z.enum([
    'created',
    'matching',
    'assigned',
    'picked_up',
    'in_transit',
    'delivered',
    'closed',
    'cancelled',
  ]),
});
export type CargoRequestStatusChanged = z.infer<typeof CargoRequestStatusChangedSchema>;

export const CargoRequestCompletedSchema = z.object({
  orderId: z.string().uuid(),
  cargoRequestId: z.string().uuid(),
  deliveredAt: z.string().datetime(),
  finalPrice: MoneySchema.optional(),
});
export type CargoRequestCompleted = z.infer<typeof CargoRequestCompletedSchema>;

export const CargoRequestFailedSchema = z.object({
  orderId: z.string().uuid(),
  cargoRequestId: z.string().uuid().optional(),
  reason: z.string(),
});
export type CargoRequestFailed = z.infer<typeof CargoRequestFailedSchema>;

/** Map routing key -> payload schema (single source of truth). */
export const PayloadSchemas = {
  [RoutingKeys.MaterialOrderCreated]: MaterialOrderCreatedSchema,
  [RoutingKeys.MaterialOrderCancelled]: MaterialOrderCancelledSchema,
  [RoutingKeys.CargoRequestMatched]: CargoRequestMatchedSchema,
  [RoutingKeys.CargoRequestStatusChanged]: CargoRequestStatusChangedSchema,
  [RoutingKeys.CargoRequestCompleted]: CargoRequestCompletedSchema,
  [RoutingKeys.CargoRequestFailed]: CargoRequestFailedSchema,
} as const satisfies Record<RoutingKey, z.ZodTypeAny>;

export type PayloadFor<K extends RoutingKey> = z.infer<(typeof PayloadSchemas)[K]>;
