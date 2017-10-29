
LegionApplyPanel = class("LegionApplyPanel", BasicPanel)
LegionApplyPanel.NAME = "LegionApplyPanel"

function LegionApplyPanel:ctor(view, panelName)
    LegionApplyPanel.super.ctor(self, view, panelName,true)
    
    self:setUseNewPanelBg(true)
end

function LegionApplyPanel:finalize()
    LegionApplyPanel.super.finalize(self)
end

function LegionApplyPanel:initPanel()
	LegionApplyPanel.super.initPanel(self)
	self:setBgType(ModulePanelBgType.NONE)
    self:setTitle(true,"legionHall", true)
    
    local tabControl = UITabControl.new(self)
    self._tabControl = tabControl

    tabControl:addTabPanel(LegionRecommendPanel.NAME, self:getTextWord(3035))
    tabControl:addTabPanel(LegionListPanel.NAME, self:getTextWord(3000))
    tabControl:addTabPanel(LegionCreatePanel.NAME, self:getTextWord(3001),true)
    
    self:updateTabs()
end
 
--发送关闭系统消息
function LegionApplyPanel:onClosePanelHandler()
    self.view:dispatchEvent(LegionApplyEvent.HIDE_SELF_EVENT)
end

function LegionApplyPanel:updateTabs()
    self:isSetChildLegion()
    self._tabControl:updateItemPosX()
end

-- 任命副盟：是否显示同盟推荐标签、创建标签
function LegionApplyPanel:isSetChildLegion()
    local tabControl = self._tabControl
    local proxy = self:getProxy(GameProxys.LordCity)
    local isSetChildLegion,_ = proxy:isSetChildLegion()
    if isSetChildLegion then
        -- logger:info(" 城主战 ~ 标签页 ")
        tabControl:setTabVisibleByIndex(1,false)
        tabControl:setTabVisibleByIndex(2,true)
        tabControl:setTabVisibleByIndex(3,false)
        tabControl:setTabSelectByName(LegionListPanel.NAME)
    else
        -- logger:info(" 同盟 ~ 标签页 ")
        tabControl:setTabVisibleByIndex(1,true)
        tabControl:setTabVisibleByIndex(2,true)
        tabControl:setTabVisibleByIndex(3,true)
        tabControl:setTabSelectByName(LegionRecommendPanel.NAME)
    end
end



function LegionApplyPanel:getAdtNode()
    return self._tabControl:getBgAdapNode(UITabControl.AdaptNode.LegionCreate)
end
