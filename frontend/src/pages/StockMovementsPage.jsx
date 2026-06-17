import DataTable from '../components/common/DataTable';
import { stockAPI } from '../services';

const StockMovementsPage = () => {
  const columns = [
    { field: 'product_name', label: 'Product' },
    { field: 'sku', label: 'SKU' },
    { field: 'movement_type', label: 'Type' },
    { field: 'quantity', label: 'Qty' },
    { field: 'reference_type', label: 'Reference' },
    { field: 'notes', label: 'Notes' },
    { field: 'created_by_name', label: 'By' },
    { field: 'created_at', label: 'Date', render: (r) => r.created_at?.slice(0, 16) },
  ];

  return (
    <DataTable
      title="Stock Movements"
      columns={columns}
      fetchData={stockAPI.getAll}
      filterOptions={[{ key: 'movement_type', label: 'Type', options: [{ value: 'IN', label: 'IN' }, { value: 'OUT', label: 'OUT' }] }]}
      exportFilename="stock-movements.csv"
    />
  );
};

export default StockMovementsPage;
