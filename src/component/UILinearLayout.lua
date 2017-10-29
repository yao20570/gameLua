UILinearLayout = class("UILinearLayout")

function UILinearLayout:ctor()
    self._widgetList = {}
    self._firstPos = nil

    self.marge = 10
end

function UILinearLayout:insertWidget(widget)
    table.insert(self._widgetList, widget)

    if self._firstPos == nil then
        self._firstPos = cc.p(widget:getPosition())
    end
end

function UILinearLayout:setWidgetVisible(widget, visible)
    widget:setVisible(visible)
    self:reset()
end

function UILinearLayout:reset()

    local visibleWidgetList = {}
    for _, widget in pairs(self._widgetList) do
        if widget:isVisible() == true then
            table.insert(visibleWidgetList, widget)
        end
    end

    local preWidget = nil
    for _, widget in pairs(visibleWidgetList) do
        if preWidget == nil then
            widget:setPosition(self._firstPos)
        else
            local x, y = preWidget:getPosition()
            local psize = preWidget:getContentSize()
            local size = widget:getContentSize()
            widget:setPositionX(x - (psize.width / 2 + size.width / 2 + self.marge ))
        end

        preWidget = widget
    end
end