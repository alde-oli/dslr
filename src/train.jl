# the great sigmoid function
function sigmoid(courses::Vector, weights::Vector{Float64})
	return 1 / (1 + exp(-sum(courses .* weights)))
end


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