import axios from 'axios';
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface AuthUser { id: string; role: 'CUSTOMER' | 'MERCHANT' | 'ADMIN'; phone: string; }

interface AuthState {
  accessToken: string | null;
  refreshToken: string | null;
  user: AuthUser | null;
  setSession: (d: { accessToken: string; refreshToken: string; user: AuthUser }) => void;
  clear: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      accessToken: null,
      refreshToken: null,
      user: null,
      setSession: (d) => set(d),
      clear: () => set({ accessToken: null, refreshToken: null, user: null }),
    }),
    { name: 'mm-admin-auth' },
  ),
);

export const api = axios.create({ baseURL: '/api' });
api.interceptors.request.use((c) => {
  const t = useAuthStore.getState().accessToken;
  if (t) c.headers.Authorization = `Bearer ${t}`;
  return c;
});
api.interceptors.response.use(
  (r) => r,
  (err) => {
    if (err.response?.status === 401) useAuthStore.getState().clear();
    return Promise.reject(err);
  },
);
