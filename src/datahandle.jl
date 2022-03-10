using NCDatasets, Statistics;       # Load nc-files, statistical computation.

##########################################################
################ Dictionary operations  ##################
##########################################################
# Initialise and fill a dictionary with experiment_key = filename.
function init_dict( nc_list::Vector{String} )
    nc_dict = Dict()
    nc_dict["nc_list"] = nc_list
    return nc_dict
end

# Fill a dictionary with experiment_key = filename.
function load_data!( nc_dict::Dict , var_list::Vector{String} )
    for file in nc_dict["nc_list"]
        nc_dict[ file ] = Dict()
        NCDataset(file) do ds
            for var in var_list
                nc_dict[ file ][ var ] = copy( ds[ var ] )
            end
            # For 2D.nc we want to compute the grounding line too!
            if occursin.( "yelmo2D.nc", file )
                nc_dict[ file ][ "f_grnd" ] = copy( ds[ "f_grnd" ] )
                nc_dict[ file ][ "G" ] = similar( nc_dict[ file ][ "f_grnd" ] )
            end
        end
    end
    return nc_dict
end

# Get extrema of the variables over time for 2D plots.
function get_extrema(
    nc_dict::Dict,
    var_list::Vector{String},
    lowerlim::Vector{Float},
    upperlim::Vector{Float},
    )

    extrema_dict = Dict()
    for exp in nc_dict["nc_list"]
        extrema_dict[exp] = Dict()
        i = 1
        for var in var_list
            extr = collect(extrema(nc_dict[ exp ][ var ]))
            extrema_dict[exp][var] = tuple( max( lowerlim[i], extr[1] ), min( upperlim[i], extr[2] ) )
            i += 1
        end
    end
    return extrema_dict
end

# Clip values for plotting.
function clip_extrema()
end

##########################################################
############# Ramp experiment functions   ################
##########################################################
# Get the value after a specified keyword in a string seperated by dots.
function get_var_value(v::Vector{SubString{String}}, varname::String)
    i = findall( v .== varname )[1]
    var = string( v[ i+1 ], ".", v[ i+2 ] )
    return parse(Float64, var)
end
# Get the ramp parameters out of the file name.
function extract_ramp_parameters(filename::String)
    v = split(filename, ".")
    dtrmp = get_var_value(v, "dtrmp")
    fmx = get_var_value(v, "fmx")
    a = fmx / dtrmp
    return dtrmp, fmx, a
end
# Get the final value of a specified variable.
function get_final_value(
    nc_dict::Dict,
    varname::String,
    avg_wdw::Int,
    )

    list = nc_dict["nc_list"]
    n = length(list)
    fmx_vec, a_vec, end_vec = zeros(n), zeros(n), zeros(n)

    for i in 1:n
        exp_key = list[i]
        dtrmp, fmx, a = extract_ramp_parameters(exp_key)
        end_state = mean(nc_dict[ exp_key ][varname][(end - avg_wdw):(end - 1)])
        fmx_vec[i], a_vec[i], end_vec[i] = fmx, a, end_state
    end
    return fmx_vec, a_vec, end_vec
end