UIGuideReward = class("UIGuideReward")

function UIGuideReward:ctor(parent, eventSender)
    local uiSkin = UISkin.new("UIGuideReward")
    uiSkin:setParent(parent)
    
    self._uiSkin = uiSkin
    self._eventSender = eventSender
    
    local children = uiSkin:getRootNode():getChildren()
    for _,child in pairs(children) do
        local zorder = child:getLocalZOrder()
        if zorder == 0 then
            child:setLocalZOrder(1)
            child:setTouchEnabled(false)
        end
    end
    
    --local secLvBg = UISecLvPanelBg.new(uiSkin:getRootNode(), self)
    --secLvBg:setTitle(TextWords:getTextWord(112))
    --secLvBg:setContentHeight(380)
    
    self:initPanel()
    self:registerEvent()
end

function UIGuideReward:finalize()
   -- self._spineModel:finalize()
    ComponentUtils:releaseAction("UIGuideReward")
    self._uiSkin:finalize()
end

function UIGuideReward:hide()
    self._eventSender:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20301, {})
    TimerManager:addOnce(30, self.finalize, self)
end

function UIGuideReward:initPanel()
    self:initReardPanel()
    --self:addHead()
    -- local  function callbackVisible()
    --     for index=1, 4 do
    --         local iconContainer = self:getChildByName("mainPanel/rewardPanel/iconContainer" .. index)
    --         iconContainer:setVisible(true)
    --     end
    -- end
    --ComponentUtils:playAction("UIGuideReward","xinshoulibao",callbackVisible)
end

function UIGuideReward:initReardPanel()
    local rewardList = {}
    table.insert(rewardList, {power = 401, typeid = 1001, num = 1})
    table.insert(rewardList, {power = 401, typeid = 1010, num = 1})
    table.insert(rewardList, {power = 401, typeid = 1019, num = 1})
    table.insert(rewardList, {power = 401, typeid = 4014, num = 3})
    
    for index=1, 4 do
        local iconContainer = self:getChildByName("mainPanel/rewardPanel/iconContainer" .. index)
        -- iconContainer:setVisible(false)
        local icon = UIIcon.new(iconContainer, rewardList[index], true, nil, nil, true)
    end
end

function UIGuideReward:addHead()
    --local headPanel = self:getChildByName("mainPanel/headPanel")
    --local spineModel = SpineModel.new(10003, headPanel)
    --spineModel:playAnimation("animation", true)
    --self._spineModel = spineModel
end

function UIGuideReward:registerEvent()
    local rewardBtn = self:getChildByName("mainPanel/rewardBtn")
    ComponentUtils:addTouchEventListener(rewardBtn, self.onRewardBtnTouch, nil, self)
end

function UIGuideReward:onRewardBtnTouch(sender)
    --TODO 领取奖励
    self._eventSender:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20301, {})
    TimerManager:addOnce(30, self.finalize, self)
end

function UIGuideReward:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end









