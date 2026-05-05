import { Injectable, Logger, Module } from '@nestjs/common';

@Injectable()
export class DocumentsService {
  private readonly logger = new Logger(DocumentsService.name);
  async generateInvoice(orderId: string): Promise<{ url: string }> {
    this.logger.log(`[STUB] Invoice PDF for ${orderId}`);
    return { url: `/static/invoices/${orderId}.pdf` };
  }
}

@Module({ providers: [DocumentsService], exports: [DocumentsService] })
export class DocumentsModule {}
