
MapSearchPanel = class("MapSearchPanel", BasicPanel)
MapSearchPanel.NAME = "MapSearchPanel"


MapSearchPanel.UnselectBtnUrl = "images/newGui9Scale/SpTab1.png"
MapSearchPanel.SelectBtnUrl = "images/newGui9Scale/SpTab2.png"


function MapSearchPanel:ctor(view, panelName)
    -- MapSearchPanel.super.ctor(self, view, panelName, 700)
    local layer = view:getLayer(ModuleLayer.UI_3_LAYER)
    -- MapSearchPanel.super.ctor(self, view, panelName, 885, layer)
    MapSearchPanel.super.ctor(self, view, panelName, 700, layer)
    
    self:setUseNewPanelBg(true)
end

function MapSearchPanel:finalize()
    MapSearchPanel.super.finalize(self)
end

function MapSearchPanel:initPanel()
	MapSearchPanel.super.initPanel(self)
	self:setTitle(true, self:getTextWord(314))
    self._listView = self:getChildByName("mainPanel/listView")
    self._conf = ConfigDataManager:getConfigData(ConfigData.ResourceConfig)
    self._pointConf = ConfigDataManager:getConfigData(ConfigData.ResourcePointConfig)

    for i=1,2 do
        local btn = self:getChildByName("mainPanel/btn"..i)
        local img = btn:getChildByName("img")
        btn.index = i - 1
        self:addTouchEventListener(btn, self.updateView)
    end
end

function MapSearchPanel:onShowHandler()
    local mapPanel = self:getPanel(MapPanel.NAME)
    local reqTileX, reqTileY = mapPanel:getCurTilePos()
--    if self._listView then
--        self._listView:jumpToPercentVertical(0.1)
--        TimerManager:addOnce(100, self.jumpAndJump, self)
--    end
    self._listView:jumpToTop()
    self._reqTileX = reqTileX
    self._reqTileY = reqTileY
    self:searchReq(reqTileX, reqTileY)
end

function MapSearchPanel:jumpAndJump()
    --self._listView:scrollToTop(0.1, true)
end

function MapSearchPanel:updateTileInfos(tileInfos)

    for j=0,1 do
        self["info"..j] = {}
        
    end
    for i=1,#tileInfos do
        local v = tileInfos[i]
        if self["info" .. v.type] ~= nil then
            table.insert(self["info" .. v.type], v)
        end
    end

    self.curIndex = self.curIndex or 0

    local btn = self:getChildByName("mainPanel/btn" .. (self.curIndex + 1))
    btn.index = self.curIndex
    self:updateView(btn)
end


--[[
        required int32 x = 1; //矿点或者玩家的x坐标
        required int32 y = 2; //矿点或者玩家的y坐标
        required int32 iconId = 3; //矿点的读表id或者玩家的头像id
        optional string playerName = 4; //是玩家的时候发玩家名，矿点不用发
        optional int32 level = 5; //是玩家的时候发玩家等级，矿点不用发
        required int32 time = 6; //抵达时间
        optional int32 devValue = 7; //是玩家的时候，发玩家的繁荣度
        required int32 type = 8; //0代表玩家，1代表矿点
        optional int32 devLimit=9;//是玩家的时候，发玩家的繁荣度上限
]]
function MapSearchPanel:renderItemPanel(itemPanel, tileInfo)
    if itemPanel == nil or tileInfo == nil then
        logger:error("itemPanel == nil or tileInfo == nil >> %s", debug.traceback())
        return
    end

    itemPanel:setVisible(true)
    local infoTxt = itemPanel:getChildByName("infoTxt")
    local labLv = itemPanel:getChildByName("labLv")
    local timeTxt = itemPanel:getChildByName("timeTxt")
    local bar = itemPanel:getChildByName("bar")
    local watchBtn = itemPanel:getChildByName("watchBtn")
    local icon = itemPanel:getChildByName("icon")
    local iconResource = itemPanel:getChildByName("iconResource")
    watchBtn.tileInfo = tileInfo
    self:addTouchEventListener(watchBtn, self.onWatchBtnTouch)

    bar:setVisible(tileInfo.type == 0)
    icon:setVisible(tileInfo.type == 0)
    iconResource:setVisible(tileInfo.type ~= 0)
    local name = ""
    if tileInfo.type == 0 then
        -- name = "Lv." .. tileInfo.level .. " " .. tileInfo.playerName
        name =  tileInfo.playerName
        local percent = tileInfo.devValue/tileInfo.devLimit*100
        percent = percent > 100 and 100 or percent
        percent = percent < 0 and 0 or percent
        local ProgressBar = bar:getChildByName("ProgressBar")
        ProgressBar:setPercent(percent)

        local txtProgress = bar:getChildByName("txtProgress")
        txtProgress:setString(tileInfo.devValue .. "/" .. tileInfo.devLimit)

        labLv:setString("Lv." .. tileInfo.level)
        labLv:setVisible(true)

        local headInfo = {}
        headInfo.icon = tileInfo.iconId
        headInfo.pendant = 100
        headInfo.preName1 = "headIcon"
        headInfo.preName2 = "headPendant"
        headInfo.isCreatPendant = true
        --headInfo.isCreatButton = false
        headInfo.playerId = rawget(tileInfo, "playerId")

        local head = itemPanel.head
        if head == nil then
            head = UIHeadImg.new(icon,headInfo,self)
            itemPanel.head = head
        else
            head:updateData(headInfo)
        end
    else
        local config = ConfigDataManager:getConfigById(ConfigData.ResourcePointConfig, tileInfo.iconId)
--        print("tileInfo.iconId：：："..tileInfo.iconId)
--        print("config.icon：：："..config.icon)
        name = config.name
        labLv:setVisible(false)
        local url = string.format("images/map/res%d.png", config.icon)
        TextureManager:updateImageView(iconResource, url)
    end
    infoTxt:setString(name)
    NodeUtils:alignNodeL2R(infoTxt,labLv)

    local time = TimeUtils:getStandardFormatTimeString6(tileInfo.time)
    timeTxt:setString(" " .. time)

end

function MapSearchPanel:updateView(sender)
    local index = sender.index
    
    if index == nil or self["info"..index] == nil or self._listView == nil then
        logger:error(" index == %d >> %s", index, debug.traceback())
        return
    end

    -- if index == self.curIndex then
    --     return
    -- end
    -- local img = sender:getChildByName("img")
    -- img:setVisible(true)
    TextureManager:updateButtonNormal(sender, MapSearchPanel.SelectBtnUrl, MapSearchPanel.SelectBtnUrl)
    sender:setTitleColor(ColorUtils.commonColor.c3bWhite)
    
    local otherIndex = math.abs(index - 1) + 1
    local otherbtn = self:getChildByName("mainPanel/btn" .. otherIndex)
    TextureManager:updateButtonNormal(otherbtn, MapSearchPanel.UnselectBtnUrl, MapSearchPanel.UnselectBtnUrl)
    otherbtn:setTitleColor(ColorUtils.commonColor.c3bMiaoShu)
    self.curIndex = index

    -- 附近资源点页面，进行排序 201 ~ 205 银铁木石粮
    if self.curIndex == 1 then
        table.sort(self["info"..index],
        function(item01, item02)
            local icon01 = ConfigDataManager:getConfigById(ConfigData.ResourcePointConfig, item01.iconId).icon
            local icon02 = ConfigDataManager:getConfigById(ConfigData.ResourcePointConfig, item02.iconId).icon
            return icon01 < icon02
        end)
    end
    self:renderListView(self._listView, self["info"..index], self, self.renderItemPanel)
end

function MapSearchPanel:onWatchBtnTouch(sender)
    local tileInfo = sender.tileInfo
    local x , y =  tileInfo.x, tileInfo.y
    
    local mapPanel = self:getPanel(MapPanel.NAME)
    mapPanel:gotoTileXY(x , y)

    self:hide()
end

function MapSearchPanel:registerEvents()
	MapSearchPanel.super.registerEvents(self)
	
	local changeBtn = self:getChildByName("mainPanel/changeBtn")
    self:addTouchEventListener(changeBtn, self.onChangeBtnTouche)
end

function MapSearchPanel:onChangeBtnTouche(sender)
    self:searchReq(self._reqTileX, self._reqTileY, 1)
end

function MapSearchPanel:searchReq(x, y, opt)
    opt = opt or 0
    self:dispatchEvent(MapEvent.WORLD_NEAR_SEARCH_REQ, {x = x, y = y, opt = opt})
end
