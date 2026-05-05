import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Button, Card } from '@cargos/ui-kit';
import { api } from '../lib/api';

export function OrdersPage() {
  const qc = useQueryClient();
  const { data = [], isLoading } = useQuery({
    queryKey: ['orders'],
    queryFn: async () => (await api.get('/orders/mine')).data as Array<Record<string, any>>,
  });
  const confirm = useMutation({
    mutationFn: async (id: string) => (await api.post(`/orders/${id}/confirm`)).data,
    onSuccess: () => qc.invalidateQueries({ queryKey: ['orders'] }),
  });

  return (
    <div>
      <h1 className="mb-6 text-2xl font-semibold">Zakazlar</h1>
      <Card>
        {isLoading ? <div>Yuklanmoqda...</div> : (
          <table className="w-full text-sm">
            <thead className="text-left text-slate-500">
              <tr><th className="py-2">ID</th><th>Status</th><th>Manzil</th><th>Summa</th><th>Driver</th><th></th></tr>
            </thead>
            <tbody>
              {data.map((o) => (
                <tr key={o.id} className="border-t border-slate-100">
                  <td className="py-2 font-mono text-xs">{o.id.slice(0, 8)}</td>
                  <td><span className="rounded bg-emerald-100 px-2 py-0.5 text-emerald-800 text-xs">{o.status}</span></td>
                  <td>{o.deliveryAddress}</td>
                  <td>{o.totalAmount.toLocaleString()} {o.currency}</td>
                  <td>{o.driverName ? `${o.driverName} (${o.vehiclePlate})` : '—'}</td>
                  <td>{o.status === 'CREATED' && (
                    <Button variant="primary" loading={confirm.isPending} onClick={() => confirm.mutate(o.id)}>Tasdiqlash</Button>
                  )}</td>
                </tr>
              ))}
              {data.length === 0 && <tr><td colSpan={6} className="py-6 text-center text-slate-400">Zakaz yo‘q</td></tr>}
            </tbody>
          </table>
        )}
      </Card>
    </div>
  );
}
