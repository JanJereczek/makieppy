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
	exp_type = "aqef_retreat/";
	path = string("/media/Data/Jan/yelmox_v1.75/", exp_type);
	nc3D_list = get_nc_lists(path, "yelmo2D.nc");
	nc1D_list = get_nc_lists(path, "yelmo1D.nc");

	ixs = collect(1:length(nc3D_list))
	nc3D_list_filt = filter_nc_list( nc3D_list, ixs );
	nc1D_list_filt = nc1D_list
end

# ╔═╡ 8e0c75ef-ae2d-4a7e-8314-5521150f51ac
begin
	vars1D = sort( get_vars( nc1D_list[1] ) )
	vars3D = sort( get_vars( nc3D_list[1] ) )
	nc1D_dict = init_dict( nc1D_list_filt )
end

# ╔═╡ 35b2bd8f-de32-4275-b86d-0f182d984fe9
begin
	# dt1D = get_dt( nc1D_list );
	# dt3D = get_dt( nc3D_list );
	dt1D = 1.0
	dt3D = 1000.0
end

# ╔═╡ e97ba5bd-4683-4c45-ba97-3b79e6e9bace
begin
	colors = load_colors(vars3D)
	labels3D = load_text3Dlabels(vars3D)
end

# ╔═╡ 5e62ebd3-06df-4429-9f11-f6a3581c6bfb


# ╔═╡ e7da9d6e-e0e1-42d8-a2ba-5358e19d7ad4
begin
	ctrl_dict = Dict()
	load_data!( nc1D_dict, ["hyst_f_now"] );
	ctrl_dict["ts"] = round.(nc1D_dict["/media/Data/Jan/yelmox_v1.75/aqef_retreat/yelmo1D.nc"]["hyst_f_now"][1:Int(dt3D):end]; digits=1)
	ctrl_dict["unit"] = "K"
end	

# ╔═╡ 0d80c308-60c1-4390-b999-ba87f62c5e67
md"""
## 3D Variables
"""

# ╔═╡ d2011ce2-0e85-4a00-9a11-b12c13dbc5f7
@bind var3D_list confirm( MultiCheckBox(vars3D , default =  ["z_srf", "uxy_s"]) )

# ╔═╡ 496ce8cd-5d9c-4a00-95ac-f0c26aad1a84
begin
	nc3D_dict = init_dict( nc3D_list_filt[1:end] );
	nc3D_dict = load_data!( nc3D_dict, var3D_list );
end

# ╔═╡ 101b282b-b92b-4b37-837b-f171dc778e32
load_data!( nc3D_dict, ["f_grnd", "z_bed", "lat2D", "lon2D", "f_ice"] );

# ╔═╡ a39d8efc-8f68-4a04-adbe-4c60be9b5e54
begin
	lowerlim = [0, 1e-8, -Inf, -Inf];
	upperlim = [1000, 4000, Inf, Inf];
	extrema3D_dict = get_extrema( nc3D_dict, var3D_list, lowerlim, upperlim );
end

# ╔═╡ 517e2adb-2fa4-4528-80a5-7de5b9b2b36d
@bind exp_id Select(ixs)

# ╔═╡ c582d0d2-aaad-4b3f-9dc0-42f4a5f3d2c6
begin
	exp_key = nc3D_list_filt[exp_id];
	nt = size( nc3D_dict[exp_key][ var3D_list[1] ] )[3];
	tframes = 1:nt;
	hm_plotcons = InitPlotConst(1, 2, 14, (1200, 600), colors, labels3D, 1.0, 1000.0);
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

# ╔═╡ 22394677-6c70-4b7b-a2d1-26524bbbcfbc
md"""
### Evolution Plot
"""

# ╔═╡ 4481bbba-39e6-415b-b1d7-12ff78968db6
@bind evol_var Select(var3D_list, default = "uxy_s")

# ╔═╡ 600d1e27-3695-42cb-ae7a-23aadad5633a
@bind evo_frames confirm(MultiCheckBox( collect(1:1:130) , default =  [1, 37, 57, 72, 74, 76] ))

# ╔═╡ c0ab2c56-1ae3-4302-abea-3db58eb41147
ctrl_dict["ts"]

# ╔═╡ 65bfe62a-1b2e-4368-8ee7-dd5662dd58ce
begin
	evolhm_plotcons = InitPlotConst(2, 3, 20, (1200, 1000), colors, labels3D, dt1D, dt3D);
	fig_evo = evolution_hmplot(nc3D_dict, ctrl_dict, evo_frames, evolhm_plotcons, evol_var, exp_key, extrema3D_dict)
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
		save_fig(plotsdir( string("yelmox_v1.75/32km/", exp_type)), name3, "both", fig_evo)
	end
end

# ╔═╡ a1adafa1-36fb-4461-a3dd-31cc720bb59b
md"""
### Error Plots
"""

# ╔═╡ e4f54db5-834a-44b5-b383-458ba850b0bc
z_ref, f_ref, u_ref = load_pd_state()

# ╔═╡ 1ebe7128-37ee-41c1-8777-1a17b2302b49
fig_z = error_plot_z(nc3D_dict, z_ref, f_ref)

# ╔═╡ c9369b1c-cf9f-4464-963b-6f88a459c319
md"""
To save the figure, simply tick the following checkbox. Note that if not unticked, it will automatically save any further update of the figure!
"""

# ╔═╡ e887c709-ce17-4530-b8a9-138c0456698d
@bind save_error_z CheckBox(false)

# ╔═╡ a144768a-2eaa-4b27-8371-db80af9b8db0
@bind name_error_z TextField(default = "error_z")

# ╔═╡ 6a1f3b14-7141-4696-9fc3-d157f6720988
begin
	if save_error_z
		save_fig(plotsdir( string("yelmox_v1.75/32km/", exp_type)), name_error_z, "both", fig_z)
	end
end

# ╔═╡ 08585af6-312a-4e6e-93c9-94a9060cded8
fig_u = error_plot_u(nc3D_dict, u_ref)

# ╔═╡ 1af8a7ff-72d3-4d67-9713-f69e8c0fd8a2
md"""
To save the figure, simply tick the following checkbox. Note that if not unticked, it will automatically save any further update of the figure!
"""

# ╔═╡ 69b8b6cc-a02f-44a2-9c26-c119e6d7413e
@bind save_error_u CheckBox(false)

# ╔═╡ bc3e2f81-2f22-4a61-81f2-95fe8b45e5e6
@bind name_error_u TextField(default = "error_u")

# ╔═╡ d8e14764-a406-4824-b591-1ca862101a39
begin
	if save_error_u
		save_fig(plotsdir( string("yelmox_v1.75/32km/", exp_type)), name_error_u, "both", fig_u)
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
# ╠═35b2bd8f-de32-4275-b86d-0f182d984fe9
# ╠═e97ba5bd-4683-4c45-ba97-3b79e6e9bace
# ╠═5e62ebd3-06df-4429-9f11-f6a3581c6bfb
# ╠═e7da9d6e-e0e1-42d8-a2ba-5358e19d7ad4
# ╟─0d80c308-60c1-4390-b999-ba87f62c5e67
# ╠═d2011ce2-0e85-4a00-9a11-b12c13dbc5f7
# ╠═496ce8cd-5d9c-4a00-95ac-f0c26aad1a84
# ╠═101b282b-b92b-4b37-837b-f171dc778e32
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
# ╟─22394677-6c70-4b7b-a2d1-26524bbbcfbc
# ╠═4481bbba-39e6-415b-b1d7-12ff78968db6
# ╠═600d1e27-3695-42cb-ae7a-23aadad5633a
# ╠═c0ab2c56-1ae3-4302-abea-3db58eb41147
# ╠═65bfe62a-1b2e-4368-8ee7-dd5662dd58ce
# ╟─25bc2940-c6a5-4104-b5aa-b7c2e2462c31
# ╠═0035667d-7d21-4e22-8c7a-7f7d45e1b936
# ╠═4f171024-2c63-4ca6-a477-7cd11fa68423
# ╟─711ee795-3f82-4f31-8fda-fb596f8ea2cf
# ╟─a1adafa1-36fb-4461-a3dd-31cc720bb59b
# ╠═e4f54db5-834a-44b5-b383-458ba850b0bc
# ╠═1ebe7128-37ee-41c1-8777-1a17b2302b49
# ╟─c9369b1c-cf9f-4464-963b-6f88a459c319
# ╟─e887c709-ce17-4530-b8a9-138c0456698d
# ╟─a144768a-2eaa-4b27-8371-db80af9b8db0
# ╟─6a1f3b14-7141-4696-9fc3-d157f6720988
# ╠═08585af6-312a-4e6e-93c9-94a9060cded8
# ╟─1af8a7ff-72d3-4d67-9713-f69e8c0fd8a2
# ╟─69b8b6cc-a02f-44a2-9c26-c119e6d7413e
# ╟─bc3e2f81-2f22-4a61-81f2-95fe8b45e5e6
# ╟─d8e14764-a406-4824-b591-1ca862101a39
# ╟─c69d8900-4f31-4e8e-b066-219c187531b5
# ╠═0d9e0b46-9e6b-4da0-ac99-05cfab2d4743
# ╠═2cd75200-4c80-4818-bd4e-22ba0ef1271b
# ╠═e9ad8f74-5646-4bc7-bcc6-039575070a2f
# ╠═7d1c8eb3-bfa3-4d21-8412-bd56d30fd2a3
# ╠═84dd18b9-3a00-499a-99ad-4000f2b3c245
# ╠═c1582e81-27cf-4644-ae08-168f87eefa8b
# ╠═80146c29-e13b-47ec-b8d3-040929e0507a
# ╟─4d9f8ca1-604c-4fe6-a4ee-ded966ee32ea
# ╠═9e565b97-d959-4624-a71e-5ed186e2264c
# ╠═491c1ca5-dfd0-4da4-9ac6-e99f81688f80
