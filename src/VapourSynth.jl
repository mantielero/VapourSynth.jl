module VapourSynth
__precompile__(false)

export savey4m, pipey4m

const libpath = "/usr/lib/libvapoursynth.so"
#const libpath = "./vs/VapourSynth.dll"
const VAPOURSYNTH_API_MAJOR = 3
const VAPOURSYNTH_API_MINOR = 5



include("./vsapi.jl")
include("./vsframe.jl")
include("./vsclip.jl")
include("./vsmap.jl")
include("./vsplugins.jl")
include("./vsmodules.jl")
include("./output.jl")

#function __init__()
const vsapi = get_api(3)
const coreptr = createCore( 0 ) # Puntero al core, que no es multihilo por defecto
#   return (vsapi,coreptr)
#end


# Skipping MacroDefinition: VAPOURSYNTH_API_VERSION ( ( VAPOURSYNTH_API_MAJOR << 16 ) | ( VAPOURSYNTH_API_MINOR ) )
# Skipping MacroDefinition: VS_EXTERNAL_API ( ret ) VS_EXTERN_C __attribute__ ( ( visibility ( "default" ) ) ) ret VS_CC
# Skipping MacroDefinition: VS_API ( ret ) VS_EXTERNAL_API ( ret )

#=
const VSGetVapourSynthAPI = Ptr{Cvoid}
const VSPublicFunction = Ptr{Cvoid}
const VSRegisterFunction = Ptr{Cvoid}
const VSConfigPlugin = Ptr{Cvoid}
const VSInitPlugin = Ptr{Cvoid}
const VSFreeFuncData = Ptr{Cvoid}
const VSFilterInit = Ptr{Cvoid}
const VSFilterGetFrame = Ptr{Cvoid}
const VSFilterFree = Ptr{Cvoid}
const VSFrameDoneCallback = Ptr{Cvoid}
const VSMessageHandler = Ptr{Cvoid}
=#

@enum VSMessageType mtDebug = 0 mtWarning = 1 mtCritical = 2 mtFatal = 3

@enum VSActivationReason arInitial = 0 arFrameReady = 1 arAllFramesReady = 2 arError = -1

@enum VSFilterMode fmParallel = 100 fmParallelRequests = 200 fmUnordered = 300 fmSerial = 400

@enum VSPresetFormat begin
   pfNone = 0
   pfGray8 = 1000010
   pfGray16 = 1000011
   pfGrayH = 1000012
   pfGrayS = 1000013
   pfYUV420P8 = 3000010
   pfYUV422P8 = 3000011
   pfYUV444P8 = 3000012
   pfYUV410P8 = 3000013
   pfYUV411P8 = 3000014
   pfYUV440P8 = 3000015
   pfYUV420P9 = 3000016
   pfYUV422P9 = 3000017
   pfYUV444P9 = 3000018
   pfYUV420P10 = 3000019
   pfYUV422P10 = 3000020
   pfYUV444P10 = 3000021
   pfYUV420P16 = 3000022
   pfYUV422P16 = 3000023
   pfYUV444P16 = 3000024
   pfYUV444PH = 3000025
   pfYUV444PS = 3000026
   pfYUV420P12 = 3000027
   pfYUV422P12 = 3000028
   pfYUV444P12 = 3000029
   pfYUV420P14 = 3000030
   pfYUV422P14 = 3000031
   pfYUV444P14 = 3000032
   pfRGB24 = 2000010
   pfRGB27 = 2000011
   pfRGB30 = 2000012
   pfRGB48 = 2000013
   pfRGBH = 2000014
   pfRGBS = 2000015
   pfCompatBGR32 = 9000010
   pfCompatYUY2 = 9000011
end

abstract type Ref
end

abstract type VSFrameContext
end

coreinfo = getCoreInfo( coreptr )

#---------- Llamamos a un filtro
# Para construir el VSMap de los argumentos, tenemos que poder construir un VSMap
#arguments = propSetData( core_p::Ptr{VSCore}, key::AbstractString, size::Int64, append::VSPropAppendMode )
#arguments = propSetData( vsmap, key, data, size, paAppend )
#ffms2plugin = Nothing
genmodules( coreptr )
#using .Ffms2
println("OK")
#=
for plugin in getplugins( coreptr )
   #println("Plugin ID: ",plugin.id)


   #if plugin.id == "com.vapoursynth.text"

   #end
   if plugin.id == "com.vapoursynth.ffms2"
      #println("Mostramos las funciones:")
      #println( plugin.functions )
      #=
      println(names(Ffms2))
      println(Ffms2.id)
      println(Ffms2.fullname)
      println(Ffms2.__ptr__)
      =#
      #println(Ffms2.getLogLevel)
      loglevel = Ffms2.getLogLevel()
      #println( loglevel )

      #loglevel = plugin.functions.GetLogLevel()
      #lista = vsmap2list(loglevel)
      #println( "LogLevel: $(lista)")
      #newmap = plugin.functions.GetLogLevel()
      #println("RESULTADO: $(vsmap2list( newmap ))")

      #println("Ahora set function:")

      #println("$(methods(plugin.functions.SetLogLevel))")
      #println("======EJECUTANDO SETLOGLEVEL(1)")
      Ffms2.setLogLevel(1)
      #plugin.functions.SetLogLevel( 1 )
      #println("======DONE")
      loglevel = plugin.functions.GetLogLevel()
      #lista = vsmap2list(loglevel)
      #println( "LogLevel: $(lista)")

      #println(methods(Ffms2.source))
      #clip = Ffms2.source( "/home/jose/src/julia/vapoursynth/videos/test.mkv" )


      #println(typeof(newmap))
      #nodes = vsmap2list( newmap )
      #println("NODES: ", nodes[1][2])
      #clip = Clip(nodes[1][2])
      #println(clip)
      #frame = clip[1]
      #println(frame.planes)


        #=
        ffms2plugin = plugin
        #print(ffms2plugin)
        vsmap = createMap()
        newmap = invoke( ffms2plugin.ptr, "Version", vsmap)
        #println( getmapitems( newmap) )





        #println("===== VIDEO INFO =====")
        #print("$(videoinfo)\n")

        #frame = unsafe_load(frame)
        #@info "Frame: $(frame)"
        #println("$(frame.ptr)")
        #rowbytes = formato.bytesPerSample * width
        pitch = getStride(frame.ptr, 0)   # NO FUNCIONA CORRECTAMENTE
        #@info "Pitch: $(pitch)"
        #println("row size: $(rowbytes)bytes")

        #row = zeros(UInt8,width)#Array{UInt8, width}
        #row = unsafe_wrap(Array, planeptr, width) #rowbytes)
        #print(row)
        #println("Tamaño fila: $(size(row))")


        # FORMA 2
        #=rows = row
        for h in 2:height
            #unsafe_wrap(row, planeptr, width)
            planeptr += rowbytes
            row = unsafe_wrap(Array, planeptr, width)
            rows = hcat( rows, row )

        end

        # FORMA 3

        print(size(rows))
	       =#
        #print("Tamaño: $(size(data))\n")

        # https://medium.com/@manvithaponnapati/part-1-julia-images-moving-from-python-to-julia-image-i-o-basic-manipulations-eecae73fe04d
        # https://github.com/JuliaImages/Images.jl/blob/master/docs/src/index.md
        #using Images, Colors, FixedPointNumbers, FileIO  #, ImageView
        #img = colorview( Gray, data./255)
        #save("prueba.png", img)
        include("./output.jl")
        =#

        # Escribir fichero de video
        #savey4m( clip, "borrame.y4m")
        #pipey4m( clip )

        #=
        freeNode( clip.ptr )
        =#
    end
end

freeCore(  coreptr )
=#
#
end
