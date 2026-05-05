import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  Module,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard, Roles, RolesGuard } from '../auth/guards';
import { UserRole, UserStatus } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.module';

const isUuid = (v: string) =>
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v);
const PHONE_RE = /^\+?[0-9]{9,15}$/;

@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
export class AdminController {
  constructor(private readonly prisma: PrismaService) {}

  @Get('stats')
  async stats() {
    const [users, merchants, products, orders, blocked] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.merchant.count(),
      this.prisma.product.count(),
      this.prisma.order.count(),
      this.prisma.user.count({ where: { status: UserStatus.BLOCKED } }),
    ]);
    return { users, merchants, products, orders, blocked };
  }

  @Get('users')
  async listUsers(
    @Query('q') q?: string,
    @Query('role') role?: UserRole,
    @Query('status') status?: UserStatus,
    @Query('take') take = '50',
    @Query('skip') skip = '0',
  ) {
    const where: any = {};
    if (role) where.role = role;
    if (status) where.status = status;
    if (q && q.trim().length > 0) {
      where.OR = [
        { phone: { contains: q, mode: 'insensitive' } },
        { fullName: { contains: q, mode: 'insensitive' } },
      ];
    }
    const [items, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        take: Math.min(Number(take) || 50, 200),
        skip: Math.max(Number(skip) || 0, 0),
      }),
      this.prisma.user.count({ where }),
    ]);
    return { items, total };
  }

  @Post('users')
  async createUser(
    @Body()
    body: {
      phone: string;
      fullName?: string;
      role: UserRole;
      language?: string;
    },
  ) {
    if (!body?.phone || !PHONE_RE.test(body.phone)) {
      throw new BadRequestException('Invalid phone');
    }
    if (!body.role || !Object.values(UserRole).includes(body.role)) {
      throw new BadRequestException('Invalid role');
    }
    const exists = await this.prisma.user.findUnique({ where: { phone: body.phone } });
    if (exists) throw new BadRequestException('Phone already in use');
    return this.prisma.user.create({
      data: {
        phone: body.phone,
        fullName: body.fullName ?? null,
        role: body.role,
        language: body.language ?? 'uz',
      },
    });
  }

  @Patch('users/:id')
  async updateUser(
    @Param('id') id: string,
    @Body()
    body: { fullName?: string; role?: UserRole; status?: UserStatus; language?: string },
  ) {
    if (!isUuid(id)) throw new BadRequestException('Invalid id');
    return this.prisma.user.update({
      where: { id },
      data: {
        fullName: body.fullName,
        role: body.role,
        status: body.status,
        language: body.language,
      },
    });
  }

  @Post('users/:id/block')
  async block(@Param('id') id: string) {
    if (!isUuid(id)) throw new BadRequestException('Invalid id');
    return this.prisma.user.update({
      where: { id },
      data: { status: UserStatus.BLOCKED },
    });
  }

  @Post('users/:id/unblock')
  async unblock(@Param('id') id: string) {
    if (!isUuid(id)) throw new BadRequestException('Invalid id');
    return this.prisma.user.update({
      where: { id },
      data: { status: UserStatus.ACTIVE },
    });
  }

  @Delete('users/:id')
  async remove(@Param('id') id: string) {
    if (!isUuid(id)) throw new BadRequestException('Invalid id');
    await this.prisma.user.delete({ where: { id } });
    return { ok: true };
  }
}

@Module({ controllers: [AdminController] })
export class AdminModule {}
