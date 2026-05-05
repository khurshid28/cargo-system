import { useQuery } from '@tanstack/react-query';
import { Card } from '@cargos/ui-kit';
import { api, useAuthStore } from '../lib/api';

export function DashboardPage() {
  const role = useAuthStore((s) => s.user?.role);
  const { data, isLoading } = useQuery({
    queryKey: ['mm-stats'],
    queryFn: async () => (await api.get('/admin/stats')).data,
    enabled: role === 'ADMIN',
  });

  if (role !== 'ADMIN') {
    return (
      <div>
        <h1 className="mb-6 text-2xl font-semibold">Merchant Dashboard</h1>
        <Card><p className="text-slate-500">O‘z mahsulot va zakazlaringizni boshqaring.</p></Card>
      </div>
    );
  }

  if (isLoading) return <div>Yuklanmoqda...</div>;
  const items = [
    { label: 'Foydalanuvchilar', value: data?.users ?? 0 },
    { label: 'Merchantlar', value: data?.merchants ?? 0 },
    { label: 'Mahsulotlar', value: data?.products ?? 0 },
    { label: 'Zakazlar', value: data?.orders ?? 0 },
  ];
  return (
    <div>
      <h1 className="mb-6 text-2xl font-semibold">Super Admin Dashboard</h1>
      <div className="grid grid-cols-4 gap-4">
        {items.map((it) => (
          <Card key={it.label} title={it.label}>
            <div className="text-3xl font-bold text-emerald-600">{it.value}</div>
          </Card>
        ))}
      </div>
    </div>
  );
}
