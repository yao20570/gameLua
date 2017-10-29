DialogueAreaClickAction = class("DialogueAreaClickAction", DialogueAction)

function DialogueAreaClickAction:ctor()
    self.info = ""
    self.moduleName = ""
    self.widgetName = ""
    self.pointY = 409
    self.rotation = 180
    
    self.autoNextAction = 3 --自动下一Action
    self.callbackArg = nil

    self._iscallback = false
    self.isShowArrow = true  --引导结束后，是否要显示箭头
end

function DialogueAreaClickAction:finalize()
    DialogueAreaClickAction.super.finalize(self)
end

function DialogueAreaClickAction:onEnter(guide)
    DialogueAreaClickAction.super.onEnter(self, guide)

end

function DialogueAreaClickAction:renderView(view, callback, widget, localPos)
    if self.isMove == nil then
        self.isMove = 0
    end
    view:updateInfoAreaClick(self.info,self.pointY,self.isMove,widget, localPos, self.rotation, callback)
end

function DialogueAreaClickAction:callback(value)
    game.manager.TimerManager:remove(self.delaycallback, self)
    if self._iscallback == true then
        return
    end

    self._iscallback = true
    
    local view = self._guide:getView()
    view:resetView(self.isShowArrow)
    
    local touchCallback = self._widget.touchCallback
    if touchCallback ~= nil then
        touchCallback(self._widget, ccui.TouchEventType.ended,value) --模拟触摸
    end
    self:nextAction()
end


