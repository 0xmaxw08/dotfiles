-- Curves
hl.curve("smoothDecel",  { type = "bezier", points = { {0.16, 1},    {0.3, 1}    } })
hl.curve("softEase",     { type = "bezier", points = { {0.25, 0.1},  {0.25, 1}   } })
hl.curve("linear",       { type = "bezier", points = { {0, 0},       {1, 1}      } })
hl.curve("gentleFade",   { type = "bezier", points = { {0.4, 0},     {0.2, 1}    } })
hl.curve("quick",        { type = "bezier", points = { {0.15, 0},    {0.1, 1}    } })
hl.curve("silk",         { type = "bezier", points = { {0.22, 1},    {0.36, 1}   } })

-- Springs — soft, fluid, minimal overshoot for a "liquid" feel
hl.curve("fluid", { type = "spring", mass = 1, stiffness = 150, dampening = 20 })

-- Border
hl.animation({ leaf = "border", enabled = true, speed = 5.5, bezier = "silk" })

-- Windows — soft spring open, smooth fade-out close (in/out now proportional to base)
hl.animation({ leaf = "windows",    enabled = true, speed = 2.2, spring = "fluid", style = "popin 82%" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 2.4, spring = "fluid", style = "popin 82%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.8, bezier = "smoothDecel", style = "popin 82%" })

-- Fade
hl.animation({ leaf = "fadeIn",  enabled = true, speed = 3.8, bezier = "gentleFade" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 3.2, bezier = "gentleFade" })
hl.animation({ leaf = "fade",    enabled = true, speed = 3.5, bezier = "quick" })

-- Layers (menus, popups, notifications)
hl.animation({ leaf = "layers",        enabled = true, speed = 4.2, bezier = "silk" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 3.8, bezier = "silk",   style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 2.8, bezier = "silk",   style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 3.5, bezier = "gentleFade" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 3.0, bezier = "gentleFade" })

-- Workspaces — smooth, consistent slide (in slightly faster than base, out matches base)
hl.animation({ leaf = "workspaces",    enabled = true, speed = 5.5, bezier = "silk", style = "slide" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 6.0, bezier = "silk", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 5.5, bezier = "silk", style = "slide" })

-- Zoom
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 6.0, bezier = "quick" })
