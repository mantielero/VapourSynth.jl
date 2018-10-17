abstract type VSNodeRef
end

abstract type VSFrameRef
end
@enum VSColorFamily cmGray = 1000000 cmRGB = 2000000 cmYUV = 3000000 cmYCoCg = 4000000 cmCompat = 9000000
@enum VSSampleType stInteger = 0 stFloat = 1

struct VSFormat
    name::String
    id::Int
    colorFamily::VSColorFamily
    sampleType::VSSampleType
    bitsPerSample::Int
    bytesPerSample::Int
    subSamplingW::Int
    subSamplingH::Int
    numPlanes::Int

    function VSFormat(ptr::Ptr{VSFormat})
        name = unsafe_string(Ptr{UInt8}(ptr), 32)
        ptr += 32
        id = unsafe_load( Ptr{Int32}(ptr) )
        colorFamily = VSColorFamily(unsafe_load(Ptr{Int32}(ptr),2))
        sampleType = VSSampleType(unsafe_load(Ptr{Int32}(ptr),3))
        bitsPerSample = unsafe_load(Ptr{Int32}(ptr),4)
        bytesPerSample = unsafe_load(Ptr{Int32}(ptr),5)
        subSamplingW = unsafe_load(Ptr{Int32}(ptr),6)
        subSamplingH = unsafe_load(Ptr{Int32}(ptr),7)
        numPlanes = unsafe_load(Ptr{Int32}(ptr),8)
        new(name, id, colorFamily, sampleType, bitsPerSample, bytesPerSample,subSamplingW,subSamplingH, numPlanes)
    end
end

function Base.show(io::IO, f::VSFormat)
    print("""
    Frame Format:
       name              : $(f.name)
       id                : $(f.id)
       colorFamily       : $(f.colorFamily)
       sampleType        : $(f.sampleType)
       bits per sample   : $(f.bitsPerSample)
       bytes per sample  : $(f.bytesPerSample)
       subSampling (W,H) : ($(f.subSamplingW),$(f.subSamplingH))
       num. planes       : $(f.numPlanes)
    """)
end


"""

http://www.vapoursynth.com/doc/api/vapoursynth.h.html#getframe

    const VSFrameRef *getFrame(int n, VSNodeRef *node, char *errorMsg, int bufSize)

        Generates a frame directly. The frame is available when the function returns.

        This function is meant for external applications using the core as a library, or if frame requests are necessary during a filter’s initialization.

        Thread-safe.

        n
            The frame number. Negative values will cause an error.
        node
            The node from which the frame is requested.
        errorMsg
            Pointer to a buffer of bufSize bytes to store a possible error message. Can be NULL if no error message is wanted.
        bufSize
            Maximum length for the error message, in bytes (including the trailing ‘0’). Can be 0 if no error message is wanted.

        Returns a reference to the generated frame, or NULL in case of failure. The ownership of the frame is transferred to the caller.

        Warning

        Never use inside a filter’s “getframe” function.

"""
#Cstring if NUL-terminated, or Ptr{UInt8} if not
function getFrame( node::Ptr{VSNodeRef}, framenumber::Int64, errorMsg::String )
    ccall( vsapi.getFrame, Ptr{VSFrameRef}, (Cint, Ptr{VSNodeRef}, Cstring, Cint,)  # const VSFrameRef *(VS_CC *getFrame)(int n, VSNodeRef *node, char *errorMsg, int bufSize) VS_NOEXCEPT; /* do never use inside a filter's getframe function, for external applications using the core as a library or for requesting frames in a filter constructor */
         , framenumber, node, errorMsg, 0)#length(errorMsg) )
    #print(ptr)
    #Int64(threads)
end

"""
http://www.vapoursynth.com/doc/api/vapoursynth.h.html#freeframe
void freeFrame(const VSFrameRef *f)

Deletes a frame reference, releasing the caller’s ownership of the frame.

It is safe to pass NULL.

Don’t try to use the frame once the reference has been deleted.
"""
function freeFrame( frame::Ptr{VSFrameRef})
    ccall( vsapi.freeFrame, Ptr{Cvoid}, (Ptr{VSFrameRef},)   # const VSFrameRef *(VS_CC *getFrame)(int n, VSNodeRef *node, char *errorMsg, int bufSize) VS_NOEXCEPT; /* do never use inside a filter's getframe function, for external applications using the core as a library or for requesting frames in a filter constructor */
         , frame )#length(errorMsg) )
end

#--------------------------------------
# FRAME
#--------------------------------------
"""
    const VSFormat *getFrameFormat(const VSFrameRef *f)

        Retrieves the format of a frame.

        name::NTuple{32, UInt8}  # NTuple{32, UInt8}    #Array{UInt8,32}
        id::Cint
        colorFamily::VSColorFamily
        sampleType::VSSampleType
        bitsPerSample::Cint
        bytesPerSample::Cint
        subSamplingW::Cint
        subSamplingH::Cint
        numPlanes::Cint
"""
function getFrameFormat( frameref::Ptr{VSFrameRef} )
    formatptr = ccall( vsapi.getFrameFormat, Ptr{VSFormat}, (Ptr{VSFrameRef}, )
                     , frameref )
    VSFormat(formatptr)
end

"""
    int getFrameWidth(const VSFrameRef *f, int plane)

        Returns the width of a plane of a given frame, in pixels. The width depends on the plane number because of the possible chroma subsampling.
"""
function getFrameWidth( frameref::Ptr{VSFrameRef}, plane::Int64 )
    value = ccall( vsapi.getFrameWidth, Cint, (Ptr{VSFrameRef}, Cint )
                 , frameref, plane )
    Int64(value)
end

"""
    int getFrameHeight(const VSFrameRef *f, int plane)

        Returns the height of a plane of a given frame, in pixels. The height depends on the plane number because of the possible chroma subsampling.

"""
function getFrameHeight( frameref::Ptr{VSFrameRef}, plane::Int64 )
    value = ccall( vsapi.getFrameHeight, Cint, (Ptr{VSFrameRef}, Cint )
                 , frameref, plane )
    Int64(value)
end

"""


    const uint8_t *getReadPtr(const VSFrameRef *f, int plane)

        Returns a read-only pointer to a plane of a frame.

        Passing an invalid plane number will cause a fatal error.

        Note

        Don’t assume all three planes of a frame are allocated in one contiguous chunk (they’re not).


"""
function getReadPtr( frameref::Ptr{VSFrameRef}, plane::Int64 )
    ccall( vsapi.getReadPtr, Ptr{UInt8}, (Ptr{VSFrameRef}, Cint )
                 , frameref, plane )
    #Int64(value)
end

"""
http://www.vapoursynth.com/doc/api/vapoursynth.h.html#getstride


    int getStride(const VSFrameRef *f, int plane)

        Returns the distance in bytes between two consecutive lines of a plane of a frame. The stride is always positive.

        Passing an invalid plane number will cause a fatal error.


"""
# NOK
function getStride( frameref::Ptr{VSFrameRef}, plane::Int )
    ccall( vsapi.getReadPtr, Int32, (Ptr{VSFrameRef}, Int32)
         , frameref, plane )
end
