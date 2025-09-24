;; ------------------------------------------------------------
;; Contract: WorkChain
;; Purpose: On-chain time tracking & automated wage payments
;; Author: Thankgod Isaac
;; ------------------------------------------------------------

;; -----------------------------
;; Data Structures
;; -----------------------------

(define-map jobs
  uint ;; job-id
  {
    employer: principal,
    worker: (optional principal),
    rate: uint,                ;; STX per hour
    total-hours: uint,
    approved-hours: uint,
    status: (string-ascii 12)  ;; "open", "active", "closed"
  }
)

(define-map logged-hours
  { job-id: uint, worker: principal }
  uint ;; total hours logged
)

(define-data-var next-job-id uint u1)

;; -----------------------------
;; Errors
;; -----------------------------
(define-constant ERR-NOT-EMPLOYER (err u100))
(define-constant ERR-NOT-WORKER (err u101))
(define-constant ERR-NOT-FOUND (err u102))
(define-constant ERR-INVALID (err u103))

;; -----------------------------
;; Create Job
;; -----------------------------
(define-public (create-job (rate uint))
  (begin
    (asserts! (> rate u0) ERR-INVALID)
    (let ((jid (var-get next-job-id)))
      (map-set jobs jid {
        employer: tx-sender,
        worker: none,
        rate: rate,
        total-hours: u0,
        approved-hours: u0,
        status: "open"
      })
      (var-set next-job-id (+ jid u1))
      (ok jid)
    )
  )
)

;; -----------------------------
;; Accept Job (worker joins)
;; -----------------------------
(define-public (accept-job (jid uint))
  (let ((job (unwrap! (map-get? jobs jid) ERR-NOT-FOUND)))
    (asserts! (is-eq (get status job) "open") ERR-INVALID)
    (map-set jobs jid (merge job { worker: (some tx-sender), status: "active" }))
    (ok true)
  )
)

;; -----------------------------
;; Log Hours (worker action)
;; -----------------------------
(define-public (log-hours (jid uint) (hours uint))
  (let ((job (unwrap! (map-get? jobs jid) ERR-NOT-FOUND)))
    (asserts! (is-some (get worker job)) ERR-INVALID)
    (asserts! (is-eq (unwrap-panic (get worker job)) tx-sender) ERR-NOT-WORKER)
    (map-set logged-hours { job-id: jid, worker: tx-sender }
             (+ (default-to u0 (map-get? logged-hours { job-id: jid, worker: tx-sender })) hours))
    (ok true)
  )
)

;; -----------------------------
;; Approve Hours & Pay Worker
;; -----------------------------
(define-public (approve-hours (jid uint) (hours uint))
  (let ((job (unwrap! (map-get? jobs jid) ERR-NOT-FOUND)))
    (asserts! (is-eq (get employer job) tx-sender) ERR-NOT-EMPLOYER)
    (let (
          (worker (unwrap-panic (get worker job)))
          (prev-approved (get approved-hours job))
          (rate (get rate job))
         )
      ;; update approved hours
      (map-set jobs jid (merge job { approved-hours: (+ prev-approved hours) }))
      ;; transfer STX payment
      (let ((payment (* hours rate)))
        (unwrap-panic (stx-transfer? payment tx-sender worker))
      )
      (ok true)
    )
  )
)

;; -----------------------------
;; Close Job (employer ends)
;; -----------------------------
(define-public (close-job (jid uint))
  (let ((job (unwrap! (map-get? jobs jid) ERR-NOT-FOUND)))
    (asserts! (is-eq (get employer job) tx-sender) ERR-NOT-EMPLOYER)
    (map-set jobs jid (merge job { status: "closed" }))
    (ok true)
  )
)

;; -----------------------------
;; Views
;; -----------------------------
(define-read-only (get-job (jid uint))
  (ok (map-get? jobs jid))
)

(define-read-only (get-logged-hours (jid uint) (worker principal))
  (ok (default-to u0 (map-get? logged-hours { job-id: jid, worker: worker })))
)
