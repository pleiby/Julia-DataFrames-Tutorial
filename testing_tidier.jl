# Testing Tidier.jl

# See: Learning Julia with #TidyTuesday and Tidier.jl by Nicola Rennie
# Source: https://nrennie.rbind.io/blog/learning-julia-with-tidytuesday-tidier/?panelset1=julia2

using Pkg;
Pkg.add("Tidier", "TidierPlots", "AlgebraOfGraphics", "CairoMakie", "DataFrames");
using Pkg;
Pkg.add("UrlDownload");

using Tidier
using UrlDownload
using DataFrames

# download the data from the #TidyTuesday GitHub repo
#  <https://github.com/rfordatascience/tidytuesday/blob/master/data/2023/2023-04-11/readme.md>
production = urldownload("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2023/2023-04-11/egg-production.csv") |> DataFrame;


# The key difference here is chaining in Julia.
# In practice, add an @ before each function, rather than a |>.
# The other difference here is that we specify when to begin and end the chain,
# but otherwise - the similarities [with R] are striking.
plot_data = @chain production begin
    @filter(prod_process == "cage-free (organic)") # filter for cage free
    @mutate(n = n_eggs / 1_000_000)
end

# Data visualisation in Julia
#  There are a lot of different plotting packages in Julia, 
#  Here, try AlgebraOfGraphics.jl, a data visualisation language for Julia,
#  that’s built on the idea of combining different building blocks (using + and *) to make plots.
#  The principles are similar to {ggplot2} - where plots are made of layers.
#  There’s even a theme_ggplot2()
using AlgebraOfGraphics, CairoMakie, Tidier

xy = data(plot_data) * mapping(:observed_month, :n) * visual(Lines)
with_theme(theme_ggplot2()) do
    draw(xy; axis=(xlabel="", ylabel="Cage-free organic eggs produced (millions)"))
end


# TidierPlots.jl.
# TidierPlots.jl brings a reimplementation of {ggplot2} to Julia,
# which is built on top of AlgebraOfGraphics.jl. 
# Similar to {ggplot2} - can almost copy and paste R code - and just add an @ at the start of each line.
using TidierPlots
@ggplot(plot_data, aes(x=observed_month, y=n)) +
@geom_point() +
@labs(x = "",
    y = "Cage-free organic eggs produced (millions)")

