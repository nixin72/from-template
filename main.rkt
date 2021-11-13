#lang racket/base

(require racket/system
         racket/match
         racket/file
         racket/port
         racket/list
         racket/string
         racket/cmdline
         racket/set
         racket/runtime-path)

(define-runtime-path windows-script "from-template.bat")
(define-runtime-path macosx-script "from-template.sh")
(define-runtime-path linux-script "from-template.sh")


(define interactive? (make-parameter #f))
(define template (make-parameter null))
(define output-dir (make-parameter null))
(define version-num (make-parameter "1.0.0"))
(define description (make-parameter ""))
(define entry-point (make-parameter "main.rkt"))
(define git-repo (make-parameter ""))
(define git-init? (make-parameter #f))
(define author (make-parameter ""))
(define license (make-parameter "MIT"))

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
  (case (system-type 'os)
    [(unix)
     (system (string-append "bash " (path->string linux-script) " " repo-name " " dir-name))]
    [(macosx)
     (system (string-append "bash " (path->string macosx-script) " " repo-name " " dir-name))]
    [(windows)
     (system (string-append (path->string windows-script) " " repo-name " " dir-name))]))

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

(define cli-args
  (command-line
   #:program "from-template"
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
     (match args
       [(list repo dir)
        (template repo)
        (output-dir dir)]
       [(list repo)
        (template repo)
        (output-dir repo)]
       ;; Errors
       [(list) (to-error-or-not-to-error? too-few-arguments-error (interactive?))]
       [_ (displayln too-many-arguments-error)
          (exit)])
     (clone-repo (template) (output-dir)))))

(module test racket/base)
