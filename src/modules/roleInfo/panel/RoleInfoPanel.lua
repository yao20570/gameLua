
RoleInfoPanel = class("RoleInfoPanel", BasicPanel)
RoleInfoPanel.NAME = "RoleInfoPanel"

function RoleInfoPanel:ctor(view, panelName)
	self.headBg = ModuleName.PersonInfoModule
    self.kuPanel = ModuleName.WarehouseModule
    self.rechargePanel = ModuleName.RechargeModule
    self.fightingCapModule = ModuleName.FightingCapModule
	self._resourceConfig = "ResourceConfig"
    RoleInfoPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function RoleInfoPanel:finalize()
    RoleInfoPanel.super.finalize(self)

    if self._roleExpUpCcb ~= nil then 
        self._roleExpUpCcb:finalize()
        self._roleExpUpCcb = nil
    end

    if self._jingyantiao ~= nil then
        self._jingyantiao:finalize()
        self._jingyantiao = nil
    end

    if self._tipEffect~= nil then
        self._tipEffect:finalize()
        self._tipEffect =nil 
    end
end

function RoleInfoPanel:initPanel()
	RoleInfoPanel.super.initPanel(self)
    self._info = {}
--    self:onRoleInfo()

    self._roleProxy = self:getProxy(GameProxys.Role)

    self:initResourcesInfo()
    --self:createOrUpdateSunshine()
    --self:createOrUpdateSunshine2()

    local sunshineImg = self:getChildByName("Panel_1/sunshineImg")
    sunshineImg:setVisible(GlobalConfig.sunshine2IsShow)
    self._sunshineImg = sunshineImg
    self._sunshineImg:setVisible(GlobalConfig.isSunshineImgShow)
    if GlobalConfig.sunshine2IsShow == true then    
        TextureManager:updateImageView(sunshineImg, GlobalConfig.sunshine2Url)
        --sunshineImg:setScale(GlobalConfig.sunshine2Scale0)
        sunshineImg:setAnchorPoint(GlobalConfig.ancPoint)
        sunshineImg:setPosition(GlobalConfig.sunshine2Pos.x, GlobalConfig.sunshine2Pos.y)
    end

    local monryBtn = self:getChildByName("Panel_1/monryBtn")
    if not monryBtn.ccb then
        local size = monryBtn:getContentSize()
        monryBtn.ccb = self:createUICCBLayer("rgb-huoquyuanbao",monryBtn)
        monryBtn.ccb:setPosition(size.width / 2, size.height / 2)
    end
    
    self:isShowSkillTip()
end

function RoleInfoPanel:onShowHandler()
    local name = self._roleProxy:getRoleName()
    if name == "" or name == nil then
    else
        print("开始在个人信息里面播放阳光普照动画") 
        TimerManager:addOnce(60,self.createOrUpdateSunshine, self)
        TimerManager:addOnce(90,self.createOrUpdateSunshine2, self)
    end
end

function RoleInfoPanel:onHideHandler()
    if self.movieChip_sunshine then
        self.movieChip_sunshine:finalize()
        self.movieChip_sunshine = nil
    end
    self._sunshineImg:stopAllActions()
end

-- 主城阳光动画
function RoleInfoPanel:createOrUpdateSunshine()
    -- body
    local sunshinePanel = self:getChildByName("Panel_1/sunshinePanel")
    sunshinePanel:setVisible(GlobalConfig.sunshineIsShow)
    
    if GlobalConfig.sunshineIsShow == true and self.movieChip_sunshine == nil then

        if self.movieChip_sunshine == nil then
            sunshinePanel:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
            local movieChip = UIMovieClip.new(GlobalConfig.ScenePreEffects[11])
            movieChip:setAnchorPoint(1,1)
            movieChip:setScale(GlobalConfig.sunshineScale)
            movieChip:setParent(sunshinePanel)
            self.movieChip_sunshine = movieChip
        end
        movieChip:play(true, nil, nil, nil)
        -- logger:info("主城阳光动画....play ")
    end
end


-- 主城阳光动画2
function RoleInfoPanel:createOrUpdateSunshine2()
    -- body
    -- local sunshineImg = self:getChildByName("Panel_1/sunshineImg")
    -- sunshineImg:setVisible(GlobalConfig.sunshine2IsShow)
    -- self._sunshineImg = sunshineImg

    if GlobalConfig.sunshine2IsShow == true then    
        -- TextureManager:updateImageView(sunshineImg, GlobalConfig.sunshine2Url)
        -- sunshineImg:setScale(GlobalConfig.sunshine2Scale0)
        -- sunshineImg:setAnchorPoint(GlobalConfig.ancPoint)
        -- sunshineImg:setPosition(GlobalConfig.sunshine2Pos.x, GlobalConfig.sunshine2Pos.y)
        
        -- sunshineImg:setOpacity(200)
        -- logger:info("主城阳光动画2 .... play ")

        self._sunshineImg:setScale(GlobalConfig.sunshine2Scale0)
        local scaleTo1 = cc.ScaleTo:create(GlobalConfig.sunshine2Delay, GlobalConfig.sunshine2Scale1)
        local scaleTo2 = cc.ScaleTo:create(GlobalConfig.sunshine2Delay, GlobalConfig.sunshine2Scale0)

        local fadeTo1 = cc.FadeTo:create(GlobalConfig.sunshine2Delay2, GlobalConfig.sunshine2Fade0)
        local fadeTo2 = cc.FadeTo:create(GlobalConfig.sunshine2Delay2, GlobalConfig.sunshine2Fade1)

        local action = cc.RepeatForever:create(cc.Spawn:create(cc.Sequence:create(scaleTo1, scaleTo2), cc.Sequence:create(fadeTo1, fadeTo2)))

        self._sunshineImg:runAction(action)
    end

end

function RoleInfoPanel:onMoveScene(data)
    -- body

    -- local x = math.abs(data[1]/data[3]*3)
    -- local y = math.abs(data[2]/data[4]/6)
    -- logger:info("RoleInfoPanel:onMoveScene(data)  data= %d %d %d %d ,,, %d %d", data[1], data[2], data[3], data[4], x, y)


    -- self._sunshineImg:setAnchorPoint(x,y)
    x = data[1] / 1200.0 * (-1)
    self._sunshineImg:setRotation(x*GlobalConfig.sunshine2MaxR)

    -- y = math.abs((data[2] / -300))
    -- y = data[2] / (-300.0 )
    -- logger:info("y = %d", y)
    -- self._sunshineImg:setScaleY(y)    
end

function RoleInfoPanel:getAllData()
    local data = {}
    local roleProxy = self._roleProxy
    data.exp = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_exp)
    data.level = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    data.icon = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_icon)
    data.vipLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel)
    data.areaId = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_areaId)--服务器id
    data.energy = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_energy)--体力
    -- data.tael = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_tael)--银两（宝石）
    -- data.iron = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_iron)--铁锭(铁矿)
    -- data.stones = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_stones)--石料（石油）
    -- data.wood = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_wood)--木材（铜矿）
    -- data.food = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_food)--粮食（硅矿）
    data.gold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold)--金币(元宝)
    data.highestCapacity = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_highestCapacity)--最高战力
    data.name = roleProxy:getRoleName()
    data.headId = roleProxy:getHeadId()
    data.pendantId = roleProxy:getPendantId()
    
    -- data.per = self:getResourcePercent(data)
    return data
end

-- -- 读取资源容量，计算%，返回%
-- function RoleInfoPanel:getResourcePercent(resData)
--     local powerDef = {
--                         [1] = {cur = PlayerPowerDefine.POWER_tael, max = PlayerPowerDefine.POWER_tael_Capacity},        --银两
--                         [2] = {cur = PlayerPowerDefine.POWER_iron, max = PlayerPowerDefine.POWER_iron_Capacity},        --铁锭
--                         [3] = {cur = PlayerPowerDefine.POWER_stones, max = PlayerPowerDefine.POWER_stones_Capacity},    --石料
--                         [4] = {cur = PlayerPowerDefine.POWER_wood, max = PlayerPowerDefine.POWER_wood_Capacity},        --木头
--                         [5] = {cur = PlayerPowerDefine.POWER_food, max = PlayerPowerDefine.POWER_food_Capacity},        --粮食
--                     }

--     local roleProxy = self:getProxy(GameProxys.Role)
--     local conf = ConfigDataManager:getConfigData(self._resourceConfig)
--     local cur,max,per = nil,nil,nil
--     for k,v in pairs(powerDef) do
--         cur = roleProxy:getRolePowerValue(GamePowerConfig.Resource,powerDef[k].cur) or 0--当前拥有量
--         max = roleProxy:getRolePowerValue(GamePowerConfig.Resource,powerDef[k].max) or 0--容量
--         if cur >= max then
--             per = 100
--         else
--             per = cur/max*100
--         end
--         resData[k] = per or 0
--     end
--     return resData
-- end

function RoleInfoPanel:onRoleInfo()
    -- body
    self._info = self:getAllData()
    self:onRoleInfoUpdateResp()
end

-- roleProxy更新
function RoleInfoPanel:onRoleInfoUpdateResp(updatePowerList)
    -- body
    self._info = self:getAllData()
    self:updateRoleInfo()  --TODO 全体刷新效率
    self:updateResInfo()  --TODO 资源UI全体刷新效率
end

--名字更新
function RoleInfoPanel:onRoleNameUpdate()
    -- local roleProxy = self._roleProxy
    -- local info = self._info
    -- local playerName = self:getChildByName("Panel_1/playerName")
    -- -- playerName:setString(string.format(self:getTextWord(529),info.level) .. " " .. info.name)
    -- playerLevel:setString(string.format(self:getTextWord(529),info.level))
    -- playerName:setString(" " .. info.name)
    self:updateRoleLvName(self._info)
end

--名字更新
function RoleInfoPanel:updateRoleLvName(info)
    --TODO:这段由于以前studio的工程文件没上传，造成后面的导出文件缺少limitLab造成异常，完全理解代码后要重新还原一个limitLab才能解决
  local playerName = self:getChildByName("Panel_1/playerName")
  local playerLevel = self:getChildByName("Panel_1/playerLevel")
  
  local targetLab = self:getChildByName("Panel_1/limitLab")
  local maxPosx = targetLab:getPositionX() - 5
  
  -- playerName:setString(string.format(self:getTextWord(529),info.level) .. " " .. info.name)
  playerLevel:setString(string.format(self:getTextWord(529),info.level))
  playerName:setString(" " .. info.name)

  --//人物升级之后 也刷新一次技能判断
  self:isShowSkillTip()

  --
  -- local nameLen = StringUtils:separate(info.name or " ")
  --
  -- local size = playerLevel:getContentSize()
  -- local x = playerLevel:getPositionX()
  -- playerName:setPositionX(x + size.width)
  --
  -- local nameSize = playerName:getContentSize()
  --
  -- local fontSize = 20
  -- if (x + size.width + nameSize.width) > maxPosx then
  --     fontSize = (maxPosx - x - size.width) / table.size(nameLen)
  --     fontSize = math.floor(fontSize)
  --     logger:error("强制调整名字的大小为：".. fontSize)
  -- end
  -- playerName:setFontSize(fontSize)
end

--头像更新
function RoleInfoPanel:onRoleHeadUpdate()
    local Panel_1 = self:getChildByName("Panel_1")
    local headFrame = Panel_1:getChildByName("headBtn")       --头像框


    -- local roleProxy = self._roleProxy
    local headId = self._roleProxy:getHeadId()
    local pendantId = self._roleProxy:getPendantId()

    local headImg = self:getChildByName("Panel_1/heandBtnImg/headImg")
    local headInfo = {}
    headInfo.icon = headId
    headInfo.pendant = pendantId
    --headInfo.preName1 = "headIcon"
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = nil
    headInfo.isCreatPendant = false
    --headInfo.isCreatButton = true
    headInfo.playerId = self._roleProxy:getPlayerId()

    local head = self._head
    if head == nil then
        head = UIHeadImg.new(headImg,headInfo,self)
        --head:setHeadScale(1.2)
        self._head = head
    else
        head:updateData(headInfo)
    end
    --head:setHeadTransparency()
end


function RoleInfoPanel:updateRoleInfo()
    local info = self._info
    
    local Panel_1 = self:getChildByName("Panel_1")
    local btnHead = Panel_1:getChildByName("heandBtnImg")       --头像
    -- local playerName = Panel_1:getChildByName("playerName")             --玩家名称
    -- local playerLevel = Panel_1:getChildByName("playerLevel")             --玩家名称
    local energyBar = Panel_1:getChildByName("energyBar") --体力进度条
    local vipBtn = Panel_1:getChildByName("vipBtn")         --VIP按钮
    local fightBtn = Panel_1:getChildByName("fightBtn")     --战力按钮
    local monryBtn = Panel_1:getChildByName("monryBtn")     --元宝按钮
    local Label_23 = monryBtn:getChildByName("Label_23")    --txt元宝
    local heavey = monryBtn:getChildByName("heavey")        --num元宝
    local expBarBg = Panel_1:getChildByName("expBarBg")     --经验条背景
    local expBar = expBarBg:getChildByName("expBar")        --经验条
    local Image_vip = vipBtn:getChildByName("Image_vip")        --vip image
    local vipTxt = vipBtn:getChildByName("vipTxt")        --vip lv
    local expLab = expBarBg:getChildByName("expLab")        --经验显示 --
    local curExpLab = expBarBg:getChildByName("curExpLab")
    local energyLab = Panel_1:getChildByName("energyLab")        --体力显示(行军令) --
    local headFrame = Panel_1:getChildByName("headBtn")       --头像框

    -- 玩家头像
    local headImg = btnHead:getChildByName("headImg")
    local headInfo = {}
    headInfo.icon = info.headId
    headInfo.pendant = info.pendantId
    --headInfo.preName1 = "headIcon"
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = nil
    headInfo.isCreatPendant = false
    --headInfo.isCreatButton = true
    headInfo.playerId = self._roleProxy:getPlayerId()

    local head = self._head
    if head == nil then
        head = UIHeadImg.new(headImg,headInfo,self)
        --head:setHeadScale(1.2)
        self._head = head
    else
        head:updateData(headInfo)
    end
    --head:setHeadTransparency()

    self.headBtn = headFrame--self._head:getButton()
    self:addTouchEventListener(self.headBtn, self.onTouchedBtnHead)


    -- 玩家名字等级
    -- playerName:setString(string.format(self:getTextWord(529),info.level) .. " " .. info.name)
    -- playerLevel:setString(string.format(self:getTextWord(529),info.level))
    -- playerName:setString(" " .. info.name)
    self:updateRoleLvName(info)

    -- 体力进度条
    local cur = info.energy or 0
    local max = 20
    local per = nil
    if cur >= max then
        per = 100
    else
        per = cur / max * 100
    end
    energyBar:setPercent(per)

    energyLab:setString(cur .. "/" .. max)

    -- 经验进度条
    local curExp = 0
    local maxExp = 0
    local barPer = 0
    self._CmderConfig = "CommanderConfig"

    if info.level > 0 then
        local conf = ConfigDataManager:getConfigById(self._CmderConfig,info.level)
        curExp = info.exp
        maxExp = conf.exp
        barPer = curExp/maxExp*100
        if curExp >= maxExp then -- 超过则算满进度
            barPer = 100
        end
    end
--        logger:error("---------玩家等级错误!!!等级不能是%d----------",info.level)
--        logger:error("---------玩家等级错误!!!等级不能是%d----------",info.level)
--        logger:error("---------当前最高等级是: %d----------",self._roleProxy:getRoleMaxLevel())
--        logger:error("---------当前最高等级是: %d----------",self._roleProxy:getRoleMaxLevel())

    expBar:setPercent(barPer)
    -- 加特效
    if curExp >= maxExp and info.level < self._roleProxy:getRoleMaxLevel() then 
        if self._roleExpUpCcb == nil then
            self._roleExpUpCcb = self:createUICCBLayer("rgb-jiantou", expBar)
            self._roleExpUpCcb:setPosition(- 30 , 5)
        end

         --//经验条也加一个特效
        if self._jingyantiao == nil then
            self._jingyantiao = self:createUICCBLayer("rpg-zgdj-liaoguang",expBar)
            self._jingyantiao:setPosition(70,7.5)
        end
        self._roleExpUpCcb:setVisible(true)
        self._jingyantiao:setVisible(true)
    else
        -- 隐藏特效
        if self._roleExpUpCcb ~= nil then 
            self._roleExpUpCcb:setVisible(false)
        end

        if self._jingyantiao ~= nil then
            self._jingyantiao:setVisible(false)
        end
    end

    -- 变颜色
    if curExp >= maxExp then
        curExpLab:setColor(ColorUtils.wordGoodColor)
    else
        curExpLab:setColor(ColorUtils.wordNameColor)
    end

    -- 经验显示
    curExpLab:setString(StringUtils:formatNumberByK4Ceil(curExp)) 
    expLab:setString("/" .. StringUtils:formatNumberByK4Ceil(maxExp))
    curExpLab:setPositionX(expLab:getPositionX() - expLab:getContentSize().width)

    -- VIP文本自适应对齐
    vipTxt:setString(info.vipLevel)
    -- local posx = vipBtn:getPositionX()
    -- local sizeL = Image_vip:getContentSize()
    -- local sizeR = vipTxt:getContentSize()
    -- local allLen = sizeL.width + sizeR.width
    -- local x1 = 0 - (allLen/2 - sizeL.width/2) + 24
    -- local x2 = x1 + sizeL.width - 12
    -- Image_vip:setPositionX(x1)
    -- vipTxt:setPositionX(x2)
    -- print("allLen="..allLen..",sizeL.width="..sizeL.width..",sizeR.width="..sizeR.width..",posx="..posx)    


    local fightTxt = fightBtn:getChildByName("fightTxt")
    fightTxt:setString(StringUtils:formatNumberByK3(info.highestCapacity, PlayerPowerDefine.POWER_highestCapacity))
    Label_23:setString(self:getTextWord(528))
    heavey:setString(info.gold)

    --繁荣
    local boomBtn = Panel_1:getChildByName("boomBtn")
    local boomLab = boomBtn:getChildByName("boomLab") 
    local curBoom = boomBtn:getChildByName("curBoom")
    local maxBoom = boomBtn:getChildByName("maxBoom")

    local boom = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_boom) or 0             --繁荣值（cur）
    local boomUpLimit = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_boomUpLimit) or 0--繁荣值（max）
    local boomLevel = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_boomLevel) or 0--繁荣等级
    
    local isDestroy,destroyBoom = self._roleProxy:getBoomState()
    -- 取繁荣倒计时(秒) 恢复到正常的时间
    local remainTime = self._roleProxy:getBoomRemainTime()
    
    if isDestroy == true then
        curBoom:setColor(ColorUtils.wordRed)
    else
        curBoom:setColor(ColorUtils.wordYellow)
    end
    curBoom:setString(boom)
    maxBoom:setString( string.format(self:getTextWord(312), boomUpLimit))

    NodeUtils:alignNodeL2R(curBoom, maxBoom)
    
   
    local data = {}
    data.boomLevel = boomLevel
    data.isDestroy = isDestroy
    data.remainTime = remainTime
    data.boom = boom
    data.boomUpLimit = boomUpLimit

    boomBtn.data = data
    self._Image_bg = boomBtn
    self:addTouchEventListener(boomBtn, self.onBoomTipBtn)   


    self:addTouchEventListener(monryBtn,self.onTouchedMoney)
    self:addTouchEventListener(fightBtn,self.onTouchedFight)
    self:addTouchEventListener(vipBtn,self.onVipBtn)
    
end

-- function RoleInfoPanel:registerEvents()

    -- local btnHead = self:getChildByName("Panel_1/heandBtnImg")
    -- local headBtn = self:getChildByName("Panel_1/heandBtnImg/headBtn")
    
    -- self:addTouchEventListener(headBtn,self.onTouchedBtnHead)
    
    -- self["headBtn"] = headBtn
-- end



-----------------------------------------------------------------------------
-- 资源UI start
-----------------------------------------------------------------------------
-- 初始化资源UI
function RoleInfoPanel:initResourcesInfo()
    -- 资源UI
    self._resPanels = {}
    local Panel_66 = self:getChildByName("Panel_66")
    local resPanel = self:getChildByName("Panel_66/resPanel")

    for i=1,5 do
        -- print("资源初始化···updateResourcesInfo---1")
        local resP = resPanel:getChildByName("res"..i)
        local number = resP:getChildByName("number")
        local barBG = resP:getChildByName("barBG")
        local bar = barBG:getChildByName("bar")

        resP.number = number
        resP.bar = bar
        self._resPanels[i] = resP
    end

    --资源按钮
    self._resBtn = resPanel:getChildByName("resBtn")
    self["warehouseBtn"] = self._resBtn --新手引导用的
    self:addTouchEventListener(self._resBtn,self.onTouchedResource)
end

-- roleProxy更新
function RoleInfoPanel:updateResInfo()
    -- body
    -- local roleProxy = self:getProxy(GameProxys.Role)
    local resInfo,powerDef = self._roleProxy:getResDataAndConf()

    self:updateResUI(resInfo,powerDef)  --TODO 全体刷新效率
end

function RoleInfoPanel:updateResUI(info,powerDef)
    -- print("资源渲染···updateResourcesInfo---0")
    -- 资源UI
    for i=1,5 do
        -- print("资源渲染···updateResourcesInfo---1")
        local indexCur = powerDef[i].cur
        local indexMax = powerDef[i].max
        self._resPanels[i].number:setString(StringUtils:formatNumberByK3(info[indexCur], indexCur)) 

        local cur = tonumber(info[indexCur])
        local max = tonumber(info[indexMax])
        local color = cur >= max and ColorUtils:color16ToC3b("#FCDA7E") or cc.c3b(255,255,255)
        self._resPanels[i].number:setColor(color)
        self._resPanels[i].bar:setPercent(info[indexCur..i])
    end
end

-- 资源按钮
function RoleInfoPanel:onTouchedResource(sender)
    -- print("···-- 资源按钮")
    ModuleJumpManager:jump(ModuleName.WarehouseModule, nil)
end
-----------------------------------------------------------------------------
-- 资源UI end
-----------------------------------------------------------------------------


-- VIP按钮接口
function RoleInfoPanel:onVipBtn(sender)
    -- body
    SDKManager:showWebHtmlView("html/vip.html")    
end

-- 头像
function RoleInfoPanel:onTouchedBtnHead(sender)
    -- self:showSysMessage("on Touched Btn Head")
    self.view:showOtherModule(self.headBg)
end

-- -- 资源
-- function RoleInfoPanel:onTouchedResource(sender)
--     self.view:showOtherModule(self.kuPanel)
-- end

-- 元宝
function RoleInfoPanel:onTouchedMoney(sender)
    self.view:showOtherModule(self.rechargePanel)
end

-- 战力
function RoleInfoPanel:onTouchedFight(sender)
    self.view:showOtherModule(self.fightingCapModule)
end


-- 繁荣度tip
function RoleInfoPanel:onBoomTipBtn(sender)
    -- body
    local BR = self:getTextWord(50059)

    local data = sender.data
    local boomlv = data.boomLevel
    local info,lastData = ConfigDataManager:getInfoFindByOneKey2(ConfigData.BoomLevelConfig,"boomlv",boomlv)

    --繁荣0级 繁荣要求(0)
    local content1 = self:getTextWord(50042)
    local content101 = boomlv
    local content102 = self:getTextWord(50043)
    local content103 = info.numneed
    local content104 = self:getTextWord(50044)    

     --带兵量+000
    local content2 = self:getTextWord(50040)
    local content002 = string.format(self:getTextWord(50041),info.command)

    --编制经验+0%
    -- local content3 = self:getTextWord(50045)
    -- local content301 = string.format(self:getTextWord(50046),math.floor(info.estExpAddRate)) --编制经验+12%


    -- 下一等级
    local content21 = self:getTextWord(50038)
    local content22 = ""
    local content23 = ""
    local content24 = ""
    local content2202 = ""
    local content2301 = ""
    local content2401 = ""
    local content2402 = ""
    local content2403 = ""
    local content2404 = ""

    if boomlv < lastData.boomlv then
        local lv = boomlv + 1
        local info2 = ConfigDataManager:getInfoFindByOneKey(ConfigData.BoomLevelConfig,"boomlv",lv)

        --繁荣0级 繁荣要求(0)
        content24 = self:getTextWord(50042)
        content2401 = lv
        content2402 = self:getTextWord(50043)
        content2403 = info2.numneed
        content2404 = self:getTextWord(50044)

         --带兵量+000
        content22 = self:getTextWord(50040)
        content2202 = string.format(self:getTextWord(50041),info2.command)

        --编制经验+0%
        -- content23 = self:getTextWord(50045)
        -- content2301 = string.format(self:getTextWord(50046),math.floor(info2.estExpAddRate)) --编制经验+12%

    else
        content24 = self:getTextWord(50039)
    end

    -- 当前繁荣 00/00
    local content00 = self:getTextWord(50054)
    local content01 = data.boom
    local content02 = string.format(self:getTextWord(50055), data.boomUpLimit)
    
    local content03 = ""
    if data.remainTime > 0 then
        content03 = string.format(self:getTextWord(50056), TimeUtils:getStandardFormatTimeString8(data.remainTime)) -- + content03
    end

    local line0 = {{content = content00, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1602}, 
        {content = content01, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1603},
        {content = content02, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1601},
        {content = content03, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1604},
    }


    -- 当前等级
    local content13 = self:getTextWord(5002300)
    local line1 = {
        {content = content13, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1602},
        {content = BR..content1, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1601},
        {content = BR..content101, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1603},
        {content = BR..content102, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1601},
        {content = BR..content103, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1603},
        {content = BR..content104, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1601}
    }
    local line2 = {{content = content2, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1601},{content = content002, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1603}}
    -- local line3 = {{content = content3, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1601},{content = content301, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1603}}


    -- 下一级
    local line21 = {{content = content21, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1602}, 
        {content = BR..content24, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1601},
        {content = BR..content2401, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1603},
        {content = BR..content2402, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1601},
        {content = BR..content2403, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1604},
        {content = BR..content2404, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1601}
    }

    local line22 = {{content = content22, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1601},{content = content2202, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1603}}
    -- local line23 = {{content = content23, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1601},{content = content2301, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1603}}


    -- 先插入表中
    local lines = {}
    table.insert(lines, line0)
    table.insert(lines, line1)
    table.insert(lines, line2)
    -- table.insert(lines, line3)      
    table.insert(lines, line21)
    table.insert(lines, line22)
    -- table.insert(lines, line23)     


    -- 繁荣状态 正常/废墟
    local content3000 = self:getTextWord(50047)
    local content3001 = ""    
    if data.isDestroy == true then
        -- 废墟
        content3001 = self:getTextWord(50049)

        local content3002 = self:getTextWord(50050)    
        local content3003 = self:getTextWord(50051)    
        local content3004 = self:getTextWord(50052)    
        local content3005 = self:getTextWord(50053)    


        local line4 = {{content = content3000, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1602}, {content = BR..content3001, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1604}}
        local line5 = {{content = content3002, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1604}}
        local line6 = {{content = content3003, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1604}}
        local line7 = {{content = content3004, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1604}}
        local line8 = {{content = content3005, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1604}}

        table.insert(lines, line4)      
        table.insert(lines, line5)      
        table.insert(lines, line6)      
        table.insert(lines, line7)      
        table.insert(lines, line8)      

    else
        -- 正常
        content3001 = self:getTextWord(50048)        
        local line4 = {{content = content3000, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1602}, {content = BR..content3001, foneSize = ColorUtils.tipSize18, color = ColorUtils.wordColorDark1603}}
        table.insert(lines, line4)      
    end
  


    local parent = self:getParent():getParent()
    local uiTip = parent:getChildByTag(9991)
    if uiTip == nil then
        --第一次打开tip
        uiTip = UITip.new(parent)
    elseif uiTip:isVisible() == false then
        logger:error("···uiTip:isVisible() = false!!")
        return
    else       
        uiTip = self._boomTip
    end


    -- 最后 渲染
    uiTip:setAllTipLine(lines)
    
    uiTip.lines = lines
    self._boomTip = uiTip

end



-- 刷新繁荣OR体力列表项
function RoleInfoPanel:updateRolePowerHandler(data)
    -- body

    if data.power == PlayerPowerDefine.POWER_boom then
        -- 刷新繁荣
        logger:info("roleinfo···刷新繁荣")
        self._info = self:getAllData()

    end

end

function RoleInfoPanel:updateRemainTimeView(remainTime)
    -- body
    local parent = self:getParent()
    local uiTip = parent:getChildByTag(9991)

    if uiTip == nil then
        return
    end

    
    self._Image_bg.data.remainTime = remainTime
    self:onBoomTipBtn(self._Image_bg)
    -- logger:info("···updateRemainTimeView")

end

function RoleInfoPanel:update()
    -- body
    -- local roleProxy = self:getProxy(GameProxys.Role)
    local boom = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_boom) or 0--繁荣值（cur）
    local boomUpLimit = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_boomUpLimit) or 0--繁荣值（max）
    if boom < boomUpLimit then
        -- 繁荣未满
       local remainTime = self._roleProxy:getBoomRemainTime()
       -- print("···繁荣未满 remainTime", remainTime)
       self:updateRemainTimeView(remainTime)
    else
        -- 繁荣已满
       -- logger:info("···繁荣已满")
       self:updateRemainTimeView(0)
    end
end

--//图标显示特效回调
function RoleInfoPanel:isShowSkillTip()
      local headBtn =self:getChildByName("Panel_1/headBtn")
      self._skillProxy = self:getProxy(GameProxys.Skill)
      if self._skillProxy._isEffectTip then
      if self._tipEffect ~=nil then
            self._tipEffect:setVisible(true)
            else
            self._tipEffect =  self:createUICCBLayer("rgb-jiantou", headBtn)
            self._tipEffect:setPosition(15,-35)
            self._tipEffect:setScale(0.75)
            end
      else
            if self._tipEffect~=nil then
            self._tipEffect:setVisible(false)
            end
      end
end
