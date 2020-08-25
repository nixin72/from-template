#lang racket/base

(require racket/system
         racket/match
         racket/path
         racket/runtime-path)

(define-runtime-path windows-script "from-template.bat")

(define [clone-repo repo-name dir-name]
  (if (eq? (system-type 'os) 'windows)
    (system (string-append (path->string windows-script) " " repo-name " " dir-name))
    (system (string-append "bash ./from-template.sh " repo-name " " dir-name))))

(match (current-command-line-arguments)
  [(vector repo dir)
   (clone-repo repo dir)]
  [(vector repo)
   (clone-repo repo repo)]
  [(vector)
   (error "Need to supply a name of a template. Checkout https://github.com/racket-templates for a list of available templates.")]
  [_ (error "Too many arguments supplied. Command should be in form `raco from-template <template-name> <dir-name>`")])
