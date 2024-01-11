# Ipaper in Julia (R base for Julia)

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://jl-pkgs.github.io/Ipaper.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jl-pkgs.github.io/Ipaper.jl/dev)
[![CI](https://github.com/jl-pkgs/Ipaper.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/jl-pkgs/Ipaper.jl/actions/workflows/CI.yml)
[![Codecov](https://codecov.io/gh/jl-pkgs/Ipaper.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/jl-pkgs/Ipaper.jl)

> Dongdong Kong

# Installation

```
using Pkg
Pkg.add(url="https://github.com/jl-pkgs/Ipaper.jl")
```

# Functions 

- `slope_mk`: 50X faster than R `rtrend::mkTrend_r`, and 10X faster than the Rcpp version `rtrend::mkTrend`
