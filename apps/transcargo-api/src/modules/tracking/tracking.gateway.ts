import {
  ConnectedSocket,
  MessageBody,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import type { Server, Socket } from 'socket.io';
import { PrismaService } from '../../prisma/prisma.module';

interface PingPayload {
  cargoRequestId: string;
  lat: number;
  lng: number;
  speedKph?: number;
}

@WebSocketGateway({ namespace: '/tracking', cors: { origin: '*' } })
export class TrackingGateway {
  @WebSocketServer()
  server!: Server;

  constructor(private readonly prisma: PrismaService) {}

  @SubscribeMessage('driver:ping')
  async onDriverPing(@MessageBody() data: PingPayload, @ConnectedSocket() _socket: Socket) {
    await this.prisma.trackingPoint.create({
      data: {
        cargoRequestId: data.cargoRequestId,
        lat: data.lat,
        lng: data.lng,
        speedKph: data.speedKph,
      },
    });
    this.server.to(`request:${data.cargoRequestId}`).emit('tracking:update', data);
    return { ok: true };
  }

  @SubscribeMessage('subscribe')
  onSubscribe(@MessageBody() data: { cargoRequestId: string }, @ConnectedSocket() socket: Socket) {
    socket.join(`request:${data.cargoRequestId}`);
    return { joined: data.cargoRequestId };
  }
}
