import { Module } from '@nestjs/common';
import { RabbitMQService } from './rabbitmq.service';
import { MaterialOrderConsumer } from './material-order.consumer';
import { CargoRequestsModule } from '../cargo-requests/cargo-requests.module';

@Module({
  imports: [CargoRequestsModule],
  providers: [RabbitMQService, MaterialOrderConsumer],
  exports: [RabbitMQService],
})
export class EventsModule {}
