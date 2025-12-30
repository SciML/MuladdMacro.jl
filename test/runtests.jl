using MuladdMacro, Test

@testset "Quality Assurance" include("qa.jl")

# Basic expressions
@testset "Basic expressions" begin
    @testset "Summation" begin
        @test @macroexpand(@muladd a * b + c) == :($(Base.muladd)(a, b, c))
        @test @macroexpand(@muladd c + a * b) == :($(Base.muladd)(a, b, c))
        @test @macroexpand(@muladd b * a + c) == :($(Base.muladd)(b, a, c))
        @test @macroexpand(@muladd c + b * a) == :($(Base.muladd)(b, a, c))
    end

    @testset "Subtraction" begin
        @test @macroexpand(@muladd a * b - c) == :($(Base.muladd)(a, b, -c))
        @test @macroexpand(@muladd a - b * c) == :($(Base.muladd)(-b, c, a))
        @test @macroexpand(@muladd b * a - c) == :($(Base.muladd)(b, a, -c))
        @test @macroexpand(@muladd a - c * b) == :($(Base.muladd)(-c, b, a))
    end
end

# Additional factors
@testset "Additional factors" begin
    @testset "Summation" begin
        @test @macroexpand(@muladd a * b * c + d) == :($(Base.muladd)(a * b, c, d))
        @test @macroexpand(@muladd a * b * c * d + e) == :($(Base.muladd)(a * b * c, d, e))
    end

    @testset "Subtraction" begin
        @test @macroexpand(@muladd a * b * c - d) == :($(Base.muladd)(a * b, c, -d))
        @test @macroexpand(@muladd a * b * c * d - e) == :($(Base.muladd)(a * b * c, d, -e))
        @test @macroexpand(@muladd a - b * c * d) == :($(Base.muladd)(-(b * c), d, a))
        @test @macroexpand(@muladd a - b * c * d * e) ==
              :($(Base.muladd)(-(b * c * d), e, a))
    end
end

# Multiple multiplications
@testset "Multiple multiplications" begin
    @testset "Summation" begin
        @test @macroexpand(@muladd a * b + c * d) == :($(Base.muladd)(c, d, a * b))
        @test @macroexpand(@muladd a * b + c * d + e * f) ==
              :($(Base.muladd)(e, f, $(Base.muladd)(c, d, a * b)))
        @test @macroexpand(@muladd a * (b * c + d) + e) ==
              :($(Base.muladd)(a, $(Base.muladd)(b, c, d), e))

        @test @macroexpand(@muladd +a) == :(+a)
    end

    @testset "Subtraction" begin
        @test @macroexpand(@muladd a * b - c * d) == :($(Base.muladd)(-c, d, a * b))
        @test @macroexpand(@muladd a * (b * c - d) - e) ==
              :($(Base.muladd)(a, $(Base.muladd)(b, c, -d), -e))

        @test @macroexpand(@muladd -a) == :(-a)
    end
end

# Dot calls
@testset "Dot calls" begin
    @testset "Summation" begin
        @test @macroexpand(@. @muladd a * b + c) == :($(Base.muladd).(a, b, c))
        @test @macroexpand(@muladd @. a * b + c) == :($(Base.muladd).(a, b, c))
        @test @macroexpand(@muladd a .* b + c) == :(a .* b + c)
        @test @macroexpand(@muladd a * b .+ c) == :(a * b .+ c)

        @test @macroexpand(@muladd .+(a .* b, c, d)) == :($(Base.muladd).(a, b, c .+ d))
        @test @macroexpand(@muladd @. a * b + c + d) == :($(Base.muladd).(a, b, (+).(c, d)))
        @test @macroexpand(@muladd @. a * b * c + d) == :($(Base.muladd).((*).(a, b), c, d))

        @test @macroexpand(@muladd f.(a) * b + c) == :($(Base.muladd)(f.(a), b, c))
        @test @macroexpand(@muladd a * f.(b) + c) == :($(Base.muladd)(a, f.(b), c))
        @test @macroexpand(@muladd a * b + f.(c)) == :($(Base.muladd)(a, b, f.(c)))

        @test @macroexpand(@muladd .+a) == :(.+a)
    end

    @testset "Subtraction" begin
        @test @macroexpand(@. @muladd a * b - c) == :($(Base.muladd).(a, b, -c))
        @test @macroexpand(@muladd @. a * b - c) == :($(Base.muladd).(a, b, (-).(c)))
        @test @macroexpand(@muladd a .* b - c) == :(a .* b - c)
        @test @macroexpand(@muladd a * b .- c) == :(a * b .- c)

        @test @macroexpand(@. @muladd a - b * c) == :($(Base.muladd).(-b, c, a))
        @test @macroexpand(@muladd @. a - b * c) == :($(Base.muladd).((-).(b), c, a))
        @test @macroexpand(@muladd a - b .* c) == :(a - b .* c)
        @test @macroexpand(@muladd a .- b * c) == :(a .- b * c)

        @test @macroexpand(@muladd .-a) == :(.-a)
    end
end

# Nested expressions
@testset "Nested expressions" begin
    @test Base.remove_linenums!(@macroexpand(@muladd f(x, y, z) = x * y + z)) ==
          Base.remove_linenums!(:(f(x, y, z) = $(Base.muladd)(x, y, z)))
    @test Base.remove_linenums!(@macroexpand(@muladd function f(x, y, z)
        x * y + z
    end)) ==
          Base.remove_linenums!(:(
        function f(x, y, z)
        $(Base.muladd)(x, y, z)
    end))
    @test Base.remove_linenums!(@macroexpand(@muladd(for i in 1:n
        z = x * i + y
    end))) ==
          Base.remove_linenums!(:(for i in 1:n
        z = $(Base.muladd)(x, i, y)
    end))
end

# Test to_muladd export and functionality
@testset "to_muladd function" begin
    # Test that to_muladd is exported
    @test isdefined(MuladdMacro, :to_muladd)
    @test to_muladd === MuladdMacro.to_muladd

    # Test that to_muladd transforms expressions structurally
    result = to_muladd(:(a * b + c))
    @test result.head == :call
    @test result.args[2] == :a
    @test result.args[3] == :b
    @test result.args[4] == :c

    # Verify the function being called is Base.muladd
    # The first arg is an Expr with head :quote containing Base.muladd
    @test result.args[1].head == :quote
    @test result.args[1].args[1] === Base.muladd

    # Test expression without multiplication stays unchanged
    @test to_muladd(:(a + b)) == :(a + b)
end

# Test include with to_muladd transformation
@testset "include with to_muladd" begin
    # Create a temporary file to test include(to_muladd, "file.jl")
    testfile = tempname() * ".jl"
    try
        write(testfile, """
        function test_muladd_include(a, b, c)
            return a * b + c
        end
        """)

        # Include with transformation
        include(to_muladd, testfile)

        # Test that the function works correctly
        @test test_muladd_include(2.0, 3.0, 4.0) == 10.0
    finally
        isfile(testfile) && rm(testfile)
    end
end

# Allocation tests - run in separate group to avoid interference with precompilation
if get(ENV, "GROUP", "all") == "all" || get(ENV, "GROUP", "all") == "nopre"
    @testset "Allocation Tests" begin
        include("alloc_tests.jl")
    end
end
