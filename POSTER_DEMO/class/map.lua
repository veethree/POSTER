-- This module handles the game grid.
local map = {}
local map_meta = {__index = map}

local random = math.random

function map.new(width, height)
    local m = setmetatable({
        width = width,
        height = height,
        cell = {},
        colors = colors
    }, map_meta)
    m:init()
    m:spawnFood()
    return m
end

function map:init()
    for y=1, self.height do
        self.cell[y] = {}
        for x=1, self.width do
            self.cell[y][x] = 1
        end
    end
end

function map:spawnFood()
    self:clear(3)
    self:set(random(1, self.width), random(1, self.height), 3)
end

function map:set(x, y, cell)
    self.cell[y][x] = cell
end

function map:get(x, y)
    if x > 0 and x <= self.width and y > 0 and y <= self.height then
        return self.cell[y][x]
    end
    return false
end

function map:clear(...)
    for y=1, self.height do
        for x=1, self.width do
            for i,v in ipairs({...}) do
                if self.cell[y][x] == v then
                    self.cell[y][x] = 1
                end
            end
        end
    end
end

function map:draw(cellSize, border)
    border = border or 1
    for y=1, self.height do
        for x=1, self.width do
            local cell = self.cell[y][x]
            lg.setColor(self.colors[cell])
            lg.rectangle("fill", (x - 1) * cellSize, (y - 1) * cellSize, cellSize - border, cellSize - border)
        end
    end
end

return map