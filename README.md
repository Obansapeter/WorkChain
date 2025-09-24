WorkChain is a Clarity smart contract for the Stacks blockchain that enables **trustless work agreements** between employers and workers.  
It provides a decentralized way to create jobs, log working hours, approve hours, and automate payments in STX.

---

## ✨ Features
- 🏗 **Job Lifecycle**
  - Employers can create jobs with hourly STX rates.
  - Workers can accept jobs and start logging hours.
  - Employers can close jobs once work is completed.

- ⏱ **Work Tracking**
  - Workers log hours directly on-chain.
  - Employers review and approve logged hours.

- 💸 **Automated Payments**
  - Payments are executed automatically when hours are approved.
  - Wages are transferred in STX based on agreed rates.

- 🔍 **Transparency & Auditability**
  - All job details, hours, and payments are stored immutably on-chain.

---

## 📜 Contract Functions

### 🔹 Public Functions
- `create-job(rate)` → Create a new job with hourly rate (STX/hour).  
- `accept-job(jid)` → Worker accepts an open job.  
- `log-hours(jid, hours)` → Worker logs hours worked.  
- `approve-hours(jid, hours)` → Employer approves hours and pays worker.  
- `close-job(jid)` → Employer closes a job.

### 🔹 Read-Only Functions
- `get-job(jid)` → View job details (employer, worker, rate, status, etc.).  
- `get-logged-hours(jid, worker)` → View hours logged by a specific worker.  

---

## ⚠️ Error Codes
- `ERR-NOT-EMPLOYER (u100)` → Action requires employer role.  
- `ERR-NOT-WORKER (u101)` → Action requires worker role.  
- `ERR-NOT-FOUND (u102)` → Job not found.  
- `ERR-INVALID (u103)` → Invalid arguments or job state.  

```bash
clarinet contract deploy workchain
🛠 Example Workflow
Employer calls create-job with an hourly rate.

Worker accepts job with accept-job.

Worker logs hours with log-hours.

Employer reviews and approves hours via approve-hours.

STX payment is automatically transferred to the worker.

Employer calls close-job to finish.

✅ Benefits
Decentralized – No intermediaries needed.

Fair – Payments tied directly to approved work.

Transparent – Hours and payments are publicly auditable.

Automated – Employers don’t manually send payments; the contract handles it.

