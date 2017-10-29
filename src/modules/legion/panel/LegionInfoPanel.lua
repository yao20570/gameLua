-- /**
--  * @DateTime:    2016-01-14 11:07:18
--  * @Description: 军团信息
--  */

LegionInfoPanel = class("LegionInfoPanel", BasicPanel)
LegionInfoPanel.NAME = "LegionInfoPanel"

function LegionInfoPanel:ctor(view, panelName)
    LegionInfoPanel.super.ctor(self, view, panelName,true)
    
    self:setUseNewPanelBg(true)
end

function LegionInfoPanel:finalize()
    LegionInfoPanel.super.finalize(self)
end

function LegionInfoPanel:initPanel()
	LegionInfoPanel.super.initPanel(self)
    self._legionProxy = self:getProxy(GameProxys.Legion)
    self._topPanel = self:getChildByName("topPanel")
    self._topBtnPanel = self._topPanel:getChildByName("topBtnPanel")
    self._downBtnPanel = self:getChildByName("downBtnPanel")
    self._infoPanel = self:getChildByName("infoPanel")

    self._levelTxt = self._infoPanel:getChildByName("levelTxt")
    self._buildTxt = self._infoPanel:getChildByName("buildTxt")
    self._joinTxt = self._infoPanel:getChildByName("joinTxt")
    self._conditionTxt = self._infoPanel:getChildByName("conditionTxt")
    self._maxNumTxt = self._infoPanel:getChildByName("maxNumTxt")

    local editBtn = self._topBtnPanel:getChildByName("editBtn")
    local editJobBtn = self._downBtnPanel:getChildByName("editJobBtn")
    self._mailBtn = self._downBtnPanel:getChildByName("mailBtn")
    local recruitMember = self._downBtnPanel:getChildByName("recruitMember")

    self:addTouchEventListener(editBtn, self.onEditBtnTouch)
    self:addTouchEventListener(editJobBtn, self.onJobEditBtnTouch)
    self:addTouchEventListener(self._mailBtn, self.onMailBtnTouch)
    self:addTouchEventListener(recruitMember, self.onRecruitBtnTouch)

    self:setTitle(true,"bittle", true)
    self:setBgType(ModulePanelBgType.NONE)

    --宣言
    self._noticePanel = self._topPanel:getChildByName("Panel_notice")
    self._noticeTxt = self._noticePanel:getChildByName("noticeTxt")
    --公告
    self._affichePanel = self._topPanel:getChildByName("Panel_affiche")
    self._afficheTxt = self._affichePanel:getChildByName("afficheTxt")
  
end

function LegionInfoPanel:doLayout()
    local topPanel = self:getChildByName("topPanel")
    local downBtnPanel = self:getChildByName("downBtnPanel")
    local infoPanel = self:getChildByName("infoPanel")
    -- NodeUtils:adaptiveListView(topPanel,downBtnPanel,infoPanel)
    -- NodeUtils:adaptiveListView(self._topPanel,self._downBtnPanel,self._infoPanel)
    NodeUtils:adaptiveUpPanel(infoPanel,nil,113)
    NodeUtils:adaptiveUpPanel(topPanel,infoPanel,GlobalConfig.downHeight)
    --NodeUtils:adaptiveDownPanel(downBtnPanel,nil,GlobalConfig.downHeight)
    NodeUtils:adaptiveUpPanel(downBtnPanel,topPanel)
end

-- 编辑
function LegionInfoPanel:onEditBtnTouch(sender)
    local panel = self:getPanel(LegionEditPanel.NAME)
    panel:show()
end
-- 职位编辑
function LegionInfoPanel:onJobEditBtnTouch(sender)
    local panel = self:getPanel(LegionJobEditPanel.NAME)
    panel:show()
end

--TODO 军团招募
function LegionInfoPanel:onRecruitBtnTouch(sender)
    self:dispatchEvent(LegionEvent.LEGION_RECRUIT_REQ)
end

function LegionInfoPanel:onMailBtnTouch(sender)
  --TODO 军团邮件
    local roleProxy = self:getProxy(GameProxys.Role)
    local lv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    if lv < GlobalConfig.chatMinLv then
        self:showSysMessage(string.format(TextWords:getTextWord(1238), GlobalConfig.chatMinLv))
        return
    end


    if self._curNumber == 1 then
        self:showSysMessage(self:getTextWord(3018))
        return
    end

    local playerName = roleProxy:getRoleName()--玩家名称

    local legionProxy = self:getProxy(GameProxys.Legion)
    local memberInfoList = legionProxy:getMemberInfoList()
    local nameTab = {}
    for k,v in pairs(memberInfoList) do
        if v.name ~= playerName then
            table.insert(nameTab, v.name)
        end
    end

    local nameContext = table.concat(nameTab, ";")
    -- print("nameContext = "..nameContext)

    -- local nameContext = self:getTextWord(3016)
    local data = {}
    data["moduleName"] = ModuleName.MailModule
    data["extraMsg"] = {}
    data["extraMsg"]["type"] = "writeMail"
    data["extraMsg"]["isCloseModule"] = true
    data["extraMsg"]["teamUnion"] = true
    data["extraMsg"]["name"] = nameContext --你要写给对方的名字

    local chatProxy = self:getProxy(GameProxys.Chat)
    chatProxy:enterWriteMsg(data)

end

function LegionInfoPanel:onAfterActionHandler()
    self:onShowHandler()
end


-- 军团信息更新
function LegionInfoPanel:onLegionInfoUpdate()
    if self:isVisible() ~= true then
        return
    end

    local legionProxy = self:getProxy(GameProxys.Legion)
    self._mineInfo = legionProxy:getMineInfo()
    self._curNumber = self._mineInfo.curNum --当前成员数量


    local infoPanel = self:getChildByName("infoPanel")
    self:renderMineInfoPanel(infoPanel, self._mineInfo)

end

function LegionInfoPanel:onShowHandler()
    if self:isModuleRunAction() then
        return
    end
    -- local tabsPanel = self:getTabsPanel()
    -- local panelBg = self:getChildByName("topPanel")  
    -- 切换标签刷新文本
    local legionProxy = self:getProxy(GameProxys.Legion)
    if legionProxy:getMineInfo() ~= nil then
        local infoPanel = self:getChildByName("infoPanel")
        self:renderMineInfoPanel(infoPanel, legionProxy:getMineInfo())
    end


    
end

function LegionInfoPanel:renderMineInfoPanel(infoPanel, mineInfo)
    self._levelTxt:setString(mineInfo.rank)
    self._buildTxt:setString(mineInfo.buildDegree)
    self._joinTxt:setString(self:getTextWord(3110 + mineInfo.joinType))
    self._maxNumTxt:setString(mineInfo.level)

    local str1 = mineInfo.joinCond1
    local str2 = mineInfo.joinCond2

    local str = nil
    if str1 == nil or str2 == nil then
        str = self:getTextWord(3108)
    elseif str1 == 0 and str2 == 0 then
        str = self:getTextWord(3108)
    elseif str1 ~= 0 and str2 ~= 0 then
        str = string.format(self:getTextWord(3109), mineInfo.joinCond1).." "..string.format(self:getTextWord(3110), StringUtils:formatNumberByK3(mineInfo.joinCond2, nil))
    elseif str1 ~= 0 and str2 == 0 then
        str = string.format(self:getTextWord(3109), mineInfo.joinCond1)
    elseif str1 == 0 and str2 ~= 0 then
        str = string.format(self:getTextWord(3110), StringUtils:formatNumberByK3(mineInfo.joinCond2, nil))
    end
    self._conditionTxt:setString(str)

    if string.len(mineInfo.affiche) == 0 then
        self._afficheTxt:setString(self:getTextWord(3006))
    else
        self._afficheTxt:setString(mineInfo.affiche)
    end

    if mineInfo.notice=="" then
        self._noticeTxt:setString( self:getTextWord(3007) )
    else
        self._noticeTxt:setString( mineInfo.notice )
    end


    -- 邮件按钮显示
    self._mailBtn:setVisible(self._legionProxy:getShowStateByJob(mineInfo.mineJob, "mailShow"))

end


function LegionInfoPanel:onClosePanelHandler()
    self.view:hideModuleHandler()
end





