import {
  ArrayMinSize,
  IsArray,
  IsNumber,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

export class OrderItemDto {
  @IsString() productId!: string;
  @IsNumber() quantity!: number;
}

export class CreateOrderDto {
  @IsString() merchantId!: string;
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => OrderItemDto)
  items!: OrderItemDto[];
  @IsString() deliveryAddress!: string;
  @IsNumber() deliveryLat!: number;
  @IsNumber() deliveryLng!: number;
  @IsOptional() @IsString() scheduledAt?: string;
}
