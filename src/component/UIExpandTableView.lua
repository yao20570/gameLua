---[[
--将ListView转成TableView
--减少渲染数
-----]]
UIExpandTableView = class("UIExpandTableView")

--Panel--BasicPanel
--titleWidget 用来处理有Title的列表
function UIExpandTableView:ctor(listView, panel, titleWidget)
    self._itemModel = listView:getItem(0)
    self._listData = {}
    self._updateDataCallback = listView.updateData
    self._listView = listView
    
    self._panel = panel
    self._titleWidget = titleWidget
    
    self._itemsMargin = listView:getItemsMargin()
    local size = self._itemModel:getContentSize()
    self._itemWidth = size.width
    self._itemHeight = size.height + self._itemsMargin
    
    listView:setVisible(false)
    
    self:initTableView()
end

function UIExpandTableView:initTableView()
    local size = self._listView:getContentSize()
    local pos = cc.p(self._listView:getPosition())
    local tableView = cc.TableView:create(size)
    tableView:setAnchorPoint(cc.p(0,0))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(pos)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listView:getParent():addChild(tableView)

    tableView:setScale(1 / NodeUtils:getAdaptiveScale())
    
    self._tableView = tableView

    local function scrollViewDidScroll(view)
--        print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
--        print("scrollViewDidZoom")
    end

    local function tableCellTouched(table,cell)
--        print("cell touched at index: " .. cell:getIdx(), table.getLocation, table )
    end

    local function cellSizeForTable(table,idx) 
        local info = self._listData[idx + 1]
        if rawget(info, "isTitleInfo") == true then
            local size = self._titleWidget:getContentSize()
            return size.height, size.width
        end
        
        return self._itemHeight, self._itemWidth
    end

    local itemClone = self._itemModel

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local info = self._listData[idx + 1]
        local isTitleInfo = rawget(info, "isTitleInfo")
        if isTitleInfo == true then
            itemClone = self._titleWidget
        else
            itemClone = self._itemModel
        end
        if nil == cell then
            cell = cc.TableViewCell:new()
            local panel = ComponentUtils:popListViewItemPool(self._listView)
            if panel == nil then
                panel = itemClone:clone()
            end
            panel:setVisible(true)
--            panel:setTouchEnabled(false) --TODO 处理为True时的拖动
            panel:setAnchorPoint(cc.p(0,0))
            panel:setScale(1)
            local dx = (size.width - itemClone:getContentSize().width) / 2
            panel:setPosition(cc.p(dx, self._itemsMargin))
            panel:setTag(123)
            panel.isTitleInfo = isTitleInfo
            cell:addChild(panel)

            self._updateDataCallback(panel, info, idx)
        else
            local panel = cell:getChildByTag(123)
            if isTitleInfo ~= panel.isTitleInfo then --对应的Idx title不一样了，需要删除，重新添加
                if panel.isTitleInfo ~= true then --正常Item，入池
                    ComponentUtils:pushListViewItemPool(self._listView, panel)
                end
                panel:removeFromParent()
                panel = nil
                if isTitleInfo ~= true then
                    panel = ComponentUtils:popListViewItemPool(self._listView)
                end
                
                if panel == nil then
                    panel = itemClone:clone()  --重新创建 --TODO可优化
                end
                
                panel:setVisible(true)
--                panel:setTouchEnabled(false)
                panel:setAnchorPoint(cc.p(0,0))
                panel:setScale(1)
                local dx = (size.width - itemClone:getContentSize().width) / 2
                panel:setPosition(cc.p(dx, self._itemsMargin))
                panel:setTag(123)
                panel.isTitleInfo = isTitleInfo
                cell:addChild(panel)
            end
            self._updateDataCallback(panel, info, idx)
        end

        return cell
    end

    local function numberOfCellsInTableView(table)
        local visible = self._panel:isVisible() --and self._panel:isModuleVisible() 不做模块的隐藏判断，直接渲染
        local num = 0 --不显示时，则不触发Touch事件
        if visible == true then
            num = #self._listData
        end
        return num
    end

    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    tableView:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    
    self._tableView = tableView
end

function UIExpandTableView:initTableViewData(data)
    self._listData = data
    self._tableView:reloadData()
end

--TODO刷新当前的
function UIExpandTableView:updateTableViewData(data, isNotReload)

    self._tableView:setVisible(true)
    local oldOffset = self._tableView:getContentOffset()
    local isOffset = true
    if #self._listData == 0 then
        isOffset = false
    end
    self._listData = data
    
    if isNotReload == true then
        return
    end
    
    self._tableView:reloadData()

    local offset = self._tableView:minContainerOffset()
    if oldOffset.y < offset.y then
        oldOffset = cc.p(oldOffset.x, offset.y)
    end
    if isOffset == true then
        self._tableView:setContentOffset(oldOffset)
    end
end

--function UIExpandTableView

--跳转到某个Index
--index从0开始计数
function UIExpandTableView:jumpToIndex(index)
--    print("--------dTableView:jumpToIndex-------", index)
    local minOffset = self._tableView:minContainerOffset()
    
    local y = minOffset.y + ( self._itemHeight * 1 / NodeUtils:getAdaptiveScale() ) * index
    
    local maxOffset = self._tableView:maxContainerOffset()
    if y > maxOffset.y then
        y = maxOffset.y
    end
    
    self._tableView:setContentOffset(cc.p(minOffset.x, y))
end

function UIExpandTableView:setVisible(visible)
    self._tableView:setVisible(visible)
end


