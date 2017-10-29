AutoClickAction = class("AutoClickAction", DialogueAction)

function AutoClickAction:ctor()
    AutoClickAction.super.ctor(self)
    self.moduleName = ""
    self.widgetName = ""
    self.rotation = 180
    
    self.isTouchCall = true --有些不需要去执行点击
    self.isShowArrow = true  --引导结束后，是否要显示箭头
end

function AutoClickAction:finalize()
    AutoClickAction.super.finalize(self)
end

function AutoClickAction:onEnter(guide)
    AutoClickAction.super.onEnter(self, guide)
end

function AutoClickAction:afterRender()
end

function AutoClickAction:renderView(view, callback, widget, localPos)
    self:callback()
end


function AutoClickAction:callback(value)
    TimerManager:remove(self.delaycallback, self)
    if self._widget ~= nil and self._widget.touchCallback ~= nil and self.isTouchCall == true then
        self._widget.touchCallback(self._widget, ccui.TouchEventType.ended) --模拟触摸
    end
    
    AutoClickAction.super.callback(self, value)
end