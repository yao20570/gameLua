

------获取道具特效---
GetGoodsEffect = class("GetGoodsEffect", BaseAnimation)

function GetGoodsEffect:finalize()
    GetGoodsEffect.super.finalize(self)
end

--function GetGoodsEffect:play()
--    if self._itemList == nil then
--        self._itemList = { }
--    end

--    local posState
--    local toolbarPanel = self:getModulePanel(ModuleName.ToolbarModule, "ToolbarPanel")
--    if toolbarPanel == nil then
--        return
--    end
--    self._targetPos = toolbarPanel:getBtnItem5Pos()
--    posState = true

--    local function completeFunc()
--        self._showGetGoodsEffectQueue:actionComplete()
--    end

--    local function delayGetRewardAction(obj, result)
--        local uiGetProp = UIRewardWithAct.new(self.parent, self, posState, completeFunc)
--        uiGetProp:show(result, self._targetPos)
--        -- print("传入move的目标为： "..self._targetPos.x.."||".. self._targetPos.y)
--    end

--    local function complete()
--        if #self._itemList > 0 then
--            self._showGetGoodsEffectQueue:push(self._itemList)
--            self._itemList = { }
--        end
--    end

--    if self._showGetGoodsEffectQueue == nil then
--        self._showGetGoodsEffectQueue = UIActionQueue.new(delayGetRewardAction, self, complete)
--    end

--    if self._showGetGoodsEffectQueue:isRunning() then
--        -- 特效还在播放，将数据缓存起来
--        table.addAll(self._itemList, self.data)
--    else
--        self._showGetGoodsEffectQueue:push(self.data)
--        -- 直接运行了
--    end
--end

function GetGoodsEffect:play()
    if self._itemList == nil then
        self._itemList = { }
    end


    local toolbarPanel = self:getModulePanel(ModuleName.ToolbarModule, "ToolbarPanel")
    if toolbarPanel == nil then
        return
    end

    self._targetPos = toolbarPanel:getBtnItem5Pos()
    local posState = true


    local function completeCallback()
        EffectQueueManager:completeEffect()
    end

    local data = self.data
    EffectQueueManager:addEffect(EffectQueueType.GET_REWARD_LIST, function()
        local uiGetProp = UIRewardWithAct.new(self.parent, self, posState, completeCallback)
        uiGetProp:show(data, self._targetPos)
    end )

end