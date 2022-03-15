# Define the latex labels dictionary for plotting.
# 1D:
function load_1Dlabels(vars)
    l = Dict()
    l["A_ice"] = L"$A_{ice}$ []"
    l["A_ice_f"] = L"$A_{ice,f}$ []"
    l["A_ice_g"] = L"$A_{ice,g}$ []"
    l["H_ice"] = L"$H_{ice}$ []"
    l["H_ice_f"] = L"$H_{ice,f}$ []"
    l["H_ice_g"] = L"$A_{ice,g}$ []"
    l["H_ice_max"] = L"$H_{ice, max}$ []"
    l["H_w"] = L"$H_{w}$ []"
    l["V_ice"] = L"$V_{ice}$ [$10^6$ cubic km]"
    l["hyst_f_now"] = L"$\Delta T$ [K]"
    l["bmb"] = L"$\frac{d m}{d t}_{base}$ [1]"
    l["smb"] = L"$\frac{d m}{d t}_{surf}$ [1]"

    defined = keys(l)
    for var in vars
        if !(var in defined)
            l[var] = var
        end
    end
    return l
end

# 3D:
function load_3Dlabels(vars)
    l = Dict()
    l["H_ice"] = L"$H_{ice}$ [m]"
    l["uxy_s"] = L"$u_{xy,s}$ [m/s]"

    defined = keys(l)
    for var in vars
        if !(var in defined)
            l[var] = var
        end
    end
    return l
end