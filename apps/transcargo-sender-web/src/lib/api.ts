// Simple in-memory mock + axios fallback. Toggle via VITE_USE_MOCK env or default true.
import axios from 'axios';

export const USE_MOCK =
  ((import.meta as any).env?.VITE_USE_MOCK ?? 'true').toString().toLowerCase() === 'true';

export const api = axios.create({
  baseURL: (import.meta as any).env?.VITE_API_BASE_URL ?? '/api',
  timeout: 12_000,
});

api.interceptors.request.use((cfg) => {
  const token = localStorage.getItem('access_token');
  if (token) cfg.headers.Authorization = `Bearer ${token}`;
  return cfg;
});

// ---- Domain types ----
export type CargoStatus =
  | 'PENDING'
  | 'ASSIGNED'
  | 'PICKED_UP'
  | 'IN_TRANSIT'
  | 'DELIVERED'
  | 'CANCELLED';

export interface CargoRequest {
  id: string;
  pickupAddress: string;
  dropoffAddress: string;
  cargoType: string;
  weightKg: number;
  priceUzs: number;
  status: CargoStatus;
  createdAt: string;
  driverName?: string;
  driverPhone?: string;
  vehiclePlate?: string;
}

// ---- Mock data ----
const seed: CargoRequest[] = [
  {
    id: 'r1',
    pickupAddress: 'Toshkent, Yashnobod, 12-uy',
    dropoffAddress: 'Samarqand, Registon ko‘ch., 5',
    cargoType: 'Mebel',
    weightKg: 320,
    priceUzs: 950000,
    status: 'IN_TRANSIT',
    createdAt: new Date(Date.now() - 3600_000 * 6).toISOString(),
    driverName: 'Akmal Karimov',
    driverPhone: '+998901234511',
    vehiclePlate: '01A123BC',
  },
  {
    id: 'r2',
    pickupAddress: 'Toshkent, Sergeli',
    dropoffAddress: 'Buxoro, Lyabi-Hauz',
    cargoType: 'Qurilish materiallari',
    weightKg: 1500,
    priceUzs: 2100000,
    status: 'DELIVERED',
    createdAt: new Date(Date.now() - 86_400_000 * 3).toISOString(),
    driverName: 'Bobur Tursunov',
    driverPhone: '+998935552233',
    vehiclePlate: '01D777EE',
  },
  {
    id: 'r3',
    pickupAddress: 'Toshkent, Chilonzor',
    dropoffAddress: 'Andijon markaz',
    cargoType: 'Texnika',
    weightKg: 220,
    priceUzs: 850000,
    status: 'PENDING',
    createdAt: new Date(Date.now() - 600_000).toISOString(),
  },
];

const store: { items: CargoRequest[] } = { items: [...seed] };
const sleep = (ms = 350) => new Promise((r) => setTimeout(r, ms));

export const SenderApi = {
  async login(phone: string, otp: string) {
    if (USE_MOCK) {
      await sleep(400);
      if (otp !== '666666') throw new Error('Noto‘g‘ri OTP. Test: 666666');
      const token = 'mock-jwt-' + Date.now();
      localStorage.setItem('access_token', token);
      localStorage.setItem('user', JSON.stringify({ id: 'u-sender-web', phone, role: 'SENDER' }));
      return { token };
    }
    await api.post('/auth/request-otp', { phone, role: 'SENDER' });
    const r = await api.post('/auth/verify-otp', { phone, otp, role: 'SENDER' });
    localStorage.setItem('access_token', r.data.accessToken);
    localStorage.setItem('user', JSON.stringify(r.data.user));
    return { token: r.data.accessToken };
  },

  async sendOtp(phone: string) {
    if (USE_MOCK) {
      await sleep(300);
      return;
    }
    await api.post('/auth/request-otp', { phone, role: 'SENDER' });
  },

  logout() {
    localStorage.removeItem('access_token');
    localStorage.removeItem('user');
  },

  currentUser(): { id: string; phone: string; role: string } | null {
    const raw = localStorage.getItem('user');
    return raw ? JSON.parse(raw) : null;
  },

  async listMine(): Promise<CargoRequest[]> {
    if (USE_MOCK) {
      await sleep();
      return [...store.items].reverse();
    }
    const r = await api.get('/cargo/mine');
    return r.data;
  },

  async create(input: Omit<CargoRequest, 'id' | 'status' | 'createdAt'>): Promise<CargoRequest> {
    if (USE_MOCK) {
      await sleep(500);
      const c: CargoRequest = {
        ...input,
        id: 'r-' + Date.now(),
        status: 'PENDING',
        createdAt: new Date().toISOString(),
      };
      store.items.push(c);
      return c;
    }
    const r = await api.post('/cargo', input);
    return r.data;
  },

  async cancel(id: string) {
    if (USE_MOCK) {
      await sleep();
      const c = store.items.find((x) => x.id === id);
      if (c && c.status === 'PENDING') c.status = 'CANCELLED';
      return;
    }
    await api.post(`/cargo/${id}/cancel`);
  },

  async stats() {
    if (USE_MOCK) {
      await sleep();
      return {
        balance: 850000,
        totalSpent: 12_500_000,
        totalShipments: store.items.length,
        active: store.items.filter((x) =>
          ['ASSIGNED', 'PICKED_UP', 'IN_TRANSIT'].includes(x.status),
        ).length,
        delivered: store.items.filter((x) => x.status === 'DELIVERED').length,
      };
    }
    const r = await api.get('/sender/stats');
    return r.data;
  },
};
