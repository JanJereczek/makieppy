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
    append!(axs, Axis(fig[nrows + 1]) )
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
                t = plotcons.dt * 0:(length(plot_var)-1)
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

function update_hm_2D(
    fig::Figure,
    axs, 
    nc_dict::Dict,
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
    text!(L"$t = $ %$(string( (tframe-1) * plotcons.dt)) yr", position = (30, 10), align = (:center, :center))
    return fig
end

