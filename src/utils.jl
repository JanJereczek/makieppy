# Get all the nc-files with a specified suffix within a folder.
function get_nc_lists( path::String, suffix::String )
    nc_list = String[]
    wdir = walkdir(path)
    for (root, dirs, files) in wdir
        for file in files
            if occursin(suffix, joinpath(root, file))
                push!(nc_list, joinpath(root, file))
            end
        end
    end
    return nc_list
end

# Filter the file list by only choosing some of them based on index vector.
function filter_nc_list( nc_list::Vector{String}, ixs::Vector{Int} )
    return nc_list = nc_list[ ixs ]
end

# Compute k-value associated with nested i,j loop.
function get_k( i::Int, j::Int, nj::Int )
    return (i-1)*nj + j
end

# Get the k-th variable.
function get_var( i::Int, j::Int, nj::Int, var_list::Vector{String} )
    k = get_k(i, j, nj)
    return var_list[k]
end

# Removes "1D.nc" or "2D.nc" in key.
function chop_ncfile_tail( key::String )
    return chop(key, head = 0, tail = 5)
end

# Get the key associated with an index.
function get_key(nc_list, exp_id)
    return nc_list[exp_id]
end

# Compute the number of frames present in an experiment.
function get_timeframes(exp_key, nc3D_dict)
	nt = size( nc3D_dict[exp_key]["H_ice"] )[3]
    return 1:nt
end

# Save a figure in pdf, png or both.
function save_fig(prefix, filename, extension, fig)
    if (extension == "pdf") || (extension == "both")
        save(string(prefix, filename, ".pdf"), fig)
    end
    if (extension == "png") || (extension == "both")
        save(string(prefix, filename, ".png"), fig)
    end
end

# Get the names of the variables in an nc-file.
function get_vars( filename )
    tmp = Dict()
    NCDataset( filename ) do ds
        tmp["var_names"] = keys(ds)
    end
    return tmp["var_names"]
end

# Get the timestep for a list of experiments. 
function extract_dt( nc_dict::Dict )
    for exp_key in nc_dict[ "nc_list" ]
        NCDataset( exp_key ) do ds
            nc_dict[ exp_key ][ "dt" ] = ds["time"][2] - ds["time"][1]
        end
    end
    return nc_dict
end

function get_ncols(list::Vector{String}, nrows::Int)
    n = length(list)
    return Int(ceil(n / nrows))
end

function get_resolution( nrows::Int, ncols::Int, base::Int)
    return ncols*base, nrows*base
end