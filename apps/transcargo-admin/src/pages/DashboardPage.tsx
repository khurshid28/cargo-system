import { useQuery } from '@tanstack/react-query';
import { Card } from '@cargos/ui-kit';
import { api } from '../lib/api';

export function DashboardPage() {
  const { data, isLoading } = useQuery({
    queryKey: ['admin-stats'],
    queryFn: async () => (await api.get('/admin/stats')).data,
  });

  if (isLoading) return <div>Yuklanmoqda...</div>;

  const items = [
    { label: 'Foydalanuvchilar', value: data?.users ?? 0 },
    { label: 'Haydovchilar', value: data?.drivers ?? 0 },
    { label: 'Mashinalar', value: data?.vehicles ?? 0 },
    { label: 'So‘rovlar', value: data?.requests ?? 0 },
  ];

  return (
    <div>
      <h1 className="mb-6 text-2xl font-semibold">Dashboard</h1>
      <div className="grid grid-cols-4 gap-4">
        {items.map((it) => (
          <Card key={it.label} title={it.label}>
            <div className="text-3xl font-bold text-brand-600">{it.value}</div>
          </Card>
        ))}
      </div>
    </div>
  );
}
