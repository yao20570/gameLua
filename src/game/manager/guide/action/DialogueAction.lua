DialogueAction = class("DialogueAction", GuideAction)

function DialogueAction:ctor()
    DialogueAction.super.ctor(self)

    self._iscallback = false
    self.openIconName = nil
    self.directGetWidget = false --直接用的，用完会被置空回去
    self.delayTimePre = 0.05 --延时到下一步 
    self.isShowArrow = false  --引导结束后，是否要显示箭头
    self.isShowIcon = false
    self.arrowDir = nil --强制箭头方向 -1从下往上 1从上往下

    self.waitNetCmd = nil --等待网络cmd，当接受到对应的协议，才能checkWidget成功
end

function DialogueAction:finalize()
    DialogueAction.super.finalize(self)

    TimerManager:remove(self._updateCheckWidget, self)
end

function DialogueAction:onEnter(guide)
    DialogueAction.super.onEnter(self, guide)
    
    self:checkWidget(guide)
    
end

--检测widget是否存在
function DialogueAction:checkWidget(guide)
    local view = guide:getView()
    local function callback()
        self:callback(self.callbackArg)
    end
    
    if self.widgetName ~= nil then
        
        local function updateCheckWidget()
            local widget, localPos = guide:getWidget(self.moduleName, self.panelName, self.widgetName, self.directGetWidget)
            if self.nextWidget ~= nil then
                local nextWidget = guide:getWidget(self.moduleName, self.panelName, self.nextWidget, self.directGetWidget)
                if nextWidget ~= nil then
                    TimerManager:remove(self._updateCheckWidget, self)
                    self:nextAction() --直接进入下一步
                    return
                end
            end
            

            if widget ~= nil and EffectQueueManager:isComplete() then
                self._widget = widget
                TimerManager:remove(self._updateCheckWidget, self)
                self:renderActionView(view, callback, widget, localPos)
                
                if self.directGetWidget == true then
                    guide:resetWidget(self.moduleName, self.panelName, self.widgetName, self.directGetWidget)
                end
            end
        end
        
        self._updateCheckWidget = updateCheckWidget
--        logger:error("=======================开始检测=====updateCheckWidget=:%f=================================", os.clock())
        TimerManager:add(30, updateCheckWidget, self, -1)
        
    else
        local function callRenderActionView()
            if EffectQueueManager:isComplete() then
                self:renderActionView(view, callback)
                TimerManager:remove(self._callRenderActionView, self)
            end
        end

        self._callRenderActionView = callRenderActionView
        TimerManager:add(30, callRenderActionView, self, -1)

        -- self:renderActionView(view, callback)
    end
end

function DialogueAction:renderActionView(view, callback, widget, localPos)
    if self.delayTimePre == nil then
        self:beforeRender(view, callback, widget, localPos)
    else
        TimerManager:addOnce(self.delayTimePre * 1000, self.beforeRender, self,view, callback, widget, localPos)
    end
    
end

function DialogueAction:beforeRender(view, callback, widget, localPos)
    self:renderView(view, callback, widget, localPos)
    self:afterRender()
end

--渲染引导
function DialogueAction:renderView(view, callback)
    --view:updateDialogueInfo(self.info, self.openIconName, callback)
    view:updateDialogueInfo(self.info, callback)
end

function DialogueAction:afterRender()
    --TODO 暂时注释掉，自动跳到下一步的
--    local delay = self.autoNextAction or self.defaultAutoNextAction
--    delay = 1
--    TimerManager:addOnce(delay * 1000, self.delaycallback, self)
end


function DialogueAction:delaycallback()
    
    if GameConfig.isConnected == false then --网络断开

        local delay = self.autoNextAction or self.defaultAutoNextAction
        TimerManager:addOnce(delay * 1000, self.delaycallback, self)
    else
        self:callback(self.callbackArg)
    end
end

function DialogueAction:callback(value)
    TimerManager:remove(self.delaycallback, self)
    if self._iscallback == true then
        return
    end

    self._iscallback = true

    AudioManager:playEffect("Button")
    
    local view = self._guide:getView()
    view:resetView(self.isShowArrow)
    if self.isShowIcon == nil then
        self.isShowIcon = false
    end
    view:resetIcon(self.isShowIcon)
    
    self.delayNextActionTime = self.delayNextActionTime or 0.01
    TimerManager:addOnce(self.delayNextActionTime * 1000, self.delayNextAction, self)
end

function DialogueAction:delayNextAction()
    self:nextAction()
end
