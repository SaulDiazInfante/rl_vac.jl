using Pkg
Pkg.activate("..")
push!(LOAD_PATH, "../src/")
using Documenter
push!(LOAD_PATH, "../src/")
cd(@__DIR__)
using Documenter, Literate, DocumenterCitations
using DataFrames
using rl_vac

# Literate.markdown("./src/tutorial.jl", "./src")
pages = [
    "Introduction" => "index.md",
    #  "Tutorial" => "tutorial.md",
    "API" => "api.md",
]
bib = CitationBibliography(joinpath(@__DIR__, "src", "refs.bib"))
makedocs(
    modules=[rl_vac],
    doctest=false,
    clean=true,
    warnonly=true,
    sitename="rl_vac.jl",
    format=Documenter.HTML(prettyurls=false),
    pages=pages,
    plugins=[bib]
)

mathengine = MathJax3(Dict(
    :loader => Dict("load" => ["[tex]/physics"]),
    :tex => Dict(
        "inlineMath" => [["\$", "\$"], ["\\(", "\\)"]],
        "tags" => "ams",
        "packages" => ["base", "ams", "autoload", "physics"],
    ),
))
