using Pkg
Pkg.activate("..")
push!(LOAD_PATH, "../src/")
using Documenter
push!(LOAD_PATH, "../src/")
cd(@__DIR__)
using Documenter, Literate, DocumenterCitations
using rl_vac

# Literate.markdown("./src/tutorial.jl", "./src")
pages = [
    "Introduction" => "index.md",
    #  "Tutorial" => "tutorial.md",
    #"API" => "api.md",
]

makedocs(
    modules=[rl_vac],
    doctest=false,
    clean=true,
    warnonly=[:missing_docs],
    sitename="rl_vac.jl",
    format=Documenter.HTML(prettyurls=false),
    pages=pages
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
