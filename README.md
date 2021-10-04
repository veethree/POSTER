# POSTER
POSTER is a post processing library for Löve. It comes with a suit of built in post processing shaders you can apply to your game with ease.

## Basic usage
The first step (*once you've downloaded it and placed it somewhere in your games directory*) is to load it.
```lua
poster = require("poster")
```
Next you need to create a "poster canvas" like so:
```lua
canvas = poster.new()
```
A "poster canvas" acts like a regular canvas.

You can draw to it:
```lua
canvas:drawTo(function()
  love.graphics.circle("fill", 100, 100, 64)
end)
```
Or if you prefer:
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


Once youre finished drawing to the canvas, You can draw the "poster object" to the screen like so:
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

## Chains
POSTER has a built in chain system that helps you set up chains of effects. To create a new chain you use:
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
Then you can apply the chains by using them as arguments in the draw function
```lua
canvas:draw(lofi)
```
Note that you can only apply one chain at a time. 

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








