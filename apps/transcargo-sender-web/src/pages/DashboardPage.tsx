import { useQuery } from '@tanstack/react-query';
import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { Wallet3, Box1, Truck, TickCircle, Add } from 'iconsax-react';
import { SenderApi } from '../lib/api';
import { fmtMoney, statusColor, statusLabel, fmtDate } from '../lib/format';

export function DashboardPage() {
  const stats = useQuery({ queryKey: ['stats'], queryFn: SenderApi.stats });
  const list = useQuery({ queryKey: ['orders'], queryFn: SenderApi.listMine });

  return (
    <div className="p-8 max-w-6xl mx-auto">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold">Boshqaruv paneli</h1>
          <p className="text-slate-500">Yuborilgan yuklar va balans</p>
        </div>
        <Link to="/create"
          className="inline-flex items-center gap-2 bg-brand-600 hover:bg-brand-700 text-white font-semibold px-4 py-2.5 rounded-xl shadow-md">
          <Add size={18} /> Yangi yuk
        </Link>
      </div>

      <div className="grid grid-cols-4 gap-4 mb-8">
        {stats.isLoading ? (
          [...Array(4)].map((_, i) => <div key={i} className="skeleton h-28" />)
        ) : (
          <>
            <StatCard color="from-indigo-500 to-indigo-700" icon={<Wallet3 size={24} />}
              label="Balans" value={fmtMoney(stats.data?.balance ?? 0)} />
            <StatCard color="from-rose-500 to-rose-700" icon={<Wallet3 size={24} />}
              label="Jami sarflangan" value={fmtMoney(stats.data?.totalSpent ?? 0)} />
            <StatCard color="from-orange-500 to-orange-700" icon={<Truck size={24} />}
              label="Faol yuklar" value={`${stats.data?.active ?? 0} ta`} />
            <StatCard color="from-emerald-500 to-emerald-700" icon={<TickCircle size={24} />}
              label="Yetkazilgan" value={`${stats.data?.delivered ?? 0} ta`} />
          </>
        )}
      </div>

      <div className="bg-white rounded-2xl border border-slate-200 overflow-hidden">
        <div className="p-5 border-b flex items-center gap-2">
          <Box1 size={20} className="text-brand-600" />
          <h2 className="font-bold">So‘nggi buyurtmalar</h2>
          <Link to="/orders" className="ml-auto text-sm text-brand-600 hover:underline">Barchasini ko‘rish →</Link>
        </div>
        {list.isLoading ? (
          <div className="p-5 space-y-3">
            {[...Array(3)].map((_, i) => <div key={i} className="skeleton h-16" />)}
          </div>
        ) : (
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-slate-600 text-xs uppercase">
              <tr>
                <th className="text-left p-3">Yo‘nalish</th>
                <th className="text-left p-3">Yuk</th>
                <th className="text-left p-3">Sana</th>
                <th className="text-left p-3">Holat</th>
                <th className="text-right p-3">Narx</th>
              </tr>
            </thead>
            <tbody>
              {(list.data ?? []).slice(0, 5).map((r) => (
                <tr key={r.id} className="border-t hover:bg-slate-50">
                  <td className="p-3">
                    <div className="font-medium">{r.pickupAddress}</div>
                    <div className="text-xs text-slate-500">→ {r.dropoffAddress}</div>
                  </td>
                  <td className="p-3">{r.cargoType} · {r.weightKg} kg</td>
                  <td className="p-3 text-slate-600">{fmtDate(r.createdAt)}</td>
                  <td className="p-3">
                    <span className={`px-2 py-1 rounded-md text-xs font-medium ${statusColor[r.status]}`}>
                      {statusLabel[r.status]}
                    </span>
                  </td>
                  <td className="p-3 text-right font-bold text-brand-700">{fmtMoney(r.priceUzs)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}

function StatCard({ color, icon, label, value }:
  { color: string; icon: JSX.Element; label: string; value: string }) {
  return (
    <motion.div whileHover={{ y: -3 }}
      className={`bg-gradient-to-br ${color} text-white p-5 rounded-2xl shadow-md`}>
      <div className="opacity-80">{icon}</div>
      <div className="text-sm opacity-80 mt-2">{label}</div>
      <div className="text-xl font-bold mt-0.5">{value}</div>
    </motion.div>
  );
}
