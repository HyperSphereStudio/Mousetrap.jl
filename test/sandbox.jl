module detail
        using CxxWrap
        import GTK4_jll, Glib_jll
        function try_update_gsettings_schema_dir()
            # request to use GTK4_jll-supplied settings schema if none are available on the machine
            if !Sys.islinux() && (!haskey(ENV, "GSETTINGS_SCHEMA_DIR") || isempty(ENV["GSETTINGS_SCHEMA_DIR"]))
                ENV["GSETTINGS_SCHEMA_DIR"] = normpath(joinpath(GTK4_jll.libgtk4, "../../share/glib-2.0/schemas"))
            end
        end

        function __init__()
            try_update_gsettings_schema_dir()   # executed on `using Mousetrap`, env needs to be set each time before `adw_init` is called
            @initcxx()
        end

        using libmousetrap_jll
        function get_mousetrap_julia_binding()
            return libmousetrap_jll.mousetrap_julia_binding
        end

        try_update_gsettings_schema_dir()       # executed on `precompile Mousetrap`, but not on using, silences warning during installation
        @wrapmodule(get_mousetrap_julia_binding)
    end