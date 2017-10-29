-- /**
--  * @Author:      fzw
--  * @DateTime:    2016-12-03 15:03:00
--  * @Description: 世界地图对玩家使用技能的弹窗
--  */

MapUseCitySkillPanel = class("MapUseCitySkillPanel", BasicPanel)
MapUseCitySkillPanel.NAME = "MapUseCitySkillPanel"

function MapUseCitySkillPanel:ctor(view, panelName)
    local layer = view:getLayer(ModuleLayer.UI_TOP_LAYER)
    MapRebelsPanel.super.ctor(self, view, panelName, 240, layer)
end

function MapUseCitySkillPanel:finalize()
    MapUseCitySkillPanel.super.finalize(self)
end

function MapUseCitySkillPanel:initPanel()
    MapUseCitySkillPanel.super.initPanel(self)
    self:setTitle(true,self:getTextWord(122))

    local yesBtn = self:getChildByName("mainPanel/yesBtn")
    local noBtn = self:getChildByName("mainPanel/noBtn")
    self:addTouchEventListener(yesBtn, self.onYesBtnTouch)
    self:addTouchEventListener(noBtn, self.onNoBtnTouch)
    self._lessNum = self:getChildByName("mainPanel/lessNum")
    self._infoTxt = self:getChildByName("mainPanel/infoTxt")
    self._titleTxt = self:getChildByName("mainPanel/titleTxt")
    self._infoTxt:setString("")
    self._titleTxt:setString("")
end

function MapUseCitySkillPanel:registerEvents()
    MapUseCitySkillPanel.super.registerEvents(self)
end

function MapUseCitySkillPanel:onClosePanelHandler()
    self:hide()
end

function MapUseCitySkillPanel:onShowHandler(data)
    self._data = data
    local config = data.config

    local titleStr = string.format(TextWords[291004], config.name)
    local infoStr = config.tipDescribe    
    self._titleTxt:setString(titleStr)
    
    local richLabel = self._infoTxt.richLabel
    if richLabel == nil then
        richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
        self._infoTxt:addChild(richLabel)
        self._infoTxt.richLabel = richLabel
    end
    richLabel:setString(infoStr)

    -- 居中显示
    local size = richLabel:getContentSize()
    local x = - size.width/2
    richLabel:setPositionX(x)

    -- 剩餘次數
    local lessNum = data.leesNum
    self._lessNum:setString(string.format(self:getTextWord(291007),lessNum))

end

function MapUseCitySkillPanel:onYesBtnTouch(sender)
    if self._data == nil then
        return
    end

    local data = self._data
    local sendData = {}
    sendData.typeId = data.typeId
    sendData.targetPlayerId = data.playerId

    local lordCityProxy = self:getProxy(GameProxys.LordCity)
    lordCityProxy:onTriggerNet360051Req(sendData)

    self:onClosePanelHandler()
end

function MapUseCitySkillPanel:onNoBtnTouch(sender)
    self:onClosePanelHandler()
end


