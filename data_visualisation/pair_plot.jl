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

Gryffindor = filter(row -> occursin("Gryffindor", row."Hogwarts House"), df)
Slytherin = filter(row -> occursin("Slytherin", row."Hogwarts House"), df)
Ravenclaw = filter(row -> occursin("Ravenclaw", row."Hogwarts House"), df)
Hufflepuff = filter(row -> occursin("Hufflepuff", row."Hogwarts House"), df)

for course1 in courses
    for course2 in courses
        data = filter(row -> !ismissing(row[course1]) && !ismissing(row[course2]), df)
        if course1 == course2
            course = course1
            local g_arithmancy = filter(row -> !ismissing(row[course]), Gryffindor)
            local s_arithmancy = filter(row -> !ismissing(row[course]), Slytherin)
            local r_arithmancy = filter(row -> !ismissing(row[course]), Ravenclaw)
            local h_arithmancy = filter(row -> !ismissing(row[course]), Hufflepuff)

            push!(scatter_plots, histogram(g_arithmancy[!, course], bins=20, label="Gryffindor", alpha=0.5, title=course, ylabel="Frequency", legend=:topleft, normed=true, fillcolor=:red))

            local g_ratio = (maximum(g_arithmancy[!, course]) - minimum(g_arithmancy[!, course]))
            local s_ratio = (maximum(s_arithmancy[!, course]) - minimum(s_arithmancy[!, course]))
            local r_ratio = (maximum(r_arithmancy[!, course]) - minimum(r_arithmancy[!, course]))
            local h_ratio = (maximum(h_arithmancy[!, course]) - minimum(h_arithmancy[!, course]))

            local s_bins = round(Int, s_ratio / g_ratio * 20)
            local r_bins = round(Int, r_ratio / g_ratio * 20)
            local h_bins = round(Int, h_ratio / g_ratio * 20)

            histogram!(s_arithmancy[!, course], bins=s_bins, label="Slytherin", alpha=0.5, normed=true, fillcolor=:green)
            histogram!(r_arithmancy[!, course], bins=r_bins, label="Ravenclaw", alpha=0.5, normed=true, fillcolor=:blue)
            histogram!(h_arithmancy[!, course], bins=h_bins, label="Hufflepuff", alpha=0.5, normed=true, fillcolor=:yellow)
        else
            scatter_plot = scatter(data[!, course1], data[!, course2],
                title=course1 * " vs " * course2,
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
end

plot(scatter_plots..., margin=15mm, size=(8000, 8000), xtickfont=font(15), ytickfont=font(15))
savefig("plots/pair_plots.png")