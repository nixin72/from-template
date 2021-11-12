#lang racket/base

(require racket/system
         racket/match
         racket/file
         racket/port
         racket/list
         racket/string
         racket/cmdline
         racket/path
         racket/set
         racket/runtime-path
         readline/readline)

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
   "Checkout https://github.com/racket-templates for a list of available templates."))
(define too-many-arguments-error
  (string-append
   "Too many arguments supplied.\n"
   "Command should be in form `raco from-template [-i] <template-name> <dir-name>`"))

(define [clone-repo repo-name dir-name]
  (case (system-type 'os)
    [(unix)
     (system (string-append "bash " (path->string linux-script) " " repo-name " " dir-name))]
    [(macosx)
     (system (string-append "bash " (path->string macosx-script) " " repo-name " " dir-name))]
    [(windows)
     (system (string-append (path->string windows-script) " " repo-name " " dir-name))]))

(define [readline-with-default prompt default]
  (let ([input (readline (if (or (string=? default "")
                                 (string=? default "\"\""))
                            prompt
                            (string-append prompt "(" default ") ")))])
    (when (string=? default "\"\"")
      (set! default ""))
    (when (string=? input "")
      (set! input default))
    (string-trim input)))

(define [readline-yes-or-no prompt default?]
  (let* ([default (if default? "(Y/n)" "(y/N)")]
         [input (readline (string-append prompt default " "))])
    (cond [(string=? input "") default?]
          [(char-ci=? (string-ref input 0) #\y) #t]
          [(char-ci=? (string-ref input 0) #\n) #f]
          [else default?])))

(define [readline-required-input prompt]
  (let loop ([input (readline prompt)])
    (if (equal? input "")
        (begin (println "You must provide input for this field.")
               (loop (readline prompt)))
        (string-trim input))))

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

(define [read-arguments-interactively args]
  (displayln "This tool will walk you through creating a new project from a Racket template.")
  (displayln "Press ^C at any time to quit")
  (displayln "")

  (match args
    [(list)
     (template (readline-required-input "template: "))
     (output-dir (readline-with-default "output dir: " (template)))]
    [(list _)
     (output-dir (readline-with-default "output dir: " (template)))]
    [_ (void)])

  (version-num (readline-with-default "version: " "1.0.0"))
  (description (readline-with-default "description: " "\"\""))
  (entry-point (readline-with-default "entry point: " "main.rkt"))
  (git-repo (readline-with-default "git repository: " "\"\""))
  (when (string=? (git-repo) "")
    (git-init? (readline-yes-or-no "initialize git repo: " #t)))
  (author (readline-with-default "author: " ""))
  (license (readline-with-default "license: " "MIT"))

  (define info-rkt
    `((define collection ,(output-dir))
      (define version ,(version-num))
      (define pkg-desc ,(description))
      (define entry-point ,(entry-point))
      (define git-repository ,(git-repo))
      (define pkg-authors '(,(author)))
      (define license ,(license))))

  (if (clone-repo (template) (output-dir))
      (begin
       (write-to-info-file info-rkt)
       (when (git-init?)
         (system (string-append "cd " (output-dir) "; git init;"))))
      (error "A fatal error occured when trying to clone the repository.")))

(define [to-error-or-not-to-error? error-message interactive?]
  (unless interactive?
    (displayln error-message)
    (exit)))

(define cli-args
  (command-line
   #:program "from-template"
   #:once-each
   [("-i" "--interactive")
    "Allows you to modify the instantiated directory interactively"
    (interactive? #t)]
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
    (if (interactive?)
        (read-arguments-interactively args)
        (clone-repo (template) (output-dir))))))
       
(module test racket/base)
