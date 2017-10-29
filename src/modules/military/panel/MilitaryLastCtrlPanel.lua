-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
MilitaryLastCtrlPanel = class("MilitaryLastCtrlPanel", BasicPanel)
MilitaryLastCtrlPanel.NAME = "MilitaryLastCtrlPanel"

function MilitaryLastCtrlPanel:ctor(view, panelName)
    local layer = view:getLayer(ModuleLayer.UI_TOP_LAYER)
    MilitaryLastCtrlPanel.super.ctor(self, view, panelName, 400, layer)
end

function MilitaryLastCtrlPanel:finalize()
    MilitaryLastCtrlPanel.super.finalize(self)
end

function MilitaryLastCtrlPanel:initPanel()
	MilitaryLastCtrlPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(510012))
    self._militaryProxy = self:getProxy(GameProxys.Military)

  

end

function MilitaryLastCtrlPanel:registerEvents()
	MilitaryLastCtrlPanel.super.registerEvents(self)
    
    self._titleTxt = self:getChildByName("mainPanel/titleTxt")
    self._memoTxt = self:getChildByName("mainPanel/memoTxt")
end

function MilitaryLastCtrlPanel:onShowHandler()
    
    self:setTopText()
    self:setMemoText()
end

function MilitaryLastCtrlPanel:setTopText()

    local allLastCtrlNum = self._militaryProxy:getAllLastCtrlNum()

    local infoStr = {
        {{self:getTextWord(510013), 20, "#9C724C"},{allLastCtrlNum, 20, "#2ba532"},{self:getTextWord(510014), 20, "#9C724C"}},
    }

    if self._titleTxt.richTxt == nil then
        self._titleTxt.richTxt = ComponentUtils:createRichLabel("", nil, nil, 2)
        self._titleTxt:addChild(self._titleTxt.richTxt)
        local size = self._titleTxt:getContentSize()
        self._titleTxt.richTxt:setPosition( size.width, size.height)
    end
    self._titleTxt.richTxt:setString(infoStr)
end

function MilitaryLastCtrlPanel:setMemoText()
    if self._memoTxt.richTxt == nil then
        self._memoTxt.richTxt = ComponentUtils:createRichLabel("", nil, nil, 2)
        self._memoTxt:addChild(self._memoTxt.richTxt)
        self._memoTxt.richTxt:setPosition( 45, - 15)
    end
    

    local infoStr = {
        {{ string.format(self:getTextWord(510016), self._militaryProxy:getSoldierRank(2)), 20, "#9C724C"}, 
            {"  +"..self._militaryProxy:getAddingLastCtrlByType(2), 20, "#FFFFFF"}, 
            {self:getDiffStrByType(2), 20, "#2ba532"}}, -- 2
        {{ string.format(self:getTextWord(510017), self._militaryProxy:getSoldierRank(1)), 20, "#9C724C"}, 
            {"  +"..self._militaryProxy:getAddingLastCtrlByType(1), 20, "#FFFFFF"}, 
            {self:getDiffStrByType(1), 20, "#2ba532"}}, -- 1
        {{ string.format(self:getTextWord(510018), self._militaryProxy:getSoldierRank(3)), 20, "#9C724C"}, 
            {"  +"..self._militaryProxy:getAddingLastCtrlByType(3), 20, "#FFFFFF"}, 
            {self:getDiffStrByType(3), 20, "#2ba532"}}, -- 3
        {{ string.format(self:getTextWord(510019), self._militaryProxy:getSoldierRank(4)), 20, "#9C724C"}, 
            {"  +"..self._militaryProxy:getAddingLastCtrlByType(4), 20, "#FFFFFF"},
            {self:getDiffStrByType(4), 20, "#2ba532"}}, -- 4
    }

    self._memoTxt.richTxt:setString(infoStr)
end

function MilitaryLastCtrlPanel:getDiffStrByType(soldierType)
    local diffNum = self._militaryProxy:getNextLastCtrlByType(soldierType)
    local diffStr = ""
    if diffNum > 0 then
        diffStr = string.format(self:getTextWord(510015), diffNum)
    end
    return diffStr
end
