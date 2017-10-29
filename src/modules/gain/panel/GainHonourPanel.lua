GainHonourPanel = class("GainHonourPanel", BasicPanel)
GainHonourPanel.NAME = "GainHonourPanel"

GainHonourPanel.FOREVERTIME = 90000000  --没有倒计时的Buff

function GainHonourPanel:ctor(view, panelName)
	GainHonourPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function GainHonourPanel:finalize()
	GainHonourPanel.super.finalize(self)
end

function GainHonourPanel:initPanel()
    GainHonourPanel.super.initPanel(self)
    self._listData = {}
    self._timeItem = {}
    self._buffShowConfig = ConfigDataManager:getConfigData(ConfigData.BuffShowConfig)

    self._scrollview = self:getChildByName("scrollView")
    self._ItemUIIndex = 1
end

function GainHonourPanel:registerEvents()
	GainHonourPanel.super.registerEvents(self)
end

--匹配listView渲染有进度条的数据
function GainHonourPanel:matchItemData(data)
    local listData = {}
    local index = 0
    for k,v in pairs(data) do
        if v.buffType == 1 then 
            for j, i in pairs(self._buffShowConfig) do
                if v.itemId == i.ID then
                    -- print("荣誉Buff ",v.powerId,v.type,v.time, v.remainTime)

                    i.remainTime = v.remainTime

                    i.powerId = v.powerId
                    i.itemId = v.itemId
                    i.type = v.type
                    i.time = v.time
                    i.layer = v.layer

                    index = index + 1
                    listData[index] = i
                    break
                end
            end

        end
    end
    return listData
end

function GainHonourPanel:doLayout()
    self:adaptivePanel()
end

-- function GainHonourPanel:mergeData(data1,data2)
--     local tempData = data2
--     for k,v in pairs(data1) do
--         for j, i in pairs(self._buffShowConfig) do
--             if v == i.ID then
--                 table.insert(tempData,i)
--                 break
--             end
--         end
--     end
--     return tempData
-- end

function GainHonourPanel:adaptivePanel()
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(self._scrollview,10, tabsPanel)
    self:createScrollViewItemUIForDoLayout(self._scrollview)
end

--数据初始化
function GainHonourPanel:onShowHandler()
    if self._listView then
        self._listView:jumpToTop()
    end

    local proxy = self:getProxy(GameProxys.ItemBuff)
    --两种buff
    self._bufferShowIds  = proxy:getItemBuffInfos()
    -- local bufferIds = proxy:getBufferShowIds()
    
    self._listData = self:matchItemData(self._bufferShowIds)

    --把两种buff合并到self._listData里
    -- self._listData = self:mergeData(bufferIds,self._listData)

    -- 从小到大排序显示
    table.sort( self._listData, function(a,b) return a.itemId < b.itemId end )

    self:renderScrollView(self._scrollview, "itemPanel", self._listData, self, self.renderItemPanel, self._ItemUIIndex, 6)
    self._ItemUIIndex = nil
end

--数据更新
function GainHonourPanel:onItemBufferUpdate(data)
    self:onShowHandler()    
end

function GainHonourPanel:renderItemPanel(itemPanel,info,index)
   if itemPanel == nil then 
        logger:error("=================itemPanel is nil !!!================")
        return 
    end

    -- print("渲染列表项 ",index)

    if itemPanel.itemChildren == nil then
        itemPanel.itemChildren = self:getItemChildren(itemPanel)
    end

    -- 标题
    local item = itemPanel.itemChildren
    item.title:setString(info.title)
    item.proPanel:setVisible(false)
    
    -- 数量
    --logger:info("info.layer %d",info.layer)
    item.number:setString("")
    if info.layer and info.layer > 1 then
        item.number:setString("x" .. info.layer)

        local x = item.title:getPositionX() + item.title:getContentSize().width + 4
        item.number:setPositionX(x)
    end

    --图标 
    local iconInfo = {}
    iconInfo.power = GamePowerConfig.Other
    iconInfo.typeid = info.icon
    iconInfo.num = 0

    local icon = item.icon
    if icon == nil then
        local iconImg = item.iconImg
        icon = UIIcon.new(iconImg,iconInfo,false)
        item.icon = icon
    else
        icon:updateData(iconInfo)
    end
    --描述
    item.desc:setString(info.info)

    item.data = info -- 刷新的数据设置

    if info.remainTime~= nil and info.remainTime > 0 then
        if info.remainTime == GainHonourPanel.FOREVERTIME then
            item.proPanel:setVisible(false)
            logger:info(info.info.. "  false")
            
            return
        end

        item.proPanel:setVisible(true)
        logger:info(info.info.. "  true")
        self:initTimeProgress(info, item)
    end
    
end


function GainHonourPanel:initTimeProgress(data, item)
    self._timeItem[item] = item

    local buffProxy = self:getProxy(GameProxys.ItemBuff)
    local time = buffProxy:getBuffRemainTimeByMore(data.itemId, data.type, data.powerId, 1)

    logger:info(data.info.. "  time: "..time)

    local labelTime = item.labelTime

    if time > 0 then
        local timeStr = TimeUtils:getStandardFormatTimeString8(time)
        local percent = (data.time-time)/data.time*100
        item.proBar:setPercent(percent)
        labelTime:setString(timeStr)
    else
        item.proBar:setPercent(0)
        item.proPanel:setVisible(false)
    end 
end

function GainHonourPanel:runTimeProgress()
    local buffProxy = self:getProxy(GameProxys.ItemBuff)
    for k , v in pairs(self._timeItem) do
        if v.data.remainTime ~= nil and v.data.remainTime > 0 then
            local proBar = v.proBar
            local time = buffProxy:getBuffRemainTimeByMore(v.data.itemId, v.data.type, v.data.powerId, 1)
           
           
            -- 永久buff也有倒计时，容错归零判断
            if v.data.remainTime == GainHonourPanel.FOREVERTIME then
                time = 0
            end

            if time > 0 then
                v.proPanel:setVisible(true)
                local labelTime = v.labelTime
                local timeStr = TimeUtils:getStandardFormatTimeString8(time)
                local percent = (v.data.time-time)/v.data.time*100
                proBar:setPercent(percent)
                labelTime:setString(timeStr)    
            else
                v.proPanel:setVisible(false)
                proBar:setPercent(0)
                self._timeItem[v] = nil
            end
        end
    end
end

--获取item的子节点
function GainHonourPanel:getItemChildren(itemPanel)
    local itemChildren = {}
    itemChildren.iconImg = itemPanel:getChildByName("Image_icon")
    itemChildren.desc = itemPanel:getChildByName("desc")
    itemChildren.title = itemPanel:getChildByName("title")
    itemChildren.status = itemPanel:getChildByName("status")
 	itemChildren.number = itemPanel:getChildByName("number")
    
    itemChildren.proPanel  = itemPanel:getChildByName("Panel_progress")
    itemChildren.proBar    = itemChildren.proPanel:getChildByName("ProgressBar")
    itemChildren.labelTime = itemChildren.proPanel:getChildByName("Label_time")

    itemChildren.number:setString("")
    itemChildren.labelTime:setString("")
    itemChildren.proBar:setPercent(0)
    itemChildren.proPanel:setVisible(false)   

    return itemChildren
end

function GainHonourPanel:update()
    self:runTimeProgress()
end 
