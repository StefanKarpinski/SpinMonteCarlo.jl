include("../src/SpinMonteCarlo.jl")

using SpinMonteCarlo

const Ls = [8, 16]
const MCS = 8192
const Therm = MCS >> 3
const Ts = linspace(0.5, 2.0, 16)

params = Dict{String, Any}[]
for update in [0,1]
    for L in Ls
        for T in Ts
            push!(params,
                  Dict{String,Any}("Model"=>XY,
                                   "Lattice"=>square_lattice,
                                   "L"=>L,
                                   "T"=>T,
                                   "MCS"=>MCS,
                                   "Thermalization"=>Therm,
                                   "UpdateMethod"=> (update==0 ? local_update! : SW_update!),
                                   "update"=>update,
                                   "Verbose"=>true,
                                  ))
        end
    end
end

obs = map(runMC, params)

const pnames = ["update", "L", "T"]
const onames = ["|Magnetization|",
                "|Magnetization|^2",
                "|Magnetization|^4",
                "Binder Ratio",
                "Magnetization x",
                "|Magnetization x|",
                "Magnetization x^2",
                "Magnetization x^4",
                "Binder Ratio x",
                "Magnetization y",
                "|Magnetization y|",
                "Magnetization y^2",
                "Magnetization y^4",
                "Binder Ratio y",
                "Susceptibility",
                "Connected Susceptibility",
                "Susceptibility x",
                "Connected Susceptibility x",
                "Susceptibility y",
                "Connected Susceptibility y",
                "Helicity Modulus x",
                "Helicity Modulus y",
                "Energy",
                "Energy^2",
                "Specific Heat",
                "MCS per Second",
                "Time per MCS",
               ]

const io = open("res-xy.dat", "w")
i=1
for pname in pnames
    println(io, "# \$$i : $pname")
    i+=1
end
for oname in onames
    println(io, "# \$$i, $(i+1): $oname")
    i+=2
end

for (p,o) in zip(params, obs)
    for pname in pnames
        print(io, p[pname], " ")
    end
    for oname in onames
        @printf(io, "%.15f %.15f ", mean(o[oname]), stderror(o[oname]))
    end
    println(io)
end
