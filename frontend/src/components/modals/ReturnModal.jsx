import { useEffect } from 'react';
import { Grid, MenuItem, TextField } from '@mui/material';
import { useForm } from 'react-hook-form';
import FormModal from '../common/FormModal';

const ReturnModal = ({ open, onClose, onSave, orders, products }) => {
  const { register, handleSubmit, reset } = useForm();

  useEffect(() => {
    reset({
      order_id: orders?.[0]?.id || '',
      product_id: products?.[0]?.id || '',
      quantity: 1,
      reason: '',
      return_date: new Date().toISOString().slice(0, 10),
      status: 'pending',
    });
  }, [open, reset, orders, products]);

  return (
    <FormModal open={open} onClose={onClose} title="Add Return" onSubmit={handleSubmit(onSave)}>
      <Grid container spacing={2}>
        <Grid item xs={12} md={6}>
          <TextField fullWidth select label="Order" {...register('order_id', { required: true, valueAsNumber: true })}>
            {(orders || []).map((o) => <MenuItem key={o.id} value={o.id}>{o.order_number}</MenuItem>)}
          </TextField>
        </Grid>
        <Grid item xs={12} md={6}>
          <TextField fullWidth select label="Product" {...register('product_id', { required: true, valueAsNumber: true })}>
            {(products || []).map((p) => <MenuItem key={p.id} value={p.id}>{p.name}</MenuItem>)}
          </TextField>
        </Grid>
        <Grid item xs={12} md={4}>
          <TextField fullWidth type="number" label="Quantity" {...register('quantity', { required: true, valueAsNumber: true })} />
        </Grid>
        <Grid item xs={12} md={4}>
          <TextField fullWidth type="date" label="Return Date" InputLabelProps={{ shrink: true }} {...register('return_date', { required: true })} />
        </Grid>
        <Grid item xs={12} md={4}>
          <TextField fullWidth select label="Status" {...register('status')}>
            <MenuItem value="pending">Pending</MenuItem>
            <MenuItem value="approved">Approved</MenuItem>
            <MenuItem value="completed">Completed</MenuItem>
          </TextField>
        </Grid>
        <Grid item xs={12}>
          <TextField fullWidth multiline rows={3} label="Reason" {...register('reason')} />
        </Grid>
      </Grid>
    </FormModal>
  );
};

export default ReturnModal;
