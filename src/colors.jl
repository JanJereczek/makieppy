using Colors

# Defines a dictionnary associating the 3D outputs with colormaps.
# Some maps have exponential scaling to resolve better the low values.
function load_colors(vars)
    c = Dict()
    c["H_ice"] = cgrad(:ice, 15, categorical = true, rev = true, scale = :exp)
    # c["z_srf"] = cgrad([:white, :ice], 15, categorical = true, rev = true, scale = :exp)
    c["z_srf"] = cgrad([:royalblue4, :royalblue, :steelblue2, :azure], scale = :exp)
    c["uxy_s"] = cgrad(:dense, scale = :exp)
    # c["uxy_s"] = cgrad(:dense, 15, categorical = true, scale = :exp)

    defined = keys(c)
    for var in vars
        if !(var in defined)
            c[var] = cgrad(:rainbow1, 15, categorical = true)
        end
    end
    return c
end