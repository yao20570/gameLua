
DungeonXView = class("DungeonXView", BasicView)

function DungeonXView:ctor(parent)
    DungeonXView.super.ctor(self, parent)
end

function DungeonXView:finalize()
    DungeonXView.super.finalize(self)
end

function DungeonXView:registerPanels()
    DungeonXView.super.registerPanels(self)

    require("modules.dungeonX.panel.DungeonXPanel")
    self:registerPanel(DungeonXPanel.NAME, DungeonXPanel)
    require("modules.dungeonX.panel.DungeonXMapPanel")
    self:registerPanel(DungeonXMapPanel.NAME, DungeonXMapPanel)
    require("modules.dungeonX.panel.DungeonXCityPanel")
    self:registerPanel(DungeonXCityPanel.NAME, DungeonXCityPanel)
    require("modules.dungeonX.panel.DungeonXCityInfoPanel")
    self:registerPanel(DungeonXCityInfoPanel.NAME, DungeonXCityInfoPanel)
end

function DungeonXView:initView()
    local panel = self:getPanel(DungeonXPanel.NAME)
    panel:show()
end

function DungeonXView:hideCityPanle()
    local panel = self:getPanel(DungeonXCityPanel.NAME)
    panel:hide()
end

function DungeonXView:setCloseBtnVisible(bool)
    local panel = self:getPanel(DungeonXPanel.NAME)
    panel:setCommentBtnVisible(bool)
end
-- --------------------------------------------------------------------
-- 重写onShowView(),用于每次打开panel都执行onShowHandler()
function DungeonXView:onShowView(extraMsg, isInit)
    DungeonXView.super.onShowView(self,extraMsg, isInit)
end

function DungeonXView:onUpdateMap()
    local panel = self:getPanel(DungeonXMapPanel.NAME)
    panel:show()
end

function DungeonXView:onDungeonInfoResp(data,curChapterId,allMapData)
    -- logger:info("DungeonXView:onDungeonInfoResp.......0")
    local panel = self:getPanel(DungeonXMapPanel.NAME)
    if panel:isVisible() then
        -- logger:info("DungeonXView:onDungeonInfoResp....显示地图副本...1")
        panel:onDungeonInfoResp(data,curChapterId,allMapData)
    end
end

function DungeonXView:onGetBoxUpdate(data)
    local panel = self:getPanel(DungeonXMapPanel.NAME)
    if panel:isVisible() then
        panel:onGetBoxUpdate(data)
    end
end

function DungeonXView:onEventsUpdate()
    local panel = self:getPanel(DungeonXMapPanel.NAME)
    if panel:isVisible() then
    	panel:onEventsUpdate()
    end
end
