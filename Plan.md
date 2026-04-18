# Implementation Plan — Task Manager App

## Overview

A minimal full-stack Task Manager. Node.js/Express backend, plain HTML/CSS/JS frontend, PostgreSQL database. No auth, no frameworks, no unnecessary complexity.

---

## Repository Structure

```
/
├── backend/
│   ├── server.js
│   ├── db.js
│   ├── package.json
│   └── .env.example
└── frontend/
    ├── index.html
    ├── style.css
    └── app.js
```

---

## Step 1 — Backend

### 1.1 `package.json`

- name: `task-manager-backend`
- dependencies: `express`, `pg`, `cors`, `dotenv`
- start script: `node server.js`

### 1.2 `db.js`

- Create and export a `pg.Pool` instance
- Read all connection config from environment variables: `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASS`

### 1.3 `server.js`

- Load `dotenv`, import `express`, `cors`, and `db.js`
- Listen on `process.env.PORT` (default `3000`)
- On startup, run the following SQL to initialize the database:

```sql
CREATE TABLE IF NOT EXISTS tasks (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  done BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW()
);
```

- Implement the following routes:

| Method | Path | Description | Success code |
|--------|------|-------------|--------------|
| GET | `/health` | Returns `{ status: "ok" }` | 200 |
| GET | `/tasks` | Returns all tasks ordered by `created_at DESC` | 200 |
| POST | `/tasks` | Creates a task, body: `{ title }`, returns created row | 201 |
| PUT | `/tasks/:id` | Updates a task, body: `{ title?, done? }`, returns updated row | 200 |
| DELETE | `/tasks/:id` | Deletes a task, returns `{ deleted: true }` | 200 |

- All routes return JSON
- Wrap all DB calls in try/catch, return 500 with `{ error: message }` on failure
- Return 400 if `title` is missing or empty on POST

### 1.4 `.env.example`

```
DB_HOST=
DB_PORT=5432
DB_NAME=tasks_db
DB_USER=
DB_PASS=
PORT=3000
```

---

## Step 2 — Frontend

### 2.1 `index.html`

Structure (no CSS frameworks, semantic HTML only):

- `<head>`: title, link to `style.css`
- `<body>`:
  - `<h1>` — app title
  - A form-like section: text `<input>` + `<button>Add</button>` (use a `div`, not `<form>`)
  - A `<ul id="task-list">` where tasks are rendered
  - `<script src="app.js">` at the bottom

### 2.2 `app.js`

- First line: `const API = "http://<ALB_DNS_PLACEHOLDER>";` — a single constant that will be replaced with the actual ALB DNS at deploy time
- On `DOMContentLoaded`: call `loadTasks()`
- `loadTasks()`: GET `/tasks`, clear the list, render each task as an `<li>`
- Each `<li>` contains:
  - A checkbox (checked if `done === true`) — on change, call `updateTask(id, { done: checked })`
  - A `<span>` with the task title — strikethrough style if done
  - A delete button — on click, call `deleteTask(id)`
- Add button click handler: read input value, validate not empty, call `createTask(title)`, clear input, reload tasks
- All fetch calls use `Content-Type: application/json`
- On any fetch error, log to console (no complex error UI needed)

### 2.3 `style.css`

Keep it minimal but not ugly:

- Body: centered, max-width `600px`, `font-family: sans-serif`
- Input: reasonable width, padding
- Buttons: cursor pointer, simple background color
- Done tasks: `text-decoration: line-through`, muted color
- Task list items: flex row, space between, padding, border-bottom

---

## Step 3 — Verification Checklist

Before handing off to infra/deployment:

- [ ] `GET /health` returns 200 with JSON body
- [ ] All four CRUD routes work correctly when tested with curl or Postman
- [ ] Backend starts cleanly with only env vars set (no hardcoded values anywhere)
- [ ] Frontend loads tasks on page open
- [ ] Adding a task updates the list without page refresh
- [ ] Toggling done updates the task in the DB
- [ ] Deleting a task removes it from the DB and the UI
- [ ] `API` constant in `app.js` is the only place the backend URL appears

---

## Notes for Deployment (infra agent context)

- The backend repo URL and the RDS endpoint need to be injected into the EC2 User Data script
- The `API` constant in `app.js` must be replaced with the ALB DNS before the frontend is served
- The backend runs on port `3000` by default — the ALB Target Group should health-check `GET /health` on that port
- The DB table is created automatically on first backend startup — no manual migration needed
