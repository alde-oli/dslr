using CSV
using DataFrames
using Plots
using StatsPlots

file_path = "../datasets/dataset_train.csv"
df = CSV.read(file_path, DataFrame)

Gryffindor = filter(row -> occursin("Gryffindor", row."Hogwarts House"), df)
Slytherin = filter(row -> occursin("Slytherin", row."Hogwarts House"), df)
Ravenclaw = filter(row -> occursin("Ravenclaw", row."Hogwarts House"), df)
Hufflepuff = filter(row -> occursin("Hufflepuff", row."Hogwarts House"), df)
courses = names(df)[7:end]

boxplots = []

for course in courses
	local g_arithmancy = filter(row -> !ismissing(row[course]), Gryffindor)
	local s_arithmancy = filter(row -> !ismissing(row[course]), Slytherin)
	local r_arithmancy = filter(row -> !ismissing(row[course]), Ravenclaw)
	local h_arithmancy = filter(row -> !ismissing(row[course]), Hufflepuff)

	push!(boxplots, boxplot([g_arithmancy[!, course], s_arithmancy[!, course], r_arithmancy[!, course], h_arithmancy[!, course]], 
							labels=["Gryffindor", "Slytherin", "Ravenclaw", "Hufflepuff"], 
							title=course, xlabel=course, ylabel="Value"))
end

plot(boxplots..., size=(4000, 4000))  # Adjust the size here
savefig("plots/box_plot.png")
