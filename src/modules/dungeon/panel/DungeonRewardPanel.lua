-- -------------------------------------------------------------------------------
-- 副本宝箱奖励弹窗
-- -------------------------------------------------------------------------------
DungeonRewardPanel = class("DungeonRewardPanel", BasicPanel)
DungeonRewardPanel.NAME = "DungeonRewardPanel"

function DungeonRewardPanel:ctor(view, panelName)
    DungeonRewardPanel.super.ctor(self, view, panelName, 400)

    self:setUseNewPanelBg(true)
end

function DungeonRewardPanel:finalize()
    DungeonRewardPanel.super.finalize(self)
end

function DungeonRewardPanel:initPanel()
    DungeonRewardPanel.super.initPanel(self)
    self:setTitle(true,self:getTextWord(200108))
    self:setLocalZOrder(2)

    self._rewardPanel = self:getChildByName("mainPanel")
    self._rewardBtn = self._rewardPanel:getChildByName("rewardBtn")
    self._countLb = self._rewardPanel:getChildByName("countLb")
    self._iconImg = self._rewardPanel:getChildByName("iconImg")

end

function DungeonRewardPanel:registerEvents()
    DungeonRewardPanel.super.registerEvents(self)
end

function DungeonRewardPanel:onClosePanelHandler()
    -- body
    self:hide()
end

function DungeonRewardPanel:onShowHandler(info)
    self:onShowRewardPanel(info)
end

function DungeonRewardPanel:onShowRewardItem(info)
    local children = self._rewardPanel:getChildren()
    for k,child in pairs(children) do
        local name = child:getName()
        if string.find(name,"iconImg_") then
            child:setVisible(false)  --已有的icon先隐藏
        end
    end

    local itemList = {}
    local function showItem(info,k)
        local name = "iconImg_"..k
        local iconImg = self._rewardPanel:getChildByName(name)
        if iconImg == nil then
            -- print("... clone new one :",name)
            iconImg = self._iconImg:clone()
            iconImg:setName(name)
            self._rewardPanel:addChild(iconImg)
        end
        itemList[k] = iconImg
        iconImg:setVisible(true)  --显示

        local iconS = iconImg.iconS
        if iconS == nil then
            iconS = UIIcon.new(iconImg,info,true,self,nil,true)
            iconImg.iconS = iconS
        else
            iconS:updateData(info)
        end
    end

    
    -- 支持显示多个icon，并且是居中显示(目测最多可显示5个)

    local rewardId = info.rewardId
    local number = table.size(rewardId)
    local itemInfo
    for k,id in pairs(rewardId) do
        -- print(".. showItem ",k,id)
        itemInfo = ConfigDataManager:getRewardConfigById(id)
        showItem(itemInfo,k)
    end

    --[[
        居中显示多个icon
        icon起始X坐标： 
            initX = mainPanel.x + (mainPanel.width - (icon.Width + dx) * iconNumber + dx) /2
        ps: dx是icon间隔距离,iconNumber是icon数量
    ]]
    local panelSize = self._rewardPanel:getContentSize()
    local panelPosX = self._rewardPanel:getPositionX()
    local iconImg = itemList[1]

    local url = "images/newGui2/Frame_prop_1.png"
    local _,rect = TextureManager:getTextureFile(url)
    local iconSize = rect[3]
    if iconSize == nil then
        iconSize = 86  --容错
    end
    local dx = 20  --dx是icon间隔距离
    iconSize = iconSize + dx

    local initX = panelPosX + (panelSize.width - iconSize * number + dx) / 2
    for k,v in pairs(itemList) do
        v:setPositionX(initX + (k - 1) * iconSize + dx)
    end

end

function DungeonRewardPanel:onShowRewardPanel(info)
    -- self._rewardPanel:setVisible(true)

    self._countLb:setString(self:getTextWord(1202)..info.count)

    -- local icon = self._iconImg.icon
    -- if icon == nil then
    --     icon = UIIcon.new(self._iconImg,info.config,true,self,nil,true)
    --     self._iconImg.icon = icon
    -- else
    --     icon:updateData(info.config)
    -- end

    self:onShowRewardItem(info)

    NodeUtils:setEnable(self._rewardBtn, false)
    if info.status == 1 then --1,未开启，2已领取 3，未领取
        self._rewardBtn:setTitleText(self:getTextWord(18003))
        return
    elseif info.status == 2 then
        self._rewardBtn:setTitleText(self:getTextWord(18000))
        return
    elseif info.status == 3 then
        NodeUtils:setEnable(self._rewardBtn, true)
        self._rewardBtn:setTitleText(self:getTextWord(18001))
    end
    
    local data = {}
    data.boxNum = info.index
    data.dungeoId = info.dungeoId
    self._rewardBtn.data = data

    if self._rewardBtn.isAddEvent ~= true then
        self._rewardBtn.isAddEvent = true
        self:addTouchEventListener(self._rewardBtn, self.onRewardBtnTouch)
        self["rewardBtn"] = self._rewardBtn
    end
end

function DungeonRewardPanel:onRewardBtnTouch(sender)
    -- body
    self:dispatchEvent(DungeonEvent.GET_REWARD_REQ,sender.data)
    self:onClosePanelHandler()
end

