#lang racket/base

(require racket/system
         racket/match)

(define [clone-repo repo-name dir-name]
  (system (string-append "bash ./from-template.sh " repo-name " " dir-name)))

(match (current-command-line-arguments)
  [(vector repo dir)
   (clone-repo repo dir)]
  [(vector repo)
   (clone-repo repo repo)]
  [(vector)
   (error "Need to supply a name of a template. Checkout https://github.com/racket-templates for a list of available templates.")]
  [_ (error "Too many arguments supplied. Command should be in form `raco from-template <template-name> <dir-name>`")])
