import { Body, Controller, Injectable, Logger, Module, Post, UseGuards } from '@nestjs/common';
import { IsEnum, IsNumber, IsString } from 'class-validator';
import { PaymentProvider } from '@prisma/client';
import { JwtAuthGuard } from '../auth/guards';

@Injectable()
export class PaymentsService {
  private readonly logger = new Logger(PaymentsService.name);

  init(input: { orderId: string; amount: number; currency: string; provider: PaymentProvider }) {
    this.logger.warn(`[STUB] Payment init: ${JSON.stringify(input)}`);
    return Promise.resolve({
      redirectUrl: `https://example.test/pay/${input.provider.toLowerCase()}/${input.orderId}`,
      externalId: `stub_${Date.now()}`,
    });
  }
}

class InitPaymentDto {
  @IsString() orderId!: string;
  @IsNumber() amount!: number;
  @IsString() currency!: string;
  @IsEnum(PaymentProvider) provider!: PaymentProvider;
}

@Controller('payments')
@UseGuards(JwtAuthGuard)
export class PaymentsController {
  constructor(private readonly svc: PaymentsService) {}
  @Post('init') init(@Body() dto: InitPaymentDto) {
    return this.svc.init(dto);
  }
}

@Module({ controllers: [PaymentsController], providers: [PaymentsService] })
export class PaymentsModule {}
