UISysMessage = class("UISysMessage") --飘字

function UISysMessage:ctor(parent)
    local uiSkin = UISkin.new("UISysMessage")
    uiSkin:setParent(parent)
    uiSkin:setTouchEnabled(false)
    
    self.uiSkin = uiSkin    
    
    self._sysMessage = uiSkin:getChildByName("SysMessage")
        
    self._sysMessageDataQueue = Queue.new()
    
end

function UISysMessage:finalize()

    if self._ccb ~= nil then
        self._ccb:finalize()
        self._ccb = nil
    end

    self.uiSkin:finalize()
end

function UISysMessage:show(content, color, font)
    
    if self._ccb ~= nil then
        self._ccb:finalize()
        self._ccb = nil
    end
    
    local owner = {}
    owner["complete"] = function()
        self._ccb:finalize()
        self._ccb = nil
    end
    self._ccb = UICCBLayer.new("rgb-tishitiao", self._sysMessage, owner)
   
	local guideTxt = tolua.cast(owner["nameTxt"], "cc.Label")
	guideTxt:setString(content or "")
    
end











