import { useState, useEffect } from 'react';
import { toast } from 'react-toastify';
import DataTable from '../components/common/DataTable';
import ReturnModal from '../components/modals/ReturnModal';
import { masterAPI, returnAPI } from '../services';

const ReturnsPage = ({ showAdd = true }) => {
  const [modalOpen, setModalOpen] = useState(false);
  const [orders, setOrders] = useState([]);
  const [products, setProducts] = useState([]);
  const [refreshKey, setRefreshKey] = useState(0);

  useEffect(() => {
    masterAPI.getAll().then((res) => {
      setOrders(res.data.data.orders);
      setProducts(res.data.data.products);
    }).catch(console.error);
  }, []);

  const columns = [
    { field: 'order_number', label: 'Order' },
    { field: 'product_name', label: 'Product' },
    { field: 'customer_name', label: 'Customer' },
    { field: 'quantity', label: 'Qty' },
    { field: 'return_date', label: 'Date' },
    { field: 'status', label: 'Status' },
    { field: 'reason', label: 'Reason' },
  ];

  const handleSave = async (data) => {
    try {
      await returnAPI.create(data);
      toast.success('Return created successfully');
      setModalOpen(false);
      setRefreshKey((k) => k + 1);
    } catch (error) {
      toast.error(error.response?.data?.message || 'Failed to create return');
    }
  };

  return (
    <>
      <DataTable
        title="Returns Report"
        columns={columns}
        fetchData={returnAPI.getAll}
        filterOptions={[{ key: 'status', label: 'Status', options: [{ value: 'pending', label: 'Pending' }, { value: 'approved', label: 'Approved' }, { value: 'completed', label: 'Completed' }] }]}
        onAdd={showAdd ? () => setModalOpen(true) : undefined}
        addLabel="Add Return"
        exportFilename="returns.csv"
        refreshKey={refreshKey}
      />
      {showAdd && <ReturnModal open={modalOpen} onClose={() => setModalOpen(false)} onSave={handleSave} orders={orders} products={products} />}
    </>
  );
};

export default ReturnsPage;
