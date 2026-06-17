import DataTable from '../../components/common/DataTable';
import { customerAPI } from '../../services';

const CustomersPage = () => {
  const columns = [
    { field: 'name', label: 'Name' },
    { field: 'email', label: 'Email' },
    { field: 'phone', label: 'Phone' },
    { field: 'address', label: 'Address' },
    { field: 'created_at', label: 'Created', render: (r) => r.created_at?.slice(0, 10) },
  ];

  return (
    <DataTable title="Customers" columns={columns} fetchData={customerAPI.getAll} exportFilename="customers.csv" />
  );
};

export default CustomersPage;
