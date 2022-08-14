using Ipaper

dir(".")

probs = factor([0.9, 0.99])

df = DataFrame(A=1:3, B=4:6, C=7:9)
fwrite(df, "a.csv")
fwrite(df, "a.csv", append=true)
df = fread("a.csv")
rm("a.csv")

d1 = DataFrame(A=1:3, B=4:6, C=7:9)
d2 = DataFrame(A=1:3, B=4:6, D=7:9)
r1 = dt_merge(d1, d2, by="A", suffixes=["_x", ".y"])
r1 = dt_merge(d1, d2, by=["A"], suffixes=["_x", ".y"])
r2 = dt_merge(d1, d2, by=:A, suffixes=["_x", ".y"])
r2 = dt_merge(d1, d2, by=[:A], suffixes=["_x", ".y"])
println(r2)
# ! time julia --sysimage /opt/julia/libIpaper-v0.1.4.so init.jl
