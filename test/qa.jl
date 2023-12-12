using MuladdMacro, Aqua
@testset "Aqua" begin
    Aqua.test_all(MuladdMacro; test_ambiguities=(recursive = false,))
end
