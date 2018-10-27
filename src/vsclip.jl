# ======================= NODES ========================
"""
Son nodos del grafo de filtros.

    getFrame
    getFrameAsync
    getFrameFilter
    requestFrameFilter
    getVideoInfo
    setVideoInfo

"""

@enum VSNodeFlags nfNoCache = 1 nfIsCache = 2 nfMakeLinear = 4

abstract type VSNode
end

struct VSVideoInfo
    format::VSFormat
    fpsNum::Int64
    fpsDen::Int64
    width::Int32
    height::Int32
    numFrames::Int32
    flags::Union{Int32,VSNodeFlags}

    function VSVideoInfo(videoinfoptr::Ptr{VSVideoInfo})
        # Obtenemos el puntero a VSFormat
        ptr = Ptr{Ptr{VSFormat}}(videoinfoptr)
        formatptr = unsafe_load( ptr )

        # Obtenemos el contenido de VSFormat
        format = VSFormat( formatptr )
        ptr = videoinfoptr + sizeof(Ptr{Ptr{VSFormat}})  # 8bytes es el tamaño del puntero
        fpsNum = unsafe_load(Ptr{Int64}(ptr), 1)
        fpsDen = unsafe_load(Ptr{Int64}(ptr), 2)
        ptr += sizeof(Int64)*2
        width = unsafe_load(Ptr{Int32}(ptr), 1)
        height = unsafe_load(Ptr{Int32}(ptr), 2)
        numFrames = unsafe_load(Ptr{Int32}(ptr), 3)
        flags  = unsafe_load(Ptr{Int32}(ptr), 4)
        if flags>0
            flags = VSNodeFlags(flags)
        end
        new(format, fpsNum, fpsDen, width, height, numFrames, flags)
    end
end

function Base.show(io::IO, v::VSVideoInfo)
    print("""
    Video Info:
    """)
    print("   ",v.format)
    print("""
       fpsNum/fpsDen  : $(v.fpsNum)/$(v.fpsDen)
       width x height : $(v.width) x $(v.height)
       numFrames      : $(v.numFrames)
       flags          : $(v.flags)
    """)
end

mutable struct Plane
   data::Array{UInt8}
   width::Int
   height::Int

   function Plane(frame::Ptr{VSFrameRef}, plane::Int)
      width  = getFrameWidth( frame, plane )
      height = getFrameHeight( frame, plane )
      planeptr = getReadPtr(frame, plane)  # Puntero al plano
      #println("Tamaño fila: $(size(row))")
      data = zeros(UInt8,width, height)
      #println("Tamaño: $(size(data))")
      # FORMA 1: leyendo en el orden secuencial en el que los datos están en memoria
      for h in 1:height
          for r in 1:width
             data[r,h] = unsafe_load(planeptr, r + (h-1)*width)
          end
      end
      new(data, width, height)
   end
end


mutable struct Frame
   format::VSFormat
   planes::Array{Plane}
   ptr::Ptr{VSFrameRef}

   function Frame( node::Ptr{VSNodeRef}, framenumber::Int64, errorMsg::String )
      frame = getFrame( node, framenumber, errorMsg )
      # Leemos el formato
      format = getFrameFormat( frame )
      planes = []
      for n in 0:format.numPlanes-1
          plane = Plane(frame, n)
          push!(planes, plane)
      end
      new(format, planes, frame)
   end
end

function Base.show(io::IO, f::Frame)
   println("Frame:")
   println("$(f.format)")
   for p in f.planes
      println("   Plane: $(size(p.data))")
   end
end


struct Clip
   ptr::Ptr{VSNodeRef}
   info::VSVideoInfo

   function Clip( node::Ptr{VSNodeRef} )
        videoinfo = getVideoInfo( node )
        new( node, videoinfo )
   end
end


function Base.getindex( clip::Clip, n::Int64 )
   Frame( clip.ptr, n, "Mi primer error" )
end

"""
https://github.com/vapoursynth/vapoursynth/blob/master/src/cython/vapoursynth.pyx#L1359
"""
function Base.getindex( clip::Clip, range::UnitRange{Int64} )
   Main.VapourSynth.Std.trim(clip; first=range[1], last=range[end])
end

Base.lastindex(c::Clip) = c.info.numFrames

function Base.show(io::IO, c::Clip)
   println("Clip:")
   println("   $(c.info)")
end



"""
http://www.vapoursynth.com/doc/api/vapoursynth.h.html#getvideoinfo
const VSVideoInfo *getVideoInfo(VSNodeRef *node)

Returns a pointer to the video info associated with a node. The pointer is valid as long as the node lives.

format::VSFormat
fpsNum::Int64
fpsDen::Int64
width::Int32
height::Int32
numFrames::Int32
flags::Union{Int32,VSNodeFlags}
"""
function getVideoInfo( node::Ptr{VSNodeRef} )
    videoinfoptr = ccall( vsapi.getVideoInfo, Ptr{VSVideoInfo}, (Ptr{VSNodeRef},)
                        , node )
    # Obtenemos el VSformat de la dirección obtenida
    VSVideoInfo( videoinfoptr )
    #=
    ptr = Ptr{Ptr{VSFormat}}(videoinfoptr)
    formatptr = unsafe_load( ptr ) # Obtenemos el puntero a VSFormat
    format = VSFormat( formatptr )
    ptr = videoinfoptr + sizeof(Ptr{VSFormat})
    ptr += sizeof(Int32)
    fpsNum = unsafe_load(Ptr{Int64}(ptr), 1)
    fpsDen = unsafe_load(Ptr{Int64}(ptr), 2)
    ptr += sizeof(Int64)*2
    width = unsafe_load(Ptr{Int32}(ptr), 1)
    height = unsafe_load(Ptr{Int32}(ptr), 2)
    numFrames = unsafe_load(Ptr{Int32}(ptr), 3)
    flags  = unsafe_load(Ptr{Int32}(ptr), 4)
    if flags>0
        flags = flags#VSNodeFlags(flags)
    end
    VSVideoInfo(format, fpsNum, fpsDen, width, height, numFrames, flags)
    =#
end

"""
VSNodeRef *cloneNodeRef(VSNodeRef *node)

    Duplicates a node reference. This new reference has to be deleted with freeNode() when it is no longer needed.

VSNodeRef *(VS_CC *cloneNodeRef)(VSNodeRef *node) VS_NOEXCEPT;
"""
function cloneNodeRef( node::Ptr{VSNodeRef} )
    ccall( vsapi.cloneNodeRef, Ptr{VSNodeRef}, (Ptr{VSNodeRef},)
         , node )
    #print(ptr)
    #Int64(threads)
end



"""
void freeNode(VSNodeRef *node)

    Deletes a node reference, releasing the caller’s ownership of the node.

    It is safe to pass NULL.

    Don’t try to use the node once the reference has been deleted.
"""
function freeNode(node::Ptr{VSNodeRef} )
    ccall( vsapi.cloneNodeRef, Ptr{Cvoid}, (Ptr{VSNodeRef},)
         , node )
    #print(ptr)
    #Int64(threads)
end
