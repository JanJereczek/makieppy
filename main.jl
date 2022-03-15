### A Pluto.jl notebook ###
# v0.18.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ d617b6f2-9b90-11ec-0b63-87c241eb148b
using DrWatson;

# ╔═╡ 761c7fa9-e262-4452-8026-1cb2aad34704
@quickactivate "makieppy";

# ╔═╡ 1b29ed5a-dc9c-498e-81fb-5cfbf1404810
using NCDatasets, CairoMakie, PlutoUI;

# ╔═╡ b79c0b90-12b2-4108-af34-2caf4a269c10
include(srcdir("structs.jl"))

# ╔═╡ acb1556b-dce7-4ec1-9f9c-85aacf500553
begin
	include(srcdir("utils.jl"));
	include(srcdir("datahandle.jl"));
	include(srcdir("plot.jl"));
	include(srcdir("colors.jl"));
	include(srcdir("labels.jl"));
	include(srcdir("video.jl"));
end

# ╔═╡ 05c69dbe-df76-457d-8b4b-ed80a851656a
md"""
## Why Julia Instead of Python?

+ Pkg.jl => Easy installation. (In future: single command installation)
+ Julia + Makie => Faster plotting.
+ Pluto + PlutoUI => Great widgets and improved interactivity compared to Jupyter.
+ Makie.jl => easier layout and video generation than Matplotlib.
+ Colors.jl => one-line definition of colormaps.
+ All of this together => ca. 400 lines of code instead of ca. 800 previously.
+ Pluto => Hiding cells makes a clean notebook interface. 
"""

# ╔═╡ fcc18548-3ab8-421f-b2bd-96189ae925e5
md"""
#### Quickactivate

This ensure that you always start with well-defined paths and environment.
"""

# ╔═╡ a576c089-68c3-4af5-97e0-285dc564184f
md"""
#### Loading Packages

+ NCDatasets: allows loading in .nc-format.
+ Cairomakie: plotting package.
+ PlutoUI: provides wide library of widgets for interactivity.
"""

# ╔═╡ fc889e21-3300-42d6-928f-c5f0b193bc60
md"""
#### Self-Written Functions
"""

# ╔═╡ 5978d34d-80bf-45a4-bfec-b88d0d4bb5e5
@bind load_struct CheckBox(true)

# ╔═╡ 20f47d5b-7100-4c29-95b4-33a41770bcea
md"""
## Select Files of Interest
"""

# ╔═╡ 0895e44a-6894-4f1d-84fe-6f1838783b32
begin
	# path = "/media/Data/Jan/yelmox_v1.662/GridRamp1/";
	# ixs = collect(1:3);
	# ixs = [1];
	# exp_type = "aqef_retreat/";
	exp_type = "ramp2/";
	path = string("/media/Data/Jan/yelmox_v1.75/", exp_type);
	nc1D_list = get_nc_lists(path, "yelmo1D.nc");
	nc1D_WAIS_list = get_nc_lists(path, "yelmo1D_WAIS.nc");
	nc3D_list = get_nc_lists(path, "yelmo2D.nc");
	
	ixs = collect(1:length(nc3D_list))
	nc1D_list_filt = filter_nc_list( nc1D_list, ixs );
	nc3D_list_filt = filter_nc_list( nc3D_list, ixs );
end

# ╔═╡ 8e0c75ef-ae2d-4a7e-8314-5521150f51ac
begin
	vars1D = sort( get_vars( nc1D_list[1] ) )
	vars1D_WAIS = sort( get_vars( nc1D_WAIS_list[1] ) )
	vars3D = sort( get_vars( nc3D_list[1] ) )
	
	colors = load_colors(vars3D)
	labels1D = load_1Dlabels(vars1D)
	labels3D = load_3Dlabels(vars3D)
	
	nc1D_dict = init_dict( nc1D_list_filt );
	nc1D_WAIS_dict = init_dict( nc1D_WAIS_list );
end

# ╔═╡ e44728c2-fd00-4f46-8af3-5552c2ce086c
md"""
## 1D Variables
"""

# ╔═╡ fae93994-bb9f-45ce-8d04-e879a2b4ef6e
md"""
Choose the 1D variables you would like to plot:
"""

# ╔═╡ ef76d945-7388-4642-984f-58e1197e7b10
@bind var1D_list confirm(MultiCheckBox(vars1D , default =  ["V_ice", "hyst_f_now", "bmb", "smb"]))

# ╔═╡ 6c307e28-1d28-4d54-87bc-34fc237fc30f
md"""
Choose the number of rows you would like to have in your figure layout and don't forget to submit:
"""

# ╔═╡ 8ecce53d-8f95-42a6-83c5-4f140fc3719a
@bind nrows1D confirm(NumberField(1:5, default=2))

# ╔═╡ 684df28f-75fb-4b60-9068-fefc85da47f4
ncols1D = get_ncols(var1D_list, nrows1D);

# ╔═╡ 311ab417-d9c7-4c73-8565-c8adad889e19
md"""
Choose the base resolution you would like to have for your plots and confirm:
"""

# ╔═╡ c3226566-3004-4f88-b73c-4426fd48ef2b
@bind base_rsl confirm(NumberField(100:100:1000, default=500))

# ╔═╡ 9551c5bb-f458-4c2a-8fdb-c1bb067ba6b6
rsl = get_resolution( nrows1D, ncols1D, base_rsl );

# ╔═╡ 897ac020-da22-48e1-a484-27ec56849904
md"""
Choose the fontsize you would like to have for your plots and confirm:
"""

# ╔═╡ 91ac16d9-6339-4839-850d-3df4bf0a1708
@bind ft_size confirm(NumberField(5:1:50, default=20))

# ╔═╡ bccb8aaf-da92-41f0-9009-6d1d14e187e9
md"""
To speed up the plotting procedure, one can choose a downsampling factor:
"""

# ╔═╡ 1fb29956-ef45-48b5-99fa-9c3660f79371
@bind downsample_factor confirm( NumberField(10:10:100, default=100) )

# ╔═╡ 3dfe71c0-e6ad-4712-94ca-cc2912a99ca4
begin
	dt1D = 1;
	dt3D = 1000;
	load_data!( nc1D_dict, var1D_list );
	line_plotcons = InitPlotConst(nrows1D, ncols1D, 20, rsl, colors, labels1D, dt1D, dt3D);
	fig1D = init_fig( line_plotcons );
	axs1D = init_axs(fig1D, line_plotcons, var1D_list);
end

# ╔═╡ e2ee4337-0251-4775-9f68-1cc3ca306b3b
init_lines(axs1D, nc1D_dict, var1D_list, line_plotcons, downsample_factor)

# ╔═╡ 547fcf0a-1f15-43e0-9532-be9d2cfcd175
@bind hl_ix Select(ixs, default = 1)

# ╔═╡ 4144b41b-3d5a-4dcb-9e61-5d532a3a8854
update_line(fig1D, axs1D, nc1D_dict, var1D_list, line_plotcons, hl_ix, downsample_factor)

# ╔═╡ 55803f22-a1f5-49cf-bfad-867794eed0ee
md"""
To save the figure, simply tick the following checkbox. Note that if not unticked, it will automatically save any further update of the figure!
"""

# ╔═╡ 5a240e0b-52f7-4a02-b79b-087f2d3c5f39
@bind save1 CheckBox(false)

# ╔═╡ b81908a7-fe95-46c0-84bb-7f5a16c29e05
begin
	if save1
		save_fig(plotsdir( string("yelmox_v1.75/", exp_type)), "1D", "both", fig1D)
	end
end

# ╔═╡ 661c6c30-0650-4669-833f-885dd6cc9418
md"""
## Comparing End States of the WAIS
"""

# ╔═╡ 710603db-6bad-4bf8-b831-9c913f48949d
md"""
Choose the 1D variables you would like to plot:
"""

# ╔═╡ 2b1d04d9-ebec-475d-98eb-34eaff147759
@bind var1D_WAIS_list confirm(MultiCheckBox(vars1D_WAIS , default =  ["V_ice", "A_ice", "bmb", "smb"]))

# ╔═╡ 32271713-4f3d-4e9f-b9dc-2679bb38f821
begin
	load_data!( nc1D_WAIS_dict, var1D_WAIS_list );
	tipgrid_plotcons = InitPlotConst(1, 1, ft_size, (base_rsl, base_rsl), colors, labels1D, dt1D, dt3D);
end

# ╔═╡ e9187f69-b2d7-42ee-939b-edcdd5bff67b
nt_WAIS = length( nc1D_WAIS_dict[ nc1D_WAIS_list[1] ][ var1D_WAIS_list[1] ] )

# ╔═╡ 616e2fc6-27a5-43d3-a4e1-70d4659cef7e
@bind tip_frame confirm( NumberField(1:nt_WAIS, default=nt_WAIS) )

# ╔═╡ aac3fb96-b0a4-435f-9ce4-478de1c2d8fe
begin
	if length(nc1D_WAIS_list) > 10
		avg_wdw = 2;
		fmx_vec, a_vec, end_vec = get_final_value(nc1D_WAIS_dict, "V_ice", avg_wdw, tip_frame);
		extrema(end_vec)
		fig_tgrid = scatter_tipping(fmx_vec, a_vec, end_vec, line_plotcons, 2080);
	end
end

# ╔═╡ f6be0066-4674-42a5-9986-5126d055acc7


# ╔═╡ fda9b297-43ad-4456-8af4-d389058ed6ac
md"""
You can set the name of the target file for saving the plot:
"""

# ╔═╡ 3402fdfc-d227-471f-839f-b405a4a0f06a
@bind name_tipgrid TextField(default = "tipgrid")

# ╔═╡ b463897f-056e-4291-85e4-6fda689ba21d
md"""
To save the figure, simply tick the following checkbox. Note that if not unticked, it will automatically save any further update of the figure!
"""

# ╔═╡ 6f653476-791d-42c4-928c-ccad121373d1
@bind save_tipgrid CheckBox(false)

# ╔═╡ ff9dc3bd-4229-4898-9e19-e8c658fb279a
begin
	if save_tipgrid
		save_fig(plotsdir( string("yelmox_v1.75/", exp_type)), name_tipgrid, "both", fig_tgrid)
	end
end

# ╔═╡ 6c661771-46c0-48ae-825d-945aa350fe8d
md"""
#### Plot the Time Series of WAIS 
"""

# ╔═╡ 10ce2861-9524-4f01-9471-5108686d1cd3
begin
	fig1D_WAIS = init_fig( line_plotcons );
	axs1D_WAIS = init_axs(fig1D_WAIS, line_plotcons, var1D_WAIS_list);
	init_lines(axs1D_WAIS, nc1D_WAIS_dict, var1D_WAIS_list, line_plotcons, downsample_factor);
end

# ╔═╡ 7c37756b-3bd9-4716-8be4-f99cf025ca70
@bind hl_ix_WAIS Select(ixs, default = 1)

# ╔═╡ 04bb319e-bb36-4480-9ab0-130965407f0c
update_line(fig1D_WAIS, axs1D_WAIS, nc1D_WAIS_dict, var1D_WAIS_list, line_plotcons, hl_ix_WAIS, downsample_factor)

# ╔═╡ f8c289d4-6aca-41a1-ae9a-ea97e3671d7f
md"""
To save the figure, simply tick the following checkbox. Note that if not unticked, it will automatically save any further update of the figure!
"""

# ╔═╡ e8f3c2bf-fc73-4dcc-982d-975e1031ff2e
@bind save2 CheckBox(false)

# ╔═╡ e5a5419c-a416-4457-afc8-885257662fd1
begin
	if save2
		save_fig(plotsdir( string("yelmox_v1.75/", exp_type)), "WAIS1D", "both", fig1D_WAIS)
	end
end

# ╔═╡ 0d80c308-60c1-4390-b999-ba87f62c5e67
md"""
## 3D Variables
"""

# ╔═╡ d2011ce2-0e85-4a00-9a11-b12c13dbc5f7
@bind var3D_list confirm( MultiCheckBox(vars3D , default =  ["H_ice", "uxy_s"]) )

# ╔═╡ 496ce8cd-5d9c-4a00-95ac-f0c26aad1a84
begin
	nc3D_dict = init_dict( nc3D_list_filt[1:2] );
	nc3D_dict = load_data!( nc3D_dict, var3D_list );
end

# ╔═╡ a39d8efc-8f68-4a04-adbe-4c60be9b5e54
begin
	lowerlim = [0.0, 0.0, -Inf, -Inf];
	upperlim = [Inf, 2000.0, Inf, Inf];
	extrema3D_dict = get_extrema( nc3D_dict, var3D_list, lowerlim, upperlim );
end

# ╔═╡ 517e2adb-2fa4-4528-80a5-7de5b9b2b36d
@bind exp_id Select(ixs)

# ╔═╡ c582d0d2-aaad-4b3f-9dc0-42f4a5f3d2c6
begin
	exp_key = nc3D_list_filt[exp_id];
	nt = size( nc3D_dict[exp_key]["H_ice"] )[3];
	tframes = 1:nt;
	hm_plotcons = InitPlotConst(2, 2, 20, (1200, 1200), colors, labels3D, dt1D, dt3D);
	fig3D = init_fig( hm_plotcons );
	axs3D = init_hm_axs(fig3D, hm_plotcons, var3D_list, exp_key, extrema3D_dict);
end

# ╔═╡ 916c521b-7e41-49f6-a94a-e401b09e8f3e
@bind tframe Select(tframes)

# ╔═╡ ce11169d-8dc1-4d9a-85d3-ed0e68447cd7
begin
	fig3D_updated = update_hm_3D( fig3D, axs3D, nc3D_dict, nc1D_dict, exp_key, tframe, var3D_list, hm_plotcons, extrema3D_dict )
end

# ╔═╡ e5d4908e-861a-4829-99c6-4dc5b93a8536
md"""
You can set the name of the target file for saving the plot:
"""

# ╔═╡ 54815cd2-9893-4124-8055-a5418ccca2d0
@bind name_2Dvarplot TextField(default = "2Dvarplot")

# ╔═╡ 1db22fa9-becc-4aee-9410-5e2e96645dab
md"""
To save the figure, simply tick the following checkbox. Note that if not unticked, it will automatically save any further update of the figure!
"""

# ╔═╡ 7529e265-1b6b-4738-ab09-9dba16f65942
@bind save_2Dvarplot CheckBox(false)

# ╔═╡ 9c3ed40f-e9c5-49ce-862d-41455373e1a5
begin
	if save_2Dvarplot
		save_fig(plotsdir( string("yelmox_v1.75/", exp_type)), name_2Dvarplot, "both", fig3D_updated)
	end
end

# ╔═╡ da4ed259-1752-4209-b555-4ab6f1dda208
md"""
## Generate Video
"""

# ╔═╡ 6e189527-5b7a-4bd9-ac99-d79b74ea60ee
md"""
To generate a video, simply tick the following checkbox. Note that if not unticked, it will automatically re-generate the video at any update!
"""

# ╔═╡ 4f45ed97-908b-4762-adec-81577870165c
@bind genvid1 CheckBox(false)

# ╔═╡ daae5d13-c460-4de4-926b-eca63f60f8b0
begin
	if genvid1
		get_hm_video( fig3D, axs3D, nc3D_dict, nc1D_dict, exp_key, var3D_list, hm_plotcons, extrema3D_dict, tframes, 5 )
	end
end

# ╔═╡ 22394677-6c70-4b7b-a2d1-26524bbbcfbc
md"""
### Evolution Plot
"""

# ╔═╡ 4481bbba-39e6-415b-b1d7-12ff78968db6
@bind evol_var Select(var3D_list, default = "H_ice")

# ╔═╡ 600d1e27-3695-42cb-ae7a-23aadad5633a
@bind evo_frames confirm(MultiCheckBox( collect(1:1:130) , default =  collect(70:1:73) ))

# ╔═╡ 65bfe62a-1b2e-4368-8ee7-dd5662dd58ce
begin
	evolhm_plotcons = InitPlotConst(2, 2, 20, (1200, 1200), colors, labels3D, dt1D, dt3D);
	fig_evo = evolution_hmplot(nc3D_dict, evo_frames, evolhm_plotcons, evol_var, exp_key, extrema3D_dict)
end

# ╔═╡ 25bc2940-c6a5-4104-b5aa-b7c2e2462c31
md"""
To save the figure, simply tick the following checkbox. Note that if not unticked, it will automatically save any further update of the figure!
"""

# ╔═╡ 0035667d-7d21-4e22-8c7a-7f7d45e1b936
@bind save3 CheckBox(false)

# ╔═╡ 4f171024-2c63-4ca6-a477-7cd11fa68423
@bind name3 TextField(default = "evo_plot")

# ╔═╡ 711ee795-3f82-4f31-8fda-fb596f8ea2cf
begin
	if save3
		save_fig(plotsdir( string("yelmox_v1.75/", exp_type)), name3, "both", fig_evo)
	end
end

# ╔═╡ c69d8900-4f31-4e8e-b066-219c187531b5
md"""
## Difference Plot
"""

# ╔═╡ 0d9e0b46-9e6b-4da0-ac99-05cfab2d4743
@bind exp_id1 Select(ixs)

# ╔═╡ 2cd75200-4c80-4818-bd4e-22ba0ef1271b
@bind exp_id2 Select(ixs)

# ╔═╡ e9ad8f74-5646-4bc7-bcc6-039575070a2f
begin
	exp_key1 = get_key(nc3D_list_filt, exp_id1)
	exp_key2 = get_key(nc3D_list_filt, exp_id2)
	tframes1 = get_timeframes(exp_key1, nc3D_dict)
	tframes2 = get_timeframes(exp_key2, nc3D_dict)
end

# ╔═╡ 7d1c8eb3-bfa3-4d21-8412-bd56d30fd2a3
@bind tframe1 Select(tframes1)

# ╔═╡ 84dd18b9-3a00-499a-99ad-4000f2b3c245
@bind tframe2 Select(tframes2)

# ╔═╡ c1582e81-27cf-4644-ae08-168f87eefa8b
plot_diffhm_3D(nc3D_dict, exp_key1, exp_key2, tframe1, tframe2, var3D_list, hm_plotcons)

# ╔═╡ 80146c29-e13b-47ec-b8d3-040929e0507a


# ╔═╡ 4d9f8ca1-604c-4fe6-a4ee-ded966ee32ea
md"""
To save the figure, simply tick the following checkbox. Note that if not unticked, it will automatically save any further update of the figure!
"""

# ╔═╡ 9e565b97-d959-4624-a71e-5ed186e2264c
@bind save4 CheckBox(false)

# ╔═╡ 491c1ca5-dfd0-4da4-9ac6-e99f81688f80
begin
	if save4
		save_fig(plotsdir( string("yelmox_v1.75/", exp_type)), "1D", "both", fig1D)
	end
end

# ╔═╡ Cell order:
# ╟─05c69dbe-df76-457d-8b4b-ed80a851656a
# ╟─fcc18548-3ab8-421f-b2bd-96189ae925e5
# ╠═d617b6f2-9b90-11ec-0b63-87c241eb148b
# ╠═761c7fa9-e262-4452-8026-1cb2aad34704
# ╟─a576c089-68c3-4af5-97e0-285dc564184f
# ╠═1b29ed5a-dc9c-498e-81fb-5cfbf1404810
# ╟─fc889e21-3300-42d6-928f-c5f0b193bc60
# ╠═5978d34d-80bf-45a4-bfec-b88d0d4bb5e5
# ╠═b79c0b90-12b2-4108-af34-2caf4a269c10
# ╠═acb1556b-dce7-4ec1-9f9c-85aacf500553
# ╟─20f47d5b-7100-4c29-95b4-33a41770bcea
# ╠═0895e44a-6894-4f1d-84fe-6f1838783b32
# ╠═8e0c75ef-ae2d-4a7e-8314-5521150f51ac
# ╟─e44728c2-fd00-4f46-8af3-5552c2ce086c
# ╟─fae93994-bb9f-45ce-8d04-e879a2b4ef6e
# ╟─ef76d945-7388-4642-984f-58e1197e7b10
# ╟─6c307e28-1d28-4d54-87bc-34fc237fc30f
# ╟─8ecce53d-8f95-42a6-83c5-4f140fc3719a
# ╟─684df28f-75fb-4b60-9068-fefc85da47f4
# ╟─311ab417-d9c7-4c73-8565-c8adad889e19
# ╟─c3226566-3004-4f88-b73c-4426fd48ef2b
# ╟─9551c5bb-f458-4c2a-8fdb-c1bb067ba6b6
# ╟─897ac020-da22-48e1-a484-27ec56849904
# ╟─91ac16d9-6339-4839-850d-3df4bf0a1708
# ╟─bccb8aaf-da92-41f0-9009-6d1d14e187e9
# ╠═1fb29956-ef45-48b5-99fa-9c3660f79371
# ╠═3dfe71c0-e6ad-4712-94ca-cc2912a99ca4
# ╠═e2ee4337-0251-4775-9f68-1cc3ca306b3b
# ╠═547fcf0a-1f15-43e0-9532-be9d2cfcd175
# ╠═4144b41b-3d5a-4dcb-9e61-5d532a3a8854
# ╟─55803f22-a1f5-49cf-bfad-867794eed0ee
# ╟─5a240e0b-52f7-4a02-b79b-087f2d3c5f39
# ╟─b81908a7-fe95-46c0-84bb-7f5a16c29e05
# ╟─661c6c30-0650-4669-833f-885dd6cc9418
# ╟─710603db-6bad-4bf8-b831-9c913f48949d
# ╠═2b1d04d9-ebec-475d-98eb-34eaff147759
# ╠═32271713-4f3d-4e9f-b9dc-2679bb38f821
# ╠═e9187f69-b2d7-42ee-939b-edcdd5bff67b
# ╠═616e2fc6-27a5-43d3-a4e1-70d4659cef7e
# ╠═aac3fb96-b0a4-435f-9ce4-478de1c2d8fe
# ╠═f6be0066-4674-42a5-9986-5126d055acc7
# ╟─fda9b297-43ad-4456-8af4-d389058ed6ac
# ╟─3402fdfc-d227-471f-839f-b405a4a0f06a
# ╟─b463897f-056e-4291-85e4-6fda689ba21d
# ╟─6f653476-791d-42c4-928c-ccad121373d1
# ╠═ff9dc3bd-4229-4898-9e19-e8c658fb279a
# ╟─6c661771-46c0-48ae-825d-945aa350fe8d
# ╠═10ce2861-9524-4f01-9471-5108686d1cd3
# ╠═7c37756b-3bd9-4716-8be4-f99cf025ca70
# ╠═04bb319e-bb36-4480-9ab0-130965407f0c
# ╟─f8c289d4-6aca-41a1-ae9a-ea97e3671d7f
# ╟─e8f3c2bf-fc73-4dcc-982d-975e1031ff2e
# ╟─e5a5419c-a416-4457-afc8-885257662fd1
# ╟─0d80c308-60c1-4390-b999-ba87f62c5e67
# ╠═d2011ce2-0e85-4a00-9a11-b12c13dbc5f7
# ╠═496ce8cd-5d9c-4a00-95ac-f0c26aad1a84
# ╠═a39d8efc-8f68-4a04-adbe-4c60be9b5e54
# ╠═517e2adb-2fa4-4528-80a5-7de5b9b2b36d
# ╠═c582d0d2-aaad-4b3f-9dc0-42f4a5f3d2c6
# ╠═916c521b-7e41-49f6-a94a-e401b09e8f3e
# ╠═ce11169d-8dc1-4d9a-85d3-ed0e68447cd7
# ╟─e5d4908e-861a-4829-99c6-4dc5b93a8536
# ╠═54815cd2-9893-4124-8055-a5418ccca2d0
# ╟─1db22fa9-becc-4aee-9410-5e2e96645dab
# ╠═7529e265-1b6b-4738-ab09-9dba16f65942
# ╟─9c3ed40f-e9c5-49ce-862d-41455373e1a5
# ╟─da4ed259-1752-4209-b555-4ab6f1dda208
# ╟─6e189527-5b7a-4bd9-ac99-d79b74ea60ee
# ╟─4f45ed97-908b-4762-adec-81577870165c
# ╠═daae5d13-c460-4de4-926b-eca63f60f8b0
# ╟─22394677-6c70-4b7b-a2d1-26524bbbcfbc
# ╠═4481bbba-39e6-415b-b1d7-12ff78968db6
# ╟─600d1e27-3695-42cb-ae7a-23aadad5633a
# ╠═65bfe62a-1b2e-4368-8ee7-dd5662dd58ce
# ╟─25bc2940-c6a5-4104-b5aa-b7c2e2462c31
# ╠═0035667d-7d21-4e22-8c7a-7f7d45e1b936
# ╠═4f171024-2c63-4ca6-a477-7cd11fa68423
# ╠═711ee795-3f82-4f31-8fda-fb596f8ea2cf
# ╟─c69d8900-4f31-4e8e-b066-219c187531b5
# ╠═0d9e0b46-9e6b-4da0-ac99-05cfab2d4743
# ╠═2cd75200-4c80-4818-bd4e-22ba0ef1271b
# ╠═e9ad8f74-5646-4bc7-bcc6-039575070a2f
# ╠═7d1c8eb3-bfa3-4d21-8412-bd56d30fd2a3
# ╠═84dd18b9-3a00-499a-99ad-4000f2b3c245
# ╠═c1582e81-27cf-4644-ae08-168f87eefa8b
# ╠═80146c29-e13b-47ec-b8d3-040929e0507a
# ╠═4d9f8ca1-604c-4fe6-a4ee-ded966ee32ea
# ╠═9e565b97-d959-4624-a71e-5ed186e2264c
# ╠═491c1ca5-dfd0-4da4-9ac6-e99f81688f80
