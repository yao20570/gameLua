
DungeonMapPanel = class("DungeonMapPanel", BasicPanel)
DungeonMapPanel.NAME = "DungeonMapPanel"

function DungeonMapPanel:ctor(view, panelName)
    DungeonMapPanel.super.ctor(self, view, panelName)
    -- self.eff={}

    self:setUseNewPanelBg(true)
end

function DungeonMapPanel:finalize()
    DungeonMapPanel.super.finalize(self)
    -- for _,v in pairs(self.eff) do
    --     if v~=nil then
    --         v:finalize()
    --     end
    -- end
    -- self.eff=nil
    if self._scrollView ~= nil then
        if self._scrollView.knifeLayer ~= nil then
            self._scrollView.knifeLayer:finalize()
            self._scrollView.knifeLayer = nil
        end
    end

    -- if
    self.boxeff1 = self:finll(self.boxeff1)
    self.boxeff2 = self:finll(self.boxeff2)
    self.boxeff3 = self:finll(self.boxeff3)
end

function DungeonMapPanel:finll(sender)
    if sender ~= nil then
        sender:finalize()
    end
    return nil
end

function DungeonMapPanel:initPanel()
    DungeonMapPanel.super.initPanel(self)
    -- 对应的12个据点坐标
    self._percent = {
        1,-- 1
        1,
        2,-- 3
        22,
        24,-- 5
        44,
        44,-- 7
        48,
        75,-- 9
        78,
        100,-- 11
        100
    }
    self.isCanJump = true
    -- true 可以滚屏，false 不可滚屏
    self._allCityInfo = { }
    for index = 1, 12 do
        self._allCityInfo[index] = { city = nil }
    end

    self._roleProxy = self:getProxy(GameProxys.Role)


    -- self._rewardPanel = self:getChildByName("Image_39")
    self._topPanel = self:getChildByName("TopPanel")
    self._totalCountTxt = self:getChildByName("TopPanel/Totalcount")
    self._scrollView = self:getChildByName("ScrollView_1")
    self._arrowPanel = self:getChildByName("ScrollView_1/arrowPanel")
    self._downPanel = self:getChildByName("DownPanel")

    local city
    local scrollView = self._scrollView
    for index = 1, 12 do
        city = scrollView:getChildByName("city" .. index)
        local heroIcon = city:getChildByName("heroIcon")
        heroIcon:setVisible(false)
        local targetIcon = city:getChildByName("targetIcon")
        targetIcon:setScale(GlobalConfig.dungeonTargetIconScale)
    end

    -- 背景图
    self:onUpdateBgImg(nil)

    -- 匕首攻击特效
    self:createKnifeEffect()


end

function DungeonMapPanel:createKnifeEffect()
    -- 匕首攻击特效
    self._cirCle = self._scrollView.knifeLayer
    if self._cirCle == nil then
        local knifeLayer = self:createUICCBLayer("rgb-fight-knife", self._scrollView)
        knifeLayer:setPosition(self._arrowPanel:getPosition())
        knifeLayer:setLocalZOrder(1000)
        self._scrollView.knifeLayer = knifeLayer
        self._cirCle = self._scrollView.knifeLayer
    else
        self._cirCle:setVisible(true)
    end
end

function DungeonMapPanel:registerEvents()


    self._arrowPanel:setVisible(false)
    self._scrollView:setBounceEnabled(false)

    local scale = NodeUtils:getAdaptiveScale()
    if scale > 1 then
        -- 自适应的滚动范围优化
        local s = self._scrollView:getInnerContainerSize()
        s.width = s.width + 60 * scale
        self._scrollView:setInnerContainerSize(s)
    end

    local buyTsBtn = self._topPanel:getChildByName("buyTsBtn")
    self:addTouchEventListener(buyTsBtn, self.onBuyTsHandle)
    self._buyBtn = buyTsBtn

    local exitBtn = self._topPanel:getChildByName("exitBtn")
    exitBtn:setTouchEnabled(true)
    self:addTouchEventListener(exitBtn, self.onExitBtnTouch)

    local realexitBtn = self._topPanel:getChildByName("realexitBtn")
    -- realexitBtn:setTouchEnabled(true)
    self:addTouchEventListener(realexitBtn, self.onRealExitBtnTouch)

    -- 新手引导用的
    self["exitBtn"] = exitBtn

    self.BtnPos = { }
    for index = 1, 3 do
        local box = self._downPanel:getChildByName("box" .. index)
        self.BtnPos[index] = { }
        self.BtnPos[index].x = box:getPositionX()
        self.BtnPos[index].y = box:getPositionY()
        box.index = index
        self:addTouchEventListener(box:getChildByName("btn"), self.onGetRewardTouch)
        self["boxBtn" .. index] = box:getChildByName("btn")
    end


    local function scrollViewEvent(sender, evenType)
        self:scrollViewEvent()
    end
    self._scrollView:addEventListener(scrollViewEvent)
end

function DungeonMapPanel:scrollViewEvent()
    -- if self._minScrollOffset == nil then
    --     return
    -- end
    -- local container = self._scrollView:getInnerContainer()
    -- local x , y = container:getPosition()
    -- print("=======scrollViewEvent===========",x, y, self._minScrollOffset)
    -- if x < self._minScrollOffset then
    --     --self._scrollView:jumpToPercentHorizontal(self._maxScrollPercent)
    -- end
end

function DungeonMapPanel:onBuyTsHandle(sender)
    if sender.ls then
        local roleProxy = self:getProxy(GameProxys.Role)
        roleProxy:getBuyEnergyBox(self)
    else
        self._buyBtn = sender

        self:dispatchEvent(DungeonEvent.BUYTIMES_REQ,1)
    end
end

function DungeonMapPanel:isShowRechargeUI(sender,dungeoId)
    local needMoney = sender.money
    local roleProxy = self:getProxy(GameProxys.Role)
    local haveGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝

    if needMoney > haveGold then
        local parent = self:getParent()
        local panel = parent.panel
        if panel == nil then
            local panel = UIRecharge.new(parent, self)
            parent.panel = panel
        else
            panel:show()
        end
    else
        sender.callFunc()
    end

end
function DungeonMapPanel:onRealExitBtnTouch(sender)
    for _,v in pairs(self._allCityInfo) do
        if v.city ~= nil then
            v.city:setVisible(false)
        end
    end
    for i =1,3 do
        local boxes = self._downPanel:getChildByName("box"..i)
        boxes:setVisible(false)
    end
   self.isCanJump = true
   self:dispatchEvent(DungeonEvent.CLOSE_ALL_EVENT)
   -- GameBaseState:resetInitState()
end
function DungeonMapPanel:onExitBtnTouch(sender)
    for _,v in pairs(self._allCityInfo) do
        if v.city ~= nil then
            v.city:setVisible(false)
        end
    end
    for i =1,3 do
        local boxes = self._downPanel:getChildByName("box"..i)
        boxes:setVisible(false)
    end
    self.isCanJump = true
    self:dispatchEvent(DungeonEvent.HIDE_SELF_EVENT) -- 隐藏
end

-- 点击宝箱弹窗
function DungeonMapPanel:onGetRewardTouch(sender)
    sender=sender:getParent()
    -- print("onGetRewardTouch 0000000000000000000")
    sender.dungeoId = self._dungeoId
    local panel = self:getPanel(DungeonRewardPanel.NAME)
    if sender.count ~= nil then
        panel:show(sender)
    else
        logger:info("无数据中断") -- 这边要调用等执行了onDungeonInfoResp(）才赋值
    end
end


function DungeonMapPanel:onUpdateBgImg(info)
    -- new bg
--    self:addBgImg( self._scrollView )
end

function DungeonMapPanel:addBgImg( parent )
    -- body
--    local bgImgTab = {1, 2}
--    local bgPath = "bg/dungeon/dungeon_bg%d%s"
--    local bg_pic
--    for k,v in pairs(bgImgTab) do
--        bg_pic = TextureManager:createImageViewFile(string.format(bgPath, v, TextureManager.bg_type)) 
--        bg_pic:setAnchorPoint(cc.p(0.0, 0.0))

--        if k == 1 then
--            bg_pic:setPosition(0,0)
--        else
--            local size = bg_pic:getContentSize()
--            bg_pic:setPosition(size.width,0)
--        end

--        parent:addChild(bg_pic)
--    end
end

--由外部更新背景图
function DungeonMapPanel:updateBgImg(bgIcon)
    if self._curBgIcon == bgIcon then
         return
    end
    self._curBgIcon = bgIcon
    local bg_type = ".jpg" --TextureManager.bg_type
    local bgImgTab = {1, 2}
    for _, tab in pairs(bgImgTab) do
        local url = string.format("bg/dungeon/%d/dungeon_bg%d%s", bgIcon, tab, bg_type)
        local bg_pic = self._scrollView["bgImgTab" .. tab]
        if bg_pic == nil then
            bg_pic = TextureManager:createImageViewFile(url) 
            bg_pic:setAnchorPoint(cc.p(0.0, 0.0))
        
            if tab == 1 then
                bg_pic:setPosition(0,0)
            else
                local size = bg_pic:getContentSize()
                bg_pic:setPosition(size.width,0)
            end
            self._scrollView:addChild(bg_pic)
        else
            TextureManager:updateImageViewFile(bg_pic, url)
        end
    end
end


function DungeonMapPanel:onDungeonInfoFlush()
    -- print("== 00 关闭布阵界面 刷新副本 ==")
    if self._copyGuideState == true or (self._copyData ~= nil and self._copyType ~= nil) then
            -- print("== 11 关闭布阵界面 刷新副本 ==")
        self:onDungeonInfoResp(self._copyData,self._copyType,self._copyExterInfo)
        self._copyData = nil
        self._copyType = nil
        self._copyExterInfo = nil
        self._copyGuideState = false
    end
end

function DungeonMapPanel:onDungeonInfoResp(data, type, exterInfo)
    if data == nil then
        logger:error("==副本刷新的数据有误: data is nil !==")
        return
    elseif type == nil then
        logger:error("==副本刷新的数据有误: type is nil !==")
        return
    end

    self._copyData = data
    self._copyType = type
    self._copyExterInfo = exterInfo
    self._copyGuideState = GuideManager:isStartGuide()


    self._papapa = nil
    local size = table.size(data.eventInfo)
    -- local percent
    -- percent = self._percent[size]
    self._maxScrollPercent = size
    self._dungeoId = data.dungeoId

    local title = self._topPanel:getChildByName("title")
    local buyTsBtn = self._topPanel:getChildByName("buyTsBtn")
    local title_name = self._topPanel:getChildByName("title_name")

    local config = nil
    local info = nil
    local forxy = self:getProxy(GameProxys.Dungeon)
    if type == 1 then
        -- 关卡
        self._config = "EventConfig"
        info = ConfigDataManager:getInfoFindByOneKey("ChapterConfig", "ID", data.dungeoId)
        buyTsBtn:setVisible(true)
        buyTsBtn.ls = 1
        -- title_name:setString("体力")
        title_name:setString(self:getTextWord(200103))
    elseif type == 2 then
        -- 历险
        self._config = "AdventureEventConfig"
        info = ConfigDataManager:getInfoFindByOneKey("AdventureConfig", "ID", data.dungeoId)
        buyTsBtn.ls = nil
        buyTsBtn:setVisible(true)
        -- title_name:setString("次数")
        title_name:setString(self:getTextWord(200104))
    end
    self._indexDungeon = forxy:getWhichPosByType(type, data.dungeoId)
    self._info = info
    title:setString(info.name)


    local index = 1
    local city
    self._lastIndex = size
    self._cirCle:setVisible(false)
    local currID = 1
    -- local lastId

    for _, v in pairs(data.eventInfo) do
        city = self._allCityInfo[index].city
        local info = ConfigDataManager:getInfoFindByOneKey(self._config, "ID", v.id)
        self._lastID = info.chapter
        currID = info.ID

        -- print("服务端数据 v.id,info.ID,info.chapter",v.id,info.ID,info.chapter)

        if city == nil then
            city = self._scrollView:getChildByName("city" .. index)
            self._allCityInfo[index].city = city
        end

        city.data = v
        city.index = index
        if index == 1 then
            --            self["city" .. city.index] = city
        end
        index = index + 1
        -- print(index, self._papapa, self.isCanJump, table.size(data.eventInfo))
        if self._papapa == nil then
            self:registerItemEvents(city, info, data, true)

            if self.isCanJump then
                if index - 1 == table.size(data.eventInfo) then
                    -- print("移动到最新关卡位置....................")
                    self:jumpToPercentHorizontal(size)
                    -- self._scrollView:jumpToPercentHorizontal(self._maxScrollPercent)
                end
            end

        else
            self._lastFunInfo = { city = city, info = info, data = data, isPass = true }
        end
    end


    self:hideOtherCity(index)
    self:updateDownPanel(data, type)
    self:onCloudMoveHandle()
end

--跳转到某个比例
function DungeonMapPanel:jumpToPercentHorizontal(index)
    local percent = self._percent[index]
    self._scrollView:jumpToPercentHorizontal(percent)
    -- print(".......................................--跳转到某个比例 ",index,percent,percent)
end

function DungeonMapPanel:setCanJump(bool)
    self.isCanJump = bool
end


function DungeonMapPanel:registerItemEvents(city, info, importantData, isPass)
    if city == nil or city.index > 12 then
        return
    end
    city:setVisible(true)


    -- print("关卡 city.index,info.icon =",city.index,info.icon)


    local data = city.data

    -- local targetIcon = city:getChildByName("targetIcon")
    -- if targetIcon.icon ~= info.icon then
    --     targetIcon.icon = info.icon
    --     -- local url = string.format("images/dungeon/%d.png", info.icon)
    --     -- TextureManager:updateImageView(targetIcon,url)
    --     local url = string.format("images/dungeonIcon/Icon_%d.png", info.sort)
    --     targetIcon.url = url
    -- end

    -- 关卡名字
    local name = city:getChildByName("name")
    -- local str
    -- if self._config == "EventConfig" then --中原战役
    --     str = info.name
    -- else
    --     str = self._indexDungeon.."-"..city.index.." "..info.name
    -- end
    name:setString(info.name)
    local isLock = false

    local xingPanel = city:getChildByName("xingPanel")
    local dataStar = 0
    if isPass == true or isPass == 2 then
        -- 已解锁
        city.data._info = info
        self:showStarByCount(xingPanel, data.star)
        dataStar = data.star

        self:onPlayEffect(city)

    else
        isLock = true
        -- 未解锁
        dataStar = 0
        self:showStarByCount(xingPanel, 0)
        self:createEffect(city)

    end


    -- 关卡提示箭头
    if isPass == true then
        self["city" .. city.index] = city
        if dataStar <= 0 then
            self:getChildByName("TopPanel/num"):setString((city.index - 1) .. "/12")
            self._cirCle:setVisible(false)
            local posX, posY = city:getPosition()
            local contentSize = city:getContentSize()
            local x = posX + contentSize.width / 2 - self._arrowPanel:getContentSize().width - 25
            local y = posY + contentSize.height / 2 - self._arrowPanel:getContentSize().height + 70
            -- 82
            self._arrowPanel:setPosition(x, y)
            self._cirCle:setPosition(x + 60, y - contentSize.height / 6 + 10)
            self._lastId = data.id


            if GuideManager:isStartGuide() ~= true then
                self._cirCle:setVisible(true)
            end

        else
            if city.index == 12 then
                self:getChildByName("TopPanel/num"):setString("12/12")
            end
            if data.id == self._lastId then
                -- 星星改变了
                self._papapa = true
                local star1 = xingPanel:getChildByName("Mxing" .. 1)
                local star2 = xingPanel:getChildByName("Mxing" .. 2)
                local star3 = xingPanel:getChildByName("Mxing" .. 3)

                star1.oldVisible = star1:isVisible()
                star2.oldVisible = star2:isVisible()
                star3.oldVisible = star3:isVisible()

                -- 直接做延迟，看下效果
                star1:setVisible(false)
                star2:setVisible(false)
                star3:setVisible(false)

                -- --TODO 先写死处理
                -- if GuideManager:isStartGuide() == true and
                --     data.id ~= 9 and data.id ~= 7 then
                --     local function delayRunStarAction(self, star1,star2,star3)
                --         self:runStarAction(star1,star2,star3)
                --     end
                --     TimerManager:addOnce(GameConfig.guideParams.DELAY_FLY_TIME,delayRunStarAction, self, star1,star2,star3)
                -- else
                --     self:runStarAction(star1,star2,star3)
                -- end

                local function handler()
                    self:runStarAction(star1, star2, star3)
                end

                local isStartGuide = GuideManager:isStartGuide()
                if isStartGuide then
                    -- 新手引导才会加入队列
                    self._isPlayEffect = true
                    EffectQueueManager:addEffect(EffectQueueType.DUNGEON_STAR, handler)
                else
                    handler()
                end


                self._lastId = nil
            end
        end
        city.importantData = importantData
        self:addItemTouchEvent(city)
    end

    -- 关卡名字的图标
    local nameIcon = city:getChildByName("nameIcon")
    if info.icon == 1 or info.icon == 2 then
        nameIcon:setVisible(true)
        local url = string.format("images/newGui1/Icon_dungeon%d.png", info.icon)
        -- images/newGui1/Icon_dungeon1.png
        TextureManager:updateImageView(nameIcon, url)
    else
        nameIcon:setVisible(false)
    end

    -- 关卡武将奖励的图标
    local heroPanel = city:getChildByName("heroIcon")
    if heroPanel.srcPos == nil then
        heroPanel.srcPos = cc.p(heroPanel:getPosition())
    end
    heroPanel:stopAllActions()
    heroPanel:setLocalZOrder(100)

    
    
       
    -- 获取掉落字符串
    local dropStr = nil 
    if dataStar == 0 then
        -- 未通关
        dropStr = rawget(info, "firstDropID") or rawget(info, "regularDropID")        
    else
        -- 已通关,
        dropStr = rawget(info, "regularDropID")        
    end

    -- 解析掉落数据
    local dropData = nil
    if dropStr ~= nil and dropStr ~= "[]" then  
        dropData = StringUtils:jsonDecode(dropStr)            
    end

    if dropData == nil then   
        -- 隐藏特别掉落d     
        heroPanel:setVisible(false)
        heroPanel:stopAllActions()
    else
        -- 显示特别掉落d
        heroPanel:setVisible(true)
        
        -- 首次掉落数据
        local data = {}
        data.power = dropData[1]
        data.typeid = dropData[2]
        data.num = dropData[3]
        
        if heroPanel.heroIcon == nil then
            local icon = heroPanel:getChildByName("icon")
            heroPanel.heroIcon = UIIcon.new(icon, data, false, self)
            heroPanel.heroIcon:setScale(0.5)
        else
            heroPanel.heroIcon:updateData(data)
        end

        local color = ColorUtils:getColorByQuality(heroPanel.heroIcon:getQuality())
        local txtName = heroPanel:getChildByName("txtName")
        txtName:setString(heroPanel.heroIcon:getName())
        txtName:setColor(color)
        print("---------------------color"..color.r.."  "..color.g.." "..color.b)
--        local moveTime = 1
--        local action1 = cc.MoveTo:create(moveTime, cc.p(heroPanel.srcPos.x, heroPanel.srcPos.y + 7))
--        local action3 = cc.MoveTo:create(moveTime, cc.p(heroPanel.srcPos.x, heroPanel.srcPos.y - 7))
--        local sequence = cc.Sequence:create(action1, action3)
--        local action = cc.RepeatForever:create(sequence)
--        heroPanel:stopAllActions()
--        heroPanel:runAction(action)
    end


    city:setTouchEnabled(isPass)
end

-- 战争迷雾 创建
function DungeonMapPanel:createEffect( target )
    -- body
    local ccbLayer = target.ccbLayer
    if ccbLayer == nil then
        local effectPanel = target:getChildByName("effectPanel")
        ccbLayer = self:createUICCBLayer("rgb-zhanzheng-miwu",effectPanel ,nil, nil, true)
        ccbLayer:setLocalZOrder(100)
        -- ccbLayer:setPosition(56,50)  --统一坐标偏移
        target.ccbLayer = ccbLayer
        ccbLayer:pause()
    end
end

-- 战争迷雾 播放
function DungeonMapPanel:onPlayEffect( target, isPlay )
    -- body
    local ccbLayer = target.ccbLayer
    if ccbLayer then
        ccbLayer:resume()
        target.ccbLayer = nil
    end
end

-- 战争迷雾 关闭界面时移除全部
function DungeonMapPanel:removeAllEffect( data )
    -- body
    for k,target in pairs(data) do
        local ccbLayer = target.ccbLayer
        if ccbLayer then
            ccbLayer:finalize()
        end
    end
end

function DungeonMapPanel:hideCallBack()
    -- body
    -- self:removeAllEffect( self._allCityInfo )
end


function DungeonMapPanel:addItemTouchEvent(item)
    if item.isAdd == true then
        return
    end
    item.isAdd = true
    self:addTouchEventListener(item,self.onCallItemTouch, nil, obj, nil, nil, true)
--    if GuideManager:isStartGuide() then
--        self:addTouchEventListener(item,self.onCallItemTouch)
--    else
--        self:addTouchEventListener(item, self.onBuildTouch)
--    end
end

------
-- 战役建筑点击闪烁
function DungeonMapPanel:onBuildTouch(sender)
    self:touchAction(sender, self.onCallItemTouch)
end

function DungeonMapPanel:touchAction(sender, callback)
    local bgFlickerAction = cc.TintTo:create(0.1, GlobalConfig.hitBuildColor[1],GlobalConfig.hitBuildColor[2],GlobalConfig.hitBuildColor[3])
    local bgFlickerAction2 = cc.TintTo:create(0.1, 255,255,255)
    local action = cc.Sequence:create(bgFlickerAction, bgFlickerAction2)
    sender:runAction(action)
    TimerManager:addOnce(0.22 * 1000, callback, self, sender)
end



--播放攻城的特效，播放完毕后，执行战斗请求
function DungeonMapPanel:playFightAnimation(callback)
    local proxy = self:getProxy(GameProxys.Dungeon)
    local cityId = proxy:getCurrCityType()

    local function complete()
        -- self:setMask(false)
        callback()
    end

    self:setMask(true)
    
    local sort = self._sort
    local bgIcon = self._info.bgicon
    local city = self:getCityByIndex(sort)
    -- print("特效 sort,bgIcon",sort,bgIcon)

    if city.data.star > 0  then  --星星大于0，直接跳过动画
        complete()
        return
    end

    -- local config = ConfigDataManager:getInfoFindByTwoKey("DungeonAttackConfig","dungeonID",bgIcon,"cityID",sort)
    local config = ConfigDataManager:getInfoFindByOneKey("DungeonAttackConfig","cityID",sort)
    local name = config.name[1] or "rgb-guanka-youshang"
    local x =  config.name[2] or 0
    local y =  config.name[3] or 0
    local dir = config.name[4] or 1
    -- local ccb = UICCBLayer.new(name, city, nil, complete, true)
    local ccb = self:createUICCBLayer(name, city, nil, nil, true)
    ccb:setPosition(x, y)
    ccb:setLocalZOrder(999)
    
    if dir >= 0 then
        dir = 1
    else
        dir = -1
    end
    -- dir = -1
    --设置方向 1正 -1反
    --TODO如果有缩放，还需要乘以缩放比例
    ccb:setDir(dir)

    TimerManager:addOnce(1600,complete,self)  --延时请求战斗

end

function DungeonMapPanel:onCallItemTouch(sender, callArg)
    -- 当前关卡有星星，则战斗结束不滚屏
    if rawget(sender.data,"star") then
        self.isCanJump = false
    else
        self.isCanJump = true
    end

    self._sort = sender.data._info.sort
    local proxy = self:getProxy(GameProxys.Dungeon)
    proxy:setCurrCityType(sender.data.id)        

    local panel
    if self:isShowCityUI(sender.data.id) == true then
        panel = self:getPanel(DungeonCityInfoPanel.NAME)
    else
        local teamDetail = self:getProxy(GameProxys.TeamDetail)
        teamDetail:setEnterTeamDetailType(1)
        panel = self:getPanel(DungeonCityPanel.NAME)
    end
    panel:show(sender.data)


    if callArg == nil then
    else
        local proxy = self:getProxy(GameProxys.Soldier)
        proxy:setMaxFighAndWeight()  --设置最大战力
        --调用最大战力
        panel:setMaxFightTeam()

    end
end

function DungeonMapPanel:isShowCityUI(cityId)
    self._dungeonProxy = self:getProxy(GameProxys.Dungeon)
    local type ,dunId = self._dungeonProxy:getCurrType()
    local isShowCityUI = true
    local cityInfo
    if type == 1 then      --中原战役
        cityInfo = ConfigDataManager:getInfoFindByOneKey("EventConfig","ID",cityId)
        if cityInfo.showwinds == 0 then
            isShowCityUI = false
        end
    end

    return isShowCityUI
end


function DungeonMapPanel:getCityByIndex(index)
    return self._allCityInfo[index].city
end

function DungeonMapPanel:onHideCitys(index)
    for i = 1,index do
        if self._allCityInfo[i].city ~= nil then
            self._allCityInfo[i].city:setVisible(false)
        end
    end
end

function DungeonMapPanel:showStarByCount(panel,count)
    local _index = 0
    for i = 1,count do
        local star = panel:getChildByName("Mxing"..i)
        star:setVisible(true)
    end
    
    for i = count + 1 ,3 do
        local star = panel:getChildByName("Mxing"..i)
        star:setVisible(false)
    end
    
end

function DungeonMapPanel:updateEnergyData()
    local title_name = self._topPanel:getChildByName("title_name")
    if title_name:getString() == self:getTextWord(200103) then
        local energy = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_energy)
        if not self.curPrice then
            self.curPrice = self._roleProxy:getEnergyNeedMoney() + 5
        end

        self._totalCountTxt:setString(energy)
        self.challengeTimes = energy
        local proxy = self:getProxy(GameProxys.Dungeon)
        proxy:setCurrentTimes(energy)
    end
end

function DungeonMapPanel:updateEnergy(energy)
    self._totalCountTxt:setString(energy)
end

function DungeonMapPanel:updateDownPanel(data,type)
    local Image_55 = self._downPanel:getChildByName("Image_55")
    local count = Image_55:getChildByName("count")
    count:setString(data.star)
    self._star = data.star
    local tili = self._topPanel:getChildByName("tili")
    self.curType = type
    if type == 1 then--战役
        local energy = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_energy)
        self.haveEnergy = energy
        self._totalCountTxt:setString(energy)
        tili:setString("20") 
        self.challengeTimes = energy
        local proxy = self:getProxy(GameProxys.Dungeon)
        proxy:setCurrentTimes(energy)
    else
        self._totalCountTxt:setString(data.times)
        tili:setString(data.timesTotal)
        self.challengeTimes = data.times
        local proxy = self:getProxy(GameProxys.Dungeon)
        proxy:setCurrentTimes(data.times)
    end
    -- local DownPanel = self:getChildByName("DownPanel")
    local numEn = {"One","Two","Three"}
    local maxBox = 1
    for index = 1,3 do
        local box = self._downPanel:getChildByName("box"..index)
        local count = box:getChildByName("count")
        if self._info["star"..numEn[index]] > 0 then
            local rewardId = self._info["rewardId"..index]
            count:setString("x"..self._info["star"..numEn[index]])
            rewardId = StringUtils:jsonDecode(rewardId)
            -- box.config = ConfigDataManager:getRewardConfigById(rewardId[1])
            box.rewardId = rewardId
            box.count = self._info["star"..numEn[index]]
            box:setVisible(true) 
        else
            box.count = 0
            box:setVisible(false) 
        end
        if box.count >= maxBox then
            maxBox = box.count
        end
    end
    self._maxBox = maxBox
    self:setBoxesStatus(data.boxes,maxBox)
end

function DungeonMapPanel:setBoxesStatus(boxes,maxBox)  --1,未开启，2已领取 3，未领取
    -- local DownPanel = self:getChildByName("DownPanel")
    local url
    for index = 1, 3 do
        local box = self._downPanel:getChildByName("box"..index)
        box:setPosition(cc.p(self.BtnPos[index].x, self.BtnPos[index].y))
        if self._star >= box.count and box.count > 0 then
            box.status = 2 -- 2 已领取
            url = "images/newGui1/Icon_chest1.png" -- 开
            box:getChildByName("btn"):setOpacity(255)
            if box.eff ~= nil then
                box.eff:setVisible(false)
                box.eff:finalize()
                box.eff=nil
            end
        else
            box.status = 1
            url = "images/newGui1/Icon_chest3.png" -- 灰
        end

        TextureManager:updateButtonNormal(box:getChildByName("btn"),url)
    end

    local indexList = {}

    -- 全部按顺序
    for k, v in pairs(boxes) do
        indexList[v] = v
    end

    for i = 1, 3 do
        local info = indexList[i] --
        local box = self._downPanel:getChildByName("box"..i)
        if info == nil then
            -- 无数据
            if box.eff ~= nil then
                box.eff:setVisible(false)
            end
            box:getChildByName("btn"):setOpacity(255)
        else
            box.status = 3
            url = "images/newGui1/Icon_chest2.png" -- 合
            TextureManager:updateButtonNormal(box:getChildByName("btn"),url)
            -- 有数据
            box:getChildByName("btn"):setOpacity(0)

            if box.eff == nil then
                box.eff = self:createUICCBLayer("rgb-gk-xiang", box)
                self["boxeff"..i] = box.eff
            end

            if box.eff then
                box.eff:setVisible(true)
            end
        end
    end


    
    local Image_55 = self._downPanel:getChildByName("Image_55")
    local Label_50 = Image_55:getChildByName("Label_50")
    local ProgressBar = self._downPanel:getChildByName("ProgressBar")
    Label_50:setString("/"..self._maxBox)
    ProgressBar:setPercent(100*self._star/self._maxBox)
end

-- 隐藏未解锁城池，隐藏配表不存在城池
function DungeonMapPanel:hideOtherCity(sort) --
    local oneChapterInfos = ConfigDataManager:getInfosFilterByOneKey(self._config, "chapter", self._lastID)

    local city
    for k,info in pairs(oneChapterInfos) do
        city = self._scrollView:getChildByName("city"..info.sort)
        if city and info.sort >= sort then
            city.index = info.sort
            self:registerItemEvents(city,info,data,false)
        end
    end

end

function DungeonMapPanel:onBuyTimes(type,index)
    --local targetIcon = self:getChildByName("DownPanel/targetIcon")

    --local Image_56 = targetIcon:getChildByName("Image_56")
    --local count = targetIcon:getChildByName("count")
    -- local buyTsBtn = targetIcon:getChildByName("buyTsBtn")
    -- local status1 = true
    -- local status2 = false
    -- if type == 2 then
    --     if index ~= 3 then
    --         status1 = false
    --         status2 = true
    --     end
    -- end
    --Image_56:setVisible(status1)
    --count:setVisible(status1)
    -- buyTsBtn:setVisible(status2)
end

-- 购买次数返回、是否弹框元宝不足
function DungeonMapPanel:onBuyTimesResp(data)
    -- print("购买次数成功 DungeonMapPanel onBuyTimesResp")
    -- print_r(data)

    -- rs=2 元宝不足
    if data.rs ~= 0 and data.rs ~= 2 then
        return 
    end

    local panel = self:getPanel(DungeonCityPanel.NAME)
    if panel:isVisible() == true then
        return
    end

    local sender = self._buyBtn
    local function callbk()
        function callreq1()
            local function callFunc()
                self:dispatchEvent(DungeonEvent.BUYTIMES_REQ, 2)
            end
            sender.callFunc = callFunc
            sender.money = data.money
            self:isShowRechargeUI(sender,data.dungeoId)
        end

        if data.dungeoId ~= 4 then
            self:showMessageBox(self:getTextWord(200105)..data.money..self:getTextWord(200106),callreq1)
        end
    end

    if data.type == 1 then
        -- 点击购买
        callbk()
    else
        -- 购买成功
        local forxy = self:getProxy(GameProxys.Dungeon)
        local oneDungeonInfo = forxy:getDungeonById(data.dungeoId)
        oneDungeonInfo.times = data.advanceTimes
        self._totalCountTxt:setString(data.advanceTimes)
        self.challengeTimes = data.advanceTimes
        forxy:setCurrentTimes(data.advanceTimes)

        self:showSysMessage(self:getTextWord(541))
    end
end

function DungeonMapPanel:onResetData(data)
    if self.curType == 2 then
        self._totalCountTxt:setString(data)
        self.challengeTimes = data
    end
end

function DungeonMapPanel:onFirstPassResp()
    local function okFun()
        -- self:dispatchEvent(DungeonEvent.SHOW_OTHER_EVENT,ModuleName.InstanceModule)
        self:dispatchEvent(DungeonEvent.SHOW_OTHER_EVENT, ModuleName.RegionModule)
        self.isCanJump = true
        EffectQueueManager:completeEffect()
    end

    local function noFun()
        EffectQueueManager:completeEffect()
	end

    local function openMessageBox()
        self:showMessageBox(self:getTextWord(200107), okFun, noFun)
    end
    EffectQueueManager:addEffect(EffectQueueType.MessageBox, openMessageBox)

end

-- function DungeonMapPanel:onGetRewardBoxStatus()
--     self._rewardPanel:setVisible(false)
--     NodeUtils:setEnable(self._getRewardBtn,false)
--     local already = self._getRewardBtn:getChildByName("already")
--     local get = self._getRewardBtn:getChildByName("get")
--     already:setVisible(true)
--     get:setVisible(false)
-- end

function DungeonMapPanel:runStarAction(star1, star2, star3)

    star1:setVisible(star1.oldVisible)
    star2:setVisible(star2.oldVisible)
    star3:setVisible(star3.oldVisible)

    
    
    

    star1:setOpacity(0)
    star2:setOpacity(0)
    star3:setOpacity(0)
    
    -- star1:setScale(3)
    -- star2:setScale(3)
    -- star3:setScale(3)
    
    local frame = 0.05
    local actionFade3 = cc.FadeTo:create(frame, 255)
    -- local actionScale5 = cc.ScaleTo:create(0.4, 0.5)
    local action = --[[cc.Sequence:create(]]actionFade3--,actionScale5)
    local function addjump(star)
            local sp1=cc.Sprite:createWithSpriteFrameName("images/newGui1/IconStar.png")
            -- createWithSpriteFrameName
            sp1:setScale(0.5)
            -- self:getChildByName("ScrollView_1"):get
            local x=star:getPositionX()/0.9+star:getParent():getPositionX()+star:getParent():getParent():getPositionX()+star:getParent():getParent():getParent():getPositionX()
            local y=star:getPositionY()/0.9+star:getParent():getPositionY()+star:getParent():getParent():getPositionY()+star:getParent():getParent():getParent():getPositionY()
            -- print("----------------------------------------------")
            -- print(x.."-----"..y)
            -- print(""..)
            -- print("----------------------------------------------")
            sp1:setPosition(cc.p(x*1.1,y*1.1))
            self:getChildByName("DownPanel"):addChild(sp1)
            -- TextureManager:createSprite(url)
            -- sp1:setPosition(cc.p(star:getPositionX(),star:getPositionX()))
            local ac1=cc.JumpBy:create(0.5, cc.p(25*7,-15*7), 15*7, 1)
            if y<300 then
                ac1=cc.JumpBy:create(0.5, cc.p(-25*5,15*5), 15*5, 1)
            end
            local ac2=cc.MoveTo:create(0.5,cc.p(11,11))
            local function count(sender)
            -- local p1=sender:getParent()
            --     p1:removeChild(sender)
            --     p1:getParent():getParent():getParent():addChild(sender)
            --     local act=cc.MoveTo:create(0.5,cc.p(0,0))
            --     sender:runAction(act)rgb-gk-xing
            -- sender:setVisible
            
            self:createUICCBLayer("rgb-gk-xing", self:getChildByName("DownPanel/Image_47"),nil,nil,true):setPosition(38,38)
            sender:setVisible(false)
            -- sender:finalize()
            end
            local cb3=cc.CallFunc:create(count)
            sp1:setOpacity(0)
            -- local function myjudge(sender)--判断移动方向
            --     -- print("----------------------------------------------------------------------"..y)
                
            -- end
            -- local func=cc.CallFunc:create(myjudge)
            local maction=cc.Sequence:create(cc.DelayTime:create(0.2),cc.FadeIn:create(0.2),ac1,ac2,cb3)
            sp1:runAction(maction)
    end
 
    local function playEffectCallback1()
        if star1.oldVisible then
            
                addjump(star1)
            
            self:createUICCBLayer("rgb-gk-xingdrop", star1,nil,nil,true):setPosition(33,33)
            AudioManager:playEffect("yx_PutStar")
            
        end
    end
    local function playEffectCallback2()
        if star2.oldVisible then
            -- local function mcallback2()
                addjump(star2)
            -- end
            self:createUICCBLayer("rgb-gk-xingdrop", star2,nil,nil,true):setPosition(33,33)
            AudioManager:playEffect("yx_PutStar")
            -- addjump(star2)
        end
    end
    local function playEffectCallback3()
        if star3.oldVisible then
            -- local function mcallback3()
                addjump(star3)
            -- end
            self:createUICCBLayer("rgb-gk-xingdrop", star3,nil,nil,true):setPosition(33,33)
            AudioManager:playEffect("yx_PutStar")
            -- addjump(star3)
        end
    end

    local function callBk()
        if self._lastFunInfo ~= nil then
            self["city" .. self._lastFunInfo.city.index] = self._lastFunInfo.city
            self:registerItemEvents(self._lastFunInfo.city,self._lastFunInfo.info,self._lastFunInfo.data,true)
            -- self._scrollView:jumpToPercentHorizontal(self._maxScrollPercent)
            self:jumpToPercentHorizontal(self._maxScrollPercent)

            if self._isPlayEffect == true then
                --标记 副本星星动画结束了
                EffectQueueManager:completeEffect() 
                self._isPlayEffect = false
            end
        end
        self._papapa = nil
    end
         
    local action1 = cc.Sequence:create(cc.DelayTime:create(frame * 10), cc.CallFunc:create(playEffectCallback1), action:clone())
    local action2 = cc.Sequence:create(cc.DelayTime:create(frame * 13), cc.CallFunc:create(playEffectCallback2), action:clone())
    local action3 = cc.Sequence:create(cc.DelayTime:create(frame * 16), cc.CallFunc:create(playEffectCallback3), action:clone(),cc.DelayTime:create(0.8),cc.CallFunc:create(callBk))
             
    star1:runAction(action1)
    star2:runAction(action2)
    star3:runAction(action3)
end

function DungeonMapPanel:getChallengeTimes()
    return self.challengeTimes or 0
end

function DungeonMapPanel:onCloudMoveHandle()
    -- for index = 1,4 do
    --     local yun_pic = self._scrollView:getChildByName("yun_pic"..index)
    --     yun_pic:stopAllActions()
    --     local function chooseCallBack()
    --         local posX = yun_pic:getPositionX()
    --         local ramdom = math.random(-180,180)
    --         if posX >= (1390) then
    --             yun_pic:setPositionX(yun_pic:getContentSize().width / 2 + ramdom)
    --         end
    --     end
    --     local fun = cc.CallFunc:create(chooseCallBack)
    --     local moveBy = cc.MoveBy:create(1.0,cc.p(10, 0))
    --     local spwan = cc.Spawn:create(moveBy,fun)
    --     local action = cc.RepeatForever:create(spwan)
    --     yun_pic:runAction(action)
    -- end
end

function DungeonMapPanel:onGetNewGift()
    self._cirCle:setVisible(true)
end


-- --start 图片变灰----------------------------------------------------------------------------
-- --start 图片变灰----------------------------------------------------------------------------
-- --TODO 只对sprite有效，对图片sprite无效,并且变灰的sprite的X锚点是反的.
-- function DungeonMapPanel:showGreyView(node) 
--     print("调用了图片变灰···DungeonMapPanel:showGreyView(node)")

--     local vertDefaultSource = "\n"..
--                            "attribute vec4 a_position; \n" ..
--                            "attribute vec2 a_texCoord; \n" ..
--                            "attribute vec4 a_color; \n"..                                                    
--                            "#ifdef GL_ES  \n"..
--                            "varying lowp vec4 v_fragmentColor;\n"..
--                            "varying mediump vec2 v_texCoord;\n"..
--                            "#else                      \n" ..
--                            "varying vec4 v_fragmentColor; \n" ..
--                            "varying vec2 v_texCoord;  \n"..
--                            "#endif    \n"..
--                            "void main() \n"..
--                            "{\n" ..
--                             "gl_Position = CC_PMatrix * a_position; \n"..
--                            "v_fragmentColor = a_color;\n"..
--                            "v_texCoord = a_texCoord;\n"..
--                            "}"
 
--     --变灰
--     local psGrayShader = "#ifdef GL_ES \n" ..
--                             "precision mediump float; \n" ..
--                             "#endif \n" ..
--                             "varying vec4 v_fragmentColor; \n" ..
--                             "varying vec2 v_texCoord; \n" ..
--                             "void main(void) \n" ..
--                             "{ \n" ..
--                             "vec4 c = texture2D(CC_Texture0, v_texCoord); \n" ..
--                             "gl_FragColor.xyz = vec3(0.299*c.r + 0.587*c.g +0.114*c.b); \n"..
--                             "gl_FragColor.w = c.w; \n"..
--                             "}" 


--     local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,psGrayShader)
    
--     pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
--     pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
--     pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
--     pProgram:link()
--     pProgram:use()
--     pProgram:updateUniforms()
--     node:setGLProgram(pProgram)
-- end
-- --end 图片变灰----------------------------------------------------------------------------

