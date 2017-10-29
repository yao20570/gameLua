
---[[
--平铺控件, 默认描点在中心点，竖平铺，先这样子处理
--坐标保存不变
--]]
UITileWidget = class("UITileWidget")

function UITileWidget:ctor(widget)
    self._widget = widget
    self._y = widget:getPositionY()
    self._height = widget:getContentSize().height
    widget:setAnchorPoint(0.5, 1)
    
    self._widgetList = {}
    self._widgetList[1] = widget
    
    self._contentHeight = self._height
end

function UITileWidget:setContentHeight(height)
    for _, widget in pairs(self._widgetList) do
    	widget:setVisible(false)
    end

    self._contentHeight = height
    local num = math.ceil(height / self._height)     
    self.less = num % self._height
    local y = self._y - height / 2
    
    local dty = 1 --重叠像素
    if dty > 0 then
        if num >= self._height then
            --重叠像素超过一个widget高度时，增加widget修补
            num = num + math.floor(num / self._height)
        end
    end

    for index=1, num do
        local widget = self._widgetList[index]
        if widget == nil then
            widget = self._widget:clone()
            self._widget:getParent():addChild(widget)
            self._widgetList[index] = widget
        end

        y = y + self._height - dty
        --print("坐标 index,Y=",index,y)

        widget:setVisible(true)
        widget:setPositionY(y)
    end

    if dty > 0 then
        self:addFixWidget(num,y,dty,self.less)
    end
    
end

-- 重叠像素要再铺widget抵消
function UITileWidget:addFixWidget(num,y,dty,less)
    -- body
    dty = dty * less
    y = y + dty
    num = num + 1
    --print("坐标 num,Y,less=",num,y,less)

    local widget = self._widgetList[num]
    if widget == nil then
        widget = self._widget:clone()
        self._widget:getParent():addChild(widget)
        self._widgetList[num] = widget
    end

    widget:setVisible(true)
    widget:setPositionY(y)
end

function UITileWidget:getContentHeight()
    return self._contentHeight
end

function UITileWidget:getPositionY()
    return self._y
end





