
MainSceneModule = class("MainSceneModule", BasicModule)

function MainSceneModule:ctor()
    MainSceneModule .super.ctor(self)
    
    self.isFullScreen = false
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_2_LAYER

    self.isLayoutNode = false
    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function MainSceneModule:initRequire()
    require("modules.mainScene.event.MainSceneEvent")
    require("modules.mainScene.view.MainSceneView")
    
    require("modules.mainScene.map.MainSceneMap")
end

function MainSceneModule:finalize()
    MainSceneModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function MainSceneModule:initModule()
    MainSceneModule.super.initModule(self)
    self._view = MainSceneView.new(self.parent)

    self:addEventHandler()
    self._isEnterScene = false
    
     -- local chatProxy = self:getProxy(GameProxys.Chat)
     -- chatProxy:onResetLoaclChatData()
end

function MainSceneModule:addEventHandler()
    self._view:addEventListener(MainSceneEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(MainSceneEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:addEventListener(MainSceneEvent.HIDE_OTHER_EVENT, self, self.onHideOtherHandler)
    self._view:addEventListener(MainSceneEvent.MOVESCENE_SEND, self, self.onSendMoveSceneHandler)
    

    self:addEventListener(AppEvent.NET_M2, AppEvent.NET_M2_C20301, self, self.onGetGuideRewardResp)

    self:addProxyEventListener(GameProxys.Building, AppEvent.PROXY_BUILDING_UPDATE, self, self.buildingUpdateHandler)
    self:addProxyEventListener(GameProxys.Building, AppEvent.BUILDING_LEVEL_UP, self, self.onShowBuildingUpEffect)
    self:addProxyEventListener(GameProxys.Building, AppEvent.PROXY_BUILDING_ALL_UPDATE, self, self.buildingAllUpdateHandler)
    self:addProxyEventListener(GameProxys.Soldier, AppEvent.PROXY_SOLIDER_MOFIDY, self, self.soldierMofidyHandler)
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_LEGION_MAINSCENE_BUILDING_UPDATE, self, self.updateLegionBuildingInfo)
    self:addProxyEventListener(GameProxys.Task, AppEvent.PROXY_TASK_GUIDE, self, self.onMainTaskGuideUpdate)

    self:addEventListener(AppEvent.SCENE_EVENT, AppEvent.SCENE_ENTER_EVENT, self, self.onEnterScene)
    self:addEventListener(GameProxys.Soldier, AppEvent.PROXY_SOLIDER_MOFIDY, self, self.onUpdateSoldiers)
    self:addEventListener(AppEvent.NET_M9,AppEvent.NET_M9_C90001, self, self.onItemUseResp)
    self:addEventListener(AppEvent.NET_M10,AppEvent.NET_M10_C100007, self, self.onItemBuyResp)
    
    self._view:addEventListener(MainSceneEvent.HIDE_MAIN_BTN, self, self.hideMainBtn)

    -- 感叹号刷新消息回调
    self:addProxyEventListener(GameProxys.Arena, AppEvent.PROXY_ARENA_ALLINFOS, self, self.updateMarkTip) -- 演武场
    self:addProxyEventListener(GameProxys.Arena, AppEvent.PROXY_ARENA_GETREWARD, self, self.updateMarkTip) -- 演武场奖励相关
    self:addProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_CONSIGRECRUIT, self, self.updateMarkTip) -- 军师
    self:addProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_UPDATE_BUY_VIEW, self, self.updateMarkTip) -- 军师
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_OPEN_BUILD_CONSIGRE, self, self.updateMarkTip) -- 军师开启回调
    self:addProxyEventListener(GameProxys.Parts,AppEvent.PARTS_UPDATE_BUILD_TIP, self, self.updateMarkTip)  -- 军械坊, 包括：军械穿戴，军械合成分解
    -- 军团感叹号刷新，特殊：在场景的时候load一遍就好- 每次打开都刷一下军团建筑信息显示
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_LEGION_UPDATE_MAINSCENE_TIP, self, self.updateMarkTip) -- 更新军团名字[20201] 退出军团时候用到
    
    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_CLOSE_UPDATE_MAINSCENE_TIP, self, self.updateMarkTip) -- 关闭军团load

--    self:addProxyEventListener(GameProxys.Building, AppEvent.PROXY_CREATE_NEW_BUILD_PANEL, self, self.showCreateBuildPanel) -- 显示创建界面
    self:addProxyEventListener(GameProxys.Building, AppEvent.BUILDING_CANCEL_UPDATE, self, self.buildingUCancelHandler)

    self:addProxyEventListener(GameProxys.Country, AppEvent.PROXY_COUNTRY_CHANGE_DYNASTY, self, self.setEmperorBuildingString)-- 修改朝代名回调
end

function MainSceneModule:removeEventHander()
    self:removeEventListener(MainSceneEvent.HIDE_MAIN_BTN, self, self.hideMainBtn)
    self._view:removeEventListener(MainSceneEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(MainSceneEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:removeEventListener(MainSceneEvent.HIDE_OTHER_EVENT, self, self.onHideOtherHandler)
    self._view:removeEventListener(MainSceneEvent.MOVESCENE_SEND, self, self.onSendMoveSceneHandler)
    
    self:removeEventListener(AppEvent.NET_M2, AppEvent.NET_M2_C20301, self, self.onGetGuideRewardResp)

    self:removeProxyEventListener(GameProxys.Task, AppEvent.PROXY_TASK_GUIDE, self, self.onMainTaskGuideUpdate)
    self:removeProxyEventListener(GameProxys.Building, AppEvent.PROXY_BUILDING_UPDATE, self, self.buildingUpdateHandler)
    self:removeProxyEventListener(GameProxys.Building, AppEvent.PROXY_BUILDING_ALL_UPDATE, self, self.buildingAllUpdateHandler)
    self:removeProxyEventListener(GameProxys.Building, AppEvent.BUILDING_LEVEL_UP, self, self.onShowBuildingUpEffect)
    self:removeProxyEventListener(GameProxys.Soldier, AppEvent.PROXY_SOLIDER_MOFIDY, self, self.soldierMofidyHandler)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_LEGION_MAINSCENE_BUILDING_UPDATE, self, self.updateLegionBuildingInfo)
    self:removeEventListener(AppEvent.SCENE_EVENT, AppEvent.SCENE_ENTER_EVENT, self, self.onEnterScene)
    self:removeEventListener(GameProxys.Soldier, AppEvent.PROXY_SOLIDER_MOFIDY, self, self.onUpdateSoldiers)
    self:removeEventListener(AppEvent.NET_M9,AppEvent.NET_M9_C90001, self, self.onItemUseResp)
    self:removeEventListener(AppEvent.NET_M10,AppEvent.NET_M10_C100007, self, self.onItemBuyResp)
    -- 感叹号刷新消息回调
    self:removeProxyEventListener(GameProxys.Arena, AppEvent.PROXY_ARENA_ALLINFOS, self, self.updateMarkTip) -- 演武场
    self:removeProxyEventListener(GameProxys.Arena, AppEvent.PROXY_ARENA_GETREWARD, self, self.updateMarkTip)
    self:removeProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_CONSIGRECRUIT, self, self.updateMarkTip) -- 军师
    self:removeProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_UPDATE_BUY_VIEW, self, self.updateMarkTip) -- 军师
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_OPEN_BUILD_CONSIGRE, self, self.updateMarkTip) -- 军师开启回调
    self:removeProxyEventListener(GameProxys.Parts,AppEvent.PARTS_UPDATE_BUILD_TIP, self, self.updateMarkTip)  -- 军械坊
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_LEGION_UPDATE_MAINSCENE_TIP, self, self.updateMarkTip) -- 更新军团名字[20201] 
    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_CLOSE_UPDATE_MAINSCENE_TIP, self, self.updateMarkTip) -- 关闭军团load

--    self:removeProxyEventListener(GameProxys.Building, AppEvent.PROXY_CREATE_NEW_BUILD_PANEL, self, self.showCreateBuildPanel) -- 显示创建界面
    self:removeProxyEventListener(GameProxys.Building, AppEvent.BUILDING_CANCEL_UPDATE, self, self.buildingUCancelHandler)

    self:removeProxyEventListener(GameProxys.Country, AppEvent.PROXY_COUNTRY_CHANGE_DYNASTY, self, self.setEmperorBuildingString)-- 修改朝代名回调
end

function MainSceneModule:onSendMoveSceneHandler(data)
    -- body
    -- logger:info("MainSceneModule 发送通知。。。00")
    self:sendNotification(AppEvent.SCENE_EVENT, AppEvent.SCENEMAP_MOVE_UPDATE, data)
end

--
function MainSceneModule:onOpenModule(extraMsg)
    MainSceneModule.super.onOpenModule(self, extraMsg)
    --为true时，toolbar的queueBtn显示
    self:sendNotification(AppEvent.STATE_EVENT,AppEvent.QUEUEBTN_STATE_EVENT, true)
    -- --判断是否有角色名，如果没有则打开创建角色界面
    --  local roleProxy = self:getProxy(GameProxys.Role)
    --  local roleName = roleProxy:getRoleName()
    --  if roleName == "" then
    --      local flag = GuideManager:trigger(101)
    --      if flag == false then --引导不成功，直接弹
    --          local function openCreatRole()
    --              self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.CreateRoleModule})
    --          end
    --          TimerManager:addOnce(100, openCreatRole, self)
    --      else
    --      end
    --  end
    
    -- local roleProxy = self:getProxy(GameProxys.Role)
    -- local hasNewGift = roleProxy:hasNewGift()
    -- if hasNewGift == true then --有新手礼包，但是新手已经跳过了
    --     if GuideManager:isGuideTrigger(102) == true then
    --         local function openGideReward()
    --             local parent = self:getLayer(ModuleLayer.UI_TOP_LAYER)
    --             UIGuideReward.new(parent, self)
    --         end
            
    --         TimerManager:addOnce(100, openGideReward, self)
    --     end
    -- end
--    self._view:onUpdateSoldiers()   --从打野模块跳过来的时候要更新佣兵数量 内部更新了
end

function MainSceneModule:onEnterScene()
    -- print("... 进入主城 走一下引导 还原快照 ...")
    self._view:onEnterScene()
    AudioManager:playEffect("yx_login")

    local roleProxy = self:getProxy(GameProxys.Role)

    -- local isReConnect = roleProxy:getReConnectState()
    -- if isReConnect == true then  --断线重连先关闭当前的guide
    --     local isTrue = GuideManager:isStartGuide()
    --     if isTrue then
    --         GuideManager:setStartGuide(not isTrue)
    --         GuideManager:hideGuide()
    --     end        
    -- end
    -- GuideManager:resetSnaphot()

    local isReConnect = roleProxy:getReConnectState()
    if isReConnect == true then  --断线重连先关闭当前的guide
        -- 断线重连关闭下城主战
        self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.LordCityModule})

        self:setMask(true)
        local isTrue = GuideManager:isStartGuide()
        if isTrue then
            GuideManager:setStartGuide(not isTrue)
            GuideManager:hideGuide()
        end        
        local function resetSnaphot()
            self:setMask(false)
            GuideManager:resetSnaphot()
        end
        TimerManager:addOnce(30, resetSnaphot, self)  --断线重连延时一下还原快照，等20000的数据处理完
    else
        GuideManager:resetSnaphot()
    end


    local roleName = roleProxy:getRoleName()    
    local hasNewGift = roleProxy:hasNewGift()
    if hasNewGift == true then --有新手礼包，但是新手已经跳过了
        local function openGideReward()
--                local parent = self:getLayer(ModuleLayer.UI_TOP_LAYER)
--                UIGuideReward.new(parent, self)
            self:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20301, {})
        end
        if GuideManager:isGuideTrigger(GuideManager.EndGuideId) == true then
            -- TimerManager:addOnce(30, openGideReward, self)
        else
            if roleName ~= "" then --有取名了，但是引导本地缓存被清除掉了
                print(".. --有取名了，但是引导本地缓存被清除掉了 请求20301..")
                TimerManager:addOnce(30, openGideReward, self)
            end
        end
    end

    ---------------------------------------------------------------------------
    
--    if GuideManager:isStartGuide() == true then
--        local function delayPlayAudio()
--            AudioManager:playEffect("guide01") --在引导这个101，播放特效
--        end
--        TimerManager:addOnce(600, delayPlayAudio, self)
--    end

    local playerName = roleProxy:getRoleName()
    local preid = roleProxy:getPreid()
    if string.len(playerName) > 1 and preid > 0 then
        local info = ConfigDataManager:getConfigById(ConfigData.MilitaryRankConfig, preid)
        local text = string.format(self:getTextWord(18108),info.name,info.prestige)
        self:showSysMessage(text)
    end
    
    self._isEnterScene = true

    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:setToolbarRedPonintInfo()   --toolbar 初始化后 分别给每个小红点赋值

    --名字是空的，弹出剧情模块
    if roleName == "" then
        local data = {}
        data["moduleName"] = ModuleName.CreateRoleModule
        --data["moduleName"] = ModuleName.DramaModule
        data["isPerLoad"] = true
        self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)

        self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.MainSceneModule})
     end
end

function MainSceneModule:isEnterScene()
    return self._isEnterScene
end

---------------------------280004
function MainSceneModule:buildingUpdateHandler(data)
    self._view:updateBuildingInfo(data)
end

function MainSceneModule:buildingAllUpdateHandler(data)
    self._view:buildingAllUpdate()
end

function MainSceneModule:soldierMofidyHandler(data)
    self._view:onSoldierMofidy()
end

function MainSceneModule:updateLegionBuildingInfo(data)
    self._view:updateLegionBuildingInfo(data)
end

-----------------------
function MainSceneModule:onGetGuideRewardResp(data)
    if data.rs == 0 then
        local roleProxy = self:getProxy(GameProxys.Role)
        roleProxy:getNewGift()
        -- local info = {}
        -- info.soldierList = data.changeInfo.soldierList
        -- info.itemList = data.changeInfo.itemList
        -- info.equipinfos = data.changeInfo.equipinfos
        -- info.odInfos = data.changeInfo.odInfos
        -- info.odpInfos = data.changeInfo.odpInfos
        -- info.diffs = data.changeInfo.diffs
        -- -- info.heros = data.changeInfo.heros
        -- info.adviserInfos = data.changeInfo.adviserInfos
        -- rawset(info, "noShow", true)
        -- roleProxy:onTriggerNet20007Resp(info)
        self._view:onEndGuide()
    end
end


--------------------------

------------------------

function MainSceneModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function MainSceneModule:onShowOtherHandler(data)
    local moduleName = data.moduleName
    local buildingType = data.buildingType
    local buildingIndex = data.buildingIndex
    
    local buildingProxy = self:getProxy(GameProxys.Building)
    buildingProxy:setBuildingPos(buildingType, buildingIndex) 
    
    local sendData = {}
    sendData.moduleName = moduleName
    if rawget(data,"panelName") then
        sendData.extraMsg = {}
        sendData.extraMsg.panelName = data.panelName        
    end
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, sendData)
    -- self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function MainSceneModule:onHideOtherHandler(data)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, data)
end


function MainSceneModule:onUpdateSoldiers(data)
    self._view:onUpdateSoldiers() 
end

function MainSceneModule:onItemUseResp(data)
    if data.rs == 0 then
        self._view:onItemUseResp()
        -- self:showSysMessage(self:getTextWord(1011)) --使用物品成功飘字：使用成功
    end
end

function MainSceneModule:onItemBuyResp(data)
    -- body
    if data.rs == 0 then
        self._view:onItemBuyResp()
        -- self:showSysMessage(self:getTextWord(1012)) --购买使用物品成功飘字：购买使用成功
    end
end

function MainSceneModule:hideMainBtn(state)
    -- 拖动为true
    self:getModule(ModuleName.ToolbarModule):hideMainBtn(state)
end

------
-- 播放特效
function MainSceneModule:onShowBuildingUpEffect(buildingInfo)
    self:getPanel(MainScenePanel.NAME):onShowBuildingUpEffect(buildingInfo)
end

------
-- 感叹号特效
function MainSceneModule:updateMarkTip()
    local mainScenePanel = self:getPanel(MainScenePanel.NAME)
    -- 暂时做全刷新 TODO 分离 
    local buildingProxy = self:getProxy(GameProxys.Building) 
    local markTable = buildingProxy:getMarkData()
    for key, moduleName in pairs(markTable) do
        mainScenePanel:updateMarkTip(moduleName)
    end
end


function MainSceneModule:onMainTaskGuideUpdate(data)
    local panel = self:getPanel(data.panelName)
    if panel:isVisible() == true then
        panel:hide()
    end
end

function MainSceneModule:setVisible(visible)
    MainSceneModule.super.setVisible(self, visible)
    SDKManager:setMultipleTouchEnabled(visible)
end

-- 显示创建界面
--function MainSceneModule:showCreateBuildPanel(data)
--    local panel = self:getPanel(BuildingCreatePanel.NAME)
--    panel:show(data)
--end

function MainSceneModule:buildingUCancelHandler(data)
    local panel = self:getPanel(BuildingUpPanel.NAME)
    if panel:isVisible() == true then
        panel:hide()
    end
end

function MainSceneModule:setEmperorBuildingString()
    local panel = self:getPanel(MainScenePanel.NAME)
    panel:setEmperorBuildingString()
end

