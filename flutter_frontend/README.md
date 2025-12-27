# Personal Finance Tracker API

A Laravel-based REST API for personal finance tracking with user authentication and role-based access control.

## Features

- User registration and authentication via Laravel Sanctum
- Role-based access control (admin/user) using Spatie Laravel Permission
- Personal finance tracking with categories, transactions, budgets, and savings
- Comprehensive CRUD operations for all resources
- Validation and error handling
- Eloquent API resources for consistent JSON responses

## Requirements

- PHP 8.2+
- Laravel 12
- MySQL
- Composer

## Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   composer install
   ```
3. Create a `.env` file and configure your database settings
4. Run migrations:
   ```bash
   php artisan migrate
   ```
5. Seed the database:
   ```bash
   php artisan db:seed
   ```
6. Generate application key:
   ```bash
   php artisan key:generate
   ```

## API Endpoints

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/register` | Register a new user |
| POST | `/api/login` | Authenticate and get token |
| POST | `/api/logout` | Revoke current token |
| GET | `/api/profile` | Get current user profile |

### Categories

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/categories` | Get user's categories (paginated) |
| POST | `/api/categories` | Create new category |
| GET | `/api/categories/{id}` | Get specific category |
| PUT | `/api/categories/{id}` | Update specific category |
| DELETE | `/api/categories/{id}` | Delete specific category |

### Transactions

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/transactions` | Get user's transactions (paginated) |
| POST | `/api/transactions` | Create new transaction |
| GET | `/api/transactions/{id}` | Get specific transaction |
| PUT | `/api/transactions/{id}` | Update specific transaction |
| DELETE | `/api/transactions/{id}` | Delete specific transaction |

### Budgets

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/budgets` | Get user's budgets (paginated) |
| POST | `/api/budgets` | Create new budget |
| GET | `/api/budgets/{id}` | Get specific budget |
| PUT | `/api/budgets/{id}` | Update specific budget |
| DELETE | `/api/budgets/{id}` | Delete specific budget |

### Savings

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/savings` | Get user's savings (paginated) |
| POST | `/api/savings` | Create new saving |
| GET | `/api/savings/{id}` | Get specific saving |
| PUT | `/api/savings/{id}` | Update specific saving |
| DELETE | `/api/savings/{id}` | Delete specific saving |

### Admin Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/admin/transactions` | Get all transactions (admin only) |
| GET | `/api/admin/categories` | Get all categories (admin only) |
| GET | `/api/admin/budgets` | Get all budgets (admin only) |
| GET | `/api/admin/savings` | Get all savings (admin only) |
| GET | `/api/admin/users` | Get all users (admin only) |

## Default Admin Account

- Email: `admin@example.com`
- Password: `12345678`

## Response Format

### Success Response
```json
{
  "success": true,
  "data": { /* resource data */ },
  "message": "Operation successful message"
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error message",
  "data": { /* validation errors or additional info */ }
}
```

## Usage Examples

### Register a new user
```bash
curl -X POST https://note-grill-spencer-non.trycloudflare.com/api/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }'
```

### Login
```bash
curl -X POST https://note-grill-spencer-non.trycloudflare.com/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

### Create a category (with authentication token)
```bash
curl -X POST https://note-grill-spencer-non.trycloudflare.com/api/categories \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "name": "Salary",
    "type": "income"
  }'
```

## Database Schema

### users
- id (BIGINT UNSIGNED, PK)
- name (VARCHAR 100)
- email (VARCHAR 100, unique)
- password (VARCHAR 255)
- created_at, updated_at

### categories
- id (BIGINT UNSIGNED, PK)
- user_id (FK to users.id)
- name (VARCHAR 100)
- type (ENUM('income','expense'))
- created_at, updated_at

### transactions
- id (BIGINT UNSIGNED, PK)
- user_id (FK to users.id)
- category_id (FK to categories.id)
- amount (DECIMAL(12,2))
- type (ENUM('income','expense'))
- description (TEXT)
- date (DATE)
- created_at, updated_at

### budgets
- id (BIGINT UNSIGNED, PK)
- user_id (FK to users.id)
- category_id (FK to categories.id)
- amount (DECIMAL(12,2))
- month (VARCHAR(7), format YYYY-MM)
- created_at, updated_at

### savings
- id (BIGINT UNSIGNED, PK)
- user_id (FK to users.id)
- goal_name (VARCHAR 100)
- target_amount (DECIMAL(12,2))
- current_amount (DECIMAL(12,2))
- deadline (DATE)
- created_at, updated_at