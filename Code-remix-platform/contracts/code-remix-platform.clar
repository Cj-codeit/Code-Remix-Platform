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