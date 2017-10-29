
PWPartsPanel = class("PWPartsPanel", BasicPanel, UIWatchOrdnance)
PWPartsPanel.NAME = "PWPartsPanel"

function PWPartsPanel:ctor(view, panelName)
    PWPartsPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function PWPartsPanel:finalize()
    PWPartsPanel.super.finalize(self)
end

function PWPartsPanel:initPanel()
    PWPartsPanel.super.initPanel(self)
    self._partsProxy = self:getProxy(GameProxys.Parts)
    self._listView = self:getChildByName("ListView")
    local batchBtn = self:getChildByName("downPanel/Button_batchResolve")
    self:addTouchEventListener(batchBtn, self.onBatchBtnClicked)
    self._addTitleStr = self:getTextWord(8242)
end

function PWPartsPanel:doLayout()
    local downPanel = self:getChildByName("downPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(self._listView,downPanel,tabsPanel,GlobalConfig.topTabsHeight)
end

function PWPartsPanel:onTabChangeEvent(tabControl)
    local panel = self:getPanel(PWPartsPanel.NAME)
    local downWidget = panel:getChildByName("downPanel")
    PWPartsPanel.super.onTabChangeEvent(self, tabControl, downWidget)

end

function PWPartsPanel:onShowHandler()
    PWPartsPanel.super.onShowHandler(self)
    self.view._close = false
    if not self.first then
        self.first = true
        TimerManager:addOnce(800, self.updateListView, self)
    else
        self:updateListView()
    end
end
--更新
function PWPartsPanel:updateListView(data)
    local partsProxy = self:getProxy(GameProxys.Parts)
    local unEquipParts = partsProxy:getOrdnanceUnEquipInfos()
    if unEquipParts == nil then
        unEquipParts = {}
    end

    --print("unEquipParts len ====",#unEquipParts)
    
    local temp = TableUtils:splitData(unEquipParts, 3)
    self:renderListView(self._listView, temp, self, self.renderItemPanel,nil,nil,LayoutConfig.scrollViewRowSpace)
     
end

function PWPartsPanel:renderItemPanel(itemPanel, info, index)
    --print("#info============",#info)
    for i = 1, 3 do
        local nameStr = "Button_cell"..i
        local cell = itemPanel:getChildByName(nameStr)
        cell:setVisible(true)
        self["item" .. (index * 3 + i) ] = cell
        -- 显示新型层
        local iconImg = cell:getChildByName("iconImg")
        local nameTxt = cell:getChildByName("nameTxt")
        --初始化cell
        local v = info[i]
        if v ~= nil then
            local data = {}
            data.num = 1 
            data.power = GamePowerConfig.Ordnance 
            data.typeid = v.typeid
            data.parts = v
            data.equip = 1
            data.tag = 1--1军械2宝具
            self._enableTouch = true
            if cell.uiIcon == nil then
                local uiIcon = UIIcon.new(cell,data,false, self)
                uiIcon:setPosition(iconImg:getPositionX(), iconImg:getPositionY())
                cell.uiIcon = uiIcon
            else
                cell.uiIcon:updateData(data)
            end 
            local btnTouch = cell:getChildByName("btnTouch")
            self:addTouchEventListener(btnTouch, self.onCellClicked)
            btnTouch._data = cell.uiIcon._data
            -- setString
            local iconValueData = cell.uiIcon._data
            local configData = self._partsProxy:getDataFromOrdnanceConfig(iconValueData.parts)
            -- 名称
            nameTxt:setString(configData.name)
            local quality = iconValueData.parts.quality
            nameTxt:setColor(ColorUtils:getColorByQuality(quality))
            local attrNames , attrNums = self._partsProxy:initAttrData(configData)
            -- 重置隐藏
            for i = 1, 2 do
                local titleTxt = cell:getChildByName( string.format( "titleTxt0%s",i))
                local valueTxt = cell:getChildByName( string.format( "valueTxt0%s",i))
                titleTxt:setVisible(false)
                valueTxt:setVisible(false)
            end
            -- 属性名
            local titleTxts = {}
            for key, value in pairs(attrNames) do
                local titleTxt = cell:getChildByName( string.format( "titleTxt0%s",key))
                value = string.gsub(value, self._addTitleStr, "")
                titleTxt:setString(value)
                titleTxt:setVisible(true)
                titleTxts[key] = titleTxt
            end
            -- 属性数值
            local titleVals = {}
            for key, value in pairs(attrNums) do
                local valueTxt = cell:getChildByName( string.format( "valueTxt0%s",key))
                valueTxt:setString("+"..value)
                valueTxt:setVisible(true)
                titleVals[key] = valueTxt
            end
            NodeUtils:centerNodes(nameTxt, {
                    cell:getChildByName( string.format( "titleTxt0%s",1)),
                    cell:getChildByName( string.format( "valueTxt0%s",1))})
            NodeUtils:centerNodes(nameTxt, {
                    cell:getChildByName( string.format( "titleTxt0%s",2)),
                    cell:getChildByName( string.format( "valueTxt0%s",2))})

            -- 位置调整
            -- for i = 1, 2 do
            --     local titleTxt = cell:getChildByName( string.format( "titleTxt0%s",i))
            --     local valueTxt = cell:getChildByName( string.format( "valueTxt0%s",i))
                -- NodeUtils:fixTwoNodePos(titleTxt, valueTxt, 3)
            -- end
        else
            if cell.uiIcon then
                cell.uiIcon:finalize()
                cell.uiIcon = nil
            end 
            --cell:removeAllChildren() -- 不能删除，会导致获取不到，动态增加的时候每列第二个出现报错
            cell:setVisible(false)
        end 
        
    end 
end 
-------------------------回调函数--------------------------

--点击按钮
function PWPartsPanel:onCellClicked(sender)
    local uiWatchOrdnance = UIWatchOrdnance.new(self, sender._data)
    self["equipBtn"] = uiWatchOrdnance.equipBtn
   
    --显示配件信息
end 
        
---------查看配件面板按钮功能实现------

--分解  
function PWPartsPanel:onPartTouchHandler(data)
    local data = data
    
    local partsInfo = data.parts
   --[[
    local partsProxy = self:getProxy(GameProxys.Parts)
    local sdata = {}
    sdata.id = {}
    sdata.id[1] = partsInfo.id  
    partsProxy:ordnanceResolveReq(sdata)
    --]]
    local temp = {}
    temp.tag = 1 --军械分解
    temp.isBatch = false --是否是批量分解
    temp.datas = {}
    temp.datas[1] = partsInfo
    UIResolvePreview.new(self, temp)
    
    
end 
--强化
function PWPartsPanel:onStrengthTouchHandler(data)
    local data = data
    local temp = {}
    temp.moduleName = "PartsStrengthenModule"
    temp.extraMsg = {}
    temp.extraMsg.data = data
    temp.extraMsg.index = 1
    temp.extraMsg.panelName = "PartsIntensifyPanel"
    self:dispatchEvent(PartsWarehouseEvent.SHOW_OTHER_EVENT,temp)
end 
--改造
function PWPartsPanel:onReformTouchHandler(data)
    local data = data
    local temp = {}
    temp.moduleName = "PartsStrengthenModule"
    temp.extraMsg = {}
    temp.extraMsg.data = data
    temp.extraMsg.index = 2
    temp.extraMsg.panelName = "PartsRemouldPanel"
    self:dispatchEvent(PartsWarehouseEvent.SHOW_OTHER_EVENT,temp)
end 
--配件卸下
function PWPartsPanel:onWearTouchHandler(data)
    local partsInfo = data.parts
    local partsProxy = self:getProxy(GameProxys.Parts)
    local senddata = {}
    senddata.id = partsInfo.id  --配件id
    partsProxy:ordnanceUnwieldReq(senddata)
end 
--配件装备
function PWPartsPanel:onEquipTouchHandler(data)
    local partsInfo = data.parts
    local partsProxy = self:getProxy(GameProxys.Parts)
    local senddata = {}
    senddata.id = partsInfo.id  --配件id
    partsProxy:ordnanceEquipedReq(senddata, PWPartsPanel.NAME)
end 
--进阶
function PWPartsPanel:onEvolveTouchHandler(data)
    local data = data
    local temp = {}
    temp.moduleName = "PartsStrengthenModule"
    temp.extraMsg = {}
    temp.extraMsg.data = data
    temp.extraMsg.index = 3
    temp.extraMsg.panelName = "PartsEvolvePanel"
    if data.parts.remoulv < 4 then
        temp.extraMsg.index = 2
        temp.extraMsg.panelName = "PartsRemouldPanel"
        self:showSysMessage(self:getTextWord(8229))
    end
    self:dispatchEvent(PartsWarehouseEvent.SHOW_OTHER_EVENT,temp)
end  
--批量分解
function PWPartsPanel:onBatchBtnClicked(sender)
    local panel = self:getPanel(PWBatchSelectPanel.NAME)
    panel:show(1)
end                           