
BattleEnterPanel = class("BattleEnterPanel", BasicPanel)
BattleEnterPanel.NAME = "BattleEnterPanel"

function BattleEnterPanel:ctor(view, panelName)
    BattleEnterPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function BattleEnterPanel:finalize()
    BattleEnterPanel.super.finalize(self)
end

function BattleEnterPanel:initPanel()
    BattleEnterPanel.super.initPanel(self)
end

function BattleEnterPanel:onShowHandler(data)

    local battleProxy = self:getProxy(GameProxys.Battle)
    local battle = battleProxy:getCurBattleData()
    local puppets = battle.puppets

    local puppetMap = {}
    for _,puppet in pairs(puppets) do
        puppetMap[puppet.attr.index] = puppet.attr
    end 


    for i=1,6 do
        local icon = self:getChildByName("mainPanel/PanelL/icon"..i)
        local puppet = puppetMap[i + 10]
        self:renderHeroIcon(icon, puppet)
    end
    for i=1,6 do
        local icon = self:getChildByName("mainPanel/PanelR/icon"..i)
        local puppet = puppetMap[i + 20]
        self:renderHeroIcon(icon, puppet)
    end

    local captainL = self:getChildByName("mainPanel/PanelL/captain")
    self:renderCounsellorIcon(captainL, puppetMap[19])

    local captainR = self:getChildByName("mainPanel/PanelR/captain")
    self:renderCounsellorIcon(captainR, puppetMap[29])
    

    self:playAction("Animation0")
    local panel = self:getChildByName("mainPanel")
    local effect = UICCBLayer.new("rgb-duijue", panel, nil, function()
        data()
    end, true)
    local x, y = NodeUtils:getCenterPosition()
    effect:setPosition(x, y)
end

--渲染出战面板
function BattleEnterPanel:renderHeroIcon(icon, puppet)
    if puppet ~= nil and puppet.heroId > 0 then
        local iconData = {}
        iconData.num = 1
        iconData.power = 409
        iconData.typeid = puppet.heroId
        if icon.uiIcon == nil then
            icon.uiIcon = UIIcon.new(icon, iconData, false, self)
            local size = icon:getContentSize()
            icon.uiIcon:setPosition(size.width/2, size.height/2)
            icon.uiIcon:setScale(60/80)
        else
            icon.uiIcon:setVisible(true)
            icon.uiIcon:updateData(iconData)
        end
    else
        if icon.uiIcon ~= nil then
            icon.uiIcon:setVisible(false)
        end
    end
end

function BattleEnterPanel:renderCounsellorIcon(captain, puppet)
    if puppet == nil then
        captain:setVisible(false)
    else
        captain:setVisible(true)
        local moduleId = puppet.modelList
        local url = "images/consigliereImg/" .. moduleId .. ".png"
        TextureManager:updateImageView(captain, url)
    end
end

