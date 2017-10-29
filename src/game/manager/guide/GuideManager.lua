
--通过ID 直接触发
GuideManager = {}

GuideManager.EndGuideId = 104

function GuideManager:init(gameState)

    self._gameState = gameState
    self._guideMap = {}
    self._curGuide = nil

    self._isStartGuide = false
    self._isInit = true
    --self._isNowGuide = nil   --从引导开始到真正结束 包括跳出引导
end

function GuideManager:finalize()
    self._guideMap = nil
    self._curGuide = nil

    self._isStartGuide = nil
    self._isGuidingUnreset = nil
    self._isInit  = nil
end

function GuideManager:getGuideData(guideId)

    if GameConfig.isTriggerGuide == false and guideId > 101 then  --配置不触发引导，直接返回nil
        return nil
    end

    local GuideClass = require("guideData.guide.Guide" .. guideId)
    if type(GuideClass) ~= type({}) then
        return
    end
    local guide = GuideClass.new(self._gameState)
    return guide
end


function GuideManager:endGuide(guide)    
    self:setStartGuide(false)
    self._isGuidingUnreset = false
    --TODO 引导结束
    if guide.id == GuideManager.EndGuideId then  --最后一个引导结束，弹出奖励框
--        local parent = self._gameState:getLayer(ModuleLayer.UI_TOP_LAYER)
        --UIGuideReward.new(parent, self._gameState)
        self._gameState:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20301, {})
    end

    if self._guideCallback and type(self._guideCallback) == "function" then
        self._guideCallback()
        self._guideCallback = nil
    end
end

--返回是否成功进入引导了
function GuideManager:trigger(guideId, isAlway)

    if self._isStartGuide == true then
        return false
    end

    self._guideId = guideId
    local snaphotGuideId, actionStep = self:getSnaphotInfo()
    if guideId == snaphotGuideId then --不触发引导，直接使用快照里面的引导
        return
    end

    local guide = nil
    if guideId ~= nil then
        guide = self:getGuideData(guideId)
    end

    if guide ~= nil then
        if guide.isTrigger ~= true then --配置中 不触发该引导
            return false
        end        
        self:setStartGuide(true)
        self._isGuidingUnreset = true
        --self._isNowGuide = true
        self._curGuide = guide
        local flag = guide:onEnter(1, isAlway)
        return flag
    end
end

function GuideManager:getCurGuideId()
    return self._guideId
end

function GuideManager:isGuideTrigger(guideId)
    local key = "guide" .. guideId 
    local bool =  LocalDBManager:getValueForKey(key)
    return bool ~= nil
end

function GuideManager:skipGuide()
    

    if self._curGuide ~= nil then
        self._curGuide:skipAction()
    else
        self:hideGuide()
    end

    
   
end

--还原快照  断线重连也会走这里
function GuideManager:resetSnaphot()
    if self._isStartGuide == true then
        return false--在引导中，不处理快照
    end
    local guideId, actionStep = self:getSnaphotInfo()
    if guideId ~= nil then
        local guide = self:getGuideData(guideId)
        if guide ~= nil then
            self._guideId = guideId
            self:setStartGuide(true)
            guide:enterActionByStep(actionStep)
            self._curGuide = guide
            return true
        end
    end
end

function GuideManager:isStartGuide()
    return self._isStartGuide
end

function GuideManager:setStartGuide(isStart)
    self._isStartGuide = isStart
end

-- 引导界面执行中，不进行重置清除
function GuideManager:isGuidingUnreset()
    return self._isGuidingUnreset
end

function GuideManager:getSnaphotInfo()
    local snapshot = LocalDBManager:getValueForKey("guideSnapshot")
    if snapshot ~= nil and snapshot ~= "" then
        local ary = StringUtils:splitString(snapshot, "-")
        local guideId = ary[1]
        local actionStep = ary[2]
        
        local guideId = tonumber(guideId) --TODO 逻辑处理
        if guideId == 101 then --特殊处理第一个引导就好了
            local id = tonumber(guideId)
            local step =  tonumber(actionStep)
            if step <= 3 then
                step = 1
            elseif step <= 5 then
                local dungeonProxy = self._gameState:getProxy(GameProxys.Dungeon)
                dungeonProxy:onExterInstanceSender(0)
                step = 4
            else
                return
            end
            return id, step
        elseif guideId == 104 then
            local id = tonumber(guideId)
            local step =  tonumber(actionStep)
            return id, step
        end
    end
end

function GuideManager:hideGuide()
    local data = {}
    data["moduleName"] = ModuleName.GuideModule
    self._gameState:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, data)
end

-- function GuideManager:isNowGuide()
--     return self._isNowGuide
-- end

-- function GuideManager:setNowGuide(flage)
--     self._isNowGuide = flage
-- end

function GuideManager:guideHideCallback(callback)
    self._guideCallback = callback
end