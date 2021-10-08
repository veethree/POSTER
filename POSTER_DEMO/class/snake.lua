local snake = {}
local snake_meta = {__index = snake}

local insert, remove = table.insert, table.remove

function snake.new(x, y, world)
    return setmetatable({
        x = x,
        y = y,
        length = 5,
        direction = 2,
        speed = 12,
        tail = {},
        directionChanged = false,
        world = world
    }, snake_meta)
end

function snake:move()
    local ox, oy = self.x, self.y
    local nx, ny = ox, oy
    if self.direction == 1 then -- left
        nx = nx - 1
    elseif self.direction == 2 then -- right
        nx = nx + 1
    elseif self.direction == 3 then -- up
        ny = ny - 1
    elseif self.direction == 4 then -- down
        ny = ny + 1
    end

    -- Tail
    insert(self.tail, 1, {ox, oy})
    if #self.tail > self.length then
        remove(self.tail)
    end

    self.world:clear(2)

    for i,v in ipairs(self.tail) do
        self.world:set(v[1], v[2], 2)
    end

    -- Collision
    local nextCell = self.world:get(nx, ny)
    if nextCell then
        if nextCell == 2 then --Snake
            gameover()
        elseif nextCell == 3 then
            self.x = nx
            self.y = ny
            eat()
            self.world:spawnFood()
        else
            self.x = nx
            self.y = ny
        end
    else
        gameover()
    end

    self.world:set(self.x, self.y, 2)
    self.directionChanged = false
end

return snake