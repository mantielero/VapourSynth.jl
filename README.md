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

Then it can done:
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

## Tasks
Some tasks to do:

- TODO: to document exported functions by means of `@doc """Help""" Ffms2.source`
- TODO: to enable array idiomatic. Something like: `clip[1:50]`:
```julia
julia> clip2=clip[2:10]
ERROR: MethodError: no method matching getindex(::VapourSynth.Clip, ::UnitRange{Int64})
```

## Links
Python scripting:

- [Basic scripting](http://www.l33tmeatwad.com/vapoursynth101/script-basics)
- [Importing videos](http://www.l33tmeatwad.com/vapoursynth101/importing-videos)
- [Using filters](http://www.l33tmeatwad.com/vapoursynth101/using-filters-functions)

AVS scripting:

- [wiki](http://avisynth.nl/index.php/Script_examples)
