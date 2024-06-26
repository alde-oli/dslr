using CSV
using DataFrames
using Base.Threads: @threads, nthreads

include("src/data.jl")
include("src/Model.jl")
include("src/train.jl")


if length(ARGS) != 2
    println("Invalid number of arguments")
    exit(1)
elseif !isfile(ARGS[1]) || !occursin(r".csv$", ARGS[1]) || !isfile(ARGS[2]) || !occursin(r".csv$", ARGS[2])
    println("Invalid file")
    exit(1)
end

excluded_columns = ["Potions", "Care of Magical Creatures", "Arithmancy", "Index", "First Name", "Last Name", "Birthday", "Best Hand"]

data = preprocess_data(select!(CSV.read(ARGS[1], DataFrame), Not(excluded_columns)))

df = CSV.read("models_output.csv", DataFrame)

models = convert_df_models(df)

output = DataFrame("Index" => Int[], "Hogwarts House" => String15[])

for (index, student) in enumerate(eachrow(data))
    best_house = ""
    best_weight = 0
    for m in models
        grades = [student[2:end]...]
        weight = sigmoid(grades, m.weights)
        if weight > best_weight
            best_house = m.house
            best_weight = weight
        end
    end
    push!(output, (index - 1, best_house))
end

CSV.write("houses.csv", output)