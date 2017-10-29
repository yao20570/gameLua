
UIExpandScrollView = class("UIExpandScrollView")



function UIExpandScrollView:ctor(scrollView, itemUI, spacing)

    self._isInit = false

    -- 滑动列表
    self._scrollView = scrollView
    self._scrollView.jumpToTop = function() 
        logger:error("不能 jumpToTop, 使用BasicPanel:renderScrollView(scrollview, itemUIName, infos, obj, rendercall, jumpIndex, spacing)里的jumpIndex = 1来实现跳到第几条，参考商城实现") 
    end
    self._sizeView = scrollView:getContentSize()
    
    self._inner = self._scrollView:getInnerContainer()
    self._oldPosX, self._oldPosY = self._inner:getPosition()

    -- 当前使用的子项表
    self._curItemUIMap = { }

    self._indexKey = { }

    -- 子项，因为动态语言，在Update时随意在ItemUI上加属性，所以只能抽出来作为拷贝的存在
    self._cloneUI = itemUI
    if self._cloneUI then
        itemUI:retain()
        itemUI:removeFromParent()
        --table.insert(self._curItemUIMap, self._cloneUI)
        --self:setItemUIIndex(self._cloneUI, 1)
    end

    -- 子项数量
    self._itemUICount = 0
    self._minIndex = 1
    self._maxIndex = 0
    self._jumpIndex = nil

    -- 回调函数
    self._funSender = nil
    self._itemUpdateFun = nil

    -- 数据
    self._data = nil
    self._dataLen = 0

    -- 间隔
    self._spacing = spacing or 0

    -- 滚动方向
    self._direction = self._scrollView:getDirection()

    self:createItemUI(false)
    
    local function scrollViewEvent(sender, evenType)
        self:evtScrolling(sender, evenType)
    end
    self._scrollView:addEventListener(scrollViewEvent)
    -- self:addScrollViewEvent(scrollView)
end

function UIExpandScrollView:finalize()
    self._cloneUI:release()
    self._cloneUI = nil
end

-- 设置间距
function UIExpandScrollView:setSpacing(spacing)
    self._spacing = spacing or 0
end

function UIExpandScrollView:evtScrolling(sender, evenType)

    --print("=======================================evenType:", evenType)
    -- if evenType == ccui.ScrollviewEventType.scrolling then
    do
        local inner = self._inner
        local sizeInner = inner:getContentSize()
        local sizeView = self._scrollView:getContentSize()
        local newX, newY = inner:getPosition()
        local oldX, oldY = self._oldPosX, self._oldPosY

        if self._direction == ccui.ScrollViewDir.horizontal then            
            if oldX < newX then
                while true do
                    if self._minIndex > 1 then
                        local itemUI = self._indexKey[self._maxIndex]
                        local itemUIPosX = itemUI:getPositionX()
                        if itemUIPosX + oldX > sizeView.width then
                            self._minIndex = self._minIndex - 1
                            self:setItemUIIndex(itemUI, self._minIndex)
                            self._itemUpdateFun(self._funSender, itemUI, self._data[self._minIndex], self._minIndex)
                            self:setItemUIIndex(nil, self._maxIndex)
                            self._maxIndex = self._maxIndex - 1
                        else
                            break
                        end
                    else
                        break
                    end
                end
            elseif oldX > newX then                
                while true do
                    if self._maxIndex < self._dataLen then

                        local itemUI = self._indexKey[self._minIndex]
                        local itemUIPosX = itemUI:getPositionX()
                        local itemUISize = itemUI:getContentSize()
                        if itemUIPosX + itemUISize.width + oldX < 0 then
                            self._maxIndex = self._maxIndex + 1
                            self:setItemUIIndex(itemUI, self._maxIndex)
                            self._itemUpdateFun(self._funSender, itemUI, self._data[self._maxIndex], self._maxIndex)
                            self:setItemUIIndex(nil, self._minIndex)
                            self._minIndex = self._minIndex + 1
                        else
                            break
                        end
                    else
                        break
                    end
                end
            end

            self._oldPosX = newX
        else
            -- print("==================>oldY:", oldY, ",  newY:", newY)
            if oldY < newY then
                while true do
                    if self._maxIndex < self._dataLen then
                        local itemUI = self._indexKey[self._minIndex]
                       
                        local itemUIPosY = itemUI:getPositionY()
                        if itemUIPosY + oldY > sizeView.height then
                            self._maxIndex = self._maxIndex + 1
                            self:setItemUIIndex(itemUI, self._maxIndex)
                            self._itemUpdateFun(self._funSender, itemUI, self._data[self._maxIndex], self._maxIndex)
                            self:setItemUIIndex(nil, self._minIndex)
                            self._minIndex = self._minIndex + 1
                        else
                            break
                        end
                    else
                        break
                    end
                end
            elseif oldY > newY then
                while true do
                    if self._minIndex > 1 then

                        local itemUI = self._indexKey[self._maxIndex]
                        local itemUIPosY = itemUI:getPositionY()
                        local itemUISize = itemUI:getContentSize()
                        if itemUIPosY + itemUISize.height + oldY < 0 then
                            self._minIndex = self._minIndex - 1
                            self:setItemUIIndex(itemUI, self._minIndex)
                            self._itemUpdateFun(self._funSender, itemUI, self._data[self._minIndex], self._minIndex)
                            self:setItemUIIndex(nil, self._maxIndex)
                            self._maxIndex = self._maxIndex - 1
                        else
                            break
                        end
                    else
                        break
                    end
                end
            end

            self._oldPosY = newY
        end

    end
end

-- 创建子项(注意，当scrollView的大小发生改变时，必须重新生成ItemUI)
function UIExpandScrollView:createItemUI(isUpdateData)

    -- 设置子项数量
    local lenItem = self:getItemLenght()
    local lenView = self:getViewLenght()
    local lenInner = self:getInnerLenght()
    local itemCount = math.ceil((lenView - self._spacing) / (lenItem+self._spacing)) + 1

    

    -- 检测子项数量是否有变化
    if itemCount == self._itemUICount  then
        
        if self:checkSizeViewIsChange() then
            -- 当scrollview的size发生变化,但子项数量没发生变化时
            
            -- 修正itemUI的位置
            local index = self._minIndex
            for k, itemUI in pairs(self._curItemUIMap) do
                self:setItemUIIndex(itemUI, index)
                index = index + 1
            end

            self._sizeView = self._scrollView:getContentSize()

            if self._jumpIndex ~= nil then 
                self:updateUI(self._data, self._funSender, self._itemUpdateFun, self._jumpIndex)
            end
        end

        return
    end

    self._itemUICount = itemCount
    if isUpdateData == false then
        self._minIndex = 1
        self._maxIndex = 0
    end

    -- 修正scrollview的itemUI数量
    local curItemUICount = #self._curItemUIMap
    if curItemUICount > self._itemUICount then
        local delCount = curItemUICount - self._itemUICount
        for i = delCount, 1, -1 do
            local index = curItemUICount - i + 1
            self._curItemUIMap[index]:removeFromParent()
            self._curItemUIMap[index] = nil
            self:setItemUIIndex(nil, index)
            self._maxIndex = self._maxIndex - 1
        end
    elseif curItemUICount < self._itemUICount then 
        -- 需要添加的数量
        local addCount = self._itemUICount - curItemUICount

        -- 重置itemUI位置，
        for i = 1 , curItemUICount do
            self._maxIndex = self._minIndex + i - 1
            local itemUI = self._curItemUIMap[ i ]
            self:setItemUIIndex(self._curItemUIMap[ i ], self._maxIndex)
            if itemUI.index ~= self._maxIndex then
                self._itemUpdateFun(self._funSender, itemUI, self._data[self._maxIndex], self._maxIndex)
            end
        end

        -- 创建新的ItemUI
        for i = 1, addCount do
            local newItemUI = self._cloneUI:clone()
            table.insert(self._curItemUIMap, newItemUI)            
            self._scrollView:addChild(newItemUI)
            self._maxIndex = self._maxIndex + 1
            self:setItemUIIndex(newItemUI, self._maxIndex)
            if isUpdateData == true and self._itemUpdateFun then
                if self._maxIndex > self._dataLen then
                    newItemUI:setVisible(false)
                else
                    newItemUI:setVisible(true)
                    self._itemUpdateFun(self._funSender, newItemUI, self._data[self._maxIndex], self._maxIndex)
                end
            end
        end
    end

    if self._jumpIndex ~= nil then 
        self:updateUI(self._data, self._funSender, self._itemUpdateFun, self._jumpIndex)
    end
end

function UIExpandScrollView:checkSizeViewIsChange()
    local sizeView = self._scrollView:getContentSize()
    if sizeView.width == self._sizeView.width and sizeView.height == self._sizeView.height then
        return false
    end

    return true
end

function UIExpandScrollView:updateUI(data, funSender, itemUpdateFun, jumpIndex)
    
    if self:checkSizeViewIsChange() == true then
        self:createItemUI(false)
    end

    self._obj = obj
    self._data = data
    self._dataLen = #data
    self._funSender = funSender
    self._itemUpdateFun = itemUpdateFun


    -- 设置innerContainer的长度
    local lenItem = self:getItemLenght()
    local lenInner = (lenItem + self._spacing) * self._dataLen + self._spacing
    self:setInnerContainerLenght(lenInner)
    local inner = self._inner
    self._oldPosX, self._oldPosY = inner:getPosition()

    --
    if jumpIndex ~= nil then
        local jumpMaxIndex = self._dataLen - self._itemUICount + 1
        if jumpMaxIndex < 1 then
            jumpMaxIndex = 1
        end
        if jumpIndex > jumpMaxIndex then
            self._minIndex = jumpMaxIndex
            self._maxIndex = self._dataLen

            jumpIndex = jumpMaxIndex + 1
        else
            self._minIndex = jumpIndex
            self._maxIndex = self._minIndex + self._itemUICount - 1
        end
        self._jumpIndex = jumpIndex
    else
        self._jumpIndex = nil
    end

    -- 检查数据长度是否比当前显示的位置还要短，true则重置显示的位置
    local moreCount = 0
    if self._maxIndex > self._dataLen then
        moreCount = self._maxIndex - self._dataLen
    end
    if moreCount > 0 then
        self._minIndex = self._minIndex - moreCount
        if self._minIndex < 1 then
            self._minIndex = 1            
        end
        self._maxIndex = self._minIndex + self._itemUICount - 1
    end

    -- item绑定index,设置位置
    local index = self._minIndex
    for k, itemUI in pairs(self._curItemUIMap) do

        self:setItemUIIndex(itemUI, index)
        if index > self._dataLen then
            itemUI:setVisible(false)
        else
            itemUI:setVisible(true)
            self._itemUpdateFun(self._funSender, itemUI, data[index], index)
        end

        index = index + 1
    end

    self:jumpIndex()
end

function UIExpandScrollView:jumpIndex()
    if self._jumpIndex ~= nil then
        
        local jumpMaxIndex = self._dataLen - self._itemUICount + 1                
        if self._jumpIndex >= jumpMaxIndex then
            if self._direction == ccui.ScrollViewDir.horizontal then                
                self._scrollView:jumpToPercentHorizontal(100)
            else                
                self._scrollView:jumpToPercentVertical(100)
            end
        else
            local p = 0
            local lenItem = self:getItemLenght()
            local viewSize = self._scrollView:getContentSize()
            local lenInner = self:getInnerLenght()
            if self._direction == ccui.ScrollViewDir.horizontal then
                local rollLen = lenInner - viewSize.width            
                if rollLen ~= 0 then 
                    p = ((self._jumpIndex - 1) * (lenItem + self._spacing)) /(lenInner - viewSize.width) * 100            
                end
                self._scrollView:jumpToPercentHorizontal(p)
            else
                local rollLen = lenInner - viewSize.height
                if rollLen ~= 0 then 
                    p = ((self._jumpIndex - 1) * (lenItem + self._spacing)) /(lenInner - viewSize.height) * 100 
                end
                self._scrollView:jumpToPercentVertical(p)
            end
        end

        
    end
end

-- 获取item的计算长度
function UIExpandScrollView:getItemLenght()
    local itemUISize = self._cloneUI:getContentSize()
    if self._direction == ccui.ScrollViewDir.horizontal then
        return itemUISize.width
    else
        return itemUISize.height
    end
end

-- 获取scrollview的计算长度
function UIExpandScrollView:getViewLenght()
    local scrollviewSize = self._scrollView:getContentSize()
    if self._direction == ccui.ScrollViewDir.horizontal then
        return scrollviewSize.width
    else
        return scrollviewSize.height
    end
end

-- 获取inner的计算长度
function UIExpandScrollView:getInnerLenght()
    local innerSize = self._scrollView:getInnerContainerSize()
    if self._direction == ccui.ScrollViewDir.horizontal then
        return innerSize.width
    else
        return innerSize.height
    end
end

-- 设置innerContainer的长度,并返回真实的长度
function UIExpandScrollView:setInnerContainerLenght(len)
    local innerSize = self._scrollView:getInnerContainerSize()
    if self._direction == ccui.ScrollViewDir.horizontal then
        self._scrollView:setInnerContainerSize(cc.size(len, innerSize.height))
        local size = self._scrollView:getInnerContainerSize()
        return size.width
    else
        self._scrollView:setInnerContainerSize(cc.size(innerSize.width, len))
        local size = self._scrollView:getInnerContainerSize()

        return size.height
    end

    return 0
end

-- 设置itemUI位置
function UIExpandScrollView:setItemUIIndex(itemUI, index)

    --logger:error("setItemUIIndex index:%d", index)

    local oldItemUI = self._indexKey[index]
    if oldItemUI then
        oldItemUI.index = nil
    end
    self._indexKey[index] = itemUI

    if itemUI ~= nil then
        if itemUI.index then
            self._indexKey[itemUI.index] = nil
        end
        itemUI.index = index
        local itemSize = self._cloneUI:getContentSize()

        if self._direction == ccui.ScrollViewDir.horizontal then
            local posX = self._spacing + (itemUI.index - 1) * (itemSize.width + self._spacing)
            itemUI:setPositionX(posX)
        else
            local innerSize = self._scrollView:getInnerContainerSize()
            local posY = innerSize.height - itemUI.index * (itemSize.height + self._spacing)
            itemUI:setPosition(0, posY)
            local y = itemUI:getPositionY()
        end
    end
end



-- 获取inner的计算长度
function UIExpandScrollView:getIndexItem(idx)
    return self._indexKey[idx]
end