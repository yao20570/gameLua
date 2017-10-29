module("server", package.seeall)

caseclass = function(msg, ...)
    local keys = {...}
    local Class = class(msg)
    function Class:ctor( ... )
        local values = { ... }
        local index = 1
        for _, key in pairs(keys) do
        	self[key] = values[index]
        	index = index + 1
        end
    end
    
    return Class
end

instanceof = function(Object, Class)
    local flag = false
    if Object ~= nil and Class ~= nil then
        if Object.__cname == Class.__cname then
            flag = true
        end
    end
    
    return flag
end



