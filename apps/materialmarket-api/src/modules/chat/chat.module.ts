import { Body, Controller, Get, Module, Param, Post, Req, UseGuards } from '@nestjs/common';
import { IsString } from 'class-validator';
import { JwtAuthGuard } from '../auth/guards';
import { PrismaService } from '../../prisma/prisma.module';

class SendMessageDto {
  @IsString() orderId!: string;
  @IsString() body!: string;
}

@Controller('chat')
@UseGuards(JwtAuthGuard)
export class ChatController {
  constructor(private readonly prisma: PrismaService) {}

  @Get(':orderId')
  list(@Param('orderId') orderId: string) {
    return this.prisma.chatMessage.findMany({
      where: { orderId },
      orderBy: { createdAt: 'asc' },
      take: 200,
    });
  }

  @Post()
  send(@Req() req: { user: { userId: string } }, @Body() dto: SendMessageDto) {
    return this.prisma.chatMessage.create({
      data: { orderId: dto.orderId, senderId: req.user.userId, body: dto.body },
    });
  }
}

@Module({ controllers: [ChatController] })
export class ChatModule {}
