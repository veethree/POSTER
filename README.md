# POSTER
POSTER is a post processing library for Löve. It comes with a suit of built in post processing shaders you can apply to your game with ease.

## Basic usage
The first step (*once you've downloaded it and placed it somewhere in your games directory*) is to load it.
```lua
poster = require("poster")
```
Next you need to create a canvas like so:
```lua
canvas = poster.new()
```
A poster canvas acts like a regular canvas.

You can draw to it:
```lua
canvas:drawTo(function()
  love.graphics.circle("fill", 100, 100, 64)
end)
```
Or if you prefer there's also a set/unset block.
```lua
canvas:set()
--draw stuff
canvas:unset()
```
If you want to draw to another canvas within the `drawTo` function or the `set`/`unset` block, Make sure to either capture the previous canvas with `love.graphics.getCanvas` and reset it, Or set the canvas to `canvas.main` once you're done

```lua
canvas:drawTo(function() 
-- draw stuff
local previousCanvas = love.graphics.getCanvas()
love.graphics.setCanvas(yourCanvas)
-- draw stuff to your canvas
love.graphics.setCanvas(previousCanvas)
-- OR
love.graphics.setCanvas(canvas.main)
-- draw more stuff
end)
```


Once youre finished drawing to the canvas, You can draw it to the screen like so:
```lua
canvas:draw()
```
Now comes the fun part, The draw function can take any number of shaders as arguments, The built in shaders are invoked as strings:
```lua
canvas:draw("brightness", "contrast", "saturation", "chromaticAberrationAngle")
```
And you can throw your own shaders into the mix if you want:
```lua
canvas:draw(yourShader, "contrast", yourOtherShader, "verticalBlur")
```
Alternatively you can place your shaders in POSTER's shaders folder and as long as they have the extension `.frag`, They will be loaded with the built in ones.

The shaders will be applied in the order of the arguments.

To control the shaders you need to send them the appropriate uniform data with:
```lua
poster:send(shader, uniform, data)
```
`poster:send()` can alternatively take a table with the following format as an argument to send data to multiple shaders:
```lua
shaderData = {
  {shader, uniform, data},
  {shader, uniform, data},
  {shader, uniform, data},
  ...
}
```
The uniform data each shader requires is explained below.

## Chains
POSTER has a built in chain system that helps you set up chains of shaders. To create a new chain you use:
### `poster.newChain(shaders, settings)`
Shaders is a table of shaders in the chain, Can be any combination of strings and/or your own shaders, Just like in `poster:draw()`. Settings is a table of uniforms for those shaders in the same format as `poster:send()`

Here's an example:
```lua
lofi = poster.newChain(
  {"pixelate", "chromaticAberrationRadius", "posterize", "scanlines"}, 
  {
    {"pixelate", "resolution", {lg.getWidth() / 2, lg.getHeight() / 2}},
    {"chromaticAberrationRadius", "radius", 10},
    {"chromaticAberrationRadius", "position", {lg.getWidth() / 2, lg.getHeight() / 2}},
    {"posterize", "colors", 16},
    {"scanlines", "opacity", 0.9},
    {"scanlines", "scale", 0.9},
  })
```

Alternatively, There's also `chain:addEffect()` & `chain:addSetting()` which you can use like this:
```lua
blur = poster.newChain()
blur:addEffect("horizontalBlur", "verticalBlur")
blur:addSetting("horizontalBlur", "amount", 2)
blur:addSetting("verticalBlur", "amount", 2)
```

Chains can also have Macros. Macros let you control multiple settings with a single value. 
To define a new macro you use:
```lua
chain:newMacro(macroName, targets)
```
`macroName` should be a string that will be used to refer to this macro.
`targets` should be a table with the following format
```lua
{
  {shader, uniform, multiplier},
  {shader, uniform, multiplier},
  ...
}
```
`Shader` & `uniform` are the shader & uniform the macro should affect, And `multiplier` lets you scale the macro value for different shaders in your chain.

Then you can apply the chains by using them as arguments in the draw function
```lua
canvas:draw(lofi)
```
You can apply multiple chains in the draw function.
 ```lua
 canvas:draw(lofi, anotherChain, etCetera)
 ```
 
However, You can **not** mix shaders and chains together.
```lua
canvas:draw(lofi, "contrast") -- This would throw an error.
```

## Standard shaders:

NOTE: Any shaders that take the uniform 'imageSize' are automatically sent a default when POSTER is loaded. The default is the window resolution. You can easily update this for all shaders that require it with `poster:sendImageSize(width, height)`


### Color correction shaders

### `brightness`
Uniforms:
* amount: Number. 1 is normal,  < 1 is darker, > 1 is brighter.

Sets the brightness.

### `contrast`
Uniforms:
* amount: Number. 1 is  normal, < 1 is less contrast, > 1 is more contrast.

Sets the contrast.

### `saturation`
Uniforms:
* amount: Number. 1 is  normal, < 1 is less saturation, > 1 is more saturation. 0 is black & white

Sets the saturation.

## `rgbMix`
Uniforms:
* rgb: vec3. {r, g, b}. 

The red, green and blue values of the image will be multiplied by this vector. So {1, 0, 0} will result in everything being red, {0.8, 1, 1.2} will result in a slightly cooler image etc.

## Blur
### `horizontalBlur` & `verticalBlur`
Uniforms:
* amount: The strength of the blur. 

A horizontal & vertical gaussian blur, It's pretty low resolution, So values above about 3 get a bit weird.

## Chromatic aberration
These are those neat RGB split effects. The red and blue channels are offset.
### `chromaticAberrationAngle`
Uniforms:
* angle: Number. Angle at which to offset the channels in radians.
* offset Number. How much to offset the channels by.

### `chromaticAberrationRadius`
Uniforms:
* position: vec2. {x, y}. The "origin" of the aberration, The farther away from this point a pixel is, The more the channels are offset.
* offset Number. How much to offset the channels by.

Offsets the channels based on a distance from a certain point.

## Other
### `pixelate`
uniforms:
* resolution vec2. {width, height}: Acts like a "render resolution". Should be something smaller than the actual resoltion of your game.

Pixelates the screen. The smaller the resolution, the more pixely it gets.

### `posterize`
uniforms:
* colors: Number: How many colors to use

Limits the number of colors

### `vignette`
uniforms:
* radius: number: How large the vignette is. 0-1.
* opacity: Number. How opaque the vignette is. 0-1.
* softness: Number: How soft the vignette is. 0-1.
* color: vec3. {r, g, b}. Color of the vignette

Adds a vignette.


# Demo
The demo is just snake. But with shaders.
Here's without shaders
![noshaders](https://github.com/veethree/POSTER/blob/main/SnakeDemoNoShaders.gif)

And here's the same with shaders
![shaders](https://github.com/veethree/POSTER/blob/main/SnakeDemoShaders.gif)

I think we can all agree shaders make it far better.


