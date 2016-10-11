abstract Model

type Ising <: Model
    lat :: Lattice
    spins :: Vector{Float64}

    function Ising(lat::Lattice)
        model = new()
        model.lat = lat
        model.spins = rand([1.0,-1.0], numsites(lat))
        return model
    end
end

type XY <: Model
    lat :: Lattice
    spins :: Vector{Float64}

    function XY(lat::Lattice)
        model = new()
        model.lat = lat
        model.spins = rand(numsites(lat))
        return model
    end
end
