
LegionScienceTechView = class("LegionScienceTechView", BasicView)

function LegionScienceTechView:ctor(parent)
    LegionScienceTechView.super.ctor(self, parent)
end

function LegionScienceTechView:finalize()
    LegionScienceTechView.super.finalize(self)
end

function LegionScienceTechView:registerPanels()
    LegionScienceTechView.super.registerPanels(self)

    require("modules.legionScienceTech.panel.LegionScienceTechPanel")
    self:registerPanel(LegionScienceTechPanel.NAME, LegionScienceTechPanel)
    
    require("modules.legionScienceTech.panel.ScienceTechUpgratePanel")
    self:registerPanel(ScienceTechUpgratePanel.NAME, ScienceTechUpgratePanel)
    
    require("modules.legionScienceTech.panel.LegionScienceHallPanel")
    self:registerPanel(LegionScienceHallPanel.NAME, LegionScienceHallPanel)

    require("modules.legionScienceTech.panel.LegionScienceDonatePanel")
    self:registerPanel(LegionScienceDonatePanel.NAME,LegionScienceDonatePanel)
end

function LegionScienceTechView:initView()

    --local panel = self:getPanel(LegionScienceHallPanel.NAME)
    --panel:setHtmlStr("html/help_legion.html")

    local panel = self:getPanel(LegionScienceDonatePanel.NAME)
    panel:show()
    --panel:setHtmlStr("html/help_legion.html")
end

function LegionScienceTechView:hideModuleHandler()
    local hallPanel = self:getPanel(LegionScienceHallPanel.NAME)
    hallPanel:onHideHandler()
    self:dispatchEvent(LegionScienceTechEvent.HIDE_SELF_EVENT, {})
end

--------------------------------------------------------------------
function LegionScienceTechView:onShowView(extraMsg, isInit)

	-- logger:info("panel 名字"..tostring(extraMsg.panelName))
	-- LegionScienceTechView.super.onShowView(self,extraMsg, isInit, true)
	if extraMsg ~= nil then
		local donatePanel = self:getPanel(LegionScienceDonatePanel.NAME)
        donatePanel:setSelectedPanel(extraMsg.panelName)
        donatePanel:show()
    else
        local donatePanel = self:getPanel(LegionScienceDonatePanel.NAME)
        donatePanel:setSelectedPanel(LegionScienceHallPanel.NAME)
        donatePanel:show()
        --print("---------------------------------------------------------show")
        local panel=self:getPanel(LegionScienceHallPanel.NAME)
        panel:onShowHandler()
	end
    --local panel=self:getPanel(LegionScienceHallPanel.NAME)
    --panel:onShowHandler()
end

function LegionScienceTechView:onSciTectUpdate()
    -- body
    local panel = self:getPanel(LegionScienceTechPanel.NAME)
    panel:onSciTectUpdate()
end


-- 科技升级
-- function LegionScienceTechView:onSciUpgrateResp(data)
--     local panel = self:getPanel(LegionScienceTechPanel.NAME)
--     panel:onSciUpgrateResp(data)
-- end

-- -- 科技升级
function LegionScienceTechView:onSciUpgrateResp(data)
    local panel = self:getPanel(LegionScienceTechPanel.NAME)
    if panel:isVisible() == true then
        panel:onSciUpgrateResp(data)
    end
end


-- 科技捐献
function LegionScienceTechView:onSciContributeResp(data)
    local panel = self:getPanel(LegionScienceTechPanel.NAME)
    panel:onSciContributeResp(data)
    
    -- local panel = self:getPanel(ScienceTechUpgratePanel.NAME)
    -- panel:onSciContributeResp(data)
end


function LegionScienceTechView:onHallInfoResp(data)
    -- body
    local panel = self:getPanel(LegionScienceHallPanel.NAME)
    if panel:isVisible() == true then
        panel:onHallInfoResp(data)
    end
end
-- 捐献之后更新
function LegionScienceTechView:onHallContributeResp(data)
    -- body
    local panel = self:getPanel(LegionScienceHallPanel.NAME)
    panel:onHallContributeResp(data)
end

-- 捐献之后更新
function LegionScienceTechView:updateRoleInfoHandler()
    -- body
    local panel = self:getPanel(LegionScienceHallPanel.NAME)
    if panel:isVisible() == true then
        panel:updateRoleInfoHandler()
    end
end

function LegionScienceTechView:donatePanelJumpSelectedPanel(panelName)
    local extraMsg 
    if panelName == LegionScienceTechPanel.NAME then
        extraMsg = {
            panelName = panelName,
        }
    end  
    self:onShowView(extraMsg)
end 


