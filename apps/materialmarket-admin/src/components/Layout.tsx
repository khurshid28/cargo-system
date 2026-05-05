import { Link, NavLink, Outlet, useNavigate } from 'react-router-dom';
import { Box, Bag, Logout, Chart, UserOctagon } from 'iconsax-react';
import { clsx } from 'clsx';
import { useAuthStore } from '../lib/api';

const NAV = [
  { to: '/', label: 'Dashboard', Icon: Chart, exact: true },
  { to: '/products', label: 'Products', Icon: Box },
  { to: '/orders', label: 'Orders', Icon: Bag },
  { to: '/users', label: 'Users', Icon: UserOctagon, adminOnly: true },
];

export function Layout() {
  const navigate = useNavigate();
  const clear = useAuthStore((s) => s.clear);
  const user = useAuthStore((s) => s.user);

  return (
    <div className="flex min-h-screen">
      <aside className="w-64 bg-emerald-900 text-emerald-50 flex flex-col">
        <Link to="/" className="px-6 py-5 text-xl font-bold tracking-tight">MaterialMarket</Link>
        <nav className="flex-1 px-3 space-y-1">
          {NAV.filter((n) => !n.adminOnly || user?.role === 'ADMIN').map(({ to, label, Icon, exact }) => (
            <NavLink
              key={to}
              to={to}
              end={exact}
              className={({ isActive }) =>
                clsx('flex items-center gap-3 rounded-md px-3 py-2 text-sm transition',
                  isActive ? 'bg-emerald-600 text-white' : 'hover:bg-emerald-800')
              }
            >
              <Icon size={18} variant="Bold" />
              {label}
            </NavLink>
          ))}
        </nav>
        <div className="p-4 border-t border-emerald-800 text-xs">
          <div className="mb-2 text-emerald-200">{user?.phone} · {user?.role}</div>
          <button
            onClick={() => { clear(); navigate('/login'); }}
            className="flex items-center gap-2 text-emerald-100 hover:text-white"
          >
            <Logout size={16} /> Chiqish
          </button>
        </div>
      </aside>
      <main className="flex-1 p-8 bg-slate-50"><Outlet /></main>
    </div>
  );
}
