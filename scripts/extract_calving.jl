
using DrWatson;
@quickactivate "makieppy";
using NCDatasets, CairoMakie, PlutoUI, Statistics;
include(srcdir("structs.jl"));
include(srcdir("utils.jl"));
include(srcdir("datahandle.jl"));
include(srcdir("plot.jl"));
include(srcdir("colors.jl"));
include(srcdir("labels.jl"));
include(srcdir("video.jl"));

exp_type = "aqef_retreat/";
path = string("/media/Data/Jan/yelmox_v1.75/", exp_type);

nc3D_list = get_nc_lists(path, "yelmo2D.nc");
vars3D = sort( get_vars( nc3D_list[1] ) )
dt3D = get_dt( nc3D_list );
colors = load_colors(vars3D)
labels3D = load_3Dlabels(vars3D)

var3D_list = ["calv"]
nc3D_dict = init_dict( nc3D_list );
nc3D_dict = load_data!( nc3D_dict, var3D_list );

exp = nc3D_dict["nc_list"][1]
C = nc3D_dict[exp]["calv"]
n1, n2, n3 = size(C)
c = zeros( n3 )

for i in 1:n3
    c[i] = -mean(C[:, :, i])
end
c[1] = c[2]
lines(c)

dt1D = 1.0
t3 = 0:dt3D:dt3D*(n3-1)
interp_linear = LinearInterpolation(t3, c)

t1 = 0:dt1D:dt3D*(n3-1)
c_dense = interp_linear.(t1)

ds = Dataset("/media/Data/Jan/yelmox_v1.75/aqef_retreat/yelmo1D.nc","a")
ds.attrib["calving"] = c_dense
close(ds);

# # ╔═╡ a39d8efc-8f68-4a04-adbe-4c60be9b5e54
# begin
# 	lowerlim = [-1000, -1000, -Inf, -Inf];
# 	upperlim = [1000, 1000, Inf, Inf];
# 	extrema3D_dict = get_extrema( nc3D_dict, var3D_list, lowerlim, upperlim );
# end

# # ╔═╡ 517e2adb-2fa4-4528-80a5-7de5b9b2b36d
# @bind exp_id Select(ixs)

# # ╔═╡ c582d0d2-aaad-4b3f-9dc0-42f4a5f3d2c6
# begin
# 	exp_key = nc3D_list_filt[exp_id];
# 	nt = size( nc3D_dict[exp_key][ var3D_list[1] ] )[3];
# 	tframes = 1:nt;
# 	# line_plotcons = InitPlotConst(nrows1D, ncols1D, ft_size, rsl, colors, labels1D, dt1D, dt3D);
# 	hm_plotcons = InitPlotConst(1, 2, ft_size, (1200, 600), colors, labels3D, dt1D, dt3D);
# 	fig3D = init_fig( hm_plotcons );
# 	axs3D = init_hm_axs(fig3D, hm_plotcons, var3D_list, exp_key, extrema3D_dict);
# end

# # ╔═╡ 916c521b-7e41-49f6-a94a-e401b09e8f3e
# @bind tframe Select(tframes)

# # ╔═╡ ce11169d-8dc1-4d9a-85d3-ed0e68447cd7
# begin
# 	fig3D_updated = update_hm_3D( fig3D, axs3D, nc3D_dict, nc1D_dict, exp_key, tframe, var3D_list, hm_plotcons, extrema3D_dict )
# end
