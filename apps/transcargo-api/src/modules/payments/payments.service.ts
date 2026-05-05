import { Injectable, Logger } from '@nestjs/common';
import type { PaymentProvider } from '@prisma/client';

export interface InitPaymentInput {
  cargoRequestId: string;
  amount: number;
  currency: string;
  provider: PaymentProvider;
}

export interface InitPaymentResult {
  redirectUrl: string;
  externalId: string;
}

/**
 * Adapter interface implemented by Click, Payme, Uzum providers.
 * Real provider impls live in `./providers/*.ts` and validate webhook signatures.
 */
export interface PaymentProviderAdapter {
  init(input: InitPaymentInput): Promise<InitPaymentResult>;
  verifyWebhook(headers: Record<string, string>, rawBody: Buffer): boolean;
  parseWebhook(payload: unknown): { externalId: string; status: 'SUCCEEDED' | 'FAILED' };
}

@Injectable()
export class PaymentsService {
  private readonly logger = new Logger(PaymentsService.name);

  // TODO: inject ClickAdapter, PaymeAdapter, UzumAdapter and route by provider.
  init(input: InitPaymentInput): Promise<InitPaymentResult> {
    this.logger.warn(`[STUB] Payment init: ${JSON.stringify(input)}`);
    return Promise.resolve({
      redirectUrl: `https://example.test/pay/${input.provider.toLowerCase()}/${input.cargoRequestId}`,
      externalId: `stub_${Date.now()}`,
    });
  }
}
