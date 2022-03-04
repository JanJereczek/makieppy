using CairoMakie;

##########################################################
############## Initialisation Functions ##################
##########################################################

function init_fig(plotcons)
    return Figure(resolution = plotcons.resolution, font = "cmunrm.ttf", fontsize = plotcons.fontsize)
end

function init_axs(fig::Figure, plotcons, var_list::Vector{String})
    nrows, ncols = plotcons.nrows, plotcons.ncols
    axs = [Axis(fig[i, j][1, 1], title = get_var(i, j, ncols, var_list) ) for j in 1:ncols, i in 1:nrows]
    return axs
end

function init_hm_axs(fig::Figure, plotcons, var_list::Vector{String}, exp_key::String, extrema_dict::Dict)
    nrows, ncols = plotcons.nrows, plotcons.ncols
    axs = [Axis(fig[i, j][1, 1], title = get_var(i, j, ncols, var_list) ) for j in 1:ncols, i in 1:nrows]
    cbs = [Colorbar(fig[i, j][1, 2], limits = extrema_dict[exp_key][get_var(i, j, ncols, var_list)] ) for j in 1:ncols, i in 1:nrows]
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
    plotcons::InitPlotConst,
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
                if l == hl_ix
                    lines!(axs[k], nc_dict[exp][var], color = :blue, line_width = 2)
                else
                    lines!(axs[k], nc_dict[exp][var], color = :lightgray)
                end
            end
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
    plotcons::InitPlotConst,
    extrema_dict::Dict,
    )

    nrows, ncols = plotcons.nrows, plotcons.ncols
    for i in 1:nrows
        for j in 1:ncols
            k = get_k(i, j, ncols)
            heatmap!( axs[k], nc_dict[ exp_key ][ var_list[k] ][:, :, tframe], colorrange = extrema_dict[exp_key][var_list[k]] )
            # heatmap!( axs[k], nc_dict[ exp_key ][ var_list[k] ][:, :, tframe] )
        end
    end
    return fig
end