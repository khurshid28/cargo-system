import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button, Card, Input } from '@cargos/ui-kit';
import { api, useAuthStore } from '../lib/api';

export function LoginPage() {
  const [phone, setPhone] = useState('+998901234567');
  const [otp, setOtp] = useState('');
  const [role, setRole] = useState<'MERCHANT' | 'ADMIN'>('MERCHANT');
  const [step, setStep] = useState<'phone' | 'otp'>('phone');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const navigate = useNavigate();
  const setSession = useAuthStore((s) => s.setSession);

  async function go() {
    setLoading(true); setError(null);
    try {
      if (step === 'phone') {
        await api.post('/auth/request-otp', { phone, role });
        setStep('otp');
      } else {
        const { data } = await api.post('/auth/verify-otp', { phone, otp, role });
        setSession(data);
        navigate('/');
      }
    } catch (e: any) { setError(e?.response?.data?.message ?? e.message); }
    finally { setLoading(false); }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-slate-100">
      <div className="w-full max-w-sm">
        <Card title="MaterialMarket Admin">
          <div className="flex flex-col gap-4">
            <div>
              <label className="text-sm text-slate-600">Rol</label>
              <select className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm"
                value={role} onChange={(e) => setRole(e.target.value as 'MERCHANT' | 'ADMIN')}>
                <option value="MERCHANT">Merchant</option>
                <option value="ADMIN">Super admin</option>
              </select>
            </div>
            <Input label="Telefon" value={phone} onChange={(e) => setPhone(e.target.value)} disabled={step === 'otp'} />
            {step === 'otp' && <Input label="OTP (test: 666666)" value={otp} onChange={(e) => setOtp(e.target.value)} maxLength={6} />}
            {error && <div className="text-sm text-red-600">{error}</div>}
            <Button onClick={go} loading={loading}>{step === 'phone' ? 'OTP yuborish' : 'Tasdiqlash'}</Button>
          </div>
        </Card>
      </div>
    </div>
  );
}
