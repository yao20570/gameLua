-- 任务奖励预览
TaskRewardPreviewPanel = class("TaskRewardPreviewPanel", BasicPanel)
TaskRewardPreviewPanel.NAME = "TaskRewardPreviewPanel"

function TaskRewardPreviewPanel:ctor(view, panelName)
    TaskRewardPreviewPanel.super.ctor(self, view, panelName, 760)
    
    self:setUseNewPanelBg(true)
end

function TaskRewardPreviewPanel:finalize()
    TaskRewardPreviewPanel.super.finalize(self)
end

function TaskRewardPreviewPanel:initPanel()
	TaskRewardPreviewPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(1325))
    _conf = ConfigDataManager:getConfigDataBySortId(ConfigData.ActiveRewardConfig)
    
    self._listView = self:getChildByName("mainPanel/ListView_1")
end

function TaskRewardPreviewPanel:onShowHandler()
    -- body
    local items = self._listView:getItems()
    if table.size(items) > 1 then
        -- print("预览···self._listView:jumpToTop()")
        self._listView:jumpToTop()
    else
        -- print("预览···self:renderListView(self._listView, _conf, self, self.onRenderItem)")
        self:renderListView(self._listView, _conf, self, self.onRenderItem)
    end

end

function TaskRewardPreviewPanel:onRenderItem(itempanel, info, index)
    -- body
    -- print("···onRenderItem index="..index)
    
    itempanel:setVisible(true)
    
    local rewardID = StringUtils:jsonDecode(info.fixreward)
    local iconTab = {1,2,3,4}

    -- local Image_10 = itempanel:getChildByName("Image_10")
    
    local active = itempanel:getChildByName("active")
    active:setString(string.format(self:getTextWord(1326),info.activeneed))


    for i=1,#rewardID do
        local rewardData = ConfigDataManager:getRewardConfigById(rewardID[i])
        local iconImg = itempanel:getChildByName("icon"..i)
        local iconName = iconImg:getChildByName("iconName")
        iconImg:setVisible(true)

        local color = ColorUtils:getColorByQuality(rewardData.color)
        iconName:setColor(color)        
        iconName:setString(rewardData.name)

        local iconInfo = {}
        iconInfo.power = rewardData.power
        iconInfo.typeid = rewardData.typeid
        iconInfo.num = rewardData.num
        
        -- local icon = UIIcon.new(iconImg, iconInfo, true)     

        local icon = iconImg.icon
        if icon == nil then
            icon = UIIcon.new(iconImg, iconInfo, true, self)
            iconImg.icon = icon
        else
            icon:updateData(iconInfo)
        end


        table.remove(iconTab,1)
    end

    for i=1,#iconTab do
        local iconImg = itempanel:getChildByName("icon"..iconTab[i])
        iconImg:setVisible(false)
    end

end

-- 点击icon
-- function TaskRewardPreviewPanel:onIconBtn(sender)
--     -- body
--     self:showSysMessage("onIconBtn")
-- end

function TaskRewardPreviewPanel:onClosePanelHandler()
    self:hide()
end
---------------------------------------------------------------------

