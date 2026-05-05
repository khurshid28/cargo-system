import { Routes, Route, Navigate, NavLink, Outlet, useNavigate } from 'react-router-dom';
import { Truck, Box1, Add, Wallet3, User, LogoutCurve } from 'iconsax-react';
import { SenderApi, USE_MOCK } from './lib/api';
import { LoginPage } from './pages/LoginPage';
import { DashboardPage } from './pages/DashboardPage';
import { OrdersPage } from './pages/OrdersPage';
import { CreateOrderPage } from './pages/CreateOrderPage';
import { ProfilePage } from './pages/ProfilePage';

function Layout() {
  const nav = useNavigate();
  const user = SenderApi.currentUser();
  const link = (active: boolean) =>
    `flex items-center gap-3 px-4 py-2.5 rounded-xl transition ${
      active ? 'bg-brand-600 text-white shadow-md' : 'text-slate-600 hover:bg-slate-100'
    }`;
  return (
    <div className="min-h-screen flex">
      <aside className="w-64 border-r bg-white p-4 flex flex-col">
        <div className="flex items-center gap-2 mb-8 px-2">
          <div className="w-9 h-9 rounded-lg bg-gradient-to-br from-brand-500 to-brand-700 grid place-items-center text-white">
            <Truck size={20} variant="Bold" />
          </div>
          <div>
            <div className="font-bold">TransCargo</div>
            <div className="text-xs text-slate-500">Sender Portal</div>
          </div>
        </div>
        <nav className="flex flex-col gap-1">
          <NavLink to="/" end className={({ isActive }) => link(isActive)}>
            <Wallet3 size={18} /> Boshqaruv paneli
          </NavLink>
          <NavLink to="/orders" className={({ isActive }) => link(isActive)}>
            <Box1 size={18} /> Buyurtmalar
          </NavLink>
          <NavLink to="/create" className={({ isActive }) => link(isActive)}>
            <Add size={18} /> Yangi yuk
          </NavLink>
          <NavLink to="/profile" className={({ isActive }) => link(isActive)}>
            <User size={18} /> Profil
          </NavLink>
        </nav>
        <div className="mt-auto">
          {USE_MOCK && (
            <div className="mb-3 text-center text-xs font-bold text-amber-800 bg-amber-100 py-1.5 rounded-lg">
              MOCK MODE
            </div>
          )}
          <div className="bg-slate-50 rounded-xl p-3 mb-2">
            <div className="text-xs text-slate-500">Foydalanuvchi</div>
            <div className="font-medium truncate">{user?.phone}</div>
          </div>
          <button
            onClick={() => { SenderApi.logout(); nav('/login'); }}
            className="w-full flex items-center gap-2 px-4 py-2 rounded-xl text-rose-600 hover:bg-rose-50"
          >
            <LogoutCurve size={18} /> Chiqish
          </button>
        </div>
      </aside>
      <main className="flex-1 overflow-auto">
        <Outlet />
      </main>
    </div>
  );
}

function RequireAuth({ children }: { children: JSX.Element }) {
  const user = SenderApi.currentUser();
  return user ? children : <Navigate to="/login" replace />;
}

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route path="/" element={<RequireAuth><Layout /></RequireAuth>}>
        <Route index element={<DashboardPage />} />
        <Route path="orders" element={<OrdersPage />} />
        <Route path="create" element={<CreateOrderPage />} />
        <Route path="profile" element={<ProfilePage />} />
      </Route>
    </Routes>
  );
}
