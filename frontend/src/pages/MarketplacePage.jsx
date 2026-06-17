import DataTable from '../components/common/DataTable';
import { orderAPI } from '../services';

const formatCurrency = (val) => `Rp ${Number(val).toLocaleString('id-ID')}`;

const MarketplacePage = ({ title = 'Marketplace Report' }) => {
  const columns = [
    { field: 'order_number', label: 'Order No' },
    { field: 'customer_name', label: 'Customer' },
    { field: 'platform_name', label: 'Platform' },
    { field: 'order_date', label: 'Date', render: (r) => r.order_date?.slice(0, 10) },
    { field: 'status', label: 'Status' },
    { field: 'total_amount', label: 'Amount', render: (r) => formatCurrency(r.total_amount) },
  ];

  return (
    <DataTable
      title={title}
      columns={columns}
      fetchData={orderAPI.getAll}
      filterOptions={[
        { key: 'status', label: 'Status', options: ['pending', 'processing', 'shipped', 'delivered', 'cancelled'].map((s) => ({ value: s, label: s.charAt(0).toUpperCase() + s.slice(1) })) },
      ]}
      exportFilename="marketplace-orders.csv"
    />
  );
};

export default MarketplacePage;
