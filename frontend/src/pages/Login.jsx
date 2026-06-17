import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box, Button, Grid, IconButton, InputAdornment, Paper, Stack, TextField, Typography,
} from '@mui/material';
import Visibility from '@mui/icons-material/Visibility';
import VisibilityOff from '@mui/icons-material/VisibilityOff';
import { toast } from 'react-toastify';
import { useAuth } from '../context/AuthContext';
import { authAPI } from '../services';

const LoginIllustration = () => (
  <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100%', p: 4 }}>
    <Box sx={{ maxWidth: 480, textAlign: 'center' }}>
      <Box
        component="svg"
        viewBox="0 0 500 400"
        sx={{ width: '100%', maxHeight: 360 }}
      >
        <ellipse cx="250" cy="340" rx="180" ry="30" fill="#E8E0FF" />
        <rect x="120" y="220" width="260" height="12" rx="6" fill="#D4A574" />
        <rect x="130" y="180" width="240" height="40" rx="4" fill="#C4956A" />
        <rect x="280" y="150" width="80" height="50" rx="4" fill="#333" />
        <rect x="160" y="195" width="100" height="65" rx="4" fill="#14B8A6" />
        <rect x="165" y="200" width="90" height="50" rx="2" fill="#0D9488" />
        <circle cx="320" cy="80" r="35" fill="#fff" stroke="#E5E7EB" strokeWidth="3" />
        <line x1="320" y1="55" x2="320" y2="80" stroke="#333" strokeWidth="2" />
        <line x1="320" y1="80" x2="340" y2="90" stroke="#333" strokeWidth="2" />
        <ellipse cx="200" cy="260" rx="25" ry="8" fill="#FBBF24" />
        <rect x="175" y="230" width="50" height="30" rx="8" fill="#FBBF24" />
        <circle cx="200" cy="210" r="22" fill="#FCD34D" />
        <circle cx="200" cy="200" r="18" fill="#FFE4B5" />
        <rect x="185" y="175" width="30" height="25" rx="12" fill="#333" />
        <rect x="188" y="235" width="24" height="35" fill="#333" />
        <rect x="182" y="268" width="12" height="8" fill="#EC4899" />
        <rect x="206" y="268" width="12" height="8" fill="#EC4899" />
        <rect x="350" y="280" width="40" height="60" rx="4" fill="#14B8A6" />
      </Box>
      <Typography variant="h6" fontWeight={600} mt={2} color="text.secondary">
        Online Sales Monitoring & Analytics
      </Typography>
    </Box>
  </Box>
);

const Login = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await authAPI.login({ email, password });
      console.log(res.data);
      const { token, user } = res.data;
      login(token, user);
      toast.success('Login successful');

      // Normalize role to avoid mismatch (case/spaces) from backend response
      const role = (user?.role ?? '').toString().trim().toUpperCase();

      const routes = {
        LEADER: '/leader/dashboard',
        ADMIN: '/admin/dashboard',
        HOST: '/host/dashboard',
      };

      // If role is missing/unknown, still redirect away from /login.
      // Prefer leader as a safe default (you can change this if needed).
      const fallbackRoute = '/leader/dashboard';
      navigate(routes[role] || fallbackRoute);
    } catch (error) {
      toast.error(error.response?.data?.message || 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Grid container sx={{ minHeight: '100vh', bgcolor: '#F8F9FC' }}>
      <Grid item xs={12} md={6} sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', p: 4 }}>
        <Paper elevation={0} sx={{ width: '100%', maxWidth: 420, p: 4, borderRadius: 4, border: '1px solid #E5E7EB' }}>
          <Stack alignItems="center" spacing={1} mb={4}>
            <Box
              sx={{
                width: 56, height: 56, borderRadius: 3,
                background: 'linear-gradient(135deg, #6C4CF1 0%, #8A6CFF 100%)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                color: '#fff', fontWeight: 800, fontSize: 20,
              }}
            >
              TN
            </Box>
            <Typography variant="h5" fontWeight={800}>TECHNOVO</Typography>
            <Typography variant="caption" color="text.secondary" letterSpacing={2}>INDONESIA</Typography>
          </Stack>

          <Typography variant="h6" fontWeight={600} mb={3}>Log in</Typography>

          <Box component="form" onSubmit={handleSubmit}>
            <TextField
              fullWidth
              label="Email Address"
              placeholder="example@gmail.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              sx={{ mb: 2 }}
              required
            />
            <TextField
              fullWidth
              label="Password"
              type={showPassword ? 'text' : 'password'}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              sx={{ mb: 3 }}
              required
              InputProps={{
                endAdornment: (
                  <InputAdornment position="end">
                    <IconButton onClick={() => setShowPassword(!showPassword)} edge="end" size="small">
                      {showPassword ? <VisibilityOff /> : <Visibility />}
                    </IconButton>
                  </InputAdornment>
                ),
              }}
            />
            <Button fullWidth type="submit" variant="contained" size="large" disabled={loading} sx={{ py: 1.5, borderRadius: 3 }}>
              Log in
            </Button>
          </Box>

          <Typography variant="caption" color="text.secondary" display="block" mt={3} textAlign="center">
            Default: sarif@technovo.id / password123
          </Typography>
        </Paper>
      </Grid>
      <Grid item xs={12} md={6} sx={{ display: { xs: 'none', md: 'block' } }}>
        <LoginIllustration />
      </Grid>
    </Grid>
  );
};

export default Login;
