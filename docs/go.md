# format slice

```
fmt.Printf("%v\n", []string{"1", "2"}) // Output [1, 2]
```

# go get with wildcard

From `go help packages`

> To make common patterns more convenient, there are two special cases.
> First, /... at the end of the pattern can match an empty string,
> so that net/... matches both net and packages in its subdirectories, like net/http.
> Second, any slash-separated pattern element containing a wildcard never
> participates in a match of the "vendor" element in the path of a vendored
> package, so that ./... does not match packages in subdirectories of
> ./vendor or ./mycode/vendor, but ./vendor/... and ./mycode/vendor/... do.
> Note, however, that a directory named vendor that itself contains code
> is not a vendored package: cmd/vendor would be a command named vendor,
> and the pattern cmd/... matches it.
> See golang.org/s/go15vendor for more about vendoring.
