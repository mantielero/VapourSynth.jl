"""
Creates modules based on plugins
"""
#abstract type VSPlugin end

function gen_module( core::Ptr{VSCore}, cadena::String)
    elems = split(cadena, ";")
    plugin_ptr = getPluginById(  core, elems[2] )
    commands = []
    modname = Symbol(uppercasefirst(elems[1]))
    id = elems[2]
    fullname = elems[3]

    funcnames = []
    for func in getpluginfunctions( plugin_ptr )
        # Creating the list with the function arguments
        params = []
        if occursin(";", func)
            arguments = split(func, ";")
            for argument in arguments[2:end]
                if occursin(":", argument)
                   push!( params,  [String(i) for i in split(argument, ":")] )
                end
            end
        end

        func = create_function( plugin_ptr, String( arguments[1] ), params)
        funcname = String( lowercasefirst(arguments[1]) )
        #if funcname == "trim"
        #    println(params)
        #end
        #funcname = String( arguments[1] )
        funcnames = [funcnames; Symbol(funcname)]
        commands = [commands; func]#Expr(:(=), Symbol(funcname), func )]
    end

    funcnames = Expr(:export, funcnames...)
    mod_body = quote
        export id, fullname, __ptr__
        #import vsplugins : vsinvoke
        $funcnames

        id = $id
        fullname = $fullname
        __ptr__ = $plugin_ptr

    end

    mod_body.args = [ mod_body.args...;commands...]
    mod = Expr(:module,true,modname, mod_body)
    #tmp1.args = commands
    #println( mod )
    eval(mod)
end
