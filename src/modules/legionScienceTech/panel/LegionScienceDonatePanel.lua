--region egionScienceDonatePanel.lua
--Author : admin
--Date   : 2017/8/28
--此文件由[BabeLua]插件自动生成

LegionScienceDonatePanel = class("LegionScienceDonatePanel",BasicPanel)
LegionScienceDonatePanel.NAME = "LegionScienceDonatePanel"

function LegionScienceDonatePanel:ctor(view,panelName)
    LegionScienceDonatePanel.super.ctor(self,view,panelName,true)
    self:setUseNewPanelBg(true)
end


function LegionScienceDonatePanel:finalize()
    LegionScienceDonatePanel.super.finalize(self)
 
end

function LegionScienceDonatePanel:initPanel()
    LegionScienceDonatePanel.super.initPanel(self)
    self:setBgType(ModulePanelBgType.NONE)
    self:addTabControl()
end


function LegionScienceDonatePanel:doLayout()
    if self._tabControl then 
    end
end

function LegionScienceDonatePanel:addTabControl()
    --self.isCanShowOtherPanel = false
    local tabControl = UITabControl.new(self)
    tabControl:addTabPanel(LegionScienceHallPanel.NAME,self:getTextWord(560206)) --之前为等级  现在改为建筑（策划要求）
    tabControl:addTabPanel(LegionScienceTechPanel.NAME,self:getTextWord(3219))
   
    tabControl:setTabSelectByName(LegionScienceHallPanel.NAME)
    self._tabControl = tabControl

    self:changeDefaultTabPanel()

    self:setTitle(true,"legionHall",true)
end

function LegionScienceDonatePanel:setSelectedPanel(panelName)
    self._tabControl:changeTabSelectByName(panelName)
end 

function LegionScienceDonatePanel:onShowHandler(data)
end

function LegionScienceDonatePanel:registerEvents()
    LegionScienceDonatePanel.super.registerEvents(self)
end

function LegionScienceDonatePanel:onClosePanelHandler()

    self.view:hideModuleHandler()

    --self:dispathcEvent(LegionScienceTechEvent.HIDE_SELF_EVENT)
end
--endregion
