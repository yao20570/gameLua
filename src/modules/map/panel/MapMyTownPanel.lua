MapMyTownPanel = class("MapMyTownPanel", BasicPanel)
MapMyTownPanel.NAME = "MapMyTownPanel"
MapMyTownPanel.TOWN_SCALE = 0.8
function MapMyTownPanel:ctor(view, panelName)
    local layer = view:getLayer(ModuleLayer.UI_TOP_LAYER)
    MapMyTownPanel.super.ctor(self, view, panelName, nil, layer)
end

function MapMyTownPanel:finalize()
    MapMyTownPanel.super.finalize(self)


end

function MapMyTownPanel:initPanel()
    MapMyTownPanel.super.initPanel(self)

    self._cityWarProxy = self:getProxy(GameProxys.CityWar)
    self._roleProxy    = self:getProxy(GameProxys.Role)
    
end

function MapMyTownPanel:registerEvents()
    local panelRoot = self:getPanelRoot()
    self:addTouchEventListener(panelRoot, self.onTownMsgBtn)

    self._mainPanel = self:getChildByName("mainPanel")
  
    self._mainImg = self._mainPanel:getChildByName("mainImg")
    self._listView = self._mainImg:getChildByName("listView")

    self._townMsgBtn = self._mainPanel:getChildByName("townMsgBtn")
    self:addTouchEventListener(self._townMsgBtn, self.onTownMsgBtn)

    self._countTipTxt = self._mainImg:getChildByName("countTipTxt")
    self._remainTxt   = self._mainImg:getChildByName("remainTxt")
    self._maxTxt      = self._mainImg:getChildByName("maxTxt")
end

function MapMyTownPanel:onShowHandler(data)
    -- 发送消息号
    self._cityWarProxy:onTriggerNet470006Req({})

    self._mainImg:setScale(0.1)
    self._listView:setVisible(false)

    local mainPanel = self._mainImg
    mainPanel:stopAllActions()
    mainPanel:runAction(cc.Sequence:create(cc.ScaleTo:create(0,0),cc.DelayTime:create(0.2),cc.ScaleTo:create(0.2,1)))

    -- 按钮红点
    self:updateMyTownRedPoint()
end

function MapMyTownPanel:onTownMsgBtn()

    local function lastCallback()
        self:hide()
    end

    self._mainImg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,0),cc.CallFunc:create(lastCallback)))     
end

--刷新郡城自己的红点
function MapMyTownPanel:updateMyTownRedPoint()
    local redImg = self._townMsgBtn:getChildByName("redImg")
    local numLab = redImg:getChildByName("numLab")
    local num = self._cityWarProxy:getMyTownRedPoint()
    redImg:setVisible(num ~= 0)
    numLab:setString(num)
end

------
-- M470006 resp回调刷新
function MapMyTownPanel:onUpdateMyTownPanel()
    self._listView:setVisible(true)
    self._townData = self._cityWarProxy:getTownInfoList()
    self:setRemainTimesShow()
    -- 0未开放1可宣战时期2宣战（可派兵）期间3开战期间4保护期间5休战期间
    -- 宣战期2＞开战期3＞归属期＞保护期4＞休战期5，同状态则按sort字段
    local function getLevel(townStatus)
        local level = 0
        if townStatus == 2 then
            level = 1
        elseif townStatus == 3 then
            level = 2
        elseif townStatus == 4 then
            level = 4
        elseif townStatus == 5 then
            level = 5
        else
            level = 3
        end
        return level
    end

    table.sort(self._townData,
    function(item1, item2)
        local level1 = getLevel(item1.townStatus)
        local level2 = getLevel(item2.townStatus)

        if level1 == level2 then
            return item1.townId < item2.townId
        else
            return level1 < level2
        end
    end)

    self:renderListView(self._listView, self._townData, self, self.renderItem, nil, nil, 2)
end

-- 渲染itemPanel
function MapMyTownPanel:renderItem(itemImg, data, index)
    local nameTxt  = itemImg:getChildByName("nameTxt") 
    local posTxt   = itemImg:getChildByName("posTxt")  
    local stateImg = itemImg:getChildByName("stateImg")
    local townImg  = itemImg:getChildByName("townImg")

    local configInfo = ConfigDataManager:getConfigById(ConfigData.TownWarConfig, data.townId) -- 

    nameTxt:setString(configInfo.stateName)
    posTxt:setString( string.format("(%s, %s)",data.x , data.y))
    NodeUtils:fixTwoNodePos(nameTxt, posTxt, 3)

    local imgUrl = string.format("images/miniMapIcon/btnCityNormal%d.png", configInfo.cityIcon )
    TextureManager:updateImageView(townImg, imgUrl)

    local stateUrl = string.format("images/map/font_town_state%d.png", data.townStatus)
    TextureManager:updateImageView(stateImg, stateUrl)


    itemImg.data = data
    self:addTouchEventListener(itemImg, self.onItemImg)


end

------
-- 点击前往州城
function MapMyTownPanel:onItemImg(sender)
    local data = sender.data

    local mapPanel = self:getPanel(MapPanel.NAME)
    mapPanel:gotoTileXY(data.x, data.y)

    -- 关闭界面
    self:onTownMsgBtn()
end

------
-- 设置次数
function MapMyTownPanel:setRemainTimesShow()
    
    if self._roleProxy:getLegionName() == "" then
        self._countTipTxt:setString(self:getTextWord(915))
        self._remainTxt:setString("")
        self._maxTxt:setString("")
    else
        local curTimes = self._cityWarProxy:getWarOnRemainTimes()
        local maxTimes = self._cityWarProxy:getWarOnMaxTimes()
        self._remainTxt:setString(curTimes)
        self._maxTxt:setString("/"..maxTimes)
        if curTimes == 0 then
            self._remainTxt:setColor(ColorUtils.wordBadColor)
        else
            self._remainTxt:setColor(ColorUtils.wordGreenColor)
        end

        NodeUtils:fixTwoNodePos(self._remainTxt, self._maxTxt)

        self._countTipTxt:setString(self:getTextWord(550035)) -- 今日剩余宣战次数：
    end

end