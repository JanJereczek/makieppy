
function get_nc_lists( path::String )
    nc1D_list = String[]
    nc2D_list = String[]
    wdir = walkdir(path)
    for (root, dirs, files) in wdir
        for file in files
            if occursin("yelmo1D.nc", joinpath(root, file))
                push!(nc1D_list, joinpath(root, file))
            elseif occursin("yelmo2D.nc", joinpath(root, file))
                push!(nc2D_list, joinpath(root, file))
            end
        end
    end
    return nc1D_list, nc2D_list
end

function filter_nc_list( nc_list::Vector{String}, ixs::Vector{Int} )
    return nc_list = nc_list[ ixs ]
end

function get_k(i::Int, j::Int, nj::Int)
    return (i-1)*nj + j
end

function get_var(i, j, nj, var_list)
    k = get_k(i, j, nj)
    return var_list[k]
end