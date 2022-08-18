# rm /share/opt/julia/*.so
time julia build.jl

# add to vscode setting

# "julia.additionalArgs": [
#         "--sysimage",
#         "/share/opt/julia/libIpaper.so"
#     ],
time julia --sysimage /opt/julia/libIpaper.so init.jl
# time julia init.jl
