import { IsNumber, IsOptional, IsString, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

class GeoDto {
  @IsString() address!: string;
  @IsNumber() lat!: number;
  @IsNumber() lng!: number;
}

export class CreateCargoRequestDto {
  @ValidateNested() @Type(() => GeoDto) pickup!: GeoDto;
  @ValidateNested() @Type(() => GeoDto) dropoff!: GeoDto;
  @IsString() cargoType!: string;
  @IsNumber() weightKg!: number;
  @IsOptional() @IsNumber() volumeM3?: number;
  @IsOptional() @IsString() bodyKind?: string;
  @IsOptional() @IsString() notes?: string;
  @IsOptional() @IsNumber() priceAmount?: number;
  @IsOptional() @IsString() scheduledAt?: string;
}
