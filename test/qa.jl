using MuladdMacro, Aqua
@testset "Aqua" begin
    Aqua.find_persistent_tasks_deps(MuladdMacro)
    Aqua.test_ambiguities(MuladdMacro, recursive = false)
    Aqua.test_deps_compat(MuladdMacro)
    Aqua.test_piracies(MuladdMacro)
    Aqua.test_project_extras(MuladdMacro)
    Aqua.test_stale_deps(MuladdMacro)
    Aqua.test_unbound_args(MuladdMacro)
    Aqua.test_undefined_exports(MuladdMacro)
end
