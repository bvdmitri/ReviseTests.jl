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
        @test preprocess_entries([ReviseTests], [r".*runtests.*"]) == [thisfile]
        @test preprocess_entries([ReviseTests], [r".*runtests.*", "runtests"]) == [thisfile]
        :wa
        :qa

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

    @testset "@track" begin 
        basicusasge = string(@macroexpand @track)
        @test contains(basicusasge, "runtests.jl")
        @test contains(basicusasge, "using ReviseTests")
        @test contains(basicusasge, "ReviseTests.track(ReviseTests, [\"runtests.jl\"]")

        filesusasge = string(@macroexpand @track("asd1", "asd2"))
        @test !contains(filesusasge, "runtests.jl")
        @test contains(filesusasge, "using ReviseTests")
        @test contains(filesusasge, "ReviseTests.track(ReviseTests, [")
        @test contains(filesusasge, "asd1")
        @test contains(filesusasge, "asd2")
    end

end

end
