
UIExpandListView = class("UIExpandListView")
UIExpandListView.PRE_LOAD_LIST_ITEM_NUM = 4

function UIExpandListView:ctor(listView, itemWidth, itemHeight, frameRenderCount)
    self._listView = listView
    self._initState = true
    self._itemWidth = itemWidth
    self._itemHeight = itemHeight

    self._updateDataCallback = listView.updateData -- 回调函数
    self._listViewData = nil

    self._minYTile = 0
    self._maxYTile = 0

    -- 随机的预加载加载时间 分散多个ListView预加载
    self._preLoadDelay = math.random(200, 500)

    self._preLoadNum = UIExpandListView.PRE_LOAD_LIST_ITEM_NUM 

    self._frameRenderCount = frameRenderCount or 3

    
    self._curLoadIndex = 0 -- 当前加载的数据Index

    self._fromPanel = fromPanel -- [[？？]]

    self:initListView(listView)
end


function UIExpandListView:initListView(listView)
    self:addListViewEvent(listView) -- 

    local size = self._listView:getContentSize()
    self._maxSeeItemCount = math.ceil(size.height / self._itemHeight) -- 可见item个数

    self._expandViewQueue = Queue.new()

end

-- 这里对于每个列表，都要做一下释放
function UIExpandListView:finalize()
    -- logger:error("~~~~~~~~~~列表释放~~~~~~~~~~~~~")
    self:removeSchedule()

    self._expandViewQueue = nil
end

-- 模块关闭的时候，还是需要移除掉定时器的
function UIExpandListView:removeSchedule()
    -- TimerManager:remove(self.onExpandViewSchedule, self)

    if self.expandSchedule ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.expandSchedule)
        self.expandSchedule = nil
    end
end

function UIExpandListView:addSchedule()
    -- TimerManager:add(30, self.onExpandViewSchedule, self)

    if self.expandSchedule ~= nil then
        return
    end

    local function onExpandViewSchedule()
        self:onExpandViewSchedule()
    end
    -- print("=========================================>addSchedule")
    self.expandSchedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onExpandViewSchedule, 0, false)
end

function UIExpandListView:onExpandViewSchedule()

    -- print("~~~~~~~~~UIExpandListView:onExpandViewSchedule()~~~~~~~~~~~~")

    if self._fromPanel ~= nil and self._fromPanel.isVisible ~= nil then
        if self._fromPanel:isVisible() == false then
            return
        end
    end

    if self._expandViewQueue:size() == 0 then
        -- 同时删除定时器
        self:removeSchedule()
        -- 没有数据就退出
        return

    end

    for index = 1, self._frameRenderCount do
        local pos = self._expandViewQueue:pop()
        if pos ~= nil then
            -- callback返回true：更新了一条，下一条下帧更新。false没有更新，继续下一条
            if self._updateDataCallback(pos.x, pos.y, 0) then
                -- return
            end
        end
    end

end

function UIExpandListView:pool()
end

-- 初始化list显示内容函数
-- 外部调用 expandListView:initListViewData   | preLoadNum == nil
function UIExpandListView:initListViewData(data, preLoadNum, isFrame, isInitAll)
    self._initState = false -- 还未初始化完成
    preLoadNum = preLoadNum or UIExpandListView.PRE_LOAD_LIST_ITEM_NUM -- [[？？]]
    if isInitAll == true then -- 是否全部初始化
        preLoadNum = #data
    end
    self._preLoadNum = preLoadNum -- 预加载的个数，默认为4, + 可见，则为当前加载个数
    -- 初始化完成之后将数据和状态设回
    local function delayMove()
        self._listViewData = data
        self._initState = true
    end

    --    print("-----UIExpandListView:initListViewData------", debug.traceback())

    -- 初始化渲染多少个
    local initCount = 1
    -- 
    if type(isFrame) == type(1) then
        initCount = isFrame -- 传入初始化个数
        isFrame = true --[[改变了类型]]
    end

    if isFrame ~= true then
        local delayTime = 0
        local count = 1
        for index, _ in pairs(data) do
            if count <= self._maxSeeItemCount + preLoadNum then -- 当前初始化多少个(可见+预加载个数)
                self._curLoadIndex = index -- 从1开始，取到的数据index，此时 index == count [[这里没必要一直赋值]]
                self:updateDataCallback(0, index - 1, count)
                delayTime = delayTime + index + 1
            end
            count = count + 1
        end  -- TODO：self._curLoadIndex = count - 1 

        TimerManager:addOnce(delayTime, delayMove, self)
    else
        local index = 1
        local function updateDataCallback()
            local isEnd = false
            for i = 1, initCount do
                if index <= self._maxSeeItemCount + preLoadNum then
                    self:updateDataCallback(0, index - 1, index)
                    index = index + 1
                else
                    isEnd = true
                end
            end

            if isEnd then
                TimerManager:addOnce(30, delayMove, self)
                -- TimerManager:addOnce(self._preLoadDelay, self.delayPushPool, self)
            else
                TimerManager:addOnce(30, updateDataCallback, self)
            end
            -- if index <= self._maxSeeItemCount + preLoadNum then
            --     self:updateDataCallback(0,index - 1, index)
            --     TimerManager:addOnce(30 , updateDataCallback, self)
            -- else
            --     TimerManager:addOnce(30, delayMove, self)
            --     TimerManager:addOnce(self._preLoadDelay, self.delayPushPool, self)
            -- end
            -- index = index + 1
        end

        updateDataCallback()
        -- TimerManager:addOnce(30 , updateDataCallback, self)
    end

end

-- TODO,增加缓存处理
function UIExpandListView:delayPushPool()
    print("~~~~~~~~~~~~~~~~~~delayPushPool~~~~~~~~~~")
    local listView = self._listView
    local items = listView:getItems()
    local count = #items
    local num = ComponentUtils:getListViewItemPoolNum(listView)
    local listViewData = self._listViewData or { }
    if count + num < #listViewData then
        -- 还有数据没有填充，先预加载Item
        local item = listView.itemModel:clone()
        ComponentUtils:pushListViewItemPool(listView, item)
        --        print("--------delayPushPool------", num, count)

        TimerManager:addOnce(self._preLoadDelay, self.delayPushPool, self)
    end
end


-- 更新列表, 已经初始化过的，外部再更新时 isDelayUpdate == nil; updateListViewData(infos), isDelayUpdate为nil
function UIExpandListView:updateListViewData(data, isDelayUpdate)

    

    self._expandViewQueue:clear() -- 把缓存队列清空，以防出现问题
    
    self._listViewData = data
    self._initState = true
    self._curLoadIndex = 0

    self:handleListViewMove(isDelayUpdate)

    self._isUpdating = true

    local function callback()
        self._isUpdating = false
    end
    TimerManager:addOnce(300, callback, self)
end

-- TODO, 有数据还没有更新，才回调计算， 初始化过的才会调用这个函数
function UIExpandListView:handleListViewMove(isMoveUpdate)
    if self._listViewData == nil then
        
        return
    end
    if table.size(self._listViewData) == 0 then
        return
    end

    local size = self._listView:getContentSize() -- 可见尺寸
    local width = size.width
    local height = size.height

    local x0, y0 = self:scPos2ItemPos(0, 0, isMoveUpdate)
    local x2, y2 = self:scPos2ItemPos(width, height, isMoveUpdate)

    local minXTile = self:xPos2Tile(x0) -2
    local maxXTile = self:xPos2Tile(x2) + 1

    local minYTile = self:yPos2Tile(y2) -2
    local maxYTile = self:yPos2Tile(y0) + 1

    --print("=====================>minYTile,maxYTile", minYTile, maxYTile)

    if minYTile <= 0 then
        minYTile = 0
    end

    if maxYTile <= 0 then
        maxYTile = 0
    end

    minXTile = math.max(0, minXTile)
    maxXTile = math.max(0, maxXTile)

    self._minYTile = minYTile -- 当前要显示的item.index， min
    self._maxYTile = maxYTile -- max

    if minXTile == self._lastMinXTile and maxXTile == self._lastMaxXTile
        and minYTile == self._lastMinYTile and maxYTile == self._lastMaxYTile then
        if isMoveUpdate == true then
            return
        end
    end

    --    print("=======handleListViewMove=======", minYTile, maxYTile)

    local isPush = isMoveUpdate or false -- 再次刷新 == false

    -- 是否是垂直滚动
    local dir = self._listView:getDirection()
    local isVerticalDir = dir == ccui.ScrollViewDir.vertical

    if self._lastMinXTile == nil or isMoveUpdate ~= true then
        -- self:delayUpdateListViewTile(minXTile, maxXTile, minYTile, maxYTile)

        if isVerticalDir then
            self:delayUpdateListViewTile(nil, nil, minYTile, maxYTile)
        else
            self:delayUpdateListViewTile(nil, nil, minXTile, maxXTile)
        end
    elseif isVerticalDir then
        local startY, endY
        local dirY = maxYTile - self._lastMaxYTile
        if dirY > 0 then
            startY = self._lastMaxYTile
            endY = maxYTile
        else
            startY = minYTile
            endY = self._lastMinYTile
        end


        -- for y = startY, endY + self._preLoadNum do
        for y = startY, endY do
            -- if startY == endY then
            --     break
            -- end
            self:updateListViewTile(0, y, y - startY + 1, isPush)
        end

        if isPush == true then
            -- 如果是isPush的，开启一个定时器
            self:addSchedule()
        end

    else

        local startX, endX
        local dirX = maxXTile - self._lastMaxXTile
        if dirX > 0 then
            startX = self._lastMaxXTile
            endX = maxXTile
        else
            startX = minXTile
            endX = self._lastMinXTile
        end

        for x = startX, endX do
            if startX == endX then
                break
            end
            self:updateListViewTile(0, x)
        end
    end

    self._lastMinXTile = minXTile
    self._lastMaxXTile = maxXTile
    self._lastMinYTile = minYTile
    self._lastMaxYTile = maxYTile
end

-- ListView移动到最底端了，判断是否还有数据可以加载
function UIExpandListView:handleListViewMoveBottom()
    print("=============handleListViewMoveBottom===============")

    for index = 1, self._maxSeeItemCount do
        local nextIndex = self._curLoadIndex + 1
        if self._listViewData[nextIndex] ~= nil then
            self:updateDataCallback(0, nextIndex - 1)
            self._curLoadIndex = self._curLoadIndex + 1
        end
    end
end

function UIExpandListView:delayUpdateListViewTile(minXTile, maxXTile, minYTile, maxYTile)
    if minYTile < 0 then
        minYTile = 0
    end
    if maxYTile < 0 then
        maxYTile = 0
    end
    local index = 0
    for j = minYTile, maxYTile + self._preLoadNum do
        --        for i=minXTile, maxXTile do
        self:updateListViewTile(0, j, index + 1)
        index = index + 1
        --        end
    end
end


function UIExpandListView:updateListViewTile(xtile, ytile, delay, isPush)
    --    print("===============updateListViewTile=================",xtile, ytile)
    self:updateDataCallback(xtile, ytile, delay, isPush)
end
-- 初始化时delay == 0，ytile == delay - 1; 初始化isPush的值为nil
function UIExpandListView:updateDataCallback(xtile, ytile, delay, isPush)
    if self._updateDataCallback ~= nil then
        if isPush == true then
            self._expandViewQueue:push( { x = xtile, y = ytile })
        else
            self._updateDataCallback(xtile, ytile, delay)

            self._curLoadIndex = ytile + 1
        end

        --
    end
end

function UIExpandListView:getMinYTile()
    return self._minYTile
end

function UIExpandListView:getMaxYTile()
    return self._maxYTile
end

-- listView响应回调添加
function UIExpandListView:addListViewEvent(listView)
    local function scrollViewEvent(sender, evenType)
        self:handleListViewMove(true)
        --print("=================>scrollViewEvent")
    end
    listView:addScrollViewEventListener(scrollViewEvent)
end


function UIExpandListView:scPos2ItemPos(scPosX, scPosY, isMoveUpdate)

    local innerX, innerY = self._listView:getInnerContainer():getPosition()

    --print("=====================>scPos2ItemPos", math.ceil(innerX), math.ceil(innerY))

    local x = scPosX + math.abs(innerX)
    local y = scPosY + math.abs(innerY)

    return x, y
end

function UIExpandListView:xPos2Tile(xpos)
    if xpos == 0 then
        return 0
    end
    local itemsMargin = self._listView:getItemsMargin()
    local items = self._listView:getItems()
    -- TODO 缓存坐标
    for i, item in ipairs(items) do
        local x = item:getPositionX()
        if xpos > x and xpos <=(x + item:getContentSize().width + itemsMargin) then
            return i
        end
    end
    local x = math.floor(xpos /(self._itemWidth))
    return x

end

function UIExpandListView:yPos2Tile(ypos)

    local itemsMargin = self._listView:getItemsMargin()
    local size = self._listView:getInnerContainerSize()
    local cy = size.height - ypos
    local y = cy /(self._itemHeight + itemsMargin)
    y = math.floor(y)
    -- local y =  math.floor( ((#items) * (self._itemHeight + itemsMargin)  - ypos) / (self._itemHeight + self._itemsMargin))

    return y
end


function UIExpandListView:getListViewData()
    return self._listViewData
end

function UIExpandListView:getInitState()
    return self._initState
end


