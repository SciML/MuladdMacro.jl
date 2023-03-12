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
         format = Documenter.HTML(;
                                  prettyurls = get(ENV, "CI", "false") == "true",
                                  canonical = "https://docs.sciml.ai/MuladdMacro/stable/",
                                  assets = ["assets/favicon.ico"]),
         pages = ["Home" => "index.md", "api.md"],
         strict = true,
         checkdocs = :exports)

deploydocs(;
           repo = "github.com/SciML/MuladdMacro.jl",
           push_preview = true)
