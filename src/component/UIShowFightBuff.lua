UIShowFightBuff = class("UIShowFightBuff")

function UIShowFightBuff:ctor(panel)
    local uiSkin = UISkin.new("UIShowFightBuff")
    
    uiSkin:setParent(panel:getParent())


    self._uiSkin = uiSkin
    self._uiSkin:setLocalZOrder(PanelLayer.UI_Z_ORDER_11)
    self._panel = panel
    self._parent = parent


    local secLvBg = UISecLvPanelBg.new(self._uiSkin:getRootNode(), self)
    self._secLvBg = secLvBg
    secLvBg:setBackGroundColorOpacity(120)
    secLvBg:setTitle(TextWords:getTextWord(2000)) -- "增益信息"
    secLvBg:setContentHeight(300)
    self:registerEvents()
end


function UIShowFightBuff:registerEvents()
    local mainPanel = self._uiSkin:getChildByName("mainPanel")

    self._listView = mainPanel:getChildByName("listView")
end

function UIShowFightBuff:finalize()
    self._uiSkin:finalize()
end

function UIShowFightBuff:hide()
    TimerManager:addOnce(1, self.finalize, self)
end


function UIShowFightBuff:setView(buffStringList , fightBuff)
    self._fightBuff = fightBuff


    ComponentUtils:renderListView(self._listView, buffStringList, self, self.renderItem, nil, nil, 0)

end

function UIShowFightBuff:renderItem(itemPanel, data, index)
    local strTxt = itemPanel:getChildByName("strTxt")
    strTxt:setString(data.str)

    local txtColor = self:getColor(data.fightBuffId)
    strTxt:setColor(txtColor)
end

function UIShowFightBuff:getColor(fightBuffId)
    
    local color = ColorUtils.wordGrayColor
    for i, value in pairs(self._fightBuff) do
        if fightBuffId == value then
            color = ColorUtils.wordGoodColor
            break
        end
    end
    return color
end




















