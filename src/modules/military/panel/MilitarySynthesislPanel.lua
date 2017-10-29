-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
MilitarySynthesislPanel = class("MilitarySynthesislPanel", BasicPanel)
MilitarySynthesislPanel.NAME = "MilitarySynthesislPanel"

function MilitarySynthesislPanel:ctor(view, panelName)
    MilitarySynthesislPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function MilitarySynthesislPanel:finalize()
    MilitarySynthesislPanel.super.finalize(self)
end

function MilitarySynthesislPanel:initPanel()
	MilitarySynthesislPanel.super.initPanel(self)

    self._isShowSynthesizable = false

    self._listView = self:getChildByName("ListView")
    self._checkBox = self:getChildByName("downPanel/checkShowSynthesis")
	self:addTouchEventListener(self._checkBox, self.showSynthesislItems)
end

function MilitarySynthesislPanel:doLayout()
    local downPanel = self:getChildByName("downPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(self._listView,downPanel,tabsPanel,GlobalConfig.topTabsHeight)
end

function MilitarySynthesislPanel:registerEvents()
	MilitarySynthesislPanel.super.registerEvents(self)
    
end

function MilitarySynthesislPanel:onShowHandler()
    self:updateListView()
end

--更新
function MilitarySynthesislPanel:updateListView()
    local config = ConfigDataManager:getConfigData(ConfigData.SynthetizeConfig)

    local targetItemList = {}
    if self._isShowSynthesizable then
        for k, v in ipairs(config) do
            if self:isSynthesizable(StringUtils:jsonDecode(v.costID)) then
                table.insert(targetItemList, v)
            end
        end
    else
        targetItemList = config
    end

    local temp = TableUtils:splitData(targetItemList, 3)
    self:renderListView(self._listView, temp, self, self.renderItemPanel,nil,nil,LayoutConfig.scrollViewRowSpace)
end

function MilitarySynthesislPanel:renderItemPanel(itemPanel, info)
    for i=1,3 do
        local nameStr = "Button_cell"..i
        local cell = itemPanel:getChildByName(nameStr)
        cell:setVisible(true)
        local iconImg = cell:getChildByName("iconImg")
        local nameTxt = cell:getChildByName("nameTxt")
        local btnTouch = cell:getChildByName("btnTouch")
        --初始化cell
        local v = info[i]
        if v ~= nil then
            local data = {}
	        local tmp = StringUtils:jsonDecode(v.targetID)
            data.num = tmp[1][3]
            data.power = tmp[1][1]--GamePowerConfig.OrdnanceFragment --test
            data.typeid = tmp[1][2]
            btnTouch.data = info[i]
            --data.piece = v
            --data.tag = 1--1军械碎片2宝具碎片
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
            end
            self:addTouchEventListener(btnTouch, self.onCellClicked)
            btnTouch._data = cell.uiIcon._data
            -- 设置文本
            nameTxt:setString(cell.uiIcon._data.name)
            nameTxt:setColor(ColorUtils:getColorByQuality(cell.uiIcon._data.color))
        else
            if cell.uiIcon then
                cell.uiIcon:finalize()
                cell.uiIcon = nil
            end 
            cell:setVisible(false)
        end
    end 
end 

--点击
function MilitarySynthesislPanel:onCellClicked(sender)
    if self._SynthesislDialog == nil then
        self._SynthesislDialog = self:getPanel(MilitarySynthesislDialogPanel.NAME)
    end
    self._SynthesislDialog:show(sender.data)
end 

function MilitarySynthesislPanel:isSynthesizable(costData)
    local itemProxy = self:getProxy(GameProxys.Item)
    local num = 0
    local numCost = 0
    for k, v in pairs(costData) do
        num = itemProxy:getItemNumByType(v[2])
        numCost = v[3]
        if num == 0 or numCost > num then
            return false
        end
    end
    return true
end

function MilitarySynthesislPanel:showSynthesislItems(sender, event)
    self._isShowSynthesizable  = not self._isShowSynthesizable 
    self:updateListView()
end