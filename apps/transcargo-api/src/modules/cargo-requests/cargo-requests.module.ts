import { Module } from '@nestjs/common';
import { CargoRequestsController } from './cargo-requests.controller';
import { CargoRequestsService } from './cargo-requests.service';

@Module({
  controllers: [CargoRequestsController],
  providers: [CargoRequestsService],
  exports: [CargoRequestsService],
})
export class CargoRequestsModule {}
