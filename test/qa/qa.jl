using SciMLTesting, JET, MuladdMacro, Test

run_qa(
    MuladdMacro;
    explicit_imports = true,
    api_docs_kwargs = (; rendered = true),
    aqua_kwargs = (; ambiguities = (recursive = false,)),
)
