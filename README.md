# TECHNOVO - Online Sales Monitoring & Analytics System

Full-stack application untuk monitoring penjualan online (Live Shop & Marketplace) dengan dashboard analytics, role-based access, dan bonus host otomatis.

## Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | React 19, Vite, MUI, React Router, Axios, React Hook Form, Recharts, React Toastify |
| Backend | Node.js, Express.js, MySQL2, JWT, bcryptjs |
| Database | MySQL (XAMPP) |

## Prerequisites

- Node.js 18+
- XAMPP (MySQL + phpMyAdmin)
- npm

## Quick Start

### 1. Database Setup

1. Start **Apache** and **MySQL** di XAMPP
2. Buka phpMyAdmin → **Import**
3. Import file: `backend/src/sql/technovo_db.sql`
4. Database `technovo_db` akan terbuat otomatis beserta seed data

### 2. Backend Setup

```bash
cd backend
cp .env.example .env   # Windows: copy .env.example .env
npm install
npm run dev
```

Backend berjalan di: `http://localhost:5000`

### 3. Frontend Setup

```bash
cd frontend
npm install
npm run dev
```

Frontend berjalan di: `http://localhost:5173`

## Default Login

| Role | Email | Password |
|------|-------|----------|
| Leader | sarif@technovo.id | password123 |
| Admin | kiki@technovo.id | password123 |
| Host | fifi@technovo.id | password123 |
| Host | zalla@technovo.id | password123 |
| Host | nisa@technovo.id | password123 |

## Project Structure

```
technovo/
├── backend/
│   ├── src/
│   │   ├── config/db.js
│   │   ├── controllers/
│   │   ├── middleware/
│   │   ├── routes/
│   │   ├── services/
│   │   ├── utils/
│   │   ├── sql/technovo_db.sql
│   │   └── server.js
│   └── scripts/generate-sql.js
├── frontend/
│   └── src/
│       ├── components/
│       ├── layouts/
│       ├── pages/
│       ├── services/
│       ├── context/
│       └── routes/
├── README.md
├── PROJECT_DOCUMENTATION.md
└── SYSTEM_FLOW_EXPLANATION.md
```

## Regenerate SQL Seed Data

```bash
cd backend
npm run generate-sql
```

## API Health Check

```
GET http://localhost:5000/api/health
```

## Documentation

- [PROJECT_DOCUMENTATION.md](./PROJECT_DOCUMENTATION.md) — Arsitektur, database, API
- [SYSTEM_FLOW_EXPLANATION.md](./SYSTEM_FLOW_EXPLANATION.md) — Alur sistem & fitur detail
