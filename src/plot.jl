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
        xlabel = (i == nrows) ? L"$t$ [kyr]" : " ",
        ylabel = plotcons.labels[get_var(i, j, ncols, var_list)],
        xminorticks = IntervalsBetween(10),
        yminorticks = IntervalsBetween(10),
        xminorgridvisible = true,
        yminorgridvisible = true,
        ) for j in 1:ncols, i in 1:nrows]
    return axs
end
# Initalise nrows*ncols axis for plotting heatmaps of the 3D variables.
function init_hm_axs(fig::Figure, plotcons::Any, var_list::Vector{String}, exp_key::String, extrema_dict::Dict)
    nrows, ncols = plotcons.nrows, plotcons.ncols
    axs = [Axis(fig[i, j][1, 1], aspect=DataAspect() ) for j in 1:ncols, i in 1:nrows]
    cbs = [Colorbar(
        fig[i, j][1, 2],
        colormap = plotcons.colors[get_var(i, j, ncols, var_list)],
        limits = extrema_dict[exp_key][get_var(i, j, ncols, var_list)],
        height = Relative(3/4),
        label = plotcons.labels[get_var(i, j, ncols, var_list)],
        lowclip = :white) for j in 1:ncols, i in 1:nrows]
    for ax in axs
        hidedecorations!(ax)
    end
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
    tlim,
    )

    t1, t2 = tlim
    nrows, ncols = plotcons.nrows, plotcons.ncols
    for i in 1:nrows
        for j in 1:ncols
            k = get_k(i, j, ncols)
            var = var_list[k]
            for l in 1:length(nc_dict["nc_list"])
                exp = nc_dict["nc_list"][l]
                plot_var = nc_dict[exp][var][1:downsample_factor:end-1]
                t = plotcons.dt1D .* downsample_factor .* ( 0:(length(plot_var)-1) ) ./ 1e3 # kyr
                i1, i2 = argmin( (t .- t1).^2 ), argmin( (t .- t2).^2 )
                lines!(axs[k], t[i1:i2], plot_var[i1:i2], color = :lightgray)
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
    tlim,
    )

    t1, t2 = tlim
    nrows, ncols = plotcons.nrows, plotcons.ncols
    var_dict = nc_dict[ nc_dict["nc_list"][hl_ix] ]
    for i in 1:nrows
        for j in 1:ncols
            k = get_k(i, j, ncols)
            var = var_list[k]
            plot_var = var_dict[var][1:downsample_factor:end-1]
            t = plotcons.dt1D .* downsample_factor .* ( 0:(length(plot_var)-1) ) ./ 1e3 # kyr
            i1, i2 = argmin( (t .- t1).^2 ), argmin( (t .- t2).^2 )
            pv = plot_var[i1:i2]

            delete!(axs[k], axs[k].scene[end])
            lines!(axs[k], t[i1:i2], pv, color = :royalblue4, line_width = 2)

            y1, y2 = minimum(pv), maximum(pv)
            ydiff = y2-y1
            y1, y2 = y1 - 0.1*ydiff, y2 + 0.1*ydiff
            limits!(axs[k], t1, t2, y1, y2) # x1, x2, y1, y2
        end
    end
    return fig
end

function get_bifurcation_diagram(ncAIS, ncWAIS, plotcons)
    exp_key_AIS = ncAIS[ "nc_list" ][1]
    exp_key_WAIS = ncWAIS[ "nc_list" ][1]
    fig = init_fig(plotcons)
    ax = Axis(
        fig[1, 1], 
        xlabel = L"$\Delta T$ [K]", 
        ylabel = L"$V_{\mathrm{ice, WAIS}}$ [mSLE]",
        xminorticks = IntervalsBetween(10),
        yminorticks = IntervalsBetween(10),
        xminorgridvisible = true,
        yminorgridvisible = true,
    )

    f = ncAIS[exp_key_AIS]["hyst_f_now"]
    V = ncWAIS[exp_key_WAIS]["V_sle"]
    lines!(ax, f, V)
    return fig
end

function plot_control(plotcons, nc_dict)
    var_list = ["hyst_f_now", "V_ice"]

    fig_ctrl = init_fig( plotcons )
	axs_ctrl = init_axs(fig_ctrl, plotcons, var_list)
    tend = 5000
    nt = Int(tend / plotcons.dt1D) + 1
    t = range(0, stop=tend, length=nt) ./ 1e3
    lines!(axs_ctrl[1], t, nc_dict[ nc_dict["nc_list"][ 1 ] ][var_list[1]][1:nt])
    lines!(axs_ctrl[2], t, nc_dict[ nc_dict["nc_list"][ 1 ] ][var_list[2]][1:nt], label = "Yelmo")
    hlines!(axs_ctrl[2], [26.5], color = :red, label = "Present-day observation")
    axislegend(position = :lb)
    ylims!(axs_ctrl[2], (20, 27))
    return fig_ctrl
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
            heatmap!(
                axs[k],
                nc_dict[ exp_key ][ var_list[k] ][:, :, tframe],
                colorrange = extrema_dict[exp_key][var_list[k]] ,
                colormap = plotcons.colors[ var_list[k] ],
                lowclip = :white,
            )
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
            hidedecorations!(axs[k])
            diff = nc_dict[ exp_key1 ][ var_list[k] ][:, :, tframe1] - nc_dict[ exp_key2 ][ var_list[k] ][:, :, tframe2]
            diff[1, 1] +=  1e-3     # avoid 0 differences for colorbar generation
            hm = heatmap!( axs[k], diff , colormap = plotcons.colors[ var_list[k] ])
            Colorbar(fig[i, j][1, 2], hm)
        end
    end
    return fig
end

function evolution_hmplot(nc3D_dict::Dict, frames::Vector{Int}, plotcons::Any, var::String, exp_key::String, extrema_dict::Dict)
    fig = init_fig(plotcons)
    nrows, ncols = plotcons.nrows, plotcons.ncols
    axs = [Axis(fig[i, j][1, 1], title = L"$t = $ %$(string( plotcons.dt3D * frames[ get_k(i, j, ncols) ] )) yr" ) for j in 1:ncols, i in 1:nrows]
    for i in 1:nrows
        for j in 1:ncols
            k = get_k(i, j, ncols)
            hidedecorations!(axs[k])
            heatmap!(
                axs[k],
                nc3D_dict[exp_key][var][:, :, frames[k]],
                colorrange = extrema_dict[exp_key][var],
                colormap = plotcons.colors[ var ],
                lowclip = :white,
            )
        end
    end
    Colorbar(fig[:, ncols+1][1, 1], colormap = plotcons.colors[var], limits = extrema_dict[exp_key][var], height = Relative(1/2), lowclip = :white, label = plotcons.labels[var])
    return fig
end

##########################################################
################## R-Tipping Plotting ####################
##########################################################

function scatter_tipping(f::Vector{Float64}, a::Vector{Float64}, e::Vector{Float64}, plotcons)
    fig = init_fig(plotcons)
    ax = Axis(
        fig[1, 1][1, 1], 
        xlabel = L"$a$ [K$ \, \mathrm{yr}^{-1}$]",
        ylabel = L"$\Delta T_{\max}$ [K]",
        xscale = log10,
        yminorticks = IntervalsBetween(5),
        yminorgridvisible = true,
    )
    
    shm = scatter!( ax, a, f, color = e, colormap = cgrad(:rainbow1, rev = true) )
    Colorbar(fig[1, 1][1, 2], shm, label = L"$V_\mathrm{ice}(t = t_{e})$ [mSLE]")
    return fig, ax
end

function hm_tipping(f::Vector{Float64}, a::Vector{Float64}, e::Vector{Float64}, plotcons)
    f_ext_nontipped = f .- 0.599
    e_ext_nontipped = maximum(e) .* ones( size(f_ext_nontipped) )
    a_ext_nontipped = a

    f_ext_tipped = f .+ 0.599
    e_ext_tipped = minimum(e) .* ones( size(f_ext_nontipped) )
    a_ext_tipped = a

    fig = init_fig(plotcons)
    ax = Axis(
        fig[1, 1][1, 1], 
        xlabel = L"$a$ [K$ \, \mathrm{yr}^{-1}$]",
        ylabel = L"$\Delta T_{\max}$ [K]",
        xscale = log10,
        yminorticks = IntervalsBetween(5),
        yminorgridvisible = true,
    )
    myblue = cgrad([:plum2, :lightblue1])
    # shm = heatmap!( ax, a, f, e, colormap = cgrad(:Blues_3, rev = true) )
    # heatmap!( ax, a_ext_nontipped, f_ext_nontipped, e_ext_nontipped, colormap = cgrad(:Blues_3, rev = true), colorrange = extrema(e) )
    # heatmap!( ax, a_ext_tipped, f_ext_tipped, e_ext_tipped, colormap = cgrad(:Blues_3, rev = true), colorrange = extrema(e) )
    shm = heatmap!( ax, a, f, e, colormap = myblue )
    heatmap!( ax, a_ext_nontipped, f_ext_nontipped, e_ext_nontipped, colormap = myblue, colorrange = extrema(e) )
    heatmap!( ax, a_ext_tipped, f_ext_tipped, e_ext_tipped, colormap = myblue, colorrange = extrema(e) )
    hlines!( ax, [ 2.8 ], color = :mediumpurple4)
    scatter!( ax, a, f, color = :black, line_width = 2 )
    Colorbar(fig[1, 1][1, 2], shm, label = L"$V_\mathrm{ice}(t = t_{e})$ [mSLE]", height = Relative(3/4) )
    return fig, ax
end

function scatter_ssp_point( ax, year, reference )
    s = load_ssp()
    ΔT, a = get_ssp( s, year, reference )

    clrs = [:darkorange, :red2, :darkred]
    l = [string("SSP2-", year) , string("SSP3-", year), string("SSP5-", year)]
    for i in 1:length(l)
        scatter!(ax, [a[i]], [ΔT[i]], color = clrs[i], markersize = 15, label = l[i])
    end
    axislegend("SSP Scenario-Year", position = :lb)
end

function scatter_ssp_path( ax, lb, ub, Δyr, reference )

    s = load_ssp()
    nscenarios = length( s["names"] ) - 1   # Historic record is not a scenario, therefore: -1
    years = lb:Δyr:ub
    nyears = length(years)

    ΔT_mat, a_mat = zeros( nscenarios, nyears ), zeros( nscenarios, nyears )
    for i in 1:nyears
        year = years[i]
        ΔT_mat[:, i], a_mat[:, i] = get_ssp( s, year, reference )
    end

    clrs = [:darkorange, :red2, :darkred]
    yrlbl = string(lb, " to ", ub)
    l = [string("SSP2: ", yrlbl) , string("SSP3: ", yrlbl), string("SSP5: ", yrlbl)]
    for i in 1:length(l)
        scatterlines!(ax, a_mat[i, :], ΔT_mat[i, :], color = clrs[i], markersize = range(10, stop = 20, length = nyears), label = l[i])
    end
    axislegend("SSP Scenario: Time Span", position = :lb)
end