
FunctionWebConfig = {}
----配置功能名字，与后台一一对应
FunctionWebConfig.FunctionName1 = "FunctionName1"
----//null
FunctionWebConfig.TK_CHANNEL = "TK_CHANNEL"                                 --//    3k渠道包  
FunctionWebConfig.MR_CHANNEL = "MR_CHANNEL"                                 --//    联运渠道    同时开启 默认MR渠道
------------------------------------------------------
FunctionWebManager = {}

--会通过平台ID进行判断
function FunctionWebManager:isFunctionOpen(functionName)
	if self._functionWebData == nil then
		return true
	end
    local configValue = self._functionWebData[functionName]
    if configValue == nil then  --默认开启
    	return true
    end

    return configValue == 1

end

function FunctionWebManager:init()
	local params = {}
    params["plat_id"] = GameConfig.platformChanleId
    params["channel_id"] = GameConfig.channelId
    params["service"] = "Function.GetFunctionList"

    local url = GameConfig.admincenter_api_url --GameConfig.admincenter_api_url
    -- 发送Http协议，设置相关的回调函数
    HttpRequestManager:send(url, params, self, self.onGetFunctionListSuccess, self.onGetFunctionListFail)
end

function FunctionWebManager:onGetFunctionListSuccess(info)
	logger:info("!!!!获取功能开放信息成功info:%s!!!!!", info)
	self:initConfig(info)
end

function FunctionWebManager:onGetFunctionListFail(info)
	logger:info("!!!!获取FunctionWebManager失败!!!!!!")
end

function FunctionWebManager:initConfig(configStr)
	require("json")
    local function decode()
        local result = json.decode(configStr)
        return result
    end
    local status, functionData = pcall(decode)
    if status ~= true then
    	functionData = {}
    end

    self._functionWebData = functionData
end