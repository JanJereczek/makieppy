using NCDatasets;

function init_dict( nc_list::Vector{String} )
    var_dict = Dict()
    var_dict["nc_list"] = nc_list
    return var_dict
end

function load_data!( var_dict::Dict , var_list::Vector{String} )
    for file in var_dict["nc_list"]
        var_dict[file] = Dict()
        NCDataset(file) do ds
            for var in var_list
                var_dict[file][var] = copy(ds[var])
            end
        end
    end
    return var_dict
end

function get_extrema(var_dict, var_list, exp_list)
    extrema_dict = Dict()
    for exp in exp_list
        extrema_dict[exp] = Dict()
        for var in var_list
            extrema_dict[exp][var] = extrema(var_dict[ exp ][ var ])
        end
    end
    return extrema_dict
end

function remove_file(  )
end

function remove_var()
end