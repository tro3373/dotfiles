# git tips.


## Add submodule

```
git submodule add git@github.com:account/repos.git path/to/repos
```

## Delete submodule

```
git submodule deinit path/to/submodule
git rm path/to/submodule

# If you use git version under v1.8.5
# and execute bellow too.
#   git config -f .gitmodules --remove-section submodule.path/to/submodule
```

