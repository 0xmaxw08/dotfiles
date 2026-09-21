hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("GTK_THEME", "Adwaita:dark")

-- Force Hyprland to render on Intel iGPU (card2), NVIDIA (card1) available for offload
hl.env("AQ_DRM_DEVICES", "/dev/dri/card1:/dev/dri/card2")
hl.env("WLR_DRM_DEVICES", "/dev/dri/card1:/dev/dri/card2")

-- NVIDIA-specific fixes (apply when apps use prime-run to offload to the dGPU)
--hl.env("LIBVA_DRIVER_NAME", "nvidia")
--hl.env("GBM_BACKEND", "nvidia-drm")
--hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")
hl.env("__GL_GSYNC_ALLOWED", "0")
hl.env("__GL_VRR_ALLOWED", "0")
