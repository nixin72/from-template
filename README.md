# from-template 

Download a repo from github.com/racket-templates to use for your project. It removes the git history from the project so you get a fresh start. 

**Note:** This only works on Linux. If you'd like to submit a PR to make it work on Windows too, I'd be more than happy to merge it in.

# Download 
```
git clone git@github:nixin72/from-template.git
cd from-template 
raco pkg install 
```

If the racket-templates org gets populated with enough stuff, I'll add this to the Racket packages repository.

# Usage 
```
raco from-template <template-name> <destination-dir>
```
