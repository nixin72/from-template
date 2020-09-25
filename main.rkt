#lang racket/base

(require racket/system
         racket/match
         racket/file
         racket/string
         racket/cmdline
         racket/path
         racket/runtime-path
         readline/readline)

(define-runtime-path windows-script "from-template.bat")
(define-runtime-path macosx-script "from-template.sh")

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
   "Command should be in form `raco from-template <template-name> <dir-name>`"))

(define [clone-repo repo-name dir-name]
  (case (system-type 'os)
    [(unix)
     (system (string-append "bash ./from-template.sh " repo-name " " dir-name))]
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
         [input (readline (string-append prompt default))])
    (cond [(string=? input "") default?]
          [(string-ci=? (string-ref input 0) #\y) #t]
          [(string-ci=? (string-ref input 0) #\n) #f]
          [else default?])))

(define [readline-required-input prompt]
  (let loop ([input (readline prompt)])
    (if (equal? input "")
        (begin (println "You must provide input for this field.")
               (loop (readline prompt)))
        (string-trim input))))

(define [write-to-info-file info-rkt]
  (define file-path (string-append (output-dir) "/info.rkt"))
  (display-lines-to-file
   info-rkt
   file-path
   #:exists 'replace))

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

  (when (equal? args '())
    (template (readline-required-input "template: "))
    (output-dir (readline-with-default "Output dir: " (template))))
  
  (version-num (readline-with-default "version: " "1.0.0"))
  (description (readline-with-default "description: " "\"\""))
  (entry-point (readline-with-default "entry point: " "main.rkt"))
  (git-repo (readline-with-default "git repository: " "\"\""))
  (when (string=? (git-repo) "")
    (git-init? (readline-yes-or-no "initialize git repo: " #t)))
  (println (git-init?))
  (author (readline-with-default "author: " ""))
  (license (readline-with-default "license: " "MIT"))

  (define info-rkt
    (list
     "#lang info"
     (string-append "(define collection \"" (output-dir) "\")")
     (string-append "(define version \"" (version-num) "\")")
     (string-append "(define description " (stringify (description)) ")")
     (string-append "(define entry-point \"" (entry-point) "\")")
     (string-append "(define git-repository " (stringify (git-repo)) ")")
     (string-append "(define authors '(" (stringify-or-empty (author)) "))")
     (string-append "(define license \"" (license) "\")")))

  (when (clone-repo (template) (output-dir))
    (write-to-info-file info-rkt)
    (when (git-init?)
      (system (string-append "cd " (output-dir) "; git init;")))))

(define [to-error-or-not-to-error? error-message interactive?]
  (unless interactive?
    (displayln error-message)))

(define cli-args
  (command-line
   #:program "from-template"
   #:once-each
   [("-i" "--interactive")
    "Allows you to modify the instantiated directory interactively"
    (interactive? #t)]
   #:args args
   (begin
    (match args
     [(list repo dir)
      (template repo)
      (output-dir dir)]
     [(list repo)
      (template repo)
      (output-dir repo)]
     ;; Errors
     [(list) (to-error-or-not-to-error? too-few-arguments-error (interactive?))]
     [_ (displayln too-many-arguments-error)])
    (if (interactive?)
        (read-arguments-interactively args)
        (clone-repo (template) (output-dir))))))
       
(module test racket/base)
