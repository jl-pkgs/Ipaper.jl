using Documenter, Ipaper
using Distributions
CI = get(ENV, "CI", nothing) == "true"

# Logging.disable_logging(Logging.Warn)

# Make the docs, without running the tests again
# We need to explicitly add all the extensions here
makedocs(
  modules=[
    Ipaper, 
    Base.get_extension(Ipaper, :IpaperSlopeExt)
  ],
  format=Documenter.HTML(
    prettyurls=CI,
  ),
  pages=[
    "Introduction" => "index.md"
    "R Base"       => "RBase.md"
    "Statistics"   => "Statistics.md"
    "Slope"        => "Slope.md"
    "Climate"      => "Climate.md"
    "Parallel"     => "Parallel.md"
  ],
  sitename="Ipaper.jl",
  warnonly=true,
  clean=false,
)

# Enable logging to console again
# Logging.disable_logging(Logging.BelowMinLevel)

deploydocs(
  repo="github.com/jl-pkgs/Ipaper.jl.git",
)
