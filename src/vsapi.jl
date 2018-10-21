struct VSAPI
    createCore::Ptr{Cvoid}
    freeCore::Ptr{Cvoid}
    getCoreInfo::Ptr{Cvoid}
    cloneFrameRef::Ptr{Cvoid}
    cloneNodeRef::Ptr{Cvoid}
    cloneFuncRef::Ptr{Cvoid}
    freeFrame::Ptr{Cvoid}
    freeNode::Ptr{Cvoid}
    freeFunc::Ptr{Cvoid}
    newVideoFrame::Ptr{Cvoid}
    copyFrame::Ptr{Cvoid}
    copyFrameProps::Ptr{Cvoid}
    registerFunction::Ptr{Cvoid}
    getPluginById::Ptr{Cvoid}
    getPluginByNs::Ptr{Cvoid}
    getPlugins::Ptr{Cvoid}
    getFunctions::Ptr{Cvoid}
    createFilter::Ptr{Cvoid}
    setError::Ptr{Cvoid}
    getError::Ptr{Cvoid}
    setFilterError::Ptr{Cvoid}
    invoke::Ptr{Cvoid}
    getFormatPreset::Ptr{Cvoid}
    registerFormat::Ptr{Cvoid}
    getFrame::Ptr{Cvoid}
    getFrameAsync::Ptr{Cvoid}
    getFrameFilter::Ptr{Cvoid}
    requestFrameFilter::Ptr{Cvoid}
    queryCompletedFrame::Ptr{Cvoid}
    releaseFrameEarly::Ptr{Cvoid}
    getStride::Ptr{Cvoid}
    getReadPtr::Ptr{Cvoid}
    getWritePtr::Ptr{Cvoid}
    createFunc::Ptr{Cvoid}
    callFunc::Ptr{Cvoid}
    createMap::Ptr{Cvoid}
    freeMap::Ptr{Cvoid}
    clearMap::Ptr{Cvoid}
    getVideoInfo::Ptr{Cvoid}
    setVideoInfo::Ptr{Cvoid}
    getFrameFormat::Ptr{Cvoid}
    getFrameWidth::Ptr{Cvoid}
    getFrameHeight::Ptr{Cvoid}
    getFramePropsRO::Ptr{Cvoid}
    getFramePropsRW::Ptr{Cvoid}
    propNumKeys::Ptr{Cvoid}
    propGetKey::Ptr{Cvoid}
    propNumElements::Ptr{Cvoid}
    propGetType::Ptr{Cvoid}
    propGetInt::Ptr{Cvoid}
    propGetFloat::Ptr{Cvoid}
    propGetData::Ptr{Cvoid}
    propGetDataSize::Ptr{Cvoid}
    propGetNode::Ptr{Cvoid}
    propGetFrame::Ptr{Cvoid}
    propGetFunc::Ptr{Cvoid}
    propDeleteKey::Ptr{Cvoid}
    propSetInt::Ptr{Cvoid}
    propSetFloat::Ptr{Cvoid}
    propSetData::Ptr{Cvoid}
    propSetNode::Ptr{Cvoid}
    propSetFrame::Ptr{Cvoid}
    propSetFunc::Ptr{Cvoid}
    setMaxCacheSize::Ptr{Cvoid}
    getOutputIndex::Ptr{Cvoid}
    newVideoFrame2::Ptr{Cvoid}
    setMessageHandler::Ptr{Cvoid}
    setThreadCount::Ptr{Cvoid}
    getPluginPath::Ptr{Cvoid}
    propGetIntArray::Ptr{Cvoid}
    propGetFloatArray::Ptr{Cvoid}
    propSetIntArray::Ptr{Cvoid}
    propSetFloatArray::Ptr{Cvoid}
    logMessage::Ptr{Cvoid}
end

abstract type VSCore
end

struct VSCoreInfo
    versionString::Cstring
    core::Cint
    api::Cint
    numThreads::Cint
    maxFramebufferSize::Int64
    usedFramebufferSize::Int64
end



function get_api( version::Int )
    pointer = ccall( (:getVapourSynthAPI, libpath)
                   , Ptr{VSAPI}, (Cint,)
                   , Cint( version) )
    if pointer == C_NULL # Could not allocate memory
       throw(OutOfMemoryError())
    end
    unsafe_load(pointer)
end


# ============= Functions that deal with the core: =============

"""
Creates the VapourSynth processing core and returns a pointer to it. It is legal to create multiple cores but in most cases it shouldn’t be needed.

threads
    Number of desired worker threads. If 0 or lower, a suitable value is automatically chosen, based on the number of logical CPUs.

http://www.vapoursynth.com/doc/api/vapoursynth.h.html#createcore
"""
function createCore( threads::Int )
    ptr = ccall( vsapi.createCore, Ptr{VSCore}, (Cint,)
               , Cint(threads))
    ptr
end

"""
void freeCore(VSCore *core)

    Frees a core. Should only be done after all frame requests have completed and all objects belonging to the core have been released.

http://www.vapoursynth.com/doc/api/vapoursynth.h.html#freecore
https://github.com/tgoyne/luasynth/blob/master/luasynth/vscore.lua

void (VS_CC *freeCore)(VSCore *core) VS_NOEXCEPT;

def __dealloc__(self):
    if self.funcs:
        self.funcs.freeCore(self.core)
"""
function freeCore( core::Ptr{VSCore})
    ptr = ccall( vsapi.freeCore, Ptr{Cvoid}, (Ptr{VSCore},)
         , core )
    #print(ptr)
    #unsafe_load(ptr)
end

"""
Returns information about the VapourSynth core.

VapourSynth retains ownership of the returned pointer.

    const VSCoreInfo *(VS_CC *getCoreInfo)(VSCore *core) VS_NOEXCEPT;
http://www.vapoursynth.com/doc/api/vapoursynth.h.html#getcoreinfo
"""
function getCoreInfo( core::Ptr{VSCore})
    ptr = ccall( vsapi.getCoreInfo, Ptr{VSCoreInfo}, (Ptr{VSCore},)
         , core )
    #print(ptr)
    unsafe_load(ptr)
end

#=
setMessageHandler
logMessage
setThreadCount
=#
"""
http://www.vapoursynth.com/doc/api/vapoursynth.h.html#setmaxcachesize
int64_t (VS_CC *setMaxCacheSize)(int64_t bytes, VSCore *core) VS_NOEXCEPT;


property max_cache_size:
    def __get__(self):
        cdef const VSCoreInfo *info = self.funcs.getCoreInfo(self.core)
        cdef int64_t current_size = <int64_t>info.maxFramebufferSize
        current_size = current_size + 1024 * 1024 - 1
        current_size = current_size // <int64_t>(1024 * 1024)
        return current_size

    def __set__(self, int mb):
        if mb <= 0:
            raise ValueError('Maximum cache size must be a positive number')
        cdef int64_t new_size = mb
        new_size = new_size * 1024 * 1024
        self.funcs.setMaxCacheSize(new_size, self.core)

        def set_max_cache_size(self, int mb):
            self.max_cache_size = mb
            return self.max_cache_size
"""
function setMaxCacheSize( core::Ptr{VSCore}, bytes::Int64 )
    bytes = ccall( vsapi.setMaxCacheSize, Cintmax_t, (Cintmax_t,)
         , Cintmax_t(bytes) )
    #print(ptr)
    Int64(bytes)
end

"""
int (VS_CC *setThreadCount)(int threads, VSCore *core) VS_NOEXCEPT;

property num_threads:
    def __get__(self):
        cdef const VSCoreInfo *info = self.funcs.getCoreInfo(self.core)
        return info.numThreads

    def __set__(self, int value):
        self.funcs.setThreadCount(value, self.core)

"""
function setThreadCount( core::Ptr{VSCore}, threads::Int64 )
    threads = ccall( api.setThreadCount, Cint, (Cint,)
                   , Cint(threads) )
    #print(ptr)
    Int64(threads)
end

"""
void (VS_CC *setMessageHandler)(VSMessageHandler handler, void *userData) VS_NOEXCEPT;

    void setMessageHandler(VSMessageHandler handler, void *userData)

        Installs a custom handler for the various error messages VapourSynth emits. The message handler is currently global, i.e. per process, not per VSCore instance.

        The default message handler simply sends the messages to the standard error stream.

        This function is thread-safe.

        handler

            typedef void (VS_CC *VSMessageHandler)(int msgType, const char *msg, void *userdata)

            Custom message handler. If this is NULL, the default message handler will be restored.

            msgType

                The type of message. One of VSMessageType.

                If msgType is mtFatal, VapourSynth will call abort() after the message handler returns.
            msg
                The message.

        userData
            Pointer that gets passed to the message handler.


http://www.vapoursynth.com/doc/api/vapoursynth.h.html#setmessagehandler

"""
