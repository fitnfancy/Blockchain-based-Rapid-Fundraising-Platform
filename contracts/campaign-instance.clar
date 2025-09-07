(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-GOAL (err u101))
(define-constant ERR-INVALID-DEADLINE (err u102))
(define-constant ERR-INVALID-TITLE (err u103))
(define-constant ERR-INVALID-DESCRIPTION (err u104))
(define-constant ERR-CAMPAIGN-ALREADY-EXISTS (err u105))
(define-constant ERR-CAMPAIGN-NOT-FOUND (err u106))
(define-constant ERR-CAMPAIGN-CLOSED (err u107))
(define-constant ERR-DEADLINE-PASSED (err u108))
(define-constant ERR-INVALID-MIN-DONATION (err u109))
(define-constant ERR-INVALID-TOKEN-TYPE (err u110))
(define-constant ERR-MAX-CAMPAIGNS-EXCEEDED (err u111))
(define-constant ERR-INVALID-UPDATE-GOAL (err u112))
(define-constant ERR-UPDATE-NOT-ALLOWED (err u113))
(define-constant ERR-INVALID-CATEGORY (err u114))
(define-constant ERR-INVALID-STATUS (err u115))
(define-constant ERR-INVALID-START-TIME (err u116))
(define-constant ERR-INVALID-MILESTONES (err u117))
(define-constant ERR-INVALID-REFUND-POLICY (err u118))
(define-constant ERR-INVALID-KYC-REQUIRED (err u119))
(define-constant ERR-INVALID-MAX-DONORS (err u120))
(define-constant ERR-INVALID-LOCATION (err u121))
(define-constant ERR-INVALID-TAGS (err u122))
(define-constant ERR-INVALID-IMAGE-HASH (err u123))
(define-constant ERR-INVALID-VIDEO-HASH (err u124))
(define-constant ERR-INVALID-WEBSITE (err u125))
(define-constant ERR-INVALID-EMAIL (err u126))
(define-constant ERR-INVALID-PHONE (err u127))
(define-constant ERR-INVALID-SOCIAL-LINKS (err u128))
(define-constant ERR-INVALID-TEAM-MEMBERS (err u129))
(define-constant ERR-INVALID-BUDGET-BREAKDOWN (err u130))

(define-data-var next-campaign-id uint u0)
(define-data-var max-campaigns uint u10000)
(define-data-var creation-fee uint u500)
(define-data-var governance-contract (optional principal) none)

(define-map campaigns
  uint
  {
    goal: uint,
    raised: uint,
    deadline: uint,
    start-time: uint,
    active: bool,
    creator: principal,
    title: (string-utf8 100),
    description: (string-utf8 1000),
    min-donation: uint,
    token-type: (string-utf8 10),
    category: (string-utf8 50),
    status: (string-utf8 20),
    milestones: (list 10 uint),
    refund-policy: bool,
    kyc-required: bool,
    max-donors: uint,
    location: (string-utf8 100),
    tags: (list 5 (string-utf8 20)),
    image-hash: (buff 32),
    video-hash: (buff 32),
    website: (string-utf8 100),
    email: (string-utf8 50),
    phone: (string-utf8 20),
    social-links: (list 5 (string-utf8 100)),
    team-members: (list 10 (string-utf8 50)),
    budget-breakdown: (string-utf8 500)
  }
)

(define-map campaigns-by-creator
  principal
  (list 100 uint)
)

(define-map campaign-updates
  uint
  {
    update-goal: uint,
    update-deadline: uint,
    update-description: (string-utf8 1000),
    update-timestamp: uint,
    updater: principal
  }
)

(define-read-only (get-campaign (id uint))
  (map-get? campaigns id)
)

(define-read-only (get-campaign-updates (id uint))
  (map-get? campaign-updates id)
)

(define-read-only (get-campaigns-by-creator (creator principal))
  (default-to (list) (map-get? campaigns-by-creator creator))
)

(define-read-only (is-campaign-active (id uint))
  (match (map-get? campaigns id)
    c (and (get active c) (< block-height (get deadline c)))
    false)
)

(define-private (validate-goal (g uint))
  (if (> g u0)
      (ok true)
      ERR-INVALID-GOAL)
)

(define-private (validate-deadline (d uint))
  (if (> d block-height)
      (ok true)
      ERR-INVALID-DEADLINE)
)

(define-private (validate-title (t (string-utf8 100)))
  (if (> (len t) u0)
      (ok true)
      ERR-INVALID-TITLE)
)

(define-private (validate-description (desc (string-utf8 1000)))
  (if (> (len desc) u0)
      (ok true)
      ERR-INVALID-DESCRIPTION)
)

(define-private (validate-min-donation (md uint))
  (if (>= md u0)
      (ok true)
      ERR-INVALID-MIN-DONATION)
)

(define-private (validate-token-type (tt (string-utf8 10)))
  (if (or (is-eq tt "STX") (is-eq tt "SIP10"))
      (ok true)
      ERR-INVALID-TOKEN-TYPE)
)

(define-private (validate-category (cat (string-utf8 50)))
  (if (> (len cat) u0)
      (ok true)
      ERR-INVALID-CATEGORY)
)

(define-private (validate-status (s (string-utf8 20)))
  (if (or (is-eq s "draft") (is-eq s "active") (is-eq s "closed"))
      (ok true)
      ERR-INVALID-STATUS)
)

(define-private (validate-start-time (st uint))
  (if (<= st block-height)
      (ok true)
      ERR-INVALID-START-TIME)
)

(define-private (validate-milestones (m (list 10 uint)))
  (if (is-eq (len m) (fold + m u0))
      (ok true)
      ERR-INVALID-MILESTONES)
)

(define-private (validate-refund-policy (rp bool))
  (ok true)
)

(define-private (validate-kyc-required (k bool))
  (ok true)
)

(define-private (validate-max-donors (md uint))
  (if (> md u0)
      (ok true)
      ERR-INVALID-MAX-DONORS)
)

(define-private (validate-location (loc (string-utf8 100)))
  (if (>= (len loc) u0)
      (ok true)
      ERR-INVALID-LOCATION)
)

(define-private (validate-tags (t (list 5 (string-utf8 20))))
  (ok true)
)

(define-private (validate-image-hash (ih (buff 32)))
  (if (is-eq (len ih) u32)
      (ok true)
      ERR-INVALID-IMAGE-HASH)
)

(define-private (validate-video-hash (vh (buff 32)))
  (if (is-eq (len vh) u32)
      (ok true)
      ERR-INVALID-VIDEO-HASH)
)

(define-private (validate-website (w (string-utf8 100)))
  (ok true)
)

(define-private (validate-email (e (string-utf8 50)))
  (ok true)
)

(define-private (validate-phone (p (string-utf8 20)))
  (ok true)
)

(define-private (validate-social-links (sl (list 5 (string-utf8 100))))
  (ok true)
)

(define-private (validate-team-members (tm (list 10 (string-utf8 50))))
  (ok true)
)

(define-private (validate-budget-breakdown (bb (string-utf8 500)))
  (ok true)
)

(define-public (set-governance-contract (contract-principal principal))
  (begin
    (asserts! (is-none (var-get governance-contract)) ERR-NOT-AUTHORIZED)
    (var-set governance-contract (some contract-principal))
    (ok true))
)

(define-public (set-max-campaigns (new-max uint))
  (begin
    (asserts! (is-some (var-get governance-contract)) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq tx-sender (unwrap! (var-get governance-contract) ERR-NOT-AUTHORIZED)) ERR-NOT-AUTHORIZED)
    (var-set max-campaigns new-max)
    (ok true))
)

(define-public (set-creation-fee (new-fee uint))
  (begin
    (asserts! (is-some (var-get governance-contract)) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq tx-sender (unwrap! (var-get governance-contract) ERR-NOT-AUTHORIZED)) ERR-NOT-AUTHORIZED)
    (var-set creation-fee new-fee)
    (ok true))
)

(define-public (create-campaign
  (goal uint)
  (deadline uint)
  (title (string-utf8 100))
  (description (string-utf8 1000))
  (min-donation uint)
  (token-type (string-utf8 10))
  (category (string-utf8 50))
  (milestones (list 10 uint))
  (refund-policy bool)
  (kyc-required bool)
  (max-donors uint)
  (location (string-utf8 100))
  (tags (list 5 (string-utf8 20)))
  (image-hash (buff 32))
  (video-hash (buff 32))
  (website (string-utf8 100))
  (email (string-utf8 50))
  (phone (string-utf8 20))
  (social-links (list 5 (string-utf8 100)))
  (team-members (list 10 (string-utf8 50)))
  (budget-breakdown (string-utf8 500)))
  (let (
        (next-id (var-get next-campaign-id))
        (current-max (var-get max-campaigns))
        (creator-campaigns (get-campaigns-by-creator tx-sender))
      )
    (asserts! (< next-id current-max) ERR-MAX-CAMPAIGNS-EXCEEDED)
    (try! (validate-goal goal))
    (try! (validate-deadline deadline))
    (try! (validate-title title))
    (try! (validate-description description))
    (try! (validate-min-donation min-donation))
    (try! (validate-token-type token-type))
    (try! (validate-category category))
    (try! (validate-milestones milestones))
    (try! (validate-refund-policy refund-policy))
    (try! (validate-kyc-required kyc-required))
    (try! (validate-max-donors max-donors))
    (try! (validate-location location))
    (try! (validate-tags tags))
    (try! (validate-image-hash image-hash))
    (try! (validate-video-hash video-hash))
    (try! (validate-website website))
    (try! (validate-email email))
    (try! (validate-phone phone))
    (try! (validate-social-links social-links))
    (try! (validate-team-members team-members))
    (try! (validate-budget-breakdown budget-breakdown))
    (map-set campaigns next-id
      {
        goal: goal,
        raised: u0,
        deadline: deadline,
        start-time: block-height,
        active: true,
        creator: tx-sender,
        title: title,
        description: description,
        min-donation: min-donation,
        token-type: token-type,
        category: category,
        status: "active",
        milestones: milestones,
        refund-policy: refund-policy,
        kyc-required: kyc-required,
        max-donors: max-donors,
        location: location,
        tags: tags,
        image-hash: image-hash,
        video-hash: video-hash,
        website: website,
        email: email,
        phone: phone,
        social-links: social-links,
        team-members: team-members,
        budget-breakdown: budget-breakdown
      })
    (map-set campaigns-by-creator tx-sender (append creator-campaigns next-id))
    (var-set next-campaign-id (+ next-id u1))
    (print { event: "campaign-created", id: next-id })
    (ok next-id))
)

(define-public (update-campaign
  (campaign-id uint)
  (new-goal uint)
  (new-deadline uint)
  (new-description (string-utf8 1000)))
  (let (
        (campaign (map-get? campaigns campaign-id))
      )
    (match campaign
      c
        (begin
          (asserts! (is-eq (get creator c) tx-sender) ERR-NOT-AUTHORIZED)
          (asserts! (get active c) ERR-CAMPAIGN-CLOSED)
          (try! (validate-goal new-goal))
          (try! (validate-deadline new-deadline))
          (try! (validate-description new-description))
          (map-set campaigns campaign-id
            (merge c {
              goal: new-goal,
              deadline: new-deadline,
              description: new-description
            }))
          (map-set campaign-updates campaign-id
            {
              update-goal: new-goal,
              update-deadline: new-deadline,
              update-description: new-description,
              update-timestamp: block-height,
              updater: tx-sender
            })
          (print { event: "campaign-updated", id: campaign-id })
          (ok true))
      ERR-CAMPAIGN-NOT-FOUND))
)

(define-public (close-campaign (campaign-id uint))
  (let (
        (campaign (map-get? campaigns campaign-id))
      )
    (match campaign
      c
        (begin
          (asserts! (is-eq (get creator c) tx-sender) ERR-NOT-AUTHORIZED)
          (asserts! (get active c) ERR-CAMPAIGN-CLOSED)
          (map-set campaigns campaign-id
            (merge c { active: false, status: "closed" }))
          (print { event: "campaign-closed", id: campaign-id })
          (ok true))
      ERR-CAMPAIGN-NOT-FOUND))
)

(define-public (add-raised (campaign-id uint) (amount uint))
  (let (
        (campaign (map-get? campaigns campaign-id))
      )
    (match campaign
      c
        (begin
          (asserts! (is-some (var-get governance-contract)) ERR-NOT-AUTHORIZED)
          (asserts! (is-eq tx-sender (unwrap! (var-get governance-contract) ERR-NOT-AUTHORIZED)) ERR-NOT-AUTHORIZED)
          (asserts! (get active c) ERR-CAMPAIGN-CLOSED)
          (asserts! (< block-height (get deadline c)) ERR-DEADLINE-PASSED)
          (map-set campaigns campaign-id
            (merge c { raised: (+ (get raised c) amount) }))
          (ok true))
      ERR-CAMPAIGN-NOT-FOUND))
)

(define-public (get-campaign-count)
  (ok (var-get next-campaign-id))
)