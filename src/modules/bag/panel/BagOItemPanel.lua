-- 其他道具
BagOItemPanel = class("BagOItemPanel", BasicPanel)
BagOItemPanel.NAME = "BagOItemPanel"

function BagOItemPanel:ctor(view, panelName)
    BagOItemPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function BagOItemPanel:finalize()
    BagOItemPanel.super.finalize(self)
end

function BagOItemPanel:doLayout()
    local tabsPanel = self:getTabsPanel()
    -- local listView =  self:getChildByName("bgListView")
    local bgScrollView =  self._bgScrollView
    NodeUtils:adaptiveListView(bgScrollView, GlobalConfig.downHeight,tabsPanel,GlobalConfig.topTabsHeight)

    self:createScrollViewItemUIForDoLayout(bgScrollView)
end

function BagOItemPanel:initPanel()
    BagOItemPanel.super.initPanel(self)

    self._updateCDUIMap = {}

    self._bgScrollView = self:getChildByName("bgScrollView")   
end   

--每次打开面板时调用
function BagOItemPanel:onShowHandler()
    local itemProxy = self:getProxy(GameProxys.Item)
    local otherList= itemProxy:getItemByClassify(3)
    self.itemList = TableUtils:splitData(otherList, 3)
    local bgScrollView = self:getChildByName("bgScrollView")
    
    self:renderScrollView(bgScrollView, "itemPanel", self.itemList, self, self.renderItemPanel,nil,GlobalConfig.scrollViewRowSpace)
end

function BagOItemPanel:update(dt)
    for k, itemUI in pairs(self._updateCDUIMap) do
        local itemData = itemUI.itemData
        if itemData ~= nil then
            local typeid = itemData.serverData.typeid
            local itemCfgData = ConfigDataManager:getInfoFindByOneKey("ItemConfig","ID",typeid)  
               
            self:setItemUIProgressbar(itemUI, itemCfgData)
        end
    end
end

function BagOItemPanel:setItemUIProgressbar(itemUI, itemCfgData)
    local remainTime, allTime
    local isUpdateProgressBar = false
    if itemCfgData.use == ItemProxy.USE_TYPE_SINGLE then
        local itemProxy = self:getProxy(GameProxys.Item)
        remainTime, allTime = itemProxy:getCDGroup(itemCfgData.cdgroup)                
        if remainTime ~= nil and remainTime > 0 and allTime ~= nil then
            if itemUI.progressbar == nil then
                local panelIcon = itemUI:getChildByName("panelIcon")        
                itemUI.progressbar = ComponentUtils:addItemCDProgressBar(panelIcon, "images/bag/bar.png")
                itemUI.progressbar:setLocalZOrder(2)

                local txtTime = ccui.Text:create()
                txtTime:setFontName(GlobalConfig.fontName)
                txtTime:setFontSize( 16 )
                txtTime:setAnchorPoint(0.5, 0.5)
                txtTime:setLocalZOrder(3)
                panelIcon:addChild(txtTime)
                itemUI.txtTime = txtTime
            end
            isUpdateProgressBar = true
        end
    end

    
    if itemUI.progressbar then
        if isUpdateProgressBar == true then
            local percent = remainTime / allTime * 100 
            itemUI.progressbar:setPercent(percent)
            itemUI.progressbar:setVisible(true)

            itemUI.txtTime:setString(TimeUtils:getStandardFormatTimeString61(remainTime))
            itemUI.txtTime:setVisible(true)
        else
            itemUI.progressbar:setVisible(false)
            itemUI.txtTime:setVisible(false)
        end
    end
end

function BagOItemPanel:hideCallBack()
    -- 关闭时滑到最高
    --[[
    if self._listView then
        self._listView:jumpToTop()
    end
    logger:info("其他  hideCallBack()")
    local itemProxy = self:getProxy(GameProxys.Item)
    itemProxy:setCurIndex(0)
    --]]
    local bgScrollView = self:getChildByName("bgScrollView")
    self:renderScrollView(bgScrollView, "itemPanel", self.itemList, self, self.renderItemPanel,1,GlobalConfig.scrollViewRowSpace)
    local itemProxy = self:getProxy(GameProxys.Item)
    itemProxy:setCurIndex(0)
end

function BagOItemPanel:renderItemPanel(listItem, data, index)
    local itemBtn01 = listItem:getChildByName("itemBtn01")
    local itemBtn02 = listItem:getChildByName("itemBtn02")
    local itemBtn03 = listItem:getChildByName("itemBtn03")
    
    self:setItemView(itemBtn01, data[1], (index - 1) * 3 + 1)
    self:setItemView(itemBtn02, data[2], (index - 1) * 3 + 2)
    self:setItemView(itemBtn03, data[3], (index - 1) * 3 + 3)
end

function BagOItemPanel:setItemView(item, itemInfo, index)
    
    self._updateCDUIMap[item] = item
    item.itemData = itemInfo
    item:setVisible(itemInfo ~= nil)
    if itemInfo == nil then
        return
    end

	local serverData = itemInfo["serverData"]
	local excelInfo = itemInfo["excelInfo"]

    item:setVisible(true)
    local typeid = serverData.typeid
    local txtName = item:getChildByName("txtName")
    local btnUse = item:getChildByName("btnUse")
    local btnLook = item:getChildByName("btnLook")
    local container = item:getChildByName("panelIcon")
    local info = ConfigDataManager:getInfoFindByOneKey("ItemConfig","ID",typeid,true)
    btnUse.info = info  
    -- local enterStr = StringUtils:getStringAddBackEnter(info.info, 12)

    txtName:setString(info.name)
    txtName:setColor(ColorUtils:getColorByQuality(info.color))
    
    self:setItemUIProgressbar(item, info)

    local itemProxy = self:getProxy(GameProxys.Item)
    local isCanUse = itemProxy:isCanUse(typeid)
    if isCanUse == false then
        if itemProxy:isSpeItem(info.type) then--4027道具特殊处理
            btnUse:setVisible(true)
            btnLook:setVisible(false)
            btnUse:setTitleText(TextWords:getTextWord(5058))--合成
        else
            btnUse:setVisible(false)
            btnLook:setVisible(true)
            btnUse:setTitleText(TextWords:getTextWord(5059))--使用
        end
    else
        btnUse:setVisible(true)
        btnLook:setVisible(false)
    end

    -- local info1 = ConfigDataManager:getInfoFindByOneKey("ItemConfig","ID",101)
    -- serverData.power = GamePowerConfig.Item
    -- local icon = UIIcon.new(container,serverData)
    -- local spriteIcon = icon:createIcon(info1.icon, "itemIcon", info.color, serverData.num)
    ----lll
    serverData.power = GamePowerConfig.Item
    local data = serverData
    local icon = container.icon
    if icon == nil then
        icon = UIIcon.new(container, data, true, self)
        icon:setTouchEnabled(true)  --自身不响应触摸事件，将触摸事件传递给父级节点
        container.icon = icon
    else
        icon:updateData(data)
    end
    -- btnUse.data = data
    -- btnUse.index = index
    -- self:addTouchEventListener(btnUse,self.useEvents)
    --btnUse:setVisible(false)

    btnLook.data = data
    btnLook.index = index
    self:addTouchEventListener(btnLook,self.lookEvents)

    if isCanUse then
        -- 数据
        btnUse.data = data
        btnUse.index = index
        self:addTouchEventListener(btnUse,self.useEvents)
    else
        local sendData = {}
        sendData.typeId = info.ID
        sendData.num = data.num
        btnUse.data = sendData
        self:addTouchEventListener(btnUse,self.uselessEvents)
    end
    
    -- 整体的响应事件
    --[[
    if isCanUse then
        -- 数据
        item.data = data
        item.index = index
        item.info = info 
        self:addTouchEventListener(item,self.useEvents)
    else
        local sendData = {}
        sendData.typeId = info.ID
        sendData.num = data.num
        item.data = sendData
        self:addTouchEventListener(item,self.uselessEvents)
    end
    --]]
end

------
--点击合成按钮
function BagOItemPanel:uselessEvents(sender)
    local info = sender.info
    local data = sender.data
    local itemProxy = self:getProxy(GameProxys.Item)
    if itemProxy:isSpeItem(info.type) == true then
        local msg = itemProxy:composeMsg(data.typeId,data.num)
        if msg then
            function okCallBack()
                itemProxy:compose(data.typeId)
            end
            self:showMessageBox(msg, okCallBack)
        end
    else
        self:showSysMessage(self:getTextWord(5051))
    end
end

function BagOItemPanel:useEvents(sender)
    self.lastTypeid = sender.data.typeid

    self.view:useEvents(sender, self.itemList)
end

function BagOItemPanel:lookEvents(sender)
    local data = sender.data
    UIIconTip.new(self:getParent(), data, true, self)
end