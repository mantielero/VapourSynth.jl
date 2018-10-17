"""
The objective is to export videos as .y4m

function VSNodeRef:writeY4MHeader(file)
  local info = self:videoInfo()
  local format = info.format
  if not format or (format.colorFamily ~= core.colorFamily.YUV and format.colorFamily ~= core.colorFamily.GRAY) then
    error('y4m only supports YUV and Gray formats')
  end




  file:write(string.format("YUV4MPEG2 C%s W%d H%d F%d:%d Ip A0:0\n",
    y4mformat, info.width, info.height, tonumber(info.fpsNum), tonumber(info.fpsDen)))
end
"""

"""
y4m stream header generator

https://docs.julialang.org/en/v1/base/io-network/#Base.IOBuffer
"""
function y4mheader( node::Ptr{VSNodeRef})
    vinfo = getVideoInfo( node)
    if !(vinfo.format.colorFamily in [cmYUV, cmGray])
       error(".y4m only supports YUV and Gray formats")
    end
    # https://github.com/vapoursynth/vapoursynth/blob/master/src/cython/vapoursynth.pyx#L1293
    format = if vinfo.format.colorFamily == cmGray
                bps = vinfo.format.bitsPerSample
                bps > 8 ? "mono$(bps)" : "mono"
             elseif vinfo.format.colorFamily == cmYUV
                # https://en.wikipedia.org/wiki/Chroma_subsampling#Types_of_sampling_and_subsampling
                # subSamplingW: 2nd and 3rd plane sampling in horizontal direction
                # subSamplingH: same for vertical direction
                ssW = vinfo.format.subSamplingW
                ssH = vinfo.format.subSamplingH
                d = Dict( (1,1) => "420", (1,0) => "422", (0,0) => "444"
                        , (2,2) => "410", (2,0) => "411", (0,1) => "440"  )
                bits = vinfo.format.bitsPerSample > 8 ? "p$(vinfo.format.bitsPerSample)" : ""
                "$(d[(ssW,ssH)])$(bits)"
             end

    #TODO: I: sólo considera vídeo progresivo (p)
    #TODO: A: pixel aspect ratio desconocido (0:0)
    "YUV4MPEG2 C$(format) W$(vinfo.width) H$(vinfo.height) F$(vinfo.fpsNum):$(vinfo.fpsDen) Ip A0:0\n"
end


function y4mframe( frame::Frame)
    tmp = b"FRAME\n"
    #frame
    #frameformat
    for plane in frame.planes
        #plane = Array{UInt8,1}(plane)
        for h in 1:plane.height
            tmp = [ tmp;  plane.data[:,h]]
        end
    end
    tmp
end
"""
local function writeFrame(file, frame, y4m)
  if y4m then
    file:write("FRAME\n")
  end

  local format = frame:format()
  for plane = 1, format.numPlanes do
    local pitch = frame:stride(plane)
    local readPtr = frame:readPtr(plane)
    local rowSize = frame:width(plane) * format.bytesPerSample
    local height = frame:height(plane)

    for y = 1, frame:height(plane) do
      ffi.C.fwrite(readPtr, 1, rowSize, file)
      readPtr = readPtr + pitch
    end
  end

  vs.freeFrame(frame)
end
"""

function savey4m(clip::Clip, name::String)
    io = Base.open(name,"w")
    header = y4mheader( clip.ptr )
    write(io, header  )
    for i in 1:clip.info.numFrames
        frame = clip[i]
        framebin = y4mframe( frame )
        freeFrame( frame.ptr )
        write(io,  framebin)
    end
    Base.close(io)
end

function pipey4m( clip::Clip )
    #io = Base.open(name,"w")
    header = y4mheader( clip.ptr )
    write(stdout, header  )
    for i in 1:clip.info.numFrames
        frame = clip[i]
        framebin = y4mframe( frame )
        freeFrame( frame.ptr )
        write(stdout,  framebin)
    end
end
