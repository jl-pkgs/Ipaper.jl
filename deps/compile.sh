rm /opt/julia/*.so
time julia compile.jl

# add to vscode setting

# "julia.additionalArgs": [
#         "--sysimage",
#         "/opt/julia/libIpaper-v0.1.4.so"
#     ],
time julia --sysimage /opt/julia/libIpaper-v0.1.4.so init.jl
time julia init.jl
