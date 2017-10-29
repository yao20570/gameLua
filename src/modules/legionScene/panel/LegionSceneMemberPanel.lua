-- /**
--  * @DateTime:    2016-01-14 11:07:18
--  * @Description: 军团成员
--  */

LegionSceneMemberPanel = class("LegionSceneMemberPanel", BasicPanel)
LegionSceneMemberPanel.NAME = "LegionSceneMemberPanel"

function LegionSceneMemberPanel:ctor(view, panelName)
    LegionSceneMemberPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function LegionSceneMemberPanel:finalize()
    LegionSceneMemberPanel.super.finalize(self)
end

function LegionSceneMemberPanel:initPanel()
	LegionSceneMemberPanel.super.initPanel(self)
    self._memberListView = self:getChildByName("mainp/memberListView")
    local item = self._memberListView:getItem(0)
    item:setVisible(false)

    self._dismissBtn = self:getChildByName("downPanel/dismissBtn")
    self._dismissBtn._oldX = self._dismissBtn:getPositionX()
    self._approveBtn = self:getChildByName("downPanel/examine")
    self._approveBtn._oldX = self._approveBtn:getPositionX()
    self._legionScenePanel = self:getPanel(LegionScenePanel.NAME)
    self:initApprovePoint()
    self:addTouchEventListener(self._dismissBtn, self.dismissLegion)
    self:addTouchEventListener(self._approveBtn, self.onApproveBtnTouch)

    local capacityTxt = self:getChildByName("topPanel/capacityTxt")
    capacityTxt:setString(self:getTextWord(136))
    -- NodeUtils:adaptiveTopPanelAndListView(upWidget, self._memberListView, downWidget, tabsPanel)
end

function LegionSceneMemberPanel:doLayout()
    local downWidget = self:getChildByName("downPanel")
    local topPanel = self:getChildByName("topPanel")
    local Image_32 = self:getChildByName("mainp/Image_32")
    local Image_31 = self:getChildByName("mainp/Image_31")--背景

    local tabsPanel = self:getTabsPanel()

    NodeUtils:adaptiveUpPanel(topPanel,tabsPanel,0)--固定上边缘

    NodeUtils:adaptiveDownPanel(downWidget,nil,GlobalConfig.downHeight)

    NodeUtils:adaptiveDownPanel(Image_32,downWidget,GlobalConfig.downHeight)

    NodeUtils:adaptiveListView(Image_31,Image_32,topPanel,0,0)
    NodeUtils:adaptiveListView(self._memberListView,Image_32,topPanel,0,10)

    -- NodeUtils:adaptiveTopPanelAndListView(Image_31, self._memberListView, downWidget, tabsPanel)

    -- NodeUtils:adaptiveTopPanelAndListView(topPanel, self._memberListView, downWidget, tabsPanel)

    
end

-- 小红点
function LegionSceneMemberPanel:initApprovePoint()
    -- body
    local url = "downPanel/examine/dotBg"
    local dotBg = self:getChildByName(url)
    dotBg:setVisible(false)
    self.dotBg = dotBg
end

--审核界面
function LegionSceneMemberPanel:onApproveBtnTouch()
  local panel = self:getPanel(LegionSceneApprovePanel.NAME)
  panel:show()
end

function LegionSceneMemberPanel:dismissLegion()
    local legionProxy = self:getProxy(GameProxys.Legion)
    local mineInfo = legionProxy:getMineInfo() --玩家个人信息

   local memberInfoList = legionProxy:getMemberInfoList()

    if mineInfo.mineJob == 7 then
        if table.size(memberInfoList) > 5 then
            self:showMessageBox(self:getTextWord(3128),nil,nil,self:getTextWord(100))

        elseif table.size(memberInfoList) <= 5 then
            local function okCallBack()
                local legionProxy = self:getProxy(GameProxys.Legion)
                legionProxy:onTriggerNet220503Req()
            end
            local function cancelCallBack()
            end
            local content = self:getTextWord(3127)
            self:showMessageBox(content,okCallBack,cancelCallBack,self:getTextWord(100),self:getTextWord(101))
        end
    else

        local function okCallBack()
            local roleProxy = self:getProxy(GameProxys.Role)
            local mineID = roleProxy:getPlayerId()

            local data = {}
            data.id = mineID
            data.type = 3
            local legionProxy = self:getProxy(GameProxys.Legion)
            legionProxy:onTriggerNet220201Req(data)
        end
        local function cancelCallBack()
        end
        local content = self:getTextWord(3116)
        self:showMessageBox(content,okCallBack,cancelCallBack,self:getTextWord(100),self:getTextWord(101))
    end


end

function LegionSceneMemberPanel:onTabChangeEvent(tabControl)
    local downWidget = self:getChildByName("downPanel")
    LegionSceneMemberPanel.super.onTabChangeEvent(self, tabControl, downWidget)
end

function LegionSceneMemberPanel:onAfterActionHandler()
    self:onShowHandler()
end

function LegionSceneMemberPanel:onShowHandler()
    -- local Image_31=self:getChildByName("mainp/Image_31")
    -- Image_31:setContentSize(560,self._memberListView:getContentSize().height+57)
    -- local Image_32=self:getChildByName("mainp/Image_32")
    -- Image_31:setPositionY(Image_32:getPositionY())
    -- print("****************************************************************"..Image_32:getPositionY())
    if self:isModuleRunAction() then
        return
    end
    local memberListView = self:getChildByName("mainp/memberListView")
    if memberListView then
        memberListView:jumpToTop()
    end
   local legionProxy = self:getProxy(GameProxys.Legion)
   local mineInfo = legionProxy:getMineInfo() --玩家个人信息

    if mineInfo.mineJob == 7 then
        self._dismissBtn:setTitleText(self:getTextWord(3130))
        self._approveBtn:setVisible(true)
        self._dismissBtn:setPositionX(self._dismissBtn._oldX)
        self._approveBtn:setPositionX(self._approveBtn._oldX)
    elseif mineInfo.mineJob == 6 then
        self._dismissBtn:setTitleText(self:getTextWord(3131))
        self._approveBtn:setVisible(true)
        self._dismissBtn:setPositionX(self._dismissBtn._oldX)
        self._approveBtn:setPositionX(self._approveBtn._oldX)
    else
        self._dismissBtn:setTitleText(self:getTextWord(3131))
        self._approveBtn:setVisible(false)
        NodeUtils:centerNodesGlobal(self._dismissBtn:getParent(),{self._dismissBtn})
    end

   local memberInfoList = legionProxy:getMemberInfoList()
   self._memberInfoList = memberInfoList
   if memberInfoList == nil then
        logger:error("memberInfoList is nil...成员列表数据为空")
   end
   memberInfoList = legionProxy:getSortedList(memberInfoList,1)

   local roleProxy = self:getProxy(GameProxys.Role)
   self._mineID = roleProxy:getPlayerId()

   self:renderListView(memberListView, memberInfoList, self, self.renderItemPanel)
   memberListView:setItemsMargin(0)
   self:onLegionApprovePointUpdate()
end

-- 军团成员界面更新
function LegionSceneMemberPanel:onLegionMemberUpdate()
    -- body
    if self:isVisible() ~= true then
        return
    end

    local memberListView = self:getChildByName("mainp/memberListView")    
    local legionProxy = self:getProxy(GameProxys.Legion)
    local mineInfo = legionProxy:getMineInfo() --玩家个人信息
    local memberInfoList = legionProxy:getMemberInfoList()
    memberInfoList = legionProxy:getSortedList(memberInfoList,1)
    if mineInfo.mineJob == 7 then
        self._dismissBtn:setTitleText(self:getTextWord(3130))
        self._approveBtn:setVisible(true)
        self._legionScenePanel:setItemCount(2,true)
        self._dismissBtn:setPositionX(self._dismissBtn._oldX)
        self._approveBtn:setPositionX(self._approveBtn._oldX)
    elseif mineInfo.mineJob == 6 then
        self._dismissBtn:setTitleText(self:getTextWord(3131))
        self._approveBtn:setVisible(true)
        self._legionScenePanel:setItemCount(2,true)
        self._dismissBtn:setPositionX(self._dismissBtn._oldX)
        self._approveBtn:setPositionX(self._approveBtn._oldX)
    else
        self._dismissBtn:setTitleText(self:getTextWord(3131))
        self._approveBtn:setVisible(false)
        self._legionScenePanel:setItemCount(2,false)
    end

   local roleProxy = self:getProxy(GameProxys.Role)
   self._mineID = roleProxy:getPlayerId()

    self:renderListView(memberListView, memberInfoList, self, self.renderItemPanel)
    memberListView:setItemsMargin(0)
    self:checkForMemberInfoUpdate(memberInfoList)

    -- 请求审批小红点刷新
    self:onLegionApprovePointUpdate()
end

-- 审批小红点更新
function LegionSceneMemberPanel:onLegionApprovePointUpdate()
    -- body
    local legionProxy = self:getProxy(GameProxys.Legion)
    local num = legionProxy:getApprovePoint()
    local job = legionProxy:getMineJob()
    self._legionScenePanel:setItemCount(2,true)
    if job ~= nil and num ~= nil and num > 0 then
        if job == 7 or job == 6 then
            local dot = self.dotBg:getChildByName("dot")
            self.dotBg:setVisible(true)
            dot:setString(num)
            return
        end
    end

    self.dotBg:setVisible(false)

end


-- 查看成员界面更新
function LegionSceneMemberPanel:checkForMemberInfoUpdate(data)
    -- body
    local panel = self:getPanel(LegionSceneMemberInfoPanel.NAME)
    if panel:isVisible() == true then

        for k,v in pairs(data) do
            if v.id == self._memberId then
                panel:onLegionInfoUpdate(v)
                return
            end
        end

    end
end

function LegionSceneMemberPanel:renderItemPanel(itemPanel, memberInfo)
    itemPanel:setVisible(true)
    local rankTxt = itemPanel:getChildByName("rankTxt")         --排名
    local rankImg = itemPanel:getChildByName("rankImg")         --排名
    local nameTxt = itemPanel:getChildByName("nameTxt")         --名称
    local jobTxt = itemPanel:getChildByName("jobTxt")           --职务
    local levelTxt = itemPanel:getChildByName("levelTxt")       --等级
    local capacityTxt = itemPanel:getChildByName("capacityTxt") --战力
    local contributeTxt = itemPanel:getChildByName("contributeTxt") --周贡献
    local mineBg = itemPanel:getChildByName("mineBg")
    local imgTouch = itemPanel:getChildByName("imgTouch")



    imgTouch:setVisible(false)


    local bgImg = itemPanel:getChildByName("bgImg")
    if memberInfo.capityrank % 2 == 1 then
        bgImg:setVisible(true)
    else
        bgImg:setVisible(false)
    end

    if self._mineID == memberInfo.id then
        mineBg:setVisible(true)
        print("is mine")
        mineBg:setOpacity(255)
    else
        mineBg:setVisible(false)
        print("is not mine")
    end


    

    -- print("···capityrank = "..memberInfo.capityrank)
    rankTxt:setString(memberInfo.capityrank)
    nameTxt:setString(memberInfo.name)
    levelTxt:setString(memberInfo.level)
    contributeTxt:setString(memberInfo.devotoWeek)
    capacityTxt:setString( StringUtils:formatNumberByK( memberInfo.capacity, 0))
    
    local legionProxy = self:getProxy(GameProxys.Legion)
    local jobName = legionProxy:getJobName(memberInfo.job)
    jobTxt:setString(jobName)
    -- 盟主的名字设为绿色job == 7
    if memberInfo.job == 7 then
        jobTxt:setColor(ColorUtils:color16ToC3b(ColorUtils.commonColor.Green))
    else
        jobTxt:setColor(ColorUtils:color16ToC3b(ColorUtils.commonColor.White))
    end

    local color = cc.c3b(255,255,255)--ColorUtils.wordColorLight02
    local rank = memberInfo.capityrank
    rankTxt:setVisible(true)
    rankImg:setVisible(false)
    if rank > 3 then
        rankTxt:setString(rank)
    else
        local url = ""
        if rank == 1 then
            url = "images/newGui2/IconNum_1.png"
            color = ColorUtils.wordAddColor
        elseif rank == 2 then
            url = "images/newGui2/IconNum_2.png"
            color = ColorUtils.wordPurpleColor
        elseif rank == 3 then
            url = "images/newGui2/IconNum_3.png"
            color = ColorUtils.wordBlueColor
        end

        TextureManager:updateImageView(rankImg, url)
        rankImg:setVisible(true)
        rankTxt:setString("")
    end
    
    nameTxt:setColor(color)

    itemPanel.memberInfo = memberInfo
    if itemPanel.isAddEvent ~= true then
        itemPanel.isAddEvent = true
        self:addTouchEventListener(itemPanel, self.onItemPanelTouch,self.onItemPanelTouchBegin)
        itemPanel.cancelCallback = function() 
            imgTouch:setVisible(false)
        end
    end
end

function LegionSceneMemberPanel:onItemPanelTouchBegin(sender)
    local imgTouch = sender:getChildByName("imgTouch")
    imgTouch:setVisible(true)
end

function LegionSceneMemberPanel:onItemPanelTouch(sender)
    local memberInfo = sender.memberInfo
    self._memberId = memberInfo.id
    local panel = self:getPanel(LegionSceneMemberInfoPanel.NAME)
    panel:show()
    panel:onShowHandlerNew(memberInfo)

    local imgTouch = sender:getChildByName("imgTouch")
    imgTouch:setVisible(false)
end

function LegionSceneMemberPanel:registerEvents()
	LegionSceneMemberPanel.super.registerEvents(self)
end