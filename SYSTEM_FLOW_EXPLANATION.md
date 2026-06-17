# TECHNOVO - System Flow Explanation

## Overview

TECHNOVO adalah sistem monitoring penjualan online yang mengintegrasikan **Live Shop Sales** dan **Marketplace Orders** dalam satu dashboard analytics dengan kontrol akses berbasis role.

---

## System Architecture Diagram

```mermaid
flowchart TB
    subgraph Client
        FE[React Frontend :5173]
    end

    subgraph Server
        BE[Express API :5000]
        JWT[JWT Auth Middleware]
        ROLE[Role Middleware]
    end

    subgraph Database
        DB[(MySQL technovo_db)]
    end

    FE -->|Axios REST| BE
    BE --> JWT --> ROLE --> DB
```

---

## Login Flow

```mermaid
sequenceDiagram
    participant U as User
    participant L as Login.jsx
    participant A as Auth API
    participant D as MySQL

    U->>L: Enter email & password
    L->>A: POST /api/auth/login
    A->>D: SELECT user by email
    D-->>A: User record
    A->>A: bcrypt.compare()
    A->>A: jwt.sign()
    A->>D: INSERT activity_log
    A-->>L: token + user
    L->>L: Store localStorage
    L->>U: Redirect by role
```

**Role Redirect:**
- LEADER → `/leader/dashboard`
- ADMIN → `/admin/dashboard`
- HOST → `/host/dashboard`

---

## Product CRUD Flow (Modal Pattern)

```mermaid
flowchart LR
    A[Products Page] --> B[Click Add/Edit]
    B --> C[ProductModal opens]
    C --> D[React Hook Form]
    D --> E{Save?}
    E -->|Create| F[POST /api/products]
    E -->|Update| G[PUT /api/products/:id]
    F --> H[Insert product + stock_movement]
    G --> I[Update product + adjust stock]
    H --> J[Toast success]
    I --> J
    J --> K[Refresh DataTable]
```

**Design Rule:** Tidak ada halaman Add/Edit terpisah — semua CRUD via Material UI Dialog (700-900px).

---

## Live Schedule → Live Sales Flow

```mermaid
flowchart TD
    S[Create Live Schedule] --> LS[(live_schedules)]
    LS --> H[Host conducts live session]
    H --> LS2[Create Live Sale]
    LS2 --> LSA[(live_sales)]
    LSA --> LSI[(live_sale_items)]
    LSI --> ST[Update product stock OUT]
    ST --> SM[(stock_movements)]
    LSA --> B[Calculate Host Bonus]
```

1. Leader membuat jadwal live (host + platform + tanggal)
2. Setelah live selesai, input live sale dengan items
3. Sistem kurangi stok produk otomatis
4. Bonus host dihitung dari item yang terjual

---

## Marketplace Order Flow

```mermaid
flowchart TD
    A[Admin creates order] --> B[(marketplace_orders)]
    B --> C[(marketplace_order_items)]
    C --> D{Status delivered?}
    D -->|Yes| E[Stock OUT]
    D -->|No| F[No stock change]
    E --> SM[(stock_movements)]
    B --> G[Dashboard marketplace stats]
```

Admin/Leader memantau order dari 4 platform marketplace dengan filter status.

---

## Return Flow

```mermaid
flowchart TD
    R[Create Return] --> RT[(returns)]
    RT --> ST[Stock IN +quantity]
    ST --> SM[(stock_movements)]
    RT --> X[Exclude from bonus eligibility]
```

Return hanya untuk marketplace orders. Stok dikembalikan ke inventory.

---

## Bonus Calculation Flow

```mermaid
flowchart TD
    LS[live_sales status=completed] --> LSI[live_sale_items]
    LSI --> P[products]
    P --> C[categories]
    C --> BR[bonus_rules]
    BR --> CALC[quantity × bonus_amount]
    CALC --> HOST[Group by host_id]
```

### Formula Detail

```
IF category = 'Laptop'     THEN bonus = qty × 10.000
IF category = 'Chromebook' THEN bonus = qty ×  3.000

Total Host Bonus = Σ bonus per item (completed live sales only)
```

### Business Logic

| Condition | Bonus Eligible |
|-----------|----------------|
| Live sale completed | ✅ Yes |
| Order delivered (marketplace) | ❌ No (bonus hanya live) |
| Product returned | ❌ No (returns = marketplace) |

---

## Dashboard Data Flow

```mermaid
flowchart LR
    D[Dashboard Page] --> API[GET /api/dashboard/{role}]
    API --> Q1[Summary queries]
    API --> Q2[Chart queries]
    API --> Q3[Recent activities/orders]
    Q1 --> R[JSON response]
    Q2 --> R
    Q3 --> R
    R --> UI[StatCards + Recharts + Tables]
```

---

## Table Features Flow

Semua halaman list menggunakan komponen `DataTable`:

| Feature | Implementation |
|---------|----------------|
| Search | TextField → query param `search` |
| Filter | Select dropdown → query params |
| Pagination | MUI TablePagination → `page`, `limit` |
| Sort | TableSortLabel → `sortBy`, `sortOrder` |
| Export CSV | Client-side exportToCSV helper |

---

## Responsive Sidebar Flow

| Breakpoint | Behavior |
|------------|----------|
| Desktop (lg+) | Sidebar fixed 260px |
| Tablet (md-lg) | Sidebar collapsed 72px |
| Mobile (xs-md) | Drawer toggle via hamburger |

---

## Seed Data Summary

| Data | Count | Period |
|------|-------|--------|
| Users | 5 | - |
| Platforms | 4 | - |
| Categories | 2 | - |
| Products | 20 | - |
| Customers | 100 | - |
| Live Schedules | 360 | Feb-May 2026 |
| Live Sales | 360 | Feb-May 2026 |
| Marketplace Orders | 1050+ | Feb-May 2026 |
| Returns | 20 | Feb-May 2026 |
| Stock Movements | 70+ | Feb-May 2026 |
| Activity Logs | 200 | Feb-May 2026 |

Regenerate: `cd backend && npm run generate-sql`

---

## Security Flow

1. Password hashed with bcrypt (10 rounds)
2. JWT expires in 24h (configurable via `.env`)
3. Every protected route requires valid Bearer token
4. Role middleware enforces permission per endpoint
5. 401 response triggers auto logout di frontend

---

## Notification Flow

```
CRUD Action → API Success → toast.success('Product created successfully')
CRUD Error  → API Error   → toast.error(message)
Login       → toast.success('Login successful')
```

Using React Toastify with `position="top-right"`, `autoClose={3000}`.
