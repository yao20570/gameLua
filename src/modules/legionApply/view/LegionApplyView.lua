
LegionApplyView = class("LegionApplyView", BasicView)

function LegionApplyView:ctor(parent)
    LegionApplyView.super.ctor(self, parent)
end

function LegionApplyView:finalize()
    LegionApplyView.super.finalize(self)
end

function LegionApplyView:registerPanels()
    LegionApplyView.super.registerPanels(self)

    require("modules.legionApply.panel.LegionApplyPanel")
    self:registerPanel(LegionApplyPanel.NAME, LegionApplyPanel)
    require("modules.legionApply.panel.LegionApplyInfoPanel")
    self:registerPanel(LegionApplyInfoPanel.NAME, LegionApplyInfoPanel)
    require("modules.legionApply.panel.LegionListPanel")
    self:registerPanel(LegionListPanel.NAME, LegionListPanel)
    require("modules.legionApply.panel.LegionCreatePanel")
    self:registerPanel(LegionCreatePanel.NAME, LegionCreatePanel)
    require("modules.legionApply.panel.LegionRecommendPanel")
    self:registerPanel(LegionRecommendPanel.NAME, LegionRecommendPanel)
end

function LegionApplyView:initView()
    local panel = self:getPanel(LegionApplyPanel.NAME)
    panel:show()
end

--军团列表数据
function LegionApplyView:updateLegionList(shortInfos)
    local panel = self:getPanel(LegionListPanel.NAME)
    panel:updateLegionList(shortInfos)
end

-- 军团推荐列表数据
function LegionApplyView:updateLegionRecommend(recommendInfos)
    local panel = self:getPanel(LegionRecommendPanel.NAME)
    panel:updateLegionRecommend(recommendInfos)

    local panel = self:getPanel(LegionListPanel.NAME)
    if panel:isVisible() and panel:isInitUI() then
        local data = self:getProxy(GameProxys.Legion):getLegionApplyList()
        panel:updateLegionList(data)
    end
end

--军团详细信息
function LegionApplyView:onGetLegionInfo(detailInfo)
    local panel = self:getPanel(LegionApplyInfoPanel.NAME)
    panel:updateData(detailInfo)
end

--军团搜索信息
function LegionApplyView:onSearchLegionInfos(infos)
    local panel = self:getPanel(LegionListPanel.NAME)
    panel:updateLegionList2(infos)
end

--军团申请信息
function LegionApplyView:onApplyResultInfo(id,type)
    -- 更新当前，
    local panel = self:getPanel(LegionListPanel.NAME)
    panel:updateLegionInfo(id,type)
    
    -- 推荐列表申请信息更改
    local recommendPanel = self:getPanel(LegionRecommendPanel.NAME)
    recommendPanel:updateLegionInfo(id,type)
end 

--任命附团推送
function LegionApplyView:updateChildLegion49(data)
    local panel = self:getPanel(LegionRecommendPanel.NAME)
    if panel:isVisible() then
        panel:updateChildLegion49(data)
    end
    
    panel = self:getPanel(LegionListPanel.NAME)
    if panel:isVisible() then
        panel:updateChildLegion49(data)
    end
end

function LegionApplyView:updateTabs()
    local panel = self:getPanel(LegionApplyPanel.NAME)
    panel:updateTabs()
end







