module ReviseTests

using Revise
using Test

import Revise: entr

"""
    track(modules, entries = [ r".*" ]; kwars...)

This function accepts a vector of files that must be re-executed if `Revise` detects an update in any code in modules provided in `modules` or in the files themselves.
Re-execution happens with a simple `include()` call. 

- entries: a vector (or any iterable really) of files that need re-execution on code update

A single entry can be:
- a full path to the file, in which case no further modification is made to the entry (uses `isfile`)
- a string, which is not a path. In this case the function tries to find all tests in the `test/` folder that include the provided string in its path (uses `occursin`).
- a regexp, same as the previous one, but uses the regexp instead of a simple string.

Uses `pathof` to get the path to a module.
Internally uses `Revise.entr`, `kwargs...` are the same as in the `Revise.entr`.

If an error occurs in one of the files the function picks up the first `TestSetException` error and displays a very limited 
version of the stacktrace.

Ctrl-C stops tracking and exits the function.
"""
function track end

track(mod::Module, entries = [ r".*" ]) = track([ mod ], entries)

function track(modules, entries = [ r".*" ]; kwargs...)
    files = preprocess_entries(modules, entries)

    for file in files 
        @info "Added the $file in the exection list"
    end

    Revise.entr(files, modules; kwargs...) do 
        ReviseTests.include_files(files)
    end

    @info "Stopping re-execution..."

    return nothing
end

# Returns a list of full paths to files that should be re-executed
function preprocess_entries(modules, entries)
    files = String[]
    files = append_tests!(files, modules, filter(!r_isfile, entries))
    for path in filter(r_isfile, entries)
        push!(files, path::String)
    end
    return files
end

# 'Safe' alternative to the `isfile` that accepts `Regex` as its input. Returns false for `Regex`.
r_isfile(path::String) = isfile(path)
r_isfile(pattern::Regex) = false

# Tries to find tests associated with `entries`
# Each entry can be either a string or a regex, `occursin` is used in both cases.
function append_tests!(files, modules, entries)
    if iszero(length(entries))
        return files
    end
    for mod in modules
        modpath = dirname(pathof(mod))
        # second `dirname` is needed, as it removes the `src`
        testdir = joinpath(dirname(modpath), "test")
        for (root, _, dirfiles) in walkdir(testdir)
            for testfile in dirfiles
                testpath = joinpath(root, testfile)
                found = false
                for entry in entries
                    # Check if the path contains the `entry`, could be a String or Regexp
                    if occursin(entry, testpath)
                        found = true
                        push!(files, testpath)
                    end
                    # Do not add duplicate entries
                    if found 
                        break
                    end
                end
            end
        end
    end
    return files
end

# `include`s files and returns a vector of errors (if any)
function include_files(files)
    errors = []
    for file in files 
        try 
            @info "Running file $file..."
            @eval Module() Base.include(@__MODULE__, $file)
        catch error 
            @error error
            push!(errors, error)
        end
    end
    if !isempty(errors)
        index = findfirst((e) -> e isa LoadError && e.error isa TestSetException, errors)
        if !isnothing(index)
            error = errors[index]
            show(stdout, first(error.error.errors_and_fails))
        end
    end
    return nothing
end

end
