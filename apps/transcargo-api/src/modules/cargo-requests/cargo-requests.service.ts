import { Injectable } from '@nestjs/common';
import { CargoRequestStatus, type CargoRequest } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.module';
import { CreateCargoRequestDto } from './dto';

export interface CreateCargoRequestInput extends CreateCargoRequestDto {
  senderId: string;
  externalOrderId?: string;
}

@Injectable()
export class CargoRequestsService {
  constructor(private readonly prisma: PrismaService) {}

  create(input: CreateCargoRequestInput): Promise<CargoRequest> {
    return this.prisma.cargoRequest.create({
      data: {
        senderId: input.senderId,
        externalOrderId: input.externalOrderId,
        pickupAddress: input.pickup.address,
        pickupLat: input.pickup.lat,
        pickupLng: input.pickup.lng,
        dropoffAddress: input.dropoff.address,
        dropoffLat: input.dropoff.lat,
        dropoffLng: input.dropoff.lng,
        cargoType: input.cargoType,
        weightKg: input.weightKg,
        volumeM3: input.volumeM3,
        bodyKind: input.bodyKind,
        notes: input.notes,
        priceAmount: input.priceAmount,
        scheduledAt: input.scheduledAt ? new Date(input.scheduledAt) : null,
        status: CargoRequestStatus.CREATED,
      },
    });
  }

  list(filter: { status?: CargoRequestStatus; senderId?: string; driverId?: string }) {
    return this.prisma.cargoRequest.findMany({
      where: filter,
      orderBy: { createdAt: 'desc' },
      take: 100,
    });
  }

  byId(id: string) {
    return this.prisma.cargoRequest.findUnique({ where: { id } });
  }

  setStatus(id: string, status: CargoRequestStatus) {
    return this.prisma.cargoRequest.update({ where: { id }, data: { status } });
  }
}
