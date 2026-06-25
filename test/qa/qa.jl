using SciMLTesting, JET, MuladdMacro, Test

run_qa(
    MuladdMacro;
    explicit_imports = true,
    aqua_kwargs = (; ambiguities = (recursive = false,)),
)
