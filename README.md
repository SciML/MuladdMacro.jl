# MuladdMacro.jl

[![Build Status](https://github.com/SciML/MuladdMacro.jl/workflows/CI/badge.svg)](https://github.com/SciML/MuladdMacro.jl/actions?query=workflow%3ACI)
[![Coverage Status](https://coveralls.io/repos/github/JuliaDiffEq/MuladdMacro.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaDiffEq/MuladdMacro.jl?branch=master)
[![codecov.io](http://codecov.io/github/JuliaDiffEq/MuladdMacro.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaDiffEq/MuladdMacro.jl?branch=master)

This package provides the `@muladd` macro. It automatically converts expressions
with multiplications and additions or subtractions to calls with `muladd` which then fuse via
FMA when it would increase the performance of the code. The `@muladd` macro
can be placed on code blocks and it will automatically find the appropriate
expressions and nest muladd expressions when necessary. In mixed expressions summands without multiplication 
will be grouped together and evaluated first but otherwise the order of evaluation of multiplications and additions is not changed.

## Examples

```julia
julia> @macroexpand(@muladd k3 = f(t + c3*dt, @. uprev+dt*(a031*k1+a032*k2)))
:(k3 = f((muladd)(c3, dt, t), (muladd).(dt, (muladd).(a032, k2, (*).(a031, k1)), uprev)))

julia> @macroexpand(@muladd integrator.EEst = integrator.opts.internalnorm((update - dt*(bhat1*k1 + bhat4*k4 + bhat5*k5 + bhat6*k6 + bhat7*k7 + bhat10*k10))./ @. (integrator.opts.abstol+max(abs(uprev),abs(u))*integrator.opts.reltol)))
:(integrator.EEst = (integrator.opts).internalnorm((muladd)(-dt, (muladd)(bhat10, k10, (muladd)(bhat7, k7, (muladd)(bhat6, k6, (muladd)(bhat5, k5, (muladd)(bhat4, k4, bhat1 * k1))))), update) ./ (muladd).(max.(abs.(uprev), abs.(u)), (integrator.opts).reltol, (integrator.opts).abstol)))
```

## Broadcasting

A `muladd` call will be broadcasted if both the `*` and the `+` or `-` are broadcasted.
If either one is not broadcasted, then the expression will be converted to a
non-dotted `muladd`.

## Limitations

Currently, `@muladd` handles only explicit calls of `+` and `*`. In particular, assignments
using `+=` or literal power such as `^2` are not supported. Thus, you need to rewrite them, e.g.
```julia
julia> using MuladdMacro

julia> a = 1.0; b = 2.0; c = 3.0;

julia> @macroexpand @muladd a += b * c # does not work
:(a += b * c)

julia> @macroexpand @muladd a = a + b * c # good alternative
:(a = (muladd)(b, c, a))

julia> @macroexpand @muladd a + b^2 # does not work
:(a + b ^ 2)

julia> @macroexpand @muladd a + b * b # good alternative
:((muladd)(b, b, a))
```

## Credit

Most of the credit goes to @fcard and @devmotion for building the first version
and greatly refining the macro. These contributions are not directly shown as
this was developed in Gitter chats and in the DiffEqBase.jl repository, but
these two individuals did almost all of the work.
