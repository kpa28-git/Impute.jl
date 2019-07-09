"""
    Interpolate <: Imputor

Performs linear interpolation between the nearest values in an vector.
"""
struct Interpolate <: Imputor
    context::AbstractContext
end

"""Interpolate(; context=Context()) -> Interpolate"""
Interpolate(; context=Context()) = Interpolate(context)

"""
    impute!(imp::Interpolate, data::AbstractVector)

Uses linear interpolation between existing elements of a vector to fill in missing data.

WARNING: Missing values at the head or tail of the array cannot be interpolated if there
are no existing values on both sides. As a result, this method does not guarantee
that all missing values will be imputed.
"""
function impute!(imp::Interpolate, data::AbstractVector{<:Union{T, Missing}}) where T
    imp.context() do c
        i = findfirst(c, data) + 1

        while i < lastindex(data)
            if ismissing(c, data[i])
                prev_idx = i - 1
                next_idx = findnext(c, data, i + 1)

                if next_idx !== nothing
                    gap_sz = (next_idx - prev_idx) - 1

                    diff = data[next_idx] - data[prev_idx]
                    incr = diff / T(gap_sz + 1)
                    val = data[prev_idx] + incr

                    # Iteratively fill in the values
                    for j in i:(next_idx - 1)
                        data[j] = val
                        val += incr
                    end

                    i = next_idx
                else
                    break
                end
            end
            i += 1
        end

        return data
    end
end
