
LegionListPanel = class("LegionListPanel", BasicPanel)
LegionListPanel.NAME = "LegionListPanel"

function LegionListPanel:ctor(view, panelName)
    LegionListPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function LegionListPanel:finalize()
    LegionListPanel.super.finalize(self)
end

function LegionListPanel:initPanel()
    LegionListPanel.super.initPanel(self)
    -- self:setBgType(ModulePanelBgType.NONE)

    --listView
    -- self._legionListView = self:getChildByName("legionListV")
    self._legionScrollView = self:getChildByName("legionScrollView")
    local item = self._legionScrollView:getChildByName("pnlItem")
    item:setVisible(false)


    --复选框 
    self._checkBoxTxt = self:getChildByName("downPanel/Label_23_0")
    self._checkBox = self:getChildByName("downPanel/joinBox")
    local onCheckBoxClicked  = function() 
        self:onCheckBoxClicked(self._checkBox)
    end
    self._checkBox:addEventListener(onCheckBoxClicked)
    --输入框
    local inputPanel = self:getChildByName("downPanel/Panel_search")
    local defualtTxt = self:getTextWord(3141)
    -- self._editeBox = ComponentUtils:addEditeBox(inputPanel,18,defualtTxt)
    self._editeBox = ComponentUtils:addEditeBox(inputPanel,18,defualtTxt,nil,false,"images/newGui9Scale/SpKeDianJiBg.png")


end

function LegionListPanel:doLayout()
    -- 自适应
    local tabsPanel = self:getTabsPanel()
    local downPanel = self:getChildByName("downPanel")
    local legionScrollView = self:getChildByName("legionScrollView")
    NodeUtils:adaptiveListView(legionScrollView,downPanel,tabsPanel,GlobalConfig.topTabsHeight)
    self:createScrollViewItemUIForDoLayout(legionScrollView)
end


function LegionListPanel:onTabChangeEvent(tabControl)
    local downWidget = self:getChildByName("downPanel")
    LegionListPanel.super.onTabChangeEvent(self, tabControl, downWidget)
end


function LegionListPanel:registerEvents()
    LegionListPanel.super.registerEvents(self)
    local cleanBtn = self:getChildByName("downPanel/Panel_search/resetBtn")
    local searchBtn = self:getChildByName("downPanel/searchBtn")
    self:addTouchEventListener(cleanBtn,self.onCleanBtnTouch)
    self:addTouchEventListener(searchBtn,self.onSearchBtnTouch)
end


function LegionListPanel:onShowHandler(data)
    LegionListPanel.super.onShowHandler(self)
    self._legionListInfos = self:getProxy(GameProxys.Legion):getLegionApplyList()
    if self._legionListInfos ~= nil then
        self:renderList(self._legionListInfos)
    end
    self:resetPanel()
    self:updateCheckBox()
end

-- 获取副盟的id
function LegionListPanel:getOldLegionName(data)
    local proxy = self:getProxy(GameProxys.LordCity)
    local isSetChildLegion,cityId,_ = proxy:isSetChildLegion()
    local cityHost = proxy:getCityHostById(cityId)
    if cityHost == nil then
        return nil
    end

    for k,v in pairs(data) do
        if v.name == cityHost.viceLegion then
            return v.name
        end
    end
    return nil
end

function LegionListPanel:updateCheckBox()  
    local proxy = self:getProxy(GameProxys.LordCity)
    local isSetChildLegion,_,_ = proxy:isSetChildLegion()
    if isSetChildLegion then
        -- 任命时 隐藏
        self._checkBox:setVisible(false)
        self._checkBoxTxt:setVisible(false)
    else
        -- 非任命时 显示
        self._checkBox:setVisible(true)
        self._checkBoxTxt:setVisible(true)
    end
end

------
-- 开始渲染列表
function LegionListPanel:onAfterActionHandler()
    self:updateLegionList(self._legionListInfos)
end
    
-- 进行了两次，第二次才有信息
--更新军团列表数据LegionApplyView:updateLegionList(shortInfos) 中预先调用
function LegionListPanel:updateLegionList(shortInfos)
    self._legionListInfos = shortInfos
    if self._legionListInfos == nil then
        self._legionListInfos = {}
    end 

    if self:isModuleRunAction() then
        return
    end
    
    self:renderList(self._legionListInfos)
end
--筛选、清除、搜索
function LegionListPanel:updateLegionList2(listInfos)
    if listInfos == nil then
        listInfos = {}
    end 
    self:renderList(listInfos)
end 
function LegionListPanel:renderList(infos)
    self._itemList = {}
    self._curShowListInfos = infos
    local tempInfos = infos
    local state = self._checkBox:getSelectedState()
    if state == true then
        tempInfos = self:getJoinEnableInfos(infos)
    end 
    -- table.sort(tempInfos,function(a,b) return a.rank < b.rank end)
    -- self._legionListView:jumpToTop()

    self._oldLegionName = self:getOldLegionName(tempInfos)

    self.tempInfos = tempInfos

    -- self:renderListView(self._legionListView, tempInfos, self, self.renderItemPanel)
    self:renderScrollView(self._legionScrollView, "pnlItem",
                                tempInfos, self, self.renderItemPanel,1,GlobalConfig.scrollViewRowSpace)
end

--更新军团申请信息
function LegionListPanel:updateLegionInfo(id,type)
    local legionInfos = self._legionListInfos
    for k,v in pairs(legionInfos)do
        if v.id == id then
            if type == 1 then --申请
                self._legionListInfos[k].applyState = 1
            else --取消申请
                self._legionListInfos[k].applyState = 0
            end 
            local itemPanel = self._itemList[id]
            local info = self._legionListInfos[k]
            self:renderItemPanel(itemPanel,info)
            return 
        end 
    end 
end
function LegionListPanel:renderItemPanel(itemPanel, info)
    if itemPanel == nil then
        -- print("===============itemPanel ========== nil !!!")
        return 
    end 
    itemPanel:setVisible(true)
    self._itemList[info.id] = itemPanel
    local rankKey = itemPanel:getChildByName("Label_18")
    local rankTxt = itemPanel:getChildByName("rankTxt")
    local nameTxt = itemPanel:getChildByName("nameTxt")
    local levelTxt = itemPanel:getChildByName("levelTxt")
    local numTxt = itemPanel:getChildByName("numTxt")
    local capacityTxt = itemPanel:getChildByName("capacityTxt")
    local capacityTxt_0 = itemPanel:getChildByName("capacityTxt_0")
    local stateTxt = itemPanel:getChildByName("stateTxt")
    local applyBtn = itemPanel:getChildByName("applyBtn")
    local rank     = info.rank
    local name     = info.name
    local level    = info.level
    local curNum   = info.curNum
    local maxNum   = info.maxNum
    local capacity = info.capacity
    local state    = info.applyState

    capacityTxt_0:setString(self:getTextWord(141))
    capacityTxt:setPositionY(capacityTxt_0:getPositionY())
    nameTxt:setString(name)
    levelTxt:setString("Lv."..level)
    rankTxt:setString(""..rank)
    -- numTxt:setString(string.format("(%d/%d)", curNum,maxNum))
    capacityTxt:setString(StringUtils:formatNumberByK(capacity,0))

    -- 左对齐
    -- local nameSize = nameTxt:getContentSize()
    -- local namePosX,namePosY = nameTxt:getPosition()
    -- levelTxt:setPosition(namePosX + nameSize.width + 10, namePosY)
    NodeUtils:alignNodeL2R(nameTxt,levelTxt)
    NodeUtils:alignNodeL2R(capacityTxt_0,capacityTxt)
    NodeUtils:alignNodeL2R(rankKey,rankTxt)
    
    if state == 1 then
        local lvSize = levelTxt:getContentSize()
        local lvPosX,lvPosY = levelTxt:getPosition()
        stateTxt:setPosition(lvSize.width + lvPosX + 5,lvPosY)
        stateTxt:setString(self:getTextWord(3132))
    else
        stateTxt:setString("")
    end


    --start 人数 富文本 ------------------------------------------------------------------
    local str1 = "("
    local str2 = curNum
    local str3 = string.format("/%d)", maxNum)
    local txtTab = {{{str1,22,"#FFFFFF"},{str2,18,ColorUtils.commonColor.Green},{str3,18,"#FFFFFF"}}}
    numTxt:setString("")

    -- 纯文字富文本显示
    local richInfoLab = itemPanel.richInfoLab
    if richInfoLab == nil then
     richInfoLab = ComponentUtils:createRichLabel("", nil, nil, 2)
     richInfoLab:setPosition(numTxt:getPosition())
     numTxt:getParent():addChild(richInfoLab)
     itemPanel.richInfoLab = richInfoLab
    end
    richInfoLab:setString(txtTab)
    --stop 人数 富文本 ------------------------------------------------------------------

    itemPanel.info = info
    
    if itemPanel.isAddEvent ~= true then
        itemPanel.isAddEvent = true
        self:addTouchEventListener(itemPanel, self.onItemPanelTouch)
    end

    NodeUtils:setEnable(applyBtn,true)
    applyBtn:setVisible(true)
    
    local proxy = self:getProxy(GameProxys.LordCity)
    local isSetChildLegion,cityId,isSelfLegion = proxy:isSetChildLegion()
    local cityHost = proxy:getCityHostById(cityId)
    if isSetChildLegion then
        -- 任命附团
        if isSelfLegion == name then
            applyBtn:setVisible(false)  --占领军团，隐藏
        else
            if self._oldLegionName and self._oldLegionName == info.name then
                -- logger:info("--附团 AAA已任命 %s",name)
                applyBtn:setTitleText(self:getTextWord(370070))  --已任命，不可点击
                NodeUtils:setEnable(applyBtn,false)
            else
                -- logger:info("--附团 BBB任命 %s",name)
                applyBtn:setTitleText(self:getTextWord(370069))  --任命，可以点击
            end
        end

    else
        -- 申请状态
        if state == 1 then
            applyBtn:setTitleText(self:getTextWord(3125)) --取消申请
        else
            applyBtn:setTitleText(self:getTextWord(3124))  --申请
        end
    end

    -- 暂时调用弹窗
    applyBtn.info = info
    if applyBtn.isAddEvent ~= true then
        applyBtn.isAddEvent = true
        self:addTouchEventListener(applyBtn, self.onItemPanelTouch)
    end

end

--重置面板
function LegionListPanel:resetPanel()
    -- if self._legionListView ~= nil then
    --     self._legionListView:jumpToTop()
    -- end

    self:renderScrollView(self._legionScrollView, "pnlItem",
                                self.tempInfos or {} , self, self.renderItemPanel,1,GlobalConfig.scrollViewRowSpace)

    self._checkBox:setSelectedState(false)
    self._editeBox:setText("")
end 

--筛选可加入的军团
function LegionListPanel:getJoinEnableInfos(infos)
    local temp = {}
    local infos = infos
    if infos == nil then
        -- print("infos == nil")
        return temp
    end 
    for _,v in pairs(infos) do
        local isPacked = v.curNum >= v.maxNum 
        if v.isCanJoin == 1 and (not isPacked) then
            table.insert(temp,v)
        end 
    end 
    return temp
end 

---------回调函数定义---------------------
--查看详细信息
function LegionListPanel:onItemPanelTouch(sender)
    local info = sender.info
    if info == nil then
        logger:error("该军团的info is nil. 无法查看.")
        return
    end
    --查看详细信息
    info.oldLegionName = self._oldLegionName
    local infoPanel = self:getPanel(LegionApplyInfoPanel.NAME)
    infoPanel:show(info)
    local data = {}
    data.id = info.id
    self.view:dispatchEvent(LegionApplyEvent.LEGION_DETAIL_REQ,data)
end
--复选框
function LegionListPanel:onCheckBoxClicked(sender)
    local state = sender:getSelectedState()
    local infos = self._curShowListInfos
    self:updateLegionList2(infos)
end 

--清除
function LegionListPanel:onCleanBtnTouch(sender)
    self._editeBox:setText("")
    local state = self._checkBox:getSelectedState()
    local infos = self._legionListInfos
    self:updateLegionList2(infos)
end 

--搜索
function LegionListPanel:onSearchBtnTouch(sender)
    local name = self._editeBox:getText()
    -- print("name===",name)
    if name == "" or name == nil then
        local tempStr = self:getTextWord(3142)
        self:showSysMessage(tempStr)
        return 
    end 
    local data = {}
    data.name = name
    self.view:dispatchEvent(LegionApplyEvent.LEGION_SEARCH_REQ,data)
end 

--申请按钮
function LegionListPanel:onApplyBtnTouch(sender)
    local userData = sender.userData
    local applyState = userData.applyState
    local limitLv  = userData.limitLv
    local limitFig = userData.limitFig
    local legionId = self._legionId
    local roleProxy = self:getProxy(GameProxys.Role)
    local roleLv   = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    local roleFig  = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_highestCapacity)
    local tempStr1 = self:getTextWord(3145)
    local tempStr2 = self:getTextWord(3146)
    local tempStr3 = self:getTextWord(3147)
    --是否满足SortList
    local legionName = self._legionName
    local tempStr
    if limitLv > roleLv and limitFig > roleFig then
        tempStr = string.format(tempStr3,legionName,limitLv,limitFig)
    elseif limitLv > roleLv then
        tempStr = string.format(tempStr1,legionName,limitLv)
    elseif limitFig > roleFig then
        tempStr = string.format(tempStr2,legionName,limitFig)
    end 
    if tempStr ~= nil then
        self:showSysMessage(tempStr)
        return
    end 
    
    local type = 1
    if applyState == 1 then
        type = 2
    end 
    -- print("id,state====",legionId,applyState)
    --请求申请
    local data = {}
    data.id = legionId
    data.type = type
    self:dispatchEvent(LegionApplyEvent.LEGION_APPLY_REQ, data)
    
    self:onClosePanelHandler()
end

--任命附团推送
function LegionListPanel:updateChildLegion49(data)
    -- logger:info("--任命附团推送 49")
    local newLegionName = data.legionName
    local item1,item2
    local legionInfos = self._legionListInfos
    for k,v in pairs(legionInfos)do
        
        if self._oldLegionName and v.name == self._oldLegionName then
            -- logger:info("--任命附团更新 任命 %d %s",k,v.name)
            local itemPanel = self._itemList[v.id]
            local info = self._legionListInfos[k]
            item1 = itemPanel
            info1 = info
        end
        if v.name == newLegionName then
            -- logger:info("--任命附团更新 已任命 %d %s",k,v.name)
            local itemPanel = self._itemList[v.id]
            local info = self._legionListInfos[k]
            item2 = itemPanel
            item2.info = info
        end 
    end
    
    if item1 then
        self._oldLegionName = nil
        self:renderItemPanel(item1,item1.info)
    end
    if item2 then
        self._oldLegionName = newLegionName
        self:renderItemPanel(item2,item2.info)
    end

end


