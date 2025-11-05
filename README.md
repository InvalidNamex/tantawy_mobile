# Tantawy Mobile App

A Flutter mobile application for sales agents with offline-first functionality.

## Tech Stack
- **State Management:** GetX
- **HTTP Client:** Dio
- **Local Storage:** Hive + SharedPreferences
- **Architecture:** MVC (Model-View-Controller)
- **Flutter Version:** Current stable version
- **Minimum SDK:** As required by packages

## Configuration

### API Base URL
```dart
baseURL: http://127.0.0.1:8000/
```

### Authentication
- **Method:** Basic Auth (username:password encoded in base64)
- **Storage:** Store complete agent model (id, name, token, storeID) in SharedPreferences after login
- **Usage:** Use Basic Auth for all API requests after login

### Account IDs
- **Customer Account:** 36 (used for sales/return sales invoices)
- **Store Cash Account:** 35 (used for receive/payment vouchers)

## User Stories

### 1. First-Time Login
- User must have internet connection for first login
- If no internet and user is not previously registered, show offline alert dialog with retry button
- If user is already registered (data exists locally), allow offline access

### 2. Login Page
- User enters username and password
- On successful login, save complete agent model to SharedPreferences:
  - Agent ID
  - Agent Name
  - Token
  - Store ID
- Use credentials for Basic Auth in subsequent requests

### 3. Data Synchronization
- Perform all GET requests on login/refresh
- Save all fetched data to Hive DB for offline access:
  - Visit plans with customers
  - Sales invoices
  - Return sales invoices
  - Receive vouchers
  - Payment vouchers
  - Negative visits
  - Items list
  - Price list details per customer

### 4. Home Screen Structure

#### AppBar
- Display agent basic info (name)
- Sync button (checks internet, bulk sends offline transactions)

#### TabBar Tabs
1. **Visit Plan** - No filters, shows ALL customers from active visit plan
2. **Sales** - Filters: DateFrom, DateTo, Customer
3. **Return Sales** - Filters: DateFrom, DateTo, Customer
4. **Negative Visits** - Filters: DateFrom, DateTo, Customer
5. **Receive Vouchers** - Filters: DateFrom, DateTo, Customer
6. **Payment Vouchers** - Filters: DateFrom, DateTo, Customer

#### Body
- ListView with ExpansionTile for each customer/transaction
- Visit Plan tab shows ALL customers from active visit plan (no filtering)
- Other tabs show filtered transactions

### 5. Customer Actions (ExpansionTile)

When a customer is tapped in Visit Plan, expansion tile opens with 4 action buttons:
1. **Sale** - Create new sales invoice
2. **Return Sale** - Create new return sales invoice
3. **Voucher** - Create voucher with switch (Receive/Payment)
4. **Negative Visit** - Record negative visit

Each button opens a new page with appropriate form.

### 6. Transaction Forms

#### Sales Invoice Form
- Customer (pre-filled from selection)
- Items selection (multiple items can be added)
- For each added item, display in a table/list with columns:
  - Item Name
  - Quantity (editable)
  - Price (default from customer's price list, manually editable)
  - Discount (editable)
  - VAT (editable)
  - Total (auto-calculated per item)
- Payment Type (Cash=1, Visa=2, Deferred=3)
- Status (Paid=0, Unpaid=1, Partially Paid=2)
- Total Paid amount
- Auto-calculate netTotal (sum of all item totals)
- Submit button

**Item Selection Flow:**
1. User selects multiple items from items list
2. Selected items are added to invoice with default prices from customer's price list
3. User can edit quantity, price, discount, and VAT for each item
4. Total column updates automatically for each item
5. netTotal updates automatically as sum of all item totals

**API Mapping:**
- invoiceType: 2 (Sales)
- customerOrVendorID: selected customer ID
- storeId: from agent model
- agentID: from agent model
- accountId: 36 (customer account)

#### Return Sales Invoice Form
- Same as Sales Invoice Form
- invoiceType: 4 (Return Sales)

#### Voucher Form
- Customer (pre-filled from selection)
- Amount
- Notes
- Switch: Receive (IN) / Payment (OUT)
- Submit button

**API Mapping:**
- type: 1 (Receipt/IN) or 2 (Payment/OUT)
- customerVendorId: selected customer ID
- storeId: from agent model
- accountId: 35 (store cash account)
- voucherDate: current timestamp

#### Negative Visit Form
- Customer (pre-filled from selection)
- Notes (text input)
- Location (auto-captured: latitude, longitude)
- Submit button

**API Mapping:**
- transType: 5 (Negative Visit)
- customerVendor: selected customer ID
- date: current timestamp
- latitude: auto-captured
- longitude: auto-captured
- notes: user input

### 7. Offline Transaction Handling

#### Online Mode (Internet Available)
- Submit transaction to API immediately
- On success, save to Hive DB
- Show success message

#### Offline Mode (No Internet)
- Save transaction to separate Hive boxes:
  - `pending_invoices` (sales and return sales)
  - `pending_vouchers` (receive and payment)
  - `pending_visits` (negative visits)
- Show offline success message
- Display pending sync indicator

### 8. Sync Functionality

#### Sync Button (AppBar)
- Check internet connectivity
- If offline, show alert
- If online:
  - Bulk send pending invoices via `/api/invoices/batch-create/`
  - Bulk send pending vouchers via `/api/vouchers/batch-create/`
  - Bulk send pending visits via `/api/visits/batch-create/`
  - On successful sync, remove synced items from pending Hive boxes
  - Update main Hive DB with new data
  - Show sync success message

## Data Models

### Agent Model
```dart
{
  id: int,
  name: String,
  token: String,
  storeID: int
}
```

### Customer Model
```dart
{
  id: int,
  customer_name: String,
  phone_one: String,
  price_list: {
    id: int,
    name: String
  }
}
```

### Item Model
```dart
{
  id: int,
  itemName: String,
  itemGroupId: int,
  barcode: String,
  sign: String
}
```

### Price List Detail Model
```dart
{
  id: int,
  item: {
    id: int,
    itemName: String
  },
  priceList: {
    id: int,
    priceListName: String
  },
  price: double
}
```

## Styling

### Theme
- Light mode and dark mode support
- Primary color: Green accent
- Follow Material Design guidelines

### Colors
- Primary: Green shades
- Accent: Green accent
- Background: White (light) / Dark grey (dark)
- Text: Dark grey (light) / White (dark)

## Localization

### Supported Languages
- Arabic (default)
- English

### Implementation
- Use GetX localization
- Store language preference in SharedPreferences
- RTL support for Arabic

## API Endpoints Reference

Refer to `mobile_api.md` for complete API documentation.

### Key Endpoints
- Login: `POST /authentication/api/agents/login/`
- Visit Plans: `GET /api/agents/visit-plans/active-with-customers/`
- Items: `GET /api/items/`
- Price Lists: `GET /api/price-list-details/pricelist/{id}/`
- Sales: `GET /authentication/api/agents/invoices/?invoice_type=2`
- Vouchers: `GET /authentication/api/agents/transactions/?transaction_type=1`
- Negative Visits: `GET /api/visits/negative/`
- Bulk Invoices: `POST /api/invoices/batch-create/`
- Bulk Vouchers: `POST /api/vouchers/batch-create/`
- Bulk Visits: `POST /api/visits/batch-create/`

## Project Structure

Refer to `PROJECT_STRUCTURE.md` for detailed folder organization.

## Additional Requirements

### Sales Invoice Item Management
- User can select multiple items at once from items list
- After items are added to invoice, user can:
  - Edit quantity for each item
  - Edit price for each item (overrides default price list price)
  - Add discount per item
  - Add VAT per item
- Display columns: Item Name, Quantity, Price, Discount, VAT, Total
- Auto-calculate item total: (Quantity × Price) - Discount + VAT
- Auto-calculate invoice netTotal: Sum of all item totals

### Visit Plan Display
- Show ALL customers from active visit plan
- No filtering or status-based display
- All customers visible regardless of visit status

---

**Version:** 1.0  
**Last Updated:** January 2025



