using NCDatasets, Statistics;

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

function get_extrema(var_dict, var_list, lowerlim, upperlim, exp_list)
    extrema_dict = Dict()
    for exp in exp_list
        extrema_dict[exp] = Dict()
        i = 1
        for var in var_list
            extr = collect(extrema(var_dict[ exp ][ var ]))
            extrema_dict[exp][var] = tuple( max( lowerlim[i], extr[1] ), min( upperlim[i], extr[2] ) )
            # println( extrema_dict[exp][var] )
            i += 1
        end
    end
    return extrema_dict
end

function scatter_tipping(f::Vector{Float64}, a::Vector{Float64}, e::Vector{Float64}, plotcons)
    fig = init_fig(plotcons)
    ax = Axis(
        fig[1, 1][1, 1], 
        xlabel = L"$a$ [K/yr]",
        ylabel = L"$\Delta T_{\max}$ [K]",
        xscale = log10,
        yminorticks = IntervalsBetween(5),
        yminorgridvisible = true,
    )
    
    shm = scatter!( ax, a, f, color = e, colormap = cgrad(:rainbow1, rev = true) )
    Colorbar(fig[1, 1][1, 2], shm, label = L"$V_{ice}(t = t_{e})$ [$10^6$ cubic km]")
    return fig
end

function extract_ramp_parameters(filename::String)
    v = split(filename, ".")
    dtrmp = get_var_value(v, "dtrmp")
    fmx = get_var_value(v, "fmx")
    a = fmx / dtrmp
    return dtrmp, fmx, a
end

function get_var_value(v::Vector{SubString{String}}, varname::String)
    i = findall( v .== varname )[1]
    var = string( v[ i+1 ], ".", v[ i+2 ] )
    return parse(Float64, var)
end

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


# function remove_file(  )
# end

# function remove_var(  )
# end