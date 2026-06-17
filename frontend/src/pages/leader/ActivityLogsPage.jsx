import DataTable from '../../components/common/DataTable';
import { activityAPI } from '../../services';

const ActivityLogsPage = () => {
  const columns = [
    { field: 'user_name', label: 'User' },
    { field: 'action', label: 'Action' },
    { field: 'module', label: 'Module' },
    { field: 'description', label: 'Description' },
    { field: 'created_at', label: 'Date', render: (r) => r.created_at?.slice(0, 16) },
  ];

  return (
    <DataTable
      title="Activity Logs"
      columns={columns}
      fetchData={activityAPI.getAll}
      filterOptions={[{ key: 'module', label: 'Module', options: [{ value: 'Auth', label: 'Auth' }, { value: 'Products', label: 'Products' }, { value: 'Users', label: 'Users' }, { value: 'Marketplace', label: 'Marketplace' }] }]}
      exportFilename="activity-logs.csv"
    />
  );
};

export default ActivityLogsPage;
