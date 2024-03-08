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

export @par, get_clusters, isCurrentWorker, mpi_id, mpi_nwork
