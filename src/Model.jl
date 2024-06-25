# struct to store weights and what the model is trying to predict
mutable struct Model
	house::String
	weights::Array{Float64, 1}

	function Model(house::String, len::Int)
		new(house, zeros(len))
	end
end