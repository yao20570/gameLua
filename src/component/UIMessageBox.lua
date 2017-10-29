UIMessageBox = class("UIMessageBox") --对话框

function UIMessageBox:ctor(parent)
    self._localZOrder = 1000
    self._parent = parent

end

function UIMessageBox:finalize()

    local layout = self._parent:getChildByName("layout")
    if layout ~= nil then
        self._parent:removeChildByName("layout")
    end
    if self._uiSkin == nil then
        return
    end
    if self._uiSkin ~= nil then
        self._uiSkin:finalize()
    end
    self._uiSkin = nil
    self._parent = nil
end

function UIMessageBox:updateContent(content)
    if self._contentTxt == nil then
        return
    end
    local newInfoStr = StringUtils:getStringAddBackEnter(content, 20)
    self._contentTxt:setString(newInfoStr)
end

function UIMessageBox:setShowSecLvBgCloseBtn(b)
    if self._secLvBg then
        self._secLvBg:hideCloseBtn(b)
    end

    self._showSecLvBgCloseBtn = b
end

-- 
--data = {
--    content,
--    tip,
--    data
--}

function UIMessageBox:show(data, okCallback, canCelcallback, okBtnName,canelBtnName)
    if self._isOpen == true then
        return
    end
    local layout = self._parent:getChildByName("layout")
    if layout == nil then
        layout = ccui.Layout:create()
        layout:setContentSize(640, 960)
        layout:setTouchEnabled(true)
        layout:setName("layout")
        self._parent:addChild(layout)
    end

    okBtnName = okBtnName or TextWords:getTextWord(100)
    canelBtnName = canelBtnName or TextWords:getTextWord(101)
    self._isOpen = true 

    self._titleName = nil
    
   -- self:delayShow(content, okCallback, canCelcallback,okBtnName,canelBtnName)
    TimerManager:addOnce(30, self.delayShow, self, data, okCallback, canCelcallback,okBtnName,canelBtnName)
end

function UIMessageBox:setTitleName(titleName)
    self._titleName = titleName
end

function UIMessageBox:delayShow(data, okCallback, canCelcallback,okBtnName,canelBtnName)
    local content = data
    local tip = nil
    local num = nil
    if type(content) == "table" then
        content = data.content
        tip = data.tip
        num = data.num
    end


    --已经设置不显示弹窗的直接执行okCallback方法
    if self._gameSettingKey ~= nil then
        local state = LocalDBManager:getValueForKey(self._gameSettingKey,true)
        self._dbState = state
        -- nil 或者 1 为需要弹窗二次确认 , 0为不需要二次确认
        if self._dbState == tostring(0) then
            if okCallback ~= nil then
                okCallback()
            end
            TimerManager:addOnce(30, self.delayRemove, self)
            return
        end
    end


    local uiSkin = UISkin.new("UIMessageBox")
    uiSkin:setParent(self._parent)
    uiSkin:setName("messagebox")
    self._uiSkin = uiSkin
    uiSkin:setLocalZOrder(self._localZOrder)

    --[[
    new一个二级背景,将messageBox的全部子节点clone到二级背景下，
    再删除messageBox的全部子节点    
    ]]
    --begin-------------------------------------------------------------------
    local secLvBg = UISecLvPanelBg.new(self._uiSkin:getRootNode(), self)
    secLvBg:setContentHeight(250)
    secLvBg:setTitle(self._titleName or TextWords:getTextWord(122))
    secLvBg:hideCloseBtn(self._showSecLvBgCloseBtn or self._showSecLvBgCloseBtn and false)
    secLvBg:setLocalZOrder(self._localZOrder)
    self._secLvBg = secLvBg

    local function onSecLvBgCloseBtnClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self._isOpen = false            
            TimerManager:addOnce(30, self.delayRemove, self)
        end
    end
    local closeBtn = secLvBg:getCloseBtn()
    closeBtn:addTouchEventListener(onSecLvBgCloseBtnClick)

    local oldPanel = uiSkin:getChildByName("messagePanel")
    local mainPanel = secLvBg:getMainPanel()
    local panel = oldPanel:clone()
    panel:setName("panel")
    panel:setLocalZOrder(self._localZOrder)
    mainPanel:addChild(panel)
    oldPanel:setVisible(false)
    oldPanel:removeFromParent()
    --end-------------------------------------------------------------------
    

    panel = mainPanel:getChildByName("panel")    

    local contentTxt = panel:getChildByName("contentTxt")
    local cancelBtn = panel:getChildByName("cancelBtn")
    local okBtn = panel:getChildByName("okBtn")
    local middOkBtn = panel:getChildByName("middOkBtn")

    local txtTip = panel:getChildByName("txtTip")
    local txtNum = panel:getChildByName("txtNum")




    local isShow = true
    local noShow = false
    if okCallback == nil then
        isShow = false
        noShow = true
    end
    okBtn:setVisible(isShow)
    cancelBtn:setVisible(isShow)
    middOkBtn:setVisible(noShow)

    if self._panel ~= nil then
        self._panel["boxOkBtn"] = okBtn
    end
    local newInfoStr = StringUtils:getStringAddBackEnter(content, 20)

    contentTxt:setString(newInfoStr)
    self._contentTxt = contentTxt
    
    if tip ~= nil then
        txtTip:setVisible(true)
        txtTip:setString(tip)

        local posY = contentTxt:getPositionY() - contentTxt:getContentSize().height/2 - txtTip:getContentSize().height/2
        txtTip:setPositionY(posY)
    else
        txtTip:setVisible(false)
    end

    if num ~= nil then
        txtNum:setVisible(true)
        txtNum:setString(num)
    else
        txtNum:setVisible(false)
    end

    okBtn:setTitleText(okBtnName)
    cancelBtn:setTitleText(canelBtnName)
    

    local function onOkClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self._isOpen = false
            AudioManager:playEffect("Button")
            if okCallback ~= nil then
                okCallback()
            end
            TimerManager:addOnce(30, self.delayRemove, self)
        end
    end
    self.okBtn = okBtn
    okBtn.touchCallback = onOkClick
    okBtn:setTouchEnabled(true)
    okBtn:addTouchEventListener(onOkClick)


    local function middOkBtnCallback(sender, eventType)
         if eventType == ccui.TouchEventType.ended then
            
            self._isOpen = false
            AudioManager:playEffect("Button")
            if okCallback ~= nil then
                okCallback()
            end
            if canCelcallback ~= nil then
                canCelcallback()
            end
            TimerManager:addOnce(30, self.delayRemove, self)
        end
    end

    middOkBtn.touchCallback = middOkBtnCallback
    middOkBtn:setTouchEnabled(true)
    middOkBtn:addTouchEventListener(middOkBtnCallback)
    middOkBtn:setTitleText(okBtnName)
    
    local function onCelcallClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self._isOpen = false
            AudioManager:playEffect("Button")
            if canCelcallback ~= nil then
                canCelcallback()
            end
            TimerManager:addOnce(30, self.delayRemove, self)
        end
    end
    cancelBtn:setTouchEnabled(true)
    cancelBtn:addTouchEventListener(onCelcallClick)


    --4411 【需求】- 增加全局控制二级弹窗处理(二级弹窗增加设置)
    local setPanel = panel:getChildByName("setPanel")
    if self._gameSettingKey ~= nil then
        setPanel:setVisible(true)
        self._checkBox = setPanel:getChildByName("checkBox")
    else
        setPanel:setVisible(false)
    end


end

function UIMessageBox:getOkBtn()
    local okBtn = self._okBtn
    return okBtn
end

function UIMessageBox:setLocalZOrder(order)
    self._localZOrder = order
end

function UIMessageBox:delayRemove()
    if self._gameSettingKey ~= nil then
        if self._checkBox then
            local cbState = self._checkBox:getSelectedState()
            local state = tostring(cbState == true and 0 or 1)
            -- nil 或者 1 为需要弹窗二次确认 , 0为不需要二次确认
            if self._dbState ~= state then
                LocalDBManager:setValueForKey(self._gameSettingKey, state,true)
            end
        end
    end
    self:finalize()
end

function UIMessageBox:setPanel(panel)
    self._panel = panel
end

--若二级弹窗为消费类（消耗元宝）弹窗提示，这需要设置
--key 缓存本地数据的key 
function UIMessageBox:setGameSettingKey(key)
    self._gameSettingKey = key
end













