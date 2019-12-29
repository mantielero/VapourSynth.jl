# VapourSynth.jl

## Why
First, this is just an experiment. Julia could be a good fit in the sense that it is good for scripting, but maybe it could be used for where normally C/C++ is used in VapourSynth. So there are two objectives:
- [X] To wrap the library to enable scripting
- [ ] To create a filter in Julia and to see how it performs.

## Scripting
### Modules vs Plugins
For each loaded plugin, a Julia module is created automatically.

To make it look more like Julia:
- the module name gets its first letter capitalized (so plugin *ffms2* becomes module *Ffms2*).
- function names get their first letter lowercased (so function *Turn180* becomes *turn180*).

In order to inspect what has been exported by a module it can be done by:
```julia
julia> using VapourSynth
julia> names(VapourSynth.Ffms2)
9-element Array{Symbol,1}:
 :Ffms2      
 :__ptr__    
 :fullname   
 :getLogLevel
 :id         
 :index      
 :setLogLevel
 :source     
 :version  
julia> VapourSynth.Ffms2.fullname
"FFmpegSource 2 for VapourSynth"
```

We can inspect also the methods of a function:
```julia
julia> methods( VapourSynth.Ffms2.source )
```

### Piping (function chaining)
Functions can be chained. It is recommended to use the package [Lazy.jl](https://github.com/MikeInnes/Lazy.jl). For instance, in order to read a file and pipe it as a .y4m file:
```julia
using VapourSynth
using Lazy
@> VapourSynth.Ffms2.source( "test.mkv" ) pipey4m
```

This way, the following works:
```
$ julia file.jl | mplayer -
```

We can pass parameters also:
```julia
using VapourSynth
using Lazy
@> VapourSynth.Ffms2.source( "test.mkv" ) savey4m("newfile.y4m")
```

## REPL
In order to test in the REPL:
```julia
julia> ]
(v1.0) pkg> activate .
(VapourSynth) pkg>
```
and press *backspace* key.

In order of reading and exporting the file as an *.y4m file*:
```julia
julia> using VapourSynth
julia> using Lazy
julia> @> VapourSynth.Ffms2.source( "test.mkv" ) savey4m("/tmp/newvideo.y4m")
```

To avoid using long namespaces, we can bring functions into scope as in the following example:
```julia
julia> using VapourSynth
julia> using VapourSynth.Ffms2
julia> using VapourSynth.Std: turn180, flipHorizontal
julia> using Lazy
julia> @> source( "test.mkv" ) turn180 flipHorizontal savey4m("/tmp/newvideo.y4m")
```

## Clip slicing
It can be done:
```julia
julia> using VapourSynth
julia> using VapourSynth.Ffms2
julia> clip = source( "test.mkv" )
Clip:
Video Info:
   Frame Format:
   name              : YUV420P8
   id                : 3000010
   colorFamily       : cmYUV
   sampleType        : stInteger
   bits per sample   : 8
   bytes per sample  : 1
   subSampling (W,H) : (1,1)
   num. planes       : 3
   fpsNum/fpsDen  : 30/1
   width x height : 1280 x 768
   numFrames      : 976
   flags          : nfMakeLinear

julia> newclip = clip[101:150]
Clip:
Video Info:
   Frame Format:
   name              : YUV420P8
   id                : 3000010
   colorFamily       : cmYUV
   sampleType        : stInteger
   bits per sample   : 8
   bytes per sample  : 1
   subSampling (W,H) : (1,1)
   num. planes       : 3
   fpsNum/fpsDen  : 30/1
   width x height : 1280 x 768
   numFrames      : 50
   flags          : nfNoCache

```
The first and last frame are inclusive.

So the following is possible:
- The whole clip: `clip[1:end]`
- Reversed: `clip[end:-1:1]`
- Odd: `clip[1:2:end]`
- Even: `clip[2:2:end]`

Is it possible to add clips also just by doing:
```julia
clip1+clip2
```

## Tasks
Some tasks to do:

- TODO: to document exported functions by means of `@doc """Help""" Ffms2.source`

## Links
Python scripting:

- [Basic scripting](http://www.l33tmeatwad.com/vapoursynth101/script-basics)
- [Importing videos](http://www.l33tmeatwad.com/vapoursynth101/importing-videos)
- [Using filters](http://www.l33tmeatwad.com/vapoursynth101/using-filters-functions)

AVS scripting:

- [wiki](http://avisynth.nl/index.php/Script_examples)
