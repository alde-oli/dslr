using CSV
using DataFrames

include("src/data.jl")


if length(ARGS) != 2
	println("Invalid number of arguments")
	exit(1)
elseif !isfile(ARGS[1]) || !occursin(r".csv$", ARGS[1]) || !isfile(ARGS[2]) || !occursin(r".csv$", ARGS[2])
	println("Invalid file")
	exit(1)
end

excluded_columns = ["Potions", "Care of Magical Creatures", "Arithmancy", "Index", "First Name", "Last Name", "Birthday", "Best Hand"]

data = preprocess_data(select!(CSV.read(ARGS[1], DataFrame), Not(excluded_columns)))

# Read the CSV file into a DataFrame
df = CSV.read("models_output.csv", DataFrame)

# Extract data from the DataFrame
houses = df.house
num_courses = ncol(df) - 1  # Determine the number of weight columns

weights = []
for i in 1:num_courses
    push!(weights, df[!, "weight_$i"])
end

# Create an array of Model instances
models = []
for i in 1:nrow(df)
    house = houses[i]
    model_weights = [weights[j][i] for j in 1:num_courses]
    push!(models, Model(house, model_weights))
end

# Print the array of models (optional)
println(models)