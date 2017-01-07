VERSION >= v"0.4.0-dev+6521" && __precompile__()

module SpinMonteCarlo

export Model, Ising, XY, Potts, Clock
export SW_update!, local_update!
export magnetizations, energy
export chain_lattice, square_lattice, triangular_lattice, cubic_lattice
export Lattice, dim, size, numsites, numbonds, neighbors, source, target
export UnionFind, addnode!, unify!, clusterize!, clusterid
export measure
export gen_snapshot!, gensave_snapshot!, load_snapshot

include("union_find.jl")
include("lattice.jl")
include("model.jl")
include("SW.jl")
include("local_update.jl")
include("measure.jl")
include("snapshot.jl")
include("observables/MCObservables.jl")

end # of module
