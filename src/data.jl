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