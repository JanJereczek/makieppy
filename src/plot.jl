using CairoMakie;   # Our bread and butter.

##########################################################
############## Initialisation Functions ##################
##########################################################
# Initialise any figure with latex font and pre-defined resolution and fontsize.
function init_fig(plotcons::Any)
    return Figure(resolution = plotcons.resolution, font = "cmunrm.ttf", fontsize = plotcons.fontsize)
end
# Initialise nrows*ncols axis for plotting 1D variables.
function init_axs(fig::Figure, plotcons::Any, var_list::Vector{String})
    nrows, ncols = plotcons.nrows, plotcons.ncols
    axs = [Axis(
        fig[i, j][1, 1],
        xlabel = L"$t$ [yr]",
        ylabel = plotcons.labels[get_var(i, j, ncols, var_list)],
        xminorticks = IntervalsBetween(5),
        yminorticks = IntervalsBetween(4),
        xminorgridvisible = true,
        yminorgridvisible = true,
        ) for j in 1:ncols, i in 1:nrows]
    return axs
end
# Initalise nrows*ncols axis for plotting heatmaps of the 3D variables.
function init_hm_axs(fig::Figure, plotcons::Any, var_list::Vector{String}, exp_key::String, extrema_dict::Dict)
    nrows, ncols = plotcons.nrows, plotcons.ncols
    axs = [Axis(fig[i, j][1, 1], title = plotcons.labels[get_var(i, j, ncols, var_list)] ) for j in 1:ncols, i in 1:nrows]
    cbs = [Colorbar(fig[i, j][1, 2], colormap = plotcons.colors[get_var(i, j, ncols, var_list)], limits = extrema_dict[exp_key][get_var(i, j, ncols, var_list)] ) for j in 1:ncols, i in 1:nrows]
    # get_crrnt_grline( nc_dict::Dict, key, frame )
    # get_ref_grline!( pd_dict::Dict )
    return axs
end

##########################################################
##################### 1D Plotting ########################
##########################################################

function init_lines(
    axs, 
    nc_dict::Dict,
    var_list::Vector{String},
    plotcons::Any,
    downsample_factor::Int,
    )

    nrows, ncols = plotcons.nrows, plotcons.ncols
    for i in 1:nrows
        for j in 1:ncols
            k = get_k(i, j, ncols)
            var = var_list[k]
            for l in 1:length(nc_dict["nc_list"])
                exp = nc_dict["nc_list"][l]
                plot_var = nc_dict[exp][var][1:downsample_factor:end-1]
                t = plotcons.dt1D .* downsample_factor .* 0:(length(plot_var)-1)
                lines!(axs[k], t, plot_var, color = :lightgray)
            end
        end
    end
end

function update_line(
    fig::Figure,
    axs, 
    nc_dict::Dict,
    var_list::Vector{String},
    plotcons::Any,
    hl_ix::Int,
    downsample_factor::Int,
    )

    nrows, ncols = plotcons.nrows, plotcons.ncols
    var_dict = nc_dict[ nc_dict["nc_list"][hl_ix] ]
    for i in 1:nrows
        for j in 1:ncols
            k = get_k(i, j, ncols)
            var = var_list[k]
            var_hl = var_dict[var][1:downsample_factor:end-1]
            t_hl = plotcons.dt1D * downsample_factor * 0:(length(var_hl)-1)

            delete!(axs[k], axs[k].scene[end])
            lines!(axs[k], t_hl, var_hl, color = :royalblue4, line_width = 2)
        end
    end

    return fig
end

##########################################################
##################### 3D Plotting ########################
##########################################################
# 3D: 2D plots over time!
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
    ΔT = round(nc1D_dict[ exp_key1D ][ "hyst_f_now" ][ tframe1D ]; digits=2)
    text!(axs[end], L"$t = $ %$(string( t )) yr", position = (30, 10), align = (:center, :center))
    text!(axs[end], L"$\Delta T = $ %$(string( ΔT )) K", position = (100, 10), align = (:center, :center))

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

##########################################################
################## R-Tipping Plotting ####################
##########################################################

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