
CenterRegionPanel = class("CenterRegionPanel", BasicPanel)
CenterRegionPanel.NAME = "CenterRegionPanel"

function CenterRegionPanel:ctor(view, panelName)
    CenterRegionPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function CenterRegionPanel:finalize()
    self:releaseEffectPool()


    CenterRegionPanel.super.finalize(self)
end

function CenterRegionPanel:initPanel()
	CenterRegionPanel.super.initPanel(self)

    self._scrollView = self:getChildByName("scrollView")

end



function CenterRegionPanel:registerEvents()
    CenterRegionPanel.super.registerEvents(self)
end

function CenterRegionPanel:doLayout()

    local regionPanel = self:getPanel(RegionPanel.NAME)
    local bottomPanel = regionPanel:getBottomPanel()
    local tabPanel = self:getTabsPanel()

    local scrollView = self:getChildByName("scrollView")

    NodeUtils:adaptiveListView(self._scrollView , bottomPanel, tabPanel,GlobalConfig.topTabsHeight,GlobalConfig.downHeight)

    self:createScrollViewItemUIForDoLayout(self._scrollView)
end



function CenterRegionPanel:onShowHandler()
    local dungeonProxy = self:getProxy(GameProxys.Dungeon)
    local data = dungeonProxy:getDungeonListInfo()
    self:updateDungeonInfoList(data.dungeoInfos)
end





function CenterRegionPanel:hideAllMapInfoPanel()
    for _, panel in pairs(self._allTilePanels) do
        local infoPanel = panel:getChildByName("infoPanel")
        infoPanel:setVisible(false)
    end
end


-- 更新图块
function CenterRegionPanel:updateDungeonInfoList(dungeonInfoList)

    self._dungeonInfoList = dungeonInfoList

    self._curMaxIndex = self:getMaxKey(dungeonInfoList)--打到的最后的章节

    self._ChapterConf = ConfigDataManager:getConfigDataBySortKey(ConfigData.ChapterConfig,"ID")

    self:renderScrollView(self._scrollView , "pnlItem", self._ChapterConf, 
                        self, self.renderItemPanel,self._curMaxIndex,GlobalConfig.scrollViewRowSpace)
    --引导使用
    -- self["panel101"] = self._expandScrollViewMap[self._scrollView]:getIndexItem(1)
    -- self["panel102"] = self._expandScrollViewMap[self._scrollView]:getIndexItem(2)
    for i =1,24 do 
        local name = string.format("panel1%02d",i)
        self[name] = self._expandScrollViewMap[self._scrollView]:getIndexItem(i)
    end
end


function CenterRegionPanel:renderItemPanel(listItem, data, index)
    if not listItem._isInit then
        listItem._isInit = true
        NodeUtils:setNodeNameForKey(listItem,1)--获取所有子节点,放在listItem下面
    end

    --关卡
    local ID = data.ID
    local url = string.format("images/region/Txt%d.png",ID or 101)
    TextureManager:updateImageView(listItem.imgName,url)


    --底图
    local panelIcon = data.panelIcon
    local url = string.format("images/region/SpBg%d.png",panelIcon or 1)
    TextureManager:updateImageView(listItem.bg,url)

    --武将头像 imghead
    local heroID = data.heroID
    local url = string.format("bg/region/itemHead/%d.pvr.ccz",heroID or 10)
    TextureManager:updateImageViewFile(listItem.imghead,url)

    --描述
    local describe = data.describe
    local descLabel = listItem.labDesc
    if descLabel.richLabel == nil then
        descLabel:setString("")
        descLabel.richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
        descLabel:addChild(descLabel.richLabel)
    end

    --描述字
    if describe then
        descLabel.richLabel:setString(describe)
    end

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


    --星星数
    --是否通关
    local str = nil
    local labVal = listItem.labStarNum
    if labVal.richLabel == nil then
        labVal:setString("")
        labVal.richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
        labVal:addChild(labVal.richLabel)
    end

    listItem.imgPass:setVisible(false)
    local tmpDungeonInfo = nil --找到的话保存起来
    for index, dungeonInfo in pairs(self._dungeonInfoList) do
        if data.ID == dungeonInfo.id then
            
            -- listItem.labStarNum:setString(string.format("%d/%d",dungeonInfo.star,dungeonInfo.totalStar))
            str = {{{dungeonInfo.star .. "/", 22, "#ffffff"},{dungeonInfo.totalStar, 22, "#ffffff"}}}
            labVal.richLabel:setString(str)

            tmpDungeonInfo = dungeonInfo
            if dungeonInfo.star == dungeonInfo.totalStar then
                listItem.imgPass:setVisible(true)
            end
            break
        end
    end
    if not tmpDungeonInfo then
        -- listItem.labStarNum:setString(string.format("%d/%d",0,data.starNum))
        str = {{{0 .. "/", 22, "#ffffff"},{data.starNum, 22, "#ffffff"}}}
        labVal.richLabel:setString(str)
    end


    --宝箱位置
    local imgBoxPos = listItem.imgBoxPos
    if tmpDungeonInfo then
        if tmpDungeonInfo.haveBox == 1 then
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

    -- 匕首特效显示处理 
    local imgDaoEffect = listItem.imgDaoEffect
    if index == self._curMaxIndex then
        imgDaoEffect:setVisible(true)
        if imgDaoEffect.knifeEffect == nil then
            imgDaoEffect.knifeEffect = self:createUICCBLayer("rgb-ditu-pishou",imgDaoEffect )
            self:pushBackToPool(imgDaoEffect.knifeEffect)
        end
    else
        imgDaoEffect:setVisible(false)
        if imgDaoEffect.knifeEffect ~= nil then
            self:releaseEffect(imgDaoEffect.knifeEffect)
            imgDaoEffect.knifeEffect = nil
        end
    end

    --是否开放
    if data.sort <= self._curMaxIndex then--开放
        listItem.imgLock:setVisible(false)
        NodeUtils:setEnableColor(listItem, true)
    else
        listItem.imgLock:setVisible(true)
        NodeUtils:setEnableColor(listItem, false)
    end

    listItem.chapter = data.ID
    --进入关卡点击
    self:addTouchEventListener(listItem,self.onMapTouch)
end

function CenterRegionPanel:pushBackToPool(effect)
    if effect then
        self.effectPool = self.effectPool or {}
        table.insert(self.effectPool,effect)
    end
end

function CenterRegionPanel:releaseEffect(effect)
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
function CenterRegionPanel:releaseEffectPool()
    self.effectPool = self.effectPool or {}
    for key,val in pairs(self.effectPool) do
        val:finalize()
    end
    self.effectPool = {}
end


-- 获取当前最新进度，用于显示匕首特效
function CenterRegionPanel:getMaxKey(listTable)
    return #listTable
end

--跳转到地图
function CenterRegionPanel:onMapTouch(sender)
    if not self._isPlayTouchAcion then
        self._isPlayTouchAcion = true
        self:touchAction(sender, self.onMapTouchCallback)

        local chapter = sender.chapter
        local info = ConfigDataManager:getConfigById(ConfigData.ChapterConfig, chapter)

        local roleProxy = self:getProxy(GameProxys.Role)
        local lv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_militaryRank)
        --TODO 这里还要判断关卡是否开启
        local dungeonProxy = self:getProxy(GameProxys.Dungeon)
        local isOpen = dungeonProxy:isDungeonOpen(chapter)
        if lv < info.rankneed or isOpen == false then
            return "close"
        end
    else
        return
    end
end


function CenterRegionPanel:onMapTouchCallback(sender)
    local chapter = sender.chapter

    self._isPlayTouchAcion = false

    local info = ConfigDataManager:getConfigById(ConfigData.ChapterConfig, chapter)

    local dungeonProxy = self:getProxy(GameProxys.Dungeon)
    local isOpen = dungeonProxy:isDungeonOpen(chapter)
    if isOpen == false then
        self:showMessageBox(self:getTextWord(350006))
        NodeUtils:setEnableColor(sender, false)
        return
    end

    local roleProxy = self:getProxy(GameProxys.Role)
    local lv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_militaryRank)
    if lv < info.rankneed then
        local function okFun()
            self:dispatchEvent(RegionEvent.SHOW_OTHER_EVENT,{name = ModuleName.PersonInfoModule})
        end
        self:showMessageBox(self:getTextWord(610) .. info.rankneedname .. self:getTextWord(611), okFun)
        return
    end

    self:dispatchEvent(RegionEvent.SHOW_OTHER_EVENT,{name = ModuleName.DungeonModule,id = chapter,type = 1,info = info})

end

-- 按钮动画
function CenterRegionPanel:touchAction(sender, callback)
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
