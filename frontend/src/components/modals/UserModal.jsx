import { useEffect } from 'react';
import { Grid, MenuItem, TextField } from '@mui/material';
import { useForm } from 'react-hook-form';
import FormModal from '../common/FormModal';

const UserModal = ({ open, onClose, onSave, editData }) => {
  const { register, handleSubmit, reset, formState: { errors } } = useForm();

  useEffect(() => {
    if (editData) reset({ ...editData, password: '' });
    else reset({ full_name: '', email: '', password: '', role: 'HOST', is_active: 1 });
  }, [editData, open, reset]);

  return (
    <FormModal open={open} onClose={onClose} title={editData ? 'Edit User' : 'Add User'} onSubmit={handleSubmit(onSave)}>
      <Grid container spacing={2}>
        <Grid item xs={12} md={6}>
          <TextField fullWidth label="Name" {...register('full_name', { required: true })} error={!!errors.full_name} />
        </Grid>
        <Grid item xs={12} md={6}>
          <TextField fullWidth label="Email" type="email" {...register('email', { required: true })} error={!!errors.email} />
        </Grid>
        <Grid item xs={12} md={6}>
          <TextField fullWidth label="Password" type="password" {...register('password', { required: !editData })} />
        </Grid>
        <Grid item xs={12} md={6}>
          <TextField fullWidth select label="Role" {...register('role', { required: true })}>
            <MenuItem value="LEADER">LEADER</MenuItem>
            <MenuItem value="ADMIN">ADMIN</MenuItem>
            <MenuItem value="HOST">HOST</MenuItem>
          </TextField>
        </Grid>
        {editData && (
          <Grid item xs={12} md={6}>
            <TextField fullWidth select label="Status" {...register('is_active')}>
              <MenuItem value={1}>Active</MenuItem>
              <MenuItem value={0}>Inactive</MenuItem>
            </TextField>
          </Grid>
        )}
      </Grid>
    </FormModal>
  );
};

export default UserModal;
