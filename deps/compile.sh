rm /opt/julia/libIpaper.so
time julia compile.jl

# add to vscode setting

# "julia.additionalArgs": [
#         "--sysimage",
#         "/opt/julia/libIpaper.so"
#     ],
time julia --sysimage /opt/julia/libIpaper.so init.jl
time julia init.jl
