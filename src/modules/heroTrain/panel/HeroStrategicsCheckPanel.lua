--
-- Author: zlf
-- Date: 2016年9月21日15:59:21
-- 兵法查看界面

HeroStrategicsCheckPanel = class("HeroStrategicsCheckPanel", BasicPanel)
HeroStrategicsCheckPanel.NAME = "HeroStrategicsCheckPanel"

function HeroStrategicsCheckPanel:ctor(view, panelName)
    HeroStrategicsCheckPanel.super.ctor(self, view, panelName, 330)
    
    self:setUseNewPanelBg(true)
end

function HeroStrategicsCheckPanel:finalize()
    HeroStrategicsCheckPanel.super.finalize(self)
end

function HeroStrategicsCheckPanel:initPanel()
	HeroStrategicsCheckPanel.super.initPanel(self)
    self:setTitle(true, "兵法查看")
    self:setLocalZOrder(PanelLayer.UI_Z_ORDER_1)

    self.proxy = self:getProxy(GameProxys.Hero)

    local sureBtn = self:getChildByName("Panel_1/Image_13/sureBtn")
    self:addTouchEventListener(sureBtn, function()
        self:hide()
    end)

end


function HeroStrategicsCheckPanel:onShowHandler(data)
    local iconImg = self:getChildByName("Panel_1/Image_13/iconImg")
    local iconUrl = string.format("images/heroWarcraft/%d.png", data.bfData.ID)
    if iconImg.img == nil then
        local size = iconImg:getContentSize()
        iconImg.img = TextureManager:createImageView(iconUrl)
        iconImg.img:setPosition(size.width/2, size.height/2)
        iconImg:addChild(iconImg.img)
    else
        TextureManager:updateImageView(iconImg.img, iconUrl)
    end


    local heroData = data.heroData
    local heroBfInfo = heroData.strategicsInfo
    local level = nil
    for k,v in pairs(heroBfInfo) do
        if v.strategicsId == data.bfData.ID then
            level = v.strategicsLv
            break 
        end
    end


    local url = level == nil and "images/newGui2/notopen.png" or "images/newGui2/Icon_maxLv.png"
    local lockImg = self:getChildByName("Panel_1/Image_13/lockImg")
    TextureManager:updateImageView(lockImg, url)

    level = level or 1

    local infoLab = self:getChildByName("Panel_1/Image_13/infoLab")
    infoLab:setString("")
    if infoLab.richLab == nil then
        infoLab.richLab = ComponentUtils:createRichLabel("", nil, nil, 2)
        local pos = cc.p(infoLab:getPosition())
        infoLab.richLab:setPosition(pos)
        infoLab:getParent():addChild(infoLab.richLab)
    end
    local text = {{{"Lv."..level, 18, ColorUtils.commonColor.BiaoTi}, {" "..data.bfData.name, 24}}}
    infoLab.richLab:setString(text)

    local descLab = self:getChildByName("Panel_1/Image_13/descLab") 
    local bfLvData = ConfigDataManager:getInfoFindByTwoKey(ConfigData.StrategicsLvConfig, "StrategicsID", data.bfData.ID, "lv", level)
    local roleProxy = self:getProxy(GameProxys.Role)
    local comNum = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)
    local infoStr = StringUtils:getSymmetricStr(bfLvData.info, "%b##", comNum)
    descLab:setString(infoStr)

    local property = StringUtils:jsonDecode(bfLvData.property)
    for k,v in pairs(property) do
        local attrLab = self:getChildByName("Panel_1/Image_13/attrLab"..k)
        attrLab:setString("") 
        if attrLab.richLab == nil then
            attrLab.richLab = ComponentUtils:createRichLabel("", nil, nil, 2)
            local pos = cc.p(attrLab:getPosition())
            attrLab.richLab:setPosition(pos)
            attrLab:getParent():addChild(attrLab.richLab)
        end
        local nameInfo = ConfigDataManager:getConfigById(ConfigData.ResourceConfig, v[1])
        local attrText = {{{nameInfo.name, 18,ColorUtils.commonColor.FuBiaoTi}, {" "..v[2]*comNum, 18}}}
        attrLab.richLab:setString(attrText)
    end
end