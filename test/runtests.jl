module ReviseTestsTests 

using ReviseTests
using Test
using Logging

@testset "ReviseTests.jl" begin

    thisfile = @__FILE__
    dummyfile1 = joinpath(dirname(thisfile), "file1.jl")

    @testset "preprocess_entries" begin
        import ReviseTests: preprocess_entries


        @test preprocess_entries([ReviseTests], []) == []
        @test preprocess_entries([ReviseTests], [dummyfile1]) == [dummyfile1]
        @test preprocess_entries([ReviseTests], ["file1"]) == [dummyfile1]
        @test preprocess_entries([ReviseTests], ["runtests"]) == [thisfile]
        @test preprocess_entries([ReviseTests], ["runtests", "runtests"]) == [thisfile]
        @test preprocess_entries([ReviseTests], [r"run.*sts"]) == [thisfile]
        @test preprocess_entries([ReviseTests], [r"run.*sts", "runtests"]) == [thisfile]

    end

    @testset "include_files" begin
        import ReviseTests: include_files

        io = IOBuffer()
        logger = SimpleLogger(io)

        with_logger(logger) do
            include_files([dummyfile1])
        end

        @test occursin("Hello world!", String(take!(io)))

    end


end

end
