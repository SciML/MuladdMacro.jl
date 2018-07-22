__precompile__(true)
module MuladdMacro

using MacroTools: postwalk

"""
    @muladd

Convert every combination of addition/subtraction and multiplication to a call of `muladd`.

If both of the involved operators are dotted, `muladd` is applied as a dot call.
The order of summation might be changed.
"""
macro muladd(ex)
    esc(to_muladd(ex))
end

"""
    to_muladd(ex)

Convert every combination of addition/subtraction and multiplication in expression `ex` to a call of `muladd`.

If both of the involved operators are dotted, `muladd` is applied as a dot call
The order of summation might be changed.
"""
function to_muladd(ex)
    postwalk(ex) do x
        # Modify summations
        issum(x) && return sum_to_muladd(x)

        # Modify subtractions
        issub(x) && return sub_to_muladd(x)

        return x
    end
end

"""
    sum_to_muladd(ex)

Replace sum `ex` by sequence of `muladd` if possible. Hereby the order of summation might be changed.
"""
function sum_to_muladd(ex)
    # Retrieve summands
    summands = args(ex)
    summands == nothing && return ex

    # Skip further calculations if no summand is a multiplication
    dotcall = isdotcall(ex)
    any(x -> ismul(x, dotcall), summands) || return ex

    # Split summands into two groups, one with expressions
    # of multiplications and one with other expressions
    mulsummands = filter(x -> ismul(x, dotcall), summands)
    oddsummands = filter(x -> !ismul(x, dotcall), summands)

    # If all summands are multiplications the first one is not reduced
    isempty(oddsummands) && push!(oddsummands, popfirst!(mulsummands))

    # Reduce sum to a composition of muladd
    foldl(mulsummands; init = newargs(ex, oddsummands...)) do s₁, s₂
        newmuladd(splitargs(s₂)..., s₁, dotcall)
    end
end

"""
    sub_to_muladd(ex)

Replace subtraction `ex` by `muladd` if possible.
"""
function sub_to_muladd(ex)
    # Retrieve operands
    _x = args(ex)
    _x == nothing && return ex
    length(_x) <= 1 && return ex
    x, y = _x

    # Modify subtraction if possible
    dotcall = isdotcall(ex)
    if ismul(y, dotcall)
        y₁, y₂ = splitargs(y)
        return newmuladd(:(-$y₁), y₂, x, dotcall)
    elseif ismul(x, dotcall)
        return newmuladd(splitargs(x)..., :(-$y), dotcall)
    end

    return ex
end

"""
    isdotcall(ex)

Determine whether `ex` is a dot call.
"""
isdotcall(ex) = (typeof(ex) <: Expr && !isempty(ex.args)) ? ex.head == :. || string(ex.args[1])[1] == '.' : false

"""
    iscall(ex, op)

Determine whether `ex` is a call to `op`.
"""
function iscall(ex, op)
    !(typeof(ex) <: Expr) && return false
    isempty(ex.args) && return false
    if ex.head == :call
        return ex.args[1] == op || ex.args[1] == Symbol(:., op)
    else ex.head == :.
        length(ex.args) < 2 && return false
        return ex.args[1] == op && ( typeof(ex.args[2]) <: Expr && ex.args[2].head == :tuple )
    end
    return false
end

"""
    issum(ex)

Determine whether `ex` is a sum.
"""
issum(ex) = iscall(ex, :+)

"""
    issub(ex)

Determine whether `ex` is a subtraction.
"""
issub(ex) = iscall(ex, :-)

"""
    ismul(ex, dot::Bool)

Determine whether expression `ex` is a multiplication that is dotted if
`dot` is `true` and not dotted otherwise.
"""
function ismul(ex, dot::Bool)
    !(typeof(ex) <: Expr) && return false
    isempty(ex.args) && return false
    if dot
        return typeof(ex) <: Expr &&
        ( ex.args[1] == :.* || (ex.head == :. && ex.args[1] == :*) )
    else
        return typeof(ex) <: Expr && ex.args[1] == :*
    end
end

"""
    newmuladd(x, y, z, dot::Bool)

Return expression `(muladd).(x, y, z)` if `dot` is `true` and
`muladd(x, y, z)` otherwise.
"""
function newmuladd(x, y, z, dot::Bool)
    # Quoting seems to be required for the @. macro to work
    if dot
        :(($(Meta.quot(Base.muladd))).($x, $y, $z))
    else
        :($(Meta.quot(Base.muladd))($x, $y, $z))
    end
end

"""
    args(ex)

Return arguments of function call in `ex`.
"""
function args(ex)
    if typeof(ex) <: Expr
        if ex.head == :call
            length(ex.args) < 2 && return nothing
            x = ex.args[2:end]
            return x
        end
        if ex.head == :.
            length(ex.args) < 2 && return nothing
            x = ex.args[2].args[1:end]
            length(ex.args[2].args) < 2 && return nothing
            return x
        end
    end
    error("expression is not a function call")
end

"""
    splitargs(ex)

Split arguments of function call `ex` before last argument and combine first
arguments to one expression if possible.
"""
function splitargs(ex)
    if ex.head == :call
        x = ex.args[2:end-1]
        y = ex.args[end]
        return newargs(ex, x...), y
    end
    if ex.head == :.
        x = ex.args[2].args[1:end-1]
        y = ex.args[2].args[end]
        return newargs(ex, x...), y
    end
    error("cannot split arguments")
end

"""
    newargs(ex, args)

Create new expression of function call `ex` with arguments `args`.

Unary function calls are not considered, i.e. if only one function
argument is provided it is returned.
"""
function newargs(ex, args...)
    # Return single argument
    length(args) == 1 && return args[1]
    f = ex.args[1]

    # Create function calls with new arguments
    ex.head == :. && return :(($f).($(args...)))
    ex.head == :call && return :(($f)($(args...)))

    error("expression is not a function call")
end

export @muladd

end # module
