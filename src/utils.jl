
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

function get_key(nc_list, exp_id)
    return nc_list[exp_id]
end

function get_timeframes(exp_key, nc3D_dict)
	nt = size( nc3D_dict[exp_key]["H_ice"] )[3]
    return 1:nt
end

function save_fig(prefix, filename, extension, fig)
    if (extension == "pdf") || (extension == "both")
        save(string(prefix, filename, ".pdf"), fig)
    end
    if (extension == "png") || (extension == "both")
        save(string(prefix, filename, ".png"), fig)
    end
end

function get_vars( filename )
    NCDataset( filename ) do ds
        global vars = keys(ds)
    end
    return vars
end

# function get_var_names(nc_list)
#     return keys( nc_list[ get_key(nc_list, 1) ] )
# end

# function load_data!( var_dict::Dict , var_list::Vector{String} )
#     for file in var_dict["nc_list"]
#         var_dict[file] = Dict()
#         NCDataset(file) do ds
#             for var in var_list
#                 var_dict[file][var] = copy(ds[var])
#             end
#         end
#     end
#     return var_dict
# end