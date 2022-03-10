function rms( pd_err::Array )
    return sqrt( sum( pd_err .^ 2 ) )
end

function obs_rmse( nc_dict::Dict, key::String )
    H_err = nc_dict[ key ][ "H_ice_pd_err" ]
    u_err = nc_dict[ key ][ "uxy_s_pd_err" ]
    return rms( H_err ), rms( u_err )
end

function load_error_vars( nc_dict::Dict )
    nc_dict = load_data!( nc_dict , ["H_ice_pd_err", "uxy_s_pd_err"] )
end

function load_rmse2dict!( nc_dict::Dict )
    for key in nc_dict["nc_list"]
        nc_dict[ key ][ "H_ice_pd_err" ], nc_dict[ key ][ "uxy_s_pd_err" ] = obs_rmse( nc_dict, key )
    end
end

function load_ref()
    pd_dict = Dict()
    ref_file = datadir("ANT-32KM_TOPO-BedMachine.nc")
    NCDataset( ref_file ) do ds
        pd_dict[ "mask" ] = copy( ds[ "mask" ] )
    end
    return pd_dict
end

function get_grline( M::Array, g::Float64 )
    G = falses( size(M) )
    for i in 2:size(M)[1]-1         # Grounding line not at the border of the domain anyway :)
        for j in 2:size(M)[2]-1     # Same here! Notice: we consider a von Neumann neighbourhood.
            neighbours = ( [M[i-1, j], M[i+1, j], M[i, j-1], M[i, j+1]] != [g, g, g, g] )
            if (M[i, j] == g) & neighbours
                G[i,j] = true
            end
        end
    end
    return G
end

function get_ref_grline!( pd_dict::Dict )
    M = pd_dict[ "mask" ]
    pd_dict[ "G" ] = get_grline(M, 2.0)
end

function get_crrnt_grline( nc_dict::Dict, key, frame )
    if sum( pd_dict[ key ][ "G" ][ :, :, frame ] ) < 1.0    # Only make the computation if it has not been made yet.
        M = nc_dict[ key ][ "f_grnd" ][:, :, frame]
        pd_dict[ key ][ "G" ][ :, :, frame ] = get_grline(M, 1.0)
    end
end