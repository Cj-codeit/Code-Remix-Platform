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

;; Public functions
;; #[allow(unchecked_data)]
(define-public (create-developer-profile (username (string-ascii 50)))
    (let ((existing-profile (map-get? developer-profiles { developer: tx-sender })))
        (if (is-some existing-profile)
            err-already-exists
            (ok (map-set developer-profiles
                { developer: tx-sender }
                { 
                    username: username, 
                    projects-created: u0, 
                    remixes-made: u0, 
                    total-upvotes: u0,
                    reputation-score: u0,
                    bio: ""
                }
            ))
        )
    )
)

;; #[allow(unchecked_data)]
(define-public (update-profile-bio (bio (string-ascii 200)))
    (let ((dev-profile (unwrap! (map-get? developer-profiles { developer: tx-sender }) err-not-found)))
        (ok (map-set developer-profiles
            { developer: tx-sender }
            (merge dev-profile { bio: bio })
        ))
    )
)

;; #[allow(unchecked_data)]
(define-public (share-project 
    (title (string-ascii 100)) 
    (description (string-ascii 500)) 
    (repo-uri (string-ascii 256)) 
    (language (string-ascii 30))
    (tags (string-ascii 100)))
    (let (
        (new-project-id (+ (var-get total-projects) u1))
        (dev-profile (unwrap! (map-get? developer-profiles { developer: tx-sender }) err-unauthorized))
    )
        (map-set projects
            { project-id: new-project-id }
            { 
                title: title, 
                description: description, 
                creator: tx-sender, 
                repo-uri: repo-uri,
                language: language, 
                remix-count: u0, 
                upvotes: u0, 
                created-at: stacks-block-height,
                is-locked: false,
                tags: tags
            }
        )
        (map-set developer-profiles
            { developer: tx-sender }
            (merge dev-profile { projects-created: (+ (get projects-created dev-profile) u1) })
        )
        (var-set total-projects new-project-id)
        (ok new-project-id)
    )
)

;; #[allow(unchecked_data)]
(define-public (create-remix 
    (original-project-id uint) 
    (repo-uri (string-ascii 256)) 
    (changes-description (string-ascii 500)))
    (let (
        (new-remix-id (+ (var-get total-remixes) u1))
        (project (unwrap! (map-get? projects { project-id: original-project-id }) err-not-found))
        (dev-profile (unwrap! (map-get? developer-profiles { developer: tx-sender }) err-unauthorized))
    )
        (asserts! (not (get is-locked project)) err-project-locked)
        (map-set remixes
            { remix-id: new-remix-id }
            {
                original-project-id: original-project-id,
                remixer: tx-sender,
                repo-uri: repo-uri,
                changes-description: changes-description,
                created-at: stacks-block-height,
                upvotes: u0
            }
        )
        (map-set projects
            { project-id: original-project-id }
            (merge project { remix-count: (+ (get remix-count project) u1) })
        )
        (map-set developer-profiles
            { developer: tx-sender }
            (merge dev-profile { remixes-made: (+ (get remixes-made dev-profile) u1) })
        )
        (var-set total-remixes new-remix-id)
        (ok new-remix-id)
    )
)

;; #[allow(unchecked_data)]
(define-public (upvote-project (project-id uint))
    (let (
        (project (unwrap! (map-get? projects { project-id: project-id }) err-not-found))
        (creator-profile (unwrap! (map-get? developer-profiles { developer: (get creator project) }) err-not-found))
        (already-upvoted (has-upvoted project-id tx-sender))
    )
        (asserts! (not already-upvoted) err-already-exists)
        (map-set project-upvotes
            { project-id: project-id, upvoter: tx-sender }
            { upvoted: true }
        )
        (map-set projects
            { project-id: project-id }
            (merge project { upvotes: (+ (get upvotes project) u1) })
        )
        (map-set developer-profiles
            { developer: (get creator project) }
            (merge creator-profile { 
                total-upvotes: (+ (get total-upvotes creator-profile) u1),
                reputation-score: (+ (get reputation-score creator-profile) u10)
            })
        )
        (ok true)
    )
)

;; #[allow(unchecked_data)]
(define-public (upvote-remix (remix-id uint))
    (let (
        (remix (unwrap! (map-get? remixes { remix-id: remix-id }) err-not-found))
        (already-upvoted (has-upvoted-remix remix-id tx-sender))
    )
        (asserts! (not already-upvoted) err-already-exists)
        (map-set remix-upvotes
            { remix-id: remix-id, upvoter: tx-sender }
            { upvoted: true }
        )
        (map-set remixes
            { remix-id: remix-id }
            (merge remix { upvotes: (+ (get upvotes remix) u1) })
        )
        (ok true)
    )
)

;; #[allow(unchecked_data)]
(define-public (add-collaborator (project-id uint) (collaborator principal) (role (string-ascii 20)))
    (let ((project (unwrap! (map-get? projects { project-id: project-id }) err-not-found)))
        (asserts! (is-eq tx-sender (get creator project)) err-unauthorized)
        (ok (map-set project-collaborators
            { project-id: project-id, collaborator: collaborator }
            { approved: true, role: role }
        ))
    )
)

;; #[allow(unchecked_data)]
(define-public (remove-collaborator (project-id uint) (collaborator principal))
    (let ((project (unwrap! (map-get? projects { project-id: project-id }) err-not-found)))
        (asserts! (is-eq tx-sender (get creator project)) err-unauthorized)
        (ok (map-delete project-collaborators { project-id: project-id, collaborator: collaborator }))
    )
)

;; #[allow(unchecked_data)]
(define-public (add-comment (project-id uint) (content (string-ascii 500)))
    (let (
        (new-comment-id (+ (var-get total-comments) u1))
        (project (unwrap! (map-get? projects { project-id: project-id }) err-not-found))
    )
        (map-set project-comments
            { comment-id: new-comment-id }
            {
                project-id: project-id,
                commenter: tx-sender,
                content: content,
                created-at: stacks-block-height
            }
        )
        (var-set total-comments new-comment-id)
        (ok new-comment-id)
    )
)

;; #[allow(unchecked_data)]
(define-public (star-project (project-id uint))
    (let (
        (project (unwrap! (map-get? projects { project-id: project-id }) err-not-found))
        (current-stars (get-project-stars project-id))
    )
        (ok (map-set project-stars
            { project-id: project-id }
            { star-count: (+ current-stars u1) }
        ))
    )
)