import { useQuery } from '@tanstack/react-query';
import { Card } from '@cargos/ui-kit';
import { api } from '../lib/api';

export function ProductsPage() {
  const { data = [], isLoading } = useQuery({
    queryKey: ['products'],
    queryFn: async () => (await api.get('/products')).data as Array<Record<string, any>>,
  });

  return (
    <div>
      <h1 className="mb-6 text-2xl font-semibold">Mahsulotlar</h1>
      <Card>
        {isLoading ? <div>Yuklanmoqda...</div> : (
          <table className="w-full text-sm">
            <thead className="text-left text-slate-500">
              <tr><th className="py-2">Nomi</th><th>Narx</th><th>Birlik</th><th>Stok</th></tr>
            </thead>
            <tbody>
              {data.map((p) => (
                <tr key={p.id} className="border-t border-slate-100">
                  <td className="py-2">{p.nameUz}</td>
                  <td>{p.price.toLocaleString()} {p.currency}</td>
                  <td>{p.unit}</td>
                  <td>{p.stock}</td>
                </tr>
              ))}
              {data.length === 0 && <tr><td colSpan={4} className="py-6 text-center text-slate-400">Mahsulot yo‘q</td></tr>}
            </tbody>
          </table>
        )}
      </Card>
    </div>
  );
}
