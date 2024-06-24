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



course = "Divination"


g_arithmancy = filter(row -> !ismissing(row[:, "Divination"]), Gryffindor)
s_arithmancy = filter(row -> !ismissing(row."Divination"), Slytherin)
r_arithmancy = filter(row -> !ismissing(row."Divination"), Ravenclaw)
h_arithmancy = filter(row -> !ismissing(row."Divination"), Hufflepuff)

# Divination histogram
# Create a histogram of the Divination column for Gryffindor with 20 bins
# Calculate the ratio of the range (max - min) to the number of bins for all the houses
# Use this ratio to create histograms with the same bar width for all the houses
# The histogram uses percentage values on the y-axis rather than counts
test = histogram(g_arithmancy."Divination", bins=20, label="Gryffindor", alpha=0.5, title="Divination Histogram", xlabel="Divination", ylabel="Frequency", legend=:topleft, normed=true)


g_ratio = (maximum(g_arithmancy."Divination") - minimum(g_arithmancy."Divination")) 
s_ratio = (maximum(s_arithmancy."Divination") - minimum(s_arithmancy."Divination")) 
r_ratio = (maximum(r_arithmancy."Divination") - minimum(r_arithmancy."Divination")) 
h_ratio = (maximum(h_arithmancy."Divination") - minimum(h_arithmancy."Divination")) 

s_bins = round(Int,s_ratio / g_ratio * 20)
r_bins = round(Int,r_ratio / g_ratio * 20)
h_bins = round(Int,h_ratio / g_ratio * 20)

histogram!(s_arithmancy."Divination", bins=s_bins, label="Slytherin", alpha=0.5, normed=true)
histogram!(r_arithmancy."Divination", bins=r_bins, label="Ravenclaw", alpha=0.5, normed=true)
histogram!(h_arithmancy."Divination", bins=h_bins, label="Hufflepuff", alpha=0.5, normed=true)


# we will have multiple plots in the same picture, so we need to use the plot function
plot(test, histogram(g_arithmancy."Divination", bins=20, label="Gryffindor", alpha=0.5, title="Divination Histogram", xlabel="Divination", ylabel="Frequency", legend=:topleft, normed=true))




savefig("histogram_arithmancy.png")


