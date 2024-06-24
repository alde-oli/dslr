using CSV
using DataFrames
using Plots

# Charger le fichier CSV dans un DataFrame
file_path = "datasets/dataset_train.csv"
df = CSV.read(file_path, DataFrame)

# Afficher les premières lignes du DataFrame pour vérifier le chargement
Gryffindor = filter(row -> occursin("Gryffindor", row."Hogwarts House"), df)
Slytherin = filter(row -> occursin("Slytherin", row."Hogwarts House"), df)
Ravenclaw = filter(row -> occursin("Ravenclaw", row."Hogwarts House"), df)
Hufflepuff = filter(row -> occursin("Hufflepuff", row."Hogwarts House"), df)


courses = names(df)[7:end]

hists = []

for course in courses
    local g_arithmancy = filter(row -> !ismissing(row[course]), Gryffindor)
    local s_arithmancy = filter(row -> !ismissing(row[course]), Slytherin)
    local r_arithmancy = filter(row -> !ismissing(row[course]), Ravenclaw)
    local h_arithmancy = filter(row -> !ismissing(row[course]), Hufflepuff)

    push!(hists, histogram(g_arithmancy[!, course], bins=20, label="Gryffindor", alpha=0.5, title=course, xlabel=course, ylabel="Frequency", legend=:topleft, normed=true))


    local g_ratio = (maximum(g_arithmancy[!, course]) - minimum(g_arithmancy[!, course]))
    local s_ratio = (maximum(s_arithmancy[!, course]) - minimum(s_arithmancy[!, course]))
    local r_ratio = (maximum(r_arithmancy[!, course]) - minimum(r_arithmancy[!, course]))
    local h_ratio = (maximum(h_arithmancy[!, course]) - minimum(h_arithmancy[!, course]))

    local s_bins = round(Int, s_ratio / g_ratio * 20)
    local r_bins = round(Int, r_ratio / g_ratio * 20)
    local h_bins = round(Int, h_ratio / g_ratio * 20)

    histogram!(s_arithmancy[!, course], bins=s_bins, label="Slytherin", alpha=0.5, normed=true)
    histogram!(r_arithmancy[!, course], bins=r_bins, label="Ravenclaw", alpha=0.5, normed=true)
    histogram!(h_arithmancy[!, course], bins=h_bins, label="Hufflepuff", alpha=0.5, normed=true)


    # we will have multiple plots in the same picture, so we need to use the plot function
end
plot(hists..., size=(1500, 1500))



savefig("histogram_arithmancy.png")


