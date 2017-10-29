--
-- Author: zlf
-- Date: 2016年8月31日21:11:06
-- 英雄兵法主界面

HeroStrategicsUpPanel = class("HeroStrategicsUpPanel", BasicPanel)
HeroStrategicsUpPanel.NAME = "HeroStrategicsUpPanel"

function HeroStrategicsUpPanel:ctor(view, panelName)
    HeroStrategicsUpPanel.super.ctor(self, view, panelName, 400)
    self.proxy = self:getProxy(GameProxys.Hero)
    
    self:setUseNewPanelBg(true)
end

function HeroStrategicsUpPanel:finalize()
    for i=1,4 do
        if self["icon"..i].uiIcon ~= nil then
            self["icon"..i].uiIcon:finalize()
            self["icon"..i].uiIcon = nil
        end
    end

    if self.uiRechargePanel ~= nil then
        self.uiRechargePanel:finalize()
        self.uiRechargePanel = nil
    end

    HeroStrategicsUpPanel.super.finalize(self)
end

function HeroStrategicsUpPanel:initPanel()
	HeroStrategicsUpPanel.super.initPanel(self)
    self:setTitle(true, "兵法升级")
    self:setLocalZOrder(PanelLayer.UI_Z_ORDER_1)
    
    self.lvLab = self:getChildByName("Panel_16/bgImg/lvLab")
    self.nameLab = self:getChildByName("Panel_16/bgImg/nameLab")
    self.descLab1 = self:getChildByName("Panel_16/bgImg/Label_11_1")
    self.descLab2 = self:getChildByName("Panel_16/bgImg/Label_11_2")
    self.lab1 = self:getChildByName("Panel_16/bgImg/attackLab")
    self.lab2 = self:getChildByName("Panel_16/bgImg/hpLab")

    local Image_bg = self:getChildByName("Panel_16/bgImg")
    -- TextureManager:updateImageView(Image_bg, "images/guiScale9/Frame_item_bg.png")

    local bgImg1 = Image_bg:getChildByName("bgImg1")
    TextureManager:updateImageView(bgImg1, "images/guiScale9/Frame_item_bg.png")

    self.sendBtn = self:getChildByName("Panel_16/bgImg/sendBtn")
    for i=1,4 do
        self["icon"..i] = self:getChildByName("Panel_16/bgImg/iconImg"..i)
    end
    self.iconImg = self:getChildByName("Panel_16/bgImg/iconImg")
end

function HeroStrategicsUpPanel:registerEvents()
end

function HeroStrategicsUpPanel:onShowHandler(data)
    self.curId = data.bfData.ID
    self.curHeroId = data.heroData.heroDbId
    local itemProxy = self:getProxy(GameProxys.Item)
    if self.iconImg.img == nil then
        self.iconImg.img = ccui.ImageView:create()
        local size = self.iconImg:getContentSize()
        self.iconImg.img:setPosition(size.width*0.5, size.height*0.5)
        self.iconImg:addChild(self.iconImg.img)
    end

    local heroData = data.heroData
    local bfData = data.bfData
    local strategicsInfo = {}

    local baseData = {}

    for k,v in pairs(heroData.strategicsInfo) do
        strategicsInfo[v.strategicsId] = v.strategicsLv
    end

    local roleProxy = self:getProxy(GameProxys.Role)
    local comNum = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)
    --算出这一级的加成，属于基础加成
    local nowLevel = strategicsInfo[bfData.ID]
    local config = ConfigDataManager:getInfoFindByTwoKey(ConfigData.StrategicsLvConfig, "StrategicsID", bfData.ID, "lv", nowLevel)
    local addData = StringUtils:jsonDecode(config.property)
    for k,v in pairs(addData) do
        baseData[v[1]] = baseData[v[1]] or 0
        baseData[v[1]] = baseData[v[1]] + v[2]*comNum
    end

    --拿下一级的表，拿下一级的加成减去这一集的加成  乘以带兵量   93行的baseAdd  和  111行的 ((v[2] - baseAdd[2])*comNum)  说明问题
    local nextData = ConfigDataManager:getInfoFindByTwoKey(ConfigData.StrategicsLvConfig, "StrategicsID", bfData.ID, "lv", nowLevel + 1)
    local addInfo = StringUtils:jsonDecode(nextData.property)
    for k,v in pairs(addInfo) do
        local baseAdd = addData[k]

        self["lab"..k]:setString("")
        local nameInfo = ConfigDataManager:getConfigById(ConfigData.ResourceConfig, v[1])
        self["descLab"..k]:setString(nameInfo.name)
        local size = self["descLab"..k]:getContentSize()
        local x = self["descLab"..k]:getPositionX()
        self["lab"..k]:setPositionX(x + size.width + 8)

        if self["lab"..k].richLab == nil then
            self["lab"..k].richLab = ComponentUtils:createRichLabel("", nil, nil, 2)
            self["lab"..k]:getParent():addChild(self["lab"..k].richLab)
        end

        local x, y = self["lab"..k]:getPosition()
        self["lab"..k].richLab:setPosition(x, y)


        local text = {{{baseData[v[1]], 20},{" +"..  ((v[2] - baseAdd[2])*comNum), 20, ColorUtils.wordColorDark1603}}}

        self["lab"..k].richLab:setString(text)

    end

    TextureManager:updateImageView(self.iconImg.img, string.format("images/heroWarcraft/%d.png", bfData.ID))

    local isEnough = {}
    local needData = StringUtils:jsonDecode(config.lvupneed)

    for i=1,4 do
        local icon = self["icon"..i]
        local haveLab = icon:getChildByName("haveLab")
        local needLab = icon:getChildByName("needLab")
        haveLab:setLocalZOrder(10)
        needLab:setLocalZOrder(10)
        icon:setVisible(needData[i] ~= nil)
        if needData[i] ~= nil then
            local iconData = {}
            local haveNum = itemProxy:getItemNumByType(needData[i][2])
            iconData.typeid = needData[i][2]
            iconData.power = needData[i][1]
            iconData.num = haveNum

            if haveNum < needData[i][3] then
                isEnough[needData[i][2]] = needData[i][3] - haveNum
            end
            
            local color = haveNum >= needData[i][3] and cc.c3b(0, 255, 0) or cc.c3b(255, 0, 0)
            haveLab:setColor(color)
            haveLab:setString(haveNum)
            needLab:setString("/"..needData[i][3])
            if icon.uiIcon == nil then
                icon.uiIcon = UIIcon.new(icon, iconData, false, self, nil, true)
            else
                icon.uiIcon:updateData(iconData)
            end
        end
    end


    self.nameLab:setString(bfData.name)
    self.lvLab:setString("Lv."..strategicsInfo[bfData.ID])


    self.sendBtn.data = data
    self.sendBtn.otherData = isEnough
    self:addTouchEventListener(self.sendBtn, self.sendLevelUpReq)
end

function HeroStrategicsUpPanel:sendLevelUpReq(sender)
    
    local function buy()
        local data = sender.data
        local sendData = {}
        sendData.heroId = data.heroData.heroDbId
        sendData.strategicsId = data.bfData.ID
        self.proxy:onTriggerNet300003Req(sendData)
    end

    local otherData = sender.otherData
    local context = TextWords:getTextWord(290016)
    if table.size(otherData) ~= 0 then
        self.proxy:CommonLvUpEnough(otherData, self, buy, context)
    else
        buy()
    end

    
end

function HeroStrategicsUpPanel:updateView()
    local heroData = self.proxy:getInfoById(self.curHeroId)
    local bfInfo = heroData.strategicsInfo
    local lv = nil
    for k,v in pairs(bfInfo) do
        if v.strategicsId == self.curId then
            lv = v.strategicsLv
            break
        end
    end


    local data = {}
    local configData = ConfigDataManager:getConfigById(ConfigData.StrategicsConfig, self.curId)
    if lv >= configData.lvmax then
        self:showSysMessage("兵法已升至满级")
        self:hide()
        return
    end
    data.heroData = heroData
    data.bfData = configData
    self:onShowHandler(data)
end