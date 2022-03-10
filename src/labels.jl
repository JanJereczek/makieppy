# Define the latex labels dictionary for plotting.
# 1D:
function load_1Dlabels()
    l = Dict()
    l["V_ice"] = L"$V_{ice}$ [$10^6$ cubic km]"
    l["hyst_f_now"] = L"$\Delta T$ [K]"
    l["bmb"] = L"$\frac{d m}{d t}_{base}$ [1]"
    l["smb"] = L"$\frac{d m}{d t}_{surf}$ [1]"
    return l
end
# 3D:
function load_3Dlabels()
    l = Dict()
    l["H_ice"] = L"$H_{ice}$ [m]"
    l["uxy_s"] = L"$u_{xy,s}$ [m/s]"
    return l
end