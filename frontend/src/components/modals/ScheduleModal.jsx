import { useEffect } from 'react';
import { Grid, MenuItem, TextField } from '@mui/material';
import { useForm } from 'react-hook-form';
import FormModal from '../common/FormModal';

const ScheduleModal = ({ open, onClose, onSave, editData, hosts, platforms }) => {
  const { register, handleSubmit, reset } = useForm();

  useEffect(() => {
    if (editData) reset(editData);
    else reset({
      host_id: hosts?.[0]?.id || '',
      platform_id: platforms?.[0]?.id || '',
      title: 'Live Session',
      schedule_date: '',
      start_time: '10:00',
      end_time: '12:00',
      status: 'scheduled',
    });
  }, [editData, open, reset, hosts, platforms]);

  return (
    <FormModal open={open} onClose={onClose} title={editData ? 'Edit Schedule' : 'Add Schedule'} onSubmit={handleSubmit(onSave)}>
      <Grid container spacing={2}>
        <Grid item xs={12} md={6}>
          <TextField fullWidth select label="Host" {...register('host_id', { required: true })}>
            {(hosts || []).map((h) => <MenuItem key={h.id} value={h.id}>{h.name}</MenuItem>)}
          </TextField>
        </Grid>
        <Grid item xs={12} md={6}>
          <TextField fullWidth select label="Platform" {...register('platform_id', { required: true })}>
            {(platforms || []).map((p) => <MenuItem key={p.id} value={p.id}>{p.name}</MenuItem>)}
          </TextField>
        </Grid>
        <Grid item xs={12}>
          <TextField fullWidth label="Title" {...register('title', { required: true })} />
        </Grid>
        <Grid item xs={12} md={4}>
          <TextField fullWidth type="date" label="Date" InputLabelProps={{ shrink: true }} {...register('schedule_date', { required: true })} />
        </Grid>
        <Grid item xs={12} md={4}>
          <TextField fullWidth type="time" label="Start Time" InputLabelProps={{ shrink: true }} {...register('start_time', { required: true })} />
        </Grid>
        <Grid item xs={12} md={4}>
          <TextField fullWidth type="time" label="End Time" InputLabelProps={{ shrink: true }} {...register('end_time', { required: true })} />
        </Grid>
        <Grid item xs={12} md={6}>
          <TextField fullWidth select label="Status" {...register('status')}>
            <MenuItem value="scheduled">Scheduled</MenuItem>
            <MenuItem value="completed">Completed</MenuItem>
            <MenuItem value="cancelled">Cancelled</MenuItem>
          </TextField>
        </Grid>
      </Grid>
    </FormModal>
  );
};

export default ScheduleModal;
