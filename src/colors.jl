using Colors

function load_colors()
    c = Dict()
    c["H_ice"] = cgrad(:ice, 15, categorical = true)
    c["uxy_s"] = cgrad(:dense, 15, categorical = true)
    return c
end