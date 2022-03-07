using CairoMakie;

##########################################################
############## Initialisation Functions ##################
##########################################################

function init_fig(plotcons::Any)
    return Figure(resolution = plotcons.resolution, font = "cmunrm.ttf", fontsize = plotcons.fontsize)
end

function init_axs(fig::Figure, plotcons::Any, var_list::Vector{String})
    nrows, ncols = plotcons.nrows, plotcons.ncols
    axs = [Axis(fig[i, j][1, 1], xlabel = L"$t$ [s]", ylabel = plotcons.labels[get_var(i, j, ncols, var_list)] ) for j in 1:ncols, i in 1:nrows]
    return axs
end

function init_hm_axs(fig::Figure, plotcons::Any, var_list::Vector{String}, exp_key::String, extrema_dict::Dict)
    nrows, ncols = plotcons.nrows, plotcons.ncols
    axs = [Axis(fig[i, j][1, 1], title = plotcons.labels[get_var(i, j, ncols, var_list)] ) for j in 1:ncols, i in 1:nrows]
    cbs = [Colorbar(fig[i, j][1, 2], colormap = plotcons.colors[get_var(i, j, ncols, var_list)], limits = extrema_dict[exp_key][get_var(i, j, ncols, var_list)] ) for j in 1:ncols, i in 1:nrows]
    return axs
end

##########################################################
################## Update Functions ######################
##########################################################

function update_line(
    fig::Figure,
    axs, 
    nc_dict::Dict,
    var_list::Vector{String},
    plotcons::Any,
    hl_ix::Int,
    )

    nrows, ncols = plotcons.nrows, plotcons.ncols
    for i in 1:nrows
        for j in 1:ncols
            k = get_k(i, j, ncols)
            var = var_list[k]
            empty!(axs[k])
            for l in 1:length(nc_dict["nc_list"])
                exp = nc_dict["nc_list"][l]
                plot_var = nc_dict[exp][var]
                t = plotcons.dt1D * 0:(length(plot_var)-1)
                lines!(axs[k], t, nc_dict[exp][var], color = :lightgray)
                if l == hl_ix
                    global phl = plot_var
                    global thl = t
                end
            end
            lines!(axs[k], thl, phl, color = :royalblue4, line_width = 2)
        end
    end
    return fig
end

function update_hm_3D(
    fig::Figure,
    axs, 
    nc_dict::Dict,
    nc1D_dict::Dict,
    exp_key::String,
    tframe::Int,
    var_list::Vector{String},
    plotcons::Any,
    extrema_dict::Dict,
    )


    nrows, ncols = plotcons.nrows, plotcons.ncols
    for i in 1:nrows
        for j in 1:ncols
            k = get_k(i, j, ncols)
            heatmap!( axs[k], nc_dict[ exp_key ][ var_list[k] ][:, :, tframe], colorrange = extrema_dict[exp_key][var_list[k]] , colormap = plotcons.colors[ var_list[k] ])
        end
    end
    t = (tframe-1) * plotcons.dt3D
    tframe1D = floor(Int, t / plotcons.dt1D + 1)
    exp_key1D = string( chop_ncfile_tail(exp_key), "1D.nc" )
    ΔT = nc1D_dict[ exp_key1D ][ "hyst_f_now" ][ tframe1D ]

    text!(L"$t = $ %$(string( t )) yr", position = (30, 10), align = (:center, :center))
    text!(L"$\Delta T = $ %$(string( ΔT )) K", position = (80, 10), align = (:center, :center))
    return fig
end

function plot_diffhm_3D(
    nc_dict::Dict,
    exp_key1::String,
    exp_key2::String,
    tframe1::Int,
    tframe2::Int,
    var_list::Vector{String},
    plotcons::Any,
    )

    nrows, ncols = plotcons.nrows, plotcons.ncols
    fig = init_fig(plotcons)
    axs = [Axis(fig[i, j][1, 1], title = plotcons.labels[get_var(i, j, ncols, var_list)] ) for j in 1:ncols, i in 1:nrows]

    for i in 1:nrows
        for j in 1:ncols
            k = get_k(i, j, ncols)
            diff = nc_dict[ exp_key1 ][ var_list[k] ][:, :, tframe1] - nc_dict[ exp_key2 ][ var_list[k] ][:, :, tframe2]
            diff[1, 1] +=  1e-3     # avoid 0 differences for colorbar generation
            hm = heatmap!( axs[k], diff , colormap = plotcons.colors[ var_list[k] ])
            Colorbar(fig[i, j][1, 2], hm)
        end
    end
    return fig
end

function evolution_hmplot(frames::Vector{Int}, plotcons::Any, var::String, exp_key::String, extrema_dict::Dict)
    fig = init_fig(plotcons)
    nrows, ncols = plotcons.nrows, plotcons.ncols
    # t = 
    axs = [Axis(fig[i, j][1, 1], title = L"$t = $ %$(string( plotcons.dt3D * frames[ get_k(i, j, ncols) ] )) yr" ) for j in 1:ncols, i in 1:nrows]
    for i in 1:nrows
        for j in 1:ncols
            k = get_k(i, j, ncols)
            heatmap!( axs[k], nc3D_dict[exp_key][var][:, :, frames[k]], colorrange = extrema_dict[exp_key][var] , colormap = plotcons.colors[ var ])
        end
    end
    Colorbar(fig[:, ncols+1][1, 1], colormap = plotcons.colors[var], limits = extrema_dict[exp_key][var] )
    return fig
end