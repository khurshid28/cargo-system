import { Module } from '@nestjs/common';
import { RabbitMQService } from './rabbitmq.service';
import { CargoUpdateConsumer } from './cargo-update.consumer';

@Module({
  providers: [RabbitMQService, CargoUpdateConsumer],
  exports: [RabbitMQService],
})
export class EventsModule {}
