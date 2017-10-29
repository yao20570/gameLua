
LegionApplyInfoPanel = class("LegionApplyInfoPanel", BasicPanel)
LegionApplyInfoPanel.NAME = "LegionApplyInfoPanel"

function LegionApplyInfoPanel:ctor(view, panelName)
    LegionApplyInfoPanel.super.ctor(self, view, panelName, 600)
    
    self:setUseNewPanelBg(true)
end

function LegionApplyInfoPanel:finalize()
    LegionApplyInfoPanel.super.finalize(self)
end

function LegionApplyInfoPanel:initPanel()
    LegionApplyInfoPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(3155))
    
    local infoPanel = self:getChildByName("mainPanel/infoPanel")
    self._infoPanel = infoPanel
end
function LegionApplyInfoPanel:registerEvents()
    LegionApplyInfoPanel.super.registerEvents(self)

    -- local closeBtn = self:getChildByName("mainPanel/closeBtn")
    -- self:addTouchEventListener(closeBtn,self.onCloseBtnTouch)
    local applyBtn = self:getChildByName("mainPanel/infoPanel/applyBtn")
    self:addTouchEventListener(applyBtn,self.onApplyBtnTouch)
    self._applyBtn = applyBtn
end
--显示界面时调用
function LegionApplyInfoPanel:onShowHandler(legionInfo)
    self._skin:setLocalZOrder(10)
    LegionApplyInfoPanel.super.onShowHandler(self)
    self:updateBaseInfo(legionInfo)
end
--更新数据
function LegionApplyInfoPanel:updateData(detailInfo)
    self:updateDetailInfo(detailInfo)
end 

function LegionApplyInfoPanel:updateApplyBtnTxt(state,name)
    local proxy = self:getProxy(GameProxys.LordCity)
    local isSetChildLegion,_,isSelfLegion = proxy:isSetChildLegion()
    NodeUtils:setEnable(self._applyBtn,true)
    if isSetChildLegion then
        if self._oldLegionName and self._oldLegionName == self._legionName then
            self._applyBtn:setTitleText(self:getTextWord(370070))  --已任命
            NodeUtils:setEnable(self._applyBtn,false)
        else
            self._applyBtn:setTitleText(self:getTextWord(370069))  --任命
        end
        if isSelfLegion == name then
            NodeUtils:setEnable(self._applyBtn,false)  --占领军团
        end
    else
        self._applyBtn:setTitleText(self:getTextWord(3124 +state )) --申请/取消申请
    end
end

function LegionApplyInfoPanel:updateBaseInfo(legionInfo)
    print("id,name====",legionInfo.id,legionInfo.name)
    self._legionId = legionInfo.id
    self._legionName = legionInfo.name
    self._oldLegionName = rawget(legionInfo,"oldLegionName")
    local infoPanel = self._infoPanel
    local nameTxt = infoPanel:getChildByName("nameTxt")
    local rankTxt = infoPanel:getChildByName("rankTxt")
    local levelTxt = infoPanel:getChildByName("levelTxt")
    local numTxt = infoPanel:getChildByName("numTxt")
    local numTxt1 = infoPanel:getChildByName("numTxt1")

    local name   = legionInfo.name
    local rank   = legionInfo.rank
    local level  = legionInfo.level
    local curNum = legionInfo.curNum
    local maxNum = legionInfo.maxNum
    
    
    -- levelTxt:setString(level)--等级
    levelTxt:setString(string.format(self:getTextWord(3200), level))--等级
    nameTxt:setString(name) --军团名
    -- numTxt:setString(string.format("%d/%d", curNum,maxNum ))--人数
    numTxt:setString(tostring(curNum))--人数
    numTxt1:setString("/"..tostring(maxNum))
    NodeUtils:alignNodeL2R(numTxt,numTxt1)
    rankTxt:setString(rank) --排名

    local size = levelTxt:getContentSize()
    nameTxt:setPositionX(levelTxt:getPositionX() + size.width + 12)

end
function LegionApplyInfoPanel:updateDetailInfo(detailInfo)
    local infoPanel = self._infoPanel
    local leaderTxt = infoPanel:getChildByName("leaderTxt")
    local joinTxt = infoPanel:getChildByName("joinTxt")
    local noticeTxt = infoPanel:getChildByName("contentTxt")
    local conditionTxt = infoPanel:getChildByName("condTxt1")
    local applyBtn = infoPanel:getChildByName("applyBtn")
    local Image_head = infoPanel:getChildByName("Image_head")


    -- 头像和挂件
    -- print("iconId="..info.iconId..",,pendantId="..info.pendantId)
    local headInfo = {}
    headInfo.icon = detailInfo.iconId
    headInfo.pendant = detailInfo.pendantId
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = "headPendant"
    headInfo.isCreatPendant = false
    --headInfo.isCreatButton = false
    headInfo.playerId = rawget(detailInfo, "playerId")

    local head = infoPanel.head
    if head == nil then
        head = UIHeadImg.new(Image_head,headInfo,self)
        
        infoPanel.head = head
    else
        head:updateData(headInfo)
    end

    
    local leader = detailInfo.leaderName 
    local type   = detailInfo.joinType --加入类型：1直接，2审核
    local state  = detailInfo.applyState --申请状态：0未申请，1申请中
    local contentStr = detailInfo.notice --军团宣言
    local condition1 = detailInfo.joinCond1 --加入条件1
    local condition2 = detailInfo.joinCond2 --加入条件2

    
    leaderTxt:setString(leader) --军团长  
    joinTxt:setString(self:getTextWord(3110 + type ))--加入方式 

    local conStr = self:getTextWord(3123)
    if condition1 > 0 and condition2 > 0 then
        local lv = condition1
        local fig = StringUtils:formatNumberByK(condition2,0)
        local lvStr = self:getTextWord(3121)
        local figStr = self:getTextWord(3122)
        conStr = string.format("%s%d  %s%s",lvStr,lv,figStr,fig)
    elseif condition1 > 0 then
        local lv = condition1
        local lvStr = self:getTextWord(3121)
        conStr = string.format("%s%d",lvStr,lv)
    elseif condition2 > 0 then
        local fig = StringUtils:formatNumberByK(condition2,0)
        local figStr = self:getTextWord(3122)
        conStr = string.format("%s%s",figStr,fig)
    end 
    conditionTxt:setString(conStr) --加入条件
    self:updateApplyBtnTxt(state,self._legionName)

    if string.len(contentStr) == 0 then
        noticeTxt:setString(self:getTextWord(3007))
    else
        noticeTxt:setString(contentStr) --军团宣言
    end
    print("军团宣言 contentStr = "..contentStr..",len = "..string.len(contentStr))


    local userData = applyBtn.userData
    if userData == nil then
        userData = {}
        applyBtn.userData = userData
    end 
    userData.applyState = state
    userData.limitLv = condition1
    userData.limitFig = condition2
end 

--------------------回调函数----------------
--申请
function LegionApplyInfoPanel:onApplyBtnTouch(sender)
    --------------------------------------------------------------
    --任命附团
    local proxy = self:getProxy(GameProxys.LordCity)
    local isSetChildLegion,cityId = proxy:isSetChildLegion()
    if isSetChildLegion then
        -- print("--任命附团",cityId,self._legionId)
        local data = {cityId = cityId, legionId = self._legionId}
        proxy:onTriggerNet360012Req(data)
        self:onClosePanelHandler()  --关闭弹窗
        return
    end
    --------------------------------------------------------------
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
    print("id,state====",legionId,applyState)
    --请求申请
    local data = {}
    data.id = legionId
    data.type = type
    self:dispatchEvent(LegionApplyEvent.LEGION_APPLY_REQ, data)
    
    self:onClosePanelHandler()
end
--关闭
function LegionApplyInfoPanel:onCloseBtnTouch(sender)
    self:onClosePanelHandler()
end 
function LegionApplyInfoPanel:onClosePanelHandler()
    LegionApplyInfoPanel.super.onClosePanelHandler(self)
    self:hide()
end

