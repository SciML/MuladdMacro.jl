using MuladdMacro, Aqua, ExplicitImports, JET, Test

@testset "Aqua" begin
    Aqua.test_all(MuladdMacro; ambiguities = (recursive = false,))
end

@testset "ExplicitImports" begin
    @test check_no_implicit_imports(MuladdMacro) === nothing
    @test check_no_stale_explicit_imports(MuladdMacro) === nothing
end

@testset "JET static analysis" begin
    rep = JET.report_call(MuladdMacro.to_muladd, (Expr,))
    @test isempty(JET.get_reports(rep))

    rep = JET.report_call(MuladdMacro.sum_to_muladd, (Expr,))
    @test isempty(JET.get_reports(rep))

    rep = JET.report_call(MuladdMacro.sub_to_muladd, (Expr,))
    @test isempty(JET.get_reports(rep))

    rep = JET.report_call(MuladdMacro.issum, (Expr,))
    @test isempty(JET.get_reports(rep))

    rep = JET.report_call(MuladdMacro.issub, (Expr,))
    @test isempty(JET.get_reports(rep))
end
