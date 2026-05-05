import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { Truck, Sms, PasswordCheck } from 'iconsax-react';
import { SenderApi, USE_MOCK } from '../lib/api';

export function LoginPage() {
  const nav = useNavigate();
  const [phone, setPhone] = useState('+998901234567');
  const [otp, setOtp] = useState('');
  const [step, setStep] = useState<'phone' | 'otp'>('phone');
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState('');

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setErr(''); setLoading(true);
    try {
      if (step === 'phone') {
        await SenderApi.sendOtp(phone);
        setStep('otp');
      } else {
        await SenderApi.login(phone, otp);
        nav('/');
      }
    } catch (e: any) {
      setErr(e?.message ?? 'Xato');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="min-h-screen grid place-items-center bg-gradient-to-br from-brand-50 via-white to-brand-100 p-6">
      <motion.div
        initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}
        className="w-full max-w-md bg-white rounded-3xl shadow-xl p-8"
      >
        <div className="flex flex-col items-center mb-6">
          <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-brand-500 to-brand-700 grid place-items-center text-white mb-3">
            <Truck size={32} variant="Bold" />
          </div>
          <h1 className="text-2xl font-bold">TransCargo</h1>
          <p className="text-slate-500 text-sm">Yuk yuboruvchi paneli</p>
        </div>
        {USE_MOCK && (
          <div className="mb-4 text-center text-xs font-bold text-amber-800 bg-amber-100 py-2 rounded-lg">
            MOCK MODE — OTP: 666666
          </div>
        )}
        <form onSubmit={submit} className="space-y-3">
          <div className="relative">
            <Sms size={18} className="absolute left-3 top-3.5 text-slate-400" />
            <input
              type="tel" value={phone} onChange={(e) => setPhone(e.target.value)}
              disabled={step === 'otp'}
              className="w-full pl-10 pr-3 py-3 border border-slate-200 rounded-xl focus:border-brand-500 outline-none disabled:bg-slate-50"
              placeholder="+998 ..."
            />
          </div>
          {step === 'otp' && (
            <motion.div initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }}>
              <div className="relative">
                <PasswordCheck size={18} className="absolute left-3 top-3.5 text-slate-400" />
                <input
                  type="text" value={otp} onChange={(e) => setOtp(e.target.value)} maxLength={6}
                  className="w-full pl-10 pr-3 py-3 border border-slate-200 rounded-xl focus:border-brand-500 outline-none tracking-widest text-center"
                  placeholder="OTP"
                />
              </div>
            </motion.div>
          )}
          {err && <div className="text-rose-600 text-sm">{err}</div>}
          <button
            type="submit" disabled={loading}
            className="w-full py-3 rounded-xl bg-brand-600 hover:bg-brand-700 text-white font-semibold transition disabled:opacity-50"
          >
            {loading ? '...' : step === 'phone' ? 'OTP yuborish' : 'Kirish'}
          </button>
        </form>
      </motion.div>
    </div>
  );
}
