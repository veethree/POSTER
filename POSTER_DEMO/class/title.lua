local title = {}
local title_meta = {__index = title}

function title.new(text, x, y, color, alignment, font)
    return setmetatable({
        text = text,
        x = x,
        y = y,
        color = color or {1, 1, 1, 1},
        alignment = alignment or "center",
        font = font or lg.getFont()
    }, title_meta)
end

function title:set(text)
    self.text = text
end

function title:setPosition(x, y, sm)
    x = x or self.x
    y = y or self.y
    smoof:new(self, {x = x, y = y}, sm)
end

function title:draw()
    lg.setColor(self.color)
    lg.setFont(self.font)
    lg.printf(self.text, self.x, self.y, lg.getWidth(), self.alignment)
end

return title