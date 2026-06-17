import { useEffect, useState } from 'react';
import {
  Box, Card, CardContent, Grid, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Typography,
} from '@mui/material';
import ShoppingCartIcon from '@mui/icons-material/ShoppingCart';
import StorefrontIcon from '@mui/icons-material/Storefront';
import ReceiptIcon from '@mui/icons-material/Receipt';
import EmojiEventsIcon from '@mui/icons-material/EmojiEvents';
import InventoryIcon from '@mui/icons-material/Inventory';
import {
  Bar, BarChart, CartesianGrid, Legend, Line, LineChart, ResponsiveContainer, Tooltip, XAxis, YAxis,
} from 'recharts';
import StatCard from '../components/common/StatCard';

const formatCurrency = (val) => `Rp ${Number(val || 0).toLocaleString('id-ID')}`;

const DashboardView = ({ fetchDashboard, title }) => {
  const [data, setData] = useState(null);

  useEffect(() => {
    fetchDashboard().then((res) => setData(res.data.data)).catch(console.error);
  }, [fetchDashboard]);

  if (!data) return <Typography>Loading dashboard...</Typography>;

  const { summary, charts, recentActivities, recentOrders } = data;

  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>{title}</Typography>

      <Grid container spacing={2} mb={3}>
        <Grid item xs={12} sm={6} md={4} lg={2}>
          <StatCard title="Total Live Sales" value={formatCurrency(summary.totalLiveSales)} icon={<ShoppingCartIcon />} />
        </Grid>
        <Grid item xs={12} sm={6} md={4} lg={2}>
          <StatCard title="Total Marketplace Sales" value={formatCurrency(summary.totalMarketplaceSales)} icon={<StorefrontIcon />} color="#8A6CFF" />
        </Grid>
        <Grid item xs={12} sm={6} md={4} lg={2}>
          <StatCard title="Total Orders" value={summary.totalOrders} icon={<ReceiptIcon />} color="#10B981" />
        </Grid>
        <Grid item xs={12} sm={6} md={4} lg={3}>
          <StatCard title="Total Bonus Host" value={formatCurrency(summary.totalBonusHost)} icon={<EmojiEventsIcon />} color="#F59E0B" />
        </Grid>
        <Grid item xs={12} sm={6} md={4} lg={3}>
          <StatCard title="Total Products Sold" value={summary.totalProductsSold} icon={<InventoryIcon />} color="#EF4444" />
        </Grid>
      </Grid>

      <Grid container spacing={2} mb={3}>
        <Grid item xs={12} lg={8}>
          <Card><CardContent>
            <Typography variant="h6" fontWeight={600} mb={2}>Sales Trend</Typography>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={charts.salesTrend}>
                <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                <XAxis dataKey="month" />
                <YAxis />
                <Tooltip formatter={(v) => formatCurrency(v)} />
                <Legend />
                <Line type="monotone" dataKey="liveSales" stroke="#6C4CF1" strokeWidth={2} name="Live Sales" />
                <Line type="monotone" dataKey="marketplaceSales" stroke="#8A6CFF" strokeWidth={2} name="Marketplace" />
              </LineChart>
            </ResponsiveContainer>
          </CardContent></Card>
        </Grid>
        <Grid item xs={12} lg={4}>
          <Card sx={{ mb: 2 }}><CardContent>
            <Typography variant="h6" fontWeight={600} mb={2}>Marketplace Comparison</Typography>
            <ResponsiveContainer width="100%" height={140}>
              <BarChart data={charts.marketplaceComparison}>
                <XAxis dataKey="platform" tick={{ fontSize: 11 }} />
                <YAxis tick={{ fontSize: 11 }} />
                <Tooltip formatter={(v) => formatCurrency(v)} />
                <Bar dataKey="total" fill="#6C4CF1" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </CardContent></Card>
          <Card><CardContent>
            <Typography variant="h6" fontWeight={600} mb={2}>Stock Summary</Typography>
            {(charts.stockSummary || []).map((s) => (
              <Box key={s.category} sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
                <Typography variant="body2">{s.category}</Typography>
                <Typography variant="body2" fontWeight={600}>{s.stock} units</Typography>
              </Box>
            ))}
          </CardContent></Card>
        </Grid>
      </Grid>

      <Grid container spacing={2}>
        <Grid item xs={12} lg={6}>
          <Card><CardContent>
            <Typography variant="h6" fontWeight={600} mb={2}>Recent Activities</Typography>
            <TableContainer><Table size="small">
              <TableHead><TableRow>
                <TableCell>User</TableCell><TableCell>Action</TableCell><TableCell>Module</TableCell><TableCell>Date</TableCell>
              </TableRow></TableHead>
              <TableBody>
                {(recentActivities || []).map((a) => (
                  <TableRow key={a.id}>
                    <TableCell>{a.user_name}</TableCell>
                    <TableCell>{a.action}</TableCell>
                    <TableCell>{a.module}</TableCell>
                    <TableCell>{a.created_at?.slice(0, 16)}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table></TableContainer>
          </CardContent></Card>
        </Grid>
        <Grid item xs={12} lg={6}>
          <Card><CardContent>
            <Typography variant="h6" fontWeight={600} mb={2}>Recent Orders</Typography>
            <TableContainer><Table size="small">
              <TableHead><TableRow>
                <TableCell>Order</TableCell><TableCell>Customer</TableCell><TableCell>Platform</TableCell><TableCell>Amount</TableCell>
              </TableRow></TableHead>
              <TableBody>
                {(recentOrders || []).map((o) => (
                  <TableRow key={o.id}>
                    <TableCell>{o.order_number || `#${o.id}`}</TableCell>
                    <TableCell>{o.customer_name || o.platform_name}</TableCell>
                    <TableCell>{o.platform_name || '-'}</TableCell>
                    <TableCell>{formatCurrency(o.total_amount)}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table></TableContainer>
          </CardContent></Card>
        </Grid>
      </Grid>
    </Box>
  );
};

export default DashboardView;
