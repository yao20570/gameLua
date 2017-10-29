
PersonInfoPanel = class("PersonInfoPanel", BasicPanel)
PersonInfoPanel.NAME = "PersonInfoPanel"

function PersonInfoPanel:ctor(view, panelName)
    PersonInfoPanel.super.ctor(self, view, panelName, true)
    -- self._tabControl = nil
    self:setUseNewPanelBg(true)
end

function PersonInfoPanel:finalize()
    PersonInfoPanel.super.finalize(self)
end

function PersonInfoPanel:initPanel()
	PersonInfoPanel.super.initPanel(self)

    local function commentCallback()
        self:onCommentBtn()
    end
    self:setCommentHandle(commentCallback, self)

	self:addTabControl()
end

function PersonInfoPanel:addTabControl()
    local tabControl = UITabControl.new(self, self.isUnlockLottery)
    tabControl:addTabPanel(PersonInfoDetailsPanel.NAME, self:getTextWord(503))
    tabControl:addTabPanel(PersonInfoSkillPanel.NAME, self:getTextWord(504))
    tabControl:addTabPanel(PersonInfoBuildPanel.NAME, self:getTextWord(505))

    local openState = FunctionShieldConfig:isShield( FunctionShield.TALENT )
    if openState~=true then
        tabControl:addTabPanel(PersonInfoTalentPanel.NAME, self:getTextWord(570))
    end

    tabControl:setTabSelectByName(PersonInfoDetailsPanel.NAME)

    self._tabControl = tabControl
    self:setTitle(true,"information", true)

    local closeBtn = self:getCloseBtn()
    self["closeBtn"] = closeBtn

    self:updateLevelUpTip()
end

function PersonInfoPanel:isUnlockLottery(newPanelName,oldPanelName)
    if PersonInfoTalentPanel.NAME == newPanelName then
        local roleProxy = self:getProxy(GameProxys.Role)
        local isLock = roleProxy:isFunctionUnLock( 47, true )
        if isLock == false then
            local panel = self:getPanel(PersonInfoTalentPanel.NAME)
            if panel:isVisible() then
                panel:hide()
            end
        end
        return isLock
    end
    return true
end
function PersonInfoPanel:onClosePanelHandler()
    -- print("关闭···PersonInfoPanel:onClosePanelHandler()")
    local panel = self:getPanel(PersonInfoSkillPanel.NAME)
    if panel:isVisible() then
        panel:onHide()
    end

    panel = self:getPanel(PersonInfoBuildPanel.NAME)
    if panel:isVisible() then
        panel:hide()
    end

    self.view:hideModuleHandler()
end

function PersonInfoPanel:setFirstPanelShow()
end

-- 类型  1-兵营 2-武将 3-太学院 4-战法 5-军师 6-国策 7-建筑
function PersonInfoPanel:onCommentBtn()
    local proxy = self:getProxy(GameProxys.Comment)
    proxy:toCommentModule(self._typeId, 0)
end

function PersonInfoPanel:tabChangeMainPanelEvent()
    PersonInfoPanel.super.tabChangeMainPanelEvent(self) -- link

    local curPanelName = self._tabControl:getCurPanelName()
    if curPanelName == PersonInfoSkillPanel.NAME then-- 4-战法
        self._typeId = 4
        self:setCommentBtnVisible(true)
    elseif curPanelName == PersonInfoTalentPanel.NAME then -- 6-国策
        self._typeId = 6
        self:setCommentBtnVisible(true)
    elseif curPanelName == PersonInfoBuildPanel.NAME then --  7-建筑
        self._typeId = 7
        self:setCommentBtnVisible(true)
    else
        self:setCommentBtnVisible(false)
    end


end

--//战法有可升级时  添加一个升级特效提示
function PersonInfoPanel:updateLevelUpTip()
    self._skillProxy = self:getProxy(GameProxys.Skill)
    if self._skillProxy._isEffectTip  then
    self._tabControl:setLevelUp(2,true)
    else
    self._tabControl:setLevelUp(2,false)
    end
end

