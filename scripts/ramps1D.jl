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
	# exp_type = "ramp3/";
	exp_type = "isotau1";
	path = string("/media/Data/Jan/yelmox_v1.75/", exp_type);
	nc1D_list = get_nc_lists(path, "yelmo1D.nc");
	nc1D_WAIS_list = get_nc_lists(path, "yelmo1D_WAIS.nc");

	# ixs = collect(6:6);
	ixs = collect(1: length(nc1D_WAIS_list))
	nc1D_list_filt = filter_nc_list( nc1D_list, ixs );
	nc1D_WAIS_filt = filter_nc_list( nc1D_WAIS_list, ixs);
end

# ╔═╡ 94a5bc06-64f6-4434-8541-95260f891707
ixs

# ╔═╡ 8e0c75ef-ae2d-4a7e-8314-5521150f51ac
begin
	vars1D = sort( get_vars( nc1D_list[1] ) )
	vars1D_WAIS = sort( get_vars( nc1D_WAIS_list[1] ) )
	
	nc1D_dict = init_dict( nc1D_list_filt );
	nc1D_WAIS_dict = init_dict( nc1D_WAIS_filt );
end

# ╔═╡ 35b2bd8f-de32-4275-b86d-0f182d984fe9
begin
	# dt1D = get_dt( nc1D_list );
	# dt3D = get_dt( nc3D_list );
	dt1D = 10.0;
	dt3D = 1000.0;
end

# ╔═╡ e97ba5bd-4683-4c45-ba97-3b79e6e9bace
begin
	colors = load_colors(["H_ice"])
	labels1D = load_1Dlabels(vars1D)
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
@bind var1D_list_alphabetical confirm(MultiCheckBox(vars1D , default =  ["hyst_f_now", "bmb", "V_sl", "V_ice"]))

# ╔═╡ 7eb4b4ec-2225-419f-835f-47022493a088
begin
	reorder = [[2], [1], [3], [4]]
	var1D_list = reorder_list(var1D_list_alphabetical, reorder)
end

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
@bind downsample_factor confirm( NumberField( 1:100, default=1) )

# ╔═╡ 3dfe71c0-e6ad-4712-94ca-cc2912a99ca4
begin
	load_data!( nc1D_dict, var1D_list_alphabetical );
	line_plotcons = InitPlotConst(nrows1D, ncols1D, ft_size, (1000,800), colors, labels1D, dt1D, dt3D);
	fig1D = init_fig( line_plotcons );
	tlim = (0, 30)
end

# ╔═╡ b818d613-907f-47a3-a141-29f8a3c0555d
axs1D = init_axs(fig1D, line_plotcons, var1D_list_alphabetical);

# ╔═╡ e2ee4337-0251-4775-9f68-1cc3ca306b3b
init_lines(axs1D, nc1D_dict, var1D_list, line_plotcons, downsample_factor; tlim)

# ╔═╡ 547fcf0a-1f15-43e0-9532-be9d2cfcd175
@bind hl_ix Select(collect(1:length(ixs)), default = 1)

# ╔═╡ e731a859-ff2a-4168-b11f-4aa72b625e02
extract_ramp_parameters( nc1D_list[hl_ix] )

# ╔═╡ ebd7685c-be44-45e9-82b6-468b8689a9fa
nc1D_list[hl_ix]

# ╔═╡ 4144b41b-3d5a-4dcb-9e61-5d532a3a8854
update_line(fig1D, axs1D, nc1D_dict, var1D_list, line_plotcons, hl_ix, downsample_factor; tlim)

# ╔═╡ 30140890-21ec-4084-97ca-dfef34c843c6
md"""
You can set the name of the target file for saving the plot:
"""

# ╔═╡ 854d7168-bed7-4d14-8939-035df6f7ddac
@bind name_AIS_1D TextField(default = "AIS_1D")

# ╔═╡ 55803f22-a1f5-49cf-bfad-867794eed0ee
md"""
To save the figure, simply tick the following checkbox. Note that if not unticked, it will automatically save any further update of the figure!
"""

# ╔═╡ 5a240e0b-52f7-4a02-b79b-087f2d3c5f39
@bind save1 CheckBox(false)

# ╔═╡ b81908a7-fe95-46c0-84bb-7f5a16c29e05
begin
	if save1
		save_fig(plotsdir( string("yelmox_v1.75/", exp_type )), name_AIS_1D, "both", fig1D)
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
@bind var1D_WAIS_alphabetical confirm(MultiCheckBox(vars1D_WAIS , default =  ["V_sle", "A_ice", "bmb", "smb"]))

# ╔═╡ b2c9dcbf-c28d-4e3e-b523-076f8bbb1621
nc1D_WAIS_dict["nc_list"]

# ╔═╡ bf9c6a34-3fcb-44dd-8d63-3e3f17811e1f
begin
	load_data!( nc1D_WAIS_dict, var1D_WAIS_alphabetical );
	add_data_field!( var1D_WAIS_alphabetical, nc1D_WAIS_dict, nc1D_dict, "hyst_f_now" )
end

# ╔═╡ 6160c281-258f-4420-bd0d-5263bb501fe6
var1D_WAIS_alphabetical

# ╔═╡ 84230c14-cda1-4645-8b6e-456564a5a3a7
begin
	reorder_WAIS = [[5], [3, 4], [2], [1]]
	var1D_WAIS_list = reorder_list(var1D_WAIS_alphabetical, reorder_WAIS)
end

# ╔═╡ 32271713-4f3d-4e9f-b9dc-2679bb38f821
begin
	tipgrid_plotcons = InitPlotConst(1, 1, ft_size, (base_rsl, base_rsl), colors, labels1D, dt1D, dt3D);
end

# ╔═╡ 230f4bc1-e9c7-4d5a-9222-63f08a5e155a
nc1D_WAIS_filt

# ╔═╡ e9187f69-b2d7-42ee-939b-edcdd5bff67b
nt_WAIS = length( nc1D_WAIS_dict[ nc1D_WAIS_filt[1] ][ var1D_WAIS_alphabetical[1] ] )

# ╔═╡ 616e2fc6-27a5-43d3-a4e1-70d4659cef7e
@bind tip_frame confirm( NumberField(1:nt_WAIS, default=nt_WAIS) )

# ╔═╡ 65408fb7-45df-4e75-8771-ecbf64190ec0
line_plotcons.resolution = (800, 800)

# ╔═╡ aac3fb96-b0a4-435f-9ce4-478de1c2d8fe
begin
	if length(nc1D_WAIS_list) > 10
		avg_wdw = 2;
		fmx_vec, a_vec, end_vec = get_final_value(nc1D_WAIS_dict, "V_sle", avg_wdw, tip_frame);
		extrema(end_vec)
		# fig_tgrid, ax_tgrid = scatter_tipping(fmx_vec, a_vec, end_vec, line_plotcons);
		fig_tgrid, ax_tgrid = hm_tipping(fmx_vec, a_vec, end_vec, line_plotcons);
		# scatter_ssp( ax, year, "industrial" )
		ant_ampl = 1.8
		# scatter_ssp_path( ax_tgrid, 2040, 2080, 10, "industrial", ant_ampl )
		ylims!(ax_tgrid, (2.0, 3.0))
		fig_tgrid
	end
end

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
		save_fig(plotsdir( string("yelmox_v1.75/32km/", exp_type)), name_tipgrid, "both", fig_tgrid)
	end
end

# ╔═╡ 6c661771-46c0-48ae-825d-945aa350fe8d
md"""
#### Plot the Time Series of WAIS 
"""

# ╔═╡ 10ce2861-9524-4f01-9471-5108686d1cd3
begin
	fig1D_WAIS = init_fig( line_plotcons );
	axs1D_WAIS = init_axs(fig1D_WAIS, line_plotcons, ["hyst_f_now", "mb", "V_sle", "A_ice"] );
	init_lines(axs1D_WAIS, nc1D_WAIS_dict, var1D_WAIS_list, line_plotcons, downsample_factor; tlim);
end

# ╔═╡ 7c37756b-3bd9-4716-8be4-f99cf025ca70
@bind hl_ix_WAIS Select(collect(1:length(ixs)), default = 1)

# ╔═╡ bf5467bc-7e8b-4dec-b9ed-ef0b3f0cb092
extract_ramp_parameters( nc1D_list[hl_ix_WAIS] )

# ╔═╡ e4425e68-fed4-4279-a915-f66ae8f2599a
var1D_WAIS_list

# ╔═╡ 04bb319e-bb36-4480-9ab0-130965407f0c
update_line(fig1D_WAIS, axs1D_WAIS, nc1D_WAIS_dict, var1D_WAIS_list, line_plotcons, hl_ix_WAIS, downsample_factor)

# ╔═╡ cadb13dc-1a5a-4c11-a0d6-661828ba2dbe
md"""
You can set the name of the target file for saving the plot:
"""

# ╔═╡ cb903cbf-c6c9-43c1-b093-3f7afa8c0640
@bind name_1DWAIS TextField(default = "WAIS_1D")

# ╔═╡ f8c289d4-6aca-41a1-ae9a-ea97e3671d7f
md"""
To save the figure, simply tick the following checkbox. Note that if not unticked, it will automatically save any further update of the figure!
"""

# ╔═╡ e8f3c2bf-fc73-4dcc-982d-975e1031ff2e
@bind save2 CheckBox(false)

# ╔═╡ e5a5419c-a416-4457-afc8-885257662fd1
begin
	if save2
		save_fig(plotsdir( string("yelmox_v1.75/32km/", exp_type)), name_1DWAIS, "both", fig1D_WAIS)
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
# ╠═94a5bc06-64f6-4434-8541-95260f891707
# ╠═8e0c75ef-ae2d-4a7e-8314-5521150f51ac
# ╠═35b2bd8f-de32-4275-b86d-0f182d984fe9
# ╠═e97ba5bd-4683-4c45-ba97-3b79e6e9bace
# ╟─e44728c2-fd00-4f46-8af3-5552c2ce086c
# ╟─fae93994-bb9f-45ce-8d04-e879a2b4ef6e
# ╠═ef76d945-7388-4642-984f-58e1197e7b10
# ╠═7eb4b4ec-2225-419f-835f-47022493a088
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
# ╠═b818d613-907f-47a3-a141-29f8a3c0555d
# ╠═e2ee4337-0251-4775-9f68-1cc3ca306b3b
# ╠═547fcf0a-1f15-43e0-9532-be9d2cfcd175
# ╟─e731a859-ff2a-4168-b11f-4aa72b625e02
# ╠═ebd7685c-be44-45e9-82b6-468b8689a9fa
# ╠═4144b41b-3d5a-4dcb-9e61-5d532a3a8854
# ╟─30140890-21ec-4084-97ca-dfef34c843c6
# ╟─854d7168-bed7-4d14-8939-035df6f7ddac
# ╟─55803f22-a1f5-49cf-bfad-867794eed0ee
# ╟─5a240e0b-52f7-4a02-b79b-087f2d3c5f39
# ╟─b81908a7-fe95-46c0-84bb-7f5a16c29e05
# ╟─661c6c30-0650-4669-833f-885dd6cc9418
# ╟─710603db-6bad-4bf8-b831-9c913f48949d
# ╠═2b1d04d9-ebec-475d-98eb-34eaff147759
# ╠═b2c9dcbf-c28d-4e3e-b523-076f8bbb1621
# ╠═bf9c6a34-3fcb-44dd-8d63-3e3f17811e1f
# ╠═6160c281-258f-4420-bd0d-5263bb501fe6
# ╠═84230c14-cda1-4645-8b6e-456564a5a3a7
# ╠═32271713-4f3d-4e9f-b9dc-2679bb38f821
# ╠═230f4bc1-e9c7-4d5a-9222-63f08a5e155a
# ╠═e9187f69-b2d7-42ee-939b-edcdd5bff67b
# ╠═616e2fc6-27a5-43d3-a4e1-70d4659cef7e
# ╠═65408fb7-45df-4e75-8771-ecbf64190ec0
# ╠═aac3fb96-b0a4-435f-9ce4-478de1c2d8fe
# ╟─fda9b297-43ad-4456-8af4-d389058ed6ac
# ╠═3402fdfc-d227-471f-839f-b405a4a0f06a
# ╟─b463897f-056e-4291-85e4-6fda689ba21d
# ╟─6f653476-791d-42c4-928c-ccad121373d1
# ╟─ff9dc3bd-4229-4898-9e19-e8c658fb279a
# ╟─6c661771-46c0-48ae-825d-945aa350fe8d
# ╠═10ce2861-9524-4f01-9471-5108686d1cd3
# ╠═7c37756b-3bd9-4716-8be4-f99cf025ca70
# ╠═bf5467bc-7e8b-4dec-b9ed-ef0b3f0cb092
# ╠═e4425e68-fed4-4279-a915-f66ae8f2599a
# ╠═04bb319e-bb36-4480-9ab0-130965407f0c
# ╟─cadb13dc-1a5a-4c11-a0d6-661828ba2dbe
# ╠═cb903cbf-c6c9-43c1-b093-3f7afa8c0640
# ╟─f8c289d4-6aca-41a1-ae9a-ea97e3671d7f
# ╟─e8f3c2bf-fc73-4dcc-982d-975e1031ff2e
# ╠═e5a5419c-a416-4457-afc8-885257662fd1
