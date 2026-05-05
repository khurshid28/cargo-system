import { useState } from 'react';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { motion, AnimatePresence } from 'framer-motion';
import { SearchNormal1, Filter, CloseSquare, Truck, Call } from 'iconsax-react';
import { SenderApi } from '../lib/api';
import { fmtDate, fmtMoney, statusColor, statusLabel } from '../lib/format';

const STATUSES = ['ALL','PENDING','ASSIGNED','PICKED_UP','IN_TRANSIT','DELIVERED','CANCELLED'];

export function OrdersPage() {
  const qc = useQueryClient();
  const [q, setQ] = useState('');
  const [status, setStatus] = useState('ALL');
  const [filterOpen, setFilterOpen] = useState(false);
  const [minPrice, setMinPrice] = useState(0);
  const [maxPrice, setMaxPrice] = useState(5_000_000);

  const orders = useQuery({ queryKey: ['orders'], queryFn: SenderApi.listMine });

  const filtered = (orders.data ?? []).filter((r) => {
    if (status !== 'ALL' && r.status !== status) return false;
    if (q && !`${r.pickupAddress} ${r.dropoffAddress} ${r.cargoType}`.toLowerCase().includes(q.toLowerCase())) return false;
    if (r.priceUzs < minPrice || r.priceUzs > maxPrice) return false;
    return true;
  });

  async function cancel(id: string) {
    if (!confirm('Bekor qilasizmi?')) return;
    await SenderApi.cancel(id);
    qc.invalidateQueries({ queryKey: ['orders'] });
  }

  return (
    <div className="p-8 max-w-7xl mx-auto">
      <h1 className="text-2xl font-bold mb-1">Buyurtmalar</h1>
      <p className="text-slate-500 mb-6">Barcha yuborilgan yuklar tarixi</p>

      <div className="flex items-center gap-3 mb-4">
        <div className="relative flex-1 max-w-md">
          <SearchNormal1 size={18} className="absolute left-3 top-3 text-slate-400" />
          <input value={q} onChange={(e) => setQ(e.target.value)}
            placeholder="Qidiruv: manzil, yuk turi..."
            className="w-full pl-10 pr-3 py-2.5 bg-white border border-slate-200 rounded-xl outline-none focus:border-brand-500" />
        </div>
        <button onClick={() => setFilterOpen(true)}
          className="inline-flex items-center gap-2 bg-white border border-slate-200 px-4 py-2.5 rounded-xl hover:bg-slate-50">
          <Filter size={18} /> Filter
        </button>
      </div>

      <div className="flex gap-2 mb-4 overflow-x-auto">
        {STATUSES.map((s) => (
          <button key={s} onClick={() => setStatus(s)}
            className={`px-3 py-1.5 rounded-full text-sm whitespace-nowrap transition ${
              status === s ? 'bg-brand-600 text-white' : 'bg-white border border-slate-200 hover:bg-slate-50'
            }`}>
            {s === 'ALL' ? 'Hammasi' : statusLabel[s]}
          </button>
        ))}
      </div>

      {orders.isLoading ? (
        <div className="space-y-3">
          {[...Array(5)].map((_, i) => <div key={i} className="skeleton h-24" />)}
        </div>
      ) : filtered.length === 0 ? (
        <div className="bg-white border rounded-2xl p-12 text-center text-slate-500">
          Hech narsa topilmadi
        </div>
      ) : (
        <div className="space-y-3">
          {filtered.map((r) => (
            <motion.div key={r.id} initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }}
              className="bg-white border border-slate-200 rounded-2xl p-5 flex items-start gap-5 hover:shadow-md transition">
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-2">
                  <span className={`px-2 py-0.5 rounded-md text-xs font-medium ${statusColor[r.status]}`}>
                    {statusLabel[r.status]}
                  </span>
                  <span className="text-xs text-slate-500">#{r.id.slice(0, 6).toUpperCase()}</span>
                  <span className="text-xs text-slate-500">· {fmtDate(r.createdAt)}</span>
                </div>
                <div className="font-semibold mb-1">
                  {r.pickupAddress} <span className="text-slate-400">→</span> {r.dropoffAddress}
                </div>
                <div className="text-sm text-slate-600">
                  {r.cargoType} · {r.weightKg} kg
                </div>
                {r.driverName && (
                  <div className="mt-3 flex items-center gap-3 bg-slate-50 rounded-lg px-3 py-2 text-sm">
                    <Truck size={16} className="text-brand-600" />
                    <div className="flex-1">
                      <div className="font-medium">{r.driverName}</div>
                      <div className="text-xs text-slate-500">{r.vehiclePlate}</div>
                    </div>
                    <a href={`tel:${r.driverPhone}`} className="flex items-center gap-1 text-emerald-600 hover:underline">
                      <Call size={14} /> {r.driverPhone}
                    </a>
                  </div>
                )}
              </div>
              <div className="text-right">
                <div className="text-xl font-bold text-brand-700">{fmtMoney(r.priceUzs)}</div>
                {r.status === 'PENDING' && (
                  <button onClick={() => cancel(r.id)}
                    className="mt-2 text-sm text-rose-600 hover:underline">Bekor qilish</button>
                )}
              </div>
            </motion.div>
          ))}
        </div>
      )}

      <AnimatePresence>
        {filterOpen && (
          <>
            <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
              onClick={() => setFilterOpen(false)}
              className="fixed inset-0 bg-black/40 z-40" />
            <motion.div initial={{ x: 400 }} animate={{ x: 0 }} exit={{ x: 400 }}
              className="fixed right-0 top-0 bottom-0 w-96 bg-white z-50 p-6 shadow-2xl overflow-auto">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-xl font-bold">Filter</h2>
                <button onClick={() => setFilterOpen(false)}><CloseSquare size={24} /></button>
              </div>
              <div className="space-y-5">
                <div>
                  <label className="text-sm font-semibold">Minimal narx</label>
                  <input type="number" value={minPrice} onChange={(e) => setMinPrice(+e.target.value)}
                    className="w-full mt-1 px-3 py-2 border rounded-lg" />
                </div>
                <div>
                  <label className="text-sm font-semibold">Maksimal narx</label>
                  <input type="number" value={maxPrice} onChange={(e) => setMaxPrice(+e.target.value)}
                    className="w-full mt-1 px-3 py-2 border rounded-lg" />
                </div>
                <button onClick={() => { setMinPrice(0); setMaxPrice(5_000_000); setStatus('ALL'); setQ(''); }}
                  className="w-full py-2.5 border rounded-xl hover:bg-slate-50">
                  Tozalash
                </button>
                <button onClick={() => setFilterOpen(false)}
                  className="w-full py-2.5 bg-brand-600 text-white rounded-xl hover:bg-brand-700">
                  Qo‘llash
                </button>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </div>
  );
}
