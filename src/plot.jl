using CairoMakie;   # Our bread and butter.

##########################################################
############## Initialisation Functions ##################
##########################################################
# Initialise any figure with latex font and pre-defined resolution and fontsize.
function init_fig(plotcons::Any)
    return Figure(resolution = plotcons.resolution, font = srcdir("cmunrm.ttf"), fontsize = plotcons.fontsize)
end
# Initialise nrows*ncols axis for plotting 1D variables.
function init_axs(fig::Figure, plotcons::Any, var_list::Any)
    nrows, ncols = plotcons.nrows, plotcons.ncols
    axs = [Axis(
        fig[i, j][1, 1],
        xlabel = (i == nrows) ? L"Time (kyr) $\,$" : " ",
        ylabel = plotcons.labels[get_var(i, j, ncols, var_list)],
        xminorticks = IntervalsBetween(10),
        yminorticks = IntervalsBetween(10),
        xminorgridvisible = true,
        yminorgridvisible = true,
        xticksvisible = (i == nrows) ? true : false,
        xticklabelsvisible = (i == nrows) ? true : false,
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
    var_list::Any,
    plotcons::Any,
    downsample_factor::Int;
    tlim = false,
    )

    nrows, ncols = plotcons.nrows, plotcons.ncols
    for i in 1:nrows
        for j in 1:ncols
            k = get_k(i, j, ncols)
            var_sublist = var_list[k]
            for var in var_sublist
                for l in 1:length(nc_dict["nc_list"])
                    exp = nc_dict["nc_list"][l]
                    plot_var = nc_dict[exp][var][1:downsample_factor:end-1]
                    t = plotcons.dt1D .* downsample_factor .* ( 0:(length(plot_var)-1) ) ./ 1e3 # kyr
                    if tlim == false
                        lines!(axs[k], t, plot_var, color = :lightgray)
                    else
                        t1, t2 = tlim
                        i1, i2 = argmin( (t .- t1).^2 ), argmin( (t .- t2).^2 )
                        lines!(axs[k], t[i1:i2], plot_var[i1:i2], color = :lightgray)
                    end
                end
            end
        end
    end
end

function update_line(
    fig::Figure,
    axs, 
    nc_dict::Dict,
    var_list::Any,
    plotcons::Any,
    hl_ix,
    downsample_factor::Int;
    tlim = false,
    legendposition = :lb,
    )

    nrows, ncols = plotcons.nrows, plotcons.ncols
    var_dict = nc_dict[ nc_dict["nc_list"][hl_ix] ]
    for i in 1:nrows
        for j in 1:ncols
            k = get_k(i, j, ncols)
            var_sublist = var_list[k]
            delete!(axs[k], axs[k].scene[end])
            total = 0.
            for var in var_sublist
                plot_var = var_dict[var][1:downsample_factor:end-1]
                global t = plotcons.dt1D .* downsample_factor .* ( 0:(length(plot_var)-1) ) ./ 1e3 # kyr

                if tlim != false
                    t1, t2 = tlim
                    i1, i2 = argmin( (t .- t1).^2 ), argmin( (t .- t2).^2 )
                    global t = t[i1:i2]
                    plot_var = plot_var[i1:i2]
                end
                lines!(axs[k], t, plot_var, line_width = 2, label = plotcons.labels[var]) #, color = :royalblue4

                total = total .+ plot_var
                # y1, y2 = minimum(plot_var), maximum(plot_var)
                # ydiff = y2-y1
                # y1, y2 = y1 - 0.1*ydiff, y2 + 0.1*ydiff
                if tlim != false
                    # limits!(axs[k], t1, t2, y1, y2) # x1, x2, y1, y2
                    xlims!(axs[k], t1, t2)
                end
            end

            if length(var_sublist) >= 2
                # lines!(axs[k], t, total, label = "total")
                axislegend(axs[k], position = legendposition)
            end
        end
    end
    return fig
end

function update_lines(
    fig::Figure,
    axs, 
    nc_dict::Dict,
    var_list::Any,
    plotcons::Any,
    hl_ix,
    downsample_factor::Int
    )

    nrows, ncols = plotcons.nrows, plotcons.ncols
    nhl = 5
    for i in 1:nrows
        for j in 1:ncols
            k = get_k(i, j, ncols)
            var_sublist = var_list[k]
            for var in var_sublist
                for l in 0:nhl
                    if var == "bmb"
                        df = 10
                    else
                        df = downsample_factor
                    end
                    var_dict = nc_dict[ nc_dict["nc_list"][hl_ix + l] ]
                    plot_var = var_dict[var][1:df:end-1]
                    t = plotcons.dt1D .* df .* ( 0:(length(plot_var)-1) ) ./ 1e3 # kyr
                    lines!(axs[k], t, plot_var, linewidth = 2, label = plotcons.labels[var]) #, color = :royalblue4
                end
            end

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
        xlabel = L"Local atmospheric temperature anomaly (K) $\,$", 
        ylabel = L"Sea-level equivalent ice volume (mSLE) $\,$",
        xminorticks = IntervalsBetween(10),
        yminorticks = IntervalsBetween(10),
        xminorgridvisible = true,
        yminorgridvisible = true,
        xticklabelcolor = :black,
    )

    ax2 = Axis(
        fig[1, 1],
        xlabel = L"Local oceanic temperature anomaly (K) $\,$",
        xaxisposition = :top,
    )
    # ax3 = Axis(
    #     fig[1, 1],
    #     xlabel = L"Global temperature anomaly (K) $\,$",
    #     xaxisposition = :bottom,
    #     xticklabelcolor = :lightgray,
    # )

    # hidespines!(ax2)
    # hidexdecorations!(ax2)

    f = ncAIS[exp_key_AIS]["hyst_f_now"]
    V = ncWAIS[exp_key_WAIS]["V_sle"]
    lines!(ax, f, V)
    lines!(ax2, f .* 0.25, V)
    # lines!(ax3, f ./ 1.8, V)

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
# Error plot
function error_plot_z(nc3D_dict, z_ref)

    fig = Figure(resolution = (1200, 1300), font = srcdir("cmunrm.ttf"), fontsize = 24)
    axs = [Axis(
        fig[i,j],
        aspect = DataAspect(),
        xlabel = ((i == 3) & (j == 2)) ? L"Observed PD surface elevation (m) $\,$" : " ",
        ylabel = ((i == 3) & (j == 2)) ? L"Simulated PD surface elevation (m) $\,$" : " ",
        xminorticks = IntervalsBetween(5),
        yminorticks = IntervalsBetween(5),
        xminorgridvisible = true,
        yminorgridvisible = true,
        xticksvisible = true,
        xticklabelsvisible = true,
        ) for i in 2:3, j in 1:2]

    for ax in axs[1:3]
        hidedecorations!(ax)
    end
    z_srf = nc3D_dict["/media/Data/Jan/yelmox_v1.75/aqef_retreat/yelmo2D.nc"]["z_srf"][:, :, 4]
    idline = collect(0:1:4500)
    lvls = 1e-3:500:4501
    cmap = cgrad( :ice, 10, categorical = true )
    c1 = contourf!( 
        axs[1],
        z_ref,
        levels = lvls,
        color = :white,
        colormap = :ice,
        linewidth = 2,
    )
    # c1 = heatmap!( 
    #     axs[1],
    #     z_ref,
    #     colorrange = (lvls[1], lvls[end]),
    #     colormap = cmap,
    #     lowclip = :lavenderblush,
    #     highclip = :white,
    #     linewidth = 2,
    # )
    c2 = contourf!(
        axs[3],
        z_srf,
        levels=lvls,
        color = :white,
        colormap = :ice,
        lowclip = :lavenderblush,
        linewidth = 2,
    )
    Colorbar(fig[1,:], c1, vertical = false, width = Relative(1/2), label = L"Surface elevation (m) $\,$")

    errormap = cgrad([:firebrick, :white, :cornflowerblue])
    hm = heatmap!( axs[2], z_srf .- z_ref, colorrange = [-400, 400], colormap = errormap, lowclip = :firebrick, highclip = :cornflowerblue)
    # hm = contourf!( axs[2], z_srf .- z_ref, levels = -400:(800/9):400, colormap = errormap)
    Colorbar(fig[4,:], hm, vertical = false, flipaxis = false, width = Relative(1/2), label = L"Surface elevation deviation (m) $\,$")

    zref_vec = collect( Iterators.flatten(z_ref))
    zsrf_vec = collect(Iterators.flatten(z_srf))
    sc = scatter!( axs[4], zref_vec, zsrf_vec, color = :grey20, markersize = 2 )
    ln = lines!( axs[4], idline, idline, color = :red, linewidth = 2)
    return fig
end

function error_plot_u(nc3D_dict, u_ref)

    fig = Figure(resolution = (1200, 1300), font = srcdir("cmunrm.ttf"), fontsize = 24)
    axs = [Axis(
        fig[i,j],
        aspect = DataAspect(),
        xlabel = ((i == 3) & (j == 2)) ? L"Observed PD surface velocity ($\mathrm{m \, yr^{-1}}$)" : " ",
        ylabel = ((i == 3) & (j == 2)) ? L"Simulated PD surface velocity ($\mathrm{m \, yr^{-1}}$)" : " ",
        xminorticks = IntervalsBetween(5),
        yminorticks = IntervalsBetween(5),
        xminorgridvisible = true,
        yminorgridvisible = true,
        xticksvisible = true,
        xticklabelsvisible = true,
        ) for i in 2:3, j in 1:2]
    for ax in axs[1:3]
        hidedecorations!(ax)
    end
    u_srf = nc3D_dict["/media/Data/Jan/yelmox_v1.75/aqef_retreat/yelmo2D.nc"]["uxy_s"][:, :, 4]
    idline = collect(0:1:2000)
    lvls = 10. .^ collect(-1:.5:3)

    c1 = contourf!( 
        axs[1],
        log10.( u_ref .+ 1e-5 ),
        color = :grey30,
        colormap = :dense,
        lowclip = :white,
        linewidth = 2,
        levels = log10.(lvls),
    )
    c2 = contourf!( 
        axs[3], 
        log10.( u_srf .+ 1e-5 ),
        color = :grey30, 
        colormap = :dense, 
        lowclip = :white,
        linewidth = 2,
        levels = log10.(lvls),
    )
    maplabels = [L"$10^{-1}$", L"$10^{0}$", L"$10^{1}$", L"$10^{2}$", L"$10^{3}$"]
    # maplabels = Dict( 0.1 => L"$10^{-1}$")
    # maplabels = log10.(lvls[1:2:end])
    Colorbar(fig[1,:], c1, vertical = false, width = Relative(1/2), ticks = (log10.(lvls[1:2:end]), maplabels),  label = L"Surface velocity ($\mathrm{m \, yr^{-1} }$)")
    xlims!(axs[1], 1, size(u_ref)[1])
    ylims!(axs[4], 1, size(u_ref)[2])

    errormap = cgrad([:firebrick, :white, :cornflowerblue], rev = true)
    hm = heatmap!( axs[2], u_srf .- u_ref, colorrange = [-400, 400], colormap = errormap, lowclip = :cornflowerblue, highclip = :firebrick)
    Colorbar(fig[4,:], hm, vertical = false, flipaxis = false, width = Relative(1/2), label = L"Surface velocity deviation ($\mathrm{m \, yr^{-1} }$)")

    xlims!(axs[4], lvls[1], 1e4)
    ylims!(axs[4], lvls[1], 1e4)
    axs[4].xscale = log10
    axs[4].yscale = log10
    uref_vec = collect( Iterators.flatten(u_ref))
    usrf_vec = collect(Iterators.flatten(u_srf))
    uref_vec_filt = uref_vec[ (uref_vec .> 0) .& (usrf_vec .> 0) ]
    usrf_vec_filt = usrf_vec[ (uref_vec .> 0) .& (usrf_vec .> 0) ]
    scatter!( axs[4], collect( Iterators.flatten(u_ref)), collect(Iterators.flatten(u_srf)), color = :grey20, markersize = 2 )
    lines!( axs[4], idline, idline, color = :red, linewidth = 2)
    return fig
end

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
    # ΔT = round(nc1D_dict[ exp_key1D ][ "hyst_f_now" ][ tframe1D ]; digits=2)
    text!(axs[end], L"$t = $ %$(string( t )) yr", position = (30, 10), align = (:center, :center))
    # text!(axs[end], L"$\Delta T = $ %$(string( ΔT )) K", position = (100, 10), align = (:center, :center))

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
    lowlim::Vector,
    uplim::Vector,
    diffmaps,
    )

    nrows, ncols = plotcons.nrows, plotcons.ncols
    fig = init_fig(plotcons)
    axs = [Axis(fig[i, j][1, 1]) for j in 1:ncols, i in 1:nrows]

    for i in 1:nrows
        for j in 1:ncols
            k = get_k(i, j, ncols)
            hidedecorations!(axs[k])
            diff = nc_dict[ exp_key1 ][ var_list[k] ][:, :, tframe1] - nc_dict[ exp_key2 ][ var_list[k] ][:, :, tframe2]
            diff[1, 1] +=  1e-3     # avoid 0 differences for colorbar generation
            hm = heatmap!( 
                axs[k],
                diff, 
                colormap = diffmaps[k],
                colorrange = [lowlim[k], uplim[k]],
            )
            Colorbar(fig[i, j][1, 2], hm, height=Relative(3/4), label = plotcons.labels[get_var(i, j, ncols, var_list)])
        end
    end
    return fig
end

# axs = [Axis(fig[i, j][1, 1], title = L"$t = $ %$(string( plotcons.dt3D * frames[ get_k(i, j, ncols) ] )) yr" ) for j in 1:ncols, i in 1:nrows]

function evolution_hmplot(
    nc3D_dict::Dict,
    ctrl_dict::Dict,
    frames::Vector{Int},
    plotcons::Any,
    var::String,
    exp_key::String,
    extrema_dict::Dict
    )

    fig = init_fig(plotcons)
    nrows, ncols = plotcons.nrows, plotcons.ncols
    ctrl = ctrl_dict["ts"][frames]
    axs = [ Axis(fig[i, j][1, 1], title = "$(string( ctrl[ get_k(i, j, ncols) ]  ) ) K") for j in 1:ncols, i in 1:nrows ]
    ref_grndline = nc3D_dict[exp_key]["f_grnd"][:, :, 1]
    for i in 1:nrows
        for j in 1:ncols
            k = get_k(i, j, ncols)
            hidedecorations!(axs[k])

            heatmap!(
                axs[k],
                nc3D_dict[exp_key]["z_bed"][:, :, frames[k]],
                # colorrange = extrema_dict[exp_key][var],
                colormap = plotcons.colors[ "z_bed" ],
                # lowclip = :white,
                transparency = true,
            )

            heatmap!(
                axs[k],
                nc3D_dict[exp_key][var][:, :, frames[k]],
                colorrange = extrema_dict[exp_key][var],
                colormap = plotcons.colors[ var ],
                lowclip = :white,
                highclip = :grey20,
                transparency = true,
            )
            contour!(axs[k], 
                nc3D_dict[exp_key]["lat2D"];
                color=:lightgray, 
                levels=-90:10:90,
            )
            contour!(axs[k], 
                nc3D_dict[exp_key]["lon2D"];
                color=:grey90, 
                levels=-180:60:180,
            )
            contour!(axs[k], 
                nc3D_dict[exp_key]["z_srf"][:, :, frames[k]];
                color=:grey60, 
                levels=1000:1000:5000,
            )
            contour!(
                axs[k],
                ref_grndline,
                levels = [0.99],
                linewidth = 2,
                color = :grey30,
            )
            contour!(
                axs[k],
                nc3D_dict[exp_key]["f_grnd"][:, :, frames[k]],
                levels = [0.99],
                linewidth = 2,
                color = :black,
            )
        end
    end
    Colorbar(fig[nrows+1, :], colormap = plotcons.colors[var], limits = extrema_dict[exp_key][var], width = Relative(1/2), lowclip = :white, highclip = :grey20, label = plotcons.labels[var], vertical = false)
    # Legend(fig[nrows+1, :], axs[nrows*ncols], framevisible = false, orientation = :horizontal, tellwidth = false, tellheight = true)
    
    elem_1 = [LineElement(color = :black, linestyle = nothing, linewidth = 5)]
    elem_2 = [LineElement(color = :grey30, linestyle = nothing, linewidth = 5)]
    elem_3 = [LineElement(color = :grey60, linestyle = nothing, linewidth = 5)]

    Legend(fig[nrows+2, :], [elem_1, elem_2, elem_3], ["Retreated grounding line", "Reference grounding line", "Surface elevation levels"], framevisible = false, orientation = :horizontal, tellwidth = false, tellheight = true)
    return fig
end

##########################################################
################## R-Tipping Plotting ####################
##########################################################

function scatter_tipping(f::Vector{Float64}, a::Vector{Float64}, e::Vector{Float64}, plotcons)
    fig = init_fig(plotcons)
    ax = Axis(
        fig[1, 1][1, 1], 
        xlabel = L"Ramp slope (K$ \, \mathrm{yr}^{-1}$)",
        ylabel = L"Maximal regional atmospheric warming (K) $ \, $",
        xscale = log10,
        yminorticks = IntervalsBetween(5),
        yminorgridvisible = true,
    )
    
    shm = scatter!( ax, a, f, color = e, colormap = cgrad(:rainbow1, rev = true) )
    Colorbar(fig[1, 1][1, 2], shm, label = L"Ice volume (mSLE) at $t = 30 \, \mathrm{kyr}$")
    return fig, ax
end

function hm_tipping(f::Vector{Float64}, a::Vector{Float64}, e::Vector{Float64}, plotcons)
    f_ext_nontipped = f .- 0.399
    e_ext_nontipped = maximum(e) .* ones( size(f_ext_nontipped) )
    a_ext_nontipped = a

    f_ext_tipped = f .+ 0.599
    e_ext_tipped = minimum(e) .* ones( size(f_ext_nontipped) )
    a_ext_tipped = a

    fig = init_fig(plotcons)
    ax = Axis(
        fig[1, 1][1, 1], 
        xlabel = L"Ramp slope (K$ \, \mathrm{yr}^{-1}$)",
        ylabel = L"Maximal regional atmospheric warming (K) $ \, $",
        xscale = log10,
        yminorticks = IntervalsBetween(5),
        yminorgridvisible = true,
    )
    myblue = cgrad([:gray80, :lightblue1])
    # myblue = cgrad([:plum1, :lightblue1]) azure, bisque, gray90, thistle2
    # myblue = cgrad([:peachpuff2, :lightblue1])
    # myblue = cgrad([:lightgreen, :lightblue1])
    
    # shm = heatmap!( ax, a, f, e, colormap = cgrad(:Blues_3, rev = true) )
    # heatmap!( ax, a_ext_nontipped, f_ext_nontipped, e_ext_nontipped, colormap = cgrad(:Blues_3, rev = true), colorrange = extrema(e) )
    # heatmap!( ax, a_ext_tipped, f_ext_tipped, e_ext_tipped, colormap = cgrad(:Blues_3, rev = true), colorrange = extrema(e) )
    shm = heatmap!( ax, a, f, e, colormap = myblue )
    heatmap!( ax, a_ext_nontipped, f_ext_nontipped, e_ext_nontipped, colormap = myblue, colorrange = extrema(e) )
    heatmap!( ax, a_ext_tipped, f_ext_tipped, e_ext_tipped, colormap = myblue, colorrange = extrema(e) )
    hlines!( ax, [ 2.8 ], color = :gray40, linewidth = 5, label = "Bifurcation point", linestyle = :dash)
    scatter!( ax, a, f, color = :gray15, linewidth = 2 )
    Colorbar(fig[1, 1][1, 2], shm, label = L"Ice volume (mSLE) at $t = 30 \, \mathrm{kyr}$", height = Relative(3/4) )
    axislegend(position = :lb)

    return fig, ax
end

function scatter_ssp_path( ax, lb, ub, Δyr, reference, ant_amplification )

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
    yrlbl = string(lb, " to ", ub+1)
    ΔT_mat = ΔT_mat .* ant_amplification
    # l = [string("SSP2: ", yrlbl) , string("SSP3: ", yrlbl), string("SSP5: ", yrlbl)]
    l = ["SSP2-4.5", "SSP3-7.0", "SSP5-8.5"]
    loc = [(:right, :top), (:right, :top), (:left, :top)]
    offset = [-1e-3, -1e-3, 1e-3]
    for i in 1:length(l)
        # lb = string.(l[i], ": ", string.(2060:10:2100))
        scatterlines!(ax, a_mat[i, :], ΔT_mat[i, :], color = clrs[i], label = l[i], linestyle = :dash, linewidth = 3)
        text!(
            ax, 
            string.(years), 
            position = [(a_mat[i, j] + offset[i], ΔT_mat[i, j] - 0.01) for j in 1:length(years)], 
            color = clrs[i],
            align = loc[i],
            markerspace = 10,
            textsize = 18,
        )
        # annotations!(ax, string.(2060:10:2100), a_mat[i, :], ΔT_mat[i, :], textsize = 0.1, color = clrs[i])
    end
    
    axislegend(position = :lb)
end