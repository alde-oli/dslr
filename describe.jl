using CSV
using DataFrames

function extract_second_type(::Vector{Union{Missing,T}}) where {T}
    return T
end

function column_means(df::DataFrame)
    means = ["mean"]
    counts = ["count"]
    stds = []
    for name in names(df)
        temp_df = df[.!ismissing.(df[!, name]), :]
        col = temp_df[!, name]
        if eltype(col) isa Union
            col = convert(Vector{extract_second_type(col)}, temp_df[!, name])
        end
        # min = col[1]
        # max

        push!(counts, string(length(col)));
        push!(means, string(round(sum(col) / length(col), sigdigits=7)))
    end
    return means, counts
end



if length(ARGS) != 1
    println("Invalid number of arguments")
    exit(1)
end

Data = select(CSV.read(ARGS, DataFrame), Not(1))

numerical_cols = filter(col -> eltype(Data[!, col]) <: Union{Missing,Number}, names(Data))
Data = select(Data, numerical_cols)

Describe = DataFrame([name => [] for name in  ["", names(Data)...]])



means, counts = column_means(Data)

push!(Describe, means, counts)

println(Describe)
