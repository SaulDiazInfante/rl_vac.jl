push!(LOAD_PATH, "../src/")
cd(@__DIR__)
using Documenter, Literate, DocumenterCitations
using rl_vac

# Literate.markdown("./src/tutorial.jl", "./src")
pages = [
    "Introduction" => "index.md",
    #  "Tutorial" => "tutorial.md",
    #  "API" => "api.md",
]

makedocs(; pages,
    sitename="rl_vac",
    format=Documenter.HTML(),
    modules=[rl_vac]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
