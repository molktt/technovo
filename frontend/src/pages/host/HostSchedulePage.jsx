import DataTable from '../../components/common/DataTable';
import { scheduleAPI } from '../../services';

const HostSchedulePage = () => {
  const columns = [
    { field: 'title', label: 'Title' },
    { field: 'platform_name', label: 'Platform' },
    { field: 'schedule_date', label: 'Date' },
    { field: 'start_time', label: 'Start' },
    { field: 'end_time', label: 'End' },
    { field: 'status', label: 'Status' },
  ];

  return (
    <DataTable
      title="My Schedule"
      columns={columns}
      fetchData={scheduleAPI.getAll}
      filterOptions={[{ key: 'status', label: 'Status', options: [{ value: 'scheduled', label: 'Scheduled' }, { value: 'completed', label: 'Completed' }] }]}
      exportFilename="my-schedule.csv"
    />
  );
};

export default HostSchedulePage;
