# Define the latex labels dictionary for plotting.
# 1D:
function load_1Dlabels(vars)
    l = Dict()
    # Uppercase
    l["A_ice"] = L"$A_{\mathrm{ice}}$ [$10^6$ $\mathrm{km}^2$]"
    l["A_ice_f"] = L"$A_{\mathrm{ice,f}}$ [$10^6$ $\mathrm{km}^2$]"
    l["A_ice_g"] = L"$A_{\mathrm{ice,g}}$ [$10^6$ $\mathrm{km}^2$]"
    l["H_ice"] = L"$H_{\mathrm{ice}}$ [m]"
    l["H_ice_f"] = L"$H_{\mathrm{ice,f}}$ [m]"
    l["H_ice_g"] = L"$A_{\mathrm{ice,g}}$ [m]"
    l["H_ice_max"] = L"$H_{\mathrm{ice, max}}$ [m]"
    l["H_w"] = L"$H_{w}$ [m]"
    l["T_shlf"] = L"$T_{shlf}$ [K]"
    l["T_srf"] = L"$T_{srf}$ [K]"
    l["V_dT"] = L"$V_{T}$ []"
    l["V_ice"] = L"$V_{\mathrm{ice}}$ [$10^6$ $\mathrm{km}^3$]"
    l["V_ice_f"] = L"$V_{\mathrm{ice,f}}$ [$10^6$ $\mathrm{km}^3$]"
    l["V_ice_g"] = L"$V_{\mathrm{ice,g}}$ [$10^6$ $\mathrm{km}^3$]"
    l["V_sle"] = L"$V_{\mathrm{ice}}$ [mSLE]"
    l["V_sl"] = L"$V_{\mathrm{ice}}$ [$10^6$ $\mathrm{km}^3$SVE]"

    # Lowercase
    l["bmb"] = L"$\dot{m}_{base}$ [m$ \, \mathrm{yr}^{-1}$]"
    l["bmb_g"] = L"$\dot{m}_{base,g}$ [m$ \, \mathrm{yr}^{-1}$]"
    l["bmb_shlf"] = L"$\dot{m}_{base,shlf}$ [m$ \, \mathrm{yr}^{-1}$]"
    l["calv"] = L"Calving rate $\dot{c}$ [m$ \, \mathrm{yr}^{-1}$]"
    l["dHicedt"] = L"$\frac{d H}{d t}$ [m$ \, \mathrm{yr}^{-1}$]"
    l["dVicedt"] = L"$\frac{d V}{d t}$ [$10^{-3}$ [$\mathrm{km}^3 \, \mathrm{yr}^{-1}$]"
    l["dzsrfdt"] = L"$\frac{d z_{srf}}{d t}$ [m$ \, \mathrm{yr}^{-1}$]"
    l["f_pmp"] = L"$f_{pmp}$ [1]"
    l["fwf"] = L"$fwf$ [Sv]"
    # l["hyst_df_dt"] = L"$\frac{d m}{d t}_{base}$ [1]"
    # l["hyst_dv_dt"] = L"$\frac{d m}{d t}_{base}$ [1]"
    l["hyst_f_now"] = L"Atmospheric $\Delta T$ [K]"
    l["mb"] = L"Mass balance $\dot{m}$ [m$ \, \mathrm{yr}^{-1}$]"
    l["smb"] = L"$\dot{m}_{surf}$ [m$ \, \mathrm{yr}^{-1}$]"
    l["time"] = L"$t$ [yr]"
    l["uxy_b"] = L"$u_{xy,b}$ [m$ \, \mathrm{yr}^{-1}$]"
    l["uxy_b_f"] = L"$u_{xy,b,f}$ [m$ \, \mathrm{yr}^{-1}$]"
    l["uxy_b_g"] = L"$u_{xy,b,g}$ [m$ \, \mathrm{yr}^{-1}$]"
    l["uxy_bar"] = L"$\bar{u}_{xy}$ [m$ \, \mathrm{yr}^{-1}$]"
    l["uxy_bar_f"] = L"$\bar{u}_{xy,f}$ [m$ \, \mathrm{yr}^{-1}$]"
    l["uxy_bar_g"] = L"$\bar{u}_{xy,g}$ [m$ \, \mathrm{yr}^{-1}$]"
    l["uxy_s"] = L"$u_{xy,s}$ [m$ \, \mathrm{yr}^{-1}$]"
    l["uxy_s_f"] = L"$u_{xy,s,f}$ [m$ \, \mathrm{yr}^{-1}$]"
    l["uxy_s_g"] = L"$u_{xy,s,g}$ [m$ \, \mathrm{yr}^{-1}$]"
    # l["xc"] = L"$\frac{d m}{d t}_{base}$ [1]"
    # l["yc"] = L"$\frac{d m}{d t}_{base}$ [1]"
    l["z_bed"] = L"$z_{bed}$ [m]"
    l["z_sl"] = L"$z_{sl}$ [m]"
    l["z_srf"] = L"$z_{srf}$ [m]"
    l["z_srf_g"] = L"$z_{srf,g}$ [m]"
    # l["zeta"] = L"$\frac{d m}{d t}_{base}$ [1]"

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
    l["H_ice"] = L"$H_{\mathrm{ice}}$ [m]"
    l["H_ice_pd_err"] = L"$\Delta H_{\mathrm{ice}}$ [m]"
    l["N_eff"] = L"$N_{eff}$ [bar]"
    l["T_srf"] = L"$T_{srf}$ [K]"
    l["Ta_ann"] = L"$\Delta T_{a}$ [K]"

    l["bmb"] = L"$\frac{d m}{d t}_{base}$ [m$ \, \mathrm{yr}^{-1}$]"
    l["calv"] = L"$\frac{d m}{d t}_{calv}$ [m$ \, \mathrm{yr}^{-1}$]"
    l["f_grnd"] = L"$f_{grnd}$ [1]"
    l["f_ice"] = L"$f_{\mathrm{ice}}$ [1]"
    l["mb_applied"] = L"$\frac{d m}{d t}$ [m$ \, \mathrm{yr}^{-1}$]"
    l["smb"] = L"$\frac{d m}{d t}_{surf}$ [m$ \, \mathrm{yr}^{-1}$]"
    l["uxy_s"] = L"$u_{xy,s}$ [m$ \, \mathrm{yr}^{-1}$]"
    l["uxy_s_pd_err"] = L"$\Delta u_{xy,s}$ [m$ \, \mathrm{yr}^{-1}$]"
    l["visc_eff_int"] = L"$visc_{eff,int}$ [Pa $\cdot$ yr $\cdot$ m]"
    l["z_bed"] = L"$z_{bed}$ [m]"
    l["z_srf"] = L"$z_{srf}$ [m]"
    l["z_srf_pd_err"] = L"$\Delta z_{srf}$ [m]"

    defined = keys(l)
    for var in vars
        if !(var in defined)
            l[var] = var
        end
    end
    return l
end