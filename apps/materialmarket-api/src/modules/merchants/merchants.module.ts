import { Body, Controller, Get, Module, Post, Req, UseGuards } from '@nestjs/common';
import { IsNumber, IsOptional, IsString } from 'class-validator';
import { JwtAuthGuard, Roles, RolesGuard } from '../auth/guards';
import { UserRole } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.module';

class CreateMerchantDto {
  @IsString() name!: string;
  @IsOptional() @IsString() description?: string;
  @IsString() warehouseAddress!: string;
  @IsNumber() warehouseLat!: number;
  @IsNumber() warehouseLng!: number;
}

@Controller('merchants')
@UseGuards(JwtAuthGuard, RolesGuard)
export class MerchantsController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  list() {
    return this.prisma.merchant.findMany({ where: { verifiedAt: { not: null } } });
  }

  @Get('mine')
  @Roles(UserRole.MERCHANT)
  mine(@Req() req: { user: { userId: string } }) {
    return this.prisma.merchant.findUnique({ where: { ownerId: req.user.userId } });
  }

  @Post()
  @Roles(UserRole.MERCHANT)
  create(@Req() req: { user: { userId: string } }, @Body() dto: CreateMerchantDto) {
    return this.prisma.merchant.create({ data: { ...dto, ownerId: req.user.userId } });
  }
}

@Module({ controllers: [MerchantsController] })
export class MerchantsModule {}
