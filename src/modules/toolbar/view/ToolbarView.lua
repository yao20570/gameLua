
ToolbarView = class("ToolbarView", BasicView)

function ToolbarView:ctor(parent)
    ToolbarView.super.ctor(self, parent)
end

function ToolbarView:finalize()
    ToolbarView.super.finalize(self)
end

function ToolbarView:registerPanels()
    ToolbarView.super.registerPanels(self)

    require("modules.toolbar.panel.ToolbarPanel")
    self:registerPanel(ToolbarPanel.NAME, ToolbarPanel)
    require("modules.toolbar.panel.QueuePanel")
    self:registerPanel(QueuePanel.NAME, QueuePanel)
    
    require("modules.team.panel.TeamInfosPanel")
    self:registerPanel(TeamInfosPanel.NAME, TeamInfosPanel)
end

function ToolbarView:initView()
    local toolbarPanel = self:getPanel(ToolbarPanel.NAME)
    toolbarPanel:show()
end

function ToolbarView:showOtherModule(moduleName)
    self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT, moduleName)
end

function ToolbarView:onGetChatInfoResp(data)
    local panel = self:getPanel(ToolbarPanel.NAME)
    panel:updateChatInfos(data.chats)
end
function ToolbarView:onGetPrivateChatInfoResp(_data)
    local panel = self:getPanel(ToolbarPanel.NAME)
    local data = {}
    data[1] = {name = _data.name,playerId = _data.playerId,type = _data.type,iconId = _data.iconId,context = _data.context}
    panel:updateChatInfos(data)
end

-- function ToolbarView:onNewMailsResp(data)
--     local panel = self:getPanel(ToolbarPanel.NAME)
--     panel:onNewMailsResp(data)
-- end

-- 来自角色信息更新通知，更新建筑信息、更新繁荣度信息
function ToolbarView:onRoleInfoUpdateResp(updatePowerList)
    local panel = self:getPanel(ToolbarPanel.NAME)
    panel:onRoleInfoUpdateResp(updatePowerList)
end

-- 来自建筑更新通知，更新建筑信息
function ToolbarView:updateBuildingInfo()
    local panel = self:getPanel(ToolbarPanel.NAME)
    panel:updateBuildingInfo()
end

function ToolbarView:updateTaskInfo()
    local panel = self:getPanel(ToolbarPanel.NAME)    
    panel:updateTaskTips()
    panel:updateTaskTips2()
end

function ToolbarView:isCanBuyVipBuilding(data)
    local panel = self:getPanel(ToolbarPanel.NAME)
    panel:isCanBuyVipBuilding(data)
end
function ToolbarView:buySuccess(num)
    -- local num = 1 
    local panel = self:getPanel(ToolbarPanel.NAME)
    panel:updateBuildingInfo(num)
end

function ToolbarView:onUpdateTipsResp(data)
    local panel = self:getPanel(ToolbarPanel.NAME)
    panel:onUpdateTipsResp(data)
end

function ToolbarView:updateNoSeeChatNum(data)
    local panel = self:getPanel(ToolbarPanel.NAME)
    panel:onUpdateNoSeeChatNum(data)
end

function ToolbarView:setCurSceneState(moduleName, visible)
    local panel = self:getPanel(ToolbarPanel.NAME)
    panel:setCurSceneState(moduleName, visible)
end

function ToolbarView:updateOpenSeverInfo(data)
    local panel = self:getPanel(ToolbarPanel.NAME)
    local index = 1
    panel:openServerGift(data,index)
end


function ToolbarView:onUpdateLegionGift(data)
    local panel = self:getPanel(ToolbarPanel.NAME)
    panel:onUpdateLegionGift(data)
end

function ToolbarView:onUpdateLimitBtn(param)
    local panel = self:getPanel(ToolbarPanel.NAME)
    panel:onUpdateLimitBtn(param)
end

function ToolbarView:isShowRankItem()
    local panel = self:getPanel(ToolbarPanel.NAME)
    panel:isShowRankItem()
end

function ToolbarView:onUpdatePkgNum(param)
    local panel = self:getPanel(ToolbarPanel.NAME)
    panel:onUpdatePkgNum(param)
end

function ToolbarView:updateVipSupplyPoint()
    local panel = self:getPanel(ToolbarPanel.NAME)
    panel:updateVipSupplyPoint()
end
function ToolbarView:updateWeekCardShowAndRedPoint()
    local panel = self:getPanel(ToolbarPanel.NAME)
    panel:updateWeekCardShowAndRedPoint()
end

-- function ToolbarView:onShowRechargeUI()
--     local panel = self:getPanel(ToolbarPanel.NAME)
--     panel:onShowRechargeUI()
-- end

function ToolbarView:onEndGuide()
    local panel = self:getPanel(ToolbarPanel.NAME)
    panel:onShowOrHidePanels(true)
end

function ToolbarView:onUpdateWarlordsStats()
    local panel = self:getPanel(ToolbarPanel.NAME)
    panel:onUpdateWarlordsStats()
end

------
-- 刷新队列界面
-- From:ToolbarModule:onupdateTeamInfoResp()
function ToolbarView:updateQueuePanel()
    local panel = self:getPanel(QueuePanel.NAME)
    local toolbarPanel = self:getPanel(ToolbarPanel.NAME)
    if panel:isInitUI() then
        panel:setTabShow()
    end
    -- 刷新队列红点
    toolbarPanel:setQueueWorkCount()
end

-- From:ToolbarModule:onupdateBeAttacked(data)
function ToolbarView:onupdateBeAttacked(data)
    -- 刷新敌袭
    local panel = self:getPanel(QueuePanel.NAME)
    local toolbarPanel = self:getPanel(ToolbarPanel.NAME)
    if panel:isInitUI() then
        panel:setTabShow()
    end
    -- 刷新队列红点
    toolbarPanel:setQueueWorkCount()
end

-- 播放警告
function ToolbarView:playWarning()
    local toolbarPanel = self:getPanel(ToolbarPanel.NAME)
    toolbarPanel:playWarning()
end



function ToolbarView:onUpdateBtnPanel()
    local toolbar = self:getPanel(ToolbarPanel.NAME)
    toolbar:onUpdateBtnPanel()
end

function ToolbarView:onUpdateBtnList(data)
    local toolbar = self:getPanel(ToolbarPanel.NAME)
    toolbar:onUpdateBtnList(data)
end

function ToolbarView:onHideQueueBtn(isShow)
    local toolbar = self:getPanel(ToolbarPanel.NAME)
    toolbar:setQueueBtn(isShow)
end
function ToolbarView:updateToolbarRedBag()
    local toolbar = self:getPanel(ToolbarPanel.NAME)
    toolbar:setRedBagVisible()
end
function ToolbarView:openRedBag(data)
    local toolbar = self:getPanel(ToolbarPanel.NAME)
    toolbar:openRedBag(data)

end

function ToolbarView:onClearCmd()

    local function hideAllChild(name, tags)
        local layer = self:getLayer(name)
        if layer == nil then
            return
        end
        for k,v in pairs(tags) do
            local child = layer:getChildByName(v)
            if child ~= nil and type(child.setVisible) == "function" then
                child:setVisible(false)
            end
        end
    end
    hideAllChild(ModuleLayer.UI_TOP_LAYER, GlobalConfig.uitopWin)
    -- hideAllChild(ModuleLayer.UI_POP_LAYER, GlobalConfig.uipopWin)

    local toolbar = self:getPanel(ToolbarPanel.NAME)
    toolbar:onClearCmd()
end

function ToolbarView:buildFreeTip(isCanFreeBuild)
    local toolbar = self:getPanel(ToolbarPanel.NAME)
    toolbar:buildFreeTip(isCanFreeBuild)
end

function ToolbarView:onRealNameBtnVisible()
    local toolbar = self:getPanel(ToolbarPanel.NAME)
    if toolbar:isVisible() == true then
        toolbar:onRealNameBtnVisible()
    end
end

function ToolbarView:onHideQueuePanel()
    local panel = self:getPanel(QueuePanel.NAME)
    if panel:isVisible() == true then
        panel:onHideQueuePanel()
    end
end

function ToolbarView:updateSeason()
    local panel = self:getPanel(ToolbarPanel.NAME)
    if panel:isVisible() == true then
        panel:updateSeason()
    end
end

function ToolbarView:updateWorldLevel()
    local panel = self:getPanel(ToolbarPanel.NAME)
    if panel:isVisible() == true then
        panel:updateWorldLevel()
    end
end


function ToolbarView:onEnterScene()
    local panel = self:getPanel(ToolbarPanel.NAME)
    --panel:onEnterScene()
end

function ToolbarView:updateChatBarrage(data)
    local panel = self:getPanel(ToolbarPanel.NAME)
    panel:updateChatBarrage(data)
end

function ToolbarView:updateUnlockBegin(data)
    local panel = self:getPanel(ToolbarPanel.NAME)
    panel:guideHide(data)
end

function ToolbarView:updateUnlockEnd(data)
    local panel = self:getPanel(ToolbarPanel.NAME)
    panel:guideShow(data)

end