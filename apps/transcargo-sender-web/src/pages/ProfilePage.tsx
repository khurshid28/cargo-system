import { useQuery } from '@tanstack/react-query';
import { Wallet3, Box1, ChartCircle, Notification, Card, Global, MessageQuestion, Edit, User } from 'iconsax-react';
import { SenderApi } from '../lib/api';
import { fmtMoney } from '../lib/format';

export function ProfilePage() {
  const stats = useQuery({ queryKey: ['stats'], queryFn: SenderApi.stats });
  const user = SenderApi.currentUser();

  return (
    <div className="p-8 max-w-4xl mx-auto">
      <h1 className="text-2xl font-bold mb-6">Profil</h1>

      <div className="bg-gradient-to-br from-brand-600 to-brand-800 text-white rounded-2xl p-6 mb-6 flex items-center gap-5 shadow-lg">
        <div className="w-20 h-20 rounded-full bg-white/20 grid place-items-center">
          <User size={40} />
        </div>
        <div className="flex-1">
          <div className="text-2xl font-bold">{user?.phone}</div>
          <div className="opacity-80">Sender · TransCargo</div>
        </div>
        <button className="bg-white/20 hover:bg-white/30 px-4 py-2 rounded-xl flex items-center gap-2">
          <Edit size={18} /> Tahrirlash
        </button>
      </div>

      <div className="grid grid-cols-3 gap-4 mb-6">
        {stats.isLoading ? (
          [...Array(3)].map((_, i) => <div key={i} className="skeleton h-28" />)
        ) : (
          <>
            <Stat icon={<Wallet3 size={22} />} color="indigo" label="Balans"
              value={fmtMoney(stats.data?.balance ?? 0)} />
            <Stat icon={<ChartCircle size={22} />} color="purple" label="Jami sarflangan"
              value={fmtMoney(stats.data?.totalSpent ?? 0)} />
            <Stat icon={<Box1 size={22} />} color="emerald" label="Jami buyurtmalar"
              value={`${stats.data?.totalShipments ?? 0} ta`} />
          </>
        )}
      </div>

      <button className="w-full mb-8 py-3 bg-brand-600 hover:bg-brand-700 text-white font-semibold rounded-xl">
        Hisobni to‘ldirish
      </button>

      <div className="space-y-2">
        <SectionTitle title="Sozlamalar" />
        <Tile icon={<Card size={20} />} title="To‘lov usullari" />
        <Tile icon={<Notification size={20} />} title="Bildirishnomalar" />
        <Tile icon={<Global size={20} />} title="Til" trailing="O‘zbek" />
        <SectionTitle title="Yordam" />
        <Tile icon={<MessageQuestion size={20} />} title="Savol-javoblar" />
      </div>
    </div>
  );
}

function Stat({ icon, color, label, value }:
  { icon: JSX.Element; color: 'indigo' | 'purple' | 'emerald'; label: string; value: string }) {
  const tones = {
    indigo: 'bg-indigo-50 text-indigo-700',
    purple: 'bg-purple-50 text-purple-700',
    emerald: 'bg-emerald-50 text-emerald-700',
  } as const;
  return (
    <div className="bg-white border border-slate-200 rounded-2xl p-5">
      <div className={`w-10 h-10 rounded-lg grid place-items-center ${tones[color]}`}>{icon}</div>
      <div className="text-sm text-slate-500 mt-3">{label}</div>
      <div className="text-lg font-bold mt-0.5">{value}</div>
    </div>
  );
}

function SectionTitle({ title }: { title: string }) {
  return <h2 className="text-sm font-bold text-slate-500 uppercase tracking-wide mt-4 mb-2">{title}</h2>;
}

function Tile({ icon, title, trailing }: { icon: JSX.Element; title: string; trailing?: string }) {
  return (
    <button className="w-full bg-white border border-slate-200 rounded-xl p-4 flex items-center gap-3 hover:bg-slate-50 transition">
      <div className="text-brand-600">{icon}</div>
      <span className="font-medium flex-1 text-left">{title}</span>
      {trailing && <span className="text-slate-500 text-sm">{trailing}</span>}
      <span className="text-slate-400">›</span>
    </button>
  );
}
