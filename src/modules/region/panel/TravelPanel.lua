--战役：远征列表界面
TravelPanel = class("TravelPanel", BasicPanel)
TravelPanel.NAME = "TravelPanel"

function TravelPanel:ctor(view, panelName)
    TravelPanel.super.ctor(self, view, panelName)
end

function TravelPanel:finalize()
    self:releaseEffectPool()
    TravelPanel.super.finalize(self)
end

function TravelPanel:initPanel()
	TravelPanel.super.initPanel(self)
    self.adventureConfig = "AdventureConfig"
    self._scrollView = self:getChildByName("scrollView")
end

function TravelPanel:doLayout()
    local regionPanel = self:getPanel(RegionPanel.NAME)
    local bottomPanel = regionPanel:getBottomPanel()
    local tabPanel = self:getTabsPanel()
    
    NodeUtils:adaptiveListView(self._scrollView , bottomPanel, tabPanel, GlobalConfig.topTabsHeight)
    self:createScrollViewItemUIForDoLayout(self._scrollView)

end

function TravelPanel:registerEvents()
    TravelPanel.super.registerEvents(self)
end

-- 刷新宝箱显示
function TravelPanel:onShowHandler()
    local infos = ConfigDataManager:getConfigDataBySortKey(self.adventureConfig,"level")
    self:renderScrollView(self._scrollView, "pnlItem", infos, self, self.renderItemPanel, 1, GlobalConfig.scrollViewRowSpace)

end

function TravelPanel:onAsiaPanelTouch(sender)
    if not self._isPlayTouchAcion then
        self._isPlayTouchAcion = true
        self:touchAction(sender, self.onAsiaPanelTouchCallBack)
    else
        return
    end
end

-- 按钮动画
function TravelPanel:touchAction(sender, callback)
    local bgFlickerAction = cc.TintTo:create(0.1, GlobalConfig.hitBuildColor[1],GlobalConfig.hitBuildColor[2],GlobalConfig.hitBuildColor[3])
    local bgFlickerAction2 = cc.TintTo:create(0.1, 255,255,255)
    local action = cc.Sequence:create(bgFlickerAction, bgFlickerAction2)

    sender:runAction(action)
    TimerManager:addOnce(0.22 * 1000, callback, self, sender)
    
    -- 点击按钮1秒后清除标记
    local function resetcallback( ... )
        self._isPlayTouchAcion = nil
    end
    TimerManager:addOnce(1 * 1000, resetcallback, self)
end

function TravelPanel:onAsiaPanelTouchCallBack(sender)
    self:onSendEvent(sender)
end

function TravelPanel:onSendEvent(sender)
    local id = sender.data.ID
    local type = sender.data.type
    local info = sender.data
    
    local isUnlock,unlockLV = self:getUnLockLevel(id)
    if isUnlock == true then
        
        local proxy = self:getProxy(GameProxys.Dungeon)
        if type == 3 then  --精英副本            
            proxy:setSubBattleType(1)
        else
            proxy:setSubBattleType(0)
        end

        self:dispatchEvent(RegionEvent.SHOW_OTHER_EVENT,{name = ModuleName.DungeonModule,id = id,type = 2,index = id,info = info})
    else
        -- 未开放，动作点亮还原
        NodeUtils:setEnableColor(sender, false)
        self:showSysMessage(self:getTextWord(608)..unlockLV..self:getTextWord(609))
    end
end

function TravelPanel:renderItemPanel(listItem, data, index)
    listItem.data = data
    local id = data.ID

    if not listItem._isInit then
        listItem._isInit = true
        NodeUtils:setNodeNameForKey(listItem,1)--获取所有子节点,放在listItem下面
    end
    --底图
    local panelIcon = data.panelIcon
    local url = string.format("images/region/SpBgEx%d.png",panelIcon or 1)
    TextureManager:updateImageView(listItem.bg,url) 

    --描述
    listItem.labDesc:setString("")
    -- local describe = {{{data.info, 18, "#eed6aa"}}}
    -- local descLabel = listItem.labDesc
    -- if descLabel.richLabel == nil then
    --     descLabel:setString("")
    --     descLabel.richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
    --     descLabel:addChild(descLabel.richLabel)
    -- end

    -- --描述字
    -- if describe then
    --     descLabel.richLabel:setString(describe)
    -- end

    --战损
    listItem.labLose:setString("")
    local lostShow = data.lostShow    
    local repairShow = data.repairShow    
    local lostStr = ""
    if repairShow > 0 then
        lostStr = string.format(self:getTextWord(624),repairShow/100.0)
    else
        lostStr = string.format(self:getTextWord(623),lostShow/100.0)
    end
    listItem.labLose:setString(lostStr)

    -- 进度
    local str
    local isUnlock,unlockLV = self:getUnLockLevel(id)
    if isUnlock == true then
        -- 已解锁
        listItem.imgLock:setVisible(false)
        NodeUtils:setEnableColor(listItem, true) -- 已经解锁显示
        local curCount
        if id == 4 then  --西域显示 进度：第X关
            curCount = 1
            local proxy = self:getProxy(GameProxys.LimitExp)
            local info = proxy:getExinfos()
            if info == nil then  --TODO 还没有西域的数据,应该请求60100
                proxy:onTriggerNet60100Req()
            else
                local config = ConfigDataManager:getConfigById("AdventureEventConfig", info.maxId)
                local remainTime = proxy:getMopRemainTime() or 0 
                
                -- logger:info("西域数据：id,maxId,remainTime = %d %d %d",info.id,info.maxId,remainTime)

                if remainTime > 0 and config ~= nil then
                    curCount = config.sort - math.floor(remainTime / 30)
                    if curCount <= 0 then
                        curCount = 1
                    end
                else
                    local curconfig = ConfigDataManager:getConfigById("AdventureEventConfig", info.id)
                    curCount = curconfig.sort
                end
            end

            curCount = string.format(self:getTextWord(627),curCount)
            str = {{{self:getTextWord(621), 22, "#f3ba85"},{curCount, 22, "#ffffff"}}}

        else --显示 次数：x/x
            curCount = 0
            local maxCount = data.time or 0
            local proxy = self:getProxy(GameProxys.Dungeon)
            local oneDungeonInfo = proxy:getDungeonById(id)
            if oneDungeonInfo then
                curCount = oneDungeonInfo.times or 0
            else
                oneDungeonInfo = proxy:getExploreInfoByID(id)
                if oneDungeonInfo then
                    curCount = oneDungeonInfo.count
                end
            end

            if curCount < 0 then
                curCount = 0
            end
            -- str = string.format(self:getTextWord(622),curCount,maxCount)
            str = {{{self:getTextWord(622), 22, "#f3ba85"},{curCount .. "/", 22, "#ffffff"},{maxCount, 22, "#ffffff"}}}
        end
        -- listItem.labVal:setString(str)
        -- listItem.labVal:setColor(ColorUtils.commonColor.c3bBiaoTi)
    else
        -- 未解锁
        -- listItem.labVal:setString(string.format(self:getTextWord(613),unlockLV))
        -- listItem.labVal:setColor(ColorUtils.commonColor.c3bRed)
        str = {{{string.format(self:getTextWord(613),unlockLV), 22, "#BF4949"}}}

        listItem.imgLock:setVisible(true)
        NodeUtils:setEnableColor(listItem, false)
    end

    local labVal = listItem.labVal
    if labVal.richLabel == nil then
        labVal:setString("")
        labVal.richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
        labVal:addChild(labVal.richLabel)
    end
    labVal.richLabel:setString(str)


    --宝箱位置
    local proxy = self:getProxy(GameProxys.Dungeon)
    local exInfo = proxy:getExploreInfoByID(id)
    local imgBoxPos = listItem.imgBoxPos
    if exInfo then
        if exInfo.haveBox == 1 then
            imgBoxPos:setVisible(true)
            if imgBoxPos.boxEffect == nil then
                local boxEffect = self:createUICCBLayer("rgb-zy-xiang",imgBoxPos )
                imgBoxPos.boxEffect = boxEffect
                self:pushBackToPool(boxEffect)
            end
        else
            imgBoxPos:setVisible(false)
            if imgBoxPos.boxEffect ~= nil then
                self:releaseEffect(imgBoxPos.boxEffect)
                imgBoxPos.boxEffect = nil
            end
        end
    else
        imgBoxPos:setVisible(false)
        if imgBoxPos.boxEffect ~= nil then
            self:releaseEffect(imgBoxPos.boxEffect)
            imgBoxPos.boxEffect = nil
        end
    end

    --进入关卡点击
    self:addTouchEventListener(listItem,self.onAsiaPanelTouch)
    
    --引导用途
    self["asiaPanel" .. id] = listItem
end

-- 获取副本当前解锁状态,以及解锁等级
function TravelPanel:getUnLockLevel(id)
    local config = ConfigDataManager:getConfigById(self.adventureConfig, id)
    local unlockLV = config.level

    local proxy = self:getProxy(GameProxys.Role)
    local level = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    if level < unlockLV then
        return false,unlockLV
    end
    return true,nil
end

-- 协议更新数据
function TravelPanel:updateInfoResp()
    self:onShowHandler()
end


function TravelPanel:pushBackToPool(effect)
    if effect then
        self.effectPool = self.effectPool or {}
        table.insert(self.effectPool,effect)
    end
end

function TravelPanel:releaseEffect(effect)
    if effect then
        self.effectPool = self.effectPool or {}
        for key,val in pairs(self.effectPool) do
            if val == effect then
                effect:finalize()
                table.remove(self.effectPool,key)
                break;
            end
        end
    end
end
function TravelPanel:releaseEffectPool()
    self.effectPool = self.effectPool or {}
    for key,val in pairs(self.effectPool) do
        val:finalize()
    end
    self.effectPool = {}
end