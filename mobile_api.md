# Mobile API Documentation

Quick reference for mobile app development with agent-specific endpoints.

---

## 🔐 Authentication

### Agent Login
**POST** `/api/agents/login/`

```json
// Request
{"username": "agent_username", "password": "agent_password"}

// Response
{"success": true, "id": 7, "name": "Agent Name", "token": "agent_token", "storeID": 3}
```

---

## 📋 Visit Plans

### Get Active Visit Plan with Customers
**GET** `/api/agents/visit-plans/active-with-customers/`  
**Auth:** Basic Auth

Returns today's active plan with customer list including price lists.

```json
// Response
{
  "success": true,
  "data": {
    "plan_id": 1,
    "date_from": "2025-10-23",
    "date_to": "2025-10-31",
    "customers": [
      {
        "id": 175,
        "customer_name": "Customer Name",
        "phone_one": "01234567890",
        "price_list": {"id": 3, "name": "Wholesale Price List"}
      }
    ],
    "total_customers": 1
  }
}
```

---

## 📊 GET Endpoints

### Get Sales Invoices
**GET** `/api/agents/invoices/?agent_id=7&invoice_type=2`

**Parameters:** `agent_id` (required), `invoice_type` (2=Sales, 4=Return), `date_from`, `date_to`, `customer_vendor`

### Get Receive Vouchers
**GET** `/api/agents/transactions/?agent_id=7&transaction_type=1`

**Parameters:** `agent_id` (required), `transaction_type` (1=Receipt, 2=Payment), `date_from`, `date_to`

### Get Negative Visits
**GET** `/api/visits/negative/?agent_id=7`

**Parameters:** `agent_id` (required), `date_from`, `date_to`, `customer_vendor`

Returns visits with no related invoices or transactions.

### Get Items (for Invoice Creation)
**GET** `/api/items/`

Returns all items with details needed for invoice creation.

```json
// Response
[
  {
    "id": 101,
    "itemName": "Product A",
    "itemGroupId": 5,
    "barcode": "123456",
    "sign": "PC"
  }
]
```

### Get Price List Details
**GET** `/api/price-list-details/pricelist/{pricelist_id}/`

Returns items with prices for a specific price list.

```json
// Response
[
  {
    "id": 1,
    "item": {"id": 101, "itemName": "Product A"},
    "priceList": {"id": 3, "priceListName": "Wholesale"},
    "price": 200.00
  }
]
```

---

## 📤 POST Endpoints - Bulk Operations

### Bulk Create Sales Invoices
**POST** `/api/invoices/batch-create/`  
**Auth:** Token or Basic Auth

```json
{
  "invoices": [
    {
      "invoiceMaster": {
        "invoiceType": 2,
        "customerOrVendorID": 15,
        "storeId": 3,
        "agentID": 7,
        "status": 1,
        "paymentType": 1,
        "netTotal": 1000.00,
        "totalPaid": 1000.00
      },
      "invoiceDetails": [
        {"item": 101, "quantity": 5.0, "price": 200.00}
      ]
    }
  ]
}
```

**Invoice Types:** 2=Sales, 4=Return Sales  
**Payment Types:** 1=Cash, 2=Visa, 3=Deferred  
**Status:** 0=Paid, 1=Unpaid, 2=Partially Paid

### Bulk Create Vouchers
**POST** `/api/vouchers/batch-create/`  
**Auth:** Basic Auth

```json
{
  "vouchers": [
    {
      "type": 1,
      "customerVendorId": 15,
      "amount": 500.00,
      "storeId": 3,
      "notes": "Payment received",
      "voucherDate": "2025-10-23T14:30:00Z",
      "accountId": 35
    }
  ]
}
```

**Types:** 1=Receipt (IN), 2=Payment (OUT)  
**Max:** 100 vouchers per batch  
**Voucher ID Format:** `{agent_id}000{r|p}{sequence}`

### Bulk Create Visits
**POST** `/api/visits/batch-create/`  
**Auth:** Basic Auth

```json
{
  "visits": [
    {
      "transType": 1,
      "customerVendor": 15,
      "date": "2025-10-23T10:30:00Z",
      "latitude": 30.0444,
      "longitude": 31.2357,
      "notes": "Customer not available"
    }
  ]
}
```

**Transaction Types:** 1=Sales, 2=Return Sales, 3=Receive Voucher, 4=Pay Voucher  
**Max:** 100 visits per batch

---

## 🔑 Authentication

### Basic Auth Header
```
Authorization: Basic base64(username:password)
```

**Python:**
```python
import base64
credentials = base64.b64encode(f"{username}:{password}".encode()).decode()
headers = {"Authorization": f"Basic {credentials}"}
```

**JavaScript:**
```javascript
const credentials = btoa(`${username}:${password}`);
const headers = {"Authorization": `Basic ${credentials}`};
```

---

## 📝 Implementation Status

| Endpoint | Status | URL |
|----------|--------|-----|
| Agent Login | ✅ | `/api/agents/login/` |
| Get Active Visit Plan | ✅ | `/api/agents/visit-plans/active-with-customers/` |
| Get Sales Invoices | ✅ | `/api/agents/invoices/` |
| Get Receive Vouchers | ✅ | `/api/agents/transactions/` |
| Get Negative Visits | ✅ | `/api/visits/negative/` |
| Get Items | ✅ | `/api/items/` |
| Get Price List Details | ✅ | `/api/price-list-details/pricelist/{id}/` |
| Bulk Create Invoices | ✅ | `/api/invoices/batch-create/` |
| Bulk Create Vouchers | ✅ | `/api/vouchers/batch-create/` |
| Bulk Create Visits | ✅ | `/api/visits/batch-create/` |

---

## 🚀 Key Features

### Negative Visits
- Dynamically filters visits with no related invoices/transactions
- No schema changes required
- Flexible date range filtering

### Bulk Operations
- Atomic transactions (all or nothing)
- Maximum 100 items per batch
- Automatic ID generation for vouchers
- Double-entry accounting for vouchers

---

**Version:** 2.0  
**Last Updated:** 2025-10-23  
**Status:** Production Ready
