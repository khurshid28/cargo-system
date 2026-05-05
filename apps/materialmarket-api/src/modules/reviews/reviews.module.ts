import { Body, Controller, Module, Post, Req, UseGuards } from '@nestjs/common';
import { IsInt, IsOptional, IsString, Max, Min } from 'class-validator';
import { JwtAuthGuard } from '../auth/guards';
import { PrismaService } from '../../prisma/prisma.module';

class CreateReviewDto {
  @IsString() productId!: string;
  @IsInt() @Min(1) @Max(5) stars!: number;
  @IsOptional() @IsString() comment?: string;
}

@Controller('reviews')
@UseGuards(JwtAuthGuard)
export class ReviewsController {
  constructor(private readonly prisma: PrismaService) {}

  @Post()
  create(@Req() req: { user: { userId: string } }, @Body() dto: CreateReviewDto) {
    return this.prisma.review.create({ data: { ...dto, authorId: req.user.userId } });
  }
}

@Module({ controllers: [ReviewsController] })
export class ReviewsModule {}
