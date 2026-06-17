import { createTheme } from '@mui/material/styles';

const theme = createTheme({
  palette: {
    primary: { main: '#6C4CF1', light: '#8A6CFF', dark: '#5236D9' },
    secondary: { main: '#8A6CFF' },
    background: { default: '#F8F9FC', paper: '#FFFFFF' },
    divider: '#E5E7EB',
    text: { primary: '#1F2937', secondary: '#6B7280' },
  },
  typography: {
    fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
  },
  shape: { borderRadius: 16 },
  components: {
    MuiCard: {
      styleOverrides: {
        root: {
          boxShadow: '0 4px 24px rgba(108, 76, 241, 0.08)',
          border: '1px solid #E5E7EB',
        },
      },
    },
    MuiButton: {
      styleOverrides: {
        root: { textTransform: 'none', fontWeight: 600, borderRadius: 12 },
      },
    },
    MuiDialog: {
      styleOverrides: {
        paper: { borderRadius: 16 },
      },
    },
  },
});

export default theme;
