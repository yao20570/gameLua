UIRankToRewardPanel = class("UIRankToRewardPanel")
------
-- @param  panel [obj] 界面
-- @param  callback [func] 点击领取的回调函数
function UIRankToRewardPanel:ctor(panel, callback)
    local uiSkin = UISkin.new("UIRankToRewardPanel")
    
    uiSkin:setParent(panel:getParent())


    self._uiSkin = uiSkin
    self._uiSkin:setLocalZOrder(PanelLayer.UI_Z_ORDER_11)
    self._panel = panel
    self._parent = parent


    local secLvBg = UISecLvPanelBg.new(self._uiSkin:getRootNode(), self)
    self._secLvBg = secLvBg
    secLvBg:setBackGroundColorOpacity(120)
    secLvBg:setTitle(TextWords:getTextWord(1325)) -- "奖励信息"
    secLvBg:setContentHeight(700)
    
    -- 领取按钮回调函数
    self._getCallback = callback

    self:registerEvents()
end


function UIRankToRewardPanel:registerEvents()
    local mainPanel = self._uiSkin:getChildByName("mainPanel")

    self._listView = mainPanel:getChildByName("listview")
    self._getBtn = mainPanel:getChildByName("getBtn")

    ComponentUtils:addTouchEventListener(self._getBtn, self.onGetBtn, nil,self)
end

function UIRankToRewardPanel:finalize()
    self._uiSkin:finalize()
end

function UIRankToRewardPanel:hide()
    TimerManager:addOnce(1, self.finalize, self)
end


function UIRankToRewardPanel:setRewardList(listData)
    
    ComponentUtils:renderListView(self._listView, listData, self, self.renderItem, nil, nil, 0)
end



function UIRankToRewardPanel:renderItem(itemPanel, data, index)

    local rankStr = ""
    if data.ranking == data.rankingii then
        rankStr = string.format(TextWords:getTextWord(250027), data.ranking)
    else
        rankStr = string.format(TextWords:getTextWord(250028), data.ranking, data.rankingii)
    end
    
    local indexTxt = itemPanel:getChildByName("index_label")
    indexTxt:setString(rankStr)

    local rewardData = StringUtils:jsonDecode(data.reward)
    for i = 1, 4 do
        local itemImg = itemPanel:getChildByName("itemImg"..i)
        if rewardData[i] == nil then
            itemImg:setVisible(false)
        else
            itemImg:setVisible(true)
            local iconData  = {}
            iconData.power  = rewardData[i][1]
            iconData.typeid = rewardData[i][2]
            iconData.num    = rewardData[i][3]

            if itemImg.uiIcon == nil then
                itemImg.uiIcon = UIIcon.new(itemImg, iconData, true, self, nil, true)
                itemImg.uiIcon:setTouchEnabled(false) 
            else
                itemImg.uiIcon:updateData(iconData)
            end
        end


    end
end



-- 设置按钮状态
function UIRankToRewardPanel:setRewardBtnState(state)
    if state == 1 then
        self._getBtn:setTitleText(TextWords:getTextWord(230144))
        NodeUtils:setEnable(self._getBtn, true)
    elseif state == 2 then
        self._getBtn:setTitleText(TextWords:getTextWord(230143))
        NodeUtils:setEnable(self._getBtn, false)
    else
        self._getBtn:setTitleText(TextWords:getTextWord(18003))
        NodeUtils:setEnable(self._getBtn, false)
    end
end


function UIRankToRewardPanel:onGetBtn(sender)
    if self._getCallback ~= nil then
        self._getCallback(self._panel)
    end
end

function UIRankToRewardPanel:setBtnVisible(isVisible)
    self._getBtn:setVisible(isVisible)
end














