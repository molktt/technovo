import DashboardView from '../DashboardView';
import { dashboardAPI } from '../../services';

const AdminDashboard = () => (
  <DashboardView fetchDashboard={dashboardAPI.admin} title="Admin Dashboard" />
);

export default AdminDashboard;
