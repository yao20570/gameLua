
PWPiecePanel = class("PWPiecePanel", BasicPanel)
PWPiecePanel.NAME = "PWPiecePanel"

function PWPiecePanel:ctor(view, panelName)
    PWPiecePanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function PWPiecePanel:finalize()
    PWPiecePanel.super.finalize(self)
end

function PWPiecePanel:initPanel()
    PWPiecePanel.super.initPanel(self)
    self._listView = self:getChildByName("ListView")
    local defaultItem = self._listView:getItem(0)
    self._listView:setItemModel(defaultItem)  
    
    local batchBtn = self:getChildByName("downPanel/Button_batchResolve")
    self:addTouchEventListener(batchBtn, self.onBatchBtnClicked)
    
    
end

function PWPiecePanel:doLayout()
    local downPanel = self:getChildByName("downPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(self._listView,downPanel,tabsPanel,GlobalConfig.topTabsHeight)
end

function PWPiecePanel:onTabChangeEvent(tabControl)
    local panel = self:getPanel(PWPiecePanel.NAME)
    local downWidget = panel:getChildByName("downPanel")
    PWPiecePanel.super.onTabChangeEvent(self, tabControl, downWidget)
end

function PWPiecePanel:onShowHandler()
    PWPiecePanel.super.onShowHandler(self)
    self:updateListView()
end

--更新
function PWPiecePanel:updateListView(data)
    local defaultItem = self._listView:getItem(0)
    local partsProxy = self:getProxy(GameProxys.Parts)
    local pieceInfos = partsProxy:getPieceInfos()
    
    if pieceInfos == nil then
        pieceInfos = {}
    end
    --print("pieceInfos len========",#pieceInfos)    

    local temp = TableUtils:splitData(pieceInfos, 3)
    self:renderListView(self._listView, temp, self, self.renderItemPanel,nil,nil,LayoutConfig.scrollViewRowSpace)
    
end
 
function PWPiecePanel:renderItemPanel(itemPanel, info)
    for i=1,3 do
        --print("i=========",i)
        local nameStr = "Button_cell"..i
        local cell = itemPanel:getChildByName(nameStr)
        cell:setVisible(true)
        local iconImg = cell:getChildByName("iconImg")
        local nameTxt = cell:getChildByName("nameTxt")
        local memoTxt = cell:getChildByName("memoTxt")
        local btnTouch = cell:getChildByName("btnTouch")
        local Label_22 = cell:getChildByName("Label_22")
        --初始化cell
        local v = info[i]
        if v ~= nil then
            local data = {}
            data.num = v.num --test
            data.power = GamePowerConfig.OrdnanceFragment --test
            data.typeid = v.typeid
            data.piece = v
            data.tag = 1--1军械碎片2宝具碎片
            if cell.uiIcon == nil then
                self._enableTouch = true
                local uiIcon = UIIcon.new(cell,data,false, self)
                uiIcon:setPosition(iconImg:getPositionX(), iconImg:getPositionY())
                cell.uiIcon = uiIcon
            else
                cell.uiIcon:updateData(data)
                -- 设置文本
                nameTxt:setString(data.name)
                nameTxt:setColor(ColorUtils:getColorByQuality(data.color))
                memoTxt:setString(data.num)
            end
            self:addTouchEventListener(btnTouch, self.onCellClicked)
            btnTouch._data = cell.uiIcon._data
            -- 设置文本
            nameTxt:setString(cell.uiIcon._data.name)
            nameTxt:setColor(ColorUtils:getColorByQuality(cell.uiIcon._data.color))
            memoTxt:setString(cell.uiIcon._data.num)
            NodeUtils:centerNodes(iconImg, {memoTxt,Label_22,})
        else
            if cell.uiIcon then
                cell.uiIcon:finalize()
                cell.uiIcon = nil
            end 
            --cell:removeAllChildren()
            cell:setVisible(false)
        end
    end 
end 
-------------------------回调函数--------------------------

--点击
function PWPiecePanel:onCellClicked(sender)
    -- local cell = sender
    UIWatchOrdnancePiece.new(self, sender._data)
end 

function PWPiecePanel:onBatchBtnClicked(sender)
    local panel = self:getPanel(PWBatchSelectPanel.NAME)
    panel:show(2)
end 
--分解
function PWPiecePanel:onResolveTouchHandler(data)
    local data = data
    local pieceInfo = data.piece
    --[[
    local partsProxy = self:getProxy(GameProxys.Parts) 
    local pieceInfo = data.piece
    local sdata = {}
    sdata.type = 1 --单个分解
    sdata.typeid = {}
    sdata.typeid[1] = pieceInfo.typeid
    partsProxy:pieceResolveReq(sdata)
    --]]
    local temp = {}
    temp.tag = 2 --碎片分解
    temp.isBatch = false --是否是批量分解
    temp.datas = {}
    temp.datas[1] = pieceInfo
    UIResolvePreview.new(self, temp)
end 
--合成
function PWPiecePanel:onCompoundTouchHandler(data)
    local partsProxy = self:getProxy(GameProxys.Parts) 
    local pieceInfo = data.piece
    local sdata = {}
    sdata.typeid = pieceInfo.typeid
    partsProxy:pieceCompoundReq(sdata)
end
--获取
function PWPiecePanel:onGetTouchHandler(data)
    local proxy = self:getProxy(GameProxys.Dungeon)
    proxy:onExterInstanceSender(2)
end