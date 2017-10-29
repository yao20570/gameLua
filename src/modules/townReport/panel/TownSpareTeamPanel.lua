TownSpareTeamPanel = class("TownSpareTeamPanel", BasicPanel)
TownSpareTeamPanel.NAME = "TownSpareTeamPanel"

function TownSpareTeamPanel:ctor(view, panelName)
    local layer = view:getLayer(ModuleLayer.UI_TOP_LAYER)
    TownSpareTeamPanel.super.ctor(self, view, panelName, 700, layer)
end

function TownSpareTeamPanel:finalize()
    TownSpareTeamPanel.super.finalize(self)


end

function TownSpareTeamPanel:initPanel()
    TownSpareTeamPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(471023))

    self._cityWarProxy = self:getProxy(GameProxys.CityWar)
    self._roleProxy = self:getProxy(GameProxys.Role)
end

function TownSpareTeamPanel:registerEvents()
    self._mainPanel = self:getChildByName("mainPanel")
    self._listView = self._mainPanel:getChildByName("listView")


end

function TownSpareTeamPanel:onShowHandler(data)
    self._spareTeamData = data

    self._roleName = self._roleProxy:getRoleName()

    self:onUpdateSpareTeamPanel()
end

-- 
function TownSpareTeamPanel:onUpdateSpareTeamPanel()
    self:renderListView( self._listView, self._spareTeamData, self, self.renderItem, nil, nil, 0)
end

function TownSpareTeamPanel:renderItem(itemImg, data, index)
    
    index = index + 1

    local rankTxt       = itemImg:getChildByName("rankTxt")      
    local nameTxt       = itemImg:getChildByName("nameTxt")      
    local legionNameTxt = itemImg:getChildByName("legionNameTxt")
    local capacityTxt   = itemImg:getChildByName("capacityTxt")  

     
    local sort		 = data.sort		-- 排序
    local playerName = data.playerName  -- 玩家名字
    local legionName = data.legionName  -- 同盟名字
    local capacity   = data.capacity    -- 退伍战力

    rankTxt:setString(sort)      
    nameTxt:setString(playerName)      
    legionNameTxt:setString(legionName)
    capacityTxt:setString( StringUtils:formatNumberByK3(capacity))  
    
    
    -- 颜色
    local bgUrl = "images/newGui9Scale/S9Gray.png"
    if index %2 == 0 then
        bgUrl = "images/newGui9Scale/S9Bg.png"
    end

    
    -- 如果是自己
    if playerName == self._roleName then
        bgUrl = "images/newGui9Scale/S9Self.png"
    end

    TextureManager:updateImageView(itemImg, bgUrl)
end


