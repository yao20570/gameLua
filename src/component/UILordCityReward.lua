UILordCityReward = class("UILordCityReward")

function UILordCityReward:ctor(panel)
    self._uiSkin = UISkin.new("UILordCityReward")
    self._uiSkin:setParent(panel)
    self._panel = panel

    self:init()
    self:registerEvents()

end


function UILordCityReward:finalize()
    UILordCityReward.super.finalize(self)
end

function UILordCityReward:init()
    self._lordCityProxy = self._panel:getProxy(GameProxys.LordCity)

    local config = ConfigDataManager:getConfigData(ConfigData.CityGuessConfig)
    self._joinReward = ConfigDataManager:getRewardsByJson(config[1].failReward)

    self:onInitItem()

    self._joinRewardBtn = self._uiSkin:getChildByName("mainPanel/itemPanel1/joinRewardBtn")
end


function UILordCityReward:registerEvents()
    self._panel:addTouchEventListener(self._joinRewardBtn, self.onJoinRewardBtnTouch, nil, self)
end

function UILordCityReward:onClosePanelHandler()
    self._panel:hide()
end

-- 初始化显示空图
function UILordCityReward:onInitItem()
    local function renderCall(type)
        for i = 1, 4 do
            local itemPanel = self._uiSkin:getChildByName("mainPanel/itemPanel" .. type .. "/iconImg" .. i)
            if itemPanel then
                TextureManager:updateImageView(itemPanel, "images/newGui1/none.png")
            end
        end
    end
    renderCall(1)
end

function UILordCityReward:onLordCityRewardUpdate()

    local function renderCall(config, type)
        for i = 1, table.size(config) do
            local itemPanel = self._uiSkin:getChildByName("mainPanel/itemPanel" .. type .. "/iconImg" .. i)
            if itemPanel then
                self:renderItem(itemPanel, config[i])
            end
        end
    end
    renderCall(self._joinReward, 1)

    self:onVoteRewardUpdate()
end

function UILordCityReward:renderItem(itemPanel, info)
    if itemPanel == nil or info == nil then
        return
    end
    local iconUI = itemPanel.iconUI
    if iconUI == nil then
        iconUI = UIIcon.new(itemPanel, info, true, self._panel)
        itemPanel.iconUI = iconUI
    end
    iconUI:updateData(info)

end

function UILordCityReward:onJoinRewardBtnTouch(sender)
    local data = { }
    data.cityId = self._lordCityProxy:getSelectCityId()
    self._lordCityProxy:onTriggerNet360018Req(data)
    self._panel:onClosePanelHandler()
end

-- 领取按钮状态显示
function UILordCityReward:onVoteRewardUpdate()
    local state = self._lordCityProxy:getVoteRewardState() or 0
    if state > 0 then
        -- 已领取
        self._joinRewardBtn:setTitleText(self._panel:getTextWord(370031))
        NodeUtils:setEnable(self._joinRewardBtn, false)
    else
        -- 未领取
        self._joinRewardBtn:setTitleText(self._panel:getTextWord(370032))
        NodeUtils:setEnable(self._joinRewardBtn, true)
    end
end


