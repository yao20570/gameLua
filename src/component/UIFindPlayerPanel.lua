UIFindPlayerPanel = class("UIFindPlayerPanel")

------
-- @param  panel [obj] 界面
-- @param  callback [func] 点击领取的回调函数
function UIFindPlayerPanel:ctor(panel, callback)
    local uiSkin = UISkin.new("UIFindPlayerPanel")
    
    uiSkin:setParent(panel:getParent())


    self._uiSkin = uiSkin
    self._uiSkin:setLocalZOrder(PanelLayer.UI_Z_ORDER_10)
    self._panel = panel
    self._parent = parent


    local secLvBg = UISecLvPanelBg.new(self._uiSkin:getRootNode(), self)
    self._secLvBg = secLvBg
    secLvBg:setBackGroundColorOpacity(120)
    secLvBg:setTitle(TextWords:getTextWord(3031)) -- "奖励信息"
    secLvBg:setContentHeight(350)
    
    -- 确定按钮回调函数
    self._okCallback = callback

    self:registerEvents()

    self:initPanel()
end


function UIFindPlayerPanel:registerEvents()
    local mainPanel = self._uiSkin:getChildByName("mainPanel")
    self._cancleBtn = mainPanel:getChildByName("cancleBtn")
    self._okBtn     = mainPanel:getChildByName("okBtn")    
    self._legionBtn = mainPanel:getChildByName("legionBtn")
    self._holdTxt   = mainPanel:getChildByName("holdTxt")  
    self._editPanel = mainPanel:getChildByName("editPanel")
    self._nameTxt   = mainPanel:getChildByName("nameTxt")  

    ComponentUtils:addTouchEventListener(self._legionBtn, self.onLegionBtn, nil, self)
    ComponentUtils:addTouchEventListener(self._okBtn, self.onOkBtn, nil, self)
    ComponentUtils:addTouchEventListener(self._cancleBtn, self.onCancleBtn, nil, self)
end

function UIFindPlayerPanel:finalize()
    if self._findCloseCallback then
        self._findCloseCallback(self)
    end

    self._uiSkin:finalize()
end

function UIFindPlayerPanel:hide()
    TimerManager:addOnce(1, self.finalize, self)
end

-- 初始化
function UIFindPlayerPanel:initPanel()
    self._nameTxt:setString("")
    self._holdTxt:setString("")
    if self._editBox == nil then
        local function callback()
            self:setContentToLabel()
        end
        self._editBox = ComponentUtils:addEditeBox(self._editPanel, 10, "", callback, nil) -- 限制五个字
    else
        self._editBox:setText("")
    end
end

function UIFindPlayerPanel:setHoldTxt(holdStr)
    self._holdTxt:setString(holdStr)
end

function UIFindPlayerPanel:setListHandler(listCallback)
    self._getListCallback = listCallback
end


function UIFindPlayerPanel:setContentToLabel()
    local text = self._editBox:getText()
    -- 为空显示占位
    if string.len(text) == 0 then
        self._holdTxt:setVisible(true)
    else
        self._holdTxt:setVisible(false)
    end

end


function UIFindPlayerPanel:onOkBtn()
    if self._holdTxt:isVisible() then
        self._panel:showSysMessage(TextWords:getTextWord(204))
        return 
    end

    if self._okCallback ~= nil then
        self._okCallback(self._panel, self._editBox:getText())
    end
end

function UIFindPlayerPanel:onCancleBtn()
    self:hide()
end

function UIFindPlayerPanel:onLegionBtn()
    if self._getListCallback then
        self._getListCallback(self._panel)
    end
end

function UIFindPlayerPanel:setEditText(name)
    if self._editBox then
        self._editBox:setText(name)
        if string.len(name) == 0 then
            self._holdTxt:setVisible(true)
        else
            self._holdTxt:setVisible(false)
        end
    end
end

function UIFindPlayerPanel:setLegionBtnVisible(state)
    self._legionBtn:setVisible(state)
end

function UIFindPlayerPanel:setCloseCallback(findCloseCallback)
    self._findCloseCallback = findCloseCallback
end















