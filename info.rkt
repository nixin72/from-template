#lang info

(define collection "from-template")
(define version "1.1")
(define pkg-authors '(nixin72))
(define pkg-desc "Download template apps to get started building new projects with Racket")
(define scribblings '(("scribblings/from-template.scrbl" ())))

(define deps
  '("base" "readline" "http-easy"))

(define build-deps
  '("racket-doc"
    "rackunit-lib"
    "scribble-lib"))

(define raco-commands
  '(("new"
     (submod from-template main)
     "Install a repo from a template at racket-templates" 50)
    ("from-template"
     (submod from-template main)
     "Install a repo from a template at racket-templates" 50)))
