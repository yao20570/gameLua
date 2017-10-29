--[[
下：60
上：760
]]

UITabControl = class("UITabControl")

--changConditionFunc 切换标签的判断函数，return false则不能切换
function UITabControl:ctor(panel, changConditionFunc, isNew)
    local uiSkin = UISkin.new("UITab")
   -- local bgImg = uiSkin:getChildByName("bgImg")
   -- NodeUtils:adaptive(bgImg)
   

    local parent = panel:getParent()
    uiSkin:setParent(parent)
    
    panel:setTabControl(self)
    
    local function defaultChangeFunc(panelName)
        return true
    end
    
    self._changConditionFunc = changConditionFunc or defaultChangeFunc
    
    
    uiSkin:setTouchEnabled(false)
    self._uiSkin = uiSkin
    -- self._uiPanelBg = UIPanelBg.new(self._uiSkin:getRootNode())    

    self._panel = panel
    self._tabItemList = {}
    self._tabItemIndexMap = {}
    
    self._index = 0
    self._tabsPanel = uiSkin:getChildByName("tabsPanel")
    self._mb=uiSkin:getChildByName("mb")
    self._chainPanel = uiSkin:getChildByName("chainPanel") 
    self._chainPanel:setVisible(false)
    -- self._tabItem1 = uiSkin:getChildByName("tabsPanel/tabItem")
    self._tabItem1 = self._tabsPanel:getChildByName("tabItem")
    self._tabItemParent = self._tabItem1:getParent()
    
    self._tabItem1:getChildByName("txt"):setColor(ColorUtils.commonColor.c3bMiaoShu)

    self.marge = -6
    self.width = self._tabItem1:getContentSize().width
    self.y = self._tabItem1:getPositionY()
    
    panel:setBgImg3Tab()
    
    local tabBg = uiSkin:getChildByName("tabBg")
    NodeUtils:adaptive(tabBg)
    
    self._tabBg = tabBg
    self._defaultSize = tabBg:getContentSize() --默认尺寸
    self._defaultPos = cc.p(tabBg:getPosition())

    
    -- 标签自适应
    NodeUtils:adaptiveTabs(self._tabsPanel, true)

end

--重置tab背景大小
function UITabControl:resetTabBgSize()
    self._tabBg:setContentSize(self._defaultSize)
    local scale = NodeUtils:getAdaptiveScale()
    self._tabBg:setPosition(self._defaultPos.x / scale, self._defaultPos.y )
    self:setDownLineStatus(false)
end

--设置背景的相对于下面的偏移量
function UITabControl:setDownOffset(downWidget)
    local scale = NodeUtils:getAdaptiveScale()
    
    local size = downWidget:getContentSize()
    local newSize = cc.size(self._defaultSize.width, self._defaultSize.height - size.height / scale)
    self._tabBg:setContentSize(newSize)
    
    
    self._tabBg:setPosition(self._defaultPos.x / scale, self._defaultPos.y + size.height / scale / 2 / scale)
    self:setDownLineStatus(true)
end

function UITabControl:setDownLineStatus(status)
    local tabBg = self._uiSkin:getChildByName("tabBg")
    local Image_1 = tabBg:getChildByName("Image_1")
    Image_1:setVisible(status)
end
----------------
--添加标签面板
function UITabControl:addTabPanel(name, content,isshowbg)
    self._index = self._index + 1
    self:insertTabItem(self._index, name, content,isshowbg)
end

function UITabControl:getCurPanelName()
    local data = self._tabItemList[self._curTabSelectIndex]
    return data.panelName
end

----------------------------------------------------------------------
function UITabControl:insertTabItem(index, name, content,isshowbg)
    self._tabItemIndexMap[name] = index
    local item = self["_tabItem" .. index]
    if item == nil then
        local newItem = self._tabItem1:clone()
        local preItem = self["_tabItem" .. (index - 1)]
        newItem:setPositionX(preItem:getPositionX() + self.width + self.marge)
        self._tabItemParent:addChild(newItem)
        
        self["_tabItem" .. index] = newItem
        item = newItem
    end

    if self.showbg==nil then
        self.showbg={}
    end
    if isshowbg~=nil then
    self.showbg[index]=isshowbg
    end
    
    local tabBtn1 = item:getChildByName("tabBtn1" )
    local tabBtn2 = item:getChildByName("tabBtn2" )
    local Image_tip = item:getChildByName("Image_tip" )
    -- local count = item:getChildByName("count" )
    tabBtn1.index = index
    tabBtn2.index = index
    Image_tip:setVisible(false)
    
    self:registerTabItemEvent(item)
    
    self:setTabContent(item, content)
    self._tabItemList[index] = {item = item, panelName = name}
end

function UITabControl:finalize()
       self:finalizeCCB()
end
function UITabControl:setItemCount(index,isShow,Count)
    if self._tabItemList[index] == nil then
        return
    end
    local Image_tip = self._tabItemList[index].item:getChildByName("Image_tip" )
    local count = Image_tip:getChildByName("count" )
    if isShow == true then
        Image_tip:setVisible(true)
        count:setString(tostring(Count))
        if Count == 0 then
            Image_tip:setVisible(false)
        end
        --调整数量文本的尺寸
        -- local labWidth = count:getContentSize().width
        local fontSize = Count >= 100 and 16 or 20
        count:setFontSize(fontSize)
    else
        Image_tip:setVisible(false)
    end
end

--//给小红点 加一个向上的标记
function UITabControl:setLevelUp(index,bool)
    if self._tabItemList[index] == nil then
        self:finalizeCCB()
        return
    end
    local txt = self._tabItemList[index].item:getChildByName("txt")

    if bool then
        if self._levelUpEffect == nil then
         self._levelUpEffect = UICCBLayer.new("rgb-jiantou", txt)
         self._levelUpEffect:setPosition(40,-30)
         self._levelUpEffect:setScale(0.9)
         else
         self._levelUpEffect:setVisible(true)
        end
    else
         if self._levelUpEffect~= nil then
         self._levelUpEffect:setVisible(false)
         end
    end
end

--//特效释放
function UITabControl:finalizeCCB()
	if self._levelUpEffect ~= nil then
		self._levelUpEffect:finalize()
		self._levelUpEffect = nil
	end
end


--这个只是用来设置选择的标签名称，设置默认Panel
function UITabControl:setTabSelectByName(name)
    local index = self._tabItemIndexMap[name]
    if index == nil then
        return false
    end

    self._panel:setDefaultTabPanelName(name)
    -- self:setTabSelect(index)
    
    return true
end

--切换至选择的标签
function UITabControl:changeTabSelectByName(name)
    local index = self._tabItemIndexMap[name]
    if index == nil then
        return false
    end

    local flag = self:setTabSelect(index)
    
    return flag
end

function UITabControl:updateTabName(panelName, content)
    local index = self._tabItemIndexMap[panelName]
    local data = self._tabItemList[index]
    self:setTabContent(data.item, content)
end

function UITabControl:getTabNameByIndex(index)
    local data = self._tabItemList[index]
    return data.panelName
end

function UITabControl:setTabSelect(index, guideValue)
    
    if self._curTabSelectIndex == index then
        return false
    end
    
    if self.showbg~=nil then
        if self.showbg[index] then
            self._mb:setVisible(true)
        else
            self._mb:setVisible(false)
        end
    end

    -- -- 切换标签前先走回调
    if self._changConditionFunc ~= nil then
        local panelName = self:getTabNameByIndex(index)
        local oldPanelName
        if self._oldTabSelectIndex ~= nil then
            local oldData = self._tabItemList[self._oldTabSelectIndex]
            oldPanelName = oldData.panelName
        end
        if self._changConditionFunc(self._panel, panelName, oldPanelName) ~= true then --条件未满足，不可切换
            print("--条件未满足，不可切换到标签",panelName)
            return false
        end
    end
    
    if self._oldTabSelectIndex ~= nil then
        local oldData = self._tabItemList[self._oldTabSelectIndex]
        self:setTabState(oldData.item, false)
        local panel = self._panel:getPanel(oldData.panelName)
        if panel:isVisible() == true then
            panel:hideVisibleCallBack()
        end
        panel:hideCallBack()
        panel:hide()
    end
    

    local data = self._tabItemList[index]
    self:setTabState(data.item, true)
    local panel = self._panel:getPanel(data.panelName)
    panel:setGuideValue(guideValue)
    panel:show()
    panel:setTouchEnabled(false)
    panel:onTabChangeEvent(self)

    self._curTabSelectIndex = index
    self._oldTabSelectIndex = index

    self._panel:tabChangeMainPanelEvent() -- 执行mainPanel里的回调
    return true
end

-- 手动重置上次标签index
function UITabControl:setOldSelectIndex( index )
    -- body
    if self._oldTabSelectIndex ~= nil then
        local oldData = self._tabItemList[self._oldTabSelectIndex]
        self:setTabState(oldData.item, false)
        local panel = self._panel:getPanel(oldData.panelName)
        panel:hide()
    end

    self._oldTabSelectIndex = index
end

---------2----true为选择  false为不选择---1
function UITabControl:setTabState(tabItem, state)
    local tabBtn1 = tabItem:getChildByName("tabBtn1")
    local tabBtn2 = tabItem:getChildByName("tabBtn2")
    if state == true then
        tabBtn1:setVisible(false)
        tabBtn2:setVisible(true)
        tabItem:getChildByName("txt"):setColor(ColorUtils.commonColor.c3bBiaoTi)
    else
        tabBtn1:setVisible(true)
        tabBtn2:setVisible(false)
        tabItem:getChildByName("txt"):setColor(ColorUtils.commonColor.c3bMiaoShu)
    end
end

function UITabControl:setTabContent(item, content)
    -- for index=1, 2 do
        local tabBtn = item:getChildByName("txt")
        tabBtn:setString(content)
    -- end
end

function UITabControl:registerTabItemEvent(item)
    local tabBtn1 = item:getChildByName("tabBtn1" )
    local tabBtn2 = item:getChildByName("tabBtn2" )
    
    self._panel["tabBtn" .. tabBtn1.index] = tabBtn1
    
    tabBtn2:setVisible(false)
    ComponentUtils:addTouchEventListener(tabBtn1,self.onChangeTabTouch, nil, self, 50)
    ComponentUtils:addTouchEventListener(tabBtn2,self.onChangeTabTouch, nil, self, 50)
end

-- guideValue, 注意这个是新手引导传的值
function UITabControl:onChangeTabTouch(sender, guideValue)
    local index = sender.index
    
    if self._curTabSelectIndex ~= index then
        self:setTabSelect(index, guideValue)
    end
end

function UITabControl:getTabsPanel()
    -- return self._uiSkin:getChildByName("tabsPanel")
    return self._tabsPanel
end

function UITabControl:setLocalZOrder(zOrder)
    self._uiSkin:setLocalZOrder(zOrder)
end

function UITabControl:getLocalZOrder()
    return self._uiSkin:getLocalZOrder()
end

-- 根据标签的索引设置标签的可见性
function UITabControl:setTabVisibleByIndex(index,isShow)
    if self._tabItemList[index] then
        local item = rawget(self._tabItemList[index],"item")
        if item then
            item:setVisible(isShow)
        end
    end
end

-- 根据标签的索引设置标签的图片
function UITabControl:setTabTexturesByIndex(index,normal,selected)
    if self._tabItemList[index] then
        local item = rawget(self._tabItemList[index],"item")
        if item then
            local tabBtn1 = item:getChildByName("tabBtn1" )
            local tabBtn2 = item:getChildByName("tabBtn2" )
            TextureManager:updateButtonNormal(tabBtn1,normal)
            TextureManager:updateButtonPressed(tabBtn1,selected)
            TextureManager:updateButtonNormal(tabBtn2,selected)
            TextureManager:updateButtonPressed(tabBtn2,normal)
        end
    end
end

------
-- 获取标签页数量
function UITabControl:getPanelCount()
    return self._index
end

-- function UITabControl:setBg(bg)
--     local bgImg=self._uiSkin:getChildByName("bgImg")
--     bgImg:setVisible(true)
--     TextureManager:updateImageViewFile(bgImg,bg)
-- end

-- 多个标签页根据可见性自动左对齐
function UITabControl:updateItemPosX()
    local tmpTabList = {}
    for index,v in pairs(self._tabItemList) do
        local item = v.item
        if item:isVisible() == true then
            table.insert(tmpTabList,{index = index, item = item})
        end
    end

    table.sort( tmpTabList, function(a,b) return a.index < b.index end )

    for k,v in pairs(tmpTabList) do
        local preX = self["_tabItem1"]:getPositionX()
        preX = preX + (self.width + self.marge) * (k - 1)
        v.item:setPositionX(preX)
        -- logger:info(" 标签页坐标 6666 %d %d",preX,k)
    end
end

UITabControl.AdaptNode = {}
UITabControl.AdaptNode.LegionCreate = 1
function UITabControl:getBgAdapNode(type)
    if type == UITabControl.AdaptNode.LegionCreate then
        return self._mb:getChildByName("Image_75")
    end
end

--是否显示锁链
function UITabControl:setChainVisbale(isVisable)
    self._chainPanel:setVisible(isVisable)
end


--设置左右锁链X轴位置
function UITabControl:setChainPosition(left, right)
    if left then
        self._chainPanel:getChildByName("leftPanel"):setPositionX(left)
    end
    if right then
        self._chainPanel:getChildByName("rightPanel"):setPositionX(right)
    end
end

--显示四条锁链
function UITabControl:isShow4Chain(isShow)
    self._chainPanel:getChildByName("leftPanel_0"):setVisible(isShow)
    self._chainPanel:getChildByName("rightPanel_0"):setVisible(isShow)
end


--设置四条锁链X轴位置
function UITabControl:setChainPosition(left, left0, right, right0)
    if left then
        self._chainPanel:getChildByName("leftPanel"):setPositionX(left)
    end
    if right then
        self._chainPanel:getChildByName("rightPanel"):setPositionX(right)
    end
    if left0 then
        self._chainPanel:getChildByName("leftPanel_0"):setPositionX(left0)
    end
    if right0 then
        self._chainPanel:getChildByName("rightPanel_0"):setPositionX(right0)
    end
end