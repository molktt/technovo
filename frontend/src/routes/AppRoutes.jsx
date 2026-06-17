import { Routes, Route, Navigate } from 'react-router-dom';
import ProtectedRoute from './ProtectedRoute';
import MainLayout from '../layouts/MainLayout';
import Login from '../pages/Login';

import LeaderDashboard from '../pages/leader/LeaderDashboard';
import LiveSchedulesPage from '../pages/leader/LiveSchedulesPage';
import UsersPage from '../pages/leader/UsersPage';
import ActivityLogsPage from '../pages/leader/ActivityLogsPage';

import AdminDashboard from '../pages/admin/AdminDashboard';
import CustomersPage from '../pages/admin/CustomersPage';

import HostDashboard from '../pages/host/HostDashboard';
import HostSchedulePage from '../pages/host/HostSchedulePage';

import ProductsPage from '../pages/ProductsPage';
import LiveSalesPage from '../pages/LiveSalesPage';
import MarketplacePage from '../pages/MarketplacePage';
import ReturnsPage from '../pages/ReturnsPage';
import BonusPage from '../pages/BonusPage';
import StockMovementsPage from '../pages/StockMovementsPage';

const AppRoutes = () => (
  <Routes>
    <Route path="/login" element={<Login />} />
    <Route path="/" element={<Navigate to="/login" replace />} />

    <Route element={<ProtectedRoute roles={['LEADER']}><MainLayout /></ProtectedRoute>}>
      <Route path="/leader/dashboard" element={<LeaderDashboard />} />
      <Route path="/leader/live-schedules" element={<LiveSchedulesPage />} />
      <Route path="/leader/live-sales" element={<LiveSalesPage />} />
      <Route path="/leader/marketplace" element={<MarketplacePage />} />
      <Route path="/leader/returns" element={<ReturnsPage />} />
      <Route path="/leader/bonus" element={<BonusPage />} />
      <Route path="/leader/products" element={<ProductsPage canDelete />} />
      <Route path="/leader/stock" element={<StockMovementsPage />} />
      <Route path="/leader/users" element={<UsersPage />} />
      <Route path="/leader/activity-logs" element={<ActivityLogsPage />} />
    </Route>

    <Route element={<ProtectedRoute roles={['ADMIN']}><MainLayout /></ProtectedRoute>}>
      <Route path="/admin/dashboard" element={<AdminDashboard />} />
      <Route path="/admin/orders" element={<MarketplacePage title="Marketplace Orders" />} />
      <Route path="/admin/products" element={<ProductsPage />} />
      <Route path="/admin/returns" element={<ReturnsPage />} />
      <Route path="/admin/stock" element={<StockMovementsPage />} />
      <Route path="/admin/customers" element={<CustomersPage />} />
    </Route>

    <Route element={<ProtectedRoute roles={['HOST']}><MainLayout /></ProtectedRoute>}>
      <Route path="/host/dashboard" element={<HostDashboard />} />
      <Route path="/host/schedule" element={<HostSchedulePage />} />
      <Route path="/host/live-sales" element={<LiveSalesPage title="My Live Sales" />} />
      <Route path="/host/bonus" element={<BonusPage title="My Bonus" />} />
    </Route>

    <Route path="*" element={<Navigate to="/login" replace />} />
  </Routes>
);

export default AppRoutes;
