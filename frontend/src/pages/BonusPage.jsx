import DataTable from '../components/common/DataTable';
import { bonusAPI } from '../services';

const formatCurrency = (val) => `Rp ${Number(val || 0).toLocaleString('id-ID')}`;

const BonusPage = ({ title = 'Host Bonus' }) => {
  const columns = [
    { field: 'host_name', label: 'Host' },
    { field: 'laptop_qty', label: 'Laptop Qty' },
    { field: 'laptop_bonus', label: 'Laptop Bonus', render: (r) => formatCurrency(r.laptop_bonus) },
    { field: 'chromebook_qty', label: 'Chromebook Qty' },
    { field: 'chromebook_bonus', label: 'Chromebook Bonus', render: (r) => formatCurrency(r.chromebook_bonus) },
    { field: 'total_bonus', label: 'Total Bonus', render: (r) => formatCurrency(r.total_bonus) },
  ];

  return (
    <DataTable title={title} columns={columns} fetchData={bonusAPI.getAll} exportFilename="host-bonus.csv" />
  );
};

export default BonusPage;
