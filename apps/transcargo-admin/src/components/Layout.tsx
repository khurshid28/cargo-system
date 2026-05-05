import { Link, NavLink, Outlet, useNavigate } from 'react-router-dom';
import { Truck, Map1, People, Logout, Chart, UserOctagon } from 'iconsax-react';
import { useAuthStore } from '../store/auth';
import { clsx } from 'clsx';

const NAV = [
  { to: '/', label: 'Dashboard', Icon: Chart, exact: true },
  { to: '/cargo-requests', label: 'Cargo Requests', Icon: Truck },
  { to: '/drivers', label: 'Drivers', Icon: People },
  { to: '/tracking', label: 'Live Tracking', Icon: Map1 },
  { to: '/users', label: 'Users', Icon: UserOctagon },
];

export function Layout() {
  const navigate = useNavigate();
  const clear = useAuthStore((s) => s.clear);
  const user = useAuthStore((s) => s.user);

  return (
    <div className="flex min-h-screen">
      <aside className="w-64 bg-slate-900 text-slate-100 flex flex-col">
        <Link to="/" className="px-6 py-5 text-xl font-bold tracking-tight">TransCargo</Link>
        <nav className="flex-1 px-3 space-y-1">
          {NAV.map(({ to, label, Icon, exact }) => (
            <NavLink
              key={to}
              to={to}
              end={exact}
              className={({ isActive }) =>
                clsx('flex items-center gap-3 rounded-md px-3 py-2 text-sm transition',
                  isActive ? 'bg-brand-600 text-white' : 'hover:bg-slate-800')
              }
            >
              <Icon size={18} variant="Bold" />
              {label}
            </NavLink>
          ))}
        </nav>
        <div className="p-4 border-t border-slate-800 text-xs">
          <div className="mb-2 text-slate-400">{user?.phone}</div>
          <button
            onClick={() => { clear(); navigate('/login'); }}
            className="flex items-center gap-2 text-slate-300 hover:text-white"
          >
            <Logout size={16} /> Chiqish
          </button>
        </div>
      </aside>
      <main className="flex-1 p-8 bg-slate-50">
        <Outlet />
      </main>
    </div>
  );
}
