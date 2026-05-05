import { Controller, Get, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards';
import { PrismaService } from '../../prisma/prisma.module';

@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly prisma: PrismaService) {}

  @Get('me')
  async me(@Req() req: { user: { userId: string } }) {
    return this.prisma.user.findUnique({ where: { id: req.user.userId } });
  }
}
