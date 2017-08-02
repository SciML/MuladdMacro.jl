module MuladdMacro

"""
    @muladd ex

Convert every combined multiplication and addition in `ex` into a call of `muladd`. If both
of the involved operators are dotted, `muladd` is applied as a "dot call".
"""
macro muladd(ex)
  esc(to_muladd(ex))
end

function to_muladd(ex::Expr)
    if !isaddition(ex)
        if ex.head == :macrocall && length(ex.args)>=2 && ex.args[1] == Symbol("@__dot__")
            # expand @. macros first (enables use of @. inside of @muladd expression)
            return to_muladd(Base.Broadcast.__dot__(last(ex.args)))
        else
            # if expression is no sum apply the reduction to its arguments
            return Expr(ex.head, to_muladd.(ex.args)...)
        end
    end

    # retrieve summands of addition and split them into two groups, one with expressions
    # of multiplications and one with other expressions
    # if addition is a dot call multiplications must be dot calls as well; if the addition
    # is a regular operation only regular multiplications are filtered
    all_operands = to_muladd.(operands(ex))
    if isdotcall(ex)
        mul_operands = filter(x->isdotcall(x, :*), all_operands)
        odd_operands = filter(x->!isdotcall(x, :*), all_operands)
    else
        mul_operands = filter(x->isoperation(x, :*), all_operands)
        odd_operands = filter(x->!isoperation(x, :*), all_operands)
    end

    # define summands that are reduced with muladd and the initial element of the reduction
    if isempty(odd_operands)
        # if all summands are multiplications one of these summands is
        # the initial element of the reduction and evaluated first
        first_operation = mul_operands[1]
        to_be_muladded = mul_operands[2:end]
    else
        to_be_muladded = mul_operands

        # expressions that are no multiplications are summed up in a separate expression
        # that is the initial element of the reduction and evaluated first
        # if the original addition was a dot call this expression also is a dot call
        if length(odd_operands) == 1
            first_operation = odd_operands[1]
        elseif isdotcall(ex)
            # make sure returned expression has same style as original expression
            if ex.head == :.
                first_operation = Expr(:., :+, Expr(:tuple, odd_operands...))
            else
                first_operation = Expr(:call, :.+, odd_operands...)
            end
        else
            first_operation = Expr(:call, :+, odd_operands...)
        end
    end

    # reduce sum to a composition of muladd
    foldl(first_operation, to_be_muladded) do last_expr, next_expr
        # retrieve factors of multiplication that will be reduced next
        next_operands = operands(next_expr)

        # second factor is always last operand
        next_factor2 = next_operands[end]

        # first factor is an expression of a multiplication if there are more than
        # two operands
        # if the original multiplication was a dot call this expression also is a dot call
        if length(next_operands) == 2
            next_factor1 = next_operands[1]
        elseif isdotcall(next_expr)
            next_factor1 = Expr(:., :*, Expr(:tuple, next_operands[1:end-1]...))
        else
            next_factor1 = Expr(:call, :*, next_operands[1:end-1]...)
        end

        # create a dot call if both involved operators are dot calls
        if isdotcall(ex)
            Expr(:., Base.muladd, Expr(:tuple, next_factor1, next_factor2, last_expr))
        else
            Expr(:call, Base.muladd, next_factor1, next_factor2, last_expr)
        end
    end
end
to_muladd(ex) = ex

"""
    isoperation(ex, op::Symbol)

Determine whether `ex` is a call of operation `op`.
"""
isoperation(ex::Expr, op::Symbol) =
    ex.head == :call && !isempty(ex.args) && ex.args[1] == op
isoperation(ex, op::Symbol) = false

"""
    isdotcall(ex[, op])

Determine whether `ex` is a dot call and, in case `op` is specified, whether it calls
operator `op`.
"""
isdotcall(ex::Expr) = !isempty(ex.args) &&
    (ex.head == :. ||
     (ex.head == :call && !isempty(ex.args) && first(string(ex.args[1])) == '.'))
isdotcall(ex) = false

isdotcall(ex::Expr, op::Symbol) = isdotcall(ex) &&
    (ex.args[1] == op || ex.args[1] == Symbol('.', op))
isdotcall(ex, op::Symbol) = false

"""
    isaddition(ex)

Determine whether `ex` is an expression of an addition.
"""
isaddition(ex) = isoperation(ex, :+) || isdotcall(ex, :+)

"""
    operands(ex)

Return arguments of function call in `ex`.
"""
function operands(ex::Expr)
    if ex.head == :. && length(ex.args) == 2 && typeof(ex.args[2]) <: Expr
        ex.args[2].args
    else
        ex.args[2:end]
    end
end

export @muladd

end # module
