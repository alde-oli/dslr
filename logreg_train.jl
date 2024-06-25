using CSV
using DataFrames
using Dates
using Base.Threads: @threads, nthreads


# struct to store weights and what the model is trying to predict
mutable struct Model
	house::String
	weights::Array{Float64, 1}

	function Model(house::String, len::Int)
		new(house, zeros(len))
	end
end


# made to get the non Missing type of a Unions because somehow when you remove missings you still can't cast into the other type of the Union
function get_second_type(::Vector{Union{Missing, T}}) where {T}
	return T
end


# returns 3 arrays with the means, mins and maxs of the columns
function cols_stats(df::DataFrame)
	means = []
	mins = []
	maxs = []

	for name in names(df)
		temp_df = df[.!ismissing.(df[!, name]), :]
		col = temp_df[!, name]
		if eltype(col) isa Union
			col = convert(Vector{get_second_type(col)}, temp_df[!, name])
		elseif !(eltype(col) <: Number)
			push!(means, 0)
			push!(mins, 0)
			push!(maxs, 0)
			continue
		end
		min = col[1]
		max = min
		for val in col
			min = min > val ? val : min
			max = max < val ? val : max
		end
		push!(means, sum(col) / length(col))
		push!(mins, min)
		push!(maxs, max)
	end
	return means, mins, maxs
end


# replaces missing values with the mean of the column and normalizes the values
function preprocess_data(df::DataFrame)
	means, mins, maxs = cols_stats(df)

	for student in eachrow(df)
		for (index, name) in enumerate(names(student))
			if ismissing(student[name])
				student[name] = means[index]
			end
			if eltype(student[name]) <: Number
				student[name] = (student[name] - mins[index]) / (maxs[index] - mins[index])
			end
		end
	end
	return df
end


# the great sigmoid function
function sigmoid(courses::Vector, weights::Vector{Float64})
	return 1 / (1 + exp(-sum(courses .* weights)))
end


# check if there is one argument
if length(ARGS) != 1
	println("Invalid number of arguments")
	exit(1)
elseif !isfile(ARGS[1]) || !occursin(r".csv$", ARGS[1])
	println("Invalid file")
	exit(1)
end


# choose the columns to exclude and the hyperparameters
excluded_columns = ["Potions", "Care of Magical Creatures", "Arithmancy", "Index", "First Name", "Last Name", "Birthday", "Best Hand"]
learning_rate = 0.1
iterations = 500


data = preprocess_data(select!(CSV.read(ARGS, DataFrame), Not(excluded_columns)))
num_courses = size(data, 2) - 1
len = size(data, 1)
models = [Model("Gryffindor", num_courses), Model("Slytherin", num_courses), Model("Ravenclaw", num_courses), Model("Hufflepuff", num_courses)]


# training function using gradient descent and logistic regression
function train(models::Array{Model, 1}, data::DataFrame, learning_rate::Float64, iterations::Int)
	for itr in 1:iterations
		@threads for m in models
			temp_model = Model(m.house, num_courses)
	
			for i in 1:num_courses
				sum_diff_weight = 0
				for student in eachrow(data)
					target = m.house == student."Hogwarts House" ? 1 : 0
					grades = [student[2:end]...]
					diff = (sigmoid(grades, m.weights) - target)
					sum_diff_weight += diff * student[i+1]
				end
				temp_model.weights[i] = learning_rate / len * sum_diff_weight
			end
			m.weights .-= temp_model.weights
		end
	end
end


# training function using gradient descent and logistic regression
function train_BGD(models::Array{Model, 1}, data::DataFrame, learning_rate::Float64, iterations::Int)
    for itr in 1:iterations
        @threads for m in models
            temp_weights = zeros(Float64, num_courses)
            
            for student in eachrow(data)
                target = m.house == student."Hogwarts House" ? 1 : 0
                grades = [student[2:end]...]
                prediction = sigmoid(grades, m.weights)
                error = prediction - target
                temp_weights .+= error * grades
            end
            m.weights .-= learning_rate * temp_weights / len
        end
    end
end


# function to calculate the accuracy of the model
function accuracy(models::Array{Model, 1}, data::DataFrame)
	success = 0

	for student in eachrow(data)
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
		success += best_house == student."Hogwarts House"
	end
	return success / size(data, 1)
end



start = now()

train(models, data, learning_rate, iterations)

println("training time: ", now() - start)
println("accuracy = ", accuracy(models, data))