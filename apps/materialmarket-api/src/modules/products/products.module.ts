import { Body, Controller, Get, Module, Param, Post, Query, Req, UseGuards } from '@nestjs/common';
import { IsArray, IsNumber, IsOptional, IsString } from 'class-validator';
import { JwtAuthGuard, Roles, RolesGuard } from '../auth/guards';
import { UserRole } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.module';

class CreateProductDto {
  @IsString() categoryId!: string;
  @IsString() nameUz!: string;
  @IsString() nameRu!: string;
  @IsOptional() @IsString() descriptionUz?: string;
  @IsOptional() @IsString() descriptionRu?: string;
  @IsNumber() price!: number;
  @IsString() unit!: string;
  @IsOptional() @IsString() bodyKind?: string;
  @IsOptional() @IsNumber() weightPerUnitKg?: number;
  @IsOptional() @IsNumber() stock?: number;
  @IsOptional() @IsArray() photos?: string[];
}

@Controller('products')
export class ProductsController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  list(@Query('categoryId') categoryId?: string, @Query('q') q?: string) {
    return this.prisma.product.findMany({
      where: {
        active: true,
        ...(categoryId ? { categoryId } : {}),
        ...(q
          ? {
              OR: [
                { nameUz: { contains: q, mode: 'insensitive' } },
                { nameRu: { contains: q, mode: 'insensitive' } },
              ],
            }
          : {}),
      },
      take: 100,
      orderBy: { createdAt: 'desc' },
    });
  }

  @Get(':id')
  byId(@Param('id') id: string) {
    return this.prisma.product.findUnique({
      where: { id },
      include: { merchant: true, category: true },
    });
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.MERCHANT)
  async create(@Req() req: { user: { userId: string } }, @Body() dto: CreateProductDto) {
    const merchant = await this.prisma.merchant.findUniqueOrThrow({
      where: { ownerId: req.user.userId },
    });
    return this.prisma.product.create({ data: { ...dto, merchantId: merchant.id } });
  }
}

@Module({ controllers: [ProductsController] })
export class ProductsModule {}
