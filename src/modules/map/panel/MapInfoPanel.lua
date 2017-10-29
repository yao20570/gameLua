MapInfoPanel = class("MapInfoPanel", BasicPanel)
MapInfoPanel.NAME = "MapInfoPanel"

function MapInfoPanel:ctor(view, panelName)
    MapInfoPanel.super.ctor(self, view, panelName)
    self._view=view
    
    self:setUseNewPanelBg(true)
end

function MapInfoPanel:finalize()
    if self._uiBuyPanel ~= nil then
        self._uiBuyPanel:finalize()
        self._uiBuyPanel = nil
    end

    local parent = self:getParent()
    if parent.panel ~= nil then
        parent.panel:finalize()
        parent.panel = nil
    end
    MapInfoPanel.super.finalize(self)
end

function MapInfoPanel:initPanel()
    self._needTxtRotation = true -- 需要转180
    MapInfoPanel.super.initPanel(self)
    self:setTouchEnabled(false)
    self:setLocalZOrder(10)

    local mainPanel = self:getChildByName("mainPanel")
    mainPanel:setLocalZOrder(10)
    
    local rolePrxoy = self:getProxy(GameProxys.Role)
    self._cityWarProxy = self:getProxy(GameProxys.CityWar)
    self._emperorCityProxy = self:getProxy(GameProxys.EmperorCity)

    local tileX, tileY = rolePrxoy:getWorldTilePos()
    
    local xTxt = self:getChildByName("mainPanel/xTxt")
    local yTxt = self:getChildByName("mainPanel/yTxt")
        
    xTxt:setString(tileX)
    yTxt:setString(tileY)

    self._oldTileX = tileX
    
    local lenTxt = self:getChildByName("mainPanel/dirImg/lenTxt")
    lenTxt:setString("")
    local dirImg = self:getChildByName("mainPanel/dirImg")
    dirImg:setVisible(false)
    ComponentUtils:addTouchEventListener(dirImg, self.onPosBtnTouch,nil , self)
    
    local posBg = self:getChildByName("mainPanel/posBg")
    posBg:setVisible(false)
    
    self._curWayTime = os.clock()

    self:initResourcesInfo()

    self._crusadePanel = self:getChildByName("mainPanel/banditBtn/res6")

    self.banditPanel = self:getChildByName("mainPanel/Panel_2")
    --self.banditPanel:setVisible(false)
    for i=1,3 do
        self["nameBg"..i] = self:getChildByName("mainPanel/Panel_2/nameBg"..i)
    end

    local refreshBtn = self:getChildByName("mainPanel/refreshBtn")
    refreshBtn:setVisible(false)

    self._btnTownMsg = self:getChildByName("mainPanel/btnTownMsg")
    self._btnTownRank = self:getChildByName("mainPanel/btnTownRank")

    local posX = refreshBtn:getPositionX()
    self.leftX = 20 - posX
    self.rightX = refreshBtn:getChildByName("redImg"):getPositionX()
    refreshBtn.dir = 1
    self:addTouchEventListener(refreshBtn, self.refreshPanel)

    self:update()
end




-- 回调打开郡城排行界面
function MapInfoPanel:onOpenTownRankModule()
    local data = {}
    data.moduleName = ModuleName.TownRankModule
    self:dispatchEvent(MapEvent.SHOW_OTHER_EVENT, data)
end

--刷新郡城自己的红点
function MapInfoPanel:updateMyTownRedPoint()
    local redImg = self:getChildByName("mainPanel/btnTownMsg/redImg")
    local numLab = redImg:getChildByName("numLab")
    local num = self._cityWarProxy:getMyTownRedPoint()
    redImg:setVisible(num ~= 0)
    numLab:setString(num)
end


--更新显示坐标，在新建账号时，有可能会有-1，需要刷新一下
function MapInfoPanel:updatePos()

    if self._oldTileX ~= -1 then
        return
    end
    local rolePrxoy = self:getProxy(GameProxys.Role)
    local tileX, tileY = rolePrxoy:getWorldTilePos()
    local xTxt = self:getChildByName("mainPanel/xTxt")
    local yTxt = self:getChildByName("mainPanel/yTxt")

    xTxt:setString(tileX)
    yTxt:setString(tileY)

    self._oldTileX = tileX
end

--设置方向
function MapInfoPanel:setWayDir(tx, ty)

    local curTime = ClockUtils:getOsClock()
    if curTime - self._curWayTime <  0.1 then
        return
    end
    self._curWayTime = curTime
    

    local roleProxy = self:getProxy(GameProxys.Role)
    local wx, wy = roleProxy:getWorldTilePos()
    local wpos = MapDef.worldTileToScreen(wx, wy)
    local dir = cc.p(wpos.x - tx ,  wpos.y - ty)
    local angle = math.deg(cc.pToAngleSelf(dir))
    
    local dirImg = self:getChildByName("mainPanel/dirImg")
    dirImg:setRotation(-angle) -- 设置img的旋转角度
    local scale = NodeUtils:getAdaptiveScale()
    local winSize = cc.Director:getInstance():getVisibleSize()
--    local rect = cc.rect(50 * scale,160,winSize.width - 80 * scale,650)
    
    local rect = cc.rect(100 * scale - 50,160,winSize.width - 80,650)
    local x0, y0 = rect.x + rect.width / 2, rect.y + rect.height / 2
    
    local pos = nil
    local recty = rect.y
    if dir.y > 0 then
        recty = recty + rect.height
    end
    local x = x0 - dir.x / dir.y * (y0 - recty) 
    local isContains = cc.rectContainsPoint(rect, cc.p(x, rect.y))
    if isContains == true then
        pos = cc.p(x, recty)
    else
        local rectx = rect.x
        if dir.x > 0 then
            rectx = rectx + rect.width
        end
        local y = y0 - dir.y / dir.x * (x0 - rectx)
        isContains = cc.rectContainsPoint(rect, cc.p(rectx, y))
        if isContains == true then
            pos = cc.p(rectx, y)
        end
    end
    
    local mainPanel = self:getChildByName("mainPanel")
    if pos == nil then
        dirImg:setVisible(false)
    else
        local cpos = mainPanel:convertToNodeSpace(pos)
        --限制一下最小的x坐标
        cpos.x = cpos.x < 40 and 40 or cpos.x
        dirImg:setPosition(cpos.x, cpos.y)
        dirImg:setVisible(true)
    end
    
    local len = math.floor(cc.pGetLength(dir)) 
    local lenTxt = dirImg:getChildByName("lenTxt")
    
    if len > 500 then
        lenTxt:setString(string.format(self:getTextWord(316), len))
        dirImg:setVisible(true)
        lenTxt:setVisible(true)
    else
        dirImg:setVisible(false)
        lenTxt:setVisible(false)
    end

    -- 设置lentxt的动态旋转
    if -angle < 90 and -angle > -90 then
        if self._needTxtRotation == false then
            self._needTxtRotation = true
            lenTxt:setRotation(0)
        end
    else
        if self._needTxtRotation == true then
            self._needTxtRotation = false
            lenTxt:setRotation(180)
        end
    end
end

function MapInfoPanel:renderPosByType(type, num)
    local txt = self:getChildByName("mainPanel/" .. type .. "Txt")
    
    if num == "E" then
        local numBgPanel = self:getChildByName("mainPanel/numBgPanel")
        self:onNumPanelCloseTouch(numBgPanel)
        return
    end
    if num == "C" then
        num = ""
        txt.lastNum = num
    end
    
    local lastNum = txt.lastNum
    if lastNum == nil then
        lastNum = ""
        txt.lastNum = lastNum
    end
    
    
    if num ~= "" then
        local newNum = lastNum .. num
        num = tonumber(newNum)
        if num > 999 then
            num = lastNum
        end 
        txt.lastNum = num
        txt.cacheNum = num
    end
    
    txt:setString(num)
    
end

function MapInfoPanel:registerEvents()
    -- 前往按钮
    local btnGo = self:getChildByName("mainPanel/btnGo")
    self:addTouchEventListener(btnGo, self.onGoBtnTouch)

    -- 坐标输入
    local xTxtBgImg = self:getChildByName("mainPanel/xTxtBgImg")
    local yTxtBgImg = self:getChildByName("mainPanel/yTxtBgImg")
    xTxtBgImg.type = "x"
    yTxtBgImg.type = "y"
    self:addTouchEventListener(xTxtBgImg, self.onNumPanelOpenTouch)
    self:addTouchEventListener(yTxtBgImg, self.onNumPanelOpenTouch)

    local numBgPanel = self:getChildByName("mainPanel/numBgPanel")
    self:addTouchEventListener(numBgPanel, self.onNumPanelCloseTouch)
    self:registerNumInputEvents()

    -- 黄巾贼
    local banditBtn = self:getChildByName("mainPanel/banditBtn")
    self:addTouchEventListener(banditBtn, self.onBanditBtnTouch)

    -- 地图
    local btnMap = self:getChildByName("mainPanel/btnMap")
    btnMap:setPressedActionEnabled(true)
    self:addTouchEventListener(btnMap, self.onMapBtnTouch)

    -- 国战
    self._btnTownMsg:setPressedActionEnabled(true)
    self:addTouchEventListener(self._btnTownMsg, self.onTownMsgBtn)
    
    -- 国战排名
    self._btnTownRank:setPressedActionEnabled(true)
    self:addTouchEventListener(self._btnTownRank, self.onTownRankBtn)

    -- 玩法介绍
    local btnExp = self:getChildByName("mainPanel/btnExp")
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    btnExp:setPositionX(36)
    btnExp:setLocalZOrder(11)
    self:addTouchEventListener(btnExp, self.onExpBtnTouch)


    -- 按钮位置参照位置
    local tl = self:getModulePanel("ToolbarModule", ToolbarPanel.NAME)
    local qy = tl:getldPositionY() + 10

    -- 收藏
    local btnSocial = self:getChildByName("rightdown/btnSocial")
    btnSocial:setPositionY(qy + 80 * 2)
    self:addTouchEventListener(btnSocial, self.onSocialBtnTouch)

    -- 查找
    local btnSearch = self:getChildByName("rightdown/btnSearch")
    btnSearch:setPositionY(qy + 80)
    self:addTouchEventListener(btnSearch, self.onSearchBtnTouch)

    -- 定位
    local btnPos = self:getChildByName("rightdown/btnPos")
    btnPos:setPositionY(qy - 80)
    self:addTouchEventListener(btnPos, self.onPosBtnTouch)

    -- 皇城战显示
    self._emperorCityPanel = self:getChildByName("mainPanel/emperorCityPanel")

    self._remianTimeTxt = self._emperorCityPanel:getChildByName("remianTimeTxt")
    self._nameTxt = self._emperorCityPanel:getChildByName("nameTxt")
    self._stateImg = self._emperorCityPanel:getChildByName("stateImg")

    self._buyCommandPanel = self:getChildByName("mainPanel/buyCommandPanel") --优惠讨伐令入口

    self:addTouchEventListener(self._buyCommandPanel:getChildByName("buyCommandBtn"), self.onBuyCommand)
    
end

function MapInfoPanel:registerNumInputEvents()
    local numInputPanel = self:getChildByName("mainPanel/numBgPanel/numInputPanel")
    local children = numInputPanel:getChildren()
    for _, child in pairs(children) do
        if child:getName() ~= "Image_13" then
            self:addTouchEventListener(child, self.onNumBtnTouch)
        end
    end
end

function MapInfoPanel:onNumBtnTouch(sender)
    local name = sender:getName()
    print("========================", name)
    local num = string.gsub(name,"numBtn", "")
    self:renderPosByType(self._curSelectType, num)
end

function MapInfoPanel:onNumPanelOpenTouch(sender)
    local numBgPanel = self:getChildByName("mainPanel/numBgPanel")
    local numInputPanel = self:getChildByName("mainPanel/numBgPanel/numInputPanel")
    numBgPanel:setVisible(true)
    
    local type = sender.type
    if type == "x" then
        numInputPanel:setPositionX(152)
    else
        numInputPanel:setPositionX(318)
    end
    
    numBgPanel.renderTxt = self:getChildByName("mainPanel/" .. type .. "Txt")
    
    self._curSelectType = type
end

function MapInfoPanel:onNumPanelCloseTouch(sender)
    local numBgPanel = self:getChildByName("mainPanel/numBgPanel")
    numBgPanel:setVisible(false)
    
    local txt = sender.renderTxt
    if txt:getString() == "" then
        txt:setString(txt.cacheNum)
    end
    
    txt.lastNum = nil
    txt.cacheNum = nil
end

--前往到自己的坐标
function MapInfoPanel:onPosBtnTouch(sender)
    local rolePrxoy = self:getProxy(GameProxys.Role)
    local tileX, tileY = rolePrxoy:getWorldTilePos()
    
    local mapPanel = self:getPanel(MapPanel.NAME)
    mapPanel:gotoTileXY(tileX, tileY)
end

function MapInfoPanel:onGoBtnTouch(sender)
    local xTxt = self:getChildByName("mainPanel/xTxt")
    local yTxt = self:getChildByName("mainPanel/yTxt")
    
    local tileX = tonumber(xTxt:getString())
    local tileY = tonumber(yTxt:getString())
    
    local mapPanel = self:getPanel(MapPanel.NAME)
    mapPanel:gotoTileXY(tileX, tileY)
end

function MapInfoPanel:onSocialBtnTouch(sender)
    local data = {}
    data.moduleName = ModuleName.FriendModule
    data.extraMsg = {}
    data.extraMsg.panel = "CollectionPanel"
    self:dispatchEvent(MapEvent.SHOW_OTHER_EVENT, data)
end

function MapInfoPanel:onSearchBtnTouch(sender)
    local panel = self:getPanel(MapSearchPanel.NAME)
    panel:show()
end

function MapInfoPanel:onMapBtnTouch(sender)
    local panel = self:getPanel(MiniMapPanel.NAME)
    local isVisible = panel:isVisible()
    if isVisible then
        panel:hide()
    else
        panel:show()
    end
    
end

function MapInfoPanel:onTownRankBtn(sender)
    local data = {}
    local cityWarProxy = self:getProxy(GameProxys.CityWar)
    cityWarProxy:onTriggerNet470005Req(data)
end


function MapInfoPanel:onTownMsgBtn(sender)
    
    local panel = self:getPanel(MapMyTownPanel.NAME)
    panel:show()
--    self._cityWarProxy = self:getProxy(GameProxys.CityWar)

--    local fightBuffListConfig = {}
--    fightBuffListConfig[1] = 3
--    fightBuffListConfig[2] = 4

--    -- 
--    local fightBuff = {}
--    fightBuff[1] = 4

--    local buffStringList = self._cityWarProxy:getFightBuffStringList2(fightBuffListConfig)

--    local uiShow = UIShowFightBuff.new(self)
--    uiShow:setView(buffStringList , fightBuff)
end


-----------------------------------------------------------------------------
-- 资源UI
-----------------------------------------------------------------------------
-- 初始化资源UI
function MapInfoPanel:initResourcesInfo()
    -- 资源UI
    self._resPanels = {}
    local resPanel = self:getChildByName("mainPanel/resPanel")
    for i=1,5 do
        -- print("资源初始化···updateResUI---1")
        local resP = resPanel:getChildByName("res"..i)
        local number = resP:getChildByName("number")
        local barBG = resP:getChildByName("barBG")
        local icon = resP:getChildByName("icon")
        local bar = barBG:getChildByName("bar")

        resP.number = number
        resP.bar = bar
        self._resPanels[i] = resP

        local url = "images/newGui1/IconRes".. i ..".png"
        TextureManager:updateImageView(icon,url)
    end

    --资源按钮
    self._resBtn = resPanel:getChildByName("resBtn")
    self:addTouchEventListener(self._resBtn,self.onTouchedResource)
end

-- roleProxy更新
function MapInfoPanel:onRoleInfoUpdateResp()
    -- body
    local roleProxy = self:getProxy(GameProxys.Role)

    local level = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    local btnExp = self:getChildByName("mainPanel/btnExp")
    --btnExp:setVisible(level < 30)

    self._info,self._powerDef = roleProxy:getResDataAndConf()

    self:updateResUI(self._info)  --TODO 全体刷新效率
end

function MapInfoPanel:updateResUI(info)
    -- print("资源渲染···updateResUI---0")
    -- 资源UI
    local indexCur = nil
    for i=1,5 do
        -- print("资源渲染···updateResUI---1")
        indexCur = self._powerDef[i].cur
        local indexMax = self._powerDef[i].max
        self._resPanels[i].number:setString(StringUtils:formatNumberByK3(info[indexCur], indexCur)) 
        local cur = tonumber(info[indexCur])
        local max = tonumber(info[indexMax])
        local color = cur >= max and ColorUtils:color16ToC3b("#FCDA7E") or cc.c3b(255,255,255)
        self._resPanels[i].number:setColor(color)
        
        self._resPanels[i].bar:setPercent(info[indexCur..i])
    end

    self:updatCrusadeEnergy()
end

-- 资源按钮
function MapInfoPanel:onTouchedResource(sender)
    -- print("···-- 资源按钮")
    ModuleJumpManager:jump(ModuleName.WarehouseModule, nil)
end

--更新讨伐令
function MapInfoPanel:updatCrusadeEnergy()
    local roleProxy = self:getProxy(GameProxys.Role)
    local crusadeEnergy = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_crusadeEnergy)

    local crusadePanel = self._crusadePanel
    local curNumber = crusadePanel:getChildByName("curNumber")
    local maxNumber = crusadePanel:getChildByName("maxNumber")
    local barBG = crusadePanel:getChildByName("barBG")
    local bar = barBG:getChildByName("bar")

    local max = GlobalConfig.maxCrusadeEnergy
    curNumber:setString(crusadeEnergy)
    maxNumber:setString("/" .. max)  
    if crusadeEnergy > 0 then
        curNumber:setColor(ColorUtils.wordGreenColor)
    else
        curNumber:setColor(ColorUtils.wordRedColor)
    end
    if crusadeEnergy > max then
        crusadeEnergy = max
    end
    bar:setPercent(crusadeEnergy / max * 100)
end

function MapInfoPanel:onBanditBtnTouch(sender, value , dir)
    if self._uiBuyPanel == nil then
        self._uiBuyPanel = UIBuyEnergy.new(self)
    else
        self._uiBuyPanel:show()
    end
    -- local roleProxy = self:getProxy(GameProxys.Role)
    -- roleProxy:getBuyCrusadeEnergyBox(self)
    -- sender:stopAllActions()
    -- sender:runAction(cc.ScaleTo:create(0.1,1))
end


-- 是否弹窗元宝不足
function MapInfoPanel:isShowRechargeUI(sender)
    -- body
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

function MapInfoPanel:update()
    local proxy = self:getProxy(GameProxys.BanditDungeon)
    local allData = proxy:getAllBandData()
    local index = 1
    local coldDown = 0
    for k,v in pairs(allData) do
        if index <= 3 then
            self["nameBg"..index]:setVisible(true)
            local levelLab = self["nameBg"..index]:getChildByName("levelLab")
            local config = ConfigDataManager:getConfigById(ConfigData.PanditMonsterConfig, v.eventId)
            if config == nil then
                logger:error("这个%d无法读表",v.eventId)
            else
                levelLab:setString("Lv."..config.lv)
                levelLab:setColor(cc.c3b(235,206,130))
                local infoLab = self["nameBg"..index]:getChildByName("infoLab")
                local time = proxy:getRemainRestTime(v.id)
                local infoStr = config.name
                local color = cc.c3b(131,98,67)
                if time > 0 then
                    coldDown = coldDown + 1
                    color = cc.c3b(255,0,0)
                    infoStr = TimeUtils:getStandardFormatTimeString4(time)
                    --print("一直在刷新时间"..infoStr)
                    levelLab:setVisible(false)
                    infoLab:setPositionX(69)
                else
                    infoLab:setPositionX(88)
                    levelLab:setVisible(true)
                end
                infoLab:setString(infoStr)
                infoLab:setColor(color)
                
            end
            
        end
        index = index + 1
    end

    for i=index,3 do
        self["nameBg"..i]:setVisible(false)
    end

    local refreshBtn = self:getChildByName("mainPanel/refreshBtn")
    refreshBtn:setVisible(false)
    local posx = refreshBtn:getPositionX()
    if posx < 20 then
        posx = 20
        refreshBtn:setPositionX(posx)
    end
    local redImg = refreshBtn:getChildByName("redImg")
    redImg:setVisible(coldDown ~= 0)
    local numLab = redImg:getChildByName("numLab")
    numLab:setString(coldDown)

    --//null 更新 开服活动提示
    --logger:info("更新开服活动提示")
    local roleProxy = self:getProxy(GameProxys.Role)
    local Image_50=self:getChildByName("mainPanel/Image_50")
    local desc = roleProxy:getWorldTimeConfigAll() 
    if desc~=nil and  desc ~="" then
    Image_50:setVisible(true)
    local Label_52=Image_50:getChildByName("Label_52")
    Label_52:setString(desc)
    local size= Label_52:getContentSize()
    Image_50:setContentSize(size.width+110,48)
    else
    Image_50:setVisible(false)
    end

    -- 7765 【优化】- 世界界面郡城相关按钮优化
    self:setShowCityWarBtns(roleProxy:isShowCityWarBtns())

    -- 皇位战倒计时
    self:showEmperorCityStateInUpdate()
end

local scaleTime = 0.2
function MapInfoPanel:refreshPanel(sender)
    local dir = sender.dir
    local scaleNum, move, posX
    if dir == 1 then
        scaleNum = 0
        move = cc.p(self.leftX, 0)
        posX = 0
    else
        scaleNum = 1
        move = cc.p(-self.leftX, 0)
        posX = self.rightX
    end
    local scale = cc.ScaleTo:create(scaleTime, scaleNum)
    local callFunc = cc.CallFunc:create(function()
        sender:runAction(cc.MoveBy:create(scaleTime, move))
    end)
    local call = cc.CallFunc:create(function()
        sender:setScaleX(dir*-1)
        local redImg = sender:getChildByName("redImg")
        redImg:setPositionX(posX)
        redImg:setScaleX(dir*-1)
    end)
    local action = cc.Spawn:create(scale, callFunc)
    local seq = cc.Sequence:create(action, call)
    self.banditPanel:runAction(seq)
    local refreshBtn = self:getChildByName("mainPanel/refreshBtn")
    refreshBtn.dir = dir * (-1)
end

function MapInfoPanel:hideBanditPanel()
    local roleProxy = self:getProxy(GameProxys.Role)

    local level = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    local btnExp = self:getChildByName("mainPanel/btnExp")
    --btnExp:setVisible(level < 30)
    
    local refreshBtn = self:getChildByName("mainPanel/refreshBtn")
    refreshBtn.dir = 1
    self:refreshPanel(refreshBtn)
end

function MapInfoPanel:onExpBtnTouch(sender)
    --local panel = self:getPanel(MapExplainPanel.NAME)
    --panel:show()
    self.view:showOtherModule( { moduleName = ModuleName.WorldHelp })
end

-- 国战和排名按钮的显示
function MapInfoPanel:setShowCityWarBtns(state)
    if self._btnTownMsg and self._btnTownRank then
        if self._btnTownMsg:isVisible() ~= state then
            self._btnTownMsg:setVisible(state)
            self._btnTownRank:setVisible(state)
        end
    end
end
-- 显示皇城战状态显示1-未开放, 2-休战期(归属期), 3准备期(保护), 4-争夺期 
function MapInfoPanel:showEmperorCityState()
    local showCityStatus = self._emperorCityProxy:getShowCityStatus()
    local remainTime = self._emperorCityProxy:getRemainTime(AppEvent.NET_M55_C550004)
    if showCityStatus == 3 or showCityStatus == 4 then
        self._emperorCityPanel:setVisible(true)
        local url = string.format("images/map/emperor_state%d.png", showCityStatus)
        TextureManager:updateImageView(self._stateImg, url)

        local timeStr = TimeUtils:getStandardFormatTimeString6(remainTime, true)
        self._remianTimeTxt:setString( string.format(self:getTextWord(146), timeStr)) -- 倒计时：

        self._buyCommandPanel:setVisible(true)
    else
        self._emperorCityPanel:setVisible(false)

        self._buyCommandPanel:setVisible(false)
    end
end

function MapInfoPanel:showEmperorCityStateInUpdate()
    local showCityStatus = self._emperorCityProxy:getShowCityStatus()
    if showCityStatus == 0 then
        return 
    end

    if self._emperorCityPanel == nil or self._buyCommandPanel == nil then
        return
    end

    if showCityStatus == 3 or showCityStatus == 4 then
        self._emperorCityPanel:setVisible(true)
        self._buyCommandPanel:setVisible(true)
        local remainTime = self._emperorCityProxy:getRemainTime(AppEvent.NET_M55_C550004)
        local timeStr = TimeUtils:getStandardFormatTimeString6(remainTime, true)
        self._remianTimeTxt:setString( string.format(self:getTextWord(146), timeStr)) -- 倒计时：
    else
        self._emperorCityPanel:setVisible(false)

        self._buyCommandPanel:setVisible(false)
    end
end

-- 点击弹出购买窗口
function MapInfoPanel:onBuyCommand()
    logger:info("点击购买军资")
    local curBoughtTimes = self._emperorCityProxy:getBoughtTimes() -- 已购买过的次数
    local configData = ConfigDataManager:getConfigData(ConfigData.EmperorWarResourceConfig)
    self._uiBuySaleCommand = UIBuySaleCommand.new(self, self.buyCommandCallback)
    self._uiBuySaleCommand:updateSalePanel(configData, curBoughtTimes)
end

-- 
function MapInfoPanel:buyCommandCallback(expendNum, buyCount)
    -- 点击购买 
    local data = {}
    local haveGold = self:getProxy(GameProxys.Role):getRoleAttrValue(PlayerPowerDefine.POWER_gold)
    if expendNum > haveGold then
        data.money = expendNum
        self:isShowRechargeUI(data)
    else
        -- 发送购买
        data.buyCount = buyCount
        self._emperorCityProxy:onTriggerNet550005Req(data)
    end

    if self._uiBuySaleCommand then
        self._uiBuySaleCommand:hide()
    end
end