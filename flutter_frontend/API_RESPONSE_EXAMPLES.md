# API Response Examples

## Authentication

### Register Success
```json
{
  "success": true,
  "data": {
    "token": "1|abc123def456...",
    "name": "John Doe"
  },
  "message": "User register successfully."
}
```

### Register Error (Validation)
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

### Login Success
```json
{
  "success": true,
  "data": {
    "token": "1|abc123def456...",
    "name": "John Doe",
    "email": "john@example.com"
  },
  "message": "User login successfully."
}
```

### Login Error
```json
{
  "success": false,
  "message": "Unauthorized.",
  "data": {
    "error": "Unauthorized"
  }
}
```

## Categories

### Get Categories Success
```json
{
  "success": true,
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
      "first": "https://each-commented-poet-compounds.trycloudflare.com/api/categories?page=1",
      "last": "https://each-commented-poet-compounds.trycloudflare.com/api/categories?page=1",
      "prev": null,
      "next": null
    },
    "meta": {
      "current_page": 1,
      "from": 1,
      "last_page": 1,
      "path": "https://each-commented-poet-compounds.trycloudflare.com/api/categories",
      "per_page": 10,
      "to": 1,
      "total": 1
    }
  },
  "message": "Categories retrieved successfully."
}
```

### Create Category Success
```json
{
  "success": true,
  "data": {
    "id": 1,
    "user_id": 1,
    "name": "Groceries",
    "type": "expense",
    "created_at": "2025-11-12T14:30:00.000000Z",
    "updated_at": "2025-11-12T14:30:00.000000Z"
  },
  "message": "Category created successfully."
}
```

### Create Category Error (Validation)
```json
{
  "success": false,
  "message": "Validation Error.",
  "data": {
    "type": [
      "Category type must be either \"income\" or \"expense\"."
    ]
  }
}
```

## Transactions

### Get Transactions Success
```json
{
  "success": true,
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
      "first": "https://each-commented-poet-compounds.trycloudflare.com/api/transactions?page=1",
      "last": "https://each-commented-poet-compounds.trycloudflare.com/api/transactions?page=1",
      "prev": null,
      "next": null
    },
    "meta": {
      "current_page": 1,
      "from": 1,
      "last_page": 1,
      "path": "https://each-commented-poet-compounds.trycloudflare.com/api/transactions",
      "per_page": 10,
      "to": 1,
      "total": 1
    }
  },
  "message": "Transactions retrieved successfully."
}
```

## Budgets

### Get Budgets Success
```json
{
  "success": true,
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
      "first": "https://each-commented-poet-compounds.trycloudflare.com/api/budgets?page=1",
      "last": "https://each-commented-poet-compounds.trycloudflare.com/api/budgets?page=1",
      "prev": null,
      "next": null
    },
    "meta": {
      "current_page": 1,
      "from": 1,
      "last_page": 1,
      "path": "https://each-commented-poet-compounds.trycloudflare.com/api/budgets",
      "per_page": 10,
      "to": 1,
      "total": 1
    }
  },
  "message": "Budgets retrieved successfully."
}
```

## Savings Goals

### Get Savings Goals Success
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": 1,
        "user_id": 1,
        "name": "Emergency Fund",
        "description": "Building an emergency fund for unexpected expenses",
        "target_amount": "1000.00",
        "current_amount": "450.00",
        "target_date": "2026-01-01",
        "status": "active",
        "created_at": "2025-11-12T14:30:00.000000Z",
        "updated_at": "2025-11-12T14:30:00.000000Z",
        "progress_percentage": 45.00,
        "days_remaining": 60,
        "amount_needed": 550.00
      }
    ],
    "links": {
      "first": "https://each-commented-poet-compounds.trycloudflare.com/api/savings-goals?page=1",
      "last": "https://each-commented-poet-compounds.trycloudflare.com/api/savings-goals?page=1",
      "prev": null,
      "next": null
    },
    "meta": {
      "current_page": 1,
      "from": 1,
      "last_page": 1,
      "path": "https://each-commented-poet-compounds.trycloudflare.com/api/savings-goals",
      "per_page": 10,
      "to": 1,
      "total": 1
    }
  },
  "message": "Savings goals retrieved successfully."
}
```

## Unauthorized Access Error
```json
{
  "success": false,
  "message": "Unauthorized.",
  "data": []
}
```

## Not Found Error
```json
{
  "success": false,
  "message": "Resource not found.",
  "data": []
}
```