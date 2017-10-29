PlotAction = class("PlotAction", GuideAction)

function PlotAction:ctor()
    PlotAction.super.ctor(self)
    
    self._iscallback = false
    self.directGetWidget = false --直接用的，用完会被置空回去

    self.delayTimePre = 0.05 --延时到下一步 

    self.waitNetCmd = nil --等待网络cmd，当接受到对应的协议，才能checkWidget成功
end

function PlotAction:finalize()
    PlotAction.super.finalize(self)

    TimerManager:remove(self._updateCheckWidget, self)
end

function PlotAction:onEnter(guide)
    PlotAction.super.onEnter(self, guide)

    self._guideView = guide:getView()

    self._plotData = self:getPlotData() -- 数据
    
    self:beginPlot(guide)
end

function PlotAction:beginPlot(guide)

    if #self._plotData == 0 or self._plotData == nil then
        return
    end

    local function callback()
        self:callback()
    end

    if self.widgetName ~= nil then -- 区分是否需要获取控件
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

                self:renderView(view, callback)
                
                if self.directGetWidget == true then
                    guide:resetWidget(self.moduleName, self.panelName, self.widgetName, self.directGetWidget)
                end
            end
        end
        
        self._updateCheckWidget = updateCheckWidget
--        logger:error("=======================开始检测=====updateCheckWidget=:%f=================================", os.clock())
        TimerManager:add(30, updateCheckWidget, self, -1)
    else
        local function renderView()
            if EffectQueueManager:isComplete() then
                self:renderView(view, callback)
                TimerManager:remove(self._renderView, self)
            end
        end
        self._renderView = renderView
        TimerManager:add(30, self._renderView, self, -1)
    end
end


function PlotAction:renderView(view, callback)
    if self.delayTimePre == nil then
        self:beforeRender(self._plotData, callback)
    else
        TimerManager:addOnce(self.delayTimePre * 1000, self.beforeRender, self, self._plotData, callback)
    end
end

function PlotAction:beforeRender(plotData, callback)
    self._guideView:updatePlot(plotData, callback)

    self:afterRender()
end


function PlotAction:afterRender()

end

function PlotAction:callback()
--    -- 不执行nextAction回调则直接退出
--    if self:isNextAction() == false then
--        -- 直接退出guidePanle模块
--        GuideManager:skipGuide()
--        return
--    end

    -- 执行一次
    if self._iscallback == true then
        return
    end
    self._iscallback = true

    self.delayNextActionTime = self.delayNextActionTime or 0.01
    TimerManager:addOnce(self.delayNextActionTime * 1000, self.delayNextAction, self)
end

function PlotAction:delayNextAction()
    self:nextAction()
end
