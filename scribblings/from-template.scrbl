#lang scribble/manual

@title{from-template}

@author{nixin72}

This package adds the capability to create new Racket application from a set of pre-built, but working,
starter templates hosted at
@hyperlink["https://github.com/racket-templates"]{https://github.com/racket-templates}.

The @tt{from-template} command this package adds to the Racket @tt{raco} command line tools clones the
chosen template and removes the git history to provide you with a fresh start.

All templates are use non-restrictive Apache2/MIT licences so you can use them in your own project freely.

@section{Download/Install}

In DrRacket, in File|Package manager|Source, enter @tt{from-template}.

Or, on the command line, type:

@tt{raco pkg install from-template}


@section{Usage}

Note: If you haven't already done so,
@hyperlink["https://github.com/racket/racket/wiki/Set-your-PATH-environment-variable"]{Set
 your PATH environment variable} so you can use raco and other Racket command line functions.

For a list of available templates type

@tt{% raco new}

Install a template by including the template name and a destination folder.

@tt{% raco new <template-name> <destination-dir>}

If no destination path is provided the template is installed in the current folder.

@tt{% raco new <template-name>}


The legacy command is still available;

@tt{% raco from-template <template-name> <destination-dir>}




