
BattlePanel = class("BattlePanel", BasicPanel)
BattlePanel.NAME = "BattlePanel"

function BattlePanel:ctor(view, panelName)
    BattlePanel.super.ctor(self, view, panelName)
    self._watchNameStr = "显示武将"
    self._watchNumStr = "显示兵数"
    self._watchSpreedStr = "正常"
    self._watchSpreedDoubleStr = "X2"
    self._headIcon = nil

    self:setUseNewPanelBg(true)
end

function BattlePanel:finalize()
    BattlePanel.super.finalize(self)
end

function BattlePanel:initPanel()
    BattlePanel.super.initPanel(self)

    local mapPanel = self:getChildByName("mapPanel")
    self:onInitMapPanel(mapPanel)

    self._maxHpMap = { }
    self._curHpMap = { }
    
    local roundTxt = self:getChildByName("headPanel/roundTxt")
    roundTxt:setLocalZOrder(1000)

    -- local effPanel = self:getChildByName("effPanl")
    -- effPanel:setVisible(true)
    -- effPanel:setTouchEnabled(false)
    -- for k,v in pairs(effPanel:getChildren()) do
    --     v:setVisible(false)
    -- end

    --    for index=1, 2 do
    --        local hpBar = self:getChildByName("headPanel/hpBar" .. index)
    --        self["hpBar" .. index] = ComponentUtils:addProgressbar(hpBar)
    --    end
    local frontPanel = self:getChildByName("bgPanel/frontPanel")
    frontPanel:setVisible(false)
    local backPanel = self:getChildByName("bgPanel/backPanel")
    backPanel:setVisible(false)


end



function BattlePanel:onRestPanel()
    self:onInitMapPanel()

    self:setNameByCamp("", 1)
    self:setNameByCamp("", 2)

end

function BattlePanel:setCurBattle(battle)
    self._battle = battle
end

function BattlePanel:stopAllActions()
    local frontPanel = self:getChildByName("bgPanel/frontPanel")
    frontPanel:stopAllActions()
    local backPanel = self:getChildByName("bgPanel/backPanel")
    backPanel:stopAllActions()
end

function BattlePanel:moveFrontBg(callback, complete)
    local frontPanel = self:getChildByName("bgPanel/frontPanel")

    frontPanel:setPosition(0, 0)

    local moveAction1 = cc.MoveTo:create(2, cc.p(-460, 0))
    local moveAction2 = cc.MoveTo:create(1, cc.p(-690, 0))

    --    local moveAction = cc.MoveTo:create(3, cc.p(-690,0))

    local action = cc.Sequence:create(moveAction1,
    cc.CallFunc:create(callback), moveAction2, cc.CallFunc:create(complete))

    frontPanel:runAction(action)

    local backPanel = self:getChildByName("bgPanel/backPanel")
    local bgImgMoveAction = cc.MoveTo:create(3, cc.p(-300, 660))
    backPanel:runAction(bgImgMoveAction)

end

function BattlePanel:onUpdateMap(id)
    local bgType = ".webp"
    -- TextureManager.bg_type
    local bgurl = string.format("bg/battle/%d/bg" .. bgType, id)

    local bgImg = self:getChildByName("bgPanel/bgImg")
    TextureManager:updateImageViewFile(bgImg, bgurl)
    local bgSize = bgImg:getContentSize()
    if bgImg.isAdptive == nil then
        NodeUtils:adaptiveXCenter(bgImg, cc.size(bgSize.width, bgSize.height))
        bgImg.isAdptive = true
    end



    --    local bgImg = self:getChildByName("bgPanel/backPanel/bgImg")
    --    local frontImg1 = self:getChildByName("bgPanel/frontPanel/frontImg1")
    --    local frontImg2 = self:getChildByName("bgPanel/frontPanel/frontImg2")

    --    local bgurl = string.format("bg/battle/%d/bg.jpg", id)
    --    local fronturl = string.format("bg/battle/%d/front.png", id)

    --    local bgWidth, bgHeight = TextureManager:updateImageViewFile(bgImg, bgurl)
    --    local width1, height1 = TextureManager:updateImageViewFile(frontImg1, fronturl)
    --    local width2, height2 = TextureManager:updateImageViewFile(frontImg2, fronturl)

    --    frontImg1:setPosition(width1 / 2, height1 / 2)
    --    frontImg2:setPosition(width1 - 3 + width2 / 2, height2 / 2 )

    --    bgImg:setPosition(bgWidth / 2, bgHeight / 2)

    --    local frontPanel = self:getChildByName("bgPanel/frontPanel")
    --    frontPanel:setPosition(0, 0)

    --    local backPanel = self:getChildByName("bgPanel/backPanel")
    --    backPanel:setPosition(0, 660)
end

function BattlePanel:onUpdateRound(round)
    local roundTxt = self:getChildByName("headPanel/roundTxt")
    roundTxt:setString(round)
end

function BattlePanel:setNameByCamp(name, camp)
    local nameTxt = self:getChildByName("headPanel/nameTxt" .. camp)
    nameTxt:setString(name)
end

-- 显示先手值
function BattlePanel:setFirstByCamp(name, camp)
    local firstTxt = self:getChildByName("headPanel/first" .. camp)
    firstTxt:setString(name)
end

--
function BattlePanel:setMaxHpByCamp(maxHp, camp)
    self._maxHpMap[camp] = maxHp
    self._curHpMap[camp] = maxHp

    self:setHpByCamp(maxHp, camp)
    self:setRedHpByCamp(maxHp, camp)
end

--
function BattlePanel:cutHpByCamp(cutHp, camp)
    local curHp = self._curHpMap[camp] - cutHp
    self._curHpMap[camp] = curHp
    self:setHpByCamp(curHp, camp)
    self:setRedHpByCamp(curHp, camp)
end

function BattlePanel:setHpByCamp(hp, camp)
    local hpTxt = self:getChildByName("headPanel/hpTxt" .. camp)
    hpTxt:setString(hp)

    local hpBar = self:getChildByName("headPanel/hpBar" .. camp)
    local maxHp = self._maxHpMap[camp]
    local rate = hp / maxHp * 100
    if rate < 0 then
        rate = 0
    end

    hpBar:setPercent(rate)

end

-- -- 红色血条
-- 红色血条坐标不对时，是因为UI动画坐标不一致
function BattlePanel:setRedHpByCamp(hp, camp)
    -- logger:info("红色血条滚动动画.....A.--- %d", camp)
    local maxHp = self._maxHpMap[camp]
    local rate = hp / maxHp * 100
    if rate < 0 then
        rate = 0
    end

    if self[camp] == nil then
        local delay = 1.5
        -- 红色进度条滚动时长
        local progressBar = self:getChildByName("headPanel/hpBar" .. camp .. "_red")
        local path = "images/battle/bar_red.png"
        --1:为蓝方阵营（自己）；2：为红方阵营
        local campBlue = 1
        local campRed = 2
        if campBlue == camp then
            path = "images/battle/bar_blue.png"
        end
        progressBar = ComponentUtils:addProgressbar(progressBar, path, delay)
        self[camp] = progressBar
    else
        self[camp].setPercent(self, rate)
    end

end


function BattlePanel:setWarBook(battle)

    local uiData = { }
    for camp = 1, 2 do
        local panelWarBook = self:getChildByName("headPanel/panelWarBook" .. camp)
        panelWarBook:setVisible(false)
        uiData[camp] = {
            isShowFirstAtkUI = true,
            rootUI = panelWarBook
        }
    end

    local warBookFightL = rawget(battle, "warBookFightL")
    if warBookFightL then
        self:updateWarBook(warBookFightL, uiData[1], UIWarBookFight.DirType_Left)
    end

    -- 右边国策显示
    local cfgData = ConfigDataManager:getInfoFindByOneKey(ConfigData.FightControlConfig, "fighttype", battle.type)
    if cfgData.formationShow then
        local warBookFightR = rawget(battle, "warBookFightR")
        if warBookFightR then
            self:updateWarBook(warBookFightR, uiData[2], UIWarBookFight.DirType_Right)
        end
    end
    

end

function BattlePanel:updateWarBook(warBookFightData, uiData, dirType)
    local updateData = {}
    local sequenceCfgData = ConfigDataManager:getConfigById( ConfigData.WarBookSequence, warBookFightData.talentActivateId)
    if sequenceCfgData then
        updateData.sequenceIcon = sequenceCfgData.firstIcon
    end 
    
    local warBookFightCfgData = ConfigDataManager:getConfigById(ConfigData.WarBookFightConfig, warBookFightData.warBookFightId)
    if warBookFightCfgData then        
        updateData.warBookFightCfgData = warBookFightCfgData
        updateData.skillLevel = { warBookFightData.skillLevel1, warBookFightData.skillLevel2 };
    end
    local uiWarBookFight = UIWarBookFight.new(self, uiData, dirType)
    uiWarBookFight:updateUI(updateData)
end


function BattlePanel:onInitMapPanel()

    local mapPanel = self:getChildByName("mapPanel")
    local initBloodPanel = mapPanel:getChildByName("bloodPanel")
    for index=11, 16 do
        local indexPanel = mapPanel:getChildByName("indexPanel" .. index)
        local x, y = indexPanel:getPosition()
        if indexPanel.srcPos == nil then
            indexPanel.srcPos = cc.p(x,y)
            local scale = self:getScaleByY(y)
            indexPanel:setScale(scale)
            
--            indexPanel:setScaleX(-1 * scale)
        end
        indexPanel:setLocalZOrder(960 - indexPanel:getPositionY())
        local infoPanel = indexPanel:getChildByName("infoPanel")
        infoPanel:setVisible(false)
        indexPanel:setVisible(false)


        local bloodPanel = initBloodPanel:clone()
        bloodPanel:setName("bloodPanel"..index)
        bloodPanel:setScale(indexPanel:getScale())
        bloodPanel:setPosition(indexPanel:getPosition())
        bloodPanel:setLocalZOrder(indexPanel:getLocalZOrder()+2000)
        bloodPanel:setVisible(false)
        mapPanel:addChild(bloodPanel)

    end

    for index=21, 26 do
        local indexPanel = mapPanel:getChildByName("indexPanel" .. index)
        local x, y = indexPanel:getPosition()
        if indexPanel.srcPos == nil then
            indexPanel.srcPos = cc.p(x,y)
            local scale = self:getScaleByY(y)
            indexPanel:setScale(scale)
        end
        indexPanel:setLocalZOrder(960 - indexPanel:getPositionY())
        local infoPanel = indexPanel:getChildByName("infoPanel")
        infoPanel:setVisible(false)
        indexPanel:setVisible(false)

        local bloodPanel = initBloodPanel:clone()
        bloodPanel:setName("bloodPanel"..index)
        bloodPanel:setScale(indexPanel:getScale())
        bloodPanel:setPosition(indexPanel:getPosition())
        bloodPanel:setLocalZOrder(indexPanel:getLocalZOrder()+2000)
        bloodPanel:setVisible(false)
        mapPanel:addChild(bloodPanel)

    end
    


    local function initMapByIndex(index,order)
        -- body
        order = order or 960
        local indexPanel = mapPanel:getChildByName("indexPanel" .. index)
        local x, y = indexPanel:getPosition()
        if indexPanel.srcPos == nil then
            indexPanel.srcPos = cc.p(x,y)
            local scale = self:getScaleByY(y)
            indexPanel:setScale(scale)
        end
        indexPanel:setLocalZOrder(order - indexPanel:getPositionY())
        local infoPanel = indexPanel:getChildByName("infoPanel")
        if infoPanel ~= nil then
            infoPanel:setVisible(false)
        end
        indexPanel:setVisible(false) 
    end

    -- -- 初始化军师 隐藏
    initMapByIndex(19,1280)  --index=19 玩家军师
    initMapByIndex(29,1280)  --index=29 敌方军师


    -- -- 初始受击特效坑位 隐藏
    -- local beHurtMapTab = {
    --     'A1','B1','C1','D1','E1','F1',
    --     'A2','B2','C2','D2','E2','F2',
    --     'G1','H1','I1','J1','K1','L1',
    --     'G2','H2','I2','J2','K2','L2'
    -- }
    -- for _,index in pairs(InitHurtMapTab) do
        -- initMapByIndex(index,1280)
    -- end

end

function BattlePanel:getScaleByY(y)
    return 1 - y * 0.0006 + 0.2
end

function BattlePanel:showSkipBtn()
    local operateBtnBg = self:getChildByName("downPanel/imgOperateBtnBg")
    operateBtnBg:setVisible(true)

    local skipBtn = self:getChildByName("downPanel/skipBtn")
    skipBtn:setVisible(true)
    
    local accelerateBtn = self:getChildByName("downPanel/accelerateBtn")
    accelerateBtn:setVisible(true)
    
    local headPanel = self:getChildByName("headPanel")
    headPanel:setVisible(true)

    local watchNameBtn = self:getChildByName("downPanel/watchNameBtn")
    watchNameBtn:setVisible(true)

    watchNameBtn.visible = nil
    --local watchNameImg = watchNameBtn:getChildByName("watchNameImg")
    --local watchNumImg = watchNameBtn:getChildByName("watchNumImg")
    --watchNameImg:setVisible(true)
    --watchNumImg:setVisible(false)

    local watchNameOrNum = watchNameBtn:getChildByName("labNameOrNum")
    watchNameOrNum:setString(self._watchNameStr)
end

function BattlePanel:hideSkipBtn()
    local operateBtnBg = self:getChildByName("downPanel/imgOperateBtnBg")
    operateBtnBg:setVisible(false)

    local skipBtn = self:getChildByName("downPanel/skipBtn")
    skipBtn:setVisible(false)
    
    local accelerateBtn = self:getChildByName("downPanel/accelerateBtn")
    accelerateBtn:setVisible(false)
    
    local headPanel = self:getChildByName("headPanel")
    headPanel:setVisible(false)

    local watchNameBtn = self:getChildByName("downPanel/watchNameBtn")
    watchNameBtn:setVisible(false)
end

function BattlePanel:registerEvents()
    local skipBtn = self:getChildByName("downPanel/skipBtn")
    self:addTouchEventListener(skipBtn, self.onSkipBtnTouch)

    self._accelerateBtn = self:getChildByName("downPanel/accelerateBtn")
    self:addTouchEventListener(self._accelerateBtn, self.onAccelerateBtnTouch)

    --local Image_x = self._accelerateBtn:getChildByName("Image_x")
    --local Image_normal = self._accelerateBtn:getChildByName("Image_normal")
    --Image_x:setVisible(false)
    --Image_normal:setVisible(true)
    local labSpeed = self._accelerateBtn:getChildByName("labSpeed")
    labSpeed:setString(self._watchSpreedStr)

    local watchNameBtn = self:getChildByName("downPanel/watchNameBtn")
    self:addTouchEventListener(watchNameBtn, self.onWatchNameBtnTouch)

end

--跳过战斗
function BattlePanel:onSkipBtnTouch(sender)
    self._battle:onSkipBattle()
end


-- start 加速按钮---------------------------------------------------------------------
function BattlePanel:showAccelerateBtn()
    -- local accelerateBtn = self:getChildByName("downPanel/accelerateBtn")
    self._accelerateBtn:setVisible(true)

end

function BattlePanel:hideAccelerateBtn()
    -- local accelerateBtn = self:getChildByName("downPanel/accelerateBtn")
    self._accelerateBtn:setVisible(false)

end

--查看名字
function BattlePanel:onWatchNameBtnTouch(sender)

    local visible = sender.visible or false
    sender.visible = not visible

    --local watchNameImg = sender:getChildByName("watchNameImg")
    --local watchNumImg = sender:getChildByName("watchNumImg")
    --watchNameImg:setVisible(not sender.visible)
    --watchNumImg:setVisible( sender.visible)
    local watchNameOrNum = sender:getChildByName("labNameOrNum")
    if sender.visible then
    watchNameOrNum:setString(self._watchNumStr)
    else
    watchNameOrNum:setString(self._watchNameStr)
    end

    local function setHeroNameVisible(indexPanel, visible)
        local puppet = indexPanel.puppet
        if puppet ~= nil then
            puppet:setHeroNameVisible(visible)
        end
    end

    local mapPanel = self:getChildByName("mapPanel")
    for index=11, 16 do
        local indexPanel = mapPanel:getChildByName("indexPanel" .. index)
        setHeroNameVisible(indexPanel, sender.visible)
    end

    for index=21, 26 do
        local indexPanel = mapPanel:getChildByName("indexPanel" .. index)
        setHeroNameVisible(indexPanel, sender.visible)
    end

    -- -- 军师名字
    -- local consIndex = {19,29}
    -- for _,index in pairs(consIndex) do
    --     local indexPanel = mapPanel:getChildByName("indexPanel" .. index)
    --     setHeroNameVisible(indexPanel, sender.visible)
    -- end

end

--加速战斗
function BattlePanel:onAccelerateBtnTouch(sender)
    local labSpeed = self._accelerateBtn:getChildByName("labSpeed")

    --local Image_x = self._accelerateBtn:getChildByName("Image_x")
    ---- local Label_num = self._accelerateBtn:getChildByName("Label_num")
    --local Image_normal = self._accelerateBtn:getChildByName("Image_normal")

    local battleProxy = self:getProxy(GameProxys.Battle)
    local timeScale = cc.Director:getInstance():getScheduler():getTimeScale()
    if timeScale > 1 then
        -- 关闭加速
--        print("···-- 关闭加速")
        battleProxy:setAaccelerate(false)
        cc.Director:getInstance():getScheduler():setTimeScale(1)
        --Image_x:setVisible(true)
        -- Label_num:setVisible(true)
        --Image_normal:setVisible(false)
        labSpeed:setString(self._watchSpreedDoubleStr)
    else
        -- 开启加速
--        print("···-- 开启加速")
        battleProxy:setAaccelerate(true)
        cc.Director:getInstance():getScheduler():setTimeScale(2)
        --Image_x:setVisible(false)
        -- Label_num:setVisible(false)
        --Image_normal:setVisible(true)
        labSpeed:setString(self._watchSpreedStr)
    end

end


function BattlePanel:setHeadIconByCamp(headIcon, camp, playerId)
    local headImg = self:getChildByName("headPanel/headIconImg".. camp)

    if camp == 1 and headIcon == 0 then
        local roleProxy = self:getProxy(GameProxys.Role)
        headIcon = roleProxy:getHeadId()
    end

    local headInfo = {}
    headInfo.icon = headIcon
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = nil
    headInfo.isBattleHead = true
    headInfo.playerId = playerId
    

    if headImg.head == nil then
        headImg.head = UIHeadImg.new(headImg, headInfo, self)
        headImg.head:setScale(0.8)
        headImg.head:setHeadTransparency()
    else
        headImg.head:updateData(headInfo)
    end

    if camp == 2 and headIcon == 0 then
        if headImg.head then
            headImg.head:getNode():setVisible(false)
        end
    elseif camp == 2 and headIcon ~= 0 then
        if headImg.head then
            headImg.head:getNode():setVisible(true)
        end
    end
end






-- end ---------------------------------------------------------------------

