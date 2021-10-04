-- POSTER: A library for applying post processing affects via shaders to your löve game.
-- Made for löve (https://love2d.org/)
-- Version 1.0

-- MIT License
-- 
-- Copyright (c) 2021 Pawel Þorkelsson
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local print_status = true


-- Creates a local version of the print function so i can easily toggle debug printing.
local _print = print
local function print(...)
    if print_status then
        _print(...)
    end
end

-- Shorthands
local lg = love.graphics
local fs = love.filesystem
local f = string.format
local insert = table.insert

-- Paths
local poster_path = (...):gsub("%.", "/") -- gsub replaces the . with /
local shader_path = f("%s/%s", poster_path, "shaders")

-- Initializing module
local poster = {
    shaders = {},
    -- Keeping track of shaders that use 'imageSize' so it can be easily updated
    shaders_with_imageSize = {"chromaticAberrationAngle", "chromaticAberrationRadius",
    "horizontalBlur", "verticalBlur", "waveDistortion", "scanlines"},
}
local poster_meta = {__index = poster}

-- Loading built in shaders
print("Loading shaders...")
local shader_directory = fs.getDirectoryItems(shader_path)
for _, shader in ipairs(shader_directory) do
    local name, extension = shader:match("(%w+).(%w+)")
    if extension == "frag" then
        poster.shaders[name] = lg.newShader(f("%s/%s", shader_path, shader))
    end
end
print("Shaders loaded.")

-- Sending a default imageSize to shaders that use it.
local imageSize = {lg.getWidth(), lg.getHeight()}
for _,shader in pairs(poster.shaders_with_imageSize) do
    print(shader)
    poster.shaders[shader]:send("imageSize", imageSize)
end

-- CHAIN
function poster.newChain(effects, settings)
    return setmetatable({
        type = "chain",
        effects = effects or {},
        settings = settings or {}
    }, poster_meta)
end

function poster:addEffect(...)
    assert(self.type == "chain", "addEffect() can only be used on chain objects")
    for i,v in ipairs({...}) do
        local shader = v
        print(type(shader))

        if type(v) == "string" then
            assert(self.shaders[shader], f("Shader '%s' does not exist.", shader))
        else
            if type(shader) == "userdata" then
                assert(shader:type() == "Shader", f("'%s' is not a shader", shader))
            end
        end

        insert(self.effects, shader)
    end
end

function poster:addSetting(...)
    assert(self.type == "chain", "addSetting() can only be used on chain objects")
    insert(self.settings, {...})
end

-- Creates and returns a new poster object.
function poster.new(w, h)
    w = w or lg.getWidth()
    h = h or lg.getHeight()

    local po = setmetatable({
        type = "canvas",
        main = lg.newCanvas(w, h),
        a = lg.newCanvas(w, h),
        b = lg.newCanvas(w, h),
        previous_canvas = false -- Used to store a previous canvas for poster:set()

    }, poster_meta)

    return po
end

-- Sends uniform data to shaders.
-- Can either take (shader, uniform, data) or a table with the following format:
-- {{shader, uniform, data }, {shader, uniform, data} ...}
function poster:send(shader, uniform, data)
    if type(shader) == "string" then
        assert(self.shaders[shader], f("Shader '%s' does not exists!", shader))
        self.shaders[shader]:send(uniform, data)
    elseif type(shader) == "table" then
        for i,v in ipairs(shader) do
            self.shaders[v[1]]:send(v[2], v[3])
        end
    end
end

-- Sending "imageSize" to shaders that require it
-- width & height default to the window size
function poster:sendImageSize(width, height)
    local imageSize = {width or lg.getWidth(), height or lg.getHeight()}
    for _,shader in pairs(self.shaders_with_imageSize) do
        poster.shaders[shader]:send("imageSize", imageSize)
    end
end

-- Sets a wrap mode for the poster object
function poster:setWrap(wrap)
    self.main:setWrap(wrap)
    self.a:setWrap(wrap)
    self.b:setWrap(wrap)
end

-- Draws to the poster object
function poster:drawTo(func)
    func = func or function() lg.clear() end
    local previous_canvas = lg.getCanvas()
    lg.setCanvas(self.main)
    func()
    lg.setCanvas(previous_canvas)
end

-- Clears the poster object
function poster:clear()
    local previous_canvas = lg.getCanvas()
    lg.setCanvas(self.main)
    lg.clear()
    lg.setCanvas(previous_canvas)
end

-- set unset block
function poster:set()
    poster.previous_canvas = lg.getCanvas()
    lg.setCanvas(self.main)
end

function poster:unset()
    lg.setCanvas(poster.previous_canvas)
end

-- Draws the poster object, Applying any shaders it gets as arguments.
function poster:draw(...)
    -- Capturing previous graphics state
    local r, g, b, a = lg.getColor()
    local previous_canvas = lg.getCanvas()
    local previous_blendMode, previous_alphaMode = lg.getBlendMode()

    local shaders = {...}
    local chain

    -- Chain handling
    if type(shaders[1]) == "table" then
        chain = shaders[1]
        shaders = chain.effects
        self:send(chain.settings)
    end

    -- Rendering effects
    lg.setBlendMode("alpha")
    lg.setCanvas(self.b)
    lg.clear()
    lg.draw(self.main)
    local state = false
    local final = false
    for _, shader in pairs(shaders) do
        local a = self.a
        local b = self.b
        if state then
            a = self.b 
            b = self.a
        end
    
        lg.setCanvas(a)
        lg.clear()
        local _shader = shader
        if type(shader) == "string" then
            assert(self.shaders[shader], f("Shader '%s' does not exist", shader))
            _shader = self.shaders[shader]
        end
        lg.setShader(_shader)
        lg.draw(b)
        lg.setShader()

        final = a

        state = not state
    end

    -- Reverting previous graphics state
    lg.setCanvas(previous_canvas)
    lg.setBlendMode(previous_blendMode, previous_alphaMode)
    lg.setColor(r, g, b, a)

    -- Drawing the final shader
    lg.draw(final or self.main)
end

return poster