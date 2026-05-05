import { Body, Controller, Get, Param, Post, Req, UseGuards } from '@nestjs/common';
import { IsString } from 'class-validator';
import { JwtAuthGuard } from '../auth/guards';
import { PrismaService } from '../../prisma/prisma.module';

class SendMessageDto {
  @IsString() cargoRequestId!: string;
  @IsString() body!: string;
}

@Controller('chat')
@UseGuards(JwtAuthGuard)
export class ChatController {
  constructor(private readonly prisma: PrismaService) {}

  @Get(':cargoRequestId')
  list(@Param('cargoRequestId') cargoRequestId: string) {
    return this.prisma.chatMessage.findMany({
      where: { cargoRequestId },
      orderBy: { createdAt: 'asc' },
      take: 200,
    });
  }

  @Post()
  send(@Req() req: { user: { userId: string } }, @Body() dto: SendMessageDto) {
    return this.prisma.chatMessage.create({
      data: { cargoRequestId: dto.cargoRequestId, senderId: req.user.userId, body: dto.body },
    });
  }
}
