import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button, Card, Input } from '@cargos/ui-kit';
import { api } from '../lib/api';
import { useAuthStore } from '../store/auth';

export function LoginPage() {
  const [phone, setPhone] = useState('+998901234567');
  const [otp, setOtp] = useState('');
  const [step, setStep] = useState<'phone' | 'otp'>('phone');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const navigate = useNavigate();
  const setSession = useAuthStore((s) => s.setSession);

  async function requestOtp() {
    setLoading(true); setError(null);
    try {
      await api.post('/auth/request-otp', { phone, role: 'ADMIN' });
      setStep('otp');
    } catch (e: any) { setError(e?.response?.data?.message ?? e.message); }
    finally { setLoading(false); }
  }

  async function verify() {
    setLoading(true); setError(null);
    try {
      const res = await api.post('/auth/verify-otp', { phone, otp, role: 'ADMIN' });
      setSession(res.data);
      navigate('/');
    } catch (e: any) { setError(e?.response?.data?.message ?? e.message); }
    finally { setLoading(false); }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-slate-100">
      <div className="w-full max-w-sm">
        <Card title="TransCargo Admin">
          <div className="flex flex-col gap-4">
            <Input label="Telefon" value={phone} onChange={(e) => setPhone(e.target.value)} disabled={step === 'otp'} />
            {step === 'otp' && (
              <Input label="OTP (test: 666666)" value={otp} onChange={(e) => setOtp(e.target.value)} maxLength={6} />
            )}
            {error && <div className="text-sm text-red-600">{error}</div>}
            {step === 'phone' ? (
              <Button onClick={requestOtp} loading={loading}>OTP yuborish</Button>
            ) : (
              <Button onClick={verify} loading={loading}>Tasdiqlash</Button>
            )}
          </div>
        </Card>
      </div>
    </div>
  );
}
