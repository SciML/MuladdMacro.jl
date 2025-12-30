using MuladdMacro, ExplicitImports, Test

@testset "ExplicitImports" begin
    @test check_no_implicit_imports(MuladdMacro) === nothing
    @test check_no_stale_explicit_imports(MuladdMacro) === nothing
end
