
LegionWelfareView = class("LegionWelfareView", BasicView)

function LegionWelfareView:ctor(parent)
    LegionWelfareView.super.ctor(self, parent)
end

function LegionWelfareView:finalize()
    LegionWelfareView.super.finalize(self)
end

function LegionWelfareView:registerPanels()
    LegionWelfareView.super.registerPanels(self)

    require("modules.legionWelfare.panel.LegionWelfarePanel")
    self:registerPanel(LegionWelfarePanel.NAME, LegionWelfarePanel)
    
    --
    require("modules.legionWelfare.panel.LegionWelfareDailyPanel")
    self:registerPanel(LegionWelfareDailyPanel.NAME, LegionWelfareDailyPanel)
    require("modules.legionWelfare.panel.LegionWelfareWarPanel")
    self:registerPanel(LegionWelfareWarPanel.NAME, LegionWelfareWarPanel)
    require("modules.legionWelfare.panel.LegionWelfareActivePanel")
    self:registerPanel(LegionWelfareActivePanel.NAME, LegionWelfareActivePanel)
    require("modules.legionWelfare.panel.LegionWelfareActiveTipPanel")
    self:registerPanel(LegionWelfareActiveTipPanel.NAME, LegionWelfareActiveTipPanel)
    require("modules.legionWelfare.panel.LegionWelfareWarAllotPanel")
    self:registerPanel(LegionWelfareWarAllotPanel.NAME, LegionWelfareWarAllotPanel)
end

function LegionWelfareView:initView()
    local panel = self:getPanel(LegionWelfarePanel.NAME)
    panel:show()
    panel:setHtmlStr("html/legion_active.html")
end
--打开系统
function LegionWelfareView:onShowView(extraMsg, isInit)
    LegionWelfareView.super.onShowView(self,extraMsg, isInit,true)
end
--更新日常福利数据
function LegionWelfareView:updateWelfareDailyInfo(data)
    self.panelInfo = data
    local dailyPanel = self:getPanel(LegionWelfareDailyPanel.NAME)
    if dailyPanel._isInitUI == true then
        dailyPanel:updateData(data)
    end
     
    local activePanel = self:getPanel(LegionWelfareActivePanel.NAME)
    if activePanel:isVisible() == true then
        activePanel:updateData(data)
    end 
end 
--领取福利成功
function LegionWelfareView:onWelfareGetResp(iscangetWelf)
    local dailyPanel = self:getPanel(LegionWelfareDailyPanel.NAME)
    if dailyPanel._isInitUI == true then
        dailyPanel:onWelfareGetResp(iscangetWelf)
    end
end 
--领取资源成功
function LegionWelfareView:onResourceGetResp()
    local activePanel = self:getPanel(LegionWelfareActivePanel.NAME)
    if activePanel._isInitUI == true then
        activePanel:onResourceGetResp()
    end
end 
--更新活跃榜
function LegionWelfareView:updateMenberActivity(data)
    local panel = self:getPanel(LegionWelfareActiveTipPanel.NAME)
    if panel._isInitUI == true then
        panel:updateMenberActivity(data)
    end 
end 

--更新战事福利
function LegionWelfareView:updateWelfarList()
    local panel = self:getPanel( LegionWelfareWarPanel.NAME )
    panel:updateListView()

    panel =self:getPanel(LegionWelfareWarAllotPanel.NAME)
    panel:updateListView()
end

--福利分配后，更新战事福利 --道具数量为0，关闭分配窗口
function LegionWelfareView:updateAllotPanel( typeid, number )
    local panel = self:getPanel( LegionWelfareWarAllotPanel.NAME )

    --分配界面刷新
    if panel:isVisible() and typeid==panel:getCurUseTypeId() then
        panel:updateNumber( number )
    end
    
    -- --列表界面刷新
    -- panel = self:getPanel( LegionWelfareWarPanel.NAME )
    -- panel:updateListData( typeid, number )
end

function LegionWelfareView:updateAllotMemberList()
    local panel = self:getPanel( LegionWelfareWarAllotPanel.NAME )
    panel:updateListView()
end

function LegionWelfareView:onWelfarePointUpdate()
     --刷新tab小红点
    local welfarePanel = self:getPanel(LegionWelfarePanel.NAME)
    welfarePanel:onShowHandler()
end
--关闭系统
function LegionWelfareView:onCloseView()
    LegionWelfareView.super.onCloseView(self)
end
