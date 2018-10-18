# VapourSynth.jl

## Modules vs Plugins
For each plugin, a Julia module is created automatically. The module name gets first letter capitalized. So plugin *ffms2* becomes module *Ffms2*. Function names get first letter lowercase. I think this brings VapourSynth a bit closer to Julia idiomatic.

In order to inspect what has been exported by a module it can be done by:
```julia
println( names(Ffms2) )
```

### Piping (function chaining)
Functions can be chained. It is recommended using the package [Lazy.jl](https://github.com/MikeInnes/Lazy.jl). For instance, in order to read a file and piping it as a .y4m file:
```julia
using Lazy
@> Ffms2.source( "test.mkv" ) |> pipey4m
```

Then we can do:
```
$ julia file.jl | mplayer -
```

We can pass parameters also:
```julia
using Lazy
@> Ffms2.source( "test.mkv" ) |> savey4m("deleteme.y4m")
```

## Tasks
Some tasks to do:

- TODO: to enable Julia idiomatic by means of `|>`. Function chaining. [see this](https://discourse.julialang.org/t/piping-in-julia/14735) and [this](https://github.com/JuliaLang/julia/issues/5571).
- TODO: to document exported functions by means of `@doc """Help""" Ffms2.source`
- TODO: to enable array idiomatic. Something like: `clip[1,50]`.

## Links
Python scripting:

- [Basic scripting](http://www.l33tmeatwad.com/vapoursynth101/script-basics)
- [Importing videos](http://www.l33tmeatwad.com/vapoursynth101/importing-videos)
- [Using filters](http://www.l33tmeatwad.com/vapoursynth101/using-filters-functions)

AVS scripting:

- [wiki](http://avisynth.nl/index.php/Script_examples)
