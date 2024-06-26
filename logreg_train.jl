using CSV
using DataFrames
using Dates
using Base.Threads: @threads, nthreads
using StatsBase
using Random

using Plots
using StatsPlots

include("src/Model.jl")
include("src/data.jl")
include("src/train.jl")


# choose the columns to exclude and the hyperparameters
excluded_columns = ["Potions", "Care of Magical Creatures", "Arithmancy", "Index", "First Name", "Last Name", "Birthday", "Best Hand"]
learning_rate = 0.1
iterations = 500
training_function = "train_bgd" # options: "train", "train_bgd", "train_sgd"
Random.seed!(555)
train_diff_data = false
record_rate = 1


# check if there is one argument and if it is a valid csv file
if length(ARGS) != 1
	println("Invalid number of arguments")
	exit(1)
elseif !isfile(ARGS[1]) || !occursin(r".csv$", ARGS[1])
	println("Invalid file")
	exit(1)
end


data = preprocess_data(select!(CSV.read(ARGS, DataFrame), Not(excluded_columns)))

total_rows = nrow(data)
n = Int(total_rows * 3 / 4)
random_indices = sample(1:total_rows, n, replace=false)
removed_indices = setdiff(1:total_rows, random_indices)
data_test = data
if train_diff_data
	data_test = data[removed_indices, :]
	data = data[random_indices, :]
end

num_courses = size(data, 2) - 1
len = size(data, 1)
models = [Model("Gryffindor", num_courses), Model("Slytherin", num_courses), Model("Ravenclaw", num_courses), Model("Hufflepuff", num_courses)]


start = now()

# choose the training function and train the models
if training_function == "train"
	accuracies = train(models, data, learning_rate, iterations, record_rate)
elseif training_function == "train_bgd"
	accuracies = train_bgd(models, data, learning_rate, iterations, record_rate)
elseif training_function == "train_sgd"
	accuracies = train_sgd(models, data, learning_rate, iterations, record_rate)
else
	println("Invalid training function")
	exit(1)
end

stop = now()
 

# plot the accuracy
if accuracies != []
	if training_function == "train_sgd"
		iterations *= len
	end
	plot(1:record_rate:iterations, accuracies, xlabel="Iterations", ylabel="Accuracy", title="Accuracy over time", legend=false, size=(1000,1000))
	savefig("plots/accuracy.png")
end


# print the results
println("training time: ", stop - start)
println("accuracy = ", accuracy(models, data_test))
println(models)