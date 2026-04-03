# ModernBread Distribution Panel

ModernBread is a browser-based distribution management project with two separate interfaces:

- `Admin.html` for the distributor/admin
- `Agent.html` for the field agent

It is designed to help manage:

- products
- merchants
- daily stock
- order collection
- expenses
- invoices
- DSR (Daily Sales Report)
- payment tracking
- delivered order marking

This project currently works fully in the browser using `localStorage` for data persistence and live syncing between the Admin and Agent panels opened on the same machine/browser profile. It is structured in a way that can be connected to Firebase next.

## Project Files

- [Admin.html]
  The admin dashboard for stock entry, merchant/product setup, DSR, reports, invoices, and oversight.
- [Agent.html]
  The agent-facing panel for taking orders, checking stock, adding expenses, and updating delivery/payment status.
- [sample_showcase_dataset.json]
  A ready-made demo dataset that can be imported into the admin panel for presentations or testing.

## What This Project Does

At a high level, the workflow is:

1. Admin sets up products and merchants.
2. Admin enters the day’s opening stock and opening balance.
3. Agent uses the agent panel to place merchant orders and add expenses.
4. Admin sees those changes reflected in the admin panel.
5. Orders can be updated for payment mode and marked as delivered.
6. Admin can generate DSR, invoices, reports, and Excel exports.

## Main Features

- Shared admin-agent data through browser storage
- Merchant and product management
- Daily stock entry and stock-aware order validation
- Retail and merchant order capture
- Cash, UPI, and credit payment tracking
- Credit recovery recording in DSR
- Delivered order tracking
- Expense tracking from agent side
- Invoice viewing and PDF download
- DSR export in Excel-compatible format
- Demo dataset import for showcasing the project

## How Data Is Stored Right Now

This version does not use a backend yet.

Instead, data is stored in the browser using `localStorage`. That means:

- data stays saved in the browser unless cleared manually
- admin and agent sync when both are opened in the same browser profile
- opening the files in different browsers or different private/incognito windows will not share the same saved data

This is important for testing and demo use.

## Before You Start

You only need:

- a modern web browser such as Chrome, Edge, or Brave
- access to the project folder

No package install is required.
No build step is required.
No server is strictly required for basic use.

## How To Run The Project

### Option 1: Open directly in the browser

This is the easiest method.

1. Open the project folder.
2. Double-click [Admin.html]
3. Open [Agent.html] in another tab or window of the same browser.

This works for most demo use cases.

### Option 2: Run through a local server

This is the cleaner option if you want a more production-like local setup.

If Python is installed, open a terminal in the project folder and run:

```powershell
python -m http.server 8000
```

Then open:

- `http://localhost:8000/Admin.html`
- `http://localhost:8000/Agent.html`

Use the same browser for both tabs so data stays shared.

## First-Time Demo Setup

If you want to showcase the project quickly, use the included sample dataset.

### Import the demo dataset

1. Open the admin panel.
2. Click `Upload Dataset` in the top bar.
3. Select [sample_showcase_dataset.json].
4. Confirm the import.

After import, the admin panel will be populated with:

- products
- merchants
- stock data
- orders
- expenses
- opening balance
- tray data
- DSR-related records

This is the fastest way to get a full project view for a demo.

## Recommended Demo Flow

If you are showing the project to someone, this sequence works well:

1. Open `Admin.html` and `Agent.html` side by side.
2. In admin, show the dashboard, product list, merchant list, and daily stock.
3. In agent, create a new order for a merchant.
4. Show how that order appears in admin live orders and invoices.
5. Update payment mode from cash, UPI, or credit.
6. Mark the order as `Delivered`.
7. Add an expense from the agent panel.
8. Show the expense reflected in admin.
9. Open DSR in admin and download the Excel file.

## Admin Panel Guide

The admin panel is the control center of the project.

### Dashboard

The dashboard shows:

- gross revenue
- profit/loss
- credit pending
- expenses
- opening balance
- closing balance
- daily revenue graph
- product performance

### Live Orders

This page shows collected orders and allows the admin to:

- see recent orders
- check payment status
- mark an order as delivered
- open the invoice
- edit the order

### Daily Stock

This section is used every morning to enter stock received for the day.

The project then uses that stock to:

- calculate available quantity
- validate new orders
- estimate remaining stock

### Expenses

This page shows expense entries, mainly those added from the agent side.

### DSR

DSR stands for Daily Sales Report.

The admin DSR section includes:

- route sheet
- day close summary
- cash received
- credit pending
- retail summary
- opening balance handling
- credit recovery recording

The DSR download is exported as an Excel-compatible `.xls` file named like:

```text
DSR_2026-04-04.xls
```

### Reports

Reports provide summarized business views such as:

- daily summary
- sales performance
- expense reporting

### Invoices

The invoices section lets the admin:

- search invoices
- review order details
- inspect payment status
- see delivered status
- download PDFs

### Products

The admin can add and edit products with fields such as:

- product name
- purchase price
- merchant price
- retail price
- DSR code

### Merchants

The admin can add and manage merchants.

Merchant entries are shared with the agent panel automatically through browser storage sync.

## Agent Panel Guide

The agent panel is designed for fast field use.

### Home

The home screen shows:

- revenue
- merchants done
- collections
- pending credit

It also lists merchants for order collection.

### Taking an Order

The normal agent flow is:

1. Select a merchant.
2. Add item quantities.
3. Review the order.
4. Choose payment mode.
5. Save the order.

The project validates stock before saving the order.

### Orders Screen

The orders screen shows today’s orders and allows the agent to:

- review payment mode
- update payment mode
- mark the order as delivered
- open full order detail

### Stock Screen

The stock screen shows live remaining stock based on:

- admin daily stock entry
- orders already placed

### Expenses Screen

The agent can add field expenses such as:

- transport
- loading
- food
- miscellaneous day expenses

These entries sync to the admin panel.

## Live Sync Behavior

The project has browser-based sync between admin and agent.

It refreshes using:

- storage event updates
- tab focus updates
- visibility updates
- a periodic fallback sync

This helps new merchants, orders, stock changes, and expenses appear across both panels without a manual reload in most cases.

## Payment and Delivery Tracking

Each order can carry:

- payment mode: `cash`, `upi`, or `credit`
- credit recovery data
- delivered flag

Delivered status is tracked as a simple completion marker. It can be updated from both panels.

## Important Notes for Beginners

- Admin and agent should be opened in the same browser for shared data.
- Do not clear browser storage unless you want to reset the project data.
- If the panels look out of sync, switch tabs or reload once.
- Importing a dataset replaces current demo data.

## How To Reset the Project

If you want a fresh start, you can clear the browser’s site storage for the project or use a new browser profile.

Because this version uses `localStorage`, reset behavior depends on how you opened the files:

- if opened with `file://`, clear local storage for local files in that browser
- if opened through `http://localhost`, clear storage for `localhost`

## Firebase Readiness

The project is not connected to Firebase yet, but the codebase has already been organized around shared persistence helpers. That makes it much easier to replace browser storage with Firebase in the next phase.

Typical next steps would be:

1. Create a Firebase project.
2. Add Firebase config to both panels.
3. Replace `localStorage` read/write helpers with Firebase reads and writes.
4. Move live sync to Firestore realtime listeners.
5. Add authentication for admin and agent roles.

## Suggested Future Improvements

- Firebase integration
- user login and role-based access
- proper multi-device realtime sync
- backup/export-import controls
- advanced search and filters
- printable DSR layout
- merchant statement history
- order delivery timestamp tracking

## Troubleshooting

### Orders are not appearing between admin and agent

- Make sure both pages are open in the same browser profile.
- Avoid private/incognito mode for demos.
- Try refocusing the tab or refreshing once.

### Merchant added in admin is not visible in agent

- Confirm the agent page is open in the same browser.
- Wait a moment for sync or switch back to the tab.

### Stock feels incorrect

- Check that daily stock was entered in admin first.
- Check whether previous orders already consumed the day’s stock.

### DSR looks empty

- Make sure there are orders for the selected day.
- Check the selected date filter.
- Confirm opening balance and stock entries were entered for that date if needed.

## Best Way To Present This Project

For a polished showcase:

1. Import the sample dataset.
2. Open admin and agent side by side.
3. Show shared sync in real time.
4. Create one fresh order from the agent panel.
5. Mark it delivered.
6. Open DSR and export Excel.

## Summary

This project is a lightweight but functional distribution workflow system for a bread distribution business. It supports admin oversight, agent field work, live browser sync, stock-aware ordering, payment tracking, DSR generation, invoice handling, and demo dataset import.

If you want, the next step can be:

- a Firebase integration guide
- a technical architecture README
- a client-facing project presentation document
