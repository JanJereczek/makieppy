using CairoMakie, Colors;   # Our bread and butter.
include(srcdir("utils.jl"))
include(srcdir("datahandle.jl"))

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
                t = plotcons.dt1D .* downsample_factor .* ( 0:(length(plot_var)-1) ) ./ 1e3 # kyr

                if tlim != false
                    t1, t2 = tlim
                    i1, i2 = argmin( (t .- t1).^2 ), argmin( (t .- t2).^2 )
                    t = t[i1:i2]
                    plot_var = plot_var[i1:i2]
                end

                if var != "V_sle"
                    lines!(axs[k], t, plot_var, line_width = 2, label = plotcons.labels[var]) #, color = :royalblue4
                else
                    lines!(axs[k], t, plot_var, line_width = 2, label = L"Quasi-equilibrium $ \, $") #, color = :royalblue4
                    ttip1, ttip2 = 695, 846
                    ttip = t[ttip1:ttip2]
                    current_slrise_rate = 7.3 / 38          # m/kyr, Rignot 2018
                    slr_extrapol_projection = plot_var[ttip1] .- current_slrise_rate .* (ttip .- ttip[1])
                    lines!(axs[k], ttip, slr_extrapol_projection, label = L"Baseline $ \, $")
                    axislegend(axs[k], position = :lb)
                end

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

    c1 = colorant"lightskyblue1"
    c2 = colorant"midnightblue"
    clrs = range(c1, stop=c2, length=6)

    nrows, ncols = plotcons.nrows, plotcons.ncols
    nhl = 5
    # clrs = [:orange, :darkorange2, :skyblue1, :steelblue, :purple4, :grey20]
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
                    lines!(axs[k], t, plot_var, linewidth = 3, label = plotcons.labels[var], color = clrs[l+1]) #, color = :royalblue4
                end
            end

        end
    end
    return fig
end

function get_bifurcation_diagram(ncAIS, ncWAIS, plotcons, downsample_factor)
    exp_key_AIS = ncAIS[ "nc_list" ][1]
    exp_key_WAIS = ncWAIS[ "nc_list" ][1]
    fig = init_fig(plotcons)
    ax = Axis(
        fig[1, 1], 
        xlabel = L"Regional atmospheric temperature anomaly (K) $\,$", 
        ylabel = L"Sea-level equivalent ice volume (mSLE) $\,$",
        xminorticks = IntervalsBetween(10),
        yminorticks = IntervalsBetween(10),
        xminorgridvisible = true,
        yminorgridvisible = true,
        xticklabelcolor = :black,
    )

    ax2 = Axis(
        fig[1, 1],
        xlabel = L"Regional SST anomaly (K) $\,$",
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

    f = ncAIS[exp_key_AIS]["hyst_f_now"][1:downsample_factor:end]
    V = ncWAIS[exp_key_WAIS]["V_sle"][1:downsample_factor:end]
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
function error_plot_z(nc3D_dict, z_ref, f_ref)

    fig = Figure(resolution = (1200, 1300), font = srcdir("cmunrm.ttf"), fontsize = 24)
    axs = [Axis(
        fig[i,j],
        aspect = DataAspect(),
        xlabel = ((i == 3) & (j == 2)) ? L"Observed PD surface elevation (km) $\,$" : " ",
        ylabel = ((i == 3) & (j == 2)) ? L"Simulated PD surface elevation (km) $\,$" : " ",
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
    f_grnd = nc3D_dict["/media/Data/Jan/yelmox_v1.75/aqef_retreat/yelmo2D.nc"]["f_grnd"][:, :, 4]
    idline = collect(0:1:4500)
    lvls = 1e-3:500:4501
    cmap = cgrad( :ice, 10, categorical = true )
    
    i1, i2 = 10, 180
    j1, j2 = 15, 175

    c1 = contourf!( 
        axs[1],
        z_ref[i1:i2, j1:j2],
        levels = lvls,
        color = :white,
        colormap = :ice,
        linewidth = 2,
    )

    f_ref[125:145, 70:90] .= 2  # ignore Vostok lake
    binary_fref = Int.(f_ref .== 2)
    c1b = contour!( 
        axs[1],
        binary_fref[i1:i2, j1:j2],
        levels = [0.5],
        color = :grey80,
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
        z_srf[i1:i2, j1:j2],
        levels=lvls,
        color = :white,
        colormap = :ice,
        linewidth = 2,
    )
    c2b = contour!( 
        axs[3],
        f_grnd[i1:i2, j1:j2],
        levels = [0.5],
        color = :grey80,
        linewidth = 2,
    )
    Colorbar(fig[1,:], c1, vertical = false, width = Relative(1/2), label = L"Surface elevation (m) $\,$")

    zdiff = z_srf .- z_ref
    errormap = cgrad([:firebrick, :white, :cornflowerblue])
    # hm = heatmap!( axs[2], zdiff[i1:i2, j1:j2], colorrange = [-400, 400], colormap = errormap, lowclip = :firebrick, highclip = :cornflowerblue)
    hm = contourf!( axs[2], zdiff[i1:i2, j1:j2], levels = -500:(1000/19):500, colormap = errormap, extendhigh = :cornflowerblue, extendlow = :firebrick)
    Colorbar(fig[4,:], hm, vertical = false, flipaxis = false, width = Relative(1/2), ticks = -500:100:500, label = L"Surface elevation deviation (m) $\,$")


    zref_vec = collect( Iterators.flatten(z_ref))
    zsrf_vec = collect(Iterators.flatten(z_srf))
    sc = scatter!( axs[4], zref_vec ./ 1e3, zsrf_vec ./ 1e3, color = :grey20, markersize = 2 )
    ln = lines!( axs[4], idline ./ 1e3, idline ./ 1e3, color = :red, linewidth = 2)

    for (label, layout) in zip([L"a) $\,$", L"b) $\,$", L"c) $\,$", L"d) $\,$"], [fig[2,1], fig[2,2], fig[3,1], fig[3,2]])
        Label(layout[1, 1, TopLeft()], label,
            textsize = 24,
            font =  srcdir("cmunrm.ttf"),
            padding = (0, 5, 5, 0),
            halign = :right)
    end
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
    f_grnd = nc3D_dict["/media/Data/Jan/yelmox_v1.75/aqef_retreat/yelmo2D.nc"]["f_grnd"][:, :, 4]
    idline = 10. .^ collect(-1.5:.1:4)
    lvls = 10. .^ collect(-1.5:.5:3.5)
    eps = 1e-8

    i1, i2 = 10, 180
    j1, j2 = 15, 175
    

    c1 = contourf!( 
        axs[1],
        log10.( u_ref .+ eps ),
        color = :grey30,
        colormap = :dense,
        linewidth = 2,
        levels = log10.(lvls),
    )

    c2 = contourf!( 
        axs[3], 
        log10.( u_srf .+ eps ),
        color = :grey30, 
        colormap = :dense, 
        linewidth = 2,
        levels = log10.(lvls),
    )

    maplabels = [L"$10^{-1}$", L"$10^{0}$", L"$10^{1}$", L"$10^{2}$", L"$10^{3}$"]
    # maplabels = Dict( 0.1 => L"$10^{-1}$")
    # maplabels = log10.(lvls[1:2:end])
    Colorbar(fig[1,:], c1, vertical = false, width = Relative(1/2), ticks = (log10.(lvls[2:2:end]), maplabels),  label = L"Surface velocity ($\mathrm{m \, yr^{-1} }$)")
    xlims!(axs[1], 1, size(u_ref)[1])
    ylims!(axs[4], 1, size(u_ref)[2])

    errormap = cgrad([:firebrick, :white, :cornflowerblue], rev = true)
    udiff = u_srf .- u_ref
    println(size(u_srf), "    ", size(u_ref))
    # hm = heatmap!( axs[2], udiff[i1:i2, i1:i2], colorrange = [-400, 400], colormap = errormap, lowclip = :cornflowerblue, highclip = :firebrick, fxaa = false)
    hm = contourf!( axs[2], udiff[i1:i2, 28:170], levels = -500:(1000/19):500, colormap = errormap, extendhigh = :firebrick, extendlow = :cornflowerblue)

    Colorbar(fig[4,:], hm, vertical = false, flipaxis = false, width = Relative(1/2), ticks = -500:100:500, label = L"Surface velocity deviation ($\mathrm{m \, yr^{-1} }$)")

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

    for (label, layout) in zip([L"a) $\,$", L"b) $\,$", L"c) $\,$", L"d) $\,$"], [fig[2,1], fig[2,2], fig[3,1], fig[3,2]])
        Label(layout[1, 1, TopLeft()], label,
            textsize = 24,
            font =  srcdir("cmunrm.ttf"),
            padding = (0, 5, 5, 0),
            halign = :right)
    end
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
    axs = [ Axis(
        fig[i, j][1, 1], 
        aspect=DataAspect(), 
        title = L"\Delta T_\mathrm{atm} = %$(ctrl[ get_k(i, j, ncols) ]) \, \mathrm{K}, \: t = %$(frames[get_k(i, j, ncols)]) \, \mathrm{kyr}",
        ) for j in 1:ncols, i in 1:nrows ]
    ref_grndline = nc3D_dict[exp_key]["f_grnd"][:, :, 1]
    # topomap = cgrad([:midnightblue, :lightskyblue])
    # topomap = cgrad([:cornsilk, :saddlebrown])
    topomap = cgrad([:deepskyblue, :azure], 8, categorical = true)
    
    cmap0 = cgrad(:dense)
    cmap = cgrad([:blue4, :transparent, :red4])
    keep_maps = Dict()
    for i in 1:nrows
        for j in 1:ncols
            k = get_k(i, j, ncols)
            hidedecorations!(axs[k])

            zbed = nc3D_dict[exp_key]["z_bed"][:, :, frames[k]]
            fice = nc3D_dict[exp_key]["f_ice"][:, :, frames[k]]
            zbed[ fice .> 0 ] .= NaN
            if k == 1
                hm = heatmap!(
                    axs[k],
                    nc3D_dict[exp_key][var][:, :, 1],
                    colorrange = extrema_dict[exp_key][var],
                    colormap = cmap0,
                    lowclip = cmap0[1],
                    highclip = cmap0[end],
                )
            else
                hm = heatmap!(
                    axs[k],
                    nc3D_dict[exp_key][var][:, :, frames[k]] .- nc3D_dict[exp_key][var][:, :, 1],
                    colorrange = (-300, 300),
                    # colormap = :Reds,
                    colormap = cmap,
                    lowclip = cmap[1],
                    highclip = cmap[end],
                )
            end

            ct = contourf!(
                axs[k],
                zbed,
                # colorrange = extrema_dict[exp_key][var],
                colormap = topomap,
                levels = -1600:200:0,
                extendlow = topomap[1],
                extendhigh = :white,
            )

            if k == 1
                keep_maps["vel0"] = hm
            elseif k == 6
                keep_maps["topo"] = ct
                keep_maps["vel"] = hm
            end

            contour!(axs[k], 
                nc3D_dict[exp_key]["lat2D"];
                color=:lightgray, 
                levels=-90:10:90,
            )
            contour!(axs[k], 
                nc3D_dict[exp_key]["lon2D"];
                color=:grey90, 
                levels=-120:60:180,
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

    Colorbar(fig[nrows+1, :], keep_maps["topo"], width = Relative(.3), label = L"Bathymetry (m) $\,$", vertical = false, halign = :left, ticks = (-1600:400:0, string.(-1600:400:0)))
    Colorbar(fig[nrows+1, :], keep_maps["vel0"], width = Relative(.3), label = L"Ice surface velocity $\mathrm{ ( m \, s^{-1} ) }$", vertical = false, halign = :center, ticks = (0:250:1000, string.(0:250:1000)))
    Colorbar(fig[nrows+1, :], keep_maps["vel"], width = Relative(.3), label = L"Ice surface velocity anomaly $\mathrm{ ( m \, s^{-1} ) }$", vertical = false, halign = :right)    # Legend(fig[nrows+1, :], axs[nrows*ncols], framevisible = false, orientation = :horizontal, tellwidth = false, tellheight = true)
    
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

    α = 100
    tks = [0.1, 0.2, 0.5, 1., 2., 5.]
    fig = init_fig(plotcons)
    ax = Axis(
        fig[1, 1][1, 1:10],
        xlabel = L"Ramp slope (K/century) $\,$",
        ylabel = L"Maximal regional atmospheric warming (K) $ \, $",
        xscale = log10,
        xticks = ( tks, string.(tks) ),
        xminorticks = vcat( .1:.1:.9 , 1:1:5 ),
        xminorticksvisible = true,
        yminorticks = IntervalsBetween(5),
        yminorticksvisible = true,
        yminorgridvisible = true,
    )

    myblue = cgrad([:thistle2, :lightblue1])

    shm = heatmap!( ax, α .* a, f, e, colormap = myblue, colorrange = [1, 4] )
    heatmap!( ax, α .* a_ext_nontipped, f_ext_nontipped, e_ext_nontipped, colormap = myblue, colorrange = extrema(e) )
    heatmap!( ax, α .* a_ext_tipped, f_ext_tipped, e_ext_tipped, colormap = myblue, colorrange = extrema(e) )
    hlines!( ax, [ 2.8 ], color = :gray40, linewidth = 5, label = "Bifurcation point", linestyle = :dash)
    scatter!( ax, α .* a, f, color = :gray15, linewidth = 2 )
    Colorbar(fig[1, 1][1, 11], shm, label = L"Ice volume (mSLE) at $t = 30 \, \mathrm{kyr}$", height = Relative(3/4) )
    axislegend(position = :lb)

    ###########################################################

	# steppath = "/media/Data/Jan/yelmox_v1.75/steps";
    # nc1D_step_list = get_nc_lists(steppath, "yelmo1D_WAIS.nc");
	# nc1D_step = init_dict( nc1D_step_list );
    # load_data!( nc1D_step, ["V_sle"] );
    # f_step, a_step, end_step = get_final_value(nc1D_step, "V_sle", 100, 2000);
    # a_step = ones( length(a_step) );

    # f_ext_nontipped = f_step .- 0.399
    # e_ext_nontipped = maximum(end_step) .* ones( size(f_ext_nontipped) )
    # a_ext_nontipped = a_step

    # f_ext_tipped = f_step .+ 0.599
    # e_ext_tipped = minimum(end_step) .* ones( size(f_ext_nontipped) )
    # a_ext_tipped = a_step

    # ax2 = Axis(fig[1, 1][1, 11])
    # hidedecorations!(ax2)
    # heatmap!( ax2, a_step, f_step, end_step, colormap = myblue )

    # heatmap!( ax2, a_ext_nontipped, f_ext_nontipped, e_ext_nontipped, colormap = myblue, colorrange = extrema(e) )
    # heatmap!( ax2, a_ext_tipped, f_ext_tipped, e_ext_tipped, colormap = myblue, colorrange = extrema(e) )
    # hlines!( ax2, [ 2.8 ], color = :gray40, linewidth = 5, linestyle = :dash)
    # scatter!( ax2, a_step, f_step, color = :gray15, linewidth = 2 )

    # myblue = cgrad([:plum1, :lightblue1]) azure, bisque, gray90, thistle2
    # myblue = cgrad([:peachpuff2, :lightblue1])
    # myblue = cgrad([:lightgreen, :lightblue1])
    
    # shm = heatmap!( ax, a, f, e, colormap = cgrad(:Blues_3, rev = true) )
    # heatmap!( ax, a_ext_nontipped, f_ext_nontipped, e_ext_nontipped, colormap = cgrad(:Blues_3, rev = true), colorrange = extrema(e) )
    # heatmap!( ax, a_ext_tipped, f_ext_tipped, e_ext_tipped, colormap = cgrad(:Blues_3, rev = true), colorrange = extrema(e) )


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

    α = 100
    clrs = [:darkorange, :red2, :darkred]
    yrlbl = string(lb, " to ", ub+1)
    ΔT_mat = ΔT_mat .* ant_amplification
    # l = [string("SSP2: ", yrlbl) , string("SSP3: ", yrlbl), string("SSP5: ", yrlbl)]
    l = ["SSP2-4.5", "SSP3-7.0", "SSP5-8.5"]
    loc = [(:right, :top), (:right, :top), (:left, :top)]
    offset = α .* [-1e-3, -1e-3, 1e-3]
    for i in 1:length(l)
        # lb = string.(l[i], ": ", string.(2060:10:2100))
        scatterlines!(ax, α .* a_mat[i, :], ΔT_mat[i, :], color = clrs[i], label = l[i], linestyle = :dash, linewidth = 3)
        text!(
            ax, 
            string.(years), 
            position = [(α .* a_mat[i, j] + offset[i], ΔT_mat[i, j] - 0.01) for j in 1:length(years)], 
            color = clrs[i],
            align = loc[i],
            markerspace = 10,
            textsize = 18,
        )
        # annotations!(ax, string.(2060:10:2100), a_mat[i, :], ΔT_mat[i, :], textsize = 0.1, color = clrs[i])
    end
    
    axislegend(position = :lb)
end