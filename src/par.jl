export @par, par_map, get_clusters, get_nthreads, isCurrentWorker, mpi_id, mpi_nwork

import Base.Threads
import MPI

macro par(parallel, ex)
    ex_par = :(Threads.@threads for _ in 1:1; end)
    ex_par.args[3] = ex

    expr = :(parallel ? $(ex_par) : $(ex))
    esc(expr)
end

macro par(ex)
    # default parallel
    ex_par = :(Threads.@threads for _ in 1:1; end)
    ex_par.args[3] = ex
    esc(ex_par)
end


"""
    par_map(f, A, args...; kw...)

# Examples
```julia
function f(x)
  sleep(0.1)
  x
end

# get_clusters()
@time par_map(f, 1:10)
@time map(f, 1:10)
```
"""
function par_map(f, A, args...; parallel=true, progress=true, kw...)
  n = length(A)
  p = Progress(n)

  res = Array{Any}(undef, size(A))
  @par parallel for i in eachindex(A)
    x = A[i]
    r = f(x, args...; kw...)
    res[i] = r

    progress && next!(p)
  end
  map(x -> x, res)
end


get_clusters() = Threads.nthreads()
get_nthreads() = Threads.nthreads()

"""
    $(TYPEDSIGNATURES)

# Example
```julia
!isCurrentWorker(i) && continue
```
"""
function isCurrentWorker(i = 0)
  cluster = mpi_id()
  ncluster = mpi_nwork()
  # @show ncluster, cluster, i
  mod(i, ncluster) == cluster
end

function mpi_id()
  MPI.Init()
  comm = MPI.COMM_WORLD
  MPI.Comm_rank(comm) # id
end

function mpi_nwork()
  MPI.Init()
  comm = MPI.COMM_WORLD
  MPI.Comm_size(comm)
end
