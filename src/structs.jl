##########################################################
################ Struct Construction  ####################
##########################################################

mutable struct InitPlotConst
    nrows::Int
    ncols::Int
    fontsize::Int
    resolution::Tuple{Int, Int}
    colors::Dict
    labels::Dict
    dt::Int
end