-- GLOBALS
lg = love.graphics
fs = love.filesystem
kb = love.keyboard
lm = love.mouse
random = math.random
noise = love.math.noise
sin = math.sin
cos = math.cos
floor = math.floor
f = string.format
insert = table.insert
remove = table.remove

colors = {
    {0.1, 0.1, 0.1, 1}, -- BG
    {0.9, 0.9, 0.9, 1}, -- Snake
    {0.1, 0.9, 0.4, 1}, -- Food
    {0.9, 0.2, 0.2, 1} -- red
}

useShaders = true -- Used to toggle shaders

function love.load()
    -- Loading the various classes
    poster = require("class.poster")
    map = require("class.map")
    snake = require("class.snake")
    smoof = require("class.smoof")
    title = require("class.title")


    -- Loading fonts
    font = {
        large = lg.newFont("font/monogram.ttf", 64),
        small = lg.newFont("font/monogram.ttf", 24)
    }

    -- Text
    text = {
        newgame = title.new("press any key to start", 0, lg.getHeight() + 100, colors[3], nil, font.large),
        shadertip = title.new("Press '1' to toggle shaders", 12, 12, colors[3], "left", font.small),

        gameover = title.new("GAME OVER", 0, -100, colors[4], nil, font.large),
        score = title.new("score", 0, lg.getHeight() * 0.87, colors[3], nil, font.large)
    }

    -- Löve setup
    lg.setBackgroundColor(0.08, 0.08, 0.08)

    -- POSTER Setup
    canvas = poster.new() -- The main canvas everything will be drawn to

    -- Bloom chain, This chain just blurs everything, and applies a bit of contrast.
    bloom = poster.newChain({"contrast", "verticalBlur", "horizontalBlur"})
    bloom:addSetting("verticalBlur", "amount", 1)
    bloom:addSetting("horizontalBlur", "amount", 1)
    bloom:addSetting("contrast", "amount", 2)
    bloom:addMacro("amount", {
        {"verticalBlur", "amount", 1},
        {"horizontalBlur", "amount", 1},
    })
    
    bloom:setMacro("amount", 2)

    -- Post chain, This is the "main" post processing chain. Everything + the kitchen sink.
    post = poster.newChain({"chromaticAberrationRadius", "barrelDistortion", "scanlines",
                            "rgbMix", "verticalBlur", "horizontalBlur", "vignette"})
    post:addSetting("chromaticAberrationRadius", "position", {lg.getWidth() / 2, lg.getHeight() / 2})
    post:addSetting("chromaticAberrationRadius", "offset", 6)
    post:addSetting("scanlines", "scale", 0.8)
    post:addSetting("scanlines", "opacity", 0.9)
    post:addSetting("barrelDistortion", "power", 1.06)
    post:addSetting("rgbMix", "rgb", {0.9, 1, 1.3})
    post:addSetting("verticalBlur", "amount", 1)
    post:addSetting("horizontalBlur", "amount", 1)
    post:addSetting("vignette", "opacity", 0.5)
    post:addSetting("vignette", "softness", 0.8)
    post:addSetting("vignette", "radius", 0.8)
    post:addSetting("vignette", "color", {0, 0, 0, 1})
    post:addMacro("blur", {
        {"verticalBlur", "amount", 1},
        {"horizontalBlur", "amount", 1},
    })

    -- This table is used to control the blur macro in the "post" chain
    -- I've set it up like this so i can use it with "smooth" easily.
    control = {blur = 2}


    newgame()
    time = 0
end

-- Resets the game
function newgame()
    -- Creating the world
    cellSize = 16
    local w = floor(lg.getWidth() / cellSize)
    local h = floor(lg.getHeight() * 0.9 / cellSize)
    world = map.new(w, h)

    -- Creating the player
    player = snake.new(floor(w / 2), floor(h / 2), world)
    world:set(player.x, player.y, 2)
    tick = 0
    score = 0
    started = false
    over = false

    --Showing & hiding the appropriate text
    text.newgame:setPosition(0, lg.getHeight() - 300)
    text.gameover:setPosition(0, -100)
    text.score:setPosition(0, lg.getHeight() * 0.87)
    text.score:set("0")
end

-- Starts the game
function start()
    started = true
    text.newgame:setPosition(0, lg.getHeight() + 100)
    text.shadertip:setPosition(-600, 12)
    smoof:new(control, {blur = 0}, 0.001)
end

-- Ends the game
function gameover()
    over = true
    smoof:new(control, {blur = 2}, 0.001)
    text.gameover:setPosition(0, 100)
    text.score:set(score)
    text.score:setPosition(0, lg.getHeight() - 200)
end

-- Called when the snake hits a food
function eat()
    score = score + 1
    text.score:set(score)
    player.length = player.length + 1
end

function love.update(dt)
    smoof:update(dt)

    post:setMacro("blur", control.blur) -- Setting the "blur" macro

    -- Little timer loop that controls how fast the snake moves
    if started and not over then
        tick = tick + dt
        if tick > (1 / player.speed) then
            player:move()
            tick = 0
        end
    end
end

function love.draw()
    -- Setting the blend mode to "alpha" because its set to add below for the bloom
    lg.setBlendMode("alpha")

    -- Drawing the game to the canvas
    canvas:drawTo(function()
        world:draw(cellSize, 0)
    end, true)

    lg.setColor(1, 1, 1, 1)
    if useShaders then
        -- Drawing the canvas to the screen, With the "post" chain
        canvas:draw(post)
        
        -- Drawing the canvas again, But with the "add" blend mode & "bloom" chain to achieve the bloom effect
        lg.setColor(1, 1, 1, 0.7)
        lg.setBlendMode("add")
        canvas:draw(bloom)
    else
        canvas:draw()
    end

    -- Drawing the text
    for i,v in pairs(text) do
        v:draw()
    end
end

function love.keypressed(key)
    -- Starting the game if any key is pressed except "1" if its not started yet.
    if not started and key ~= "1" then
        start()
    end

    -- Restarting the game if any key is pressed except "1"
    if over and key ~= "1"  then
        newgame()
    end

    if key == "escape" then love.event.push("quit") end -- Exit with escape
    if key == "1" then useShaders = not useShaders end -- Toggle shaders with "1"

    -- Controlling the snakes direction
    if key == "left" then
        if player.direction ~= 2 and not player.directionChanged then
            player.direction = 1
            player.directionChanged = true
        end
    elseif key == "right" then
        if player.direction ~= 1 and not player.directionChanged then
            player.direction = 2
            player.directionChanged = true
        end
    elseif key == "up" then
        if player.direction ~= 4 and not player.directionChanged then
            player.direction = 3
            player.directionChanged = true
        end
    elseif key == "down" then
        if player.direction ~= 3 and not player.directionChanged then
            player.direction = 4
            player.directionChanged = true
        end
    end
end