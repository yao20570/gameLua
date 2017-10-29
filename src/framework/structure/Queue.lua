
--[[
队列数据结构，内部下标从0开始，外部使用下标从1开始（符合lua的习惯）
]]
Queue = class("Queue")

function Queue:ctor()

    self:clear()
end

function Queue:empty()

    return self._last < self._first
end

function Queue:size()
    return self._last - self._first + 1
end

function Queue:clear()

    self._queue = {}
    self._first = 0
    self._last  = -1
end

function Queue:front()

    if self:empty() then
        return nil
    end

    return self._queue[self._first]
end

function Queue:getList()
    return self._queue
end

function Queue:back()

    if self:empty() then
        return nil
    end

    return self._queue[self._last]
end

function Queue:push(data)

    self._last  = self._last + 1
    self._queue[self._last] = data
end

function Queue:pop()

    if self:empty() then
        return nil
    end

    local data                  = self._queue[self._first]
    self._queue[self._first]    = nil
    self._first                 = self._first + 1
    return data
end

function Queue:at(index)

    if self:empty() or index > self:size() then
        return nil
    end

    return self._queue[self._first + index - 1]
end

function Queue:find(data)
    local index = -1
    local size = self:size()
    for i=1, size do
        local d = self:at(i)
        if d == data then
            index = i
            break
        end
    end
    return index
end

