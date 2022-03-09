
function get_hm_video( fig3D, axs3D, nc3D_dict, nc1D_dict, exp_key, var_list, hm_plotcons, extrema3D_dict, tframes, framerate )
    record(fig3D, plotsdir("yelmo_video.mp4"), tframes; framerate = framerate) do t
        # node[] = Δx
        update_hm_3D( fig3D, axs3D, nc3D_dict, nc1D_dict, exp_key, t, var_list, hm_plotcons, extrema3D_dict )
    end
end