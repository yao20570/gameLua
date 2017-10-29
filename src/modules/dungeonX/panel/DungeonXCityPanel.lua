-- -- /**
-- --  * @Author:      fzw
-- --  * @DateTime:    2016-04-20 21:43:13
-- --  * @Description: 试炼场副本据点详情界面
-- --  */
-- -------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------
DungeonXCityPanel = class("DungeonXCityPanel", BasicPanel)
DungeonXCityPanel.NAME = "DungeonXCityPanel"

function DungeonXCityPanel:ctor(view, panelName)
    DungeonXCityPanel.super.ctor(self, view, panelName,true)

    self:setUseNewPanelBg(true)
end

function DungeonXCityPanel:finalize()
    if self.UITeamDetailPanel then
       self.UITeamDetailPanel:finalize() 
    end
    DungeonXCityPanel.super.finalize(self)
end

function DungeonXCityPanel:initPanel()
    DungeonXCityPanel.super.initPanel(self)
    self:setTitle(true,"budui",true)
    self:setBgType(ModulePanelBgType.TEAM)
end

function DungeonXCityPanel:registerEvents()
    DungeonXCityPanel.super.registerEvents(self)
end

function DungeonXCityPanel:onClosePanelHandler(  )
    -- body
    self:hide()
end

function DungeonXCityPanel:onShowHandler(data)    
    self._uiType = 6
    data.extra = {
        isShowStar = false,   --星星
        isShowLost = false,   --战损
        isShowSleep = false,  --挂机
    }    

    if self.UITeamDetailPanel then
        self.UITeamDetailPanel:onUpdateData(data,self._uiType)
    else
        self.UITeamDetailPanel = UITeamDetailPanel.new(self,data,self._uiType)
    end

    if not self:isRunShowPanelAction() then
        self:showPanelAction()
    end
end

-- -------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------