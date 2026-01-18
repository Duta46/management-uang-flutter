# Postman API Documentation - Personal Finance Tracker

## Table of Contents
1. [Getting Started](#getting-started)
2. [Authentication](#authentication)
3. [User Profile](#user-profile)
4. [Categories](#categories)
5. [Transactions](#transactions)
6. [Budgets](#budgets)
7. [Savings Goals](#savings-goals)
8. [Bill Reminders](#bill-reminders)
9. [Reports](#reports)
10. [Dashboard](#dashboard)
11. [Financial Analytics](#financial-analytics)
12. [Financial Chatbot](#financial-chatbot)

## Getting Started

### Base URL
```
https://serial-basketball-humanitarian-flip.trycloudflare.com/api
```

### Headers
For protected endpoints, include the following header:
```
Authorization: Bearer {your_access_token}
Content-Type: application/json
```

---

## Authentication

### Register
**Endpoint:** `POST /api/auth/register`

**Description:** Register a new user account

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}
```

**Request Fields:**
- `name` (required): User's full name (max 255 characters)
- `email` (required): Valid email address (unique)
- `password` (required): Minimum 8 characters, must match confirmation
- `password_confirmation` (required): Must match password

**Success Response:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "email_verified_at": null,
      "created_at": "2025-11-12T14:30:00.000000Z",
      "updated_at": "2025-11-12T14:30:00.000000Z"
    },
    "token": "1|abc123def456..."
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Validation Error.",
  "data": {
    "email": [
      "The email has already been taken."
    ],
    "password": [
      "The password confirmation does not match."
    ]
  }
}
```

### Login
**Endpoint:** `POST /api/auth/login`

**Description:** Authenticate user and receive access token

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Request Fields:**
- `email` (required): Valid email address
- `password` (required): User's password

**Success Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "email_verified_at": null,
      "created_at": "2025-11-12T14:30:00.000000Z",
      "updated_at": "2025-11-12T14:30:00.000000Z"
    },
    "token": "1|abc123def456..."
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Invalid login credentials"
}
```

### Logout
**Endpoint:** `POST /api/auth/logout`

**Description:** Log out the authenticated user and invalidate the token

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

## User Profile

### Get Profile
**Endpoint:** `GET /api/auth/profile`

**Description:** Retrieve the authenticated user's profile information

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Profile retrieved successfully",
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "email_verified_at": null,
    "created_at": "2025-11-12T14:30:00.000000Z",
    "updated_at": "2025-11-12T14:30:00.000000Z"
  }
}
```

### Update Profile
**Endpoint:** `PUT /api/auth/profile`

**Description:** Update the authenticated user's profile information

**Headers:**
```
Authorization: Bearer {your_access_token}
Content-Type: multipart/form-data  // If updating profile photo
```
or
```
Authorization: Bearer {your_access_token}
Content-Type: application/json    // If not updating profile photo
```

**Request Body (JSON):**
```json
{
  "name": "John Smith",
  "email": "johnsmith@example.com"
}
```

**Request Fields:**
- `name` (optional): Updated name (max 255 characters)
- `email` (optional): Updated email (must be unique)
- `profile_photo` (optional): Image file (jpeg, png, jpg, gif, max 2MB)

**Success Response:**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "id": 1,
    "name": "John Smith",
    "email": "johnsmith@example.com",
    "email_verified_at": null,
    "created_at": "2025-11-12T14:30:00.000000Z",
    "updated_at": "2025-11-12T15:00:00.000000Z",
    "profile_photo": "profile-photos/1636723800_1.jpg"
  }
}
```

---

## Categories

### Get All Categories
**Endpoint:** `GET /api/categories`

**Description:** Retrieve all categories for the authenticated user

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Query Parameters:**
- `page` (optional): Page number for pagination
- `per_page` (optional): Number of items per page

**Success Response:**
```json
{
  "success": true,
  "message": "Categories retrieved successfully",
  "data": {
    "data": [
      {
        "id": 1,
        "user_id": 1,
        "name": "Salary",
        "type": "income",
        "created_at": "2025-11-12T14:30:00.000000Z",
        "updated_at": "2025-11-12T14:30:00.000000Z"
      }
    ],
    "links": {
      "first": "http://localhost:8000/api/categories?page=1",
      "last": "http://localhost:8000/api/categories?page=1",
      "prev": null,
      "next": null
    },
    "meta": {
      "current_page": 1,
      "from": 1,
      "last_page": 1,
      "path": "http://localhost:8000/api/categories",
      "per_page": 10,
      "to": 1,
      "total": 1
    }
  }
}
```

### Create Category
**Endpoint:** `POST /api/categories`

**Description:** Create a new category

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Request Body:**
```json
{
  "name": "Groceries"
}
```

**Request Fields:**
- `name` (required): Category name (max 255 characters)

**Success Response:**
```json
{
  "success": true,
  "message": "Category created successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "name": "Groceries",
    "type": "expense",
    "created_at": "2025-11-12T14:30:00.000000Z",
    "updated_at": "2025-11-12T14:30:00.000000Z"
  }
}
```

### Get Single Category
**Endpoint:** `GET /api/categories/{id}`

**Description:** Retrieve a specific category

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Parameters:**
- `id` (required): Category ID

**Success Response:**
```json
{
  "success": true,
  "message": "Category retrieved successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "name": "Groceries",
    "type": "expense",
    "created_at": "2025-11-12T14:30:00.000000Z",
    "updated_at": "2025-11-12T14:30:00.000000Z"
  }
}
```

### Update Category
**Endpoint:** `PUT /api/categories/{id}`

**Description:** Update an existing category

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Parameters:**
- `id` (required): Category ID

**Request Body:**
```json
{
  "name": "Updated Groceries",
  "type": "expense"
}
```

**Request Fields:**
- `name` (optional): Updated category name (max 255 characters)
- `type` (optional): Either "income" or "expense"

**Success Response:**
```json
{
  "success": true,
  "message": "Category updated successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "name": "Updated Groceries",
    "type": "expense",
    "created_at": "2025-11-12T14:30:00.000000Z",
    "updated_at": "2025-11-12T15:00:00.000000Z"
  }
}
```

### Delete Category
**Endpoint:** `DELETE /api/categories/{id}`

**Description:** Delete a category

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Parameters:**
- `id` (required): Category ID

**Success Response:**
```json
{
  "success": true,
  "message": "Category deleted successfully"
}
```

---

## Transactions

### Get All Transactions
**Endpoint:** `GET /api/transactions`

**Description:** Retrieve all transactions for the authenticated user

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Query Parameters:**
- `page` (optional): Page number for pagination
- `per_page` (optional): Number of items per page
- `category_id` (optional): Filter by category ID
- `type` (optional): Filter by transaction type ("income" or "expense")
- `date_from` (optional): Filter from date (YYYY-MM-DD)
- `date_to` (optional): Filter to date (YYYY-MM-DD)

**Success Response:**
```json
{
  "success": true,
  "message": "Transactions retrieved successfully",
  "data": {
    "data": [
      {
        "id": 1,
        "user_id": 1,
        "category_id": 1,
        "amount": "50.00",
        "type": "expense",
        "description": "Bought groceries",
        "date": "2025-11-12",
        "created_at": "2025-11-12T14:30:00.000000Z",
        "updated_at": "2025-11-12T14:30:00.000000Z",
        "category": {
          "id": 1,
          "name": "Groceries",
          "type": "expense"
        }
      }
    ],
    "links": {
      "first": "http://localhost:8000/api/transactions?page=1",
      "last": "http://localhost:8000/api/transactions?page=1",
      "prev": null,
      "next": null
    },
    "meta": {
      "current_page": 1,
      "from": 1,
      "last_page": 1,
      "path": "http://localhost:8000/api/transactions",
      "per_page": 10,
      "to": 1,
      "total": 1
    }
  }
}
```

### Create Transaction
**Endpoint:** `POST /api/transactions`

**Description:** Create a new transaction

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Request Body:**
```json
{
  "category_id": 1,
  "amount": 50.00,
  "type": "expense",
  "description": "Bought groceries",
  "date": "2025-11-12"
}
```

**Request Fields:**
- `category_id` (required): ID of the category
- `amount` (required): Transaction amount (numeric)
- `type` (required): Either "income" or "expense"
- `description` (optional): Description of the transaction (max 255 characters)
- `date` (required): Date of the transaction (YYYY-MM-DD format)

**Success Response:**
```json
{
  "success": true,
  "message": "Transaction created successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "category_id": 1,
    "amount": "50.00",
    "type": "expense",
    "description": "Bought groceries",
    "date": "2025-11-12",
    "created_at": "2025-11-12T14:30:00.000000Z",
    "updated_at": "2025-11-12T14:30:00.000000Z",
    "category": {
      "id": 1,
      "name": "Groceries",
      "type": "expense"
    }
  }
}
```

### Get Single Transaction
**Endpoint:** `GET /api/transactions/{id}`

**Description:** Retrieve a specific transaction

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Parameters:**
- `id` (required): Transaction ID

**Success Response:**
```json
{
  "success": true,
  "message": "Transaction retrieved successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "category_id": 1,
    "amount": "50.00",
    "type": "expense",
    "description": "Bought groceries",
    "date": "2025-11-12",
    "created_at": "2025-11-12T14:30:00.000000Z",
    "updated_at": "2025-11-12T14:30:00.000000Z",
    "category": {
      "id": 1,
      "name": "Groceries",
      "type": "expense"
    }
  }
}
```

### Update Transaction
**Endpoint:** `PUT /api/transactions/{id}`

**Description:** Update an existing transaction

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Parameters:**
- `id` (required): Transaction ID

**Request Body:**
```json
{
  "category_id": 2,
  "amount": 75.00,
  "type": "expense",
  "description": "Updated groceries purchase",
  "date": "2025-11-13"
}
```

**Request Fields:**
- `category_id` (optional): Updated category ID
- `amount` (optional): Updated transaction amount
- `type` (optional): Either "income" or "expense"
- `description` (optional): Updated description
- `date` (optional): Updated date (YYYY-MM-DD format)

**Success Response:**
```json
{
  "success": true,
  "message": "Transaction updated successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "category_id": 2,
    "amount": "75.00",
    "type": "expense",
    "description": "Updated groceries purchase",
    "date": "2025-11-13",
    "created_at": "2025-11-12T14:30:00.000000Z",
    "updated_at": "2025-11-13T10:00:00.000000Z",
    "category": {
      "id": 2,
      "name": "Utilities",
      "type": "expense"
    }
  }
}
```

### Delete Transaction
**Endpoint:** `DELETE /api/transactions/{id}`

**Description:** Delete a transaction

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Parameters:**
- `id` (required): Transaction ID

**Success Response:**
```json
{
  "success": true,
  "message": "Transaction deleted successfully"
}
```

---

## Budgets

### Get All Budgets
**Endpoint:** `GET /api/budgets`

**Description:** Retrieve all budgets for the authenticated user

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Query Parameters:**
- `page` (optional): Page number for pagination
- `per_page` (optional): Number of items per page

**Success Response:**
```json
{
  "success": true,
  "message": "Budgets retrieved successfully",
  "data": {
    "data": [
      {
        "id": 1,
        "user_id": 1,
        "category_id": 1,
        "amount": "200.00",
        "month": "2025-11",
        "created_at": "2025-11-12T14:30:00.000000Z",
        "updated_at": "2025-11-12T14:30:00.000000Z",
        "category": {
          "id": 1,
          "name": "Groceries",
          "type": "expense"
        }
      }
    ],
    "links": {
      "first": "http://localhost:8000/api/budgets?page=1",
      "last": "http://localhost:8000/api/budgets?page=1",
      "prev": null,
      "next": null
    },
    "meta": {
      "current_page": 1,
      "from": 1,
      "last_page": 1,
      "path": "http://localhost:8000/api/budgets",
      "per_page": 10,
      "to": 1,
      "total": 1
    }
  }
}
```

### Create Budget
**Endpoint:** `POST /api/budgets`

**Description:** Create a new budget

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Request Body:**
```json
{
  "category_id": 1,
  "amount": 200.00,
  "month": "2025-11"
}
```

**Request Fields:**
- `category_id` (required): ID of the category
- `amount` (required): Budget amount (numeric)
- `month` (required): Month in YYYY-MM format (e.g., "2025-11")

**Success Response:**
```json
{
  "success": true,
  "message": "Budget created successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "category_id": 1,
    "amount": "200.00",
    "month": "2025-11",
    "created_at": "2025-11-12T14:30:00.000000Z",
    "updated_at": "2025-11-12T14:30:00.000000Z",
    "category": {
      "id": 1,
      "name": "Groceries",
      "type": "expense"
    }
  }
}
```

### Get Single Budget
**Endpoint:** `GET /api/budgets/{id}`

**Description:** Retrieve a specific budget

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Parameters:**
- `id` (required): Budget ID

**Success Response:**
```json
{
  "success": true,
  "message": "Budget retrieved successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "category_id": 1,
    "amount": "200.00",
    "month": "2025-11",
    "created_at": "2025-11-12T14:30:00.000000Z",
    "updated_at": "2025-11-12T14:30:00.000000Z",
    "category": {
      "id": 1,
      "name": "Groceries",
      "type": "expense"
    }
  }
}
```

### Update Budget
**Endpoint:** `PUT /api/budgets/{id}`

**Description:** Update an existing budget

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Parameters:**
- `id` (required): Budget ID

**Request Body:**
```json
{
  "category_id": 2,
  "amount": 250.00,
  "month": "2025-12"
}
```

**Request Fields:**
- `category_id` (optional): Updated category ID
- `amount` (optional): Updated budget amount
- `month` (optional): Updated month in YYYY-MM format

**Success Response:**
```json
{
  "success": true,
  "message": "Budget updated successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "category_id": 2,
    "amount": "250.00",
    "month": "2025-12",
    "created_at": "2025-11-12T14:30:00.000000Z",
    "updated_at": "2025-11-13T10:00:00.000000Z",
    "category": {
      "id": 2,
      "name": "Utilities",
      "type": "expense"
    }
  }
}
```

### Delete Budget
**Endpoint:** `DELETE /api/budgets/{id}`

**Description:** Delete a budget

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Parameters:**
- `id` (required): Budget ID

**Success Response:**
```json
{
  "success": true,
  "message": "Budget deleted successfully"
}
```

### Get Budgets with Status
**Endpoint:** `GET /api/budgets-with-status`

**Description:** Retrieve all budgets with their spending status

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Budgets with status retrieved successfully",
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "category_id": 1,
      "amount": "200.00",
      "month": "2025-11",
      "spent": "150.00",
      "remaining": "50.00",
      "percentage_used": 75.00,
      "status": "under_budget",
      "created_at": "2025-11-12T14:30:00.000000Z",
      "updated_at": "2025-11-12T14:30:00.000000Z",
      "category": {
        "id": 1,
        "name": "Groceries",
        "type": "expense"
      }
    }
  ]
}
```

---

## Savings Goals

### Get All Savings Goals
**Endpoint:** `GET /api/savings-goals`

**Description:** Retrieve all savings goals for the authenticated user

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Query Parameters:**
- `page` (optional): Page number for pagination
- `per_page` (optional): Number of items per page

**Success Response:**
```json
{
  "success": true,
  "message": "Savings goals retrieved successfully",
  "data": {
    "data": [
      {
        "id": 1,
        "user_id": 1,
        "goal_name": "Emergency Fund",
        "target_amount": "1000.00",
        "current_amount": "450.00",
        "deadline": "2026-01-01",
        "created_at": "2025-11-12T14:30:00.000000Z",
        "updated_at": "2025-11-12T14:30:00.000000Z",
        "progress_percentage": 45.00
      }
    ],
    "links": {
      "first": "http://localhost:8000/api/savings-goals?page=1",
      "last": "http://localhost:8000/api/savings-goals?page=1",
      "prev": null,
      "next": null
    },
    "meta": {
      "current_page": 1,
      "from": 1,
      "last_page": 1,
      "path": "http://localhost:8000/api/savings-goals",
      "per_page": 10,
      "to": 1,
      "total": 1
    }
  }
}
```

### Create Savings Goal
**Endpoint:** `POST /api/savings-goals`

**Description:** Create a new savings goal

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Request Body:**
```json
{
  "goal_name": "Vacation Fund",
  "target_amount": 2000.00,
  "current_amount": 500.00,
  "deadline": "2026-06-01"
}
```

**Request Fields:**
- `goal_name` (required): Name of the savings goal (max 255 characters)
- `target_amount` (required): Target amount to save (numeric)
- `current_amount` (required): Current amount saved (numeric, <= target_amount)
- `deadline` (required): Deadline date (YYYY-MM-DD format)

**Success Response:**
```json
{
  "success": true,
  "message": "Savings goal created successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "goal_name": "Vacation Fund",
    "target_amount": "2000.00",
    "current_amount": "500.00",
    "deadline": "2026-06-01",
    "created_at": "2025-11-12T14:30:00.000000Z",
    "updated_at": "2025-11-12T14:30:00.000000Z",
    "progress_percentage": 25.00
  }
}
```

### Get Single Savings Goal
**Endpoint:** `GET /api/savings-goals/{id}`

**Description:** Retrieve a specific savings goal

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Parameters:**
- `id` (required): Savings goal ID

**Success Response:**
```json
{
  "success": true,
  "message": "Savings goal retrieved successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "goal_name": "Vacation Fund",
    "target_amount": "2000.00",
    "current_amount": "500.00",
    "deadline": "2026-06-01",
    "created_at": "2025-11-12T14:30:00.000000Z",
    "updated_at": "2025-11-12T14:30:00.000000Z",
    "progress_percentage": 25.00
  }
}
```

### Update Savings Goal
**Endpoint:** `PUT /api/savings-goals/{id}`

**Description:** Update an existing savings goal

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Parameters:**
- `id` (required): Savings goal ID

**Request Body:**
```json
{
  "goal_name": "Updated Vacation Fund",
  "target_amount": 2500.00,
  "current_amount": 600.00,
  "deadline": "2026-07-01"
}
```

**Request Fields:**
- `goal_name` (optional): Updated name of the savings goal
- `target_amount` (optional): Updated target amount
- `current_amount` (optional): Updated current amount saved
- `deadline` (optional): Updated deadline date

**Success Response:**
```json
{
  "success": true,
  "message": "Savings goal updated successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "goal_name": "Updated Vacation Fund",
    "target_amount": "2500.00",
    "current_amount": "600.00",
    "deadline": "2026-07-01",
    "created_at": "2025-11-12T14:30:00.000000Z",
    "updated_at": "2025-11-13T10:00:00.000000Z",
    "progress_percentage": 24.00
  }
}
```

### Delete Savings Goal
**Endpoint:** `DELETE /api/savings-goals/{id}`

**Description:** Delete a savings goal

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Parameters:**
- `id` (required): Savings goal ID

**Success Response:**
```json
{
  "success": true,
  "message": "Savings goal deleted successfully"
}
```

### Get Savings Goals with Status
**Endpoint:** `GET /api/savings-goals-with-status`

**Description:** Retrieve all savings goals with their status

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Savings goals with status retrieved successfully",
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "goal_name": "Vacation Fund",
      "target_amount": "2000.00",
      "current_amount": "500.00",
      "deadline": "2026-06-01",
      "created_at": "2025-11-12T14:30:00.000000Z",
      "updated_at": "2025-11-12T14:30:00.000000Z",
      "progress_percentage": 25.00,
      "status": "on_track"
    }
  ]
}
```

### Get Active Savings Goals
**Endpoint:** `GET /api/savings-goals-active`

**Description:** Retrieve all active savings goals

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Active savings goals retrieved successfully",
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "goal_name": "Vacation Fund",
      "target_amount": "2000.00",
      "current_amount": "500.00",
      "deadline": "2026-06-01",
      "created_at": "2025-11-12T14:30:00.000000Z",
      "updated_at": "2025-11-12T14:30:00.000000Z",
      "progress_percentage": 25.00
    }
  ]
}
```

---

## Bill Reminders

### Get All Bill Reminders
**Endpoint:** `GET /api/bill-reminders`

**Description:** Retrieve all bill reminders for the authenticated user

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Query Parameters:**
- `page` (optional): Page number for pagination
- `per_page` (optional): Number of items per page

**Success Response:**
```json
{
  "success": true,
  "message": "Bill reminders retrieved successfully",
  "data": {
    "data": [
      {
        "id": 1,
        "user_id": 1,
        "name": "Electricity Bill",
        "description": "Monthly electricity payment",
        "amount": "150.00",
        "due_date": "2025-12-15",
        "frequency": "monthly",
        "is_paid": false,
        "is_active": true,
        "created_at": "2025-11-12T14:30:00.000000Z",
        "updated_at": "2025-11-12T14:30:00.000000Z"
      }
    ],
    "links": {
      "first": "http://localhost:8000/api/bill-reminders?page=1",
      "last": "http://localhost:8000/api/bill-reminders?page=1",
      "prev": null,
      "next": null
    },
    "meta": {
      "current_page": 1,
      "from": 1,
      "last_page": 1,
      "path": "http://localhost:8000/api/bill-reminders",
      "per_page": 10,
      "to": 1,
      "total": 1
    }
  }
}
```

### Create Bill Reminder
**Endpoint:** `POST /api/bill-reminders`

**Description:** Create a new bill reminder

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Request Body:**
```json
{
  "name": "Internet Bill",
  "description": "Monthly internet subscription",
  "amount": 80.00,
  "due_date": "2025-12-20",
  "frequency": "monthly",
  "is_active": true
}
```

**Request Fields:**
- `name` (required): Name of the bill (max 255 characters)
- `description` (optional): Description of the bill (max 255 characters)
- `amount` (required): Bill amount (numeric)
- `due_date` (required): Due date (YYYY-MM-DD format)
- `frequency` (required): Frequency of the bill ("one_time", "weekly", "monthly", "yearly")
- `is_active` (optional): Whether the reminder is active (true/false, default: true)

**Success Response:**
```json
{
  "success": true,
  "message": "Bill reminder created successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "name": "Internet Bill",
    "description": "Monthly internet subscription",
    "amount": "80.00",
    "due_date": "2025-12-20",
    "frequency": "monthly",
    "is_paid": false,
    "is_active": true,
    "created_at": "2025-11-12T14:30:00.000000Z",
    "updated_at": "2025-11-12T14:30:00.000000Z"
  }
}
```

### Get Single Bill Reminder
**Endpoint:** `GET /api/bill-reminders/{id}`

**Description:** Retrieve a specific bill reminder

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Parameters:**
- `id` (required): Bill reminder ID

**Success Response:**
```json
{
  "success": true,
  "message": "Bill reminder retrieved successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "name": "Internet Bill",
    "description": "Monthly internet subscription",
    "amount": "80.00",
    "due_date": "2025-12-20",
    "frequency": "monthly",
    "is_paid": false,
    "is_active": true,
    "created_at": "2025-11-12T14:30:00.000000Z",
    "updated_at": "2025-11-12T14:30:00.000000Z"
  }
}
```

### Update Bill Reminder
**Endpoint:** `PUT /api/bill-reminders/{id}`

**Description:** Update an existing bill reminder

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Parameters:**
- `id` (required): Bill reminder ID

**Request Body:**
```json
{
  "name": "Updated Internet Bill",
  "description": "Annual internet subscription",
  "amount": 960.00,
  "due_date": "2026-01-20",
  "frequency": "yearly",
  "is_paid": false,
  "is_active": true
}
```

**Request Fields:**
- `name` (optional): Updated name of the bill
- `description` (optional): Updated description of the bill
- `amount` (optional): Updated bill amount
- `due_date` (optional): Updated due date
- `frequency` (optional): Updated frequency
- `is_paid` (optional): Payment status (true/false)
- `is_active` (optional): Active status (true/false)

**Success Response:**
```json
{
  "success": true,
  "message": "Bill reminder updated successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "name": "Updated Internet Bill",
    "description": "Annual internet subscription",
    "amount": "960.00",
    "due_date": "2026-01-20",
    "frequency": "yearly",
    "is_paid": false,
    "is_active": true,
    "created_at": "2025-11-12T14:30:00.000000Z",
    "updated_at": "2025-11-13T10:00:00.000000Z"
  }
}
```

### Delete Bill Reminder
**Endpoint:** `DELETE /api/bill-reminders/{id}`

**Description:** Delete a bill reminder

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Parameters:**
- `id` (required): Bill reminder ID

**Success Response:**
```json
{
  "success": true,
  "message": "Bill reminder deleted successfully"
}
```

### Get Bill Reminders with Status
**Endpoint:** `GET /api/bill-reminders-with-status`

**Description:** Retrieve all bill reminders with their status

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Bill reminders with status retrieved successfully",
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "name": "Internet Bill",
      "description": "Monthly internet subscription",
      "amount": "80.00",
      "due_date": "2025-12-20",
      "frequency": "monthly",
      "is_paid": false,
      "is_active": true,
      "status": "overdue",
      "days_until_due": -5,
      "created_at": "2025-11-12T14:30:00.000000Z",
      "updated_at": "2025-11-12T14:30:00.000000Z"
    }
  ]
}
```

### Check and Renew Due Bills
**Endpoint:** `POST /api/bill-reminders/check-and-renew`

**Description:** Check for due bills and renew recurring ones

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Due bills checked and renewed successfully",
  "data": {
    "renewed_bills": [
      {
        "id": 1,
        "name": "Internet Bill",
        "next_due_date": "2026-01-20"
      }
    ],
    "overdue_bills": [
      {
        "id": 2,
        "name": "Electricity Bill",
        "due_date": "2025-12-15"
      }
    ]
  }
}
```

---

## Reports

### Daily Report
**Endpoint:** `GET /api/reports/daily`

**Description:** Get daily financial report

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Query Parameters:**
- `date` (optional): Specific date (YYYY-MM-DD format, default: today)

**Success Response:**
```json
{
  "success": true,
  "message": "Daily report retrieved successfully",
  "data": {
    "date": "2025-11-12",
    "total_income": "500.00",
    "total_expense": "250.00",
    "net_balance": "250.00",
    "transactions": [
      {
        "id": 1,
        "category_id": 1,
        "amount": "200.00",
        "type": "income",
        "description": "Salary",
        "date": "2025-11-12"
      },
      {
        "id": 2,
        "category_id": 2,
        "amount": "150.00",
        "type": "expense",
        "description": "Groceries",
        "date": "2025-11-12"
      }
    ]
  }
}
```

### Monthly Report
**Endpoint:** `GET /api/reports/monthly`

**Description:** Get monthly financial report

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Query Parameters:**
- `month` (optional): Specific month (YYYY-MM format, default: current month)

**Success Response:**
```json
{
  "success": true,
  "message": "Monthly report retrieved successfully",
  "data": {
    "month": "2025-11",
    "total_income": "2000.00",
    "total_expense": "1200.00",
    "net_balance": "800.00",
    "income_by_category": [
      {
        "category": "Salary",
        "amount": "2000.00"
      }
    ],
    "expense_by_category": [
      {
        "category": "Groceries",
        "amount": "500.00"
      },
      {
        "category": "Utilities",
        "amount": "300.00"
      }
    ],
    "budget_utilization": [
      {
        "category": "Groceries",
        "budgeted": "600.00",
        "spent": "500.00",
        "utilization": "83.33%"
      }
    ]
  }
}
```

---

## Dashboard

### Dashboard Summary
**Endpoint:** `GET /api/dashboard/summary`

**Description:** Get dashboard summary data

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Dashboard summary retrieved successfully",
  "data": {
    "total_balance": "1500.00",
    "total_income_month": "2000.00",
    "total_expense_month": "1200.00",
    "net_balance_month": "800.00",
    "recent_transactions": [
      {
        "id": 1,
        "category_id": 1,
        "amount": "200.00",
        "type": "income",
        "description": "Salary",
        "date": "2025-11-12"
      }
    ],
    "upcoming_bills": [
      {
        "id": 1,
        "name": "Electricity Bill",
        "amount": "150.00",
        "due_date": "2025-11-15"
      }
    ],
    "active_savings_goals": [
      {
        "id": 1,
        "goal_name": "Emergency Fund",
        "target_amount": "1000.00",
        "current_amount": "450.00",
        "progress_percentage": 45.00
      }
    ]
  }
}
```

### Dashboard Chart Data
**Endpoint:** `GET /api/dashboard/chart`

**Description:** Get chart data for dashboard visualization

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Dashboard chart data retrieved successfully",
  "data": {
    "income_expense_chart": {
      "labels": ["Week 1", "Week 2", "Week 3", "Week 4"],
      "income_data": [500, 600, 450, 450],
      "expense_data": [300, 400, 250, 250]
    },
    "expense_by_category_chart": {
      "labels": ["Groceries", "Utilities", "Entertainment"],
      "data": [500, 300, 200]
    },
    "budget_utilization_chart": {
      "labels": ["Groceries", "Utilities", "Transportation"],
      "data": [83.33, 100.00, 60.00]
    }
  }
}
```

---

## Financial Analytics

### Get Insights
**Endpoint:** `GET /api/financial-analytics/insights`

**Description:** Get financial insights and recommendations

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Financial insights retrieved successfully",
  "data": [
    {
      "id": 1,
      "title": "High Expense Alert",
      "content": "Your grocery expenses are 30% higher than usual this month.",
      "type": "alert",
      "is_read": false,
      "created_at": "2025-11-12T14:30:00.000000Z"
    }
  ]
}
```

### Get Unread Insights
**Endpoint:** `GET /api/financial-analytics/unread-insights`

**Description:** Get unread financial insights

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Unread financial insights retrieved successfully",
  "data": [
    {
      "id": 1,
      "title": "High Expense Alert",
      "content": "Your grocery expenses are 30% higher than usual this month.",
      "type": "alert",
      "created_at": "2025-11-12T14:30:00.000000Z"
    }
  ]
}
```

### Mark Insight as Read
**Endpoint:** `PUT /api/financial-analytics/insights/{id}/mark-read`

**Description:** Mark a financial insight as read

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Parameters:**
- `id` (required): Insight ID

**Success Response:**
```json
{
  "success": true,
  "message": "Insight marked as read successfully"
}
```

### Get Budget Recommendations
**Endpoint:** `GET /api/financial-analytics/budget-recommendations`

**Description:** Get budget recommendations based on spending patterns

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Budget recommendations retrieved successfully",
  "data": [
    {
      "category": "Groceries",
      "current_budget": "600.00",
      "recommended_budget": "500.00",
      "suggested_savings": "100.00",
      "rationale": "Based on your spending history, you can reduce grocery expenses by 100 per month."
    }
  ]
}
```

### Get Financial Recommendations
**Endpoint:** `GET /api/financial-analytics/recommendations`

**Description:** Get general financial recommendations

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Financial recommendations retrieved successfully",
  "data": [
    {
      "id": 1,
      "title": "Increase Emergency Fund",
      "content": "Consider increasing your emergency fund to cover 6 months of expenses.",
      "type": "savings",
      "is_applied": false,
      "created_at": "2025-11-12T14:30:00.000000Z"
    }
  ]
}
```

### Mark Recommendation as Applied
**Endpoint:** `PUT /api/financial-analytics/recommendations/{id}/mark-applied`

**Description:** Mark a financial recommendation as applied

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Parameters:**
- `id` (required): Recommendation ID

**Success Response:**
```json
{
  "success": true,
  "message": "Recommendation marked as applied successfully"
}
```

### Get Predictions
**Endpoint:** `GET /api/financial-analytics/predictions`

**Description:** Get financial predictions based on historical data

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Financial predictions retrieved successfully",
  "data": {
    "predicted_expenses_next_month": "1300.00",
    "predicted_income_next_month": "2100.00",
    "predicted_net_balance_next_month": "800.00",
    "trend_analysis": {
      "expense_trend": "increasing",
      "income_trend": "stable",
      "risk_level": "medium"
    }
  }
}
```

### Get Financial Health Score
**Endpoint:** `GET /api/financial-analytics/health-score`

**Description:** Get overall financial health score

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Financial health score retrieved successfully",
  "data": {
    "score": 75,
    "grade": "B+",
    "breakdown": {
      "savings_rate": 25,
      "debt_to_income": 10,
      "budget_adherence": 85,
      "expense_diversification": 70
    },
    "recommendations": [
      "Increase your savings rate to 30%",
      "Maintain good budget adherence"
    ]
  }
}
```

### Get Comprehensive Analysis
**Endpoint:** `GET /api/financial-analytics/comprehensive-analysis`

**Description:** Get comprehensive financial analysis

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Comprehensive financial analysis retrieved successfully",
  "data": {
    "health_score": 75,
    "spending_patterns": {
      "highest_spending_category": "Groceries",
      "seasonal_spending_trends": "Higher spending in December"
    },
    "budget_performance": {
      "overall_adherence": "85%",
      "categories_over_budget": ["Dining Out"]
    },
    "savings_progress": {
      "goals_on_track": 2,
      "goals_behind_schedule": 1
    },
    "investment_opportunities": [
      "Consider investing excess funds in low-risk instruments"
    ],
    "action_items": [
      "Reduce dining out expenses by 20%",
      "Review subscriptions for unnecessary costs"
    ]
  }
}
```

---

## Financial Chatbot

### Ask Question
**Endpoint:** `POST /api/chatbot/ask`

**Description:** Ask a financial question to the chatbot

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Request Body:**
```json
{
  "question": "How can I improve my savings rate?"
}
```

**Request Fields:**
- `question` (required): The financial question to ask

**Success Response:**
```json
{
  "success": true,
  "message": "Question answered successfully",
  "data": {
    "question": "How can I improve my savings rate?",
    "answer": "To improve your savings rate, consider reducing discretionary expenses like dining out and entertainment. Also, review your subscriptions to eliminate unused services. Based on your income, aim to save at least 20% monthly.",
    "timestamp": "2025-11-12T14:30:00.000000Z"
  }
}
```

### Get History
**Endpoint:** `GET /api/chatbot/history`

**Description:** Get chatbot conversation history

**Headers:**
```
Authorization: Bearer {your_access_token}
```

**Query Parameters:**
- `page` (optional): Page number for pagination
- `per_page` (optional): Number of items per page

**Success Response:**
```json
{
  "success": true,
  "message": "Chat history retrieved successfully",
  "data": {
    "data": [
      {
        "id": 1,
        "question": "How can I improve my savings rate?",
        "answer": "To improve your savings rate, consider reducing discretionary expenses...",
        "created_at": "2025-11-12T14:30:00.000000Z"
      }
    ],
    "links": {
      "first": "http://localhost:8000/api/chatbot/history?page=1",
      "last": "http://localhost:8000/api/chatbot/history?page=1",
      "prev": null,
      "next": null
    },
    "meta": {
      "current_page": 1,
      "from": 1,
      "last_page": 1,
      "path": "http://localhost:8000/api/chatbot/history",
      "per_page": 10,
      "to": 1,
      "total": 1
    }
  }
}
```

---

## Common Error Responses

### Unauthorized Access
```json
{
  "success": false,
  "message": "Unauthorized.",
  "data": []
}
```

### Resource Not Found
```json
{
  "success": false,
  "message": "Resource not found.",
  "data": []
}
```

### Validation Error
```json
{
  "success": false,
  "message": "Validation Error.",
  "data": {
    "field_name": [
      "Error message for the specific field"
    ]
  }
}
```

### Server Error
```json
{
  "success": false,
  "message": "Internal server error occurred.",
  "data": []
}
```

---

## Postman Collection Setup Instructions

1. **Import the Collection**: Import this documentation into Postman as a collection
2. **Set Environment Variables**:
   - `BASE_URL`: Your API base URL (e.g., `http://localhost:8000/api`)
   - `ACCESS_TOKEN`: Your authentication token
3. **Authentication Flow**:
   - First, use the Register/Login endpoints to get an access token
   - Set the token in your environment variables
   - Use the token for protected endpoints
4. **Testing Sequence**:
   - Register → Login → Get Profile → Create Category → Create Transaction → Create Budget → Create Savings Goal → Create Bill Reminder → View Dashboard

## Tips for Using the API

1. **Always include the Authorization header** for protected endpoints
2. **Handle token expiration** by refreshing or re-authenticating
3. **Validate responses** before processing data in your application
4. **Use appropriate HTTP methods** for each endpoint
5. **Follow the request body format** exactly as specified
6. **Check for rate limits** if making many requests
7. **Handle errors gracefully** in your application