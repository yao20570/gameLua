AreaClickAction = class("AreaClickAction", DialogueAction)

function AreaClickAction:ctor()
    AreaClickAction.super.ctor(self)
    
    self._iscallback = false
    self.isMove = false
    self.isShowArrow = true  --引导结束后，是否要显示箭头
end

function AreaClickAction:finalize()
    AreaClickAction.super.finalize(self)
end

function AreaClickAction:onEnter(guide)
    AreaClickAction.super.onEnter(self, guide)
--    print("AreaClickAction=========>1", self.info)
--    print("AreaClickAction=========>2", self.moduleName)
--    print("AreaClickAction=========>3", self.panelName)
--    print("AreaClickAction=========>4", self.widgetName)
end

function AreaClickAction:renderView(view, callback, widget, localPos)
    if self.isMove == nil then
        self.isMove = 0
    end
    
    view:updateAreaClick(widget, callback, self.info, self.isMove, self.arrowDir)
end

function AreaClickAction:callback(value)
    TimerManager:remove(self.delaycallback, self)
    if self._iscallback == true then
        return
    end
    
    local view = self._guide:getView()
    view:resetView(self.isShowArrow)

    local touchCallbackValue = nil
    local touchCallback = self._widget.touchCallback
    if touchCallback ~= nil then
        touchCallbackValue = touchCallback(self._widget, ccui.TouchEventType.ended,value, true) --模拟触摸
    end
    
    AreaClickAction.super.callback(self, value)
    return touchCallbackValue --触发后的回调值
end



