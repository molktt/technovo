import DashboardView from '../DashboardView';
import { dashboardAPI } from '../../services';

const LeaderDashboard = () => (
  <DashboardView fetchDashboard={dashboardAPI.leader} title="Leader Dashboard" />
);

export default LeaderDashboard;
