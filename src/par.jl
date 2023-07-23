import Base.Threads
import Base.Threads: threading_run, threadid, _threadsfor, nthreads
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

get_clusters() = Threads.nthreads()


"""
    $(TYPEDSIGNATURES)

# Example
```julia
if !isCurrentWorker(i); continue; end
```
"""
function isCurrentWorker(i = 0)
  MPI.Init()
  comm = MPI.COMM_WORLD
  cluster = MPI.Comm_rank(comm)
  ncluster = MPI.Comm_size(comm)
  # @show ncluster, cluster, i
  mod(i, ncluster) == cluster
end


export @par, get_clusters, isCurrentWorker
