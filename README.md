# MuladdMacro.jl

[![Build Status](https://travis-ci.org/JuliaDiffEq/MuladdMacro.jl.svg?branch=master)](https://travis-ci.org/JuliaDiffEq/MuladdMacro.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/ospomrhxtmiylx57?svg=true)](https://ci.appveyor.com/project/ChrisRackauckas/muladdmacro-jl)
[![Coverage Status](https://coveralls.io/repos/ChrisRackauckas/MuladdMacro.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/ChrisRackauckas/MuladdMacro.jl?branch=master)
[![codecov.io](http://codecov.io/github/ChrisRackauckas/MuladdMacro.jl/coverage.svg?branch=master)](http://codecov.io/github/ChrisRackauckas/MuladdMacro.jl?branch=master)

This package provides the `@muladd` macro. It automatically converts expressions
with multiplications and additions to calls with `muladd` which then fuse via
FMA when it would increase the performance of the code. The `@muladd` macro
can be placed on code blocks and it will automatically find the appropriate
expressions and nest muladd expressions when necessary.

## Examples

```julia
julia> macroexpand(:(@muladd k3 = f(t + c3*dt, @. uprev+dt*(a031*k1+a032*k2))))
:(k3 = f((muladd)(c3, dt, t), (muladd).(dt, (muladd).(a031, k1, *.(a032, k2)), uprev)))

julia> macroexpand(:(@muladd integrator.EEst = integrator.opts.internalnorm((update - dt*(bhat1*k1 + bhat4*k4 + bhat5*k5 + bhat6*k6 + bhat7*k7 + bhat10*k10))./ @. (integrator.opts.abstol+max(abs(uprev),abs(u))*integrator.opts.reltol))))
:(integrator.EEst = integrator.opts.internalnorm((update - dt * (muladd)(bhat1, k1, (muladd)(bhat4, k4, (muladd)(bhat5, k5, (muladd)(bhat6, k6, (muladd)(bhat7, k7, bhat10 * k10)))))) ./ (muladd).(max.(abs.(uprev), abs.(u)), integrator.opts.reltol, integrator.opts.abstol)))
```

## Broadcasting

A `muladd` call will be broadcasted if both the `*` and the `+` are broadcasted.
If either one is not broadcasted, then the expression will be converted to a
non-dotted `muladd`.

## Credit

Most of the credit goes to @fcard and @devmotion for building the first version
and greatly refining the macro. These contributions are not directly shown as
this was developed in Gitter chats and in the DiffEqBase.jl repository, but
these two individuals did almost all of the work.
