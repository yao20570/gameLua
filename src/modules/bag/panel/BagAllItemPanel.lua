-- 所有道具
BagAllItemPanel = class("BagAllItemPanel", BasicPanel)
BagAllItemPanel.NAME = "BagAllItemPanel"

function BagAllItemPanel:ctor(view, panelName)
    BagAllItemPanel.super.ctor(self, view, panelName) 
    self:registerEvents()

    self:setUseNewPanelBg(true)

end

function BagAllItemPanel:finalize()

    BagAllItemPanel.super.finalize(self)
end

function BagAllItemPanel:doLayout()
    -- local listView =  self:getChildByName("bgListView")
    local bgScrollView =  self._bgScrollView
    local tabsPanel = self:getTabsPanel()
    -- NodeUtils:adaptiveListView(listView, GlobalConfig.downHeight,tabsPanel,GlobalConfig.topTabsHeight)
    NodeUtils:adaptiveListView(bgScrollView, GlobalConfig.downHeight,tabsPanel,GlobalConfig.topTabsHeight)
    bgScrollView._oldY = bgScrollView:getPositionY()

    self:createScrollViewItemUIForDoLayout(bgScrollView)
end

function BagAllItemPanel:initPanel()
    BagAllItemPanel.super.initPanel(self)

    self._updateCDUIMap = {}


    -- self._listView = self:getChildByName("bgListView")
    self._bgScrollView = self:getChildByName("bgScrollView")
    
    -- local item = listView:getItem(0)
    -- item:setVisible(false)
    local item = self._bgScrollView:getChildByName("itemPanel")
    item:setVisible(false)

    
end

--每次打开面板时调用
function BagAllItemPanel:onShowHandler()
    if self:isModuleRunAction() then
        return
    end

    local itemProxy = self:getProxy(GameProxys.Item)
    local itemList = itemProxy:getAllItemList()
    self.itemList = TableUtils:splitData(itemList, 3)

    local bgScrollView = self:getChildByName("bgScrollView")
    self:renderScrollView(bgScrollView, "itemPanel", self.itemList, self, self.renderItemPanel, nil, GlobalConfig.scrollViewRowSpace)
end

function BagAllItemPanel:update(dt)
    for k, itemUI in pairs(self._updateCDUIMap) do
        local itemData = itemUI.itemData
        if itemData ~= nil then
            local typeid = itemData.typeid
            local itemCfgData = ConfigDataManager:getInfoFindByOneKey("ItemConfig","ID",typeid)  
               
            self:setItemUIProgressbar(itemUI, itemCfgData)
        end
    end
end

function BagAllItemPanel:setItemUIProgressbar(itemUI, itemCfgData)
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

                local r_table = cc.rect(10,0,1,1)
                local rUrl = "images/newGui2/Frame_bg_box.png"
                local txtTimeBg = TextureManager:createScale9ImageView(rUrl, r_table)
                txtTimeBg:setAnchorPoint(0,0.5)
                txtTimeBg:setLocalZOrder(3)
                txtTimeBg:setPosition(-38,31)
                itemUI.txtTimeBg = txtTimeBg
                panelIcon:addChild(txtTimeBg)

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
            itemUI.txtTime:setPosition(-40+itemUI.txtTime:getContentSize().width/2 + 2,40-itemUI.txtTime:getContentSize().height/2)
            itemUI.txtTime:setVisible(true)
            itemUI.txtTimeBg:setVisible(true)
        else
            itemUI.progressbar:setVisible(false)
            itemUI.txtTime:setVisible(false)
            itemUI.txtTimeBg:setVisible(false)
        end
    end
end


function BagAllItemPanel:onAfterActionHandler()
    self:onShowHandler()
end

function BagAllItemPanel:hideCallBack()

    local bgScrollView = self:getChildByName("bgScrollView")
    self:renderScrollView(bgScrollView, "itemPanel", self.itemList, self, self.renderItemPanel, 1, GlobalConfig.scrollViewRowSpace)
    local itemProxy = self:getProxy(GameProxys.Item)
    itemProxy:setCurIndex(0)
end

function BagAllItemPanel:renderItemPanel(listItem, data, index)

    local itemBtn01 = listItem:getChildByName("itemBtn01")
    local itemBtn02 = listItem:getChildByName("itemBtn02")
    local itemBtn03 = listItem:getChildByName("itemBtn03")

    self:setItemView(itemBtn01, data[1], (index - 1) * 3 + 1)
    self:setItemView(itemBtn02, data[2], (index - 1) * 3 + 2)
    self:setItemView(itemBtn03, data[3], (index - 1) * 3 + 3)

end

function BagAllItemPanel:setItemView(item, itemInfo, index)

    self._updateCDUIMap[item] = item
    item.itemData = itemInfo
    item:setVisible(itemInfo ~= nil)
    if itemInfo == nil then
        return
    end

    local itemProxy = self:getProxy(GameProxys.Item)
    local itemList = itemProxy:getItemNumByType(itemInfo.typeid)
    local typeid = itemInfo.typeid
    local info = ConfigDataManager:getInfoFindByOneKey("ItemConfig", "ID", typeid)
    
        
    local btnUse = item:getChildByName("btnUse")
    local btnLook = item:getChildByName("btnLook")
    local container = item:getChildByName("panelIcon")
    local txtName = item:getChildByName("txtName")
        
    btnUse.info = info
    txtName:setString(info.name)
    txtName:setColor(ColorUtils:getColorByQuality(info.color))

    self:setItemUIProgressbar(item, info)

    local isCanUse = itemProxy:isCanUse(itemInfo.typeid)
    if isCanUse == false then
        if itemProxy:isSpeItem(info.type) then
            -- 4027道具特殊处理
            btnUse:setVisible(true)
            btnLook:setVisible(false)
            -- 合成
            btnUse:setTitleText(TextWords:getTextWord(5058))
        else
            btnUse:setVisible(false)
            btnLook:setVisible(true)
        end
    else
        btnUse:setVisible(true)
        btnLook:setVisible(false)
        -- 使用
        btnUse:setTitleText(TextWords:getTextWord(5059))
    end

    itemInfo.power = GamePowerConfig.Item
    local data = itemInfo
    local icon = container.icon
    if icon == nil then
        icon = UIIcon.new(container, data, true, self)
        -- 自身不响应触摸事件，将触摸事件传递给父级节点
        icon:setTouchEnabled(true)
        container.icon = icon
    else
        icon:updateData(data)
    end


    btnLook.data = data
    self:addTouchEventListener(btnLook, self.lookEvents)

    if isCanUse then
        -- 数据
        btnUse.data = data
        btnUse.info = info
        self["item" .. data.typeid] = item
        self:addTouchEventListener(btnUse, self.useEvents)
    else
        local sendData = { }
        sendData.typeId = info.ID
        sendData.num = data.num
        btnUse.data = sendData
        btnUse.info = info
        self:addTouchEventListener(btnUse, self.uselessEvents)
    end

end

--点击合成按钮
function BagAllItemPanel:uselessEvents(sender)
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

function BagAllItemPanel:useEvents(sender)

    self.lastTypeid = sender.data.typeid

    self.view:useEvents(sender, self.itemList)
end

function BagAllItemPanel:lookEvents(sender)
    local data = sender.data
    UIIconTip.new(self:getParent(), data, true, self)
end


