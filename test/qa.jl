using MuladdMacro, Aqua
@testset "Aqua" begin
    Aqua.test_all(MuladdMacro; ambiguities=(recursive = false,))
end
