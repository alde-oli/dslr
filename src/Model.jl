# struct to store weights and what the model is trying to predict
mutable struct Model
	house::String
	weights::Array{Float64, 1}

	function Model(house::String, len::Int)
		new(house, zeros(len))
	end
	function Model(house::String15, weights::Vector{Float64})
		new(house, weights)
	end
end