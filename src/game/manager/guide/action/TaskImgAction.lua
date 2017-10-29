TaskImgAction = class("TaskImgAction", DialogueAction)

function TaskImgAction:ctor()
    TaskImgAction.super.ctor(self)
    
    self.isShowIcon = true  --引导结束后，是否要显示任务Icon
    self._iscallback = false
    self.offsetX = 0
    self.offsetY = 0
end

function TaskImgAction:finalize()
    TaskImgAction.super.finalize(self)
end

function TaskImgAction:onEnter(guide)
    TaskImgAction.super.onEnter(self, guide)
end

function TaskImgAction:renderView(view, callback, widget, localPos)
    view:updateIconPos(widget, self.offsetX, self.offsetY)
    self:callback()
    -- print("下个引导~~")
    -- view:updateAreaClick(widget, callback, self.info, self.isMove, self.arrowDir)
end

-- function TaskImgAction:callback(value)
-- --     TimerManager:remove(self.delaycallback, self)
-- --     print("这个是什么回调？？",self._iscallback)
-- --     -- if self._iscallback == true then
-- --     --     return
-- --     -- end
    
--     local view = self._guide:getView()
-- --     -- view:resetView(self.isShowArrow)
--     view:resetIcon(self.isShowIcon)
--     self:nextAction()

-- --     -- -- self:delayNextAction()
-- --     -- local touchCallbackValue = nil
-- --     -- local touchCallback = self._widget.touchCallback
-- --     -- if touchCallback ~= nil then
-- --     --     touchCallbackValue = touchCallback(self._widget, ccui.TouchEventType.ended,value, true) --模拟触摸
-- --     -- end
    
--     TaskImgAction.super.callback(self, value)
-- --     return touchCallbackValue --触发后的回调值
-- end



