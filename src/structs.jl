# Store the plotting constants in a struct.
mutable struct InitPlotConst
    nrows::Int
    ncols::Int
    fontsize::Int
    resolution::Tuple{Int, Int}
    colors::Dict
    labels::Dict
    dt1D::Int
    dt3D::Int
end