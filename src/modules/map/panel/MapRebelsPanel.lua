
MapRebelsPanel = class("MapRebelsPanel", BasicPanel)
MapRebelsPanel.NAME = "MapRebelsPanel"

function MapRebelsPanel:ctor(view, panelName)
    local layer = view:getLayer(ModuleLayer.UI_TOP_LAYER)
    MapRebelsPanel.super.ctor(self, view, panelName, 520, layer)
    
    self:setUseNewPanelBg(true)
end

function MapRebelsPanel:finalize()
    MapRebelsPanel.super.finalize(self)
end

function MapRebelsPanel:initPanel()
    MapRebelsPanel.super.initPanel(self)

    self:setTitle(true, self:getTextWord(401200))

    -- 按钮
    self.btnFight = self:getChildByName("panelMain/btnFight")
    self:addTouchEventListener(self.btnFight, self.onFight)
end

function MapRebelsPanel:registerEvents()
    MapRebelsPanel.super.registerEvents(self)
end

function MapRebelsPanel:onShowHandler(rebelsTileInfo)

    -- local rebelInfo = self._rebelsTileInfo.rebelInfo

    self._rebelsTileInfo = rebelsTileInfo
    self:renderInfo()

    self:dispatchEvent(MapEvent.MARCH_TIME_REQ, { x = self._rebelsTileInfo.x, y = self._rebelsTileInfo.y })
end

function MapRebelsPanel:renderInfo()

    local rebelInfo = self._rebelsTileInfo.rebelInfo

    -- 叛军生成配置表
    local rebelsDesignData = ConfigDataManager:getInfoFindByOneKey(ConfigData.ArmyGoDesignConfig, "monsterType", rebelInfo.rebelArmyType)


    -- 叛军奖励配置表
    local function checkData(armyGoMonsterData)
        local minAndMax = StringUtils:jsonDecode(armyGoMonsterData.monsterFightInterval)
        return armyGoMonsterData.monsterGround == rebelsDesignData.monsterGround and minAndMax[1] < rebelInfo.capacity and rebelInfo.capacity < minAndMax[2]
    end
    local rebelsMonsterData = ConfigDataManager:getInfoFindByFunc(ConfigData.ArmyGoMonsterConfig, checkData);

    -- 叛军图片
    self.imgHead = self:getChildByName("panelMain/imgHead")
    TextureManager:updateImageView(self.imgHead, "images/map/rebels" .. rebelInfo.rebelArmyType .. ".png")

    -- 名称
    local labLvAndName = self:getChildByName("panelMain/labLvAndName")
    labLvAndName:setString("Lv." .. rebelInfo.level .. "  " .. rebelsDesignData.monsterName)

    -- 生命
    local barHp = self:getChildByName("panelMain/panelHp/barHp")
    barHp:setPercent(rebelInfo.nowHp)

    local labHp = self:getChildByName("panelMain/panelHp/labHp")
    labHp:setString(rebelInfo.nowHp .. "%")

    -- 这个时间需要请求
    local labTime = self:getChildByName("panelMain/labTime")
    labTime:setVisible(false)


    -- 奖励物品
    local itemInfos = { }
    local rewards = StringUtils:jsonDecode(rebelsMonsterData.goRewardShow)
    for _, reward in pairs(rewards) do
        local info = { }
        info.power = reward[1]
        info.typeid = reward[2]
        info.num = reward[3]
        info.isTrue = false
        -- 概率
        info.isShowNum = true
        table.insert(itemInfos, info)
    end

    for i = 1, 4 do
        local imgItem = self:getChildByName("panelMain/panelAwardItem/imgItem" .. i)


        if itemInfos[i] == nil then
            imgItem:setVisible(false)
        else
            imgItem:setVisible(true)
            if imgItem.iconSprite == nil then
                imgItem.iconSprite = UIIcon.new(imgItem, itemInfos[i], itemInfos[i].isShowNum, self, false, true)
            else
                imgItem.iconSprite:updateData(itemInfos[i])
            end
        end
    end

end

function MapRebelsPanel:onFight(sender)

    -- local teamDetail = self:getProxy(GameProxys.TeamDetail)
    -- teamDetail:setEnterTeamDetailType(1)
    local mapRebelsFightPanel = self:getPanel(MapRebelsFightPanel.NAME)
    mapRebelsFightPanel:show(self._rebelsTileInfo)
    self:hide()

    
end

function MapRebelsPanel:setMarchTime(data)
    local labTime = self:getChildByName("panelMain/labTime")
    labTime:setVisible(true)
    local strMarchTime = TimeUtils:getStandardFormatTimeString6(data.time)
    labTime:setString(strMarchTime)
end