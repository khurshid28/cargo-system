import { Injectable, Logger, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { UserRole, UserStatus } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.module';
import type { AppConfig } from '../../config/app.config';

export interface JwtPayload {
  sub: string;
  role: UserRole;
  phone: string;
}

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly cfg: ConfigService,
  ) {}

  private get config(): AppConfig {
    return this.cfg.get<AppConfig>('APP_CONFIG')!;
  }

  async requestOtp(phone: string, role: UserRole) {
    if (this.config.auth.testMode) {
      this.logger.warn(
        `[TEST MODE] OTP request ${phone} (${role}) — use "${this.config.auth.testOtp}".`,
      );
      return { ok: true, testMode: true };
    }
    this.logger.log(`OTP requested for ${phone} (${role})`);
    return { ok: true, testMode: false };
  }

  async verifyOtp(phone: string, otp: string, role: UserRole) {
    if (this.config.auth.testMode) {
      if (otp !== this.config.auth.testOtp)
        throw new UnauthorizedException('Invalid OTP (test mode expects 666666)');
    } else {
      throw new UnauthorizedException('SMS provider not configured');
    }
    const user = await this.prisma.user.upsert({
      where: { phone },
      create: { phone, role, status: UserStatus.ACTIVE },
      update: {},
    });
    if (user.status === UserStatus.BLOCKED) throw new UnauthorizedException('User is blocked');
    return this.issueTokens(user.id, user.role, user.phone);
  }

  async refresh(token: string) {
    try {
      const p = await this.jwt.verifyAsync<JwtPayload>(token, {
        secret: this.config.jwt.refreshSecret,
      });
      return this.issueTokens(p.sub, p.role, p.phone);
    } catch {
      throw new UnauthorizedException('Invalid refresh token');
    }
  }

  private async issueTokens(sub: string, role: UserRole, phone: string) {
    const payload: JwtPayload = { sub, role, phone };
    const [accessToken, refreshToken] = await Promise.all([
      this.jwt.signAsync(payload, {
        secret: this.config.jwt.accessSecret,
        expiresIn: this.config.jwt.accessTtl,
      }),
      this.jwt.signAsync(payload, {
        secret: this.config.jwt.refreshSecret,
        expiresIn: this.config.jwt.refreshTtl,
      }),
    ]);
    return { accessToken, refreshToken, user: { id: sub, role, phone } };
  }
}
