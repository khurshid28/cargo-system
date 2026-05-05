import { Body, Controller, Get, Param, Post, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard, Roles, RolesGuard } from '../auth/guards';
import { UserRole } from '@prisma/client';
import { OrdersService } from './orders.service';
import { CreateOrderDto } from './dto';

@Controller('orders')
@UseGuards(JwtAuthGuard, RolesGuard)
export class OrdersController {
  constructor(private readonly svc: OrdersService) {}

  @Post()
  @Roles(UserRole.CUSTOMER)
  create(@Req() req: { user: { userId: string } }, @Body() dto: CreateOrderDto) {
    return this.svc.create(req.user.userId, dto);
  }

  @Post(':id/confirm')
  @Roles(UserRole.MERCHANT, UserRole.ADMIN)
  confirm(@Param('id') id: string) {
    return this.svc.confirm(id);
  }

  @Get('mine')
  mine(@Req() req: { user: { userId: string; role: UserRole } }) {
    return req.user.role === UserRole.MERCHANT
      ? this.svc.list({
          merchantId:
            req.user.userId /* note: merchant id mapped via Merchant.ownerId in real query */,
        })
      : this.svc.list({ customerId: req.user.userId });
  }

  @Get(':id')
  byId(@Param('id') id: string) {
    return this.svc.byId(id);
  }
}
