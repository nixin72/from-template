#lang info

(define collection "racket-package-template")

(define scribblings
  (list (list "main.scrbl"
              (list 'multi-page)
              (list 'library)
              "racket-package-template")))

(define deps
  (list "base"))

(define build-deps
  (list "racket-doc"
        "rackunit-lib"
        "scribble-lib"))

(define raco-commands
  '(("from-template" "main.rkt" "Install a repo from a template at racket-templates" 50)))
