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

# ╔═╡ acb1556b-dce7-4ec1-9f9c-85aacf500553
begin
	include(srcdir("utils.jl"));
	include(srcdir("datahandle.jl"));
	include(srcdir("plot.jl"));
end

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
"""

# ╔═╡ fc889e21-3300-42d6-928f-c5f0b193bc60
md"""
#### Self-Written Functions
"""

# ╔═╡ 5978d34d-80bf-45a4-bfec-b88d0d4bb5e5
@bind load_struct CheckBox(true)

# ╔═╡ b79c0b90-12b2-4108-af34-2caf4a269c10
begin
	if load_struct
		include(srcdir("structs.jl"))
	end
end

# ╔═╡ 0895e44a-6894-4f1d-84fe-6f1838783b32
begin
	path = "/media/Data/Jan/GridRamp1/";
	nc1D_list, nc2D_list = get_nc_lists(path);
	ixs = collect(1:3);
	nc1D_list_filt = filter_nc_list( nc1D_list, ixs );
	nc2D_list_filt = filter_nc_list( nc2D_list, ixs );
end

# ╔═╡ e44728c2-fd00-4f46-8af3-5552c2ce086c
md"""
## 1D Variables
"""

# ╔═╡ 3dfe71c0-e6ad-4712-94ca-cc2912a99ca4
begin
	var1D_list = ["V_ice", "hyst_f_now", "bmb", "smb"];
	nc1D_dict = init_dict( nc1D_list_filt );
	nc1D_dict = load_data!( nc1D_dict, var1D_list );
	line_plotcons = InitPlotConst(2, 2, 20, (1000, 1000));
	fig1D = init_fig( line_plotcons );
	axs1D = init_axs(fig1D, line_plotcons, var1D_list);
end

# ╔═╡ 547fcf0a-1f15-43e0-9532-be9d2cfcd175
@bind hl_ix Select(ixs, default = 1)

# ╔═╡ 4144b41b-3d5a-4dcb-9e61-5d532a3a8854
update_line(fig1D, axs1D, nc1D_dict, var1D_list, line_plotcons, hl_ix)

# ╔═╡ 0d80c308-60c1-4390-b999-ba87f62c5e67
md"""
## 3D Variables
"""

# ╔═╡ a39d8efc-8f68-4a04-adbe-4c60be9b5e54
begin
	var_list = ["H_ice", "uxy_s"];
	nc2D_dict = init_dict( nc2D_list_filt );
	nc2D_dict = load_data!( nc2D_dict, var_list );
	extrema2D_dict = get_extrema( nc2D_dict, var_list, nc2D_list_filt );
end

# ╔═╡ 517e2adb-2fa4-4528-80a5-7de5b9b2b36d
@bind exp_id Select(ixs)

# ╔═╡ c582d0d2-aaad-4b3f-9dc0-42f4a5f3d2c6
begin
	exp_key = nc2D_list_filt[exp_id];
	nt = size(nc2D_dict[exp_key]["H_ice"])[3];
	hm_plotcons = InitPlotConst(1, 2, 20, (1200, 500));
	fig2D = init_fig( hm_plotcons );
	axs2D = init_hm_axs(fig2D, hm_plotcons, var_list, exp_key, extrema2D_dict);
end

# ╔═╡ 916c521b-7e41-49f6-a94a-e401b09e8f3e
@bind tframe Select(1:nt)

# ╔═╡ ce11169d-8dc1-4d9a-85d3-ed0e68447cd7
begin
	fig2D_updated = update_hm_2D(fig2D, axs2D, nc2D_dict, exp_key, tframe, var_list, hm_plotcons, extrema2D_dict )
end

# ╔═╡ Cell order:
# ╟─fcc18548-3ab8-421f-b2bd-96189ae925e5
# ╠═d617b6f2-9b90-11ec-0b63-87c241eb148b
# ╠═761c7fa9-e262-4452-8026-1cb2aad34704
# ╟─a576c089-68c3-4af5-97e0-285dc564184f
# ╠═1b29ed5a-dc9c-498e-81fb-5cfbf1404810
# ╟─fc889e21-3300-42d6-928f-c5f0b193bc60
# ╠═5978d34d-80bf-45a4-bfec-b88d0d4bb5e5
# ╠═b79c0b90-12b2-4108-af34-2caf4a269c10
# ╠═acb1556b-dce7-4ec1-9f9c-85aacf500553
# ╠═0895e44a-6894-4f1d-84fe-6f1838783b32
# ╟─e44728c2-fd00-4f46-8af3-5552c2ce086c
# ╠═3dfe71c0-e6ad-4712-94ca-cc2912a99ca4
# ╠═547fcf0a-1f15-43e0-9532-be9d2cfcd175
# ╠═4144b41b-3d5a-4dcb-9e61-5d532a3a8854
# ╟─0d80c308-60c1-4390-b999-ba87f62c5e67
# ╠═a39d8efc-8f68-4a04-adbe-4c60be9b5e54
# ╠═517e2adb-2fa4-4528-80a5-7de5b9b2b36d
# ╠═c582d0d2-aaad-4b3f-9dc0-42f4a5f3d2c6
# ╠═916c521b-7e41-49f6-a94a-e401b09e8f3e
# ╠═ce11169d-8dc1-4d9a-85d3-ed0e68447cd7
