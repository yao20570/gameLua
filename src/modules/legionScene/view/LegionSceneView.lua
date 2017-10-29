
LegionSceneView = class("LegionSceneView", BasicView)

function LegionSceneView:ctor(parent)
    LegionSceneView.super.ctor(self, parent)
end

function LegionSceneView:finalize()
    LegionSceneView.super.finalize(self)
end

function LegionSceneView:registerPanels()
    LegionSceneView.super.registerPanels(self)

    require("modules.legionScene.panel.LegionScenePanel")
    self:registerPanel(LegionScenePanel.NAME, LegionScenePanel)

    require("modules.legionScene.panel.LegionSceneHallPanel")
    self:registerPanel(LegionSceneHallPanel.NAME, LegionSceneHallPanel)

    require("modules.legionScene.panel.LegionSceneMemberPanel")
    self:registerPanel(LegionSceneMemberPanel.NAME, LegionSceneMemberPanel)

    require("modules.legionScene.panel.LegionSceneAllListPanel")
    self:registerPanel(LegionSceneAllListPanel.NAME, LegionSceneAllListPanel)

    require("modules.legionScene.panel.LegionSceneMemberInfoPanel")
    self:registerPanel(LegionSceneMemberInfoPanel.NAME, LegionSceneMemberInfoPanel)

    require("modules.legionScene.panel.LegionSceneOtherInfoPanel")
    self:registerPanel(LegionSceneOtherInfoPanel.NAME, LegionSceneOtherInfoPanel)

    require("modules.legionScene.panel.LegionSceneApprovePanel")
    self:registerPanel(LegionSceneApprovePanel.NAME, LegionSceneApprovePanel)

    require("modules.legionScene.panel.LegionSceneSetJobPanel")
    self:registerPanel(LegionSceneSetJobPanel.NAME, LegionSceneSetJobPanel)

end

function LegionSceneView:initView()
    local panel = self:getPanel(LegionScenePanel.NAME)
    panel:show()
    panel:setHtmlStr("html/help_legion.html")
end

function LegionSceneView:hideModuleHandler()
    self:dispatchEvent(LegionSceneEvent.HIDE_SELF_EVENT, {})
end

function LegionSceneView:onLegionAllListResp(data)

    local panelList = self:getPanel(LegionSceneAllListPanel.NAME)
    if panelList:isVisible() == true then
        panelList:onLegionAllListResp(data)
    end

    local panel = self:getPanel(LegionSceneHallPanel.NAME)
    if panel:isVisible() == true then
        panel:onLegionAllListResp(data)
    end
end

function LegionSceneView:updateDetailInfoPanel(data)
    -- body
    local panel = self:getPanel(LegionSceneOtherInfoPanel.NAME)
    if panel:isVisible() == true then
        panel:updateDetailInfoPanel(data)
    end
end

-- 显示搜索军团结果
function LegionSceneView:onSearchLegionInfos(data)
    local panel = self:getPanel(LegionSceneAllListPanel.NAME)
    if panel:isVisible() == true then
        panel:onSearchLegionInfos(data)
    end
end

function LegionSceneView:onChatPersonInfoResp(data)
    -- body
    local panel = self:getPanel(LegionSceneMemberInfoPanel.NAME)
    if panel:isVisible() == true then
        panel:onChatPersonInfoResp(data)
    end
end

function LegionSceneView:onLegionInfoUpdate()
    local panel = self:getPanel(LegionSceneMemberPanel.NAME)
    if panel:isVisible() == true then
        panel:onLegionMemberUpdate()
    end
end

function LegionSceneView:updateLegionSceneAffiche(data)
    local panel = self:getPanel(LegionSceneHallPanel.NAME)
    panel:updateLegionSceneAffiche(data)
end

function LegionSceneView:onUpdateApplyInfos()
    local panel = self:getPanel(LegionSceneApprovePanel.NAME)
    if panel:isVisible() == true then
        panel:onUpdateApplyInfos()
    end
end


-- 更新小红点
function LegionSceneView:onLegionApprovePointUpdate()
    local panel = self:getPanel(LegionSceneMemberPanel.NAME)
    if panel:isVisible() == true then
        panel:onLegionApprovePointUpdate()
    end
    --更新tab小红点
    local panel = self:getPanel(LegionScenePanel.NAME)
    panel:setItemCount(2,true)
end

-- 再次打开更新tab小红点
function LegionSceneView:setTabItemCount()
    local panel = self:getPanel(LegionScenePanel.NAME)
    panel:setItemCount(2,true)
end


-- 审批同意/拒绝 回调
function LegionSceneView:onLegionApproveOptResp(data)
    local panel = self:getPanel(LegionSceneApprovePanel.NAME)
    if panel:isVisible() == true then
        panel:onUpdateApplyInfos()
    end
end

--更新军团列表成员
function LegionSceneView:onMemberOptResp(data)
    -- body
    local panel = self:getPanel(LegionSceneMemberInfoPanel.NAME)
    panel:onClose()
    local panel = self:getPanel(LegionSceneHallPanel.NAME)
    panel:onShowHandler()
end

-- 更新成员列表，包括盟主转让
function LegionSceneView:onLegionMemberUpdate()
    local panel = self:getPanel(LegionSceneHallPanel.NAME)
    panel:updateLegionSceneMenberNum()
    local panel = self:getPanel(LegionScenePanel.NAME)
    panel:setItemCount(2,true)
    local panel = self:getPanel(LegionSceneMemberPanel.NAME)
    if panel:isVisible() == true then
        panel:onLegionMemberUpdate()
        return
    end
    
end

-- 关闭成员查看界面
function LegionSceneView:onSetJobResp(data)
    -- body
    local panel = self:getPanel(LegionSceneMemberInfoPanel.NAME)
    panel:onClose()
end

--更新互助小红点
function LegionSceneView:onHelpPointUpdate()
    local  panel = self:getPanel(LegionSceneHallPanel.NAME)
    if panel:isVisible() == true then 
        panel:onHelpPointUpdate()
    end 
end

--更新福利红点
function LegionSceneView:onWelfarePointUpdate()
    local  panel = self:getPanel(LegionSceneHallPanel.NAME)
    panel:onWelfarePointUpdate()
end

--更新福利红点
function LegionSceneView:onBattlePointUpdate()
    local  panel = self:getPanel(LegionSceneHallPanel.NAME)
    panel:onBattlePointUpdate()
end

--更新贡献度
function LegionSceneView:onDevoteResp(data)
    local  panel = self:getPanel(LegionSceneHallPanel.NAME)
    panel:onDevoteResp(data)
end

--聊天信息更新
function LegionSceneView:onGetChatInfoResp(data)
    local panel = self:getPanel(LegionSceneHallPanel.NAME)
    panel:updateChatInfos(data.chats)
end
function LegionSceneView:onGetPrivateChatInfoResp(_data)
    local panel = self:getPanel(LegionSceneHallPanel.NAME)
    local data = {}
    data[1] = {name = _data.name,playerId = _data.playerId,type = _data.type,iconId = _data.iconId,context = _data.context}
    panel:updateChatInfos(data)
end

--更新聊天信息数目
function LegionSceneView:updateNoSeeChatNum(data)
    local panel = self:getPanel(LegionSceneHallPanel.NAME)
    panel:onUpdateNoSeeChatNum(data)
end

function LegionSceneView:onClearCmd()
    local panel = self:getPanel(LegionSceneHallPanel.NAME)
    panel:onClearCmd()
end

function LegionSceneView:updateRedPoint(data)
    local panel =self:getPanel(LegionSceneHallPanel.NAME)
    panel:updateRedPoint(data) 
end