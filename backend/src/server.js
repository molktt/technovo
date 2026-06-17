require('dotenv').config();
const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/authRoutes');
const dashboardRoutes = require('./routes/dashboardRoutes');
const productRoutes = require('./routes/productRoutes');
const userRoutes = require('./routes/userRoutes');
const liveScheduleRoutes = require('./routes/liveScheduleRoutes');
const liveSaleRoutes = require('./routes/liveSaleRoutes');
const marketplaceRoutes = require('./routes/marketplaceRoutes');
const returnRoutes = require('./routes/returnRoutes');
const bonusRoutes = require('./routes/bonusRoutes');
const customerRoutes = require('./routes/customerRoutes');
const stockMovementRoutes = require('./routes/stockMovementRoutes');
const activityLogRoutes = require('./routes/activityLogRoutes');
const masterRoutes = require('./routes/masterRoutes');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/api/health', (req, res) => {
  res.json({ success: true, message: 'TECHNOVO API is running' });
});

app.use('/api/auth', authRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/products', productRoutes);
app.use('/api/users', userRoutes);
app.use('/api/live-schedules', liveScheduleRoutes);
app.use('/api/live-sales', liveSaleRoutes);
app.use('/api/orders', marketplaceRoutes);
app.use('/api/returns', returnRoutes);
app.use('/api/bonus-host', bonusRoutes);
app.use('/api/customers', customerRoutes);
app.use('/api/stock-movements', stockMovementRoutes);
app.use('/api/activity-logs', activityLogRoutes);
app.use('/api/master', masterRoutes);

app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ success: false, message: 'Internal server error' });
});

app.listen(PORT, () => {
  console.log(`TECHNOVO Backend running on http://localhost:${PORT}`);
});
