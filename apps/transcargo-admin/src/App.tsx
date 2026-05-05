import { Navigate, Route, Routes } from 'react-router-dom';
import { Layout } from './components/Layout';
import { LoginPage } from './pages/LoginPage';
import { DashboardPage } from './pages/DashboardPage';
import { CargoRequestsPage } from './pages/CargoRequestsPage';
import { DriversPage } from './pages/DriversPage';
import { TrackingMapPage } from './pages/TrackingMapPage';
import { UsersPage } from './pages/UsersPage';
import { useAuthStore } from './store/auth';

function RequireAuth({ children }: { children: JSX.Element }) {
  const token = useAuthStore((s) => s.accessToken);
  return token ? children : <Navigate to="/login" replace />;
}

export function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route
        path="/"
        element={
          <RequireAuth>
            <Layout />
          </RequireAuth>
        }
      >
        <Route index element={<DashboardPage />} />
        <Route path="cargo-requests" element={<CargoRequestsPage />} />
        <Route path="drivers" element={<DriversPage />} />
        <Route path="tracking" element={<TrackingMapPage />} />
        <Route path="users" element={<UsersPage />} />
      </Route>
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
