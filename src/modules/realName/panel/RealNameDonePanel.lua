-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 实名认证完成
--  */
RealNameDonePanel = class("RealNameDonePanel", BasicPanel)
RealNameDonePanel.NAME = "RealNameDonePanel"

function RealNameDonePanel:ctor(view, panelName)
    local layer = view:getLayer(ModuleLayer.UI_Z_ORDER_5)
    RealNamePanel.super.ctor(self, view, panelName, 260, layer)
end

function RealNameDonePanel:finalize()
    RealNameDonePanel.super.finalize(self)
end

function RealNameDonePanel:initPanel()
	RealNameDonePanel.super.initPanel(self)
    self:setTitle(true,self:getTextWord(461011))
end

function RealNameDonePanel:registerEvents()
    RealNameDonePanel.super.registerEvents(self)
end

function RealNameDonePanel:onHideHandler()
    self:dispatchEvent(RealNameEvent.HIDE_SELF_EVENT)
end

function RealNameDonePanel:onShowHandler()
    local realNameProxy = self:getProxy(GameProxys.RealName)
    local info = realNameProxy:getRealNameInfo()
    self:showInfo(info)
end

function RealNameDonePanel:showInfo(info)
    local infoTxt = self:getChildByName("mainPanel/infoTxt")
    local infoStr = {
        {{self:getTextWord(461016), 20, "#E3DACF"},{info.name, 20, "#ffffff"}},
        {{"\n", 20, "#E3DACF"}},
        {{self:getTextWord(461017), 20, "#E3DACF"},{info.idNum, 20, "#ffffff"}},
    }

    infoTxt:setString("")
    local richLabel = infoTxt.richLabel
    if richLabel == nil then
        richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
        infoTxt:addChild(richLabel)
        infoTxt.richLabel = richLabel
    end
    richLabel:setString(infoStr)

end
