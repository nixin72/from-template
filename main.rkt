#lang racket/base

(require racket/system
         racket/match
         racket/cmdline
         racket/path
         racket/runtime-path)

(define-runtime-path windows-script "from-template.bat")

(define-runtime-path macosx-script "from-template.sh")

(define [clone-repo repo-name dir-name]
  (case (system-type 'os)
    [(unix)
     (system (string-append "bash ./from-template.sh " repo-name " " dir-name))]
    [(macosx)
     (system (string-append "bash " (path->string macosx-script) " " repo-name " " dir-name))]
    [(windows)
     (system (string-append (path->string windows-script) " " repo-name " " dir-name))]))

(define too-few-arguments-error
  (string-append
   "Need to supply a name of a template. "
   "Checkout https://github.com/racket-templates for a list of available templates."))
(define too-many-arguments-error
  (string-append
   "Too many arguments supplied. "
   "Command should be in form `raco from-template <template-name> <dir-name>`"))

(define interactive? (make-parameter #f))
(define template (make-parameter null))
(define output-dir (make-parameter null))

(define cli-args
  (command-line
   #:program "from-template"
   #:once-each
   [("-i" "--interactive") "Allows you to modify the instantiated directory interactively"
                           (interactive? #t)]
   #:args args
   (let ([success?]
         (match args
          [(list repo dir) ; Clone repo using new directory name
           (clone-repo repo dir)]
          [(list repo) ; Clone repo without changing output location
           (clone-repo repo repo)]
          ;; Errors
          [(list) (error too-few-arguments-error)]
          [_ (error too-many-arguments-error)]))
     (println interactive?))))

(module test racket/base)
