using PackageCompiler

# version = "v0.1.4"
lib_Ipaper = "libIpaper.so"

pkg = "Ipaper"
PackageCompiler.create_sysimage([pkg]; sysimage_path="libIpaper.so",
  precompile_execution_file="init.jl")

try
  mv(lib_Ipaper, "/share/opt/julia/libIpaper.so")
catch e
  println(e)
end

println(pwd())
println("Hello world!")
