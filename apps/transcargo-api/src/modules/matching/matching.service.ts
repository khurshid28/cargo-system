import { Injectable, Logger } from '@nestjs/common';
import { CargoRequestStatus, DriverAvailability, UserRole } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.module';

/** Earth radius in km. */
const EARTH_R = 6371;

function haversineKm(aLat: number, aLng: number, bLat: number, bLng: number): number {
  const toRad = (x: number) => (x * Math.PI) / 180;
  const dLat = toRad(bLat - aLat);
  const dLng = toRad(bLng - aLng);
  const s =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(aLat)) * Math.cos(toRad(bLat)) * Math.sin(dLng / 2) ** 2;
  return 2 * EARTH_R * Math.asin(Math.sqrt(s));
}

@Injectable()
export class MatchingService {
  private readonly logger = new Logger(MatchingService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Find online drivers within radiusKm of pickup whose vehicle fits cargo.
   * Returns sorted by distance (closest first).
   *
   * NOTE: For production-scale, replace haversine in-memory filter with PostGIS
   * `ST_DWithin(geog, point, radius)` index query.
   */
  async findCandidates(params: {
    pickupLat: number;
    pickupLng: number;
    bodyKind?: string;
    weightKg: number;
    radiusKm?: number;
    limit?: number;
  }) {
    const radiusKm = params.radiusKm ?? 25;
    const limit = params.limit ?? 10;

    const drivers = await this.prisma.driverProfile.findMany({
      where: {
        availability: DriverAvailability.ONLINE,
        lastLat: { not: null },
        lastLng: { not: null },
        user: { status: 'ACTIVE', role: UserRole.DRIVER },
      },
      include: {
        user: { include: { vehicles: { where: { active: true } } } },
      },
    });

    const matches = drivers
      .map((d) => {
        const fittingVehicle = d.user.vehicles.find(
          (v) =>
            v.capacityKg >= params.weightKg && (!params.bodyKind || v.bodyKind === params.bodyKind),
        );
        if (!fittingVehicle || d.lastLat == null || d.lastLng == null) return null;
        const distanceKm = haversineKm(d.lastLat, d.lastLng, params.pickupLat, params.pickupLng);
        return { driver: d, vehicle: fittingVehicle, distanceKm };
      })
      .filter((x): x is NonNullable<typeof x> => x !== null && x.distanceKm <= radiusKm)
      .sort((a, b) => a.distanceKm - b.distanceKm)
      .slice(0, limit);

    this.logger.log(
      `Matching: pickup=(${params.pickupLat},${params.pickupLng}) found=${matches.length}`,
    );
    return matches;
  }

  async assignDriver(cargoRequestId: string, driverId: string, vehicleId: string) {
    return this.prisma.cargoRequest.update({
      where: { id: cargoRequestId },
      data: { driverId, vehicleId, status: CargoRequestStatus.ASSIGNED },
    });
  }
}
