export const fmtMoney = (v: number) =>
  new Intl.NumberFormat('uz-UZ', { maximumFractionDigits: 0 }).format(v) + ' so‘m';

export const fmtDate = (iso: string) =>
  new Date(iso).toLocaleString('uz-UZ', {
    day: '2-digit',
    month: 'short',
    hour: '2-digit',
    minute: '2-digit',
  });

export const statusLabel: Record<string, string> = {
  PENDING: 'Kutilmoqda',
  ASSIGNED: 'Tayinlandi',
  PICKED_UP: 'Olib chiqildi',
  IN_TRANSIT: 'Yo‘lda',
  DELIVERED: 'Yetkazildi',
  CANCELLED: 'Bekor qilindi',
};

export const statusColor: Record<string, string> = {
  PENDING: 'bg-amber-100 text-amber-700',
  ASSIGNED: 'bg-indigo-100 text-indigo-700',
  PICKED_UP: 'bg-sky-100 text-sky-700',
  IN_TRANSIT: 'bg-orange-100 text-orange-700',
  DELIVERED: 'bg-emerald-100 text-emerald-700',
  CANCELLED: 'bg-rose-100 text-rose-700',
};
