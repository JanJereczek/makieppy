using Colors

# Defines a dictionnary associating the 3D outputs with colormaps.
# Some maps have exponential scaling to resolve better the low values.
function load_colors()
    c = Dict()
    c["H_ice"] = cgrad(:ice, 15, categorical = true, rev = true, scale = :exp)
    c["uxy_s"] = cgrad(:dense, 15, categorical = true, scale = :exp)
    return c
end