-- /**
--  * @Author:    fzw
--  * @DateTime:    2016-08-24 14:35:23
--  * @Description: 副本双边布阵通用UI
--  */


-- --战斗类型
-- GameConfig.battleType = {}
-- GameConfig.battleType.level = 1 --战役
-- GameConfig.battleType.explore = 2 --探险
-- GameConfig.battleType.arena = 3 --演武场
-- GameConfig.battleType.world = 4 --世界战斗
-- GameConfig.battleType.world_def = 5 --世界战斗防守
-- GameConfig.battleType.legion = 6 --军团试炼场
-- GameConfig.battleType.world_boss = 7 --世界Boss


--------type 副本类型
-- 0:默认布阵界面
-- 1:战役  
-- 2:远征
-- 3:
-- 4:
-- 5:
-- 6:军团试炼场
-- 7:
-- 8:
-- 9:剿匪副本



--[[
按钮请求的返回，在代理TeamDetailProxy处理

callBack：   挑战按钮的回调，点挑战时有回调，直接走回调
type:        副本界面类型
extra：      未启用
]]


--[[


配置显示参数(星星，战损，挂机)，默认都显示
data.extra = {
    isShowStar = true/false,   --星星
    isShowLost = true/false,   --战损
    isShowSleep = true/false,  --挂机
    isConfigData = true/false, --敌军的数据是否来自配置表（注意:如果没填，默认为true）
    targetName = "皇军贼",     --行军目标
}

]]

--[[
    @param  type:作为跳过战斗的key  每种战斗类型都在本地存放了一个key  (GameConfig.isAutoBattle .. self._type)
    要跟具体的战斗类型对应起来

    --战斗类型
    GameConfig.battleType = {}
    GameConfig.battleType.level = 1 --战役
    GameConfig.battleType.explore = 2 --探险
    GameConfig.battleType.arena = 3 --演武场
    GameConfig.battleType.world = 4 --世界战斗
    GameConfig.battleType.world_def = 5 --世界战斗防守
    GameConfig.battleType.legion = 6 --军团试炼场
    GameConfig.battleType.world_boss = 7 --世界Boss
    GameConfig.battleType.qunxiong = 8 --群雄逐鹿
    GameConfig.battleType.kill = 9 --剿匪
    GameConfig.battleType.west = 10 --西域远征  
    GameConfig.battleType.rebels = 14 --消灭叛军
]]

UITeamDetailPanel = class("UITeamDetailPanel")

function UITeamDetailPanel:ctor(parent, data, type, callBack, extra)
    local uiSkin = UISkin.new("UITeamDetailPanel")
    uiSkin:setVisible(false)
    self._uiSkin = uiSkin
    uiSkin:setParent(parent)
    self._parent = parent

    -- 配置显示参数(星星，战损，挂机)，默认都显示
    self._extra = rawget(data, "extra") or { }

    -- self._setTeamData = {}   --点开套用阵型时候的6组兵的数组

    -- 出战阵型的保存
    self._fightPosMap = { }

    -- 选中的team
    self._selectTeam = nil

    -- 总共开放的坑数量
    self._totalKen = 0

    -- 总共出战的佣兵数目
    self._totalSolsiers = 0

    -- 当前的载重
    self._currWeight = 0

    -- 当前的战力
    self._currFight = 0

    -- 军师出战ID
    self._consuId = nil
    
    --子战斗类型
    self._subBattleType = rawget(self._extra,"subtype") or 0
    
    self._data = data
    self._type = type or 0
    self._callBack = callBack
    self._btnMap = { }
    -- 所有按钮集合

    self:registerEvents()
    self:registerProxyEvent()
    self:initCCBPanel()
    self:initPosImg()
    self:setCurrFight()
    self:onUpdateData(data, type)

    self:adaptive()
    self:adaptiveBgImg()


    -- 做一个延时，避免自适应时界面跳动
    local function showCallback(...)
        self._uiSkin:setVisible(true)
    end
    TimerManager:addOnce(30, showCallback, self)
end

function UITeamDetailPanel:finalize()
    self._fightPosMap = {}
    self._selectTeam = nil
    self._totalKen = 0 
    self._totalSolsiers = 0 
    self._currWeight = 0 
    self._currFight = 0 
    self._consuId = nil  
    self._data = nil
    self._callBack = nil
    self._btnMap = nil

    if self._ccbFenWei ~= nil then
        self._ccbFenWei:finalize()
        self._ccbFenWei = nil
    end

    if self._sleepPanel then
        self._sleepPanel:finalize()
    end
    if self._UITeamMessPanel then
        self._UITeamMessPanel:finalize()
    end

    if self._uiAdviserListPanel ~=nil then
        self._uiAdviserListPanel:finalize()
        self._uiAdviserListPanel = nil
    end

    if self._uiSetTeamPanel ~= nil then
        self._uiSetTeamPanel:finalize()
        self._uiSetTeamPanel = nil
    end

--    local looseBgImg = self._middlePanel:getChildByName("looseBgImg")
--    if looseBgImg.effect ~= nil then
--        looseBgImg.effect:finalize()
--        looseBgImg.effect = nil
--    end
    
    self:removeProxyEvent()
    self._uiSkin:finalize()
end

--获取最大战力按钮
function UITeamDetailPanel:getMaxFightBtn()
    return self._maxFightBtn
end

--获取出战按钮
function UITeamDetailPanel:getFightBtn()
    return self._fightBtn
end

function UITeamDetailPanel:adaptive()
    -- 自适应
    local topAdaptivePanel = self._parent:topAdaptivePanel()
    NodeUtils:adaptiveTopPanelAndListView(self._topPanel, self._downPanel,GlobalConfig.downHeight,topAdaptivePanel)
end

function UITeamDetailPanel:registerEvents() --注册事件
    self._topPanel = self._uiSkin:getChildByName("topPanel")
    self._middlePanel = self._uiSkin:getChildByName("middlePanel")
    self._downPanel = self._uiSkin:getChildByName("DownPanel")
    self._ccbPanel = self._uiSkin:getChildByName("ccbPanel")

    self._bgImg = self._topPanel:getChildByName("bgImg")
    --TextureManager:updateImageViewFile(self._bgImg,"bg/ui/Bg_teamset.pvr.ccz")

    
    self._panelL = self._topPanel:getChildByName("PanelL") 
    self._panelR = self._topPanel:getChildByName("PanelR") 


    self._squreBtn =  self._downPanel:getChildByName("squreBtn")        --套用阵型按钮
    self._maxFightBtn = self._downPanel:getChildByName("maxFightBtn")      --最大战力
    self._maxWeightBtn = self._downPanel:getChildByName("maxWeightBtn")    --最大载重
    self._fightBtn = self._downPanel:getChildByName("fightBtn")            --出战按钮
    self._heroBtn = self._downPanel:getChildByName("heroBtn")              --显示武将按钮
    self._repairBtn = self._downPanel:getChildByName("repairBtn")          --治疗按钮
    self._tipTxt = self._downPanel:getChildByName("tipTxt")                --默认提示
    self._repairDotBg = self._repairBtn:getChildByName("dotBg")            --待治疗小红点背景
    self._repairDot = self._repairDotBg:getChildByName("dot")              --待治疗小红点

    self._richInfoTxt = self._panelL:getChildByName("richInfo")             --富文本L
    self._richInfoTxtR = self._panelR:getChildByName("richInfo")             --富文本R

    self._maxWeightBtn:setTitleText(TextWords:getTextWord(771))
    --self._squreBtn:setTitleText(TextWords:getTextWord(757))
    
    self._tipTxt:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 50), cc.FadeTo:create(0.5, 255))))

    self._roleProxy = self._parent:getProxy(GameProxys.Role)
    self._soliderProxy = self._parent:getProxy(GameProxys.Soldier)
    self._dungeonProxy = self._parent:getProxy(GameProxys.Dungeon)
    self._consiProxy = self._parent:getProxy(GameProxys.Consigliere)
    self._equipProxy =  self._parent:getProxy(GameProxys.Equip)
    self._patrsProxy = self._parent:getProxy(GameProxys.Parts)
    self._battleProxy = self._parent:getProxy(GameProxys.Battle)
    self._teamDetailProxy = self._parent:getProxy(GameProxys.TeamDetail)
    self._heroProxy = self._parent:getProxy(GameProxys.Hero)

    -- 跳过战斗按钮
    self.battleState = self._downPanel:getChildByName("battleState")
    local touchPanel = self._downPanel:getChildByName("touchPanel")
    self.touchPanel = touchPanel    
    ComponentUtils:addTouchEventListener(touchPanel, self.onBattleStateTouch, nil, self)

    self._btnMap = {
            self._squreBtn,
            self._maxFightBtn,
            self._maxWeightBtn,
            self._fightBtn,
            self._heroBtn,
            self._repairBtn,
        }

    self._heroBtnType = 1
    self._maxFightBtn.type = 1
    self._maxWeightBtn.type = 2

    for _,v in pairs(self._btnMap) do
        ComponentUtils:addTouchEventListener(v, self.onBtnTouchHandle, nil, self)
    end

end

function UITeamDetailPanel:registerProxyEvent()
    self._dungeonProxy:addEventListener(AppEvent.PROXY_DUNGEON_BUY_TIMES, self, self.onBuyTimesResp)
    self._soliderProxy:addEventListener(AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onRoleInfoChange)
    self._soliderProxy:addEventListener(AppEvent.PROXY_CONSUGOREQ, self, self.onConsuGoReq)
    self._soliderProxy:addEventListener(AppEvent.PROXY_TEAMPOS_UPDATE, self, self.updateTeamPos)
    self._soliderProxy:addEventListener(AppEvent.BAD_SOLDIER_LIST_UPDATE, self, self.updateRepairDot)
end

function UITeamDetailPanel:removeProxyEvent()
    self._dungeonProxy:removeEventListener(AppEvent.PROXY_DUNGEON_BUY_TIMES, self, self.onBuyTimesResp)
    self._soliderProxy:removeEventListener(AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onRoleInfoChange)
    self._soliderProxy:removeEventListener(AppEvent.PROXY_CONSUGOREQ, self, self.onConsuGoReq)
    self._soliderProxy:removeEventListener(AppEvent.PROXY_TEAMPOS_UPDATE, self, self.updateTeamPos)
    self._soliderProxy:removeEventListener(AppEvent.BAD_SOLDIER_LIST_UPDATE, self, self.updateRepairDot)
end

function UITeamDetailPanel:getProxy(name)
    return self._parent:getProxy(name)
end

function UITeamDetailPanel:onRoleInfoChange()  --个人信息发生改变
    local level = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)  --指挥官等级
    self._level = level
    self:setOpenPosBylevel(level)       --指挥官等级的改变，导致开放的坑位数目发生改变
    self:setSolderCount()              --每个槽位的出战佣兵上线的改变
end

function UITeamDetailPanel:initCCBPanel()
    if self._ccbFenWei == nil then
        self._ccbFenWei = self._parent:createUICCBLayer("rgb-szbd-fenwei", self._ccbPanel)
    end
end

function UITeamDetailPanel:initPosImg()  --初始化获得6个位置
    self._movePanel = self._uiSkin:getChildByName("movePanelL")
    NodeUtils:adaptive(self._movePanel)

    -- 从UISoldilerMainPos拿坑位UI，然后clone加载到当前panel
    local tt = UISoldilerMainPos.new(self._movePanel)
    self._commonImgPanel = tt:getChildByName("imgPos")
    local consImgPanel = tt:getChildByName("consPos")  --军师UI模板
    tt:finalize()  -- UI已经多余了，自杀

    self._posMap = {}  --槽位的开放设置
    local function callback1(pos)
        return self:getWhichPosEnable(pos)
    end
    local function callback2(pos) --弹出到佣兵列表的界面
        self:onPopTouch(pos)
    end

    local function callback3(team) --两个team成功交换pos之后
        self:changeTeamPos(team)
    end

    for index = 1 ,6 do
        local imgPos = self._movePanel:getChildByName("imgPos1"..index)
        local x,y = imgPos:getPosition()
        imgPos:setVisible(false)

        local team = self._commonImgPanel:clone()
        team:setVisible(true)
        team:setPosition(x,y)
        team:setName("imgPos"..index)
        self._movePanel:addChild(team)

        team.pos = index
        local args = {}
        args["objcet"] = self
        args["callback1"] = callback1
        args["callback2"] = callback2
        args["callback3"] = callback3
        IDrag.new(team,args, true)   --初始化各个坑位
        self._posMap[index] = { isOpen = false } --test
        self:setTeamSelectStatusByTeam(team,false)
    end


    -- 军师UI初始化
    local consuLMap = {}
    consuLMap[1] = {"movePanelL","movePanelL/consuImg"}
    consuLMap[2] = {"movePanelRR","movePanelRR/consuImg"}
    
    for k,str in pairs(consuLMap) do
        local panel = self._uiSkin:getChildByName(str[1])
        local imgPos = self._uiSkin:getChildByName(str[2])                      --军师L
        local x,y = imgPos:getPosition()
        imgPos:setVisible(false)

        local team = consImgPanel:clone()
        team:setVisible(true)
        team:setPosition(x,y)
        team:setName("consuImg")
        panel:addChild(team)
        ComponentUtils:addTouchEventListener(team, self.onClickConsuHandle, nil, self)
        
        if k == 1 then
            self._consuL = team
        else
            self._consuR = team
        end

    end
    self._consuR:setVisible(false)
    self._consuL:setScale(GlobalConfig.UITeamDetailScale)
    self._consuR:setScale(GlobalConfig.UITeamDetailScale)
    -- ComponentUtils:updateSoliderPosImg(self._consuR, 2, 2)

end

-- 每次打开刷新数据
function UITeamDetailPanel:onUpdateData(data, type)    
    
    if rawget(data,"extra") ~= nil then
        self._subBattleType = rawget(data.extra,"subtype") or 0
    end

    self._isWithoutHero = self:isWithoutHero(data) -- 判断是否不上阵武将
    if self._heroBtnType == 2 and self._isWithoutHero then
        self:onHeroBtnTouch(self._heroBtn)
    end

    self._enterType = self._teamDetailProxy:getEnterTeamDetailType() or 1    -- 1=战斗，2=挂机
    self:updateFightBtnText(self._enterType)    -- 更新挑战按钮文字
    self:setBattleStateVisible(self._enterType)    -- 是否显示跳过战斗按钮
    self:updateRepairDot()    -- 更新治疗小红点

    self:setWithoutHeroText(self._isWithoutHero)

    self._maxFightBtn:setVisible(true)    -- 默认显示 最大战力
    self._maxWeightBtn:setVisible(false)    --

    self._soliderProxy:setMaxFighAndWeight()

    self._data = data
    self._type = type or self._type

    self:onRoleInfoChange()    -- 刷新个槽位开启,需要加入随时更新监听
    self:onUpDateSoliderList(data)

    -- 更新怪物相关信息
    local isConfigData = rawget(self._extra, "isConfigData")
    if isConfigData == false then
        self:updateEnemyInfo(data)              
    else
        self:updateCityInfo(data)
    end
    self:setFirstNumber()
    -- self:setSolidertime()                        --刷新行军时间，todo:世界跳转过来的时候 需要从新计算时间
    -- self:setCurrFight()
    
    if GuideManager:isStartGuide() ~= true then  --新手引导不走pve逻辑
        self:updatePveTeamPos(self._type)
    end    
end


function UITeamDetailPanel:onUpDateSoliderList(Data)
    local isOwer
    -- if self._type == 5 or self._type == 8 then  --副本攻打 挂机
    --     self:onEventCity() 
    -- else--部队详情
    -- end

    self:onEventCity() 

    if not isOwer then
        self:onShowConsuImg(nil)
        self:setSoliderList(nil) 
    end
end

-- function UITeamDetailPanel:onShowBtnAndLabel() --根据type的不同 ，各个btn和label的显隐性设置
--     self._sleepBtn.hide = false
--     self._fightBtn.hide = false

--     for _,v in pairs(self._btnMap) do
--         if v.hide == true then
--             v:setVisible(false)
--         else
--             v:setVisible(true)
--         end
--     end
-- end

-- 更新按钮文字
function UITeamDetailPanel:updateFightBtnText(type)
    type = type or 1
    local strNo = 124
    if type == nil then
    elseif type == 1 then
        strNo = 124
    elseif type == 2 then
        strNo = 125
    end
    self._fightBtn:setTitleText(TextWords:getTextWord(strNo))
end

function UITeamDetailPanel:setBattleStateVisible(type)
    type = type or 1
    local isShow
    if type == 1 then
        isShow = true
    elseif type == 2  then
        isShow = false
    end
    self.battleState:setVisible(isShow)
    self.touchPanel:setVisible(isShow)
end


function UITeamDetailPanel:setFigAndWeiVisible(isShow,noshow)
    self._maxFightBtn:setVisible(isShow)
    self._maxWeightBtn:setVisible(noshow)
end

function UITeamDetailPanel:onTouchFigAndWeiBtnHandle(sender)
    local type = sender ~= nil and sender.type or 1  --点击最大战力或者载重的状态，默认最大战力
    self:setSoliderList(nil)
--    self._soliderProxy:soldierMaxFightChange()
    --这里需要拿一下最大战力的军师id跟self._consuId比较一下   不一样就需要重算最大战力
    local newAdviserId = self._consiProxy:getMaxConsuId()
    if self._consuId ~= newAdviserId then
        -- print("最大战力的军师id跟self._consuId,不一样就需要重算最大战力")
        self._soliderProxy:soldierMaxFightChange()
    end

    self._soliderProxy:setMaxFighAndWeight()
    local data 
    if type == 1 then
        data = self._soliderProxy:getMaxFight()   --获取最大战力
        self:setFigAndWeiVisible(false,true)
    else
        data = self._soliderProxy:getMaxWeight()  --获取最大载重
        self:setFigAndWeiVisible(true,false)
    end
    local consuId = self._consiProxy:getMaxConsuId()  --获取战力最大的军师
    --todo   暂时屏蔽军师功能
    -- consuId = nil
    self:onShowConsuImgById(consuId)
    
    if table.size(data) == 0 then
        self._parent:showSysMessage(TextWords[7079])
        return
    end
    self:setSoliderList(data) -- 最大阵容
end

function UITeamDetailPanel:updateCityInfo(data)
    -- local chapter = data._info.chapter
    -- -- 跳过战斗按钮
    --西域、鲜卑、匈奴公用type 2    需要用chapter字段来区分   
    local isAuto
    if self._type == 2 then
        local type ,dunId = self._dungeonProxy:getCurrType()
        local info = ConfigDataManager:getInfoFindByOneKey("AdventureConfig","ID",dunId)
        isAuto = LocalDBManager:getValueForKey(GameConfig.isAutoBattle .. self._type .. info.type)
    else
        isAuto = LocalDBManager:getValueForKey(GameConfig.isAutoBattle .. self._type)
    end
    self.battleState:setSelectedState(isAuto == "yes")

    -- local info = rawget(data,"_info")
    -- local monstergroup = rawget(info,"monstergroup")
    -- logger:error("... 测试 怪物组 monstergroup...%d", monstergroup)
    -- logger:error("... 测试 ...%s", debug.traceback())


    -- 怪物组配表数据
    local monsterGroupConfig = ConfigDataManager:getInfoFindByOneKey("MonsterGroupConfig","ID",data._info.monstergroup)
    
    local star = rawget(data,"star")

    local legionMonsterNum = 0  --统计军团副本的兵总数 ，<=0 则显示配表数量
    if self._type == GameConfig.battleType.legion then  --军团副本校验怪物数量变化
        if self._legionMonsterInfos ~= nil then
            local isDifferent = false
            for k,newInfo in pairs(data.monsterInfos) do
                legionMonsterNum = legionMonsterNum + newInfo.num                    
                
                local oldInfo = nil
                for _,info in pairs(self._legionMonsterInfos) do
                    if info.post == newInfo.post then
                        oldInfo = info
                    end
                end

                if oldInfo then
                    if newInfo.num ~= oldInfo.num 
                        or newInfo.id ~= oldInfo.id
                        or newInfo.post ~= oldInfo.post then
                        isDifferent = true
                    end
                end
            end

            if isDifferent == false then
                -- print("... 怪物数量没有变化，不刷新怪物")
                return
            end

        else
            for k,v in pairs(data.monsterInfos) do
                legionMonsterNum = legionMonsterNum + v.num
            end
        end
        self._legionMonsterInfos = data.monsterInfos


        -- print("... 统计军团副本的兵总数 legionMonsterNum",legionMonsterNum)

    elseif self._monsterGroupConfig == monsterGroupConfig and self._fightBtn.star == star then
        -- print("... 应该不是军团副本type 怪物组没有变化，不刷新怪物",self._type)
        return
    end

    -- 挂机按钮    
    self._fightBtn.star = star
    self._fightBtn.data = data

        
    -- 星星，战损，挂机 (默认都显示)
    local isShowStar = rawget(self._extra,"isShowStar")
    local isShowLost = rawget(self._extra,"isShowLost")
    local isShowSleep = rawget(self._extra,"isShowSleep")
    if isShowStar == nil then
        isShowStar = true
    end
    if isShowLost == nil then
        isShowLost = true
    end
    if isShowSleep == nil then
        isShowSleep = true
    end
    isShowStar = false  --当前版本隐藏星星
    self:showStarByCount(isShowStar, star)
    self:showLostInfo(isShowLost,0) --战损暂时显示0%


    self._monsterGroupConfig = monsterGroupConfig

    
    local function updateTeamR(movePanel)
        -- 敌方佣兵坑位显示更新
        local team = nil
        for index = 1,6 do
            team = movePanel:getChildByName("imgPos"..index)
            team:setTouchEnabled(false)
            team:setScale(GlobalConfig.UITeamDetailScale)
            self:setSoldierScale( team, "right" )

            if team.isSetImg == nil then
                team.isSetImg = true
                ComponentUtils:updateSoliderPosImg(team, 2)
            end

            local value = monsterGroupConfig["position"..index]
            value = StringUtils:jsonDecode(value)
            if table.size(value) == 0 then
                -- print("木有佣兵数据啦??：：index=",index)
                ComponentUtils:updateSoliderPos(team, nil, nil, nil, index, true)
            else
                -- print("有佣兵数据啦：：index=",index)
                local info = ConfigDataManager:getInfoFindByOneKey("MonsterConfig","ID",value[1])
                local _modeId = info.model
                
                local num = value[2]
                if self._type == GameConfig.battleType.legion and legionMonsterNum > 0 then  --军团副本要显示剩余数量
                    for k,v in pairs(data.monsterInfos) do
                        if v.post == index then
                            num = v.num
                            -- print("...  显示的num",v.post,v.num)
                        end
                    end
                end

                ComponentUtils:updateSoliderPos(team, _modeId, num, -1, nil, true)
            end

            local suoImg = team:getChildByName("suoImg")
            suoImg:setVisible(false)
            self:setTeamSelectStatusByTeam(team,false)
        end
    end
    
   
    -- 敌方佣兵坑位
    if self._movePanelR == nil then
        -- print("第一次加载...")
        local newTeam = nil
        self._movePanelR = self._uiSkin:getChildByName("movePanelRR")

        NodeUtils:adaptive(self._movePanelR)
        for index=1,6 do
            local imgPos = self._movePanelR:getChildByName("imgPos1"..index)
            local x,y = imgPos:getPosition()
            imgPos:setVisible(false)

            newTeam = self._commonImgPanel:clone()
            newTeam:setVisible(true)
            newTeam:setPosition(x,y)
            newTeam:setName("imgPos"..index)
            self._movePanelR:addChild(newTeam)
        end
    end
    updateTeamR(self._movePanelR)

    self:updateTopPanel( data, self._panelR )
    
end

function UITeamDetailPanel:updateEnemyInfo(data)

    local isAuto = LocalDBManager:getValueForKey(GameConfig.isAutoBattle .. self._type)
    self.battleState:setSelectedState(isAuto == "yes")

    -- 怪物组配表数据
    self._monsterGroupConfig = ConfigDataManager:getInfoFindByOneKey("MonsterGroupConfig", "ID", data._info.monsterGroupId)

    local star = rawget(data, "star")
    if self._monsterGroupConfig == monsterGroupConfig and self._fightBtn.star == star then
        return
    end

    -- 挂机按钮
    self._fightBtn.star = star
    self._fightBtn.data = data


    -- 星星，战损，挂机 (默认都显示)
    local isShowStar = rawget(self._extra, "isShowStar")
    local isShowLost = rawget(self._extra, "isShowLost")
    local isShowSleep = rawget(self._extra, "isShowSleep")
    if isShowStar == nil then
        isShowStar = true
    end
    if isShowLost == nil then
        isShowLost = true
    end
    if isShowSleep == nil then
        isShowSleep = true
    end
    isShowStar = false
    -- 当前版本隐藏星星
    self:showStarByCount(isShowStar, star)   
    -- 战损暂时显示0%
    self:showLostInfo(isShowLost, 0)


    


    local function updateTeamR(movePanel, posInfos)
        -- 敌方佣兵坑位显示更新
        local team = nil
        for index = 1, 6 do
            team = movePanel:getChildByName("imgPos" .. index)
            team:setTouchEnabled(false)
            team:setScale(GlobalConfig.UITeamDetailScale)
            self:setSoldierScale(team, "right")

            if team.isSetImg == nil then
                team.isSetImg = true
                ComponentUtils:updateSoliderPosImg(team, 2)
            end

            --注意，坑位无论有没有怪，服务端都发这个数据(叛军模块注，以后其他模块得注意)
            local value = posInfos[index]
            local monsterCfg = ConfigDataManager:getInfoFindByOneKey("MonsterConfig", "ID", value.typeid)
            if monsterCfg == nil then
                -- print("木有叛军数据啦??：：index=",index)
                ComponentUtils:updateSoliderPos(team, nil, nil, nil, index, true)
            else
                -- print("有叛军数据啦：：index=",index)
                ComponentUtils:updateSoliderPos(team, monsterCfg.model, value.num, -1, nil, true)
            end

            local suoImg = team:getChildByName("suoImg")
            suoImg:setVisible(false)
            self:setTeamSelectStatusByTeam(team, false)
        end
    end

    local posInfos = data._info.posInfos

    -- 敌方佣兵坑位
    if self._movePanelR == nil then
        -- print("第一次加载...")
        local newTeam = nil
        self._movePanelR = self._uiSkin:getChildByName("movePanelRR")
        NodeUtils:adaptive(self._movePanelR)
        for index = 1, 6 do
            local imgPos = self._movePanelR:getChildByName("imgPos1" .. index)
            local x, y = imgPos:getPosition()
            imgPos:setVisible(false)

            newTeam = self._commonImgPanel:clone()
            newTeam:setVisible(true)
            newTeam:setPosition(x, y)
            newTeam:setName("imgPos" .. index)
            self._movePanelR:addChild(newTeam)
        end
    end

    
    

    updateTeamR(self._movePanelR, posInfos)

    self:updateTopPanel(data, self._panelR)

end

function UITeamDetailPanel:setMarchTime(data)
    local panelInfo = self._panelR:getChildByName("panelInfo")
    local labTime = panelInfo:getChildByName("labTime")
    local marchTime = TimeUtils:getStandardFormatTimeString8(data.time)
    labTime:setString(marchTime)
end

function UITeamDetailPanel:setSoldierScale( team, direct )
    -- body
    local dot = team:getChildByName("dot")
    if dot then
        dot:setScale(GlobalConfig.UITeamDetailSoldierScale)
        if direct == "right" then
            dot:setFlippedX(true)
        end
    end
end

--设置敌方战力显示
function UITeamDetailPanel:setCurrFightR(data)  
    local fightTxt = self._panelR:getChildByName("fightTxt")
    local fightImg = self._panelR:getChildByName("fightImg")
    --fightTxt:setVisible(false)
    --fightImg:setVisible(false)

    local force
    if self._type == GameConfig.battleType.legion then
        force = rawget(data,"force") or 0
        -- if force == nil or force == 0 then
            -- print("... 军团副本 force 是否有问题",force)
        --     force = self._monsterGroupConfig.force
        -- end
    else
        if data._info.fight then
            force = data._info.fight
        else
            force = self._monsterGroupConfig.force
        end
    end
    self.enemyFight = force
    --force = StringUtils:formatNumberByK3(force)

    
    fightTxt:setString(StringUtils:formatNumberByK3(force))
    --self:setCurRichInfo(1,force,2)
end

function UITeamDetailPanel:updateTopPanel(data, panel)

    self:setCurrFightR(data)
    self:setFirstNumberR(self._monsterGroupConfig.firstnum)

    self:updateWarBookRight()

    local num = 0
    local isConfigData = rawget(self._extra, "isConfigData")
    if isConfigData == false then
        for k, v in pairs(data._info.posInfos) do
            num = num + v.num
        end
    else
        num = self._monsterGroupConfig.num
    end

    self:setTeamNumberR(num)
    -- self:setCurRichInfo(4,nil,2)
end



-- 设置先手值显示
function UITeamDetailPanel:setFirstNumberR(number)
    number = number or 0
    --self:setCurRichInfo(2,number,2)
    local labFirstATK = self._panelR:getChildByName("labFirstATK_txt")
    labFirstATK:setString(number)
end

-- 设置部队数显示
function UITeamDetailPanel:setTeamNumberR(number)
    number = number or 0
    --self:setCurRichInfo(3,number,2)
    local labFirstTeam = self._panelR:getChildByName("labFirstTeam_txt")
    labFirstTeam:setString(number)
end

-- 关卡星星
function UITeamDetailPanel:showStarByCount(isShow, count)
    local starPanel = self._middlePanel:getChildByName("starPanel")
    if isShow ~= true or count == nil then
        starPanel:setVisible(false)
        return
    else
        starPanel:setVisible(true)
        local _index = 0
        for i = 1,count do
            local starBg = starPanel:getChildByName("starBg"..i)
            local star = starBg:getChildByName("starImg")
            star:setVisible(true)
        end
        for i = count + 1 ,3 do
            local starBg = starPanel:getChildByName("starBg"..i)
            local star = starBg:getChildByName("starImg")
            star:setVisible(false)
        end
    end
end

-- 计算战损：根据战斗类型读表
function UITeamDetailPanel:calFightLost()
    local type = self._sendType
    if type == nil or self._type == 9 then  
        type = self._type
    end
    -- 如果传进来的是叛军类型14，让type == 14
    if self._type == 14 then
        type = self._type
    end

    local lost = 0 -- 减益数据
    local lostOrRepairType = 1 -- 默认损兵1，伤兵2 


    local dungeonType ,dunId = self._dungeonProxy:getCurrType()
    local cityId = self._dungeonProxy:getCurrCityType()
    -- print("副本onEventCity: dungeonType,cityId,dunId = ",dungeonType,cityId,dunId)

    local info,cityInfo = {}, {}
    if dungeonType == 1 and dunId then  --征战
        info = ConfigDataManager:getInfoFindByOneKey("ChapterConfig","ID",dunId)
    elseif dungeonType == 2 and dunId then  --冒险
        info = ConfigDataManager:getInfoFindByOneKey("AdventureConfig","ID",dunId)
    else
        info = ConfigDataManager:getInfoFindByTwoKey("FightControlConfig", "fighttype", type, "subtype", self._subBattleType)
    end

    -- local info = ConfigDataManager:getInfoFindByTwoKey("FightControlConfig", "fighttype", type, "subtype", self._subBattleType)
    if info then
        if info.lostShow > 0 then
            lost = info.lostShow / 100.0
            lostOrRepairType = 1 -- 损兵
        elseif info.repairShow > 0 then 
            lost = info.repairShow / 100.0
            lostOrRepairType = 2 -- 伤兵
        end
    end
    -- print("........................................计算战损 ",type,self._type,self._subBattleType,lost,lostOrRepairType)
    return lost, lostOrRepairType
end

-- 显示战损
function UITeamDetailPanel:showLostInfo( isShow, count )
    local lostOrRepairType 
    count, lostOrRepairType = self:calFightLost()

    local looseBgImg = self._middlePanel:getChildByName("looseBgImg")
    local looseImg   = looseBgImg:getChildByName("labLoose")

--    if looseBgImg.effect == nil then
--        looseBgImg.effect = UICCBLayer.new("rgb-zhansun", looseBgImg)
--        local size = looseBgImg:getContentSize()
--        looseBgImg.effect:setPosition(size.width/2, size.height/2)
--    end

    -- 更换图标
    if lostOrRepairType == 1 then
        looseImg:setString(TextWords:getTextWord(625))  --损兵
    elseif lostOrRepairType == 2 then
        looseImg:setString(TextWords:getTextWord(626))  --伤兵
    end

    if looseBgImg then
        looseBgImg:setVisible(isShow)
        local looseTxt = looseBgImg:getChildByName("looseTxt")
        if looseTxt then
            count = count or 0
            looseTxt:setString(count.."%")
            if count == 0 then
                looseTxt:setColor(ColorUtils.wordGreenColor)
            else
                looseTxt:setColor(ColorUtils.wordRedColor)
            end
        end
    end
end

function UITeamDetailPanel:onBattleStateTouch(sender)
    local currentState = self.battleState:getSelectedState()

    
    local saveValue = currentState and "no" or "yes"
    self.battleState:setSelectedState(not currentState)
    local key
    if self._type == 2 then
        local type ,dunId = self._dungeonProxy:getCurrType()
        local info = ConfigDataManager:getInfoFindByOneKey("AdventureConfig","ID",dunId)
        key = self._type .. info.type
    else
        key = self._type
    end

    LocalDBManager:setValueForKey(GameConfig.isAutoBattle..key, saveValue)

    self._battleProxy:setIsAutoBattle(saveValue == "yes")
end

-- 判定出战按钮OR挂机按钮是否满足触发条件，FightPosMap=上阵数据
function UITeamDetailPanel:isCanDo()
    --currentType:1征战 2探险 3军团副本
    -- dungeoId:
    -- 1=匈奴
    -- 2=鲜卑
    -- 3=南越
    -- 4=西域

    local currentType,dungeoId = self._dungeonProxy:getCurrType()  
    -- print("判定出战按钮 self._type,currentType,dungeoId",self._type,currentType,dungeoId)

    if self._type == 9 or self._type == 14 then

        -- 废墟状态不可以派部队出城
        local isDestroy,_ = self._roleProxy:getBoomState()
        if isDestroy == true then
            self._parent:showSysMessage(TextWords:getTextWord(371))
            return false
        end

        -- 讨伐令不足，不可以挑战
        if self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_crusadeEnergy) <= 0 then  --讨伐令
            self._roleProxy:getBuyCrusadeEnergyBox(self, nil, nil, true)  --弹窗购买讨伐令
            return false
        else
            if self._type == 14 then
                -- 粮食不足，不可以出战
                local _,needNum = self:getWorldNeedRes()
                local haveNum = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_food)
                if haveNum < needNum then
                    self._parent:showSysMessage(TextWords:getTextWord(341))
                    return false
                end
            end
            return true
        end   
    end


    if currentType then
        if currentType == 1 then
            -- 体力不足，不可以挂机
            if self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_energy) <= 0 then  --体力值
                self._roleProxy:getBuyEnergyBox(self, nil, nil, true)
                return false
            else
                return true
            end    
        elseif currentType == 2 then
            if dungeoId ~= 4 then --1=匈奴,2=鲜卑,3=南越
                -- 挑战次数不足，不可以挂机
                local currentTimes =  self._dungeonProxy:getCurrentTimes()
                if currentTimes <= 0 then
                    self._teamDetailProxy:buyChallengeTimes(1)  --购买成功，执行回调onSleepBtnHandle
                    return false
                end
            end
        end
    end

    


    return true
end

-- 计算粮食消耗
function UITeamDetailPanel:getWorldNeedRes( ... )
    -- body
    local totalNeed = 0
    
    local infos = self:checkFightPosMap()
    if infos then
        local info
        for k,posInfo in pairs(infos) do
        -- {post = pos,typeid = id,num = num}
            if posInfo.post ~= self._consuId and posInfo.post ~= 9 then
                -- print("消耗粮食的佣兵 post,typeid,num = ",posInfo.post,posInfo.typeid,posInfo.num)
                info = ConfigDataManager:getInfoFindByOneKey("ArmKindsConfig","ID",posInfo.typeid)
                totalNeed = totalNeed + info.worldneed * posInfo.num
            end
        end
    end

    local totalNeedStr = StringUtils:formatNumberByK(totalNeed)

    return totalNeedStr, totalNeed
end


function UITeamDetailPanel:onTouchFightBtnHandle(sender) --出战按钮
     --检测英雄数量是否已满
    local currentType,dungeoId = self._dungeonProxy:getCurrType() 
    -- logger:info("出战按钮 %d %d",currentType,dungeoId)
    
    if currentType == 1 then
        local heroProxy = self:getProxy(GameProxys.Hero)
        local heroNum = heroProxy:getAllHeroNum()
        if heroNum >= GameConfig.Hero.MaxNum then
            local function okcallbk()
                ModuleJumpManager:jump(ModuleName.HeroHallModule)
                TimerManager:addOnce(100, function()
                    self._dungeonProxy:sendNotification(AppEvent.PROXY_COLSE_EVENT)
                end, self)
            end
            local str = TextWords:getTextWord(290063)
            self._parent:showMessageBox(str,okcallbk)
            return
        end
    elseif currentType == 2 then 
        if dungeoId == 1 or dungeoId == 4 then 
            local heroProxy = self:getProxy(GameProxys.Hero)
            local heroNum = heroProxy:getAllHeroNum()
            if heroNum >= GameConfig.Hero.MaxNum then 
                local function okcallbk()
                    ModuleJumpManager:jump(ModuleName.HeroHallModule)
                    TimerManager:addOnce(100, function()
                        self._dungeonProxy:sendNotification(AppEvent.PROXY_COLSE_EVENT)
                    end, self)
                end
                local str = TextWords:getTextWord(290063)
                self._parent:showMessageBox(str,okcallbk)
                return
            end
        end
    end

    
    local fightPosMap = self:checkFightPosMap()
    if fightPosMap ~= nil then
        if self:isCanDo(fightPosMap) == true then
            AudioManager:playEffect("yx03") -- 可出战才能播放音效
            local data = {}
            data.type = self._sendType
            data.id = self._cityId
            data.infos = fightPosMap

            -- 出战更新pve阵型
            local soldierProxy = self:getProxy(GameProxys.Soldier)
            soldierProxy:onFightUpdatePveTeam(data)

            if self._callBack == nil then
                self:onGoFightHandler(data)
            else
                self._callBack(self._parent)
            end
        end
    end

end

function UITeamDetailPanel:onGoFightHandler(data)  --出战
    self._teamDetailProxy:setSendData(data)
    self._teamDetailProxy:setCurPanel(self._parent)

    if data.type == GameConfig.battleType.legion then  --军团副本：已在军团副本模块询问过了
        --print("军团副本-出战-不用再次询问")
        local sendData = {}
        sendData.id = data.id
        self._teamDetailProxy:onTriggerNet270001Req(sendData)
        return
    end

    -- 非军团副本：询问完毕在teamDetailProxy代理处理是否出战
    local serverData = {}
    serverData.battleType = data.type
    serverData.evendId = data.id
    -- print("出战前询问 battleType,evendId", serverData.battleType, serverData.evendId)
    self._teamDetailProxy:onTriggerNet60002Req(serverData)
end


function UITeamDetailPanel:onTouchSqureBtnHandle(sender)
    -- self:setSoliderList(nil) --首先清除一下全部的
    -- self:onCheckConsuData(self._soliderProxy:onGetTeamInfo()[1].members)  --加上军师信息,直接拿套用阵型数据
        
    -- local data = clone(self._fightPosMap)
    -- local info = TableUtils:map2list(data)
    -- if self._consuId then  --军师加进去
    --     table.insert(info, {typeid = self._consuId, num = 1, post = 9})
    -- end

    local info = self:checkFightPosMap(true)

    if self._uiSetTeamPanel == nil then
        self._uiSetTeamPanel = UISetTeamPanel.new(self._parent, info)
    else
        self._uiSetTeamPanel:show(info)
    end
end

function UITeamDetailPanel:showMsgBox()
end

function UITeamDetailPanel:checkSqureIsNull(srcData)  --判定套用阵型是否为空
    local isNull = false
    
    local data = {}
    for _, info in pairs(srcData) do
        if info.typeid > 0 and info.num > 0 then
            table.insert(data, info)
        end 
    end

    if self._consuId then  --军师加进去
        table.insert(data, {typeid = self._consuId,num = 1,post = 9})
    end
    if #data == 0 then
        isNull = true  --木有可套用的阵型
        -- return
    end
    return isNull
end

function UITeamDetailPanel:onHisBtnHandle()
    self._roleProxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.ArenaMailModule})
end

function UITeamDetailPanel:onEventCity()         --副本
   

    local panelInfo = self._panelR:getChildByName("panelInfo")    
    local isConfigData = rawget(self._extra, "isConfigData")
    if isConfigData == false then
        local targetName = rawget(self._extra, "targetName")
       
        -- 隐蔽掉
        --panelInfo:setVisible(true)
        panelInfo:setVisible(false)

        local labTarget = panelInfo:getChildByName("labTarget")
        local labTime = panelInfo:getChildByName("labTime")
        labTarget:setString(targetName)

    else
        local type ,dunId = self._dungeonProxy:getCurrType()
        local cityId = self._dungeonProxy:getCurrCityType()
        -- print("副本onEventCity: type,cityId,dunId = ",type,cityId,dunId)

        self._sendType = type or cityId
        self._cityId = cityId

        panelInfo:setVisible(false)
        --[[暂时屏蔽行军目标显示    
        local name = ""
        local targetName = rawget(self._extra,"targetName")
        if targetName ~= nil then
            -- 自定义行军目标 如：世界地图剿匪
            name = targetName
        else
            local info,cityInfo = {}, {}
            if type == 1 then  --征战
                info = ConfigDataManager:getInfoFindByOneKey("ChapterConfig","ID",dunId)
                cityInfo = ConfigDataManager:getInfoFindByOneKey("EventConfig","ID",cityId)
            elseif type == 2 then  --冒险
                info = ConfigDataManager:getInfoFindByOneKey("AdventureConfig","ID",dunId)
                cityInfo = ConfigDataManager:getInfoFindByOneKey("AdventureEventConfig","ID",cityId)
            elseif type == 6 then  --军团副本
                info = ConfigDataManager:getInfoFindByOneKey("LegionCapterConfig","ID",dunId)
                cityInfo = ConfigDataManager:getInfoFindByOneKey("LegionEventConfig","ID",cityId)
            end

            if cityInfo ~= nil then
                name = cityInfo.name    
            end
        end

        self:setTargetCity(name)  --暂时屏蔽行军目标显示
        ]]
    end
end

function UITeamDetailPanel:isVisible()
    -- body
    return self._uiSkin:isVisible()
end

-- 购买次数返回、是否弹框元宝不足
function UITeamDetailPanel:onBuyTimesResp(data)
    -- rs=2 元宝不足
    if data.rs ~= 0 and data.rs ~= 2 then
        return 
    end

    if self._parent:isVisible() ~= true then
        -- print("UITeamDetailPanel 没显示 ")
        return
    end

    local sender = self._fightBtn
    local function callbk()
        function callreq1()
            local function callFunc()
                self._teamDetailProxy:buyChallengeTimes(2)
            end
            sender.callFunc = callFunc
            sender.money = data.money
            self:isShowRechargeUI(sender,data.dungeoId)
        end

        if data.dungeoId ~= 4 then
            self._parent:showMessageBox(TextWords:getTextWord(200105)..data.money..TextWords:getTextWord(200106),callreq1)
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
        forxy:setCurrentTimes(data.advanceTimes)

        self._parent:showSysMessage(TextWords:getTextWord(541))
    end
end

function UITeamDetailPanel:isShowRechargeUI(sender,dungeoId)
    local needMoney = sender.money
    local roleProxy = self:getProxy(GameProxys.Role)
    local haveGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝

    if needMoney > haveGold then
        local parent = self:getParent()
        local panel = parent.panel
        if panel == nil then
            local panel = UIRecharge.new(parent, self._parent)
            parent.panel = panel
        else
            panel:show()
        end
    else
        sender.callFunc()
    end

end

-- 挂机按钮响应
function UITeamDetailPanel:onSleepBtnHandle(star)
    if star == nil or star < 3 then
        self._parent:showSysMessage(TextWords:getTextWord(200100))  --三星副本才可以挂机
        return
    end
    
    local data = self:checkFightPosMap()
    if data ~= nil then
        -- local currentType,_ = self._dungeonProxy:getCurrType()  --1征战 2探险 3军团副本
        -- if currentType then
        --     if currentType == 1 then
        --         -- 体力不足，不可以挂机
        --         if self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_energy) <= 0 then  --体力值
        --             self._roleProxy:getBuyEnergyBox()
        --             return
        --         end    
        --     else
        --         -- 次数不足，不可以挂机
        --         local currentTimes =  self._dungeonProxy:getCurrentTimes()
        --         if currentTimes <= 0 then
        --             self._teamDetailProxy:buyChallengeTimes(1) 
        --             return
        --         end
        --     end
        -- end

        if self:isCanDo() == true then      
            -- 有伤兵，不可以挂机
            if table.size(self._soliderProxy:getBadSoldiersList()) > 0 then 
                local function okCallback()
                    ModuleJumpManager:jump(ModuleName.TeamModule,"TeamReparePanel")
                end
                self._parent:showMessageBox(TextWords[7075],okCallback)
                return
            end

            -- 请求挂机
            if self._sleepPanel == nil then
                self._sleepPanel = UITeamSleepPanel.new(self,self._parent)
                self._teamDetailProxy:setSleepPanel(self._sleepPanel)
            end
            self._sleepPanel:startSend(self._sendType,self._cityId,data)
        end

    end
end

function UITeamDetailPanel:onBtnTouchHandle(sender)
    if sender == self._maxFightBtn or sender == self._maxWeightBtn then --最大战力/最大负重
        self:onTouchFigAndWeiBtnHandle(sender)
    elseif sender == self._fightBtn then        --点击出战
        if self._enterType == 1 then
            self:onTouchFightBtnHandle()        --挑战
        elseif self._enterType == 2 then    
            self:onSleepBtnHandle(sender.star)  --挂机
        end
    elseif sender == self._squreBtn then          --点击套用阵型按钮
        self:onTouchSqureBtnHandle()
    elseif sender == self._heroBtn then           --点击显示武将
        self:onHeroBtnTouch(sender)
    elseif sender == self._repairBtn then         --点击治疗伤兵
        self:onRepairBtnTouch(sender)
    end
end

-- 点击显示武将
function UITeamDetailPanel:onHeroBtnTouch(sender)
    if self._heroBtnType == 1 and self._isWithoutHero then
        self._parent:showSysMessage(TextWords:getTextWord(618))
        return
    end

    if self._heroBtnType == 1 then
        self._heroBtnType = 2
    elseif self._heroBtnType == 2 then
        self._heroBtnType = 1
    end
    
    local infoImg = self._heroBtn:getChildByName("info")
    TextureManager:updateImageView(infoImg,"images/newGui2/Txt_img"..self._heroBtnType..".png")


    for _, info in pairs(self._fightPosMap) do
        if info.typeid > 0 and info.num > 0 then
            local name,color = self:getSoliderPosCount(info.num, info.post, self._heroBtnType, self._isWithoutHero)
            local team = self:getTeamByPos(info.post)
            ComponentUtils:updateSoliderPosCount(team, name, color)
        end
    end

end

function UITeamDetailPanel:getSoliderPosCount(num, pos, heroBtnType, isWithoutHero)
    local color
    local curNum = num
    if heroBtnType == 2 then -- 需要显示武将
        if isWithoutHero then
            curNum = TextWords:getTextWord(127)
	        color  = ColorUtils.wordWhiteColor
        else
            curNum, color = self._heroProxy:getHeroNameByPos(pos)
        end
    end
    return curNum,color
end

-- 点击治疗伤兵
function UITeamDetailPanel:onRepairBtnTouch(sender)
    local dotNum = table.size(self._soliderProxy:getBadSoldiersList()) or 0
    if dotNum < 1 then
        self._parent:showSysMessage(TextWords:getTextWord(126))
    else
       ModuleJumpManager:jump(ModuleName.TeamModule,"TeamReparePanel") 
    end
end

-- 更新治疗小红点
function UITeamDetailPanel:updateRepairDot()
    local dotNum = table.size(self._soliderProxy:getBadSoldiersList()) or 0
    if dotNum < 1 then
        self._repairDotBg:setVisible(false)
    else
        self._repairDotBg:setVisible(true)
        self._repairDot:setString(dotNum)
    end
end


function UITeamDetailPanel:setSoliderList(data)
    self._setTeamData = data
    if data == nil then
        for index = 1 ,6 do
            -- print("空阵型...",index)
            self:setPuppetById(index,0,0, false)
        end
        self._fightPosMap = {}
    else
        local len = table.size(data)
        if len ~= 0 then
            NodeUtils:addSwallow()
        end
        
        local posMaxCommandCount = self:getEveryPosMaxCommand() -- 可能不是最大的
        for _,v in pairs(data) do
            -- 武将屏蔽时过滤超过的带兵量
            local soldierNum = v.num
            if self._isWithoutHero then
                if soldierNum > posMaxCommandCount then
                    soldierNum = posMaxCommandCount
                end
            end  
            self:setPuppetById(v.post,v.typeid, soldierNum, false)
        end
        
        local coolTime = len*0.2
        coolTime = coolTime > 0.6 and 0.6 or coolTime
        TimerManager:addOnce(coolTime*1000, function()
            NodeUtils:removeSwallow()
        end, self)
    end

    if self._type ~= nil then
        self:setfightPosMap()  --优化，放到外面来处理，这个方法很消耗，也没有必要在每次setPuppetById都去设置
    end
end

-- 我方坑位佣兵
--isCalFightPosMap 是否重算战力，默认计算，只有重新刷新不算，由外部计算
function UITeamDetailPanel:setPuppetById(pos,id,num, isCalFightPosMap)
    if pos == 9 or pos == 19 then
        -- local team = self:getTeamByPos(pos)
        -- team:setScale(GlobalConfig.UITeamDetailScale)
        return
    end
    local team = self:getTeamByPos(pos)
    team:setScale(GlobalConfig.UITeamDetailScale)
    self:setSoldierScale( team, "left" )
    
    local isAction = num > 0
    local function delayUpdateSoliderPos()
        ComponentUtils:updateSoliderPos(team, id, num, nil, nil, true, nil, isAction)
        if self._heroBtnType == 2 then
            local name,color = self:getSoliderPosCount(num, pos, self._heroBtnType, self._isWithoutHero)
            ComponentUtils:updateSoliderPosCount(team, name, color)
        end
    end

    if isAction then
        TimerManager:addOnce(pos * 80, delayUpdateSoliderPos, {})
    else
        delayUpdateSoliderPos()
    end
    local imgNum = team:getChildByName("imgNum")
    imgNum:setVisible(self._posMap[pos].isOpen)

   
    -- 发生变更时就更新位置表 只设置坑位
    self._fightPosMap[pos] = {post = pos,typeid = id, num = num}
    logger:info("槽位pos："..pos.."  数量num："..num)
    
    -- 更改自身阵型
    self:updateWarBookLeft()

    if isCalFightPosMap ~= false then
        self:setfightPosMap()
    end
end

--更新阵型数据
function UITeamDetailPanel:updateWarBookLeft()
    -- 阵型
    local panelWarBook = self._panelL:getChildByName("panelWarBook")

    -- 叛军
    local isConfigData = rawget(self._extra, "isConfigData")
    if isConfigData == true then
        -- 叛军不显示
        panelWarBook:setVisible(false)
        return
    end

    local uiData = {
        isShowFirstAtkUI = false,
        rootUI = panelWarBook
    }

    local types = { }
    for k, v in pairs(self._fightPosMap) do
        local info = ConfigDataManager:getConfigById(ConfigData.ArmKindsConfig, v.typeid)
        if info then
            table.insert(types, info.type)
        end
    end

    local uiWarBookFight = UIWarBookFight.new(self._parent, uiData,  UIWarBookFight.DirType_Left)
    uiWarBookFight:updateUIBySelfData(types)
end

--更新阵型数据
function UITeamDetailPanel:updateWarBookRight()
    
    -- 阵型
    local panelWarBook = self._panelR:getChildByName("panelWarBook")

    --没有怪物组
    if self._monsterGroupConfig == nil then        
        panelWarBook:setVisible(false)
        return
    end

    -- 怪物组没阵型
    if self._monsterGroupConfig.iswarbook == 0 then
        panelWarBook:setVisible(false)
        return
    end

    -- 叛军
    local isConfigData = rawget(self._extra, "isConfigData")
    if isConfigData == true then
        -- 叛军不显示
        panelWarBook:setVisible(false)
        return
    end
    

    local uiData = {
        isShowFirstAtkUI = false,
        rootUI = panelWarBook
    }
    local updateData = {}    
    local warBookFightCfgData = ConfigDataManager:getConfigById(ConfigData.WarBookFightConfig, self._monsterGroupConfig.iswarbook)
    if warBookFightCfgData then        
        updateData.warBookFightCfgData = warBookFightCfgData        
        updateData.skillLevel = { self._monsterGroupConfig.warbooklv, self._monsterGroupConfig.warbooklv };
    end
    local uiWarBookFight = UIWarBookFight.new(self, uiData, UIWarBookFight.DirType_Right)
    uiWarBookFight:updateUI(updateData)

end

function UITeamDetailPanel:setfightPosMap(fightItem)
    -- self._fightPosMap[fightItem["post"]] = fightItem
     
    self._totalSolsiers = 0 --当前出战的总兵力
    self._currWeight = 0  --当前的载重
    self._currFight = 0   --当前的战力
    local allPos = {}
    for _,v in pairs(self._fightPosMap) do
        if v.typeid > 0 and v.num > 0 then
            local AdviserInfo = self._consiProxy:getInfoById(self._consuId)
            self._totalSolsiers = self._totalSolsiers + v.num
            allPos[v.post] = true
            local fight = self._soliderProxy:getPosAllFight(v, AdviserInfo or {}, self._isWithoutHero)
            self._currFight = self._currFight + fight
            self._currWeight = self._currWeight + self._soliderProxy:getOneSoldierWeightById(v.typeid) * v.num
        end
    end

    --没兵的已经解锁的槽位也要计算军师战力
    for i=1,6 do
        if allPos[i] ~= true and self:getWhichPosEnable(i) then
            local AdviserInfo = self._consiProxy:getInfoById(self._consuId)
            self._currFight = self._currFight + self._soliderProxy:getPosAllFight({num = 0, typeid = 0, post = i}, AdviserInfo or {}, self._isWithoutHero)
        end
    end


    self:setCurrFight()
    self:setSolderCount()
    -- self:setCurrWeight()
end

function UITeamDetailPanel:setCurrFight()  --战力显示
    local fightTxt = self._panelL:getChildByName("fightTxt")
    local fightImg = self._panelL:getChildByName("fightImg")
    fightTxt:setString(StringUtils:formatNumberByK3(self._currFight))
    --fightTxt:setVisible(false)
    --fightImg:setVisible(false)
    --self:setCurRichInfo(1,StringUtils:formatNumberByK3(self._currFight),1)
end

function UITeamDetailPanel:setFirstNumber(addnum) --先手值
    addnum = 0
    -- 军师先手值
    if self._consuId ~= nil and self._consiProxy:getInfoById(self._consuId) ~= nil then
        local configLvData = self._consiProxy:getConfLvById( self._consuId )
        addnum = configLvData.firstnum or 0
    end
    -- 武将+宝具先手值
    local heroTotalFirstNum = 0
    if self._isWithoutHero ~= true then
        heroTotalFirstNum = self._soliderProxy:getTotalFirstnum()
    end
    local number = heroTotalFirstNum + addnum
    local labFirstATK = self._panelL:getChildByName("labFirstATK_txt")
    labFirstATK:setString(number)
    --self:setCurRichInfo(2, number, 1)
end

function UITeamDetailPanel:setTargetCity( name )  --行军目标
    self:setCurRichInfo(1,name,1)
end

function UITeamDetailPanel:setSolidertime(time) --行军时间
    self:setCurRichInfo(2,time,1)
end

function UITeamDetailPanel:setSolderCount()  --带兵数量
    
    local count = self:getEveryPosMaxCommand()

    local str = self._totalSolsiers.."/"..count*self._totalKen
    
    local labFirstTeam = self._panelL:getChildByName("labFirstTeam_txt")
    labFirstTeam:setString(str)
    --self:setCurRichInfo(3,str,1)
end

function UITeamDetailPanel:setCurrWeight()  --部队载重
    self:setCurRichInfo(4,StringUtils:formatNumberByK(self._currWeight),1)
end

-- dir=1 自己（默认），dir=2 敌人
function UITeamDetailPanel:setCurRichInfo(strType,str,dir)  --富文本 可动态显示0~4行内容
    dir = dir or 1
    local curRichTxt,richInfoLab,panel
    local tmpTab = {}
    local textNo = strType + 7041
    local fontSize = 20
    local color1 = "#FFFFFF"
    local color2 = "#FFBD30"
    if dir == 1 then
        curRichTxt = self._richInfoTxt
        panel = self._panelL
        richInfoLab = self._panelL.richInfoLab

        if self.txtTab == nil then
            self.txtTab = {}
            self.txtTab[1] = nil
            self.txtTab[2] = nil
            self.txtTab[3] = nil
            self.txtTab[4] = nil
        end
        if strType ~= nil and str ~= nil then
            if strType == 1 then
                if type(self.enemyFight) == "number" then
                    color2 = self.enemyFight > self._currFight and ColorUtils.wordRedColor16 or ColorUtils.wordGreenColor16
                end
            end
            self.txtTab[strType] = {{TextWords:getTextWord(textNo),fontSize,color1},{str,fontSize,color2}}
        elseif str == nil then
            self.txtTab[strType] = nil
        end

        for k,v in pairs(self.txtTab) do
            if type(v) == type(tmpTab) then
                table.insert(tmpTab,v)
            end
        end

    else
        curRichTxt = self._richInfoTxtR
        panel = self._panelR
        richInfoLab = self._panelR.richInfoLab

        if self.txtTabR == nil then
            self.txtTabR = {}
            self.txtTabR[1] = nil
            self.txtTabR[2] = nil
            self.txtTabR[3] = nil
            self.txtTabR[4] = nil
        end
        if strType ~= nil and str ~= nil then
            self.txtTabR[strType] = {{TextWords:getTextWord(textNo),fontSize,color1},{str,fontSize,color2}}
        elseif str == nil then
            self.txtTabR[strType] = nil
        end

        for k,v in pairs(self.txtTabR) do
            if type(v) == type(tmpTab) then
                table.insert(tmpTab,v)
            end
        end
    end

    if richInfoLab == nil then
        richInfoLab = ComponentUtils:createRichLabel("", nil, nil, 2)
        richInfoLab:setPosition(curRichTxt:getPosition())
        panel:addChild(richInfoLab)
        panel.richInfoLab = richInfoLab
    end
    curRichTxt:setString("")
    richInfoLab:setString(tmpTab)

end



function UITeamDetailPanel:getWhichPosEnable(pos)  --根据坑位判断当前的wight是否开放
    return self._posMap[pos].isOpen    
end

function UITeamDetailPanel:addButtonAction()
    if self._btnEffect == nil then
        self._btnEffect = UICCBLayer.new("rpg-button-light", self._maxFightBtn )
        local size = self._maxFightBtn:getContentSize()
        self._btnEffect:setPosition(size.width/2, size.height/2)
    else
        self._btnEffect:setVisible(true)
    end
end

function UITeamDetailPanel:getTeamByPos(pos)
    for i = 1 ,6 do
        local item = self._movePanel:getChildByName("imgPos"..i)
        if item.pos == pos then
            return item
        end
    end  
end

function UITeamDetailPanel:setTeamSuoStatus(pos,isShow,lv)
    local function getItem(pos)
        for i = 1 ,6 do
            local item = self._movePanel:getChildByName("imgPos"..i)
            if item.pos == pos then
                return item
            end
        end
    end

    local item = getItem(pos)
    local suoImg = item:getChildByName("suoImg")
    suoImg:setVisible(isShow)
    local imgNum = item:getChildByName("imgNum")  --数字标签
    if isShow == true then
        local suoLabel = suoImg:getChildByName("suoLabel")
        suoLabel:setString(lv..TextWords[7057])
        imgNum:setVisible(false)
    else
        TextureManager:updateImageView(imgNum, "images/team/" .. item.pos .. ".png")
    end
end

function UITeamDetailPanel:setOpenPosBylevel(level) --根基指挥官等级设置槽位的开放

    local index = 0
    for pos = 1,6 do
        local flag, notOpenInfo = self._soliderProxy:isTroopsOpen(pos)
        if flag then
            self._posMap[pos].isOpen = true
            self:setTeamSuoStatus(pos, false, notOpenInfo)
            index = index + 1
        else
            self._posMap[pos].isOpen = false
            self:setTeamSuoStatus(pos, true, notOpenInfo)
        end

        local item = self._movePanel:getChildByName("imgPos"..pos)
        local imgNum = item:getChildByName("imgNum")        
        local infoImg = item:getChildByName("infoImg")
        if infoImg ~= nil and imgNum ~= nil then
            if infoImg:isVisible() == true then
                flag = false  --坑位有兵，不显示坑位数字
            end
        end
        imgNum:setVisible(flag)

    end

    

    self._totalKen = index
    self:setSolderCount()
    self:onFirstSelect()
end

function UITeamDetailPanel:onFirstSelect()
    for index = 1,6 do
        if self._posMap[index].isOpen == true then
            local item = self:getTeamByPos(index)
            if item ~= self._selectTeam then
                -- if self._selectTeam ~= nil then
                --     self:setTeamSelectStatusByTeam(self._selectTeam,false)
                -- end 
                self._selectTeam = item
                self:setTeamSelectStatusByTeam(item,false)  --??? 应该是初始化第一个坑位显示变亮
            end
            break
        end
    end
end

function UITeamDetailPanel:setTeamSelectStatusByTeam(item,isShow)
    -- local selectImg = item:getChildByName("selectImg")
    -- selectImg:setVisible(isShow)
    ComponentUtils:setTeamSelectStatusByTeam(item,isShow)
end

function UITeamDetailPanel:checkFightPosMap(noShowTips)  --出战前检查数据 防止为空
    local data = {}
    for _, info in pairs(self._fightPosMap) do
        if info.typeid > 0 and info.num > 0 then
            table.insert(data, info)
        end 
    end

    local isHaveSoldier = #data == 0

    if self._consuId and self._consiProxy:getInfoById(self._consuId) ~= nil then  --加上军师
        local ConsuData = self._consiProxy:getInfoById(self._consuId)
        table.insert(data,{typeid = ConsuData.typeId ,post = 9, num = 1, adviserId = self._consuId, adviserLv = ConsuData.lv})
    end
    
    if isHaveSoldier and (not noShowTips) then
        self._parent:showSysMessage(TextWords[747])
        return
    end
    return data
end

function UITeamDetailPanel:onPopTouch(pos)
    local item = self:getTeamByPos(pos)
    if item ~= self._selectTeam then
        if self._selectTeam ~= nil then
            self:setTeamSelectStatusByTeam(self._selectTeam,false)
        else
            self:setTeamSelectStatusByTeam(item,true)
        end 
        self._selectTeam = item
    end
    if item.isShowPuppet == false then
        local serverListData = self._soliderProxy:onShowEveryPosCount(self._fightPosMap)
        if serverListData ~= nil then
            -- local typeId
            local adviserData = self._consiProxy:getInfoById(self._consuId)
            -- if adviserData ~= nil then
            --     typeId = adviserData.typeId
            -- end

            if self._UITeamMessPanel == nil then
                self._UITeamMessPanel = UITeamMessPanel.new(self,serverListData,pos,self.setPuppetById, adviserData, self._isWithoutHero)
            else
                self._UITeamMessPanel:updateData(serverListData, pos, adviserData, self._isWithoutHero)
            end
        end
    else
        -- self:updateSetTeamData(pos, 0, 0)
        self:setPuppetById(pos,0,0) --隐藏pupplt
    end
end

function UITeamDetailPanel:getProxy(name)
    return self._parent:getProxy(name)
end

function UITeamDetailPanel:changeTeamPos(team)
    -- print("changeTeamPos(team) ............")
    if team.isShowPuppet == true then
        self:setPuppetById(team.pos,team.modeId,team.num)
    else
        self:setPuppetById(team.pos,0,0)
    end
    local imgNum = team:getChildByName("imgNum")
        TextureManager:updateImageView(imgNum, "images/team/" .. team.pos .. ".png")
end

-------------------------------------------------------------------------------
-- 军师上阵显示处理 begin
-------------------------------------------------------------------------------
function UITeamDetailPanel:onIsOpenConsu(isShowMsg,customMsg)  --24级开启军师
    local isUnlock = self._roleProxy:isFunctionUnLock(45,isShowMsg,customMsg)
    self:showIsUnlockConsu(isUnlock)
    return isUnlock
end

function UITeamDetailPanel:showIsUnlockConsu(isUnlock)
    -- if isUnlock == false then  
    --     self._consuId = nil
    -- end
    self:onShowConsuSuoImg(not isUnlock)

    local consuData = {}
    consuData.icon = 999
    consuData.infoImgShow = false
    consuData.suoImgShow = not isUnlock
    self:updateConsuPos(consuData)

end

function UITeamDetailPanel:onShowConsuImgById(id)  --显示上阵军师的图片
    local icon = 999
    local name = ""
    local infoImgIsShow,starNo,quality
    if id then
        if self._consiProxy:getInfoById(id) ~= nil then
            self._consuId = id
            local consiData = self._consiProxy:getInfoById(id)
            local typeId = consiData.typeId
            local configData = self._consiProxy:getDataById(typeId)
            infoImgIsShow = configData ~= nil
            starNo = consiData.lv
            if configData ~= nil then
                icon = 0
                name = configData.name
                quality = configData.quality
                infoImgIsShow = true
            end
            self:setFirstNumber() --叠加先手值
        else
            infoImgIsShow = false
            self._consuId = nil
        end
    else
        infoImgIsShow = false
        self._consuId = nil
    end

    local consuData = {}
    consuData.icon = icon
    consuData.name = name
    consuData.quality = quality
    consuData.starNo = starNo
    consuData.infoImgShow = infoImgIsShow
    self:updateConsuPos(consuData)

end

function UITeamDetailPanel:onClickConsuHandle(sender)
    if self:onIsOpenConsu(true,TextWords:getTextWord(772)) == true then
        if self._consuId and self._consiProxy:getInfoById(self._consuId) ~= nil then
            local consuData = {}
            consuData.icon = 999
            consuData.infoImgShow = false
            self:updateConsuPos(consuData)
            
            self._consuId = nil

            -- self:setSoliderList()
            self._soliderProxy:soldierMaxFightChange()
            -- --去掉军师，重算带兵量
            self._soliderProxy:setMaxFighAndWeight("")
            -- local data = nil
            -- if self._maxFightBtn:isVisible() then
            --     data = self._soliderProxy:getMaxWeight()
            -- else
            --     data = self._soliderProxy:getMaxFight()
            -- end
            -- self:setSoliderList(data)   --去掉军师,计算当前战力
            self:updateSoliderNum()  --更新带兵量
            self:setFirstNumber() --重新计算先手值
        else
            -- 弹窗选择军师上阵
            if not self._uiAdviserListPanel then
                local strTitle = self._parent:getTextWord( 270072 )
                self._uiAdviserListPanel = UIAdviserList.new( self._parent, strTitle )
            end
            self._uiAdviserListPanel:show( self, self.onConsuGoCallback )
        end
    end
end

--上阵军师和去掉军师的时候，更新兵力
function UITeamDetailPanel:updateSoliderNum()
    local command = 0
    local _addVull = 0

    local data = self._consiProxy:getInfoById(self._consuId)
    if self._consuId == nil or data == nil then
        command = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)
    else
        _addVull = self._soliderProxy:getAdviserCommand(data)
        command = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command) + _addVull
    end

    -- 若屏蔽武将带兵量 - 武将带兵
    if self._isWithoutHero then
        local heroProxy = self._parent:getProxy(GameProxys.Hero)
        command = command - heroProxy:getHerosCommand()
    end


    if self._lastCommand == nil then
        self._lastCommand = _addVull
    end

    self._totalSolsiers = 0 --当前出战的总兵力
    self._currWeight = 0  --当前的载重
    self._currFight = 0   --当前的战力

    local allSoldierNum = {}
    for k,v in pairs(self._fightPosMap) do
        if v.post ~= 9 and v.post ~= 19 then
            allSoldierNum[v.typeid] = self._soliderProxy:getSoldierCountById(v.typeid)
        end
    end

    local allPos = {}
    for i=1,6 do
        local v = self._fightPosMap[i]
        if v ~= nil then
            
            -- a)军师上阵时，只改变当前已上阵的兵种数量，不用重新再计算上阵一次的兵种
            --  i.如果军师没有增加带兵量，则阵型不变
            -- ii.如果军师有增加带兵量，则直接在当前的阵型对应的兵补足具体的带兵量，整体阵型不变；补兵从1号位开始
            -- iii.同理，卸掉军师之后，当前阵型减去对应的带兵量
            
            if _addVull == 0 then
                if v.num >= command then
                    v.num = command
                else
                    v.num = v.num - self._lastCommand
                    if v.num < 1 then
                        v.num = 1
                    end
                end
            elseif _addVull > 0 then
                if _addVull > self._lastCommand then
                    v.num = v.num + _addVull - self._lastCommand
                else
                    v.num = v.num + _addVull
                end
            end

            if v.num > allSoldierNum[v.typeid] then
                v.num = allSoldierNum[v.typeid]
            end
            allSoldierNum[v.typeid] = allSoldierNum[v.typeid] - v.num
            self._totalSolsiers = self._totalSolsiers + v.num

            allPos[v.post] = true
            -- self._posMap
            local AdviserInfo = self._consiProxy:getInfoById(self._consuId)
            local fight = self._soliderProxy:getPosAllFight(v, AdviserInfo or {}, self._isWithoutHero)
            self._currFight = self._currFight + fight
            self._currWeight = self._currWeight + self._soliderProxy:getOneSoldierWeightById(v.typeid) * v.num
            local team = self:getTeamByPos(v.post)
            ComponentUtils:updateSoliderPos(team, v.typeid, v.num, nil, nil, true, nil, false)
            logger:info("== 刷新槽位 v.typeid, v.num >> %d,%d ==",v.typeid, v.num)
        end
    end

    self._lastCommand = _addVull
    
    --没兵的已经解锁的槽位也要计算军师战力
    for i=1,6 do
        if allPos[i] ~= true and self:getWhichPosEnable(i) then
            local AdviserInfo = self._consiProxy:getInfoById(self._consuId)
            self._currFight = self._currFight + self._soliderProxy:getPosAllFight({num = 0, typeid = 0, post = i}, AdviserInfo or {}, self._isWithoutHero)
        end
    end

    self:setCurrFight()
    self:setSolderCount()    
    -- self:setCurrWeight()
    -- self:updateWorldNeedInfo() --刷新粮食消耗
end


--侦查报告只发了typeid  要拿typeid来更新军师的信息
function UITeamDetailPanel:onUpdateAdviser(typeId)
    local configData = self._consiProxy:getDataById(typeId)
    local name = configData ~= nil and configData.name or ""

    local consuData = {}
    consuData.name = name
    consuData.infoImgShow = configData ~= nil
    self:updateConsuPos(consuData)
end

--军师显示信息
--[[
    -- 数据结构
    -- local consuData = {}
    -- consuData.icon = 军师图片 (0显示默认军师图片，999显示空图)
    -- consuData.name = 军师名字
    -- consuData.quality = 军师品质
    -- consuData.starNo = 星数
    -- consuData.infoImgShow = 是否显示军师信息
]]
function UITeamDetailPanel:updateConsuPos(data)
    ComponentUtils:updateConsuPos(self._parent, self._consuL, data)
end

-- 军师解锁图片
function UITeamDetailPanel:onShowConsuSuoImg(status)
    local suoImg = self._consuL:getChildByName("suoImg")
    suoImg:setVisible(status)
end

function UITeamDetailPanel:onConsuGoCallback( AdviserInfo )
    local conf = self._consiProxy:getDataById( AdviserInfo.typeId )
    self:onConsuGoReq(AdviserInfo)
    return true
end

-------------------------------------------------------------------------------
-- 军师上阵显示处理 end
-------------------------------------------------------------------------------

function UITeamDetailPanel:onShowConsuImg(data)
    if self:onIsOpenConsu(false) == true then
        local id = nil
        if data then
            for _,v in pairs(data) do
                if v.post == 9 or v.post == 19 then  --特殊位置
                    if v.num > 0 then
                        id = v.adviserId
                    end
                    break 
                end
            end
        end
        self:onShowConsuImgById(id)
    end
end

function UITeamDetailPanel:onConsuGoReq(data)  --军师上阵
    -- self:setSoliderList(nil)
    self._soliderProxy:soldierMaxFightChange()
    self._soliderProxy:setMaxFighAndWeight(data.id)
    self:onShowConsuImgById(data.id)
    -- self:setSoliderList(self._fightPosMap)  --加上军师 计算战力
    -- local info = nil
    -- if self._maxFightBtn:isVisible() then
    --     info = self._soliderProxy:getMaxWeight()
    -- else
    --     info = self._soliderProxy:getMaxFight()
    -- end
    -- self:setSoliderList(info)  --加上军师 计算战力
    self:updateSoliderNum()
    self:setFirstNumber() --重新计算先手值
end

function UITeamDetailPanel:onCheckConsuData(data) --检查军师数据,防止军师都派出去了
    -- local id = nil
    -- for _,v in pairs(data) do
    --     if v.post == 9 or v.post == 19 then
    --         if v.num > 0 then
    --             local conData = self._consiProxy:getConsuById(v.typeid)
    --             -- if conData.num - conData.fightnum > 0 then
    --             id = v.adviserId
    --             -- end
    --         end
    --         break
    --     end 
    -- end
    -- self:onShowConsuImgById(id)
end



function UITeamDetailPanel:adaptiveBgImg()  --背景图的自适应
    local scale = NodeUtils:getAdaptiveScale()

    local bgImg = self._topPanel:getChildByName("bgImg")
    local size = bgImg:getContentSize()
    local posY = bgImg:getPositionY()
    if scale > 1 then
        if scale <= 540/480 then
            posY = posY * scale - 24  --24是什么鬼
        else
            posY = posY * scale - 36  --24是什么鬼
        end

        bgImg:setScaleY(scale)
        bgImg:setPositionY(posY)
    end
end

---------------------------------------------------------------------------
-- 公有接口
---------------------------------------------------------------------------
-- 获取出战列表 infos
function UITeamDetailPanel:getFightElementInfos()
    return self:checkFightPosMap()
end

-- 获取省流量按钮状态 0=关闭 1=开启
function UITeamDetailPanel:getSaveTrafficState()
   --  local saveTraffic = 0
   local key
    if self._type == 2 then
        local type ,dunId = self._dungeonProxy:getCurrType()
        local info = ConfigDataManager:getInfoFindByOneKey("AdventureConfig","ID",dunId)
        key = self._type .. info.type
    else
        key = self._type
    end

    local isAuto = LocalDBManager:getValueForKey(GameConfig.isAutoBattle .. key)
    local saveTraffic = isAuto == "yes" and 1 or 0
    return saveTraffic
end


function UITeamDetailPanel:getParent()
    return self._parent
end

function UITeamDetailPanel:getUiSkin()
    return self._uiSkin
end

function UITeamDetailPanel:onGetUIDownPanel()
    return self._uiSkin:getChildByName("DownPanel")
end

--选择了套用阵型，回调更新阵型的位置
function UITeamDetailPanel:updateTeamPos(data)
    self:setSoliderList(nil)
    self:onShowConsuImg(data)
    self:setSoliderList(data)
end

--显示默认pve阵型: 战斗类型为（战役、远征、世界战斗、剿匪、乱军）时
function UITeamDetailPanel:updatePveTeamPos(uiType)
    if uiType == nil then
        return
    end

    local isPve = self._soliderProxy:isPve(uiType)
    if isPve ~= true then
        logger:info("UITeamDetailPanel 打印pve阵型信息 isPve=false ")
        return
    end

    local data = self._soliderProxy:getPveTeamInfo()
    -- for k,v in pairs(data.members) do
    --     logger:info("UITeamDetailPanel 打印pve阵型信息 %d %d %d %d",k,v.typeid,v.num,v.post)
    -- end

    self:setSoliderList(nil)
    self:onShowConsuImg(data.members)
    self:setSoliderList(data.members)

end

--更新点开套用阵型所需的数据
-- function UITeamDetailPanel:updateSetTeamData(pos, num, typeid)
--     self._setTeamData = self._setTeamData or {}
--     for k,v in pairs(self._setTeamData) do
--         if self._setTeamData[k].post == pos then
--             self._setTeamData[k].num = num
--             self._setTeamData[k].typeid = typeid
--         end
--     end
-- end

------
-- 判断是否不上阵武将
function UITeamDetailPanel:isWithoutHero(data)
    local state = false
    local id = rawget(data, "id")
    if id ~= nil then
        local configInfo = ConfigDataManager:getConfigById( ConfigData.EventConfig, id)
        if configInfo ~= nil then
            state = configInfo.heroBattle == 0
        end

        local adventureEventInfo = ConfigDataManager:getConfigById( ConfigData.AdventureEventConfig, id)
        if adventureEventInfo ~= nil then
            state = adventureEventInfo.heroBattle == 0
        end

    end
    return state
end

------
-- 设置是否提示武将限制关卡
function UITeamDetailPanel:setWithoutHeroText(isWithoutHero)
    local withoutHeroImg = self._middlePanel:getChildByName("withoutHeroImg")
    withoutHeroImg:setVisible(false)
    if isWithoutHero then
        withoutHeroImg:setVisible(true)
    end
end


function UITeamDetailPanel:getEveryPosMaxCommand()
    local count = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)  --每个坑位的佣兵出战上线数目
    -- 军师带兵量加成
    if self._consuId ~= nil and self._consiProxy:getInfoById(self._consuId) ~= nil then
        local conData = self._consiProxy:getInfoById(self._consuId)
        local adviserCommand = self._soliderProxy:getAdviserCommand(conData)
        count = adviserCommand + count
    else
        self._consuId = nil
    end
    
    -- 如果屏蔽武将，带兵量减去武将带兵
    if self._isWithoutHero then
        local heroProxy = self._parent:getProxy(GameProxys.Hero)
        count = count - heroProxy:getHerosCommand()
    end

    return count
end

