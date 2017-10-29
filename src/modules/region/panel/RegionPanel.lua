
RegionPanel = class("RegionPanel", BasicPanel)
RegionPanel.NAME = "RegionPanel"

function RegionPanel:ctor(view, panelName)
    RegionPanel.super.ctor(self, view, panelName,true)
    -- self.isCanShowOtherPanel = true
    
    self:setUseNewPanelBg(true)
end

function RegionPanel:finalize()
    RegionPanel.super.finalize(self)
end

function RegionPanel:initPanel()
	RegionPanel.super.initPanel(self)

    self:addTabControl()

    local peopleBtn = self:getChildByName("pnlBottom/pnlHeart/btnHeart")
    self:addTouchEventListener(peopleBtn, self.onPeopleBtnTouch)
end

function RegionPanel:addTabControl()
    -- self.isCanShowOtherPanel = false
    local tabControl = UITabControl.new(self)
    tabControl:addTabPanel(CenterRegionPanel.NAME, self:getTextWord(619))
    tabControl:addTabPanel(TravelPanel.NAME, self:getTextWord(620))
    tabControl:setTabSelectByName(CenterRegionPanel.NAME)
    
    self._tabControl = tabControl
    
    self:setTitle(true,"Region",true)
end

function RegionPanel:registerEvents()
    CenterRegionPanel.super.registerEvents(self)
end

function RegionPanel:onShowHandler()
    self._tabControl:setTabSelect(1)
end

--更新中原,远征的红点
function RegionPanel:updateRedPoint()
        
    --远征副本 剩余次数
    local configs = ConfigDataManager:getConfigData(ConfigData.AdventureConfig)
    local dungeonProxy = self:getProxy(GameProxys.Dungeon)
    local num = 0

    for k,v in pairs(configs) do
        if v.ID ~= 4 then  --西域远征另计
            local times = dungeonProxy:getTimesById(v.ID)
            if times ~= -1 then
                num = num + times
            end
        end
    end

    --西域远征
    local limitExpProxy = self:getProxy(GameProxys.LimitExp)
    local limitExpInfos = limitExpProxy:getExinfos()
    if limitInfos then
        if limitInfos.fightCount ~= 0 or limitInfos.backCount ~= 0 then
            num = num + 1
        end
    else
        local roleProxy = self:getProxy(GameProxys.Role)
        num = num + roleProxy:getlimitExp()
    end
    local isShow = false
    if num ~= 0 then
        isShow = true
    end
    self._tabControl:setItemCount(2,isShow,num)

    --中原
    --null

end


function RegionPanel:updatePeopleRed()
    local dotImg = self:getChildByName("pnlBottom/pnlHeart/btnHeart/dot")
    local dot = dotImg:getChildByName("labNum")
    local playerProxy = self:getProxy(GameProxys.Role)
    local supportNum = playerProxy:getRoleAttrValue(PlayerPowerDefine.POWER_support)
    dot:setString(supportNum)
    dotImg:setVisible(self:isUnlockFunc(false) and supportNum > 0)
end

function RegionPanel:isUnlockFunc(isShowMsg)
    -- 判定民心是否已解锁
    local roleProxy = self:getProxy(GameProxys.Role)
    local isUnlock = roleProxy:isFunctionUnLock(17,isShowMsg,nil)
    return isUnlock
end


function RegionPanel:getBottomPanel()
    return self:getChildByName("pnlBottom")
end

function RegionPanel:getTabControl()
    return self._tabControl
end

-- -- 民心按钮
function RegionPanel:onPeopleBtnTouch(sender)
    if self:isUnlockFunc(true) == false then
        return
    end
    self:dispatchEvent(RegionEvent.SHOW_OTHER_EVENT,{name = ModuleName.PopularSupportModule})
end


-- -- 关闭
function RegionPanel:onClosePanelHandler()
    self.view:hideModuleHandler()
end



--[[
界面图块编号：
1=匈奴
2=鲜卑
3=南越
4=西域
5=中原
]]

-- function RegionPanel:registerEvents()
-- 	RegionPanel.super.registerEvents(self)

--     local peopleBtn = self:getChildByName("infoPanel/peopleBtn")
--     local returnBtn = self:getChildByName("returnBtn")
--     self:addTouchEventListener(returnBtn, self.onCloseBtnTouch)
--     self:addTouchEventListener(peopleBtn, self.onPeopleBtnTouch)

--     self["peopleBtn"] = peopleBtn

--     self._maps = {}
--     local mapPanel = self:getChildByName("mapPanel")
--     for index = 1, 5, 1 do
--         local panel = mapPanel:getChildByName("asiaPanel" .. index)
--         if panel then
--             boxPanel = panel:getChildByName("boxPanel")
--             infoPanel = panel:getChildByName("infoPanel")
--             boxPanel:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
--             boxPanel:setTouchEnabled(false)
--             infoPanel:setTouchEnabled(false)
--             if index == 3 then
--                 -- 南越未开启，暂时隐藏
--                 panel:setVisible(false)
--             else
--                 panel:setVisible(true)
--             end

--             panel.index = index
--             panel.boxPanel = boxPanel
--             panel.infoPanel = infoPanel
--             self._maps[index] = panel
--             self:addTouchEventListener(panel, self.onAsiaPanelTouch)

--             self["asiaPanel" .. index] = panel
--         end
--     end
    
-- end

-- -- 刷新宝箱显示
-- function RegionPanel:onShowHandler()
--     local index
--     local boxPanel
--     local dungeonProxy = self:getProxy(GameProxys.Dungeon)
--     local boxes = dungeonProxy:getBoxes()
--     for _,map in pairs(self._maps) do
--         index = map.index
--         -- if index == 3 then
--         --     return  --南越暂无功能
--         -- end

--         boxPanel = map.boxPanel
--         local haveBox = false
--         if  index == 5 then
--             haveBox = self:isHaveBox(index)
--         end
--         if index == 1 or index == 2 then
--             if boxes[index] > 0 then
--                 haveBox = true   
--             end
--         end
--         if index == 4 then
--             haveBox = false   
--         end

--         -- 宝箱特效显示处理
--         local boxEffect = boxPanel.boxEffect
--         if haveBox then
--             boxPanel:setVisible(true)
--             if boxEffect == nil then
--                 boxEffect = UICCBLayer.new("rgb-zy-xiang",boxPanel )
--                 boxPanel.boxEffect = boxEffect
--             end
--         else
--             boxPanel:setVisible(false)
--             if boxEffect ~= nil then
--                 boxEffect:finalize()  --隐藏的时候直接移除
--                 boxPanel.boxEffect = nil
--             end
--         end

--         print("...............index",index)
--         self:updateInfoPanel(map.infoPanel,index)


--     end
--     self:updatePeopleRed()
-- end

-- function RegionPanel:updateInfoPanel(infoPanel,index)
--     -- 进度信息显示处理
--     if index == 3 then
--         return  --南越暂无功能
--     end
--     if index == 5 then
--         infoPanel:setVisible(false)
--         return
--     end

--     infoPanel:setScaleX(NodeUtils:getAdaptiveScale())
--     local countTxt = infoPanel:getChildByName("countTxt")
--     local isUnlock,unlockLV = self:getUnLockLevel(index)
--     if isUnlock == true then
--         -- 已解锁
--         local str
--         local curCount
--         if index == 5 then  --中原显示 进度：第X关
--             curCount = 1
--             str = string.format(self:getTextWord(615),curCount)
--         elseif index == 4 then  --西域显示 进度：第X关
--             local proxy = self:getProxy(GameProxys.LimitExp)
--             info = proxy:getExinfos()
--             if info == nil then  --TODO 还没有西域的数据,应该请求60100
--                 proxy:onTriggerNet60100Req()
--                 curCount = 1
--             else
--                 local config = ConfigDataManager:getInfoFindByOneKey("AdventureEventConfig","ID",info.maxId)
--                 local remainTime = proxy:getMopRemainTime() or 0 
--                 if remainTime > 0 and config ~= nil then
--                     curCount = config.sort - math.floor(remainTime / 30)
--                     if curCount <= 0 then
--                         curCount = 1
--                     end
--                 else
--                     config = ConfigDataManager:getInfoFindByOneKey("AdventureEventConfig","ID",info.id)
--                     curCount = config.sort
--                     -- proxy:onTriggerNet60100Req()  --有可能是扫荡完成了，重新请求一下
--                     -- curCount = 1
--                 end
--             end
--             str = string.format(self:getTextWord(615),curCount)
--         else --显示 次数：x/x
--             local config = ConfigDataManager:getInfoFindByOneKey(self.adventureConfig,"type",index)
--             local maxCount = config.time or 0
--             local proxy = self:getProxy(GameProxys.Dungeon)
--             local oneDungeonInfo = proxy:getDungeonById(index)
--             if oneDungeonInfo == nil then
--                 -- proxy:onTriggerNet60001Req({id = index})
--                 oneDungeonInfo = proxy:getExploreInfoByID(index)
--                 curCount = oneDungeonInfo.count
--             else
--                 curCount = oneDungeonInfo.times or 0
--             end

--             str = string.format(self:getTextWord(614),curCount,maxCount)
--         end
--         countTxt:setString(str)
--         countTxt:setColor(ColorUtils.wordOrangeColor)
--     else
--         -- 未解锁
--         logger:info("未解锁.......index",index)            
--         countTxt:setString(string.format(self:getTextWord(613),unlockLV))
--         countTxt:setColor(ColorUtils.wordRedColor)
--     end    

-- end

-- -- 协议更新数据
-- function RegionPanel:updateInfoResp()
--     self:onShowHandler()
-- end

-- -- 是否显示宝箱
-- function RegionPanel:isHaveBox( index )
--     -- body
--     local dungeonProxy = self:getProxy(GameProxys.Dungeon)
--     local data = dungeonProxy:getDungeonListInfo()

--     local haveBox = false
--     local infos
--     if index == 5 then
--         infos = data.dungeoInfos
--     else
--         infos = data.dungeoExplore
--     end

--     for k,v in pairs(infos) do
--         if v.haveBox == 1 then
--             haveBox = true
--             return haveBox
--         end
--     end

--     return haveBox
-- end


-- --匈奴
-- function RegionPanel:onHandlerAsiaTouch1(index)
--     self:onSendEvent(index)
-- end

-- --鲜卑
-- function RegionPanel:onHandlerAsiaTouch2(index)
--     self:onSendEvent(index)
-- end

-- -- --南越
-- -- function RegionPanel:onHandlerAsiaTouch3(index)
-- --     self:onSendEvent(index)
-- -- end

-- --西域
-- function RegionPanel:onHandlerAsiaTouch4(index)
--     self:onSendEvent(index)
-- end


-- --中原
-- function RegionPanel:onHandlerAsiaTouch5(sender)
--     local panel = self:getPanel(CenterRegionPanel.NAME)
--     panel:show()
--     self:hide()
-- end

-- -- 民心按钮
-- function RegionPanel:onPeopleBtnTouch(sender)
--     if self:isUnlockFunc(true) == false then
--         return
--     end
--     self:dispatchEvent(RegionEvent.SHOW_OTHER_EVENT,{name = ModuleName.PopularSupportModule})
-- end

-- -- 关闭
-- function RegionPanel:onCloseBtnTouch(sender)
--     local panel = self:getPanel(CenterRegionPanel.NAME)
--     panel:show()
--     self:dispatchEvent(RegionEvent.HIDE_SELF_EVENT, {})
--     self:hide()
-- end

-- -- 获取副本当前解锁状态,以及解锁等级
-- function RegionPanel:getUnLockLevel(index)
--     logger:info("lock................index",index)
--     if index == 5 then
--         return true,nil
--     end

--     local unlockLV
--     if index == 3 then
--         unlockLV = 0
--     else
--         local config = ConfigDataManager:getInfoFindByOneKey(self.adventureConfig,"type",index)
--         unlockLV = config.level
--     end

--     local proxy = self:getProxy(GameProxys.Role)
--     local level = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
--     if level < unlockLV then
--         return false,unlockLV
--     end
--     return true,nil
-- end

-- function RegionPanel:onSendEvent(index)
--     local isUnlock,unlockLV = self:getUnLockLevel(index)
--     if isUnlock == true then
--         local info = ConfigDataManager:getInfoFindByOneKey(self.adventureConfig,"type",index)
--         self:dispatchEvent(RegionEvent.SHOW_OTHER_EVENT,{name = ModuleName.DungeonModule,id = index,type = 2,index = index,info = info})
--     else
--         self:showSysMessage(self:getTextWord(608)..unlockLV..self:getTextWord(609))
--     end
-- end

-- function RegionPanel:updatePeopleRed()
--     local dotImg = self:getChildByName("infoPanel/peopleBtn/dot")
--     local dot = dotImg:getChildByName("num")
--     local playerProxy = self:getProxy(GameProxys.Role)
--     local supportNum = playerProxy:getRoleAttrValue(PlayerPowerDefine.POWER_support)
--     dot:setString(supportNum)
--     dotImg:setVisible(self:isUnlockFunc(false) and supportNum > 0)
-- end

-- function RegionPanel:isUnlockFunc(isShowMsg)
--     -- 判定民心是否已解锁
--     local roleProxy = self:getProxy(GameProxys.Role)
--     local isUnlock = roleProxy:isFunctionUnLock(17,isShowMsg,nil)
--     return isUnlock
-- end

-- function RegionPanel:onAsiaPanelTouch(sender)
--     if self._isPlayTouchAcion == nil then
--         self._isPlayTouchAcion = true
--         self:touchAction(sender, self.onAsiaPanelTouchCallBack)
--     else
--         return
--     end
-- end

-- function RegionPanel:onAsiaPanelTouchCallBack(sender)
--     local index = sender.index
--     local func = self["onHandlerAsiaTouch" .. index]
--     if func ~= nil then
--         func(self,index)
--         -- self:hide()
--     end
-- end

-- -- 按钮动画
-- function RegionPanel:touchAction(sender, callback)
--     local bgFlickerAction = cc.TintTo:create(0.1, GlobalConfig.hitBuildColor[1],GlobalConfig.hitBuildColor[2],GlobalConfig.hitBuildColor[3])
--     local bgFlickerAction2 = cc.TintTo:create(0.1, 255,255,255)
--     local action = cc.Sequence:create(bgFlickerAction, bgFlickerAction2)

--     sender:runAction(action)
--     TimerManager:addOnce(0.22 * 1000, callback, self, sender)
    
--     -- 点击按钮1秒后清除标记
--     local function resetcallback( ... )
--         self._isPlayTouchAcion = nil
--     end
--     TimerManager:addOnce(1 * 1000, resetcallback, self)
-- end

-- -- 远征按钮
-- function RegionPanel:onExpeditionBtnTouch(sender)
--     self:hide()
--     local panel = self:getPanel(CenterRegionPanel.NAME)
--     panel:show()
-- end