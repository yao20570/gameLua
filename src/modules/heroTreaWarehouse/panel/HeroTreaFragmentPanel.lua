--宝具仓库（碎片标签）
HeroTreaFragmentPanel = class("HeroTreaFragmentPanel", BasicPanel)
HeroTreaFragmentPanel.NAME = "HeroTreaFragmentPanel"

function HeroTreaFragmentPanel:ctor(view, panelName)
    HeroTreaFragmentPanel.super.ctor(self, view, panelName)

end

function HeroTreaFragmentPanel:finalize()
    HeroTreaFragmentPanel.super.finalize(self)
end

function HeroTreaFragmentPanel:initPanel()
	HeroTreaFragmentPanel.super.initPanel(self)
	self.proxy = self:getProxy(GameProxys.HeroTreasure)
	self._listView = self:getChildByName("ListView")
    local batchBtn = self:getChildByName("bottonPanel/batchResolveBtn")
    self:addTouchEventListener(batchBtn, self.onBatchBtnClicked)
    local defaultItem = self._listView:getItem(0)
    self._listView:setItemModel(defaultItem)  

end
function HeroTreaFragmentPanel:doLayout()
    local downPanel = self:getChildByName("bottonPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(self._listView,downPanel,tabsPanel,GlobalConfig.topTabsHeight)
end
function HeroTreaFragmentPanel:onShowHandler()
    HeroTreaFragmentPanel.super.onShowHandler(self)
    self:updateListView()
end 
function HeroTreaFragmentPanel:updateListView()
    local htProxy = self:getProxy(GameProxys.HeroTreasure)
    local treasurePieceInfos = htProxy:getAllTreasurePieceInfosList()

    if treasurePieceInfos == nil then
        treasurePieceInfos = {}
    end   
    if #treasurePieceInfos == 0 then
        self:showSysMessage(self:getTextWord(3810))
    end
    local temp = {}
    local count = 0
    local t 
    for k,v in pairs(treasurePieceInfos)do
        if v ~= nil then
            if count == 0 then
                t = {}
            end 
            table.insert(t,v)
            count = count + 1
            if k == #treasurePieceInfos then
                table.insert(temp,t)
            else
                if count == 2 then
                    table.insert(temp,t)
                    count = 0
                end
            end 
        end
    end 
    self:renderListView(self._listView, temp, self, self.renderItemPanel)
     
end 
function HeroTreaFragmentPanel:renderItemPanel(itemPanel, info, index)
    for i=1,2 do
        --print("i=========",i)
        local nameStr = "Button_cell"..i
        local cell = itemPanel:getChildByName(nameStr)
        cell:setVisible(true)
        local iconImg = cell:getChildByName("iconImg")
        local nameTxt = cell:getChildByName("nameTxt")
        local memoTxt = cell:getChildByName("memoTxt")
        self:addTouchEventListener(cell, self.onCellClicked)
        --初始化cell
        local v = info[i]
        if v ~= nil then
            local data = {}
            data.num = v.num --test
            data.power = GamePowerConfig.HeroTreasureFragment --test
            data.typeid = v.typeid
            data.piece = v
            data.tag = 2--1军械碎片2宝具碎片
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
            -- 设置文本
            nameTxt:setString(cell.uiIcon._data.name)
            nameTxt:setColor(ColorUtils:getColorByQuality(cell.uiIcon._data.color))
            memoTxt:setString(cell.uiIcon._data.num)
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

function HeroTreaFragmentPanel:registerEvents()
	HeroTreaFragmentPanel.super.registerEvents(self)
end
--点击cell
function HeroTreaFragmentPanel:onCellClicked(sender)
     local cell = sender
     UIWatchOrdnancePiece.new(self, cell.uiIcon._data)
   
    --显示配件信息
end 

--分解
function HeroTreaFragmentPanel:onResolveTouchHandler(data)
    local data = data
    local pieceInfo = data.piece

    local temp = {}
    temp.tag = 4 --宝具碎片分解
    temp.isBatch = false --是否是批量分解
    temp.datas = {}
    temp.datas[1] = pieceInfo
    UIResolvePreview.new(self, temp)
end 
--合成
function HeroTreaFragmentPanel:onCompoundTouchHandler(data)
    local sdata = {}
    sdata.typeid = data.typeid

    local htProxy = self:getProxy(GameProxys.HeroTreasure)
    htProxy:onTriggerNet350005Req(sdata)
end
--获取
function HeroTreaFragmentPanel:onGetTouchHandler(data)
    --local proxy = self:getProxy(GameProxys.Dungeon)
    --proxy:onExterInstanceSender(2)
end
--批量分解
function HeroTreaFragmentPanel:onBatchBtnClicked(sender)
    local panel = self:getPanel(HTBatchSelectPanel.NAME)
    panel:show(4)
end 