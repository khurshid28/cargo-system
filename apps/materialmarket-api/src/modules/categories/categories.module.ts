import { Body, Controller, Get, Module, Post, UseGuards } from '@nestjs/common';
import { IsOptional, IsString } from 'class-validator';
import { JwtAuthGuard, Roles, RolesGuard } from '../auth/guards';
import { UserRole } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.module';

class CreateCategoryDto {
  @IsString() slug!: string;
  @IsString() nameUz!: string;
  @IsString() nameRu!: string;
  @IsOptional() @IsString() icon?: string;
  @IsOptional() @IsString() parentId?: string;
}

@Controller('categories')
export class CategoriesController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  list() {
    return this.prisma.category.findMany({ orderBy: { nameUz: 'asc' } });
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  create(@Body() dto: CreateCategoryDto) {
    return this.prisma.category.create({ data: dto });
  }
}

@Module({ controllers: [CategoriesController] })
export class CategoriesModule {}
