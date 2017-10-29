GuideLog = {}

function GuideLog:onBegin(step)

    local params = {}
    params["serId"] = GameConfig.serverId
    params["roleId"] = GameConfig.actorid
    params["step"] = step
    
    LogUtils:send(nil, "statis_guide",params)

end

--记录在哪一步进行跳过
function GuideLog:onSkip(step)
    local params = {}
    params["serId"] = GameConfig.serverId
    params["roleId"] = GameConfig.actorid
    params["step"] = step
    
    LogUtils:send(nil, "statis_guide_skip",params)
end

-----------------------------------------
--引导统计
--state 1 开始 2结束 3跳过 4引导中
function GuideLog:onBeginGuide(guideId)
    local params = {}
    params["serId"] = GameConfig.serverId
    params["roleId"] = GameConfig.actorid
    params["guideId"] = guideId
    params["state"] = 1
    params["step"] = 0
    
    LogUtils:send(nil, "statis_guide_log",params)
end

--引导中步骤
function GuideLog:onGuideing(guideId, step)
    step = step or 0
    local params = {}
    params["serId"] = GameConfig.serverId
    params["roleId"] = GameConfig.actorid
    params["guideId"] = guideId
    params["step"] = step
    params["state"] = 4
    LogUtils:send(nil, "statis_guide_log",params)
end

--引导结束，包括跳过
--step掉过步数 不跳过则为0 or nil
function GuideLog:onCompleteGuide(guideId, step)
    step = step or 0
    local params = {}
    params["serId"] = GameConfig.serverId
    params["roleId"] = GameConfig.actorid
    params["guideId"] = guideId
    params["step"] = step
    if step == 0 then
        params["state"] = 2
    else
        params["state"] = 3
    end
    LogUtils:send(nil, "statis_guide_log",params)
end




