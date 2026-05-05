import { z } from 'zod';

/** Geographic point (WGS84). */
export const GeoPointSchema = z.object({
  lat: z.number().min(-90).max(90),
  lng: z.number().min(-180).max(180),
});
export type GeoPoint = z.infer<typeof GeoPointSchema>;

/** Address with optional resolved coordinates. */
export const AddressSchema = z.object({
  raw: z.string().min(1),
  region: z.string().optional(),
  city: z.string().optional(),
  point: GeoPointSchema,
});
export type Address = z.infer<typeof AddressSchema>;

/** Cargo specification used by both projects. */
export const CargoSpecSchema = z.object({
  /** e.g. "coal", "brick", "gravel", "general" */
  type: z.string().min(1),
  weightKg: z.number().positive(),
  volumeM3: z.number().positive().optional(),
  /** required vehicle body kind, e.g. "tipper", "flatbed", "tent" */
  bodyKind: z.string().optional(),
  notes: z.string().max(2000).optional(),
});
export type CargoSpec = z.infer<typeof CargoSpecSchema>;

/** Money amount with ISO currency. */
export const MoneySchema = z.object({
  amount: z.number().nonnegative(),
  currency: z.string().length(3).default('UZS'),
});
export type Money = z.infer<typeof MoneySchema>;
