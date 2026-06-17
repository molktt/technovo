import api from './api';

export const authAPI = {
  login: (data) => api.post('/auth/login', data),
};

export const dashboardAPI = {
  leader: () => api.get('/dashboard/leader'),
  admin: () => api.get('/dashboard/admin'),
  host: () => api.get('/dashboard/host'),
};

export const productAPI = {
  getAll: (params) => api.get('/products', { params }),
  getById: (id) => api.get(`/products/${id}`),
  create: (data) => api.post('/products', data),
  update: (id, data) => api.put(`/products/${id}`, data),
  delete: (id) => api.delete(`/products/${id}`),
};

export const userAPI = {
  getAll: (params) => api.get('/users', { params }),
  create: (data) => api.post('/users', data),
  update: (id, data) => api.put(`/users/${id}`, data),
  delete: (id) => api.delete(`/users/${id}`),
};

export const scheduleAPI = {
  getAll: (params) => api.get('/live-schedules', { params }),
  create: (data) => api.post('/live-schedules', data),
  update: (id, data) => api.put(`/live-schedules/${id}`, data),
  delete: (id) => api.delete(`/live-schedules/${id}`),
};

export const liveSaleAPI = {
  getAll: (params) => api.get('/live-sales', { params }),
  create: (data) => api.post('/live-sales', data),
};

export const orderAPI = {
  getAll: (params) => api.get('/orders', { params }),
  create: (data) => api.post('/orders', data),
};

export const returnAPI = {
  getAll: (params) => api.get('/returns', { params }),
  create: (data) => api.post('/returns', data),
};

export const bonusAPI = {
  getAll: (params) => api.get('/bonus-host', { params }),
};

export const customerAPI = {
  getAll: (params) => api.get('/customers', { params }),
};

export const stockAPI = {
  getAll: (params) => api.get('/stock-movements', { params }),
};

export const activityAPI = {
  getAll: (params) => api.get('/activity-logs', { params }),
};

export const masterAPI = {
  getAll: () => api.get('/master'),
};
