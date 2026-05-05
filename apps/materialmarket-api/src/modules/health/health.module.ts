import { Controller, Get, Module } from '@nestjs/common';

@Controller('health')
export class HealthController {
  @Get() ping() {
    return { status: 'ok', service: 'materialmarket-api', timestamp: new Date().toISOString() };
  }
}

@Module({ controllers: [HealthController] })
export class HealthModule {}
