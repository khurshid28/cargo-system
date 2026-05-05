import { useQuery } from '@tanstack/react-query';
import { Card } from '@cargos/ui-kit';
import { api } from '../lib/api';

export function CargoRequestsPage() {
  const { data = [], isLoading } = useQuery({
    queryKey: ['cargo-requests'],
    queryFn: async () => (await api.get('/cargo-requests/mine')).data as Array<Record<string, any>>,
  });

  return (
    <div>
      <h1 className="mb-6 text-2xl font-semibold">Cargo Requests</h1>
      <Card>
        {isLoading ? (
          <div>Yuklanmoqda...</div>
        ) : (
          <table className="w-full text-sm">
            <thead className="text-left text-slate-500">
              <tr>
                <th className="py-2">ID</th>
                <th>Pickup</th>
                <th>Dropoff</th>
                <th>Status</th>
                <th>Yaratilgan</th>
              </tr>
            </thead>
            <tbody>
              {data.map((r) => (
                <tr key={r.id} className="border-t border-slate-100">
                  <td className="py-2 font-mono text-xs">{r.id.slice(0, 8)}</td>
                  <td>{r.pickupAddress}</td>
                  <td>{r.dropoffAddress}</td>
                  <td><span className="rounded bg-brand-100 px-2 py-0.5 text-brand-800 text-xs">{r.status}</span></td>
                  <td className="text-slate-500">{new Date(r.createdAt).toLocaleString()}</td>
                </tr>
              ))}
              {data.length === 0 && <tr><td colSpan={5} className="py-6 text-center text-slate-400">Hech narsa yo‘q</td></tr>}
            </tbody>
          </table>
        )}
      </Card>
    </div>
  );
}
