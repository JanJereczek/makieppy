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

function add_data_field!( var_list, nc_dict1, nc_dict2, var)
    nclist1, nclist2 = nc_dict1["nc_list"], nc_dict2["nc_list"]
    for i in 1:length(nclist1)
        nc_dict1[nclist1[i]][var] = nc_dict2[nclist2[i]][var]
    end
    push!(var_list, var)
    return var_list, nc_dict1
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
        ssp_dict[ name ] = DataFrame( CSV.File( string(datadir("SSP/"), name, ".csv" ) ) )
        ssp_dict[ string(name, "_interp") ] = LinearInterpolation( ssp_dict[ name ][:, 1], ssp_dict[ name ][:, 2] )
        println( ssp_dict[ name ] )
    end
    return ssp_dict
end
# Get forcing and mean rate for a given year
function get_ssp( s, year, reference )

    if reference == "industrial"
        ref_year = 2014
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

function extract_calving!(var_list, nc1D_dict, path)
    nc3D_list = get_nc_lists(path, "yelmo2D.nc");
    dt3D = get_dt( nc3D_list );

    var3D_list = ["calv"]
    nc3D_dict = init_dict( nc3D_list );
    nc3D_dict = load_data!( nc3D_dict, var3D_list );

    dt1D = 1.0

    nc1D_list, nc3D_list = nc1D_dict["nc_list"], nc3D_dict["nc_list"]
    for i in 1:length(nc1D_list)
        exp1, exp3 = nc1D_list[i], nc3D_list[i]
        C = nc3D_dict[exp3]["calv"]
        n1, n2, n3 = size(C)
        c = zeros( n3 )

        for i in 1:n3
            c[i] = -mean(C[:, :, i])
        end
        c[1] = c[2]

        t3 = 0:dt3D:dt3D*(n3-1)
        interp_linear = LinearInterpolation(t3, c)

        t1 = 0:dt1D:dt3D*(n3-1)
        nc1D_dict[exp1]["calv"] = interp_linear.(t1)
    end
    push!(var_list, "calv")
    return var_list, nc1D_dict
end
