# POSTER
POSTER is a post processing library for Löve. It comes with a suit of built in post processing shaders you can apply to your game with ease.

## Basic usage
The first step (*once you've downloaded it and placed it somewhere in your games directory*) is to load it.
```lua
poster = require("poster")
```
Next you need to create a "poster object" like so:
```lua
canvas = poster.new()
```
A "poster object" acts like a canvas.

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

## Standard shaders:

NOTE: Any shaders that take the uniform 'imageSize' are automatically sent a default when POSTER is loaded. The default is the window resolution. You can easily update this for all shaders that require it with `poster:sendImageSize(width, height)`

### Utility shaders
### `bandpass`
Uniforms:
* cutoff: Number in the range 0-1
* bandwidth: Number in the range 0-1

Any pixels brighter than the value of `cutoff` and dimmer than `cutoff + bandwidth` are rendered normally, Others are not.

### `lowpass`
Uniforms:
* cutoff: Number in the range 0-1

Any pixels dimmer than `cutoff` are rendered normally, Others are not

### `highpass`
Uniforms:
* cutoff: Number in the range 0-1

Any pixels brighter than `cutoff` are rendered normally, Others are not

### `convolution`
Uniforms:
* imageSize: vec2 representing the image size.
* kernelSize: vec2 representing the kernel size.
* kernel: 1-dimensional array representing the kernel.

Performs a [convolution](https://en.wikipedia.org/wiki/Kernel_(image_processing)#Convolution) on your image. Can take a kernel of any size, But by default limited to 25 values.

### `convolution3x3`
Uniforms:
* imageSize: vec2 representing the image size.
* kernel: 1-dimensional array representing the kernel. Should contain 9 numbers.

Same as `convolution`, But only works for 3x3 kernels. Should be a bit faster than `convolution` because it doesn't use any loops.

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








