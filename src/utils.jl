
function get_nc_lists( path::String )
    nc1D_list = String[]
    nc3D_list = String[]
    wdir = walkdir(path)
    for (root, dirs, files) in wdir
        for file in files
            if occursin("yelmo1D.nc", joinpath(root, file))
                push!(nc1D_list, joinpath(root, file))
            elseif occursin("yelmo2D.nc", joinpath(root, file))
                push!(nc3D_list, joinpath(root, file))
            end
        end
    end
    return nc1D_list, nc3D_list
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

function chop_ncfile_tail(key)
    return chop(key, head = 0, tail = 5)    # removes "1D.nc" or "2D.nc"
end

function get_key(nc3D_list, exp_id)
    return nc3D_list[exp_id]
end

function get_timeframes(exp_key, nc3D_dict)
	nt = size( nc3D_dict[exp_key]["H_ice"] )[3]
    return 1:nt
end