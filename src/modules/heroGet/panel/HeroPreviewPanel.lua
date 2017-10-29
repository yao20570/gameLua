-- -------------------------------------------------------------------------------
-- 英雄分解预览
-- -------------------------------------------------------------------------------
HeroPreviewPanel = class("HeroPreviewPanel", BasicPanel)
HeroPreviewPanel.NAME = "HeroPreviewPanel"

function HeroPreviewPanel:ctor(view, panelName)
    HeroPreviewPanel.super.ctor(self, view, panelName,320)

end

function HeroPreviewPanel:finalize()
    HeroPreviewPanel.super.finalize(self)
end

function HeroPreviewPanel:initPanel()
    HeroPreviewPanel.super.initPanel(self)

    self:setCloseBtnStatus(false) -- 隐藏关闭按钮

    self:setTitle(true,self:getTextWord(290069))
    self:setLocalZOrder(PanelLayer.UI_Z_ORDER_2)

    self._rewardPanel = self:getChildByName("mainPanel")
    local label1 = self._rewardPanel:getChildByName("Label1")
    label1:setString(self:getTextWord(290073))
    local Image_bg = self._rewardPanel:getChildByName("Image_bg")
    TextureManager:updateImageView(Image_bg, "images/guiScale9/Frame_item_bg.png")
    local rewardBtn = self._rewardPanel:getChildByName("rewardBtn")
    rewardBtn:setTitleText(self:getTextWord(270011))
    self._countLb = self._rewardPanel:getChildByName("countLb")
    -- self._iconImg = self._rewardPanel:getChildByName("iconImg")
    self.icons = {}
    for i=1,4 do
        self.icons[i] = self._rewardPanel:getChildByName("iconImg"..i)
    end

    self:addTouchEventListener(rewardBtn, self.sendReq)

end

function HeroPreviewPanel:registerEvents()
    HeroPreviewPanel.super.registerEvents(self)
end

function HeroPreviewPanel:onClosePanelHandler()
    self:hide()
end

function HeroPreviewPanel:onShowHandler(data)
    for k,v in pairs(self.icons) do
        v:setVisible(false)
    end
    data = data or {}

    for k,v in pairs(data) do
        local icon = self.icons[k]
        if icon ~= nil then
            icon:setVisible(true)
            if icon.uiIcon == nil then
                icon.uiIcon = UIIcon.new(icon, v, true, self, nil, true)
            else
                icon.uiIcon:updateData(v)
            end
        end
    end

    self:adjustIconPos(table.size(data))
end

function HeroPreviewPanel:adjustIconPos(lenght)
    if lenght < 1 then
        return
    end
    local pos = {}
    pos["pos4"] = {116, 232, 348, 464}
    for i=1,3 do
        pos["pos"..i] = {}
        for j=1,i do
            pos["pos"..i][j] = 580/(i + 1) * j
        end
    end
    local posData = pos["pos"..lenght]
    for i=1, lenght do
        local icon = self.icons[i]
        icon:setPositionX(posData[i])
    end
end

function HeroPreviewPanel:sendReq(sender)
    local panel = self:getPanel(HeroGetPanel.NAME)
    panel:sendHeroResolveReq()
end