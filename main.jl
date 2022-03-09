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

+ Pkg.jl => Easy installation.
+ Julia + Makie => Faster plotting.
+ Pluto + PlutoUI => Great widgets and improved interactivity compared to Jupyter.
+ Makie.jl => easier layout and video generation than Matplotlib.
+ Colors.jl => one-line definition of colormaps.
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
	path = "/media/Data/Jan/yelmox_v1.75/ramp1/";
	nc1D_list = get_nc_lists(path, "yelmo1D.nc");
	nc1D_WAIS_list = get_nc_lists(path, "yelmo1D_WAIS.nc");
	nc3D_list = get_nc_lists(path, "yelmo2D.nc");
	
	ixs = collect(1:length(nc3D_list))
	nc1D_list_filt = filter_nc_list( nc1D_list, ixs );
	nc3D_list_filt = filter_nc_list( nc3D_list, ixs );
	colors, labels1D, labels3D = load_colors(), load_1Dlabels(), load_3Dlabels()
end

# ╔═╡ e44728c2-fd00-4f46-8af3-5552c2ce086c
md"""
## 1D Variables
"""

# ╔═╡ 8e0c75ef-ae2d-4a7e-8314-5521150f51ac
begin
	vars1D = sort( get_vars( nc1D_list[1] ) )
	vars3D = sort( get_vars( nc3D_list[1] ) )
end

# ╔═╡ ef76d945-7388-4642-984f-58e1197e7b10
@bind var1D_list MultiCheckBox(vars1D , default =  ["V_ice", "hyst_f_now", "bmb", "smb"])

# ╔═╡ 3dfe71c0-e6ad-4712-94ca-cc2912a99ca4
begin
	dt1D = 1;
	dt3D = 1000;
	downsample_factor = 100;
	# var1D_list = ["V_ice", "hyst_f_now", "bmb", "smb"];
	# @bind my_functions MultiCheckBox([sin, cos, tan])
	nc1D_dict = init_dict( nc1D_list_filt );
	nc1D_dict = load_data!( nc1D_dict, var1D_list );
	line_plotcons = InitPlotConst(2, 2, 20, (1000, 1000), colors, labels1D, dt1D, dt3D);
	fig1D = init_fig( line_plotcons );
	axs1D = init_axs(fig1D, line_plotcons, var1D_list);
end

# ╔═╡ e2ee4337-0251-4775-9f68-1cc3ca306b3b
init_lines(axs1D, nc1D_dict, var1D_list, line_plotcons, downsample_factor)

# ╔═╡ 547fcf0a-1f15-43e0-9532-be9d2cfcd175
@bind hl_ix Select(ixs, default = 1)

# ╔═╡ 4144b41b-3d5a-4dcb-9e61-5d532a3a8854
update_line(fig1D, axs1D, nc1D_dict, var1D_list, line_plotcons, hl_ix, downsample_factor)

# ╔═╡ d3a22df5-56dd-4e54-b987-f6097e01f6bd
begin
	if false
		save_fig(plotsdir("yelmox_v1.75/aqef_retreat/"), "1D", "both", fig1D)
	end
end

# ╔═╡ 661c6c30-0650-4669-833f-885dd6cc9418
md"""
## Comparing End States
"""

# ╔═╡ 32271713-4f3d-4e9f-b9dc-2679bb38f821
begin
	nc1D_WAIS_dict = init_dict( nc1D_WAIS_list );
	nc1D_WAIS_dict = load_data!( nc1D_WAIS_dict, ["H_ice"] );
	avg_wdw = 10;
	fmx_vec, a_vec, end_vec = get_final_value(nc1D_WAIS_dict, "H_ice", avg_wdw);
	scatter_tipping(fmx_vec, a_vec, end_vec, line_plotcons);
end

# ╔═╡ 0d80c308-60c1-4390-b999-ba87f62c5e67
md"""
## 3D Variables
"""

# ╔═╡ d2011ce2-0e85-4a00-9a11-b12c13dbc5f7
@bind var3D_list MultiCheckBox(vars3D , default =  ["H_ice", "uxy_s"])

# ╔═╡ 496ce8cd-5d9c-4a00-95ac-f0c26aad1a84
begin
	nc3D_dict = init_dict( nc3D_list_filt );
	nc3D_dict = load_data!( nc3D_dict, var_list );
end

# ╔═╡ a39d8efc-8f68-4a04-adbe-4c60be9b5e54
begin
	lowerlim = [0.0, 0.0];
	upperlim = [Inf, 2000.0];
	extrema3D_dict = get_extrema( nc3D_dict, var_list, lowerlim, upperlim, nc3D_list_filt );
end

# ╔═╡ 517e2adb-2fa4-4528-80a5-7de5b9b2b36d
@bind exp_id Select(ixs)

# ╔═╡ c582d0d2-aaad-4b3f-9dc0-42f4a5f3d2c6
begin
	exp_key = nc3D_list_filt[exp_id];
	nt = size( nc3D_dict[exp_key]["H_ice"] )[3];
	tframes = 1:nt;
	hm_plotcons = InitPlotConst(1, 2, 20, (1200, 500), colors, labels3D, dt1D, dt3D);
	fig3D = init_fig( hm_plotcons );
	axs3D = init_hm_axs(fig3D, hm_plotcons, var_list, exp_key, extrema3D_dict);
end

# ╔═╡ 916c521b-7e41-49f6-a94a-e401b09e8f3e
@bind tframe Select(tframes)

# ╔═╡ ce11169d-8dc1-4d9a-85d3-ed0e68447cd7
begin
	fig3D_updated = update_hm_3D( fig3D, axs3D, nc3D_dict, nc1D_dict, exp_key, tframe, var_list, hm_plotcons, extrema3D_dict )
end

# ╔═╡ da4ed259-1752-4209-b555-4ab6f1dda208
md"""
## Generate Video
"""

# ╔═╡ 7a215c7e-860b-4ee2-84de-c95404678d41
@bind gen_vid CheckBox(false)

# ╔═╡ daae5d13-c460-4de4-926b-eca63f60f8b0
begin
	if gen_vid
		get_hm_video( fig3D, axs3D, nc3D_dict, nc1D_dict, exp_key, var_list, hm_plotcons, extrema3D_dict, tframes, 5 )
	end
end

# ╔═╡ 22394677-6c70-4b7b-a2d1-26524bbbcfbc
md"""
### Evolution Plot
"""

# ╔═╡ 4481bbba-39e6-415b-b1d7-12ff78968db6
@bind evol_var Select()

# ╔═╡ 65bfe62a-1b2e-4368-8ee7-dd5662dd58ce
begin
	evolhm_plotcons = InitPlotConst(2, 2, 20, (1200, 1200), colors, labels3D, dt1D, dt3D);
	evolution_frames = collect(1:10:30)
	evolution_hmplot(evolution_frames, evolhm_plotcons, "H_ice", exp_key, extrema3D_dict)
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
plot_diffhm_3D(nc3D_dict, exp_key1, exp_key2, tframe1, tframe2, var_list, hm_plotcons)

# ╔═╡ 80146c29-e13b-47ec-b8d3-040929e0507a


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
# ╟─e44728c2-fd00-4f46-8af3-5552c2ce086c
# ╠═8e0c75ef-ae2d-4a7e-8314-5521150f51ac
# ╠═ef76d945-7388-4642-984f-58e1197e7b10
# ╠═3dfe71c0-e6ad-4712-94ca-cc2912a99ca4
# ╠═e2ee4337-0251-4775-9f68-1cc3ca306b3b
# ╠═547fcf0a-1f15-43e0-9532-be9d2cfcd175
# ╠═4144b41b-3d5a-4dcb-9e61-5d532a3a8854
# ╠═d3a22df5-56dd-4e54-b987-f6097e01f6bd
# ╟─661c6c30-0650-4669-833f-885dd6cc9418
# ╠═32271713-4f3d-4e9f-b9dc-2679bb38f821
# ╟─0d80c308-60c1-4390-b999-ba87f62c5e67
# ╠═d2011ce2-0e85-4a00-9a11-b12c13dbc5f7
# ╠═496ce8cd-5d9c-4a00-95ac-f0c26aad1a84
# ╠═a39d8efc-8f68-4a04-adbe-4c60be9b5e54
# ╠═517e2adb-2fa4-4528-80a5-7de5b9b2b36d
# ╠═c582d0d2-aaad-4b3f-9dc0-42f4a5f3d2c6
# ╠═916c521b-7e41-49f6-a94a-e401b09e8f3e
# ╠═ce11169d-8dc1-4d9a-85d3-ed0e68447cd7
# ╟─da4ed259-1752-4209-b555-4ab6f1dda208
# ╠═7a215c7e-860b-4ee2-84de-c95404678d41
# ╠═daae5d13-c460-4de4-926b-eca63f60f8b0
# ╟─22394677-6c70-4b7b-a2d1-26524bbbcfbc
# ╠═4481bbba-39e6-415b-b1d7-12ff78968db6
# ╠═65bfe62a-1b2e-4368-8ee7-dd5662dd58ce
# ╟─c69d8900-4f31-4e8e-b066-219c187531b5
# ╠═0d9e0b46-9e6b-4da0-ac99-05cfab2d4743
# ╠═2cd75200-4c80-4818-bd4e-22ba0ef1271b
# ╠═e9ad8f74-5646-4bc7-bcc6-039575070a2f
# ╠═7d1c8eb3-bfa3-4d21-8412-bd56d30fd2a3
# ╠═84dd18b9-3a00-499a-99ad-4000f2b3c245
# ╠═c1582e81-27cf-4644-ae08-168f87eefa8b
# ╠═80146c29-e13b-47ec-b8d3-040929e0507a
