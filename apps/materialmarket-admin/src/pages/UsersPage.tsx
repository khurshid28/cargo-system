import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Add, CloseCircle, ShieldTick, Trash, ShieldSearch, SearchNormal1 } from 'iconsax-react';
import { api } from '../lib/api';

type User = {
  id: string;
  phone: string;
  fullName: string | null;
  role: 'CUSTOMER' | 'MERCHANT' | 'ADMIN';
  status: 'ACTIVE' | 'BLOCKED' | 'PENDING';
  language: string;
  createdAt: string;
};

const ROLES: User['role'][] = ['CUSTOMER', 'MERCHANT', 'ADMIN'];
const STATUSES: User['status'][] = ['ACTIVE', 'BLOCKED', 'PENDING'];

const STATUS_BADGE: Record<User['status'], string> = {
  ACTIVE: 'bg-emerald-100 text-emerald-700',
  BLOCKED: 'bg-rose-100 text-rose-700',
  PENDING: 'bg-amber-100 text-amber-700',
};
const ROLE_BADGE: Record<User['role'], string> = {
  ADMIN: 'bg-violet-100 text-violet-700',
  MERCHANT: 'bg-emerald-100 text-emerald-700',
  CUSTOMER: 'bg-slate-100 text-slate-700',
};

export function UsersPage() {
  const qc = useQueryClient();
  const [q, setQ] = useState('');
  const [role, setRole] = useState<string>('');
  const [status, setStatus] = useState<string>('');
  const [showCreate, setShowCreate] = useState(false);

  const { data, isLoading } = useQuery({
    queryKey: ['admin', 'users', { q, role, status }],
    queryFn: async () => {
      const params: Record<string, string> = { take: '100' };
      if (q) params.q = q;
      if (role) params.role = role;
      if (status) params.status = status;
      const res = await api.get<{ items: User[]; total: number }>('/admin/users', { params });
      return res.data;
    },
  });

  const invalidate = () => qc.invalidateQueries({ queryKey: ['admin', 'users'] });

  const block = useMutation({
    mutationFn: (id: string) => api.post(`/admin/users/${id}/block`),
    onSuccess: invalidate,
  });
  const unblock = useMutation({
    mutationFn: (id: string) => api.post(`/admin/users/${id}/unblock`),
    onSuccess: invalidate,
  });
  const remove = useMutation({
    mutationFn: (id: string) => api.delete(`/admin/users/${id}`),
    onSuccess: invalidate,
  });
  const changeRole = useMutation({
    mutationFn: (p: { id: string; role: string }) =>
      api.patch(`/admin/users/${p.id}`, { role: p.role }),
    onSuccess: invalidate,
  });

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Foydalanuvchilar</h1>
          <p className="text-sm text-slate-500">Yaratish, bloklash va o‘chirish</p>
        </div>
        <button
          onClick={() => setShowCreate(true)}
          className="flex items-center gap-2 bg-emerald-600 text-white px-4 py-2 rounded-md text-sm hover:bg-emerald-700"
        >
          <Add size={18} /> Yangi foydalanuvchi
        </button>
      </div>

      <div className="bg-white rounded-lg shadow-sm border border-slate-200 p-4 mb-4 flex flex-wrap gap-3">
        <div className="flex items-center gap-2 flex-1 min-w-[200px]">
          <SearchNormal1 size={18} className="text-slate-400" />
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Telefon yoki ism"
            className="flex-1 outline-none text-sm"
          />
        </div>
        <select
          value={role}
          onChange={(e) => setRole(e.target.value)}
          className="border border-slate-200 rounded-md px-3 py-1.5 text-sm"
        >
          <option value="">Hamma rollar</option>
          {ROLES.map((r) => (<option key={r} value={r}>{r}</option>))}
        </select>
        <select
          value={status}
          onChange={(e) => setStatus(e.target.value)}
          className="border border-slate-200 rounded-md px-3 py-1.5 text-sm"
        >
          <option value="">Hamma statuslar</option>
          {STATUSES.map((s) => (<option key={s} value={s}>{s}</option>))}
        </select>
      </div>

      <div className="bg-white rounded-lg shadow-sm border border-slate-200 overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-slate-50 text-slate-600 text-left text-xs uppercase tracking-wider">
            <tr>
              <th className="px-4 py-3">Telefon</th>
              <th className="px-4 py-3">F.I.SH</th>
              <th className="px-4 py-3">Rol</th>
              <th className="px-4 py-3">Status</th>
              <th className="px-4 py-3">Yaratildi</th>
              <th className="px-4 py-3 text-right">Amallar</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {isLoading && (
              <tr><td colSpan={6} className="px-4 py-8 text-center text-slate-400">Yuklanmoqda…</td></tr>
            )}
            {!isLoading && (data?.items.length ?? 0) === 0 && (
              <tr><td colSpan={6} className="px-4 py-8 text-center text-slate-400">Topilmadi</td></tr>
            )}
            {data?.items.map((u) => (
              <tr key={u.id} className="hover:bg-slate-50">
                <td className="px-4 py-3 font-mono">{u.phone}</td>
                <td className="px-4 py-3">{u.fullName || '—'}</td>
                <td className="px-4 py-3">
                  <select
                    value={u.role}
                    onChange={(e) => changeRole.mutate({ id: u.id, role: e.target.value })}
                    className={`px-2 py-1 rounded text-xs font-medium ${ROLE_BADGE[u.role]}`}
                  >
                    {ROLES.map((r) => (<option key={r} value={r}>{r}</option>))}
                  </select>
                </td>
                <td className="px-4 py-3">
                  <span className={`px-2 py-1 rounded text-xs font-medium ${STATUS_BADGE[u.status]}`}>
                    {u.status}
                  </span>
                </td>
                <td className="px-4 py-3 text-slate-500">
                  {new Date(u.createdAt).toLocaleDateString()}
                </td>
                <td className="px-4 py-3">
                  <div className="flex items-center gap-2 justify-end">
                    {u.status === 'BLOCKED' ? (
                      <button
                        onClick={() => unblock.mutate(u.id)}
                        className="flex items-center gap-1 text-emerald-600 hover:bg-emerald-50 px-2 py-1 rounded text-xs"
                      >
                        <ShieldTick size={16} /> Ochish
                      </button>
                    ) : (
                      <button
                        onClick={() => block.mutate(u.id)}
                        className="flex items-center gap-1 text-amber-600 hover:bg-amber-50 px-2 py-1 rounded text-xs"
                      >
                        <ShieldSearch size={16} /> Bloklash
                      </button>
                    )}
                    <button
                      onClick={() => {
                        if (confirm(`O'chirilsinmi: ${u.phone}?`)) remove.mutate(u.id);
                      }}
                      className="flex items-center gap-1 text-rose-600 hover:bg-rose-50 px-2 py-1 rounded text-xs"
                    >
                      <Trash size={16} /> O‘chirish
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {showCreate && (
        <CreateUserModal
          roles={ROLES}
          onClose={() => setShowCreate(false)}
          onCreated={() => {
            setShowCreate(false);
            invalidate();
          }}
        />
      )}
    </div>
  );
}

function CreateUserModal({
  roles,
  onClose,
  onCreated,
}: {
  roles: readonly string[];
  onClose: () => void;
  onCreated: () => void;
}) {
  const [phone, setPhone] = useState('+998');
  const [fullName, setFullName] = useState('');
  const [role, setRole] = useState(roles[0]);
  const [error, setError] = useState<string | null>(null);

  const create = useMutation({
    mutationFn: () => api.post('/admin/users', { phone, fullName: fullName || undefined, role }),
    onSuccess: onCreated,
    onError: (e: any) => setError(e?.response?.data?.message ?? 'Xatolik'),
  });

  return (
    <div className="fixed inset-0 bg-slate-900/50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg shadow-xl w-full max-w-md">
        <div className="flex items-center justify-between p-4 border-b">
          <h3 className="font-semibold">Yangi foydalanuvchi</h3>
          <button onClick={onClose} className="text-slate-400 hover:text-slate-600">
            <CloseCircle size={20} />
          </button>
        </div>
        <div className="p-4 space-y-3">
          <div>
            <label className="text-xs text-slate-500">Telefon</label>
            <input
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              placeholder="+998901234567"
              className="w-full border border-slate-200 rounded-md px-3 py-2 text-sm mt-1"
            />
          </div>
          <div>
            <label className="text-xs text-slate-500">F.I.SH (ixtiyoriy)</label>
            <input
              value={fullName}
              onChange={(e) => setFullName(e.target.value)}
              className="w-full border border-slate-200 rounded-md px-3 py-2 text-sm mt-1"
            />
          </div>
          <div>
            <label className="text-xs text-slate-500">Rol</label>
            <select
              value={role}
              onChange={(e) => setRole(e.target.value)}
              className="w-full border border-slate-200 rounded-md px-3 py-2 text-sm mt-1"
            >
              {roles.map((r) => (<option key={r} value={r}>{r}</option>))}
            </select>
          </div>
          {error && <div className="text-sm text-rose-600">{error}</div>}
        </div>
        <div className="p-4 border-t flex justify-end gap-2">
          <button
            onClick={onClose}
            className="px-4 py-2 text-sm text-slate-600 hover:bg-slate-100 rounded-md"
          >
            Bekor
          </button>
          <button
            disabled={create.isPending}
            onClick={() => create.mutate()}
            className="px-4 py-2 text-sm bg-emerald-600 text-white rounded-md hover:bg-emerald-700 disabled:opacity-50"
          >
            {create.isPending ? 'Yaratilmoqda…' : 'Yaratish'}
          </button>
        </div>
      </div>
    </div>
  );
}
