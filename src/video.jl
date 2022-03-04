
function get_hm_video( fig2D, axs2D, nc2D_dict, exp_key, var_list, hm_plotcons, extrema2D_dict, tframes, framerate )
    record(fig2D, plotsdir("yelmo_video.mp4"), tframes; framerate = framerate) do t
        # node[] = Δx
        update_hm_2D( fig2D, axs2D, nc2D_dict, exp_key, t, var_list, hm_plotcons, extrema2D_dict )
    end
end