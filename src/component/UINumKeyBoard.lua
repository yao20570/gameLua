--[[------
数字键盘控件
---]]

UINumKeyBoard = class("UINumKeyBoard")

function UINumKeyBoard:ctor(panel, maxNum, numcallback)
    self._uiSkin = UISkin.new("UINumKeyBoard")
    self._uiSkin:setParent(panel:getParent())
    
    self._maxNum = maxNum
    self._numcallback = numcallback
    self._panel = panel
    
    self._uiSkin:setVisible(false)
    self._uiSkin:setLocalZOrder(999)
    self:registerEvents()
end

--传入触摸touch实例，来定位面板的坐标
function UINumKeyBoard:show(sender)
    self._uiSkin:setVisible(true)
    self._sender = sender
    
    local pos = sender:getTouchEndPosition()
end

function UINumKeyBoard:hide()
    self._uiSkin:setVisible(false)
end

function UINumKeyBoard:registerEvents()
    local numInputPanel = self:getChildByName("numInputPanel")
    local children = numInputPanel:getChildren()
    for _, child in pairs(children) do
        if child:getName() ~= "Image_40" then
            self:addTouchEventListener(child, self.onNumBtnTouch)
        end
    end

    self:addTouchEventListener(self._uiSkin.root, self.onClosePanelTouch)
end

function UINumKeyBoard:onNumBtnTouch(sender)
    local name = sender:getName()
    local num = string.gsub(name,"numBtn", "")
    if num == "E" then
        self:onClosePanelTouch()
        return
    end
    if num == "C" then
        num = ""
        self.lastNum = num
    end

    local lastNum = self.lastNum
    if lastNum == nil then
        lastNum = ""
        self.lastNum = lastNum
    end


    if num ~= "" then
        local newNum = lastNum .. num
        num = tonumber(newNum)
        if num > self._maxNum then
            num = lastNum
        end 
        self.lastNum = num
        self.cacheNum = num
    end

    self._numcallback(self._panel, self._sender, num)
end

function UINumKeyBoard:onClosePanelTouch(sender)
    if self.lastNum == "" then
        self._numcallback(self._panel, self._sender, self.cacheNum)
    end

    self.lastNum = nil
    self.cacheNum = nil
    
    self:hide()
end


function UINumKeyBoard:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end

function UINumKeyBoard:addTouchEventListener(widget, callback)
    ComponentUtils:addTouchEventListener(widget,callback, nil, self)
end

-- 设置可输入最大值
function UINumKeyBoard:setMaxNum( maxNum )
    -- body
    self._maxNum = maxNum
end
