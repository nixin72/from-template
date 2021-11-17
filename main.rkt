#lang racket/base

(require racket/system
         racket/match
         racket/file
         racket/port
         racket/list
         racket/string
         racket/cmdline
         racket/set
         racket/runtime-path
         net/http-easy)

(define-runtime-path windows-script "from-template.bat")
(define-runtime-path macosx-script "from-template.sh")
(define-runtime-path linux-script "from-template.sh")

(define normal "\033[0m")
(define [color color strs] (string-append color (string-join strs " ") normal))
(define [bold . strings] (color "\033[0;1m" strings))

(define listing? (make-parameter #f))
(define interactive? (make-parameter #f))
(define template (make-parameter null))
(define output-dir (make-parameter null))
(define version-num (make-parameter "1.1.0"))
(define description (make-parameter ""))
(define entry-point (make-parameter "main.rkt"))
(define ssh? (make-parameter #f))
(define git-repo (make-parameter ""))
(define git-init? (make-parameter #f))
(define author (make-parameter ""))
(define license (make-parameter "MIT"))

(define api-url "https://api.github.com/repos/racket-templates/racket-templates/contents/templates")

(define too-few-arguments-error
  (string-append
   "Need to supply a name of a template.\n"
   "Command should be in form `raco new <template-name> [dir-name]`\n"
   "Checkout https://github.com/racket-templates for a list of available templates."))

(define too-many-arguments-error
  (string-append
   "Too many arguments supplied.\n"
   "Command should be in form `raco new <template-name> [dir-name]`"))

(define [clone-repo repo-name dir-name]
  (define protocol (if ssh? "git@github.com:" "https://github.com/"))
  (case (system-type 'os)
    [(unix)
     (system (string-append "bash " (path->string linux-script) " " protocol " " repo-name " " dir-name))]
    [(macosx)
     (system (string-append "bash " (path->string macosx-script) " " protocol " " repo-name " " dir-name))]
    [(windows)
     (system (string-append (path->string windows-script) " " protocol " " repo-name " " dir-name))]))

(define [existing-options-in-info-rkt]
  (define file-path (build-path (current-directory) (output-dir) "info.rkt"))
  (if (file-exists? file-path)
      (call-with-input-string
       (string-append "(" (string-replace (file->string file-path) "#lang info" "") ")")
       (lambda (in) (read in)))
      '()))

(define [first-where predicate lst]
  (car (filter predicate lst)))

(define [write-to-info-file info-rkt-new]
  (define file-path (string-append (output-dir) "/info.rkt"))
  (define info-rkt-old (existing-options-in-info-rkt))
  (define options-old (map (lambda (x) (second x)) info-rkt-old))
  (define options-new (map (lambda (x) (second x)) info-rkt-new))

  (display-to-file "#lang info.rkt\n\n"
                   file-path
                   #:exists 'replace)
  (for ([opt (list->set (append options-new options-old))])
    (let ([i1 (index-of options-old opt)]
          [i2 (index-of options-new opt)])
      (with-output-to-file file-path #:exists 'append
        (lambda ()
          (define line (if i2
                           (list-ref info-rkt-new i2)
                           (list-ref info-rkt-old i1)))
          (displayln (list 'define (second line) (string-replace (format "~v" (third line)) "''" "'"))))))))

(define [stringify str]
  (if (string=? str "")
      "\"\""
      (string-append "\"" str "\"")))

(define [stringify-or-empty str]
  (if (string=? str "")
      ""
      (string-append "\"" str "\"")))

(define [to-error-or-not-to-error? error-message interactive?]
  (unless interactive?
    (displayln error-message)
    (exit)))

(define [get-template file-url]
  (with-input-from-string
    (bytes->string/utf-8 (response-body (get file-url)))
    (λ ()
      (define template (apply hash (read)))
      (displayln
       (string-append (bold (symbol->string (hash-ref template 'name)))
                      (if (hash-has-key? template 'desc)
                          (string-append "\n" (hash-ref template 'desc))
                          ""))))))

;; This is super naive. What should happen is that whenever a new template gets added to the
;; template archive the description for that template gets compiled into a big list of
;; templates and then this checks against that one list instead of making a bunch of different
;; HTTP requests to get the contents of all of these files. It's slow.
(define [list-templates query]
  (map (lambda (x)
         (define file-url (hash-ref x 'download_url))
         (cond
           [(empty? query) (get-template file-url)]
           [(string-contains? file-url (first query)) (get-template file-url)]
           ))
       (response-json
        (get api-url))))

(define [get-template-repo template-name]
  (with-input-from-bytes
    (response-body
     (get (string-append
           "https://raw.githubusercontent.com/racket-templates/racket-templates/main/templates/"
           template-name)))
    (λ ()
      (hash-ref (apply hash (read)) 'repo))))

(define cli-args
  (command-line
   #:program "from-template"
   #:once-any
   [("-l" "--list")
    "Lists all available templates to clone"
    (listing? #t)]
   [("-s" "--ssh")
    "Clone over ssh instead of https"
    (ssh? #t)]
   #:args args
   (with-handlers ([exn:break?
                    (lambda (e)
                      (displayln "\n\nProject creation aborted by user.")
                      (exit))]
                   [exn?
                    (lambda (e)
                      (displayln e)
                      (displayln "\n\nHmm, an unexpected error has occured...")
                      (displayln "If you'd like, we'd really appreciate it if you filed a bug report at")
                      (displayln "https://github.com/nixin72/from-template/issues/new")
                      (displayln "\nSorry for the inconvenience, please try again and change up your options if the problem persists."))])
     (cond
       [(listing?) (list-templates args)]
       [else
        (match args
          [(list repo dir)
           (template (get-template-repo repo))
           (output-dir dir)]
          [(list repo)
           (template (get-template-repo repo))
           (output-dir repo)]
          ;; Errors
          [(list) (to-error-or-not-to-error? too-few-arguments-error (interactive?))]
          [_ (displayln too-many-arguments-error)
             (exit)])
        (clone-repo (template) (output-dir))
        ]))))

(module test racket/base)
