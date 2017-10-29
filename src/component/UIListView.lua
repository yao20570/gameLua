UIListView = class("UIListView")

function UIListView:ctor(listView, itemWidth, itemHeight)
    self._listView = listView
    self._itemWidth = itemWidth
    self._itemHeight = itemHeight
    
    self._itemsMargin = listView:getItemsMargin()
    self._updateDataCallback = listView.updateData
    
    self._maxNum = 0
    self._exNum = 2
    
    self._listViewData = nil
    
    self:initListView(listView)
end

function UIListView:initListView(listView)
    local size = self._listView:getContentSize()
    self._maxSeeItemCount = math.ceil( size.height / self._itemHeight )
    
    self:addListViewEvent(listView)
end

--初始化ListView
function UIListView:initListViewData(data)
    self._maxNum = #data
    self._listViewData = data
    local listView = self._listView
    for i=0, self._maxSeeItemCount + self._exNum do --多加载两个，用来循环
        listView:pushBackDefaultItem()
    end

    local items = listView:getItems()
    for index=0, #items - 1 do
        local item = listView:getItem(index)
        item.index = index
        self._updateDataCallback(item)
    end
    
end

--更新ListView
function UIListView:updateListViewData(data)
    local listView = self._listView
    self._listViewData = data
    
    local items = listView:getItems()
    for index=0, #items - 1 do
        local item = listView:getItem(index)
        self._updateDataCallback(item) --TODO 可能没有数据，数据减少了
    end
    
end

--跳转到顶部
function UIListView:jumpToTop()
    local listView = self._listView
    local items = listView:getItems()
    for index=0, #items - 1 do
        local item = listView:getItem(index)
        item.index = index
        self._updateDataCallback(item)
    end
    
    listView:jumpToTop()
    
end

--跳转到某个Index，数据Index
--需要计算出Index的相对位置
function UIListView:jumpToIndex(index)
    local listView = self._listView
    
    local maxNum = #self._listViewData --最大数据
    if index + self._maxSeeItemCount < maxNum then --位置还没有超过最底部
        local items = listView:getItems()
        local p = 2 / #items * 100
        listView:jumpToPercentVertical(p)
        
        for i=index - 1, #items - 1 do
            local item = listView:getItem(i)
            item.index = i
            self._updateDataCallback(item)
        end
        
    else
    
    end
    
    
end

function UIListView:addListViewEvent(listView)
    local maxIndex = self._maxSeeItemCount + self._exNum
    local maxNum = 20
    local wh = listView:getContentSize().height
    local sh = self._itemHeight + self._itemsMargin

    local lasty = nil

    local function scrollViewEvent(sender, evenType)
        maxNum = self._maxNum
        local container = listView:getInnerContainer()
        local ch = container:getContentSize().height
        local x , y = container:getPosition()
        local sIndex = math.floor((ch - wh - math.abs(y)) / sh)

        if lasty == nil then
            lasty = y
            return
        end
        local dir = y - lasty
        local item = listView:getItem(maxIndex)    
        if sIndex == 2 and evenType == 4 and item.index < maxNum - 1 then
            local item = ComponentUtils:setListViewItemIndex(listView, 0, maxIndex) --把第一个放到最后
            item.index = item.index + maxIndex + 1
            container:setPosition(x, y - sh)
            for index=sIndex, sIndex + self._maxSeeItemCount do --TODO 可优化
                local item = listView:getItem(index)
                self._updateDataCallback(item)
            end
        end

        if sIndex == 0 and evenType == 4 and item.index > maxIndex then
            local item = ComponentUtils:setListViewItemIndex(listView, maxIndex, 0) --把最后一个放到第一个
            item.index = item.index - maxIndex - 1
            container:setPosition(x, y + sh)
            for index=sIndex, sIndex + self._maxSeeItemCount do  --TODO 可优化
                local item = listView:getItem(index)
                self._updateDataCallback(item)
            end
        end

        lasty = y
    end
    
    listView:addScrollViewEventListener(scrollViewEvent)
end



