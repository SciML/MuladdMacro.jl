using Documenter

# Print `@debug` statements (https://github.com/JuliaDocs/Documenter.jl/issues/955)
if haskey(ENV, "GITHUB_ACTIONS")
    ENV["JULIA_DEBUG"] = "Documenter"
end

using MuladdMacro

cp(joinpath(@__DIR__, "Manifest.toml"), joinpath(@__DIR__, "src/assets/Manifest.toml");
    force = true)
cp(joinpath(@__DIR__, "Project.toml"), joinpath(@__DIR__, "src/assets/Project.toml");
    force = true)

makedocs(;
    modules = [MuladdMacro],
    repo = "https://github.com/SciML/MuladdMacro.jl/blob/{commit}{path}#{line}",
    sitename = "MuladdMacro.jl",
    clean = true, doctest = false, linkcheck = true,
    strict = [
        :doctest,
        :linkcheck,
        :parse_error,
        :example_block,
        :cross_references,
        # Other available options are
        # :autodocs_block, :cross_references, :docs_block, :eval_block, :example_block, :footnote, :meta_block, :missing_docs, :setup_block
    ],
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://docs.sciml.ai/MuladdMacro/stable/",
        assets = ["assets/favicon.ico"]),
    pages = ["Home" => "index.md", "api.md"],
    checkdocs = :exports)

deploydocs(;
    repo = "github.com/SciML/MuladdMacro.jl",
    push_preview = true)
