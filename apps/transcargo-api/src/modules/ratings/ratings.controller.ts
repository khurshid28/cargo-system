import { Body, Controller, Post, Req, UseGuards } from '@nestjs/common';
import { IsInt, IsOptional, IsString, Max, Min } from 'class-validator';
import { JwtAuthGuard } from '../auth/guards';
import { PrismaService } from '../../prisma/prisma.module';

class CreateRatingDto {
  @IsString() cargoRequestId!: string;
  @IsString() toUserId!: string;
  @IsInt() @Min(1) @Max(5) stars!: number;
  @IsOptional() @IsString() comment?: string;
}

@Controller('ratings')
@UseGuards(JwtAuthGuard)
export class RatingsController {
  constructor(private readonly prisma: PrismaService) {}

  @Post()
  create(@Req() req: { user: { userId: string } }, @Body() dto: CreateRatingDto) {
    return this.prisma.rating.create({
      data: { ...dto, fromUserId: req.user.userId },
    });
  }
}
