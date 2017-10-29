
--[[
自定义的PageView，实现循环翻页
index从0开始
]]
UIExpandPageView = class("UIExpandPageView")

function UIExpandPageView:ctor(pageView)
    
    self._pageView = pageView
    self._pageList = {}
    self._eventState = true


end

function UIExpandPageView:renderPage(dataList, obj)
    self._obj = obj -- self
    local firstPage = self._pageView:getPage(0)
    firstPage:setVisible(true)
    
    for index, data in pairs(dataList) do
        local page = self._pageView:getPage(index - 1)
        if page == nil then
            page = firstPage:clone()
            if index == #dataList then
                self._pageView:insertPage(page, 0)
            end
            self._pageView:addPage(page)
        end 
        page.index = index - 1
        table.insert(self._pageList,page)
    end
    -- 初始化到第二页
    self._pageView:scrollToPage(1)
end


-- 每次scrollToPage()都会走这里
function UIExpandPageView:onPageViewListenerHandler()

    local index = self._pageView:getCurPageIndex() -- 控件内index
    logger:info("控件内页码：".. index)

    local page = self._pageView:getPage(index) -- 当前的数据页
    if self._curDataIndex == page.index + 1 then
        return 
    end

    logger:info("数据：".. page.index)
    self._curDataIndex = page.index + 1

    
    local pageNum = #self._pageList 
    pageView = self._pageView 
    if index == 0 then 
        -- 最后一个移动到第一个
        local page = pageView:getPage(pageNum - 1)
        page:retain()
        pageView:removePageAtIndex(pageNum - 1)
        pageView:insertPage(page, 0)
        page:release()

        pageView:scrollToPage(1)

        pageView:update(10)

    end

    if index == pageNum - 1 then 
        -- 第一个移动到最后一个
        local page = pageView:getPage(0)
        page:retain()
        pageView:removePageAtIndex(0)
        
        pageView:insertPage(page, pageNum - 1)
        
        page:release()

        pageView:scrollToPage(pageNum - 2)

        pageView:update(10)
    end

    -- 执行回调函数
    if self._pageCallBack ~= nil then
        self._pageCallBack(self._obj)
    end

end

------------------------------------


--向左翻页
function UIExpandPageView:moveLeft()
    local curPageIndex = self._pageView:getCurPageIndex()
    curPageIndex = curPageIndex - 1
    if curPageIndex < 0 then
        -- curPageIndex = 0
        local pageNum = #self._pageView:getPages()
        curPageIndex = pageNum - 1
    end
    self._pageView:scrollToPage(curPageIndex)

    TimerManager:addOnce(100, self.onPageViewListenerHandler, self)
end

--向右翻页
function UIExpandPageView:moveRight()
    local curPageIndex = self._pageView:getCurPageIndex()
    self._pageView:scrollToPage(curPageIndex + 1)

    curPageIndex = self._pageView:getCurPageIndex()

    TimerManager:addOnce(100, self.onPageViewListenerHandler, self)
end

function UIExpandPageView:getCurDataIndex()
    return self._curDataIndex 
end

function UIExpandPageView:getCurDataPage()
    return self._pageList[self._curDataIndex ]
end

function UIExpandPageView:getPageCount()
    return #self._pageList
end

function UIExpandPageView:setPageCallback(callback)
    self._pageCallBack = callback
end
