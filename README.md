# from-template 

This package `from-template` allows users to quickly set up a working template for a variety of Racket projects.
It works by adding a new `raco` command `from-template` that downloads a repo from 
[github.com/racket-templates](https://github.com/racket-templates) and removing the git history 
from the project so you get a fresh start.

# Install

1. [Set your PATH environment variable](https://github.com/racket/racket/wiki/Set-your-PATH-environment-variable) 
so you can use `raco` and other Racket command line functions.
2. either look for `from-template` in the DrRacket menu **File|Package Manager**, or run the `raco` command:
```bash
raco pkg install from-template
```

# Usage 
```bash
raco from-template <template-name> <destination-dir>
```
OR 
```bash
raco new <template-name> <destination-dir>
```

# Contributing to this project

Contibutions to both this tool and the collection of templates is welcome.

Contribute to this project by submitting a pull request or reporting an issue. Discussion on [Racket Users mailing list](https://groups.google.com/forum/#!forum/racket-users/join) ([google group](https://groups.google.com/forum/#!forum/racket-users)),
[#racket IRC on freenode.net](https://botbot.me/freenode/racket/) or [Racket Slack](https://racket-slack.herokuapp.com/).

Comtribute a new template by using the template at https://github.com/racket-templates/template-template 

# License

This package is free software, see [LICENSE](https://github.com/nixin72/from-template/blob/master/LICENSE) for more details.

By making a contribution, you are agreeing that your contribution is licensed under the Apache 2.0 license and the MIT license.

## get started

```
git clone git@github:nixin72/from-template.git
cd from-template 
raco pkg install 
```
