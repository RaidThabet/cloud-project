# Deployment Testing Guide (Frontend + Backend)

This document explains how to verify the deployed infrastructure and app behavior on AWS.

## 1) Get deployment endpoints

From the Terraform folder, read outputs:

- `backend_alb_dns`: backend API entrypoint (through ALB)
- `frontend_public_ip`: frontend website entrypoint

Use:

- `terraform output backend_alb_dns`
- `terraform output frontend_public_ip`

Then set:

- `BACKEND_DNS=<backend_alb_dns_without_quotes>`
- `FRONTEND_IP=<frontend_public_ip_without_quotes>`

---

## 2) Basic infrastructure checks

### Backend ALB health endpoint

Test backend API health through ALB:

- `curl -i http://$BACKEND_DNS/health`

Expected:

- HTTP status `200`
- JSON body containing `{"status":"ok"}`

### Frontend reachability

Open in browser:

- `http://$FRONTEND_IP`

Expected:

- Frontend page loads (HTML/CSS/JS)
- Task UI is visible

---

## 3) Backend API functional checks (CRUD)

### Create task

- `curl -i -X POST http://$BACKEND_DNS/tasks -H 'Content-Type: application/json' -d '{"title":"Test task"}'`

Expected:

- HTTP `201`
- JSON with created task (`id`, `title`, `done`)

### Read tasks

- `curl -i http://$BACKEND_DNS/tasks`

Expected:

- HTTP `200`
- JSON array containing created task

### Update task

Replace `<TASK_ID>` with the created id:

- `curl -i -X PUT http://$BACKEND_DNS/tasks/<TASK_ID> -H 'Content-Type: application/json' -d '{"done":true}'`

Expected:

- HTTP `200`
- JSON with `done: true`

### Delete task

- `curl -i -X DELETE http://$BACKEND_DNS/tasks/<TASK_ID>`

Expected:

- HTTP `200`
- JSON `{"deleted":true}`

---

## 4) Frontend-to-backend integration checks

In browser at `http://$FRONTEND_IP`:

1. Add a task from UI
2. Mark task done/undone
3. Delete task

Expected:

- Actions update immediately in UI
- Same data changes are visible from backend API (`GET /tasks`)

Optional validation in browser DevTools:

- Network calls should go to `http://<ALB_DNS>/tasks` (not to EC2 private IP)

---

## 5) Resilience checks (ASG + ALB)

Goal: verify backend remains available if one instance is terminated.

1. In AWS Console, go to EC2 instances.
2. Find one backend instance in the Auto Scaling Group.
3. Terminate that instance.
4. Continuously test:
   - `curl -i http://$BACKEND_DNS/health`

Expected:

- Endpoint continues returning `200` (after brief replacement/re-registration)
- ASG launches a replacement instance automatically

---

## 6) Security checks (grading-critical)

Validate Security Group rules in AWS Console:

- ALB SG: inbound HTTP `80` from `0.0.0.0/0`
- Backend SG: inbound app port only from ALB SG
- RDS SG: inbound DB port only from Backend SG
- Frontend SG: inbound HTTP `80` from `0.0.0.0/0`; SSH `22` restricted (if enabled for debug)

Also verify:

- Backend instances are in private subnets
- RDS is not publicly accessible

---

## 7) Common troubleshooting

- `terraform plan` asks for `db_password`: provide variable via `-var` or `.tfvars`.
- `/health` not `200`: check backend app process, target group health, and SG rules.
- Frontend loads but API calls fail: verify ALB DNS replacement in frontend `app.js` during user-data bootstrap.
- DB connection errors: verify env vars on backend instance (`DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`) and RDS SG rule.

---

## 8) Minimum demo checklist

- [ ] Frontend opens in browser
- [ ] `GET /health` returns `200`
- [ ] CRUD works through ALB
- [ ] Frontend triggers backend successfully
- [ ] SG chain is correct (ALB -> backend -> RDS)
- [ ] ASG replaces failed backend instance
