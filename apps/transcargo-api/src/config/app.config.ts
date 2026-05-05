import { registerAs } from '@nestjs/config';

export interface AppConfig {
  port: number;
  corsOrigins: string[];
  jwt: {
    accessSecret: string;
    refreshSecret: string;
    accessTtl: string;
    refreshTtl: string;
  };
  auth: {
    testMode: boolean;
    testOtp: string;
  };
  redisUrl: string;
  rabbitmqUrl: string;
}

export const appConfig = registerAs(
  'APP_CONFIG',
  (): AppConfig => ({
    port: parseInt(process.env.PORT ?? '3001', 10),
    corsOrigins: (process.env.CORS_ORIGINS ?? 'http://localhost:5173')
      .split(',')
      .map((s) => s.trim()),
    jwt: {
      accessSecret: process.env.JWT_ACCESS_SECRET ?? 'dev_access',
      refreshSecret: process.env.JWT_REFRESH_SECRET ?? 'dev_refresh',
      accessTtl: process.env.JWT_ACCESS_TTL ?? '15m',
      refreshTtl: process.env.JWT_REFRESH_TTL ?? '30d',
    },
    auth: {
      testMode: (process.env.AUTH_TEST_MODE ?? 'true').toLowerCase() === 'true',
      testOtp: process.env.AUTH_TEST_OTP ?? '666666',
    },
    redisUrl: process.env.REDIS_URL ?? 'redis://localhost:6379/0',
    rabbitmqUrl: process.env.RABBITMQ_URL ?? 'amqp://cargos:cargos_dev_pass@localhost:5672',
  }),
);
