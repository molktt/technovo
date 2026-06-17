import { useEffect } from 'react';
import { Grid, MenuItem, TextField } from '@mui/material';
import { useForm } from 'react-hook-form';
import FormModal from '../common/FormModal';

const ProductModal = ({ open, onClose, onSave, editData, categories }) => {
  const { register, handleSubmit, reset, formState: { errors } } = useForm();

  useEffect(() => {
    if (editData) reset(editData);
    else reset({ name: '', sku: '', brand: 'ASUS', category_id: 1, price: 0, stock: 0 });
  }, [editData, open, reset]);

  const brands = ['ASUS', 'Acer', 'Dell', 'Lenovo', 'HP', 'Toshiba', 'Fujitsu'];

  return (
    <FormModal open={open} onClose={onClose} title={editData ? 'Edit Product' : 'Add Product'} onSubmit={handleSubmit(onSave)}>
      <Grid container spacing={2}>
        <Grid item xs={12} md={6}>
          <TextField fullWidth label="Product Name" {...register('name', { required: true })} error={!!errors.name} />
        </Grid>
        <Grid item xs={12} md={6}>
          <TextField fullWidth label="SKU" {...register('sku', { required: true })} error={!!errors.sku} />
        </Grid>
        <Grid item xs={12} md={6}>
          <TextField fullWidth select label="Brand" {...register('brand', { required: true })}>
            {brands.map((b) => <MenuItem key={b} value={b}>{b}</MenuItem>)}
          </TextField>
        </Grid>
        <Grid item xs={12} md={6}>
          <TextField fullWidth select label="Category" {...register('category_id', { required: true })}>
            {(categories || []).map((c) => <MenuItem key={c.id} value={c.id}>{c.name}</MenuItem>)}
          </TextField>
        </Grid>
        <Grid item xs={12} md={6}>
          <TextField fullWidth type="number" label="Price" {...register('price', { required: true, valueAsNumber: true })} />
        </Grid>
        <Grid item xs={12} md={6}>
          <TextField fullWidth type="number" label="Stock" {...register('stock', { valueAsNumber: true })} />
        </Grid>
      </Grid>
    </FormModal>
  );
};

export default ProductModal;
