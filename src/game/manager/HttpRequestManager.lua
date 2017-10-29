HttpRequestManager  = {}

function HttpRequestManager:init()
    self._sendMap = {}
end

function HttpRequestManager:finalize()
    self._sendMap = {}
end

function HttpRequestManager:send(url, params, obj, successCallback, failCallback, timeout)

    local redurl = self:packUrlByParams(url,params)

    timeout = timeout or 10 

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    
    xhr.timeoutHandler = self.timeoutHandler
    TimerManager:addOnce(timeout * 1000,xhr.timeoutHandler, self, redurl, obj, failCallback)
    
    self._sendMap[redurl] = true

    xhr:open("GET", redurl)
    
    local function onReadyStateChange()
        if self._sendMap[redurl] ~= true then  --已经对该请求做过处理了
            return
        end
        if xhr.status == 200 then --接受数据成功
            local info = xhr.response
            self._sendMap[redurl] = false
            successCallback(obj, info)
        else
            if failCallback ~= nil then
                failCallback()
            end
        end
    end
    
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send()
    
end

function HttpRequestManager:timeoutHandler(url, obj, failCallback)
    if self._sendMap[url] == true then  --time out
        self._sendMap[url] = false
        if failCallback ~= nil then
            failCallback(obj)
        end
    end
end

--url + parms
function HttpRequestManager:packUrlByParams(url, params)
    local pstr = ""
    local index = 1
    for key, val in pairs(params) do
        if index == 1 then
            pstr = pstr .. key .. "=" .. val 
        else
            pstr = pstr .. "&" .. key .. "=" .. val 
        end
        index = index + 1
    end
    local redurl = url
    if pstr ~= "" then
        redurl = url .. "?" .. pstr
    end
    
    return redurl
end




