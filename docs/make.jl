using Documenter, Ipaper
using DataFrames

CI = get(ENV, "CI", nothing) == "true"

# Logging.disable_logging(Logging.Warn)

# Make the docs, without running the tests again
# We need to explicitly add all the extensions here
makedocs(
  # modules=[
  #   Ipaper, TidyTable2
  # ],
  format=Documenter.HTML(
    prettyurls=CI,
  ),
  pages=[
    "Introduction" => "index.md"
    "R Base"       => "RBase.md"
    "Statistics"   => "Statistics.md"
    "Climate"      => "Climate.md"
  ],
  sitename="Ipaper.jl",
  strict=false,
  clean=false,
)

# Enable logging to console again
# Logging.disable_logging(Logging.BelowMinLevel)

deploydocs(
  repo="github.com/jl-spatial/Ipaper.jl.git",
)
