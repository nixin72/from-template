#lang info

(define collection "racket-package-template")

(define scribblings '(("scribblings/from-template.scrbl" ())))

(define deps
  '("base" "readline" "http-easy"))

(define build-deps
  '("racket-doc"
    "rackunit-lib"
    "scribble-lib"))

(define raco-commands
  '(("new" "main.rkt" "Install a repo from a template at racket-templates" 50)
    ("from-template" "main.rkt" "Install a repo from a template at racket-templates" 50)))
