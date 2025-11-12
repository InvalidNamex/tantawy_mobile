# Used Endpoints

This document tracks the API endpoints that are currently being used in the application.

## Authentication Endpoints

### 1. Login
- **Endpoint**: `POST /api/agents/login/`
- **Authentication**: None (public endpoint)
- **Request Body**:
  ```json
  {
    "username": "string",
    "password": "string"
  }
  ```
- **Response**: Agent object containing:
  - `id`: Agent ID
  - `name`: Agent name
  - `username`: Username (added from request)
  - `password`: Password (added from request, stored for Basic Auth)
  - `token`: Authentication token
  - `storeID`: Store ID
- **Used In**: `AuthController.login()` → `AuthRepository.login()` → `ApiProvider.login()`
- **Notes**: 
  - Credentials are stored locally after successful login
  - Username and password are used for Basic Authentication in subsequent requests
  - Initial data fetch is triggered after successful login

