using AllocCheck
using MuladdMacro
using Test

# Test that @muladd-generated code is allocation-free at runtime
# Note: The macro transformation happens at compile time, but the resulting
# code (muladd calls) should have zero allocations at runtime

@testset "Runtime Allocation Tests" begin
    # Simple muladd: a + b*c
    @check_allocs muladd_simple(a::Float64, b::Float64, c::Float64) = @muladd a + b * c

    @testset "Simple muladd" begin
        result = muladd_simple(1.0, 2.0, 3.0)
        @test result == 7.0  # 1.0 + 2.0*3.0 = 7.0
    end

    # Multiple muladd: a + b*c + d*e
    @check_allocs muladd_multiple(a::Float64, b::Float64, c::Float64, d::Float64, e::Float64) = @muladd a + b * c + d * e

    @testset "Multiple muladd" begin
        result = muladd_multiple(1.0, 2.0, 3.0, 4.0, 5.0)
        @test result == 27.0  # 1.0 + 2.0*3.0 + 4.0*5.0 = 27.0
    end

    # Subtraction muladd: a - b*c
    @check_allocs muladd_sub(a::Float64, b::Float64, c::Float64) = @muladd a - b * c

    @testset "Subtraction muladd" begin
        result = muladd_sub(10.0, 2.0, 3.0)
        @test result == 4.0  # 10.0 - 2.0*3.0 = 4.0
    end

    # Nested muladd: a*(b*c + d) + e
    @check_allocs muladd_nested(a::Float64, b::Float64, c::Float64, d::Float64, e::Float64) = @muladd a * (b * c + d) + e

    @testset "Nested muladd" begin
        result = muladd_nested(2.0, 3.0, 4.0, 5.0, 6.0)
        @test result == 40.0  # 2.0*(3.0*4.0 + 5.0) + 6.0 = 2.0*17.0 + 6.0 = 40.0
    end

    # Complex expression with multiple terms
    @check_allocs muladd_complex(a::Float64, b::Float64, c::Float64, d::Float64) = @muladd a * b + c * d

    @testset "Complex muladd" begin
        result = muladd_complex(1.0, 2.0, 3.0, 4.0)
        @test result == 14.0  # 1.0*2.0 + 3.0*4.0 = 14.0
    end
end
