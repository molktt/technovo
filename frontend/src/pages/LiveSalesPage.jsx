import DataTable from '../components/common/DataTable';
import { liveSaleAPI } from '../services';

const formatCurrency = (val) => `Rp ${Number(val).toLocaleString('id-ID')}`;

const LiveSalesPage = ({ title = 'Live Sales Report' }) => {
  const columns = [
    { field: 'sale_date', label: 'Date' },
    { field: 'host_name', label: 'Host' },
    { field: 'platform_name', label: 'Platform' },
    { field: 'schedule_title', label: 'Schedule' },
    { field: 'total_items', label: 'Items' },
    { field: 'total_amount', label: 'Amount', render: (r) => formatCurrency(r.total_amount) },
    { field: 'status', label: 'Status' },
  ];

  return (
    <DataTable
      title={title}
      columns={columns}
      fetchData={liveSaleAPI.getAll}
      filterOptions={[{ key: 'status', label: 'Status', options: [{ value: 'completed', label: 'Completed' }, { value: 'pending', label: 'Pending' }] }]}
      exportFilename="live-sales.csv"
    />
  );
};

export default LiveSalesPage;
