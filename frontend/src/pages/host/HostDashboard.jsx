import DashboardView from '../DashboardView';
import { dashboardAPI } from '../../services';

const HostDashboard = () => (
  <DashboardView fetchDashboard={dashboardAPI.host} title="Host Dashboard" />
);

export default HostDashboard;
