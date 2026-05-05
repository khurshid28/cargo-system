import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface AuthUser {
  id: string;
  role: 'SENDER' | 'DRIVER' | 'ADMIN';
  phone: string;
}

interface AuthState {
  accessToken: string | null;
  refreshToken: string | null;
  user: AuthUser | null;
  setSession: (data: { accessToken: string; refreshToken: string; user: AuthUser }) => void;
  clear: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      accessToken: null,
      refreshToken: null,
      user: null,
      setSession: (data) => set(data),
      clear: () => set({ accessToken: null, refreshToken: null, user: null }),
    }),
    { name: 'tc-admin-auth' },
  ),
);
