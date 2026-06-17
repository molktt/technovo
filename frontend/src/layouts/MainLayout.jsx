import {
  Avatar, Box, Divider, Drawer, IconButton, List, ListItemButton, ListItemIcon,
  ListItemText, Toolbar, Typography, useMediaQuery, useTheme,
} from '@mui/material';
import MenuIcon from '@mui/icons-material/Menu';
import LogoutIcon from '@mui/icons-material/Logout';
import { useState } from 'react';
import { NavLink, Outlet, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const drawerWidth = 260;

const menuByRole = {
  LEADER: [
    { label: 'Dashboard', path: '/leader/dashboard' },
    { label: 'Live Schedules', path: '/leader/live-schedules' },
    { label: 'Live Sales Report', path: '/leader/live-sales' },
    { label: 'Marketplace Report', path: '/leader/marketplace' },
    { label: 'Returns Report', path: '/leader/returns' },
    { label: 'Host Bonus', path: '/leader/bonus' },
    { label: 'Products', path: '/leader/products' },
    { label: 'Stock Movements', path: '/leader/stock' },
    { label: 'Users', path: '/leader/users' },
    { label: 'Activity Logs', path: '/leader/activity-logs' },
  ],
  ADMIN: [
    { label: 'Dashboard', path: '/admin/dashboard' },
    { label: 'Marketplace Orders', path: '/admin/orders' },
    { label: 'Products', path: '/admin/products' },
    { label: 'Returns', path: '/admin/returns' },
    { label: 'Stock Movements', path: '/admin/stock' },
    { label: 'Customers', path: '/admin/customers' },
  ],
  HOST: [
    { label: 'Dashboard', path: '/host/dashboard' },
    { label: 'My Schedule', path: '/host/schedule' },
    { label: 'My Live Sales', path: '/host/live-sales' },
    { label: 'My Bonus', path: '/host/bonus' },
  ],
};

const SidebarContent = ({ collapsed, onNavigate = () => {} }) => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const menus = menuByRole[user?.role] || [];

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <Box sx={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      <Toolbar sx={{ px: collapsed ? 1 : 2 }}>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <Avatar sx={{ bgcolor: 'primary.main', width: 36, height: 36, fontSize: 14, fontWeight: 700 }}>TN</Avatar>
          {!collapsed && (
            <Box>
              <Typography variant="subtitle1" fontWeight={800}>TECHNOVO</Typography>
              <Typography variant="caption" color="text.secondary">INDONESIA</Typography>
            </Box>
          )}
        </Box>
      </Toolbar>
      <Divider />
      <List sx={{ flex: 1, px: 1, py: 2 }}>
        {menus.map((item) => (
          <ListItemButton
            key={item.path}
            component={NavLink}
            to={item.path}
            onClick={onNavigate}
            sx={{
              borderRadius: 2, mb: 0.5,
              '&.active': { bgcolor: 'primary.main', color: '#fff', '& .MuiListItemIcon-root': { color: '#fff' } },
            }}
          >
            <ListItemIcon sx={{ minWidth: 36 }}><Box sx={{ width: 8, height: 8, borderRadius: '50%', bgcolor: 'primary.main' }} /></ListItemIcon>
            {!collapsed && <ListItemText primary={item.label} primaryTypographyProps={{ fontSize: 14, fontWeight: 500 }} />}
          </ListItemButton>
        ))}
      </List>
      <Divider />
      <Box sx={{ p: 2 }}>
        {!collapsed && (
          <Typography variant="body2" fontWeight={600} gutterBottom>{user?.full_name}</Typography>
        )}
        <ListItemButton onClick={handleLogout} sx={{ borderRadius: 2 }}>
          <ListItemIcon sx={{ minWidth: 36 }}><LogoutIcon fontSize="small" /></ListItemIcon>
          {!collapsed && <ListItemText primary="Logout" />}
        </ListItemButton>
      </Box>
    </Box>
  );
};

const MainLayout = () => {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));
  const isTablet = useMediaQuery(theme.breakpoints.between('md', 'lg'));
  const [mobileOpen, setMobileOpen] = useState(false);
  const collapsed = isTablet;

  return (
    <Box sx={{ display: 'flex', minHeight: '100vh', bgcolor: 'background.default' }}>
      {!isMobile && (
        <Drawer
          variant="permanent"
          sx={{
            width: collapsed ? 72 : drawerWidth,
            flexShrink: 0,
            '& .MuiDrawer-paper': {
              width: collapsed ? 72 : drawerWidth,
              boxSizing: 'border-box',
              borderRight: '1px solid',
              borderColor: 'divider',
            },
          }}
        >
          <SidebarContent collapsed={collapsed} />
        </Drawer>
      )}

      {isMobile && (
        <Drawer
          variant="temporary"
          open={mobileOpen}
          onClose={() => setMobileOpen(false)}
          ModalProps={{ keepMounted: true }}
          sx={{ '& .MuiDrawer-paper': { width: drawerWidth } }}
        >
          <SidebarContent onNavigate={() => setMobileOpen(false)} />
        </Drawer>
      )}

      <Box component="main" sx={{ flex: 1, p: { xs: 2, md: 3 }, overflow: 'auto' }}>
        {isMobile && (
          <IconButton onClick={() => setMobileOpen(true)} sx={{ mb: 2 }}>
            <MenuIcon />
          </IconButton>
        )}
        <Outlet />
      </Box>
    </Box>
  );
};

export default MainLayout;
