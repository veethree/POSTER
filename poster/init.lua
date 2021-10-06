-- POSTER: A library for applying post processing effects via shaders to your löve game.
-- Version: v0.2

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


local print_status = true -- This is for debugging, If true, POSTER will print out what its doing

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
    loaded_shaders = {},
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
        print(f("Loading shader '%s/%s'.", shader_path, shader))
        poster.loaded_shaders[name] = lg.newShader(f("%s/%s", shader_path, shader))
    end
end
print("Shaders loaded.")

-- Sending a default imageSize to shaders that use it.
print("Sending 'imageSize' to shaders in the 'shaders_with_imageSize' list")
local imageSize = {lg.getWidth(), lg.getHeight()}
for _,shader in pairs(poster.shaders_with_imageSize) do
    print(f("Sending to '%s'", shader))
    poster.loaded_shaders[shader]:send("imageSize", imageSize)
end
print("Finished.")

--==[[ LOCAL METHODS ]]==--

local function shaderLoaded(shader)
    return poster.loaded_shaders[shader] or false
end

--==[[ CHAIN SYSTEM ]]==--

-- Creates a new chain
function poster.newChain(shaders, settings)
    return setmetatable({
        type = "chain",
        shaders = shaders or {},
        settings = settings or {},
        macros = macros or {}
    }, poster_meta)
end

-- Adds a shader to a chain
function poster:addShader(...)
    assert(self.type == "chain", "addShader() can only be used on chain objects")
    for i,v in ipairs({...}) do
        local shader = v
        -- Checking if the shader provided exists & is of the appropriate type.
        if type(v) == "string" then
            assert(self.loaded_shaders[shader], f("Shader '%s' does not exist.", shader))
        else
            if type(shader) == "userdata" then
                assert(shader:type() == "Shader", f("'%s' is not a shader", shader))
            end
        end

        insert(self.shaders, shader)
    end
end

-- Adds a setting to a chain
function poster:addSetting(...)
    assert(self.type == "chain", "addSetting() can only be used on chain objects")
    insert(self.settings, {...})
end

-- Adds a macro to a chain. macroName is the name used to refer to the macro
-- targets is a table with the following format
-- { {targetShader, targetUniform, Multiplier}, ... }
function poster:addMacro(macroName, targets)
    local macro = {
        targets = targets,
        targetSettings = {}
    }

    for _, target in ipairs(targets) do
        for _,setting in ipairs(self.settings) do
            if setting[1] == target[1] and setting[2] == target[2] then
                insert(macro.targetSettings, setting)
            end
        end
    end

    self.macros[macroName] = macro
end

-- Sets a macros value
function poster:setMacro(macroName, value)
    for _, setting in ipairs(self.macros[macroName].targetSettings) do
        setting[3] = value * self.macros[macroName].targets[_][3]
    end
end

--==[[ CANVAS SYSTEM ]]==--

-- Creates and returns a new poster canvas.
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
        assert(self.loaded_shaders[shader], f("Shader '%s' does not exists!", shader))
        self.loaded_shaders[shader]:send(uniform, data)
    elseif type(shader) == "table" then
        for i,v in ipairs(shader) do
            self.loaded_shaders[v[1]]:send(v[2], v[3])
        end
    end
end

-- Sending "imageSize" to shaders that require it
-- width & height default to the window size
function poster:sendImageSize(width, height)
    local imageSize = {width or lg.getWidth(), height or lg.getHeight()}
    for _,shader in pairs(self.shaders_with_imageSize) do
        poster.loaded_shaders[shader]:send("imageSize", imageSize)
    end
end

-- Sets a wrap mode for the poster object
function poster:setWrap(wrap)
    self.main:setWrap(wrap)
    self.a:setWrap(wrap)
    self.b:setWrap(wrap)
end

-- Draws to the poster canvas
function poster:drawTo(func)
    func = func or function() lg.clear() end
    local previous_canvas = lg.getCanvas()
    lg.setCanvas(self.main)
    func()
    lg.setCanvas(previous_canvas)
end

-- Clears the poster canvas
function poster:clear()
    local previous_canvas = lg.getCanvas()
    lg.setCanvas(self.main)
    lg.clear()
    lg.setCanvas(previous_canvas)
end

-- set / unset block
function poster:set()
    poster.previous_canvas = lg.getCanvas()
    lg.setCanvas(self.main)
end

function poster:unset()
    lg.setCanvas(poster.previous_canvas)
end

-- Draws the poster canvas, Applying any shaders it gets as arguments.
function poster:draw(...)
    -- Capturing previous graphics state
    local r, g, b, a = lg.getColor()
    local previous_canvas = lg.getCanvas()
    local previous_blendMode, previous_alphaMode = lg.getBlendMode()
    local arguments = {...}

    -- Checking arguments
    local isChain, isShader = false, false
    for i,v in ipairs(arguments) do
        if type(v) == "table" then
            if v.type == "chain" then
                assert(not isShader, "Cannot mix chains and shaders when drawing")
                isChain = true
            end
        elseif type(v) == "string" then
            assert(shaderLoaded(v), f("Shader '%s' does not exist", v))
            assert(not isChain, "Cannot mix chains and shaders when drawing")
            isShader = true
        end
    end

    local chains = {1}
    if isChain then
        chains = arguments
    end

    -- Rendering effects
    lg.setBlendMode("alpha")
    lg.setCanvas(self.b)
    lg.clear()
    lg.draw(self.main)
    local state = false
    local final = false

    for _, chain in ipairs(chains) do
        local shaders = arguments
        if isChain then
            shaders = chain.shaders
            self:send(chain.settings)
        end

        for _, shader in pairs(shaders) do
            -- Swapping canvas a & b
            local a = self.a
            local b = self.b
            if state then
                a = self.b 
                b = self.a
            end
            
            -- Applying shader
            lg.setCanvas(a)
            lg.clear()
            local _shader = shader
            if type(shader) == "string" then
                -- Asserting that the shader exists in the loaded_shaders table
                assert(self.loaded_shaders[shader], f("Shader '%s' does not exist", shader))
                _shader = self.loaded_shaders[shader]
            end
            lg.setShader(_shader)
            lg.draw(b)
            lg.setShader()

            final = a

            state = not state
        end
    end
    -- Reverting previous graphics state
    lg.setCanvas(previous_canvas)
    lg.setBlendMode(previous_blendMode, previous_alphaMode)
    lg.setColor(r, g, b, a)

    -- Drawing the final shader
    lg.draw(final or self.main)
end

return poster