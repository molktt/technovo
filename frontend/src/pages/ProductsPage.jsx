import { useState, useEffect } from 'react';
import { IconButton } from '@mui/material';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import { toast } from 'react-toastify';
import DataTable from '../components/common/DataTable';
import ProductModal from '../components/modals/ProductModal';
import { masterAPI, productAPI } from '../services';

const formatCurrency = (val) => `Rp ${Number(val).toLocaleString('id-ID')}`;

const ProductsPage = ({ canDelete = false }) => {
  const [modalOpen, setModalOpen] = useState(false);
  const [editData, setEditData] = useState(null);
  const [categories, setCategories] = useState([]);
  const [refreshKey, setRefreshKey] = useState(0);

  useEffect(() => {
    masterAPI.getAll().then((res) => setCategories(res.data.data.categories)).catch(console.error);
  }, []);

  const columns = [
    { field: 'sku', label: 'SKU' },
    { field: 'name', label: 'Name' },
    { field: 'brand', label: 'Brand' },
    { field: 'category_name', label: 'Category' },
    { field: 'price', label: 'Price', render: (r) => formatCurrency(r.price) },
    { field: 'stock', label: 'Stock' },
    {
      label: 'Actions',
      sortable: false,
      render: (row) => (
        <>
          <IconButton size="small" onClick={() => { setEditData(row); setModalOpen(true); }}><EditIcon fontSize="small" /></IconButton>
          {canDelete && (
            <IconButton size="small" color="error" onClick={async () => {
              if (window.confirm('Delete this product?')) {
                await productAPI.delete(row.id);
                toast.success('Product deleted successfully');
                setRefreshKey((k) => k + 1);
              }
            }}><DeleteIcon fontSize="small" /></IconButton>
          )}
        </>
      ),
    },
  ];

  const handleSave = async (data) => {
    try {
      if (editData) {
        await productAPI.update(editData.id, data);
        toast.success('Product updated successfully');
      } else {
        await productAPI.create(data);
        toast.success('Product created successfully');
      }
      setModalOpen(false);
      setEditData(null);
      setRefreshKey((k) => k + 1);
    } catch (error) {
      toast.error(error.response?.data?.message || 'Failed to save product');
    }
  };

  return (
    <>
      <DataTable
        title="Products"
        columns={columns}
        fetchData={productAPI.getAll}
        filterOptions={[
          { key: 'category_id', label: 'Category', options: categories.map((c) => ({ value: c.id, label: c.name })) },
        ]}
        onAdd={() => { setEditData(null); setModalOpen(true); }}
        addLabel="Add Product"
        exportFilename="products.csv"
        refreshKey={refreshKey}
      />
      <ProductModal open={modalOpen} onClose={() => { setModalOpen(false); setEditData(null); }} onSave={handleSave} editData={editData} categories={categories} />
    </>
  );
};

export default ProductsPage;
