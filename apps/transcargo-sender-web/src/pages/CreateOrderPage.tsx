import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useQueryClient } from '@tanstack/react-query';
import { Add, Box1, Location, Weight } from 'iconsax-react';
import { SenderApi } from '../lib/api';

export function CreateOrderPage() {
  const nav = useNavigate();
  const qc = useQueryClient();
  const [form, setForm] = useState({
    pickupAddress: 'Toshkent, Yashnobod tumani, ',
    dropoffAddress: 'Samarqand, ',
    cargoType: 'Mebel',
    weightKg: 100,
    priceUzs: 800_000,
  });
  const [busy, setBusy] = useState(false);

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    try {
      await SenderApi.create(form);
      qc.invalidateQueries({ queryKey: ['orders'] });
      qc.invalidateQueries({ queryKey: ['stats'] });
      nav('/orders');
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="p-8 max-w-3xl mx-auto">
      <h1 className="text-2xl font-bold mb-1">Yangi yuk so‘rovi</h1>
      <p className="text-slate-500 mb-6">A nuqtadan B nuqtaga yuk yuborish</p>
      <form onSubmit={submit} className="bg-white rounded-2xl border border-slate-200 p-6 space-y-5">
        <Field icon={<Location size={18} className="text-emerald-600" />} label="Olib chiqish manzili">
          <input value={form.pickupAddress}
            onChange={(e) => setForm({ ...form, pickupAddress: e.target.value })}
            className="w-full px-3 py-2.5 border border-slate-200 rounded-xl outline-none focus:border-brand-500" />
        </Field>
        <Field icon={<Location size={18} className="text-rose-600" />} label="Yetkazib berish manzili">
          <input value={form.dropoffAddress}
            onChange={(e) => setForm({ ...form, dropoffAddress: e.target.value })}
            className="w-full px-3 py-2.5 border border-slate-200 rounded-xl outline-none focus:border-brand-500" />
        </Field>
        <div className="grid grid-cols-2 gap-4">
          <Field icon={<Box1 size={18} className="text-brand-600" />} label="Yuk turi">
            <select value={form.cargoType} onChange={(e) => setForm({ ...form, cargoType: e.target.value })}
              className="w-full px-3 py-2.5 border border-slate-200 rounded-xl outline-none focus:border-brand-500">
              {['Mebel','Qurilish materiallari','Texnika','Oziq-ovqat','Boshqa'].map(s => <option key={s}>{s}</option>)}
            </select>
          </Field>
          <Field icon={<Weight size={18} className="text-amber-600" />} label="Vazn (kg)">
            <input type="number" value={form.weightKg}
              onChange={(e) => setForm({ ...form, weightKg: +e.target.value })}
              className="w-full px-3 py-2.5 border border-slate-200 rounded-xl outline-none focus:border-brand-500" />
          </Field>
        </div>
        <Field icon={<Box1 size={18} className="text-brand-600" />} label="Taklif qilingan narx (so‘m)">
          <input type="number" value={form.priceUzs}
            onChange={(e) => setForm({ ...form, priceUzs: +e.target.value })}
            className="w-full px-3 py-2.5 border border-slate-200 rounded-xl outline-none focus:border-brand-500" />
        </Field>
        <button type="submit" disabled={busy}
          className="w-full inline-flex items-center justify-center gap-2 py-3 bg-brand-600 hover:bg-brand-700 text-white font-semibold rounded-xl disabled:opacity-50">
          <Add size={20} /> {busy ? 'Yuborilmoqda...' : 'So‘rov yuborish'}
        </button>
      </form>
    </div>
  );
}

function Field({ icon, label, children }:
  { icon: JSX.Element; label: string; children: React.ReactNode }) {
  return (
    <div>
      <label className="flex items-center gap-2 text-sm font-semibold mb-1.5">{icon} {label}</label>
      {children}
    </div>
  );
}
