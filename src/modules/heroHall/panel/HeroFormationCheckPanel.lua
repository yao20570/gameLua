--
-- Author: zlf
-- Date: 2016年9月21日11:52:53
-- 阵法查看界面

HeroFormationCheckPanel = class("HeroFormationCheckPanel", BasicPanel)
HeroFormationCheckPanel.NAME = "HeroFormationCheckPanel"

function HeroFormationCheckPanel:ctor(view, panelName)
    HeroFormationCheckPanel.super.ctor(self, view, panelName, 330)
    
    self:setUseNewPanelBg(true)
end

function HeroFormationCheckPanel:finalize()
    HeroFormationCheckPanel.super.finalize(self)
end

function HeroFormationCheckPanel:initPanel()
	HeroFormationCheckPanel.super.initPanel(self)
    self:setTitle(true, TextWords:getTextWord(290010))
    self:setLocalZOrder(PanelLayer.UI_Z_ORDER_1)

    self.proxy = self:getProxy(GameProxys.Hero)

    local sureBtn = self:getChildByName("Panel_1/Image_13/sureBtn")
    self:addTouchEventListener(sureBtn, function()
        self:hide()
    end)

end


function HeroFormationCheckPanel:onShowHandler(data)
    local iconImg = self:getChildByName("Panel_1/Image_13/iconImg")
    local iconUrl = string.format("images/heroFormation/%d.png", data.ID)
    if iconImg.img == nil then
        local size = iconImg:getContentSize()
        iconImg.img = TextureManager:createImageView(iconUrl)
        iconImg.img:setPosition(size.width/2, size.height/2)
        iconImg:addChild(iconImg.img)
    else
        TextureManager:updateImageView(iconImg.img, iconUrl)
    end
    
    
    local level = self.proxy:getFormationById(data.ID)
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
    local text = {{{"Lv."..level, 20, ColorUtils.wordColorLight1602}, {" "..data.name, 20}}}
    infoLab.richLab:setString(text)

    local descLab = self:getChildByName("Panel_1/Image_13/descLab") 
    local formationData = ConfigDataManager:getInfoFindByTwoKey(ConfigData.FormationLvConfig, "FormationID", data.ID, "lv", level)
    descLab:setString(formationData.info)

    local property = StringUtils:jsonDecode(formationData.property)
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
        local attrText = {{{nameInfo.name, 20}, {" "..v[2], 20, ColorUtils.wordColorLight1602}}}
        attrLab.richLab:setString(attrText)
    end
end