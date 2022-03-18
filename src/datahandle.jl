using NCDatasets, Statistics, CSV, DataFrames, Interpolations


function get_dt( nc_list )
    file = nc_list[ 1 ]
    NCDataset(file) do ds
        global dt = ds[ "time" ][ 2 ] - ds[ "time" ][ 1 ]
    end
    println(dt)
    return dt
end

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
        if !( file in keys(nc_dict) )   # Only initialise if non-existing.
            nc_dict[ file ] = Dict()
        end
        NCDataset(file) do ds
            for var in var_list
                if !( var in keys(nc_dict[ file ]) )   # Only load if empty.
                    nc_dict[ file ][ var ] = copy( ds[ var ] )
                end
            end
            # # For 2D.nc we want to compute the grounding line too!
            # if occursin.( "yelmo2D.nc", file )
            #     nc_dict[ file ][ "f_grnd" ] = copy( ds[ "f_grnd" ] )
            #     nc_dict[ file ][ "G" ] = similar( nc_dict[ file ][ "f_grnd" ] )
            # end
        end
    end
    return nc_dict
end

# Initialise the grounding line computation by loading the needed variable.
function init_grline!( nc_dict::Dict )
    for file in nc_dict["nc_list"]
        NCDataset(file) do ds
            if !( "f_grnd" in keys(nc_dict[ file ]) )   # Only load if empty.
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
    lowerlim::Vector{Float64},
    upperlim::Vector{Float64},
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
    fmx = get_var_value(v, "fmx")
    if "dtrmp" in v
        dtrmp = get_var_value(v, "dtrmp")
        a = fmx / dtrmp
    elseif "dfdtmx" in v
        a = get_var_value(v, "dfdtmx")
    end
    return fmx, a
end
# Get the final value of a specified variable.
function get_final_value(
    nc_dict::Dict,
    varname::String,
    avg_wdw::Int,
    final_frame::Int,
    )

    list = nc_dict["nc_list"]
    n = length(list)
    fmx_vec, a_vec, end_vec = zeros(n), zeros(n), zeros(n)

    for i in 1:n
        exp_key = list[i]
        fmx, a = extract_ramp_parameters(exp_key)
        end_state = mean(nc_dict[ exp_key ][varname][(final_frame - avg_wdw):(final_frame - 1)])
        fmx_vec[i], a_vec[i], end_vec[i] = fmx, a, end_state
    end
    return fmx_vec, a_vec, end_vec
end
##########################################################
############# Ramp experiment functions   ################
##########################################################
# 
function load_ssp()
    ssp_dict = Dict()
    names = ["SSP2", "SSP3", "SSP5", "History"]
    ssp_dict["names"] = names
    for name in names
        ssp_dict[ name ] = DataFrame( CSV.File( string("data/SSP/", name, ".csv" ) ) )
        ssp_dict[ string(name, "_interp") ] = LinearInterpolation( ssp_dict[ name ][:, 1], ssp_dict[ name ][:, 2] )
    end
    return ssp_dict
end
# Get forcing and mean rate for a given year
function get_ssp( s, year, reference )

    if reference == "industrial"
        ref_year = 2000
        ref = s["History_interp"](ref_year)
    elseif reference == "pre-industrial"
        ref_year = 1850
        ref = 0
    end
    
    proj = [ s["SSP2_interp"](year), s["SSP3_interp"](year), s["SSP5_interp"](year) ]
    ΔT = proj .- ref
    a = ΔT ./ ( year-ref_year )
    return ΔT, a
end