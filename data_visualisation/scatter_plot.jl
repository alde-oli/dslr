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
course1 = "Defense Against the Dark Arts"
course2 = "Astronomy"
scatter_plot = scatter(df[!, course1], df[!, course2],
                title=course1 * " vs " * course2,
                xlabel=course1, ylabel=course2,
                label="",
                markersize=5,
                markercolor=[category_colors[row."Hogwarts House"] for row in eachrow(df)],
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

plot(scatter_plot, margin=10mm, xtickfont=font(15), ytickfont=font(15))

savefig("plots/scatter_plots.png")