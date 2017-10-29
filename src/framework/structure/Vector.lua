Vector = class("Vector")

-- vector data sturcture

function Vector:ctor()
    self._vector = {}
    self._size = 0
end

-- removes all elements from the vector
function Vector:clear()
    self._vector = {}
    self._size = 0
end

-- returns the number of items in the vector
function Vector:size()
    return self._size
end

-- true if the vector has no elements
function Vector:empty()
    return self._size == 0
end

-- add an element to the end into the vector
function Vector:push_back(data)
    self._vector[self._size] = data
    self._size               = self._size + 1
end

-- removes the last element from the vector
function Vector:pop_back()
    self._vector[self._size] = nil
    self._size               = self._size - 1 
end

-- returns the first element of the vector
function Vector:front()
    if self:empty() then
        return nil
    end

    return self._vector[0]
end

-- returns the last element of the vector
function Vector:back()
    if self:empty() then
        return nil
    end

    return self._vector[self._size - 1]
end

-- removes the element of the vector
function Vector:remove(data)
    local idx = self:find(data)
    if idx ~= -1 then
        self:erase(idx)
        return true
    end

    return false
end

-- removes the the element by index from the vector
-- index begin from 1
function Vector:erase(index)
    if self:empty() then
        return nil
    end

    if (index < 1 or index > self._size) then
        return nil
    end

    local curIndex = index
    while curIndex < self._size do
        self._vector[curIndex - 1] = self._vector[curIndex]
        curIndex                   = curIndex + 1
    end
    self._vector[curIndex - 1] = nil
    self._size                 = self._size - 1
end

-- returns an element at a specific location
-- index begin from 1
function Vector:at(index)
    if self:empty() then
        return nil
    end

    if (index < 1 or index > self._size) then
        return nil
    end

    return self._vector[index - 1]
end

function Vector:assignAt(index, value)

    if self:at(index) ~= nil then
        self._vector[index - 1] = value
    end
end

function Vector:cloneData(vector)

    local array = {}
    for key,value in pairs(vector) do
        array[key] = value
    end
    return array
end

-- 遍历的时候不要删除数据，若删除数据，
function Vector:foreach(func)
    if self:empty() then
        return
    end

    local size      = self:size()
    local vector    = self:cloneData(self._vector)
    for i=0,size-1 do
        if func(i+1, vector[i]) == false then
            break
        end
    end
end

function Vector:find(data)
    if self:empty() then
        return -1
    end

    for idx,value in pairs(self._vector) do
        if value == data then
            return idx + 1
        end
    end

    return -1
end
