import { Body, Controller, Get, Param, Post, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard, Roles, RolesGuard } from '../auth/guards';
import { UserRole } from '@prisma/client';
import { CargoRequestsService } from './cargo-requests.service';
import { CreateCargoRequestDto } from './dto';

@Controller('cargo-requests')
@UseGuards(JwtAuthGuard, RolesGuard)
export class CargoRequestsController {
  constructor(private readonly svc: CargoRequestsService) {}

  @Post()
  @Roles(UserRole.SENDER, UserRole.ADMIN)
  create(@Req() req: { user: { userId: string } }, @Body() dto: CreateCargoRequestDto) {
    return this.svc.create({ ...dto, senderId: req.user.userId });
  }

  @Get('mine')
  mine(@Req() req: { user: { userId: string; role: UserRole } }) {
    return req.user.role === UserRole.DRIVER
      ? this.svc.list({ driverId: req.user.userId })
      : this.svc.list({ senderId: req.user.userId });
  }

  @Get(':id')
  byId(@Param('id') id: string) {
    return this.svc.byId(id);
  }
}
