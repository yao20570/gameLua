
MainSceneView = class("MainSceneView", BasicView)

function MainSceneView:ctor(parent)
    MainSceneView.super.ctor(self, parent)
    
    self._hideUpdateBuildList = {} --隐藏时，有更新的建筑数据，因为优化导致的处理 打开升级面板隐藏该面板 供MainScenePanel使用
end

function MainSceneView:finalize()
    MainSceneView.super.finalize(self)
end

function MainSceneView:registerPanels()
    MainSceneView.super.registerPanels(self)

    require("modules.mainScene.panel.MainScenePanel")
    self:registerPanel(MainScenePanel.NAME, MainScenePanel)
    
    require("modules.mainScene.panel.BuildingCreatePanel")
    self:registerPanel(BuildingCreatePanel.NAME, BuildingCreatePanel)
    
    require("modules.mainScene.panel.BuildingUpPanel")
    self:registerPanel(BuildingUpPanel.NAME, BuildingUpPanel)
end

function MainSceneView:initView()
    local panel = self:getPanel(MainScenePanel.NAME)
    panel:show()
end

function MainSceneView:updateBuildingInfo(buildingInfo)
    local panel = self:getPanel(MainScenePanel.NAME)
    if panel:isVisible() then
        panel:updateBuildingInfo(buildingInfo)
    else
        table.insert(self._hideUpdateBuildList, {buildingIndex = buildingInfo.index, 
            buildingType = buildingInfo.buildingType})
    end
end

function MainSceneView:getHideUpdateBuildList(panelName)
    return self._hideUpdateBuildList
end

function MainSceneView:clearHideUpdateBuildMap()
    self._hideUpdateBuildList = {}
end

function MainSceneView:buildingAllUpdate(data)
    logger:error("-=====MainSceneView=====buildingAllUpdate============")
    local panel = self:getPanel(MainScenePanel.NAME)
    panel:initAllBuilding()
end

function MainSceneView:onSoldierMofidy()
    local panel = self:getPanel(MainScenePanel.NAME)
    panel:onUpdateSoldiers()
end

function MainSceneView:onEnterScene()
    local panel = self:getPanel(MainScenePanel.NAME)
    panel:enterSceneAction()
end

function MainSceneView:onUpdateSoldiers()
    local panel = self:getPanel(MainScenePanel.NAME)
    panel:onUpdateSoldiers()
end

function MainSceneView:updateLegionBuildingInfo(data)
    local panel = self:getPanel(MainScenePanel.NAME)
    panel:updateLegion(data)
end

function MainSceneView:onShowView(extraMsg,isInit)
    MainSceneView.super.onShowView(self,extraMsg,isInit,true)
    local mainScenePanel = self:getPanel(MainScenePanel.NAME)
    mainScenePanel:show()
    --mainScenePanel:changeSceneActionIn()
end

function MainSceneView:onCloseView()
    MainSceneView.super.onCloseView(self)
    local mainScenePanel = self:getPanel(MainScenePanel.NAME)
    mainScenePanel:hide()
    --mainScenePanel:changeSceneActionOut()
    --local function callback()
    --    MainSceneView.super.onCloseView(self)
    --    local mainScenePanel = self:getPanel(MainScenePanel.NAME)
    --    mainScenePanel:hide()
    --end
    --TimerManager:addOnce(700, callback, self) 
end


function MainSceneView:onItemUseResp()
    -- body
    local panel = self:getPanel(BuildingUpPanel.NAME)
    if panel:isVisible() == true then
--        print("0000···MainSceneView:onItemUseResp()")
        self:showSysMessage(self:getTextWord(1011)) --使用物品成功飘字：使用成功
    end
end

function MainSceneView:onItemBuyResp()
    -- body
    local panel = self:getPanel(BuildingUpPanel.NAME)
    if panel:isVisible() == true then
--        print("3333···MainSceneView:onItemBuyResp()")
        self:showSysMessage(self:getTextWord(1012)) --使用物品成功飘字：使用成功
    end
end

function MainSceneView:showFullScreenPanel()
    local mainScenePanel = self:getPanel(MainScenePanel.NAME)
    mainScenePanel:hide()
    
    self:setModuleVisible(ModuleName.ToolbarModule, false)
    self:setModuleVisible(ModuleName.RoleInfoModule, false)

    SDKManager:setMultipleTouchEnabled(false)  --隐藏主城，屏蔽多点触控
end

function MainSceneView:hideFullScreenPanel()
    local mainScenePanel = self:getPanel(MainScenePanel.NAME)
    mainScenePanel:show()

    self:setModuleVisible(ModuleName.ToolbarModule, true)
    self:setModuleVisible(ModuleName.RoleInfoModule, true)

    SDKManager:setMultipleTouchEnabled(true)  --显示主城，打开多点触控
end

function MainSceneView:onEndGuide()
    local mainScenePanel = self:getPanel(MainScenePanel.NAME)
    mainScenePanel:onShowHandler()
    -- mainScenePanel:update()
    -- mainScenePanel:onUpdateSoldiers()
    
    -- mainScenePanel:createOrUpdatePatrouille()

    -- mainScenePanel:createOrUpdateWater()

    -- mainScenePanel:createOrUpdateBird()
end

