using DataFrames
using CSV
using Plots
using Plots.PlotMeasures

file_path = "datasets/dataset_train.csv"
df = CSV.read(file_path, DataFrame)

courses = names(df)[7:end]
scatter_plots = []
category_colors = Dict(
    "Gryffindor" => :red,
    "Slytherin" => :green,
    "Ravenclaw" => :blue,
    "Hufflepuff" => :yellow
)
for course in courses
	data = filter(row -> !ismissing(row[course]), df)

	scatter_plot = scatter(data[!, course],
		xlabel=course, ylabel="",
		# label="",
		# markersize=5,
		# markercolor=[category_colors[row."Hogwarts House"] for row in eachrow(data)],
		# legend=false,
		# gridalpha=0.5,
		# grid=:true,
		# xtickfont=font(15),
		# ytickfont=font(15),
		# background_color=:white,
		# titlefontsize=14,
		# markerstrokewidth=0,
		# markeropacity=0.8
	)
	push!(scatter_plots, scatter_plot)
end

plot(scatter_plots..., margin=10mm, size=(8000, 8000), xtickfont=font(15), ytickfont=font(15))

savefig("plots/scatter_plots.png")