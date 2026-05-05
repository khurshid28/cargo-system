import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { IsEnum, IsNumber, IsString } from 'class-validator';
import { PaymentProvider } from '@prisma/client';
import { JwtAuthGuard } from '../auth/guards';
import { PaymentsService } from './payments.service';

class InitPaymentDto {
  @IsString() cargoRequestId!: string;
  @IsNumber() amount!: number;
  @IsString() currency!: string;
  @IsEnum(PaymentProvider) provider!: PaymentProvider;
}

@Controller('payments')
@UseGuards(JwtAuthGuard)
export class PaymentsController {
  constructor(private readonly svc: PaymentsService) {}

  @Post('init')
  init(@Body() dto: InitPaymentDto) {
    return this.svc.init(dto);
  }
}
