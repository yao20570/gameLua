

function handler(obj, method)
    return function(...)
        if method then
            return method(obj, ...)
        else
            print("error:handler has a nil method")
        end
    end
end