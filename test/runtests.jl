using MuladdMacro
using Test

# Basic expressions
@testset "Basic expressions" begin
    @test @macroexpand(@muladd a*b+c) == :($(Base.muladd)(a, b, c))
    @test @macroexpand(@muladd c+a*b) == :($(Base.muladd)(a, b, c))
    @test @macroexpand(@muladd b*a+c) == :($(Base.muladd)(b, a, c))
    @test @macroexpand(@muladd c+b*a) == :($(Base.muladd)(b, a, c))
end

# Additional factors
@testset "Additional factors" begin
    @test @macroexpand(@muladd a*b*c+d) == :($(Base.muladd)(a*b, c, d))
    @test @macroexpand(@muladd a*b*c*d+e) == :($(Base.muladd)(a*b*c, d, e))
end

# Multiple multiplications
@testset "Multiple multiplications" begin
    @test @macroexpand(@muladd a*b+c*d) == :($(Base.muladd)(c, d, a*b))
    @test @macroexpand(@muladd a*b+c*d+e*f) == :($(Base.muladd)(e, f,
                                                                $(Base.muladd)(c, d, a*b)))
    @test @macroexpand(@muladd a*(b*c+d)+e) == :($(Base.muladd)(a,
                                                                $(Base.muladd)(b, c, d), e))
end

# Dot calls
@testset "Dot calls" begin
    @test @macroexpand(@. @muladd a*b+c) == :($(Base.muladd).(a, b, c))
    @test @macroexpand(@muladd @. a*b+c) == :($(Base.muladd).(a, b, c))
    @test @macroexpand(@muladd a.*b+c) == :(a.*b+c)
    @test @macroexpand(@muladd a*b.+c) == :(a*b.+c)
    @test @macroexpand(@muladd .+(a.*b, c, d)) == :($(Base.muladd).(a, b, c.+d))
    @test @macroexpand(@muladd @. a*b+c+d) == :($(Base.muladd).(a, b, (+).(c, d)))
    @test @macroexpand(@muladd @. a*b*c+d) == :($(Base.muladd).((*).(a, b), c, d))
    @test @macroexpand(@muladd f.(a)*b+c) == :($(Base.muladd)(f.(a), b, c))
    @test @macroexpand(@muladd a*f.(b)+c) == :($(Base.muladd)(a, f.(b), c))
    @test @macroexpand(@muladd a*b+f.(c)) == :($(Base.muladd)(a, b, f.(c)))
end

# Nested expressions
@testset "Nested expressions" begin
    @test @macroexpand(@muladd f(x, y, z) = x*y+z) == :(f(x, y, z) =
                                                        $(Base.muladd)(x, y, z))
    @test @macroexpand(@muladd function f(x, y, z) x*y+z end) ==
        :(function f(x, y, z) $(Base.muladd)(x, y, z) end)
    @test @macroexpand(@muladd for i in 1:n z = x*i + y end) ==
        :(for i in 1:n z = $(Base.muladd)(x, i, y) end)
end
