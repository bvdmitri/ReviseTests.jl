# ReviseTests

[![Build Status](https://github.com/bvdmitri/ReviseTests.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/bvdmitri/ReviseTests.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/bvdmitri/ReviseTests.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/bvdmitri/ReviseTests.jl)
[![PkgEval](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/R/ReviseTests.svg)](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/report.html)

The package implements a helper function `ReviseTests.track`.

```
    track(modules, entries = [ r".*" ], use_test_env = true; kwars...)
```

This function accepts a vector of entries (files) that must be re-executed if `Revise` detects an update in any code in modules provided in `modules` or in the files themselves.
Re-execution happens with a simple `include()` call. 

- entries: a vector (or any iterable really) of files that need re-execution on code update
- use_test_env: (optional), if `true` calls `TestEnv.activate()` before start tracking

A single entry can be:
- a full path to the file, in which case no further modification is made to the entry (uses `isfile`)
- a string, which is not a path. In this case the function tries to find all tests in the `test/` folder that include the provided string in its path (uses `occursin`).
- a regexp, same as the previous one, but uses the regexp instead of a simple string.

Uses `pathof` to get the path to a module.
Internally uses `Revise.entr`, `kwargs...` are the same as in the `Revise.entr`.

If an error occurs in one of the files the function picks up the first `TestSetException` error and displays a very limited 
version of the stacktrace.

Ctrl-C stops tracking and exits the function.

### Typical use-cases

```julia
julia> using ReviseTests

julia> using MyPackage

julia> ReviseTests.track(MyPackage)
```
or
```julia
julia> ReviseTests.track(MyPackage, [ "specific_test" ])
```

The package is aimed to re-run tests, but can also re-run arbitrary files, e.g.

```julia
julia> using ReviseTests

julia> using MyPackage

julia> ReviseTests.track(MyPackage, [ "path/to/my/file" ])
```

For convenience the package provides the `@track` macro, that tries to figure out the current package in development automatically, e.g
calling 

```julia
julia> @track "path/to/myfile"
```

within `MyPackage` will be automatically transformed to

```julia
julia> ReviseTests.track(MyPackage, [ "path/to/my/file" ])
```

For the `@track` macro to work properly the package's folder must contain `.jl` in it, e.g `MyPackage.jl`.

The package itself has been tested with `ReviseTests`. Open an issue if I missed something!
