
LogUtils = {}


function LogUtils:send(ct, ac, params, url, callback)
    do
        return -- 先把日志请求发送屏蔽掉 看看效果
    end

    ct = ct or "1"
    url = url or GameConfig.statistics_url
    local str = "ct=" .. ct ..  "&ac=" .. ac
    for key, value in pairs(params) do
        str = str .. "&" .. key .. "=" .. value
    end

    local url = url .. "?" .. str

    local xhr = XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    
    local function onReadyStateChange()
        local info = xhr.response
        logger:info("======kkk日志返回:%s==============", info)
        if callback ~= nil then
            callback(info)
        end
    end


    print("--------kkk日志发送--------------")
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:open("GET", url)
    xhr:send()
end