
LegionRecommendPanel = class("LegionRecommendPanel", BasicPanel)
LegionRecommendPanel.NAME = "LegionRecommendPanel"

function LegionRecommendPanel:ctor(view, panelName)
    LegionRecommendPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function LegionRecommendPanel:finalize()
    LegionRecommendPanel.super.finalize(self)
end

function LegionRecommendPanel:initPanel()
	LegionRecommendPanel.super.initPanel(self)

    --listView
    self._legionListView = self:getChildByName("legionListV_0")
    local item = self._legionListView:getItem(0)
    item:setVisible(false)

    --
    self._legionProxy = self:getProxy(GameProxys.Legion)
end

------
-- 响应初始化
function LegionRecommendPanel:registerEvents()
	LegionRecommendPanel.super.registerEvents(self)
    -- 换一批
    local changeBtn = self:getChildByName("downPanel/searchBtn")
    self:addTouchEventListener(changeBtn, self.onTouchChange)
end

------
-- 自适应doLayout
function LegionRecommendPanel:doLayout()
    -- 自适应
    local tabsPanel = self:getTabsPanel()
    local downPanel = self:getChildByName("downPanel")
    NodeUtils:adaptiveListView(self._legionListView,downPanel,tabsPanel,GlobalConfig.topTabsHeight)
end

-------
-- 切换刷新
function LegionRecommendPanel:onShowHandler()
    LegionRecommendPanel.super.onShowHandler(self)
    self:updateLegionRecommend()
end

------
--  刷新数据
function LegionRecommendPanel:updateLegionRecommend()
    self._itemList = {}

    -- 新推荐列表不为空则用推荐列表
    if self._legionProxy:getNewRecommendList() ~= nil then
        self._legionListInfos = self._legionProxy:getNewRecommendList()

        self._legionListView:jumpToTop()

        self:renderListView(self._legionListView, self._legionListInfos, self, self.renderItemPanel)
    end 

    
end

------
-- 切换的时候改变
function LegionRecommendPanel:onTabChangeEvent(tabControl)
    local downWidget = self:getChildByName("downPanel")
    LegionRecommendPanel.super.onTabChangeEvent(self, tabControl, downWidget)
    
end

------
-- 换一批按钮功能回调
function LegionRecommendPanel:onTouchChange(sender)
    self._legionProxy:onTriggerNet220105Req()
end


function LegionRecommendPanel:renderItemPanel(itemPanel, info)
    if itemPanel == nil then
        print("===============itemPanel ========== nil !!!")
        return 
    end 
    itemPanel:setVisible(true)
    self._itemList[info.id] = itemPanel
    local rankKey = itemPanel:getChildByName("Label_19")
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
    -- capacityTxt:setPositionY(capacityTxt_0:getPositionY())
    nameTxt:setString(name)
    levelTxt:setString("Lv."..level)
    rankTxt:setString(string.format(self:getTextWord(3126),rank))
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

    --start 人数 富文本 ---------------------------------------------------------------------
    local str1 = "("
    local str2 = curNum
    local str3 = string.format("/%d)", maxNum)
    local txtTab = {{{str1,18,"#FFFFFF"},{str2,18,ColorUtils.commonColor.Green},{str3,18,"#FFFFFF"}}}
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
    --stop 人数 富文本 -----------------------------------------------------------------

    itemPanel.info = info
    
    if itemPanel.isAddEvent ~= true then
        itemPanel.isAddEvent = true
        self:addTouchEventListener(itemPanel, self.onItemPanelTouch)
    end


    NodeUtils:setEnable(applyBtn,true)
    local proxy = self:getProxy(GameProxys.LordCity)
    local isSetChildLegion,_,isSelfLegion = proxy:isSetChildLegion()
    if isSetChildLegion then
        -- 任命附团
        applyBtn:setTitleText(self:getTextWord(370069))
        if isSelfLegion == name then
            NodeUtils:setEnable(applyBtn,false)
        end
    else
        -- ÉêÇë°´Å¥
        if state == 1 then
            applyBtn:setTitleText(self:getTextWord(3125))
        else
            applyBtn:setTitleText(self:getTextWord(3124))
        end
    end

    -- 暂时调用弹窗
    applyBtn.info = info
    if applyBtn.isAddEvent ~= true then
        applyBtn.isAddEvent = true
        self:addTouchEventListener(applyBtn, self.onItemPanelTouch)
    end


end



---------回调函数定义---------------------
--查看详细信息
function LegionRecommendPanel:onItemPanelTouch(sender)
    local info = sender.info
    if info == nil then
        logger:error("¸Ã¾üÍÅµÄinfo is nil. ÎÞ·¨²é¿´.")
        return
    end
    --查看详细信息
    local infoPanel = self:getPanel(LegionApplyInfoPanel.NAME)
    infoPanel:show(info)
    local data = {}
    data.id = info.id
    self.view:dispatchEvent(LegionApplyEvent.LEGION_DETAIL_REQ,data)
end


--更新军团申请信息
function LegionRecommendPanel:updateLegionInfo(id,type)
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


--任命附团更新
function LegionRecommendPanel:updateChildLegion(data)
    
end

