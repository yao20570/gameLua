--
-- Author: zlf
-- Date: 2016年9月1日16:44:29
-- 阵法升级界面

HeroFormationLvUpPanel = class("HeroFormationLvUpPanel", BasicPanel)
HeroFormationLvUpPanel.NAME = "HeroFormationLvUpPanel"

function HeroFormationLvUpPanel:ctor(view, panelName)
    HeroFormationLvUpPanel.super.ctor(self, view, panelName, 520)
    self.proxy = self:getProxy(GameProxys.Hero)
    
    self:setUseNewPanelBg(true)
end

function HeroFormationLvUpPanel:finalize()

    -- for i=1,4 do
    --     if self["icon"..i].uiIcon ~= nil then
    --         self["icon"..i].uiIcon:finalize()
    --         self["icon"..i].uiIcon = nil
    --     end
    -- end

    if self.uiRechargePanel ~= nil then
        self.uiRechargePanel:finalize()
        self.uiRechargePanel = nil
    end

    HeroFormationLvUpPanel.super.finalize(self)
end

function HeroFormationLvUpPanel:initPanel()
	HeroFormationLvUpPanel.super.initPanel(self)
    self:setTitle(true, TextWords:getTextWord(290010))
    self:setLocalZOrder(PanelLayer.UI_Z_ORDER_1)
    self.lvLab = self:getChildByName("Panel_30/bgImg/lvLab")
    self.nameLab = self:getChildByName("Panel_30/bgImg/nameLab")
    self.lab1 = self:getChildByName("Panel_30/bgImg/attackLab")
    self.lab2 = self:getChildByName("Panel_30/bgImg/hpLab")
    self.descLab1 = self:getChildByName("Panel_30/bgImg/Label_11_1")
    self.descLab2 = self:getChildByName("Panel_30/bgImg/Label_11_2")
    self.descLab = self:getChildByName("Panel_30/bgImg/descLab")
    self.sendBtn = self:getChildByName("Panel_30/bgImg/sendBtn")
    for i=1,4 do
        self["icon"..i] = self:getChildByName("Panel_30/bgImg/iconImg"..i)
    end
    self.iconImg = self:getChildByName("Panel_30/bgImg/iconImg")
end

function HeroFormationLvUpPanel:registerEvents()
end

function HeroFormationLvUpPanel:onShowHandler(data)
    -- local itemProxy = self:getProxy(GameProxys.Item)
    if self.iconImg.img == nil then
        self.iconImg.img = ccui.ImageView:create()
        local size = self.iconImg:getContentSize()
        self.iconImg.img:setPosition(size.width*0.5, size.height*0.5)
        self.iconImg:addChild(self.iconImg.img)
    end

    local ID = data.ID
    self.curId = ID

    local baseData = {}

    local formationLv = self.proxy:getFormationById(ID)

    -- for i=1,formationLv do
        local baseConfig = ConfigDataManager:getInfoFindByTwoKey(ConfigData.FormationLvConfig, "FormationID", ID, "lv", formationLv)
        local baseProperty = StringUtils:jsonDecode(baseConfig.property)
        for k,v in pairs(baseProperty) do
            baseData[v[1]] = baseData[v[1]] or 0
            baseData[v[1]] = baseData[v[1]] + v[2]
        end
    -- end

        
    TextureManager:updateImageView(self.iconImg.img, string.format("images/heroFormation/%d.png", ID))
       
    local levelData = ConfigDataManager:getInfoFindByTwoKey(ConfigData.FormationLvConfig, "FormationID", ID, "lv", formationLv + 1)

    self.lvLab:setString("Lv."..formationLv)
    self.nameLab:setString(data.name)
    local addInfo = StringUtils:jsonDecode(levelData.property)

    local infoData = ConfigDataManager:getInfoFindByTwoKey(ConfigData.FormationLvConfig, "FormationID", ID, "lv", formationLv)

    self.descLab:setString(infoData.info)

    for k,v in pairs(addInfo) do
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
        local text = {{{baseData[v[1]], 20},{" +"..(v[2] - baseData[v[1]]), 20, ColorUtils.wordColorDark1603}}}
        self["lab"..k].richLab:setString(text)
    end

    local needData = StringUtils:jsonDecode(infoData.lvupneed)
    -- local needData = StringUtils:jsonDecode(levelData.lvupneed)
    self:setIcon(needData)

    self.sendBtn.data = data
    self:addTouchEventListener(self.sendBtn, self.sendLevelUpReq)
end

function HeroFormationLvUpPanel:sendLevelUpReq(sender)
    

    self.itemData = self.itemData or {}
    local function lvUp()
        local data = sender.data
        local sendData = {}
        sendData.formationId = data.ID
        self.proxy:onTriggerNet300002Req(sendData)
    end


    local context = TextWords:getTextWord(290018)
    if table.size(self.itemData) ~= 0 then
        self.proxy:CommonLvUpEnough(self.itemData, self, lvUp, context)
    else
        lvUp()
    end
end

function HeroFormationLvUpPanel:onUpdateView(noShow)
    local configData = ConfigDataManager:getConfigById(ConfigData.FormationsConfig, self.curId)
    local formationLv = self.proxy:getFormationById(self.curId)
    print("刷新界面")
    if formationLv >= configData.lvmax then
        if not noShow then
            self:showSysMessage("阵法已升至满级")
        -- else
        --     local levelData = ConfigDataManager:getInfoFindByTwoKey(ConfigData.FormationLvConfig, "FormationID", self.curId, "lv", formationLv)
        --     local needData = StringUtils:jsonDecode(levelData.lvupneed)
        --     self:setIcon(needData)
        end
        self:hide()
        return
    end
    self:onShowHandler(configData)
end

function HeroFormationLvUpPanel:setIcon(needData)
    self.itemData = {}
    local itemProxy = self:getProxy(GameProxys.Item)
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
                self.itemData[needData[i][2]] = needData[i][3] - haveNum
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
end