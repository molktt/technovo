# TECHNOVO - Project Documentation

## 1. Folder Structure

### Backend (`backend/`)

| Folder/File | Description |
|-------------|-------------|
| `src/server.js` | Entry point Express, route registration |
| `src/config/db.js` | MySQL connection pool (mysql2) |
| `src/controllers/` | Request handlers per module |
| `src/middleware/auth.js` | JWT verification |
| `src/middleware/role.js` | Role-based access control |
| `src/routes/` | API route definitions |
| `src/services/bonusService.js` | Bonus calculation business logic |
| `src/utils/` | Response helper, activity logger |
| `src/sql/technovo_db.sql` | Database schema + seed data |
| `scripts/generate-sql.js` | SQL seed generator |

### Frontend (`frontend/src/`)

| Folder | Description |
|--------|-------------|
| `components/common/` | DataTable, FormModal, StatCard |
| `components/modals/` | CRUD modal forms |
| `layouts/MainLayout.jsx` | Sidebar + responsive layout |
| `pages/` | Page components per role |
| `services/` | Axios API calls |
| `context/AuthContext.jsx` | Auth state management |
| `routes/` | React Router + protected routes |
| `theme/theme.js` | MUI theme (#6C4CF1 primary) |

---

## 2. Database Design

### Entity Relationship

```
users ──┬── live_schedules ── live_sales ── live_sale_items ── products
        │                                              │
        └── activity_logs                              └── categories ── bonus_rules

customers ── marketplace_orders ── marketplace_order_items ── products
                    │
                    └── returns

products ── stock_movements
platforms ── live_schedules / marketplace_orders
```

### Tables (14)

1. **users** — Akun sistem (LEADER, ADMIN, HOST)
2. **platforms** — Shopee, Tokopedia, Lazada, TikTok Shop
3. **categories** — Laptop, Chromebook
4. **bonus_rules** — Bonus per kategori (10000 / 3000)
5. **customers** — Data pelanggan marketplace
6. **products** — Produk dengan SKU, brand, stok
7. **live_schedules** — Jadwal live streaming
8. **live_sales** — Transaksi live shop
9. **live_sale_items** — Detail item live sale
10. **marketplace_orders** — Order marketplace
11. **marketplace_order_items** — Detail order
12. **returns** — Retur produk
13. **stock_movements** — Log pergerakan stok IN/OUT
14. **activity_logs** — Audit trail aktivitas user

---

## 3. API List

| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| POST | `/api/auth/login` | Public | Login |
| GET | `/api/dashboard/leader` | LEADER | Dashboard leader |
| GET | `/api/dashboard/admin` | ADMIN, LEADER | Dashboard admin |
| GET | `/api/dashboard/host` | HOST | Dashboard host |
| GET/POST/PUT/DELETE | `/api/products` | LEADER, ADMIN | CRUD produk |
| GET/POST/PUT/DELETE | `/api/users` | LEADER | CRUD user |
| GET/POST/PUT/DELETE | `/api/live-schedules` | LEADER, HOST (read) | Jadwal live |
| GET/POST | `/api/live-sales` | LEADER, HOST | Live sales |
| GET/POST | `/api/orders` | LEADER, ADMIN | Marketplace orders |
| GET/POST | `/api/returns` | LEADER, ADMIN | Returns |
| GET | `/api/bonus-host` | LEADER, HOST | Bonus host |
| GET | `/api/customers` | ADMIN, LEADER | Customers |
| GET | `/api/stock-movements` | LEADER, ADMIN | Stock log |
| GET | `/api/activity-logs` | LEADER | Activity logs |
| GET | `/api/master` | All authenticated | Master data dropdown |

---

## 4. Authentication Flow

```
1. User submit email + password (Login.jsx)
2. POST /api/auth/login → authController.login()
3. Query users table by email
4. bcrypt.compare(password, hash)
5. Generate JWT { id, name, email, role }
6. Log activity → activity_logs
7. Return token + user data
8. Frontend store token di localStorage
9. Axios interceptor attach Bearer token
10. Protected routes check role via ProtectedRoute.jsx
11. Backend middleware auth.js verify JWT
12. role.js check allowed roles per endpoint
```

---

## 5. Dashboard Calculation Logic

### Leader/Admin Summary Cards

| Card | Query Logic |
|------|-------------|
| Total Live Sales | SUM(live_sales.total_amount) WHERE status='completed' |
| Total Marketplace Sales | SUM(marketplace_orders.total_amount) WHERE status='delivered' |
| Total Orders | COUNT(marketplace_orders) |
| Total Bonus Host | SUM(live_sale_items.qty × bonus_rules.bonus_amount) |
| Total Products Sold | SUM qty from live_sale_items + marketplace_order_items (delivered) |

### Charts

- **Sales Trend**: Group by month (YYYY-MM) from live_sales + marketplace_orders
- **Marketplace Comparison**: SUM total_amount GROUP BY platform
- **Stock Summary**: SUM stock GROUP BY category

---

## 6. Bonus Calculation Logic

### Formula

```
Bonus per item = quantity × bonus_rules.bonus_amount

Laptop     → Rp 10.000 per unit
Chromebook → Rp  3.000 per unit

Total Host Bonus = SUM(live_sale_items.quantity × bonus_rules.bonus_amount)
```

### Business Rules

- Bonus dihitung dari **live sales** dengan status `completed`
- Produk harus match kategori di `bonus_rules`
- Return marketplace mengurangi eligibility order (tidak bonus marketplace)
- Host hanya melihat bonus sendiri; Leader melihat semua host

---

## 7. Role Permission Matrix

| Feature | LEADER | ADMIN | HOST |
|---------|--------|-------|------|
| Dashboard | ✅ | ✅ | ✅ |
| Live Schedules | ✅ CRUD | ❌ | ✅ Read |
| Live Sales Report | ✅ | ❌ | ✅ Own |
| Marketplace Report | ✅ | ✅ Orders | ❌ |
| Returns Report | ✅ | ✅ | ❌ |
| Host Bonus | ✅ All | ❌ | ✅ Own |
| Products | ✅ CRUD+Delete | ✅ CRUD | ❌ |
| Stock Movements | ✅ | ✅ | ❌ |
| Users | ✅ CRUD | ❌ | ❌ |
| Activity Logs | ✅ | ❌ | ❌ |
| Customers | ✅ | ✅ | ❌ |

---

## 8. Frontend Component Structure

```
App.jsx
├── AuthProvider
├── ThemeProvider
└── AppRoutes
    ├── Login.jsx
    └── MainLayout (per role)
        ├── Sidebar (responsive: drawer/collapse)
        └── Pages
            ├── DashboardView (shared charts/cards)
            ├── DataTable (search/filter/sort/pagination/export)
            └── Modals (Product, User, Schedule, Return)
```

---

## 9. Backend Architecture

```
Request → Express Router → auth middleware → role middleware → Controller → MySQL (mysql2)
                                                                    ↓
                                                          activityLogger (optional)
```

- **No ORM**: Raw SQL queries via mysql2/promise
- **Connection Pool**: Shared pool in config/db.js
- **Transactions**: Used for live_sales, orders, returns (multi-table inserts)

---

## 10. Data Flow

```
Frontend Page → services/index.js → Axios (/api/*) → Backend Route → Controller → MySQL
                                                                                    ↓
Frontend ← JSON Response ← sendSuccess/sendError ← Query Result ←──────────────────┘
```

Toast notifications via React Toastify for CRUD feedback.

---

## Feature Explanations

### LOGIN

| Item | Detail |
|------|--------|
| Frontend file | `frontend/src/pages/Login.jsx` |
| Backend Route | `POST /api/auth/login` |
| Controller | `authController.js` |
| Database Table | `users`, `activity_logs` |
| Flow | Form → API → bcrypt verify → JWT → redirect by role |

### PRODUCT

| Item | Detail |
|------|--------|
| Frontend file | `frontend/src/pages/ProductsPage.jsx` |
| Modal file | `frontend/src/components/modals/ProductModal.jsx` |
| API file | `frontend/src/services/index.js` → productAPI |
| Route | `/api/products` |
| Controller | `productController.js` |
| Database | `products`, `stock_movements`, `categories` |
| Flow | DataTable → Modal form → POST/PUT → toast → refresh table |

### LIVE SCHEDULE

| Item | Detail |
|------|--------|
| Frontend file | `frontend/src/pages/leader/LiveSchedulesPage.jsx` |
| API file | scheduleAPI in services |
| Route | `/api/live-schedules` |
| Controller | `liveScheduleController.js` |
| Database | `live_schedules`, `users`, `platforms` |
| Flow | Leader CRUD via modal; Host read-only via HostSchedulePage |

### MARKETPLACE

| Item | Detail |
|------|--------|
| Frontend file | `frontend/src/pages/MarketplacePage.jsx` |
| API file | orderAPI |
| Route | `/api/orders` |
| Controller | `marketplaceController.js` |
| Database | `marketplace_orders`, `marketplace_order_items`, `customers`, `platforms` |
| Flow | List orders with filter → Admin/Leader view reports |

### BONUS HOST

| Item | Detail |
|------|--------|
| Frontend file | `frontend/src/pages/BonusPage.jsx` |
| API file | bonusAPI |
| Route | `/api/bonus-host` |
| Controller | `bonusController.js` |
| Database | `live_sales`, `live_sale_items`, `products`, `categories`, `bonus_rules`, `users` |
| Flow | Aggregate bonus per host from completed live sales |
| Formula | `SUM(quantity × bonus_amount)` per category |
| Business Logic | Laptop=10000, Chromebook=3000; only completed live sales count |
