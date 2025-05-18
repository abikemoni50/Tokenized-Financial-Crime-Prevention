;; Risk Scoring Contract
;; This contract identifies suspicious activity

;; Define admin variable
(define-data-var admin principal tx-sender)

;; Map to store entity risk scores
(define-map risk-scores principal
  {
    score: uint,
    last-updated: uint
  }
)

;; Map to store risk factors
(define-map risk-factors
  { entity: principal, factor-index: uint }
  (string-utf8 50)
)

;; Function to set a risk score
(define-public (set-risk-score
    (entity principal)
    (score uint)
    (factor (string-utf8 50)))
  (begin
    ;; Check if sender is admin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))

    ;; Store risk score
    (map-set risk-scores entity
      {
        score: score,
        last-updated: block-height
      }
    )

    ;; Store risk factor
    (map-set risk-factors
      { entity: entity, factor-index: u0 }
      factor
    )

    (ok true)
  )
)

;; Function to add a risk factor
(define-public (add-risk-factor
    (entity principal)
    (factor (string-utf8 50))
    (factor-index uint))
  (begin
    ;; Check if sender is admin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))

    ;; Store risk factor
    (map-set risk-factors
      { entity: entity, factor-index: factor-index }
      factor
    )

    (ok true)
  )
)

;; Function to get risk score
(define-read-only (get-risk-score (entity principal))
  (default-to
    { score: u0, last-updated: u0 }
    (map-get? risk-scores entity)
  )
)

;; Function to get risk factor
(define-read-only (get-risk-factor (entity principal) (factor-index uint))
  (map-get? risk-factors { entity: entity, factor-index: factor-index })
)

;; Function to check if entity is high risk
(define-read-only (is-high-risk (entity principal))
  (>
    (get score (default-to
      { score: u0, last-updated: u0 }
      (map-get? risk-scores entity)
    ))
    u70
  )
)
