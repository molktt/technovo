import {
  Box, Button, Dialog, DialogActions, DialogContent, DialogTitle, IconButton, Typography,
} from '@mui/material';
import CloseIcon from '@mui/icons-material/Close';

const FormModal = ({
  open,
  onClose,
  title,
  onSubmit,
  children,
  loading = false,
  maxWidth = 'md',
}) => (
  <Dialog open={open} onClose={onClose} maxWidth={maxWidth} fullWidth PaperProps={{ sx: { maxWidth: 850 } }}>
    <DialogTitle sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', pb: 1 }}>
      <Typography variant="h6" fontWeight={700}>{title}</Typography>
      <IconButton onClick={onClose} size="small"><CloseIcon /></IconButton>
    </DialogTitle>
    <Box component="form" onSubmit={onSubmit}>
      <DialogContent dividers sx={{ py: 3 }}>{children}</DialogContent>
      <DialogActions sx={{ px: 3, py: 2 }}>
        <Button onClick={onClose} variant="outlined" color="inherit">Cancel</Button>
        <Button type="submit" variant="contained" disabled={loading}>Save</Button>
      </DialogActions>
    </Box>
  </Dialog>
);

export default FormModal;
