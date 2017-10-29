--宝具仓库（宝具标签）
HeroTreaAllItemPanel = class("HeroTreaAllItemPanel", BasicPanel)
HeroTreaAllItemPanel.NAME = "HeroTreaAllItemPanel"

function HeroTreaAllItemPanel:ctor(view, panelName)
    HeroTreaAllItemPanel.super.ctor(self, view, panelName)

end

function HeroTreaAllItemPanel:finalize()
    HeroTreaAllItemPanel.super.finalize(self)
end

function HeroTreaAllItemPanel:initPanel()
	HeroTreaAllItemPanel.super.initPanel(self)
	self.proxy = self:getProxy(GameProxys.HeroTreasure)
	self._listView = self:getChildByName("ListView")
    local batchBtn = self:getChildByName("bottonPanel/batchResolveBtn")
    self:addTouchEventListener(batchBtn, self.onBatchBtnClicked)
    local defaultItem = self._listView:getItem(0)
    self._listView:setItemModel(defaultItem) 
end
function HeroTreaAllItemPanel:doLayout()
    local downPanel = self:getChildByName("bottonPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(self._listView,downPanel,tabsPanel,GlobalConfig.topTabsHeight)
end
function HeroTreaAllItemPanel:onShowHandler()
    HeroTreaAllItemPanel.super.onShowHandler(self)
    self:updateListView()
end
--更新
function HeroTreaAllItemPanel:updateListView(data)
    local heroTreasureProxy = self:getProxy(GameProxys.HeroTreasure)
    local allTreasureInfos = heroTreasureProxy:getUnEquipInfosList()
    if allTreasureInfos == nil then
        allTreasureInfos = {}
    end
    if #allTreasureInfos == 0 then
        self:showSysMessage(self:getTextWord(3809))
    end

    
    local temp = {}
    local count = 0
    local t 
    for k,v in pairs(allTreasureInfos)do
        if v ~= nil then
            if count == 0 then
                t = {}
            end 
            table.insert(t,v)
            count = count + 1
            if k == #allTreasureInfos then
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
function HeroTreaAllItemPanel:renderItemPanel(itemPanel, info, index)
    --print("#info============",#info)
    for i = 1, 2 do
        local nameStr = "cellBtn"..i
        local cell = itemPanel:getChildByName(nameStr)
        cell:setVisible(true)
        -- 显示新型层
        local iconImg = cell:getChildByName("iconImg")
		local nameTxt = cell:getChildByName("nameTxt")
        self:addTouchEventListener(cell, self.onCellClicked)
        --初始化cell
        local v = info[i]
        if v ~= nil then
            local data = {}
            data.num = i 
            data.power = GamePowerConfig.HeroTreasure 
            data.typeid = v.typeid
            data.parts = v
            data.equip = 1
            data.tag = 2--1军械2宝具
            self._enableTouch = true
            if cell.uiIcon == nil then
                local uiIcon = UIIcon.new(cell,data,false, self)
                uiIcon:setPosition(iconImg:getPositionX(), iconImg:getPositionY())
                cell.uiIcon = uiIcon
            else
                cell.uiIcon:updateData(data)
                -- cell.uiIcon:finalize()
                -- cell.uiIcon = nil
                -- local uiIcon = UIIcon.new(cell,data,false, self)
                -- uiIcon:setPosition(iconImg:getPositionX(), iconImg:getPositionY())
                -- cell.uiIcon = uiIcon
            end 
            -- setString
            local iconValueData = cell.uiIcon._data
            local configData = self.proxy:getDataFromTreasureBaseConfig(iconValueData.typeid)
            -- 名称
            nameTxt:setString(configData.name)
            local quality = configData.color
            nameTxt:setColor(ColorUtils:getColorByQuality(quality))

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
--点击cell
function HeroTreaAllItemPanel:onCellClicked(sender)
     local cell = sender
     --UIWatchOrdnance.new(self, cell.uiIcon._data)
     local panel = self:getPanel(HeroTreaDetailPanel.NAME)
     panel:show(cell.uiIcon._data) 
   
end 
function HeroTreaAllItemPanel:registerEvents()
	HeroTreaAllItemPanel.super.registerEvents(self)
end
--批量分解
function HeroTreaAllItemPanel:onBatchBtnClicked(sender)
    local panel = self:getPanel(HTBatchSelectPanel.NAME)
    panel:show(3)
end 