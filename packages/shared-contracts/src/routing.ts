/**
 * RabbitMQ exchange + routing key constants.
 * Topology: topic exchange `cargos.events`, durable queues per consumer.
 */
export const CARGOS_EXCHANGE = 'cargos.events';

export const RoutingKeys = {
  MaterialOrderCreated: 'material_order.created',
  MaterialOrderCancelled: 'material_order.cancelled',
  CargoRequestMatched: 'cargo_request.matched',
  CargoRequestStatusChanged: 'cargo_request.status_changed',
  CargoRequestCompleted: 'cargo_request.completed',
  CargoRequestFailed: 'cargo_request.failed',
} as const;

export type RoutingKey = (typeof RoutingKeys)[keyof typeof RoutingKeys];

export const Queues = {
  TranscargoMaterialOrders: 'transcargo.material_orders',
  MaterialmarketCargoUpdates: 'materialmarket.cargo_updates',
} as const;
