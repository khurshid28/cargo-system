import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
import { IsInt, IsOptional, IsString, Min } from 'class-validator';
import { JwtAuthGuard, Roles, RolesGuard } from '../auth/guards';
import { UserRole } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.module';

class CreateVehicleDto {
  @IsString() plate!: string;
  @IsString() bodyKind!: string;
  @IsInt() @Min(1) capacityKg!: number;
  @IsOptional() volumeM3?: number;
}

@Controller('vehicles')
@UseGuards(JwtAuthGuard, RolesGuard)
export class VehiclesController {
  constructor(private readonly prisma: PrismaService) {}

  @Get('mine')
  @Roles(UserRole.DRIVER, UserRole.ADMIN)
  mine(@Req() req: { user: { userId: string } }) {
    return this.prisma.vehicle.findMany({ where: { ownerId: req.user.userId } });
  }

  @Post()
  @Roles(UserRole.DRIVER)
  create(@Req() req: { user: { userId: string } }, @Body() dto: CreateVehicleDto) {
    return this.prisma.vehicle.create({ data: { ...dto, ownerId: req.user.userId } });
  }
}
