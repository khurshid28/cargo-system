import { Injectable, Logger, Module } from '@nestjs/common';

@Injectable()
export class DocumentsService {
  private readonly logger = new Logger(DocumentsService.name);

  /** Generate transport invoice/waybill PDF. Stub returns a placeholder URL. */
  async generateInvoice(cargoRequestId: string): Promise<{ url: string }> {
    this.logger.log(`[STUB] Invoice PDF for ${cargoRequestId}`);
    return { url: `/static/invoices/${cargoRequestId}.pdf` };
  }
}

@Module({ providers: [DocumentsService], exports: [DocumentsService] })
export class DocumentsModule {}
