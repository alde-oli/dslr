using CSV
using DataFrames
using Dates

function extract_second_type(::Vector{Union{Missing,T}}) where {T}
    return T
end

function clean(n::Number)
    return string(round(n, sigdigits=7))
end

function percentile(p, data, len)
    k = (len - 1) * p + 1
    f = floor(Int, k)
    c = ceil(Int, k)
    if f == c
        return data[f]
    else
        return data[f] * (c - k) + data[c] * (k - f)
    end
end

function column_means(df::DataFrame)
    means = ["mean"]
    counts = ["count"]
    stds = ["std"]
    mins = ["min"]
    maxs = ["max"]
    medians = ["50%"]
    quarter1s = ["25%"]
    quarter2s = ["75%"]

    for name in names(df)
        temp_df = df[.!ismissing.(df[!, name]), :]
        col = temp_df[!, name]
        if eltype(col) isa Union
            col = convert(Vector{extract_second_type(col)}, temp_df[!, name])
        end
        len = length(col)
        min = col[1]
        max = min
        for val in col
            if min > val
                min = val
            end
            if max < val
                max = val
            end
        end
        col_s = sort(col)
        median = percentile(0.5, col_s, len)
        quarter1 = percentile(0.25, col_s, len)
        quarter2 = percentile(0.75, col_s, len)
        push!(quarter1s, clean(quarter1))
        push!(quarter2s, clean(quarter2))

        push!(counts, string(len))
        mean = sum(col) / len
        push!(means, clean(mean))
        push!(mins, clean(min))
        push!(maxs, clean(max))
        push!(medians, clean(median))
        std = 0
        foreach(x -> std += (x - mean)^2, col)
        std = sqrt(std / len)
        push!(stds, clean(std))
    end
    return counts, means, stds, mins, quarter1s, medians, quarter2s, maxs
end



if length(ARGS) != 1
    println("Invalid number of arguments")
    exit(1)
end

data = select(CSV.read(ARGS, DataFrame), Not(1))

data.days = Dates.value.(data.Birthday)

numerical_cols = filter(col -> eltype(data[!, col]) <: Union{Missing,Number}, names(data))
data = select(data, numerical_cols)

describe = DataFrame([name => [] for name in  ["", names(data)...]])


push!(describe, column_means(data)...)

println(describe)
