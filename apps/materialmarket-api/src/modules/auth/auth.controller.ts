import { Body, Controller, HttpCode, HttpStatus, Post } from '@nestjs/common';
import { IsEnum, IsString, Length, Matches } from 'class-validator';
import { UserRole } from '@prisma/client';
import { AuthService } from './auth.service';

class RequestOtpDto {
  @Matches(/^\+?\d{9,15}$/) phone!: string;
  @IsEnum(UserRole) role!: UserRole;
}
class VerifyOtpDto {
  @Matches(/^\+?\d{9,15}$/) phone!: string;
  @IsString() @Length(4, 8) otp!: string;
  @IsEnum(UserRole) role!: UserRole;
}
class RefreshDto {
  @IsString() refreshToken!: string;
}

@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('request-otp')
  @HttpCode(HttpStatus.OK)
  requestOtp(@Body() dto: RequestOtpDto) {
    return this.auth.requestOtp(dto.phone, dto.role);
  }

  @Post('verify-otp')
  @HttpCode(HttpStatus.OK)
  verifyOtp(@Body() dto: VerifyOtpDto) {
    return this.auth.verifyOtp(dto.phone, dto.otp, dto.role);
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  refresh(@Body() dto: RefreshDto) {
    return this.auth.refresh(dto.refreshToken);
  }
}
