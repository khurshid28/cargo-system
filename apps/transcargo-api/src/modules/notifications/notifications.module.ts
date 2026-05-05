import { Injectable, Logger, Module } from '@nestjs/common';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  /** Send FCM push to a user's devices. Stub. */
  async pushToUser(
    userId: string,
    payload: { title: string; body: string; data?: Record<string, string> },
  ) {
    this.logger.log(`[STUB][FCM->${userId}] ${payload.title}: ${payload.body}`);
  }

  /** Send SMS via Eskiz/Playmobile. In test mode it's a no-op. */
  async sms(phone: string, message: string) {
    this.logger.log(`[STUB][SMS->${phone}] ${message}`);
  }
}

@Module({ providers: [NotificationsService], exports: [NotificationsService] })
export class NotificationsModule {}
