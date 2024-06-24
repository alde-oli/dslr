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
for (i, course1) in enumerate(courses)
    for course2 in courses[(i+1):end]
        data = filter(row -> !ismissing(row[course1]) && !ismissing(row[course2]), df)

        scatter_plot = scatter(data[!, course1], data[!, course2],
            xlabel=course1, ylabel=course2,
            label="",
            markersize=5,
            markercolor=[category_colors[row."Hogwarts House"] for row in eachrow(data)],
            legend=false,
            gridalpha=0.5,
            grid=:true,
            xtickfont=font(15),
            ytickfont=font(15),
            background_color=:white,
            titlefontsize=14,
            markerstrokewidth=0,
            markeropacity=0.8
        )
        push!(scatter_plots, scatter_plot)
    end
end

plot(scatter_plots..., margin=10mm, size=(8000, 8000), xtickfont=font(15), ytickfont=font(15))

savefig("scatter_plots.png")