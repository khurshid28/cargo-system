import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ConfigService } from '@nestjs/config';
import { ExtractJwt, Strategy } from 'passport-jwt';
import type { AppConfig } from '../../config/app.config';
import type { JwtPayload } from './auth.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(cfg: ConfigService) {
    const c = cfg.get<AppConfig>('APP_CONFIG')!;
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: c.jwt.accessSecret,
    });
  }
  validate(payload: JwtPayload) {
    return { userId: payload.sub, role: payload.role, phone: payload.phone };
  }
}
