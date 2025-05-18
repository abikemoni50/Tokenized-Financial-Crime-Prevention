;; Institution Verification Contract
;; This contract validates financial entities

;; Define admin variable
(define-data-var admin principal tx-sender)

;; Map to store verified institutions
(define-map verified-institutions principal bool)

;; Map to store institution details
(define-map institution-details principal
  {
    name: (string-utf8 100),
    license-id: (string-utf8 50),
    verification-date: uint,
    is-active: bool
  }
)

;; Function to verify a new institution
(define-public (verify-institution
    (institution principal)
    (name (string-utf8 100))
    (license-id (string-utf8 50)))
  (begin
    ;; Check if sender is admin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))

    ;; Set institution as verified
    (map-set verified-institutions institution true)

    ;; Store institution details
    (map-set institution-details institution
      {
        name: name,
        license-id: license-id,
        verification-date: block-height,
        is-active: true
      }
    )
    (ok true)
  )
)

;; Function to check if an institution is verified
(define-read-only (is-verified (institution principal))
  (default-to false (map-get? verified-institutions institution))
)

;; Function to get institution details
(define-read-only (get-institution-details (institution principal))
  (map-get? institution-details institution)
)

;; Function to revoke verification
(define-public (revoke-verification (institution principal))
  (begin
    ;; Check if sender is admin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))

    ;; Check if institution exists
    (asserts! (is-some (map-get? institution-details institution)) (err u2))

    ;; Update institution details
    (map-set institution-details institution
      {
        name: (get name (unwrap-panic (map-get? institution-details institution))),
        license-id: (get license-id (unwrap-panic (map-get? institution-details institution))),
        verification-date: (get verification-date (unwrap-panic (map-get? institution-details institution))),
        is-active: false
      }
    )

    ;; Set institution as not verified
    (map-set verified-institutions institution false)

    (ok true)
  )
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    ;; Check if sender is admin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))

    ;; Set new admin
    (var-set admin new-admin)
    (ok true)
  )
)
