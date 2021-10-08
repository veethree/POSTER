-- Smoof: A tiny tweening library for lua
-- Version 1.2
--
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
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local smoof = {
    stack = {},
    bind_stack = {},
    default_smoof_value = 0.001,
    default_completion_threshold = 0.1
}

-- Checks if an object is already in the stack, And returns every instance of it
local function in_stack(object) 
    local duplicate = false
    for i,item in ipairs(smoof.stack) do
        if item.object == object then
            if not duplicate then duplicate = {} end
            duplicate[#duplicate + 1] = {
                key = i,
                item = item
            }
        end
    end
    return duplicate
end

-- Self explanatory.
function smoof:setDefaultSmoofValue(val)
    self.default_smoof_value = val
end

-- Self explanatory.
function smoof:setCompletionThreshold(threshold)
    self.default_completion_threshold = threshold
end

-- Starts a new animation
-- object: A table containing the values you want to animate
-- target: A table containing the target values. Must have at least one key in common with 'object'
--         Keys not found in object will be ignored.
-- smoof_value: How long the animation is. Smaller value means slower animation. Values between 1 & 15 are reasonable
-- completion_threshold: How close the value needs to get to the target before snapping to it and ending the animation
-- bind: Boolean, If true, The animation is never removed from the stack, So the values will constantly
--       animate towards target.
-- callback: A table containing one or more of the following functions: onStart, onStep, onArrive
function smoof:new(object, target, smoof_value, completion_threshold, bind, callback)
    smoof_value = smoof_value or self.default_smoof_value
    completion_threshold = completion_threshold or self.default_completion_threshold
    bind = bind or false
    callback = callback or {}

    -- Checking if exists
    local duplicates = in_stack(object)
    local remove_list = {}
    
    -- If object is already in stack, Remove it.
     if duplicates then
         for _, duplicate in ipairs(duplicates) do
            table.remove(self.stack, duplicate.key)
         end
     end

    -- Adding to stack
    self.stack[#self.stack + 1] = {
        object = object,
        target = target,
        smoof_value = smoof_value,
        completion_threshold = completion_threshold,
        bind = bind,
        callback = callback
    }
    if type(self.stack[#self.stack].callback["onStart"]) == "function" then
        self.stack[#self.stack].callback["onStart"](self.stack[#self.stack])
    end
end

function smoof:unbind(object)
    local items = in_stack(object)
    for _, item in pairs(items) do
        table.remove(self.stack, _)
    end
end

function smoof:update(dt)
    for _,item in ipairs(self.stack) do
        local finished = true
        for key,val in pairs(item.target) do
            -- Smoofing
            if item.object[key] then
                item.object[key] = item.object[key] + (val - item.object[key]) * (1 - (item.smoof_value ^ dt))
                if type(item.callback["onStep"]) == "function" then
                    item.callback["onStep"](item)
                end
                -- Checking if the value is within the threshold
                if math.abs(item.object[key] - val) > item.completion_threshold then
                    finished = false
                else
                    item.object[key] = val
                end
            end
        end
        if finished then
            -- Removing from stack if finished
            if not item.bind then
                table.remove(self.stack, _)
                if type(item.callback["onArrive"]) == "function" then
                    item.callback["onArrive"](item)
                end
            end
        end
    end
end

return smoof