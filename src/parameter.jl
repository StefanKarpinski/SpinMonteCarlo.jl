using MacroTools

@doc doc"""
    @gen_convert_parameter(model_typename, (keyname, size_fn, default)...)

Generates `convert_parameter(model::model_typename, param::Parameter)`.

# Example

``` julia
@gen_convert_parameter(A, ("A", numbondtypes, 1.0), ("B", 1, 1))
```

generates a function equivalent to the following:

``` julia
doc\"""
    convert_parameter(model::A, param::Parameter)

# Keynames

- "A": a vector with `numbondtypes(model)` elements (default: 1)
- "B": a scalar (default: 1.0)

\"""
function convert_parameter(model::A, param::Parameter)
    ## if `size_fn` is a `Function`,
    ## result is a vector whose size is `size_fn(model)`.
    ## `param["A"]` can take a scalar or a vector.
    a = get(param, "A", 1.0)
    as = zeros(Float64, numbondtypes(model))
    as .= a

    ## otherwise,
    ## result is a scalar.
    b = get(param, "B", 1) :: Int

    return as, b
end
```
"""
macro gen_convert_parameter(model_typename, args...)
    body = Expr(:block)

    document = "    convert_parameter(model::$(model_typename), param::Parameter)\n\n"
    document *= "# Keynames:\n"

    syms = Symbol[]
    for arg in args
        @capture(arg, (name_String, sz_, default_))
        eltyp = typeof(default)
        sym = gensym()
        if isa(eval(sz), Function)
            push!(body.args,
                  esc(:( $(sym) = get(param, $name, $default) ))
                 )
            sym2 = gensym()
            push!(syms, sym2)
            push!(body.args,
                  esc(:( $(sym2) = zeros($eltyp, $sz(model))))
                 )
            push!(body.args,
                  esc(:( $(sym2) .= $(sym) ))
                 )
            document *= "- \"$name\": a vector with `$(sz)(model)` elements (default: $default).\n"
        else
            push!(body.args,
                  esc(:( $(sym) = get(param, $name, $default) :: $eltyp ))
                 )
            push!(syms, sym)
            document *= "- \"$name\": a scalar (default: $default).\n"
        end
    end
    ret = Tuple( s for s in syms )
    push!(body.args, 
          esc(:(return tuple($(syms...))  )) 
         )

    res_fn = :(function $(esc(:convert_parameter))($(esc(:(model::$model_typename))),
                                                   $(esc(:(param::Parameter)))
                                                  )
                   $body
               end)


    :( @doc $document $res_fn )
end

@doc doc"""
    convert_parameter(model, param)

Generates arguments of updater and estimator.

# Example
``` julia-repl
julia> model = Ising(chain_lattice(4));

julia> p = convert_parameter(model, Parameter("J"=>1.0))
(1.0, [1.0, 1.0]) # T and Js

julia> p = convert_parameter(model, Parameter("J"=>[1.5, 0.5]))
(1.0, [1.5, 0.5]) # J can take a vector whose size is `numbondtypes(model)`

julia> model.spins
4-element Array{Int64,1}:
  1
  1
  1
 -1

julia> local_update!(model, p...);

julia> model.spins
4-element Array{Int64,1}:
  1
  1
 -1
 -1
```
"""
function convert_parameter end

@gen_convert_parameter(Union{Ising, Potts, Clock, XY}, ("T", 1, 1.0),
                                                       ("J", numbondtypes, 1.0),
                                                      )
@gen_convert_parameter(QuantumXXZ, ("T", 1, 1.0),
                                   ("Jz", numbondtypes, 1.0),
                                   ("Jxy", numbondtypes, 1.0),
                                   ("Gamma", numsitetypes, 0.0),
                                  )
