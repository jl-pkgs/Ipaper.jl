using PackageCompiler

pkg = "Ipaper"
version = "v0.1.4"
PackageCompiler.create_sysimage([pkg]; sysimage_path="/opt/julia/lib$pkg-$version.so",
  precompile_execution_file="init.jl")
