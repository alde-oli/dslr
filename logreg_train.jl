using CSV
using DataFrames


function extract_second_type(::Vector{Union{Missing, T}}) where {T}
	return T
end





function column_means(df::DataFrame)
	means = []
	mins = []
	maxs = []

	for name in names(df)
		temp_df = df[.!ismissing.(df[!, name]), :]
		col = temp_df[!, name]
		if eltype(col) isa Union
			col = convert(Vector{extract_second_type(col)}, temp_df[!, name])
		end
		if !(eltype(col) <: Number)
			push!(means, 0)
			push!(mins, 0)
			push!(maxs, 0)
			continue
		end
		len = length(col)
		min = col[1]
		max = min
		for val in col
			min = min > val ? val : min
			max = max < val ? val : max
		end

		mean = sum(col) / len

		push!(means, mean)
		push!(mins, min)
		push!(maxs, max)

	end
	return means, mins, maxs
end


function preprocess_data(df::DataFrame)

	means, mins, maxs = column_means(df)

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
end



function sigmoid(courses::Vector{Union{Missing, Float64}}, weights::Vector{Float64}, bias::Float64)
	1 / (2.72^-(sum(courses .* weights) + bias))
end


function sigmoid(courses::Vector{Float64}, weights::Vector{Float64}, bias::Float64)
	1 / (2.72^-(sum(courses .* weights) + bias))
end


if length(ARGS) != 1
	println("Invalid number of arguments")
	exit(1)
end

data = CSV.read(ARGS, DataFrame)
learning_rate = 0.1
iterations = 1000



mutable struct model
	house::String
	weights::Array{Float64, 1}
	bias::Float64

	function model(house::String)
		new(house, zeros(length(names(data)) - 1), 0)
	end
end


data = select!(data, Not([:"Potions", :"Care of Magical Creatures", :"Arithmancy", :"Index", :"First Name", :"Last Name", :"Birthday", :"Best Hand"]));
num_courses = length(names(data)) - 1
len = size(data, 1)

preprocess_data(data)


println(describe(data))
# preprocessing: replace 'missing' with average
# current norm method: between 0 and 1 by offset and division

# models: 4 houses, weight for each course and bias

models = [model("Gryffindor"), model("Slytherin"), model("Ravenclaw"), model("Hufflepuff")]

for itr in 1:iterations
	for m in models
		temp_model = model("")

		for i in 1:num_courses
			sum_diff_weight = 0
			sum_diff_bias = 0
			for student in eachrow(data)
				target = m.house == student."Hogwarts House" ? 1 : 0
				grades = [student[2:end]...]
				diff = (sigmoid(grades, m.weights, m.bias) - target)
				sum_diff_weight += diff * student[i+1]
				# sum_diff_bias += diff
			end
			temp_model.weights[i] = learning_rate / len * sum_diff_weight
			temp_model.bias = learning_rate / len * sum_diff_bias
			m.bias -= sum_diff_bias

		end

		m.weights .-= temp_model.weights

	end
end

success = 0

for student in eachrow(data)
    best_house = ""
    best_weight = 0
    for m in models
        grades = [student[2:end]...]

        weight = sigmoid(grades, m.weights, m.bias)
        # println(weight)
        if weight > best_weight
            # println("SET HOUSE ", m.house)
            best_house = m.house
            best_weight = weight
        end
    end
    # println(best_house, student."Hogwarts House")
    # println( best_house === student."Hogwarts House")
    # println(best_house, " vs ", student."Hogwarts House")
    # println(best_house == student."Hogwarts House")
    global success += best_house == student."Hogwarts House"

end
println(success)
println(models)