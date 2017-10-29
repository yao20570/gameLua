
Stack = class("Stack")

function Stack:ctor()
    self.stack = {}
    self.top = 0
end

function Stack:push(value)
    self.top = self.top + 1
    self.stack[self.top] = value
end

function Stack:pop()
    if self.top <= 0 then
        return nil
    end

    local value = self.stack[self.top]
    self.stack[self.top] = nil
    self.top = self.top - 1
    if self.top <= 0 then
        self.top = 0
    end
    return value
end

function Stack:size()
    return self.top
end

function Stack:isEmpty()
    return self.top == 0
end

function Stack:back()
    if self.top ~= 0 then
        return self.stack[self.top]
    end
end

function Stack:clear()
    for i = 1, self.top do
        self:pop()
    end
end

function Stack:isInState(value)
    local flag = false
    for _, var in pairs(self.stack) do
    	if var == value then
    	    flag = true
    	    break
    	end
    end
    
    return flag
end
