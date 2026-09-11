using MuladdMacro, BenchmarkTools
using StableRNGs

const SUITE = BenchmarkGroup()
const rng = StableRNG(123)

N = 200
A = rand(rng, N, N)
B = rand(rng, N, N)
C = rand(rng, N, N)
x = rand(rng, N)
y = rand(rng, N)

# =============================================================================
# @muladd-annotated kernels
# =============================================================================

@muladd function matvec_kernel!(out, A, x)
    @inbounds for i in axes(A, 1)
        s = A[i, 1] * x[1]
        for j in 2:size(A, 2)
            s = s + A[i, j] * x[j]
        end
        out[i] = s
    end
    return out
end

@muladd function matmat_kernel!(C, A, B)
    @inbounds for j in axes(B, 2), i in axes(A, 1)
        s = A[i, 1] * B[1, j]
        for k in 2:size(A, 2)
            s = s + A[i, k] * B[k, j]
        end
        C[i, j] = s
    end
    return C
end

out = similar(y)

SUITE["kernel"] = BenchmarkGroup()
SUITE["kernel"]["matvec"] = @benchmarkable matvec_kernel!($out, $A, $x)
SUITE["kernel"]["matmat"] = @benchmarkable matmat_kernel!($C, $A, $B)

# =============================================================================
# @muladd on expressions
# =============================================================================

SUITE["expr"] = BenchmarkGroup()

a, b, c, d = 1.2, 2.3, 3.4, 4.5
SUITE["expr"]["poly"] = @benchmarkable @muladd($a * $b + $c * $d)
SUITE["expr"]["nested"] = @benchmarkable @muladd($a + $b * ($c + $d * $a))
