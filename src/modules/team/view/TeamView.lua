
TeamView = class("TeamView", BasicView)

function TeamView:ctor(parent)
    TeamView.super.ctor(self, parent)
end

function TeamView:finalize()
    TeamView.super.finalize(self)
end

function TeamView:registerPanels()
    TeamView.super.registerPanels(self)

    require("modules.team.panel.TeamPanel")
    self:registerPanel(TeamPanel.NAME, TeamPanel)
    
    require("modules.team.panel.TeamReparePanel")
    self:registerPanel(TeamReparePanel.NAME, TeamReparePanel)
    
    require("modules.team.panel.TeamSetPanel")
    self:registerPanel(TeamSetPanel.NAME, TeamSetPanel)
    
    require("modules.team.panel.TeamSquirePanel")
    self:registerPanel(TeamSquirePanel.NAME, TeamSquirePanel)
    
    require("modules.team.panel.TeamWorkPanel")
    self:registerPanel(TeamWorkPanel.NAME, TeamWorkPanel)
    
    require("modules.team.panel.TeamChoosePanel")
    self:registerPanel(TeamChoosePanel.NAME, TeamChoosePanel)

    -- require("modules.team.panel.TeamSleepPanel")
    -- self:registerPanel(TeamSleepPanel.NAME, TeamSleepPanel)
    
    require("modules.team.panel.TeamInfosPanel")
    self:registerPanel(TeamInfosPanel.NAME, TeamInfosPanel)
end

function TeamView:initView()
    local panel = self:getPanel(TeamPanel.NAME)
    panel:show()
end

function TeamView:hideModuleHandler()
    -- local panel = self:getPanel(TeamSetPanel.NAME)
    -- panel:setShowMyCityStatusOpenFun()
    self:setShowMyCityStatus()
    
    panel = self:getPanel(TeamWorkPanel.NAME)
    panel:onCloseTimerOpenFun()--关闭定时器
    self:dispatchEvent(TeamEvent.HIDE_SELF_EVENT, {})
end

function TeamView:updateTeamSet(data, showType, isShowOtherCity, otherCityStr, isNeedBody, isPlayerRes)
    local panel = self:getPanel(TeamSetPanel.NAME)
    panel:show()
    panel:updateTeamSet(data, showType, isShowOtherCity, otherCityStr, isNeedBody, isPlayerRes)
end

function TeamView:updateSoliderList(data)
    -- local panel = self:getPanel(TeamChoosePanel.NAME)
    -- panel:updateSoliderList(data)
end

function TeamView:updateLevel(level)
    -- local panel = self:getPanel(TeamSetPanel.NAME)
    -- panel:setOpenPosBylevelOpenFun(level)
    -- panel = self:getPanel(TeamSquirePanel.NAME)
    -- if panel:isInitUI() == true then
    --     panel:setOpenPosBylevel(level)
    -- end
end

function TeamView:updateMaxFightSoldierCount()
    -- local panel = self:getPanel(TeamSetPanel.NAME)
    -- panel:setSolderCountOpenFun()
    -- panel = self:getPanel(TeamSquirePanel.NAME)
    -- if panel:isInitUI() == true then
    --     panel:setSolderCount()
    -- end
    
    -- panel = self:getPanel(TeamChoosePanel.NAME)
    -- if panel:isInitUI() == true then
    --     panel:onUpdateMaxCount()
    -- end
end

function TeamView:onAllRepaireList()
    local panel = self:getPanel(TeamReparePanel.NAME)
    if panel:isInitUI() == true then
        panel:onAllRepaireList()
    end
    
end

function TeamView:setFirstPanelShow(type)
    local panel = self:getPanel(TeamPanel.NAME)
    panel:show()
    panel:setFirstPanelShow(type)
end

function TeamView:onSleepRespHandle(data)
    -- local panel = self:getPanel(TeamSleepPanel.NAME)
    -- if panel:isInitUI() == true then
    --     panel:updateData(data)
    -- end
end

function TeamView:updateCurrJewel()
    -- local panel = self:getPanel(TeamSleepPanel.NAME)
    -- if panel:isInitUI() == true then
    --     panel:updateCurrJewel()
    -- end
end

function TeamView:onListenCountResp()
    local panel = self:getPanel(TeamPanel.NAME)
    panel:updateItemCount()
end

function TeamView:onTipsUpdateHandle()
    -- local panel = self:getPanel(TeamSetPanel.NAME)
    -- panel:updateEquipAndParts()
    -- panel = self:getPanel(TeamSquirePanel.NAME)
    -- if panel:isInitUI() == true then
    --     panel:updateEquipAndParts()
    -- end
end

function TeamView:onGetAllWorkResp(data)
    local panel = self:getPanel(TeamWorkPanel.NAME)
    if panel:isInitUI() == true then
        panel:onUpdateData(data)
    end
    panel = self:getPanel(TeamPanel.NAME)
    panel:onUpdateWorkCount(data)
end

function TeamView:getWorkData()
    return self._workData
end

function TeamView:onJumpToWorkPanel()
    local panel = self:getPanel(TeamPanel.NAME)
    panel:setFirstPanelShow(true)
end

function TeamView:setShowMyCityStatus(type)
    -- local panel = self:getPanel(TeamSetPanel.NAME)
    -- panel:setShowMyCityStatusOpenFun(type)
end

function TeamView:setJumpToWorkPanel(type)
    --self._isInWrokStatus = type
end

function TeamView:getJumpToWorkPanel()
    --return self._isInWrokStatus
end

function TeamView:onBuyTimesResp(data)
    -- local panel = self:getPanel(TeamSleepPanel.NAME)
    
    -- if panel:isInitUI() == true and panel:isVisible() == true then
    --     panel:onBuyTimesResp(data)
    -- else
    --     panel = self:getPanel(TeamSetPanel.NAME)
    --     panel:onBuyTimesResp(data)
    -- end
end

function TeamView:updaeEnergyNeedMoney()
    -- local panel = self:getPanel(TeamSleepPanel.NAME)
    -- if panel:isInitUI() == true then
    --     panel:updaeEnergyNeedMoney()
    -- end
end

function TeamView:badSoldierListUpdate()
    local panel = self:getPanel(TeamPanel.NAME)
    if panel:isInitUI() == true then
        panel:updateItemCount()
    end
end

function TeamView:onGetRunTimeResp(data)
    local panel = self:getPanel(TeamSetPanel.NAME)
    panel:setSolidertime(data.time)
end

function TeamView:onConsuGoReq(data)
    -- local panel = self:getPanel(TeamSetPanel.NAME)
    -- if panel:isInitUI() == true then
    --     panel:onConsuGoReq(data)
    -- end
    -- panel = self:getPanel(TeamSquirePanel.NAME)
    -- if panel:isInitUI() == true then
    --     panel:onConsuGoReq(data)
    -- end
end