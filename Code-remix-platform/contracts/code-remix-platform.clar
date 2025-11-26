;; Code Remix Platform - Distributed coding project sharing

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-already-exists (err u103))
(define-constant err-invalid-input (err u104))
(define-constant err-insufficient-balance (err u105))
(define-constant err-project-locked (err u106))

;; Data Variables
(define-data-var total-projects uint u0)
(define-data-var total-remixes uint u0)
(define-data-var total-comments uint u0)
(define-data-var platform-fee uint u100)

;; Data Maps
(define-map projects
    { project-id: uint }
    {
        title: (string-ascii 100),
        description: (string-ascii 500),
        creator: principal,
        repo-uri: (string-ascii 256),
        language: (string-ascii 30),
        remix-count: uint,
        upvotes: uint,
        created-at: uint,
        is-locked: bool,
        tags: (string-ascii 100)
    }
)

(define-map remixes
    { remix-id: uint }
    {
        original-project-id: uint,
        remixer: principal,
        repo-uri: (string-ascii 256),
        changes-description: (string-ascii 500),
        created-at: uint,
        upvotes: uint
    }
)

(define-map developer-profiles
    { developer: principal }
    {
        username: (string-ascii 50),
        projects-created: uint,
        remixes-made: uint,
        total-upvotes: uint,
        reputation-score: uint,
        bio: (string-ascii 200)
    }
)

(define-map project-upvotes
    { project-id: uint, upvoter: principal }
    { upvoted: bool }
)

(define-map remix-upvotes
    { remix-id: uint, upvoter: principal }
    { upvoted: bool }
)

(define-map project-collaborators
    { project-id: uint, collaborator: principal }
    { approved: bool, role: (string-ascii 20) }
)

(define-map project-comments
    { comment-id: uint }
    {
        project-id: uint,
        commenter: principal,
        content: (string-ascii 500),
        created-at: uint
    }
)

(define-map project-tags
    { tag: (string-ascii 30) }
    { project-count: uint }
)

(define-map project-stars
    { project-id: uint }
    { star-count: uint }
)

;; Read-only functions
;; #[allow(unchecked_data)]
(define-read-only (get-project (project-id uint))
    (map-get? projects { project-id: project-id })
)

;; #[allow(unchecked_data)]
(define-read-only (get-remix (remix-id uint))
    (map-get? remixes { remix-id: remix-id })
)

;; #[allow(unchecked_data)]
(define-read-only (get-developer-profile (developer principal))
    (map-get? developer-profiles { developer: developer })
)

;; #[allow(unchecked_data)]
(define-read-only (has-upvoted (project-id uint) (upvoter principal))
    (default-to false (get upvoted (map-get? project-upvotes { project-id: project-id, upvoter: upvoter })))
)

;; #[allow(unchecked_data)]
(define-read-only (has-upvoted-remix (remix-id uint) (upvoter principal))
    (default-to false (get upvoted (map-get? remix-upvotes { remix-id: remix-id, upvoter: upvoter })))
)

;; #[allow(unchecked_data)]
(define-read-only (get-total-projects)
    (ok (var-get total-projects))
)

;; #[allow(unchecked_data)]
(define-read-only (get-total-remixes)
    (ok (var-get total-remixes))
)

;; #[allow(unchecked_data)]
(define-read-only (get-total-comments)
    (ok (var-get total-comments))
)

;; #[allow(unchecked_data)]
(define-read-only (get-platform-fee)
    (ok (var-get platform-fee))
)

;; #[allow(unchecked_data)]
(define-read-only (get-project-comment (comment-id uint))
    (map-get? project-comments { comment-id: comment-id })
)

;; #[allow(unchecked_data)]
(define-read-only (get-collaborator-status (project-id uint) (collaborator principal))
    (map-get? project-collaborators { project-id: project-id, collaborator: collaborator })
)

;; #[allow(unchecked_data)]
(define-read-only (get-project-stars (project-id uint))
    (default-to u0 (get star-count (map-get? project-stars { project-id: project-id })))
)

;; #[allow(unchecked_data)]
(define-read-only (get-tag-stats (tag (string-ascii 30)))
    (map-get? project-tags { tag: tag })
)