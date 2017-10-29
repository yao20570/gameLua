-- /**
--  * @Author:      wzy
--  * @DateTime:    2016-11-30 14:16:00
--  * @Description: 叛军活动信息
--  */
RebelsInfoPanel = class("RebelsInfoPanel", BasicPanel)
RebelsInfoPanel.NAME = "RebelsInfoPanel"

function RebelsInfoPanel:ctor(view, panelName)
    RebelsInfoPanel.super.ctor(self, view, panelName)

end

function RebelsInfoPanel:finalize()
    RebelsInfoPanel.super.finalize(self)
end

function RebelsInfoPanel:initPanel()
    RebelsInfoPanel.super.initPanel(self)

    self._proxy = self:getProxy(GameProxys.Rebels)

    -- info面板
    self._panelInfor = self:getChildByName("panelInfor")
    self._labState = self._panelInfor:getChildByName("labState")
    self._labRemainingTime = self._panelInfor:getChildByName("labRemainingTime")
    self._labRebelsNum = self._panelInfor:getChildByName("labRebelsNum")
    self._labKillNum = self._panelInfor:getChildByName("labKillNum")
    self._labAppearType = self._panelInfor:getChildByName("labAppearType")
    self._labAppearTime = self._panelInfor:getChildByName("labAppearTime")

    local btnTip = self._panelInfor:getChildByName("btnTip")
    self:addTouchEventListener(btnTip, self.onTip)

    -- 叛军切换按钮面板
    self._panelDetailTab = self:getChildByName("panelDetailTab")
    --self._imgSelectFlag = self._panelDetailTab:getChildByName("imgSelectFlag")
    self._btnRebelsType = { }
    self._btnRebelsImg = { }
    for i = 1, 3 do
        self._btnRebelsType[i] = self._panelDetailTab:getChildByName("btnRebelsType" .. i)
        self._btnRebelsType[i].tag = i
        self:addTouchEventListener(self._btnRebelsType[i], self.onSwitchRebelsList)
        
        self._btnRebelsImg[i] = self._panelDetailTab:getChildByName("img" .. i)
        self._btnRebelsImg[i].tag = i
    end
    

    -- 叛军列表
    self._svRebels = self:getChildByName("svRebels")
    self._ItemUIIndex = 1

    -- 切换到喽啰按钮
    self:switchRebelsButton(RebelsProxy.REBELS_TYPE_1);
    
end

function RebelsInfoPanel:registerEvents()
    RebelsInfoPanel.super.registerEvents(self)
end

function RebelsInfoPanel:doLayout()
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(self._panelInfor, nil, GlobalConfig.downHeight, tabsPanel, 3)
    NodeUtils:adaptiveTopPanelAndListView(self._panelDetailTab, nil, GlobalConfig.downHeight, self._panelInfor, 3)
    NodeUtils:adaptiveListView(self._svRebels, GlobalConfig.downHeight, self._panelDetailTab, 3)

    self:createScrollViewItemUIForDoLayout(self._svRebels)
end

function RebelsInfoPanel:update()
    if self._proxy:isInActivity() == false then
        return
    end

    local strActivityRemainTime = TimeUtils:getStandardFormatTimeString6(self._proxy:getActivityRemainTime())
    self._labRemainingTime:setString(strActivityRemainTime)

    local nextRebelsType, appearRemainTime = self._proxy:getNextRebelsTypeAndAppearRemainTime();
    if appearRemainTime == 0 then
        self._labAppearType:setVisible(false)
        self._labAppearTime:setVisible(false)
    else
        self._labAppearType:setVisible(true)
        self._labAppearTime:setVisible(true)

        if nextRebelsType == RebelsProxy.REBELS_TYPE_2 then
            self._labAppearType:setString(string.format(self:getTextWord(401015), self:getTextWord(401013)))
        else
            self._labAppearType:setString(string.format(self:getTextWord(401015), self:getTextWord(401014)))
        end

        local strAppearTime = TimeUtils:getStandardFormatTimeString6(appearRemainTime)
        self._labAppearTime:setString(strAppearTime)
    end

end

function RebelsInfoPanel:onClosePanelHandler()
    self:dispatchEvent(RebelsEvent.HIDE_SELF_EVENT)
end

function RebelsInfoPanel:onShowHandler()
    local parent = self:getParent()
    if parent.infoPanel ~= nil then
        parent.infoPanel:hide()
    end


    self._proxy:onTriggerNet400000Req( { })

    self._ItemUIIndex = 1

end

function RebelsInfoPanel:updateUI()
    self:updatePanelInfor()
    self:updateRebelsListView(self.curRebelsType)
end


function RebelsInfoPanel:updatePanelInfor()

    local activityInfo = self._proxy:getActivityInfo()
    local maxCount1 = self._proxy:getMaxRebelsCountByType(RebelsProxy.REBELS_TYPE_1)
    local maxCount2 = self._proxy:getMaxRebelsCountByType(RebelsProxy.REBELS_TYPE_2)
    local maxCount3 = self._proxy:getMaxRebelsCountByType(RebelsProxy.REBELS_TYPE_3)

    if self._proxy:isInActivity() == true then
        -- 下一波叛军的类型 和 出现剩余时间
        local nextRebelsType, appearRemainTime = self._proxy:getNextRebelsTypeAndAppearRemainTime();
        if appearRemainTime == 0 then
            self._labAppearType:setVisible(false)
            self._labAppearTime:setVisible(false)
        else
            self._labAppearType:setVisible(true)
            self._labAppearTime:setVisible(true)

            if nextRebelsType == RebelsProxy.REBELS_TYPE_2 then
                self._labAppearType:setString(string.format(self:getTextWord(401015), self:getTextWord(401013)))
            else
                self._labAppearType:setString(string.format(self:getTextWord(401015), self:getTextWord(401014)))
            end

            local strAppearTime = TimeUtils:getStandardFormatTimeString6(appearRemainTime)
            self._labAppearTime:setString(strAppearTime)
        end

        -- 活动状态
        self._labState:setString(self:getTextWord(401007));

        -- 活动剩余时间
        local strActivityTime = TimeUtils:getStandardFormatTimeString6(self._proxy:getActivityRemainTime())
        self._labRemainingTime:setVisible(true)
        self._labRemainingTime:setString(strActivityTime)

        -- 活动里所有叛军的击杀数量
        local killNum1 = self._proxy:getAllKillNumByType(RebelsProxy.REBELS_TYPE_1)
        local killNum2 = self._proxy:getAllKillNumByType(RebelsProxy.REBELS_TYPE_2)
        local killNum3 = self._proxy:getAllKillNumByType(RebelsProxy.REBELS_TYPE_3)
        --self._labRebelsNum:setString(string.format(self:getTextWord(401009), killNum1, maxCount1, killNum2, maxCount2, killNum3, maxCount3))
        self._labRebelsNum:setString("")
        
        if self._labRebelsNum.richLabel == nil then
            self._labRebelsNum.richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
            self._labRebelsNum.richLabel:setPosition(self._labRebelsNum:getPosition())
            self._labRebelsNum:getParent():addChild(self._labRebelsNum.richLabel)
        end
        
        local infoStr = {
            {
            {self:getTextWord(401016), 20, ColorUtils.commonColor.White},{killNum1, 20, ColorUtils.commonColor.BiaoTi},{"/" .. maxCount1 .. ")", 20, ColorUtils.commonColor.White},
            {self:getTextWord(401017), 20, ColorUtils.commonColor.White},{killNum2, 20, ColorUtils.commonColor.BiaoTi},{"/" .. maxCount2 .. ")", 20, ColorUtils.commonColor.White},
            {self:getTextWord(401018), 20, ColorUtils.commonColor.White},{killNum3, 20, ColorUtils.commonColor.BiaoTi},{"/" .. maxCount3 .. ")", 20, ColorUtils.commonColor.White},
            },
        }
        self._labRebelsNum.richLabel:setString(infoStr)

        -- 玩家自己击杀叛军的数量
        self._labKillNum:setString(activityInfo.alreadyKill .. "/" .. self._proxy:getMaxKill())
    else
        self._labAppearType:setVisible(false)
        self._labAppearTime:setVisible(false)
        self._labState:setString(self:getTextWord(401008));
        self._labRemainingTime:setVisible(false)
        --self._labRebelsNum:setString(string.format(self:getTextWord(401009), 0, maxCount1, 0, maxCount2, 0, maxCount3))--喽啰(%d/%d)    头目(%d/%d)    将领(%d/%d)
        self._labKillNum:setString(0 .. "/" .. 0)
        self._labRebelsNum:setString("")
        
        if self._labRebelsNum.richLabel == nil then
            self._labRebelsNum.richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
            self._labRebelsNum.richLabel:setPosition(self._labRebelsNum:getPosition())
            self._labRebelsNum:getParent():addChild(self._labRebelsNum.richLabel)
        end
        
        local infoStr = {
            {
            {self:getTextWord(401016), 20, ColorUtils.commonColor.White},{0, 20, ColorUtils.commonColor.BiaoTi},{"/" .. maxCount1 .. ")", 20, ColorUtils.commonColor.White},
            {self:getTextWord(401017), 20, ColorUtils.commonColor.White},{0, 20, ColorUtils.commonColor.BiaoTi},{"/" .. maxCount2 .. ")", 20, ColorUtils.commonColor.White},
            {self:getTextWord(401018), 20, ColorUtils.commonColor.White},{0, 20, ColorUtils.commonColor.BiaoTi},{"/" .. maxCount3 .. ")", 20, ColorUtils.commonColor.White},
            },
        }
        self._labRebelsNum.richLabel:setString(infoStr)
    end
end

function RebelsInfoPanel:updateRebelsListView(rebelsType)

    local rebelsList = self._proxy:getRebelsList(rebelsType)

    local rolePrxoy = self:getProxy(GameProxys.Role)
    local beginX, beginY = rolePrxoy:getWorldTilePos()
    for k, v in pairs(rebelsList) do
        local time = rolePrxoy:calcNeedTime(RoleProxy.MarchingType_Rebles, beginX, beginY, v.x, v.y)
        --计算并设置到达叛军位置的行军时间
        v.time = time
    end
    --按状态和行军时间排序
    table.sort(rebelsList, function(a, b) return(a.state * 10000000 + a.time) <(b.state * 10000000 + b.time) end)

    self:renderScrollView(self._svRebels, "panelItem", rebelsList, self, self.renderItemUI, self._ItemUIIndex, 6)
    self._ItemUIIndex = nil
end

function RebelsInfoPanel:renderItemUI(item, data, index)

    local rebelsDesignCfg = ConfigDataManager:getInfoFindByOneKey(ConfigData.ArmyGoDesignConfig, "monsterType", data.type)

    -- icon
    local iconBgImg = item:getChildByName("iconBgImg")
    local icon = iconBgImg:getChildByName("icon")
    local url = string.format("images/rebels/%s.png", rebelsDesignCfg.monsterIcon)
    TextureManager:updateImageView(icon, url)

    -- 叛军等级
    local labLevel = item:getChildByName("labLevel")
    if data.level == -1 then
        labLevel:setString("Lv." .. "??")
    else
        labLevel:setString("Lv." .. data.level)
    end

    -- 叛军名称
    local labName = item:getChildByName("labName")
    labName:setString(rebelsDesignCfg.monsterName)

    -- 叛军坐标
    local labTile = item:getChildByName("labTile")
    if data.x == -1 or data.y == -1 then
        labTile:setString("( ??? , ??? )")
    else
        labTile:setString("( " .. data.x .. " , " .. data.y .. " )")
    end

    NodeUtils:alignNodeL2R(labLevel, labName, labTile, 5)

    -- 叛军状态
    local panelAlive = item:getChildByName("panelAlive")
    local progressBarHp = panelAlive:getChildByName("progressBarHp")
    local labMarchTime = panelAlive:getChildByName("labMarchTime")

    local panelDead = item:getChildByName("panelDead")
    local labState = panelDead:getChildByName("labState")
    local labPlayerName = panelDead:getChildByName("labPlayerName")

    if (data.state == RebelsProxy.REBELS_STATE_ALIVE) then
        if self._proxy:isInActivity() == true then
            panelAlive:setVisible(true)
            panelDead:setVisible(false)
            progressBarHp:setPercent(data.nowHp)
            local strAppearTime = TimeUtils:getStandardFormatTimeString6(data.time)
            labMarchTime:setString(strAppearTime)
        else
            panelAlive:setVisible(false)
            panelDead:setVisible(true)
            labState:setString(self:getTextWord(401004))
            labPlayerName:setVisible(false)
        end

    elseif (data.state == RebelsProxy.REBELS_STATE_DEAD) then
        panelAlive:setVisible(false)
        panelDead:setVisible(true)
        labState:setString(self:getTextWord(401005))
        labPlayerName:setVisible(true)
        labPlayerName:setString(data.killerName)

    else
        panelAlive:setVisible(false)
        panelDead:setVisible(true)
        labState:setString(self:getTextWord(401006))
        labPlayerName:setVisible(false)
    end


    -- 集结按钮
    local btnFight = panelAlive:getChildByName("btnFight")
    btnFight.data = data
    btnFight:setVisible(self._proxy:isInActivity())
    self:addTouchEventListener(btnFight, self.onFight)
    NodeUtils:setEnable(btnFight, data.state == 0)


end

-- 切换叛军列表
function RebelsInfoPanel:switchRebelsButton(rebelsType)

    if (self.curRebelsType ~= nil) then
        self._btnRebelsType[self.curRebelsType]:loadTextureNormal("images/rebels/6.png", ccui.TextureResType.plistType)
        self._btnRebelsType[self.curRebelsType]:loadTexturePressed("images/rebels/6.png", ccui.TextureResType.plistType)
    end
    self.curRebelsType = rebelsType
    self._btnRebelsType[self.curRebelsType]:loadTextureNormal("images/rebels/5.png", ccui.TextureResType.plistType)
    self._btnRebelsType[self.curRebelsType]:loadTexturePressed("images/rebels/5.png", ccui.TextureResType.plistType)

    --self._imgSelectFlag:setPositionX(self._btnRebelsType[self.curRebelsType]:getPositionX())
    
    for i = 1, 3 do
        if self.curRebelsType == i then
            TextureManager:updateImageView(self._btnRebelsImg[i], "images/rebels/fontRebelsType" .. i + 3 .. ".png")
        else
            TextureManager:updateImageView(self._btnRebelsImg[i], "images/rebels/fontRebelsType" .. i .. ".png")
        end
    end
    
end

-- 攻击叛军
function RebelsInfoPanel:onFight(sender)

    local rebelsData = sender.data;

    -- 叛军已被消灭
    if rebelsData.state ~= 0 then
        return
    end

    -- 叛军还没生成到地图上
    if rebelsData.x == nil or rebelsData.y == nil then
        return
    end

    -- 跳到世界地图
    self._proxy:goToTile(rebelsData.x, rebelsData.y)
end

-- 切换叛军列表
function RebelsInfoPanel:onSwitchRebelsList(sender)

    --self._imgSelectFlag:setPositionX(sender:getPositionX())

    self:switchRebelsButton(sender.tag)
    
    self._ItemUIIndex = 1

    self:updateRebelsListView(self.curRebelsType)
end

function RebelsInfoPanel:onTip(sender)
    local parent = self:getParent()
    local uiTip = UITip.new(parent)
    local lines = { }
    for i = 0, 8 do
        lines[i] = { { content = TextWords:getTextWord(401400 + i), foneSize = ColorUtils.tipSize20, color = ColorUtils.commonColor.MiaoShu} }
    end
    uiTip:setAllTipLine(lines)
end