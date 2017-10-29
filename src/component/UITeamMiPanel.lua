--------created by zhangfan in 2016-08-09
--------设置部队阵型的通用面板
UITeamMiPanel = class("UITeamMiPanel")
--[[
--------type 
0:临时跳转的战斗(无阵型数据,例如:世界地图挑战  
2:防守阵型(设置防守阵型)  
1:套用阵型  
3:演武场阵型  
--------
4:世界boss活动阵型 
5:挂机(type 0的特殊状态) 
6:各种部队详情界面(panel不可点击) 
7:群雄涿鹿(type 0的特殊状态) 
8:副本攻打(普通和军团)
9:驻军
10:默认空界面
11:城主战防守阵型
12:城主战进攻阵型
]]
function UITeamMiPanel:ctor(parent,data,type,callBack,tabsPanel,isTeamModule)

    --
    self._iconsPath = {
        "images/newGui1/IconShuXingMuBiao.png",
        "images/newGui1/IconShuXingXianShou.png",
        "images/newGui1/IconShuXingFuZhong.png",
        "images/newGui1/IconShuXingTime.png",
        "images/newGui1/IconShuXingXiaoHao.png",
        "images/newGui1/IconShuXingzhuangTai.png"
    }
    self._iconsDescribe = {
        7031,
        7032,
        7033,
        7034,
        7035,
        7036
    }

    local function doLayout(uiSkin)
        self:doLayout(uiSkin)

        -- TimerManager:addOnce(30, self.doLayout, self, uiSkin)
    end
    local uiSkin = UISkin.new("UITeamMiPanel",nil,doLayout)
    self._uiSkin = uiSkin
    uiSkin:setParent(parent)
    self._parent = parent
    self.tabsPanel = tabsPanel
    self.isTeamModule = isTeamModule  --是否为部队模块调用
    self._subBattleType = 0  --子战斗类型
    self._taskType = 0
    self._fightPosMap = {}        --出战阵型的保存

    -- self._setTeamData = {}   --点开套用阵型时候的6组兵的数组

    self._posMap = {}  --槽位的开放设置
    self._selectTeam = nil        --选中的team
    self._totalKen = 0            --总共开放的坑数量
    self._totalSolsiers = 0       --总共出战的佣兵数目
    self._currWeight = 0          --当前的载重
    self._currFight = 0           --当前的战力
    self._consuId = nil           --军师出战ID
    self._srcType = 0             --1=重算战力，0=不用重算战力

    self._data = data
    self._callBack = callBack
    self._btnMap = {}             --所有按钮集合
    self._type = type

    self._delayFunKeys = { }         -- 延迟渲染函数keys

    -- 自适应
    self._downPanel = self._uiSkin:getChildByName("DownPanel")
    self._ccbPanel = self._uiSkin:getChildByName("panelCCB")
    self._movePanel = self._uiSkin:getChildByName("movePanel")
    self._topPanel = self._uiSkin:getChildByName("NewTopPanel")
    self._posTopPanel = self._uiSkin:getChildByName("Panel_36")
    self._bgImg    = self._uiSkin:getChildByName("Image_105")

    self:initTopInfo()
    self:initCCBPanel()
    self:registerEvents()
    self:registerProxyEvents()
    self:initPosImg()
    self:setCurrFight()
    self:onUpdateData(data,type)

end

function UITeamMiPanel:doLayout(uiSkin)
    self._uiSkin = uiSkin
    self:adaptive()
    self:adaptiveBgImg()

    NodeUtils:adaptiveUpPanel(self._downPanel, self._movePanel,1 )

end
function UITeamMiPanel:adaptive()
    -- 自适应
    if self.tabsPanel then
        if self.tabsPanel.topOffset or self._type == 7 or self._type == 6 then  --群雄逐鹿
            NodeUtils:adaptiveUpPanel(self._topPanel, self.tabsPanel, self.tabsPanel.topOffset)
            return
        end
        NodeUtils:adaptiveTopPanelAndListView(self._topPanel, nil, self._downPanel, self.tabsPanel)
    -- elseif self._type == 7 then  --群雄逐鹿 兼容旧UI
    --     -- 没标签自适应
    --     local tabsPanel = self._parent:topAdaptivePanel()
    --     NodeUtils:adaptiveTopPanelAndListView(self._topPanel, self._bgImg, self._downPanel, tabsPanel)    
    -- else
    --     -- 没标签自适应
    --     NodeUtils:adaptiveTopPanelAndListView(self._posTopPanel, self._bgImg, GlobalConfig.downHeight, GlobalConfig.topHeight)    
    else
        -- 没标签自适应
        local tabsPanel = self._parent:topAdaptivePanel()
        NodeUtils:adaptiveTopPanelAndListView(self._topPanel, self._bgImg, self._downPanel, tabsPanel)
    end
end


function UITeamMiPanel:finalize()
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

    if self._UITeamMessPanel then
        self._UITeamMessPanel:finalize()
    end
    if self._uiSetTeamPanel ~= nil then
        self._uiSetTeamPanel:finalize()
        self._uiSetTeamPanel = nil
    end
    if self._uiAdviserListPanel ~=nil then
        self._uiAdviserListPanel:finalize()
        self._uiAdviserListPanel = nil
    end
    self:removeProxyEvents()
    self._uiSkin:finalize()
end

function UITeamMiPanel:removeProxyEvents()
    self._soldierProxy:removeEventListener(AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onRoleInfoChange)
    self._soldierProxy:removeEventListener(AppEvent.PROXY_CONSUGOREQ, self, self.onConsuGoReq)
    self._soldierProxy:removeEventListener(AppEvent.PROXY_TEAMPOS_UPDATE, self, self.onUpdateTeamPos)
    self._soldierProxy:removeEventListener(AppEvent.PROXY_DEFTEAM_UPDATE, self, self.onUpdateDefTeam)
end

function UITeamMiPanel:registerProxyEvents()
    self._soldierProxy:addEventListener(AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onRoleInfoChange)
    self._soldierProxy:addEventListener(AppEvent.PROXY_CONSUGOREQ, self, self.onConsuGoReq)
    self._soldierProxy:addEventListener(AppEvent.PROXY_TEAMPOS_UPDATE, self, self.onUpdateTeamPos)
    self._soldierProxy:addEventListener(AppEvent.PROXY_DEFTEAM_UPDATE, self, self.onUpdateDefTeam)
end

function UITeamMiPanel:registerEvents() --注册事件
    
    self._maxFightBtn = self._uiSkin:getChildByName("DownPanel/maxFightBtn")      --最大战力
    self._squreBtn =  self._uiSkin:getChildByName("DownPanel/SqureBtn")           --套用阵型按钮
    self._protectBtn = self._uiSkin:getChildByName("DownPanel/protectBtn")        --防守阵型
    self._fightBtn = self._uiSkin:getChildByName("DownPanel/fightBtn")            --出战按钮
    self._maxWeightBtn = self._uiSkin:getChildByName("DownPanel/maxWeightBtn")    --最大载重
    self._equipBtn = self._uiSkin:getChildByName("DownPanel/EquipBtn")            --装备
    self._sleepBtn = self._uiSkin:getChildByName("DownPanel/sleepBtn")            --挂机
    self._peijianBtn = self._uiSkin:getChildByName("DownPanel/PeijianBtn")        --配件
    self._signUpBtn = self._uiSkin:getChildByName("DownPanel/signUpBtn")          --报名
    self._winTxt = self._uiSkin:getChildByName("DownPanel/winTxt")                --连胜次数：
    self._countTxt = self._uiSkin:getChildByName("DownPanel/countTxt")            --次数xx
    self._tipTxt = self._uiSkin:getChildByName("DownPanel/tipTxt")                --默认提示
    self._heroBtn = self._uiSkin:getChildByName("DownPanel/heroBtn")              --显示武将按钮

    self._arenaTxt = self._uiSkin:getChildByName("DownPanel/arenaTxt")   --演武场提示文本
    
    -- 部队详情界面武将按钮
    self._decHeroBtn = self._uiSkin:getChildByName("heroBtn")   --显示武将按钮，适用于查看部隊詳情界面
    self._decHeroBtn:setVisible(false) --默认隐藏
    -- 部队详情界面前往按钮


    self._panelDesc = self._uiSkin:getChildByName("panelDesc")   --详情按钮
    self._panelDesc:setVisible(false) --默认隐藏

    self._decJumpBtn = self._panelDesc:getChildByName("jumpBtn")   --矿点显示前往按钮，适用于查看部隊詳情界面
    self._decReturnBtnBtn = self._panelDesc:getChildByName("returnBtn")   --矿点显示前往按钮，适用于查看部隊詳情界面

    
    self._tipTxt:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 50), cc.FadeTo:create(0.5, 255))))

    self._roleProxy = self._parent:getProxy(GameProxys.Role)
    self._soldierProxy = self._parent:getProxy(GameProxys.Soldier)
    self._dungeonProxy = self._parent:getProxy(GameProxys.Dungeon)
    self._equipProxy =  self._parent:getProxy(GameProxys.Equip)
    self._patrsProxy = self._parent:getProxy(GameProxys.Parts)
    self._consiProxy = self._parent:getProxy(GameProxys.Consigliere)
    self._heroProxy = self._parent:getProxy(GameProxys.Hero)
    self._seasonProxy = self._parent:getProxy(GameProxys.Seasons)

    if self._type == 6 then   --部队详情界面特殊情况
        self._heroBtnType = 1
        self._decHeroBtn:setVisible(true)
        ComponentUtils:addTouchEventListener(self._decHeroBtn, self.onBtnTouchHandle, nil, self)
        ComponentUtils:addTouchEventListener(self._decJumpBtn, self.onBtnTouchHandle, nil, self)
        ComponentUtils:addTouchEventListener(self._decReturnBtnBtn, self.onBtnTouchHandle, nil, self)

        self:onSetInfosUi()
        if self.isTeamModule then
            self._topPanel:setVisible(true)
        else
            self._topPanel:setVisible(false)
            return
        end
    else
        self._topPanel:setVisible(true)
        
        self._winTxt:setVisible(false)
        self._countTxt:setVisible(false)

        -- DownPanel的初始化------------------------------------------------------------------
        --self._squreBtn:setTitleText(TextWords:getTextWord(757))
        self._heroBtnType = 1
        self._maxFightBtn.type = 1
        self._maxWeightBtn.type = 2

        self._btnMap = {self._squreBtn,self._maxFightBtn,self._protectBtn,self._fightBtn,
            self._maxWeightBtn,self._sleepBtn,self._signUpBtn,self._heroBtn}


        for _,v in pairs(self._btnMap) do
            ComponentUtils:addTouchEventListener(v, self.onBtnTouchHandle, nil, self)
        end

        -- 屏蔽部分按钮
        -- ComponentUtils:addTouchEventListener(self._equipBtn, self.onBtnTouchHandle, nil, self)
        -- ComponentUtils:addTouchEventListener(self._peijianBtn, self.onBtnTouchHandle, nil, self)
        -- ComponentUtils:addTouchEventListener(self._consuImg, self.onClickConsuHandle, nil, self)  --屏蔽军师功能
        self._equipBtn:setVisible(false)
        self._peijianBtn:setVisible(false)

        self:onShowBtnAndLabel()
    end
end

function UITeamMiPanel:setVisible(isVisible)
    self._uiSkin:setVisible(isVisible)
end

-----
-- 设置任务类型
function UITeamMiPanel:setTaskType(taskType)
    self._taskType = taskType
end


--防守阵型刷新
function UITeamMiPanel:onUpdateDefTeam()
    if self._type == 2 then
        local data = self._soldierProxy:onGetTeamInfo()
        self:setSoliderList(data[2].members)
    end
end

function UITeamMiPanel:onRoleInfoChange()  --个人信息发生改变
    -- if self._uiSkin:isVisible() ~= true then
    --     return
    -- end
    local level = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)  --指挥官等级
    if self._type ~= 6 then -- 加限制判断防止其他信息回调影响刷新
        self._level = level
        self:setOpenPosBylevel(level)       --指挥官等级的改变，导致开放的坑位数目发生改变
    end
    --self:setSolderCount()              --每个槽位的出战佣兵上线的改变
end

function UITeamMiPanel:onProhibitMovePanel(movePanel)  --详情界面禁止触摸事件
    for i = 1 ,6 do
        local panel = movePanel:getChildByName("imgPos"..i)
        panel.pos = i
        panel:setTouchEnabled(false)
        -- local selectImg = panel:getChildByName("selectImg")
        -- selectImg:setVisible(false)
        -- ComponentUtils:setTeamSelectStatusByTeam(panel,false)

        self:setTeamSuoStatus(i,false)
        self:setTeamSelectStatusByTeam(panel,false)
    end
end

function UITeamMiPanel:initPosImg()  --初始化获得6个位置
    self._movePanel = self._uiSkin:getChildByName("movePanel")
    self:initPosPanel()

    if self._type == 6 then
        self:onProhibitMovePanel(self._movePanel)
        return
    end

    
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
        local team = self._movePanel:getChildByName("imgPos"..index)
        team.pos = index
        local args = {}
        args["objcet"] = self
        args["callback1"] = callback1
        args["callback2"] = callback2
        args["callback3"] = callback3
        IDrag.new(team,args, true)   --初始化各个坑位
        self._posMap[index] = { isOpen = false } --test
        -- local selectImg = team:getChildByName("selectImg")
        -- selectImg:setVisible(false)
        self:setTeamSelectStatusByTeam(team,false)
    end

end

function UITeamMiPanel:initPosPanel()
    -- 从UISoldilerMainPos拿坑位UI，然后clone加载到当前panel
    local tt = UISoldilerMainPos.new(self._movePanel)
    local commonImgPanel = tt:getChildByName("imgPos")  --佣兵UI模板
    local consImgPanel = tt:getChildByName("consPos")  --军师UI模板
    tt:finalize()

    -- 佣兵
    for index = 1 ,6 do
        local imgPos = self._movePanel:getChildByName("imgPos1"..index)
        local x,y = imgPos:getPosition()
        imgPos:setVisible(false)

        local team = commonImgPanel:clone()
        team:setVisible(true)
        team:setPosition(x,y)
        team:setName("imgPos"..index)
        self._movePanel:addChild(team)
    end

    -- 军师
    self._imgPos = self._movePanel:getChildByName("consuImg")
    self._imgPos:setVisible(false)
    local x,y = self._imgPos:getPosition()

    local team = consImgPanel:clone()
    team:setVisible(true)
    team:setPosition(x,y)
    team:setName("consuImg")
    self._movePanel:addChild(team)
    self._consuImg = team
    self._consuImg:setTouchEnabled(self._type ~= 6)
    ComponentUtils:addTouchEventListener(self._consuImg, self.onClickConsuHandle, nil, self)
end


function UITeamMiPanel:onUpdateData(data,flag)  --每次打开刷新数据
    if self._type == 6 then  ---详情界面特殊
        return
    end

    self._arenaTxt:setVisible(false)
    if self._type == 3 then
        local proxy = self._parent:getProxy(GameProxys.Arena)
        local isSeted = proxy:onGetIsSquire()
        self._arenaTxt:setVisible(not isSeted)
    end

    self._data = data
    if self._type ~= flag and flag ~= nil then                        -- type 0 2 5共享同一个队伍页面
        self._type = flag
        self:onShowBtnAndLabel()
        self._solidertime = nil
    end


    if self._type == 10 then  ---默认界面
        return
    end

    self:onRoleInfoChange()  --刷新个槽位开启,需要加入随时更新监听    
    self:updateEquipAndParts()                   --刷新军械和武将的小红点数目,需要加入随时更新监听
    self:onUpDateSoliderList(data)
    self:setSolidertime(self._solidertime)                        --刷新行军时间，todo:世界跳转过来的时候 需要从新计算时间
    self:updateWorldNeedInfo()
    self:setFirstNumber()
    -- self:setCurrFight()
    -- if self._type == 3 and data ~= nil then
    --     self:onUpdateWinCount(data.count)             --演武场 刷新连胜次数
    -- end

    if self._type == 0 or self._type == 4 or self._type == 7 
        or self._type == 16 or self._type == 17 
        or self._type == 18 or self._type == 19  then  --世界战斗        
        self:showLostInfo(true,0) --显示战损
    else
        self:showLostInfo(false,0) --隐藏战损
    end


    self._maxFightBtn:setVisible(true)           --出战按钮
    self._maxWeightBtn:setVisible(false)  

    self:updatePveTeamPos(self._type)
end

function UITeamMiPanel:onUpDateSoliderList(Data)
    local isOwer
    if self._type >= 1 and self._type <= 4 then  --套用阵型 防守阵型 竞技场阵型 世界boss阵型
        isOwer = true
        self:setSoliderList(nil)

        --套用阵型的数据要在别的地方拿
        local data = self._soldierProxy:onGetTeamInfo()        
        local teamData
        if self._type == 1 then
            data = self._soldierProxy:getTeamDataMap()
            for i=1,4 do
                if data[i] ~= nil then
                    teamData = data[i].members
                    break
                end
            end
        else
            teamData = data[self._type].members
        end

        local isOpenArena = self._type == 3  --是否打开演武场阵型界面
        local showData,adviserLv = self:checkAdviserData(teamData, isOpenArena)
        self:onShowConsuImg(showData, adviserLv)   --军师图片

        self:setSoliderList(showData)
        self:onProtectOwerCity()    --防守本城
    
    elseif self._type == 0 then     --世界进攻
        self:onWorldCity(Data)
    
    elseif self._type == 5 or self._type == 8 then  --副本攻打 挂机
        self:onEventCity() 
    
    elseif self._type == 7 or self._type == 11 or self._type == 12 then     --群雄涿鹿 --城主战  不用检查
        isOwer = true
        self:setSoliderList(nil)
        self:onShowConsuImg(Data)   --军师图片
        self:setSoliderList(Data)
    
    elseif self._type == 16 or self._type == 17 then -- 16=郡城盟战pvp, 17=郡城盟战pve
        self:onWorldCity(Data)
    elseif self._type == 18 or self._type == 19 then -- 18=皇位战pvp, 19=郡城盟战pve
        self:onWorldCity(Data)
    else--部队详情
    end

    if not isOwer then
        self:onShowConsuImg(nil)
        self:setSoliderList(nil) 
    end
end

function UITeamMiPanel:onShowBtnAndLabel() --根据type的不同 ，各个btn和label的显隐性设置
    self._sleepBtn.hide = true
    self._signUpBtn.hide = true
    self._fightBtn.hide = true
    self._decHeroBtn.hide = true
    if self._type == 0 or self._type == 8 or self._type == 12 then
        self._protectBtn.hide = true
        self._fightBtn.hide = false
    elseif self._type == 1 then
        self._squreBtn.hide = true
        self._protectBtn:setTitleText(TextWords:getTextWord(760))
    elseif self._type == 2 then
        self._protectBtn.hide = false
        --self._fightBtn.hide = true
    elseif self._type == 3 then
        self._protectBtn:setTitleText(TextWords:getTextWord(760))
        self._squreBtn.hide = false
        self._maxWeightBtn.hide = true
    elseif self._type == 4 then
        self._protectBtn:setTitleText(TextWords:getTextWord(760))
        self._maxWeightBtn.hide = true
    elseif self._type == 5 then
        self._sleepBtn.hide = false
        self._protectBtn.hide = true
        self._maxWeightBtn.hide = true
    elseif self._type == 7 then
        self._signUpBtn.hide = false
        self._protectBtn.hide = true
        self._maxWeightBtn.hide = true
    elseif self._type == 9 then --驻军
        self._protectBtn:setTitleText(TextWords:getTextWord(770))
    elseif self._type == 11 then --城主战设置防守
        self._protectBtn.hide = false
        self._fightBtn.hide = true
    elseif self._type == 6 then  --查看部队详情界面 显示武将按钮
        self._decHeroBtn.hide = false
    elseif self._type == 16 or self._type == 17 then -- 16=郡城盟战pvp
        self._protectBtn.hide = true
        self._fightBtn.hide = false
    elseif self._type == 18 or self._type == 19 then 
        self._protectBtn.hide = true
        self._fightBtn.hide = false
    end

    for _,v in pairs(self._btnMap) do
        if v.hide == true then
            v:setVisible(false)
        else
            v:setVisible(true)
        end
    end
end

function UITeamMiPanel:setFigAndWeiVisible(isShow,noshow)
    if self._type ~= 3 and self._type ~= 4 and self._type ~= 5 and  self._type ~= 7 then
        self._maxWeightBtn:setVisible(noshow)
        self._maxFightBtn:setVisible(isShow)
    end
end

-- 点击最大战力OR最大载重按钮
function UITeamMiPanel:onTouchFigAndWeiBtnHandle(sender)
    self:setSoliderList(nil)
    --这里需要拿一下最大战力的军师id跟self._consuId比较一下   不一样就需要重算最大战力
    local newAdviserId = self._consiProxy:getMaxConsuId()
    if self._consuId ~= newAdviserId then
        -- print("最大战力的军师id跟self._consuId,不一样就需要重算最大战力")
        self._soldierProxy:soldierMaxFightChange()
    end

    self._soldierProxy:setMaxFighAndWeight()
    local data 
    if sender.type == 1 then
        data = self._soldierProxy:getMaxFight()   --获取最大战力
        self:setFigAndWeiVisible(false,true)
    else
        data = self._soldierProxy:getMaxWeight()  --获取最大载重
        self:setFigAndWeiVisible(true,false)
    end
    local consuId = self._consiProxy:getMaxConsuId()  --获取战力最大的军师
    self:onShowConsuImgById(consuId)
    
    --城主战 有个削弱带兵量的效果要校验
    local lordCityProxy = self._parent:getProxy(GameProxys.LordCity)
    if lordCityProxy:isLordCityTeamUI() == true then
        data = lordCityProxy:updateCommand(data)
    end

    if table.size(data) == 0 then
        self._parent:showSysMessage(TextWords[7079])
        return
    end
    self:setSoliderList(data)
end

function UITeamMiPanel:onTouchFightBtnHandle(sender) --部队中普通和军团出战  世界出战 请求
    local data = {}
    data.type = self._sendType or self._type --sendType为nil时，是世界出战，传type进入
    data.id = self._cityId
    data.infos = self:checkFightPosMap(true)
    if data.infos ~= nil then
        if self:isCanDo() == true then
            local function yesCallback()
                AudioManager:playEffect("yx03") -- 可出战才能播放音效
                -- 出战更新pve阵型
                local soldierProxy = self:getProxy(GameProxys.Soldier)
                soldierProxy:onFightUpdatePveTeam(data)
                self._parent:onTouchFightBtnHandle(data)
            end
            local function noCallback()
            end

            -- 进攻矿点时，若自己有保护罩，则需要弹提示窗口
            if self._type == 0 then
                -- logger:info("矿点弹窗 0 type=%d",self._subBattleType,self._data.isPlayerRes)
                if self._subBattleType > 0 or self._data.isPlayerRes == true then
                    local itemBuffProxy = self._parent:getProxy(GameProxys.ItemBuff)
                    local isHaveNewRoleBuff = itemBuffProxy:isHaveNewRoleBuff()
                    local isHaveProtectBuff = itemBuffProxy:isHaveProtectBuff()
                    -- print("保护罩",isHaveNewRoleBuff,isHaveProtectBuff)
                    if isHaveNewRoleBuff == true or isHaveProtectBuff == true then  --有新手保护罩buff / 有道具保护罩
                        local state = LocalDBManager:getValueForKey("FightResTile",true)
                        if state ~= tostring(0) then  --需要弹窗确认
                            if self.UIFightDialog == nil then --判nil防止重复创建面板
                                local UIFightDialog = UIFightDialogPanel.new(self._parent)--false：创建但不显示
                                self.UIFightDialog = UIFightDialog
                            end
                            self.UIFightDialog:updateData(yesCallback)
                            return
                        end
                    end
                end
            end


            -- 攻打矿点判断是否弹窗提示战损
            local lost = 0
            if self._subBattleType ~= 0 then
                lost,_ = self:calFightLost(0)
            end
            if lost > 0 then
                local messageBox = self._parent:showMessageBox(TextWords:getTextWord(7078), yesCallback, noCallback)
                messageBox:setGameSettingKey(GameConfig.RESOURCELOSTCONFIRM)
            else
                yesCallback()
            end

        end
    end
end

function UITeamMiPanel:onTouchSqureBtnHandle(sender)
    -- self:setSoliderList(nil) --首先清除一下全部的
    -- self:onCheckConsuData(self._soldierProxy:onGetTeamInfo()[1].members)  --加上军师信息,直接拿套用阵型数据
    local info = self:checkFightPosMap()

    if self._uiSetTeamPanel == nil then
        self._uiSetTeamPanel = UISetTeamPanel.new(self._parent, info)
    else
        self._uiSetTeamPanel:show(info)
    end

end

-- 判定出战按钮OR挂机按钮是否满足触发条件
function UITeamMiPanel:isCanDo()
    if self._type == 0 then
        -- 讨伐令不足，不可以挑战
        if self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_crusadeEnergy) <= 0 then  --讨伐令
            self._roleProxy:getBuyCrusadeEnergyBox(self, nil, nil, true)  --弹窗购买讨伐令
            return false
        end
                    
        -- 粮食不足，不可以出战
        local _,needNum = self:getWorldNeedRes()
        local haveNum = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_food)
        if haveNum < needNum then
            self._parent:showSysMessage(TextWords:getTextWord(341))
            return false
        end

        -- 攻打同盟的资源点，不可以出战
        local isTeammateRes = self._soldierProxy:isTeammateRes()
        if isTeammateRes then -- 是同盟点
            self._parent:showSysMessage(TextWords:getTextWord(342))
            return not isTeammateRes
        end
        
        -- 出战队列已满，不可以出战
        local isFightButMaxMarchCount = self._soldierProxy:isFightButMaxMarchCount()
        if isFightButMaxMarchCount then
            self._parent:showSysMessage(TextWords:getTextWord(7073))
            return not isFightButMaxMarchCount
        end

        -- 废墟状态不可以派部队出城
        local isDestroy,_ = self._roleProxy:getBoomState()
        if isDestroy == true then
            self._parent:showSysMessage(TextWords:getTextWord(371))
            return false
        end
    end

    return true
end

function UITeamMiPanel:showMsgBox()
end

function UITeamMiPanel:checkSqureIsNull(srcData)  --判定套用阵型是否为空
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
    end
    return isNull
end

function UITeamMiPanel:onHisBtnHandle()
    -- self:dispatchEvent(ArenaEvent.SHOW_OTHER_EVENT,ModuleName.ArenaMailModule)
    self._roleProxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.ArenaMailModule})
end

function UITeamMiPanel:onTouchProtectBtnHandle(sender)  --保存防守阵型
    local sendData = {}
    sendData.info = {}
    if self._type >= 1 and self._type <= 4 then
        sendData.info.type = self._type
    end

    sendData.formationCapacity = self._currFight

    sendData.info.members = self:checkFightPosMap(true)

    --TODO 全部类型都判定阵型是否为空
    
    if sendData.info.members then
        self._parent:onTouchProtectBtnHandle(sendData)
    end

end

function UITeamMiPanel:onProtectOwerCity()   --防守本城
    local x,y = self._roleProxy:getWorldTilePos()
    local str
    if self._type == 3 then
        str = TextWords:getTextWord(1908)
    elseif self._type == 4 then
        str = self._data
    else
        str = TextWords[705]--.."/"..x..","..y
    end
    self:setTargetCity(str)
end

function UITeamMiPanel:onWorldCity(Data)     --世界
    local target = Data.city
    self:setTargetCity(target)
end

function UITeamMiPanel:onEventCity()         --副本
    local type ,dunId = self._dungeonProxy:getCurrType()
    local cityId = self._dungeonProxy:getCurrCityType()
    self._sendType = type or cityId
    self._cityId = cityId

    local info,cityInfo
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
    -- self:setTargetCity(info.name.."/"..cityInfo.name)
    self:setTargetCity(cityInfo.name)
end

function UITeamMiPanel:onSleepBtnHandle(sender)
    local data = self:checkFightPosMap(true)
    if data ~= nil then
        local currentType,_ = self._dungeonProxy:getCurrType()  --1征战 2探险 3军团副本
        if currentType then
            if currentType == 1 then
                if self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_energy) <= 0 then  --体力值
                    self._roleProxy:getBuyEnergyBox()
                    return
                end    
            else
                local currentTimes =  self._dungeonProxy:getCurrentTimes()
                if currentTimes <= 0 then
                    self:dispatchEvent(TeamEvent.BUYTIMES_REQ,1)
                    return
                end
            end
        end
        if table.size(self._soldierProxy:getBadSoldiersList()) > 0 then
            self._parent:showSysMessage(TextWords[7072])
            return
        end

        -- local panel = self._parent:getPanel(TeamSleepPanel.NAME)
        -- panel:show()
        -- panel:startSend(self._sendType,self._cityId,data)

        -- 请求挂机
        if self._sleepPanel == nil then
            self._sleepPanel = UITeamSleepPanel.new(self,self._parent)
            self._teamDetailProxy:setSleepPanel(self._sleepPanel)
        end
        self._sleepPanel:startSend(self._sendType,self._cityId,data)

    end
end

function UITeamMiPanel:onSignHandle()
    if self._callBack then
        local isColdTime = self._callBack(self._parent)
        if isColdTime == true then
            self._parent:showSysMessage("冷却时间内无法再次报名！")
            return
        end
    end

    local data = self:checkFightPosMap(true)
    if data then
        local count = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command) 
        self._parent:onSignHandle(data,{count = self._totalSolsiers,total = count * self._totalKen,fight = self._currFight}, self._currFight)
    end
end

function UITeamMiPanel:onBtnTouchHandle(sender)
    if self._maxFightBtn == sender or self._maxWeightBtn == sender then
        self:onTouchFigAndWeiBtnHandle(sender)
    elseif sender == self._fightBtn then          --出战请求
        self:onTouchFightBtnHandle()
    elseif self._squreBtn == sender then          --点击套用阵型按钮
        if self._type == 3 then
            self:onHisBtnHandle()
        else
            self:onTouchSqureBtnHandle()
        end
    elseif self._protectBtn == sender then        --点击设置防守按钮
        self:onTouchProtectBtnHandle()
    elseif self._signUpBtn == sender then         --点击群雄涿鹿出战
        self:onSignHandle()
    elseif self._peijianBtn == sender then        --点击进入配件
        self._roleProxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.PartsModule})
    elseif self._equipBtn == sender then          --点击进入装备
        self._roleProxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.HeroModule})
    elseif self._sleepBtn == sender then          --点击进入挂机
        self:onSleepBtnHandle()
    elseif self._heroBtn == sender then          --点击显示武将
        self:onHeroBtnTouch(sender)
    elseif self._decHeroBtn == sender then       --点击显示武将
        self:onHeroBtnTouch(sender)
    elseif self._decJumpBtn == sender then       --点击前往按钮
        self:onJumpBtnTouch(sender)
    elseif self._decReturnBtnBtn == sender then  --点击返回按钮
        self:onReturnBtnTouch(sender)
    end
end

-- 部队详情点击前往按钮（矿点有效）
function UITeamMiPanel:onJumpBtnTouch(sender)
    self:onGoToPosHandle(self._decJumpBtnData)
end

-- 更新前往按钮的显示
function UITeamMiPanel:updateJumpBtn(data)
    if data == nil or self._panelDesc == nil then
        self._panelDesc:setVisible(false)
        return
    end

    -- data.type 1进攻, 2返回, 3挖掘, 4出发驻防, 5驻防中, 6别人的驻军, 7盟战准备开战

    -- 前往按钮
    local x = nil
    local y = nil
    self._decJumpBtn:setVisible(false)
    if data.type == 1 or data.type == 3 or data.type == 4 or data.type == 5 or data.type == 7 then
        -- 进攻，挖掘
        x = data.x
        y = data.y
        self._decJumpBtn:setVisible(true)
    elseif data.type == 2 then
        -- 返回,驻防中
        x = data.startx
        y = data.starty
        self._decJumpBtn:setVisible(true)
    end

    -- 返回按钮
    if data.type == 3 or data.type == 5 then
        self._decReturnBtnBtn:setVisible(true)
        self._decReturnBtnBtn.taskTeamInfo = data
    else
        self._decReturnBtnBtn:setVisible(false)
    end

    -- 按钮位置，数据等设置
    if self._decJumpBtn:isVisible() == false and self._decReturnBtnBtn:isVisible() == false then
        self._panelDesc:setVisible(false)
        return
    else
        self._panelDesc:setVisible(true)

        self._decJumpBtnData = { }
        self._decJumpBtnData.moduleName = ModuleName.MapModule
        self._decJumpBtnData.extraMsg = { }
        self._decJumpBtnData.extraMsg.tileX = x
        self._decJumpBtnData.extraMsg.tileY = y
        
        local pos = { }
        pos[1] = { 320 }
        pos[2] = { 205, 434 }
        
        local btns = { }
        if self._decJumpBtn:isVisible() then
            table.insert(btns, self._decJumpBtn)
        end

        if self._decReturnBtnBtn:isVisible() then
            table.insert(btns, self._decReturnBtnBtn)
        end

        local posIndex = #btns
        for k, v in pairs(btns) do
            v:setPositionX(pos[posIndex][k])
        end
    end
end

function UITeamMiPanel:onGoToPosHandle(data) --前往矿点
    if data == nil then
        logger:info("点击了前往矿点 但是没有数据 ！！！~~~~")
        return
    end

    self._roleProxy:onHideQueuePanel()
    self._roleProxy:sendAppEvent(AppEvent.M2M_MAIN_EVENT,AppEvent.WATCH_WORLD_TILE,{tileX = data.extraMsg.tileX,tileY = data.extraMsg.tileY})
    self._roleProxy:sendAppEvent(AppEvent.MODULE_EVENT,AppEvent.MODULE_OPEN_EVENT,data)
    self._parent:onClose()
end

-- 点击返回按钮
function UITeamMiPanel:onReturnBtnTouch(sender)
    local taskTeamInfo = sender.taskTeamInfo

    local function callBack()
        self._soldierProxy:onTriggerNet80004Req( { id = taskTeamInfo.id })
        self._parent:onClose()
    end

    if taskTeamInfo.type == 3 then
        local key = "teamTask" .. taskTeamInfo.id
        local remainTime = self._soldierProxy:getRemainTime(key)
        if (taskTeamInfo.totalTime - remainTime * taskTeamInfo.product) < taskTeamInfo.load then
            -- 采集未满确认要返回?
            self._parent:showMessageBox(self._parent:getTextWord(7067), callBack)
            
            return
        end
    end

    callBack()    
end

-- 点击显示武将
function UITeamMiPanel:onHeroBtnTouch(sender)
    if self._heroBtnType == 1 then
        self._heroBtnType = 2
    elseif self._heroBtnType == 2 then
        self._heroBtnType = 1
    end
    

    local infoImg = sender:getChildByName("info")
    TextureManager:updateImageView(infoImg,"images/newGui2/Txt_img"..self._heroBtnType..".png")


    for _, info in pairs(self._fightPosMap) do
        if info.typeid > 0 and info.num > 0 then
            local color = nil
            local team = self:getTeamByPos(info.post)
            if self._heroBtnType == 2 then
                local name,color = self:getSoliderPosCount(info.num, info.post, self._heroBtnType, info.heroType)
                ComponentUtils:updateSoliderPosCount(team, name, color)
            else
                ComponentUtils:updateSoliderPosCount(team, info.num, color)
            end
        end
    end
end



function UITeamMiPanel:getSoliderPosCount(num, pos, heroBtnType, heroType)
    local color
    local curNum = num
    if heroBtnType == 2 then
        curNum = TextWords:getTextWord(127)
        color  = ColorUtils.wordWhiteColor
        if self._taskType and self._taskType == 6 then
            if heroType then
                local configInfo = self._heroProxy:getHeroConfigInfo(heroType)
                curNum = configInfo.name
                color = ColorUtils:getColorByQuality(configInfo.color) or ColorUtils.wordWhiteColor
            end
            logger:info(" 别人的 武将 %d %s",self._taskType,curNum)
        else
            curNum, color = self._heroProxy:getHeroNameByPos(pos)
            logger:info(" 自己的 武将 %s",curNum)
        end
    end
    return curNum,color
end

function UITeamMiPanel:getSoliderPosHelpName(num, pos, heroBtnType)
    local color
    local curNum = num
    if heroBtnType == 2 then
        curNum  = TextWords:getTextWord(127)
        color = ColorUtils.wordWhiteColor
    end
    return curNum,color
end


function UITeamMiPanel:updateEquipAndParts()
    local img = self._equipBtn:getChildByName("img")
    local count = img:getChildByName("count")
    local equipData = self._equipProxy:getEquipAllHome()
    if #equipData == 0 then
        img:setVisible(false)
    else
        img:setVisible(true)
        count:setString(#equipData)
    end
    img = self._peijianBtn:getChildByName("img")
    count = img:getChildByName("count")
    local partsData = self._patrsProxy:getOrdnanceUnEquipInfos()
    if partsData == nil or #partsData == 0 then
        img:setVisible(false)
    else
        img:setVisible(true)
        count:setString(#partsData)
    end
end

function UITeamMiPanel:setSoliderList(data)
    -- self._setTeamData = data
    self._soldierProxy = self._soldierProxy or self._parent:getProxy(GameProxys.Soldier)
    for i=1,6 do
        self._posMap[i] = self._posMap[i] or {}
        self._posMap[i].isOpen = self._soldierProxy:isTroopsOpen(i)
    end

    if data == nil then
        for index = 1 ,6 do
            self:setPuppetById(index,0,0, false)
        end
        self._fightPosMap = {}

        for _, v in pairs(self._delayFunKeys) do
            TimerManager:remove(v, self)
        end
        self._delayFunKeys = {}
    else
        local len = table.size(data)
        if len ~= 0 then
            NodeUtils:addSwallow()
        end
        for _,v in pairs(data) do
            self:setPuppetById(v.post,v.typeid,v.num, false, v)
        end
        local coolTime = len*0.2
        coolTime = coolTime > 0.6 and 0.6 or coolTime
        TimerManager:addOnce(coolTime*1000, function()
            NodeUtils:removeSwallow()
        end, self)
    end

    if self._type ~= 6 or self._srcType == 1 then
        self:setfightPosMap() --优化，放到外面来处理，这个方法很消耗，也没有必要在每次setPuppetById都去设置
    end

end

-- isCalFightPosMap 是否重算战力，默认计算，只有重新刷新不算，由外部计算
-- @info 单个槽位网络数据
function UITeamMiPanel:setPuppetById(pos, id, num, isCalFightPosMap, info)
    if pos == 9 or pos == 19 then
        return
    end
    local team = self:getTeamByPos(pos)
    local isAction = num > 0

    local delayUpdateSoliderPos = function()
        ComponentUtils:updateSoliderPos(team, id, num, nil, nil, true, nil, isAction)
        if self._heroBtnType == 2 then
            local heroType = nil
            if info then
                logger:info("-- 有武将 : 显示佣兵  00")
                heroType = rawget(info,"heroType")
            end
            local name, color = self:getSoliderPosCount(num, pos, self._heroBtnType, heroType)
            ComponentUtils:updateSoliderPosCount(team, name, color)
        end
    end

    if isAction then
        TimerManager:addOnce(pos * 80, delayUpdateSoliderPos, self)
        table.insert(self._delayFunKeys, delayUpdateSoliderPos)
    else
        delayUpdateSoliderPos()
    end
    local imgNum = team:getChildByName("imgNum")
    if self._posMap[pos].isOpen ~= nil then
        imgNum:setVisible(self._posMap[pos].isOpen)
    end

    if id == 0 then
        -- 显示默认的，不算出来
        -- return
    end

    -- 发生变更时就更新位置表
    self._fightPosMap[pos] = { post = pos, typeid = id, num = num}
    if info ~= nil then
        local heroType = rawget(info, "heroType")
        self._fightPosMap[pos].heroType = heroType -- 添加武将数据字段
    end

    -- 更改阵型
    self:updateWarBook()

    if isCalFightPosMap ~= false then
        if self._type ~= 6 then
            self:setfightPosMap()
        end
    end
end

------
-- 侦查报告，修正对方部队阵型标签的显示
 -- @param  showData [data] 阵型数据
function UITeamMiPanel:showResourceAtlas(showData)
    for i = 1 , 6 do
        local team = self:getTeamByPos(i)
        local imgNum = team:getChildByName("imgNum")
        if showData[i].num == 0 then
            imgNum:setVisible(true)
        else
            imgNum:setVisible(false)
        end
    end
end

function UITeamMiPanel:setSrcType(type)
    self._srcType = type
end

function UITeamMiPanel:getSrcType()
    return self._srcType
end

function UITeamMiPanel:setfightPosMap(fromType)
    self._totalSolsiers = 0 --当前出战的总兵力
    self._currWeight = 0  --当前的载重
    self._currFight = 0   --当前的战力

    local allPos = {}

    for _,v in pairs(self._fightPosMap) do
        if v.typeid and v.num > 0 then
            self._totalSolsiers = self._totalSolsiers + v.num
            local AdviserInfo = self._consiProxy:getInfoById(self._consuId)
            allPos[v.post] = true
            local fight = self._soldierProxy:getPosAllFight(v, AdviserInfo or {})
            self._currFight = self._currFight + fight
            self._currWeight = self._currWeight + self._soldierProxy:getOneSoldierWeightById(v.typeid) * v.num
        end
    end

    --没兵的已经解锁的槽位也要计算军师战力
    for i=1,6 do
        if allPos[i] ~= true and self:getWhichPosEnable(i) then
            local AdviserInfo = self._consiProxy:getInfoById(self._consuId)
            self._currFight = self._currFight + self._soldierProxy:getPosAllFight({num = 0, typeid = 0, post = i}, AdviserInfo or {})
        end
    end

    fromType = fromType or self._srcType
    if fromType == 1 then
        -- logger:info("计算后的战力 %d",self._currFight)
        self:setCurrFight()
        self:setSolderCount(nil,nil,fromType)
    else
        self:setCurrFight()
        self:setSolderCount()    
        self:setCurrWeight()
        self:updateWorldNeedInfo() --刷新粮食消耗
    end
end

function UITeamMiPanel:getWhichPosEnable(pos)  --根据坑位判断当前的wight是否开放
    return self._posMap[pos].isOpen    
end

function UITeamMiPanel:setTargetCity( name )  --行军目标
    if self._type == 3 or self._type == 7 then --演武场/群雄逐鹿报名 不显示
        return
    end
    -- self:setCurRichInfo(1,name)

    local data = {}
    data.icon = 1
    data.str = name

    self:setTopState(1,data)
end

--firstValue  --叠加一个军师先手值。默认0
function UITeamMiPanel:setFirstNumber( firstValue )  --先手值

    if firstValue == nil then
        if self._consuId ~= nil and self._consiProxy:getInfoById(self._consuId) ~= nil then
            local configLvData = self._consiProxy:getConfLvById( self._consuId )
            firstValue = configLvData.firstnum
        end

        firstValue = (firstValue or 0) + self._soldierProxy:getTotalFirstnum()
    end

    local data = {}
    data.icon = 2
    data.str = firstValue or 0

    self:setTopState(2,data)
end

function UITeamMiPanel:setSolidertime(time) --行军时间
    self._solidertime = time
    if self._type == 7 then --群雄逐鹿报名 不显示
        time = nil
    elseif type(time) == type(0) then
        time = TimeUtils:getStandardFormatTimeString8(time)
    else
        time = nil
    end
    -- self:setCurRichInfo(2,time)
    local data = {}
    data.icon = 4
    data.str = time

    self:setTopState(4,data)
end

function UITeamMiPanel:setSolderCount(curNum,maxNum,fromType)  --带兵数量
    if self.isTeamModule and fromType == nil then
        maxNum = maxNum
    else
        local count = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)  --每个坑位的佣兵出战上线数目
        if self._consuId ~= nil then
            local adviserData = self._consiProxy:getInfoById(self._consuId)
            if adviserData ~= nil then
                local adviserCommand = self._soldierProxy:getAdviserCommand(adviserData)
                count = adviserCommand + count
            else
                self._consuId = nil
            end
        end
        curNum = self._totalSolsiers
        maxNum = count*self._totalKen

        if fromType == 1 then
            if curNum > maxNum then
                maxNum = curNum
            end
        end
    end


    local data = {}
    data.isShow = true
    data.isRich = true
    data.str = curNum
    data.str2 = "/" .. maxNum
    self:updateTopInfo(2,data)
end

function UITeamMiPanel:setQXZLSolderCount(curNum,maxNum)  --群雄逐鹿带兵数量
    local data = {}
    data.isShow = true
    data.isRich = true
    data.str = curNum
    data.str2 = "/"..maxNum
    self:updateTopInfo(2,data)
end

function UITeamMiPanel:setCurrWeight(weight)  --部队载重
    if self._type == 3      --演武场 不显示
    or self._type == 4      --世界boss 不显示
    or self._type == 7 then --群雄逐鹿报名 不显示
        return
    end

    weight = weight or self._currWeight
    local str = StringUtils:formatNumberByK(weight)
    -- self:setCurRichInfo(4,str)
    local data = {}
    data.icon = 3
    data.str = str
    self:setTopState(3,data)
end

function UITeamMiPanel:setCurrStatus(status)  --部队状态
    local data = {}
    data.icon = 6
    data.str = status

    self:setTopState(6,data)
end


function UITeamMiPanel:initCCBPanel()
    if self._ccbFenWei == nil then
        self._ccbFenWei = self._parent:createUICCBLayer("rgb-szbd-fenwei", self._ccbPanel)
    end
end

function UITeamMiPanel:initTopInfo()
    self._topInfoList = { }
    self._topInfoBg = self._topPanel:getChildByName("infoBg")

    -- 第一行的控件
    for i = 1, 3 do
        local infoImg = self._topInfoBg:getChildByName("img" .. i)
        local infoTxt = self._topInfoBg:getChildByName("info" .. i)
        local infoTxt2 = self._topInfoBg:getChildByName("info" .. i .. i)
        infoImg:setVisible(false)
        infoTxt:setVisible(false)
        infoTxt2:setVisible(false)
        self._topInfoList["info" .. i] = { }
        self._topInfoList["info" .. i].infoImg = infoImg
        self._topInfoList["info" .. i].infoTxt = infoTxt
        self._topInfoList["info" .. i].infoTxt2 = infoTxt2
    end

    -- 第二行的控件
    for i = 1, 5 do
        local state = self._topPanel:getChildByName("state" .. i)
        state:setVisible(false)
        self._topInfoList["state" .. i] = { }
        self._topInfoList["state" .. i] = state
    end


end

--更新阵型数据
function UITeamMiPanel:updateWarBook()
    -- 阵型
    local panelWarBook = self._topPanel:getChildByName("panelWarBook")
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

-- 更新TOP数据和可见性 index=1战力，index=2部队数，index=3战损
function UITeamMiPanel:updateTopInfo(index, data)
    local topInfo = self._topInfoList["info"..index]
    if topInfo then
        topInfo.infoImg:setVisible(data.isShow)
        topInfo.infoTxt:setVisible(data.isShow)
        if data.isRich == true then
            topInfo.infoTxt:setString(data.str)
            topInfo.infoTxt2:setColor(ColorUtils.wordWhiteColor)
            topInfo.infoTxt2:setString(data.str2)
            topInfo.infoTxt2:setPositionX(topInfo.infoTxt:getPositionX() + topInfo.infoTxt:getContentSize().width)
            topInfo.infoTxt2:setVisible(true)
        else
            topInfo.infoTxt:setString(data.str)
            topInfo.infoTxt2:setVisible(false)
        end
    end
end

-- 更新state数据和图标
function UITeamMiPanel:updateTopStateInfo(index,data)
    local stateInfo = self._topInfoList["state"..index]
    if stateInfo then
        stateInfo:setVisible(true)
        -- local infoBg = panel:getChildByName("infoBg")
        local infoImg = stateInfo:getChildByName("infoImg")
        local infoTxt = stateInfo:getChildByName("infoTxt")
        local infoLab = stateInfo:getChildByName("labInfoTxt")


        --local url = string.format("images/component/Icon_team%d.png",data.icon)
        local url = self._iconsPath[data.icon]
        TextureManager:updateImageView(infoImg, url)
        infoTxt:setString(data.str)
        infoLab:setString(TextWords:getTextWord(self._iconsDescribe[data.icon]))
    end
end

-- 更新state数据和图标可见性
function UITeamMiPanel:updateTopStateInfoVisible(index)
    local stateInfo = self._topInfoList["state"..index]
    if stateInfo then
        stateInfo:setVisible(false)
    end
end

function UITeamMiPanel:clearTopInfo()
    -- 第二行的控件
    for i=1,5 do
        local state = self._topPanel:getChildByName("state"..i)
        state:setVisible(false)
    end
    self.topStateTab = {}
end

function UITeamMiPanel:setTopState(index,data)
    if self.topStateTab == nil then
        self.topStateTab = {}
        self.topStateTab[1] = nil
        self.topStateTab[2] = nil
        self.topStateTab[3] = nil
        self.topStateTab[4] = nil
        self.topStateTab[5] = nil
        self.topStateTab[6] = nil
    end

    if index ~= nil and data ~= nil and data.str ~= nil then
        self.topStateTab[index] = data  --更新数据
    elseif data == nil or data.str == nil then
        self.topStateTab[index] = nil
        self:updateTopStateInfoVisible(index)
    end

    local tmpTab = {}
    for k,v in pairs(self.topStateTab) do
        if type(v) == type(tmpTab) then
            table.insert(tmpTab,v)
        end
    end

    for i,info in pairs(tmpTab) do
        self:updateTopStateInfo(i,info)
    end
end

function UITeamMiPanel:setCurrFight(fightCap)  --战力的计算    
    fightCap = fightCap or self._currFight
    local data = {}
    data.isShow = true
    data.isRich = false
    data.color = cc.c3b(255,78,0)
    data.str = StringUtils:formatNumberByK3(fightCap)
    self:updateTopInfo(1,data)
end

function UITeamMiPanel:setSubBattleType(type)
    self._subBattleType = type
end

-- 计算战损：根据战斗类型读表
function UITeamMiPanel:calFightLost(fightType)
    -- self._type 表示之前传进来的战斗类型
    local type = fightType
    if type == 0 then
        type = self._sendType
        if self._type == 0 or self._type == 6 then -- self._type ==0 表示世界战斗 (应该区分攻击和防守才对)            
            type = GameConfig.battleType.world               --4是攻打资源点
        elseif self._type == 7 then -- TODO 取世界战斗的战损显示，世界战斗防守战损没处理            
            type = 8-- 群雄逐鹿
        elseif self._type == 16 or self._type == 17 then -- 盟战州城
            type = self._type
        elseif self._type == 18 or self._type == 19 then -- 皇城战
            type = self._type
        end
    end

    local lost = 0
    
    local lostOrRepairType = 1 -- 默认损兵1，伤兵2

    if self._type == 0 then
        if self._data.isPlayerRes == true then
            type = GameConfig.battleType.palyerRes
            self._subBattleType = 0
        elseif self._subBattleType <= 0 then
            type = GameConfig.battleType.world_def  --TODO 先写死了！！，没有子战斗类型的世界就当做攻打建筑的
        end
    end

    local info = ConfigDataManager:getInfoFindByTwoKey("FightControlConfig", "fighttype", type, "subtype", self._subBattleType)
    if info then
        if info.lostShow > 0 then
            lost = info.lostShow / 100

            if type == GameConfig.battleType.world 
                or type == GameConfig.battleType.world_def
                or type == GameConfig.battleType.palyerRes then

                if self._roleProxy:isFunctionUnLock(52, false) then  
                    if self._seasonProxy:isWorldLevelOpen() == true then
                        local worldLevelCfg = self._seasonProxy:getWorldLevelConfigData()
                        lost = lost - worldLevelCfg.worldLose / 100
                    end

                    if self._seasonProxy:isWorldSeasonOpen() == true then
                        local seasonCfg = ConfigDataManager:getInfoFindByOneKey(ConfigData.WorldSeasonConfig, "type", self._seasonProxy:getCurSeason())
                        lost = lost + seasonCfg.worldLose / 100
                    end
                end
            end
            lost = math.max( lost, 0)

            lostOrRepairType = 1 -- 损兵1
        elseif info.repairShow > 0 then 
            lost = info.repairShow / 100
            lostOrRepairType = 2 -- 伤兵2
        end
    end

    return lost, lostOrRepairType
end

-- 显示战损
function UITeamMiPanel:showLostInfo(isShow, fightType)
    local count, lostOrRepairType = self:calFightLost(fightType) 

    local lostStr = nil
    if lostOrRepairType == 1 then 
        --损兵1
        lostStr = TextWords[625]
    else  
        --伤兵
        lostStr = TextWords[626]
    end   
    local img3 = self._topInfoBg:getChildByName("img3")
    img3:setString(lostStr)

    local data = { }
    data.isShow = isShow
    data.isRich = false
    data.color = cc.c3b(255, 78, 0)
    data.str = count .. "%"
    self:updateTopInfo(3, data)
end


-- 刷新粮食消耗信息
function UITeamMiPanel:updateWorldNeedInfo(  )
    local str
    if self._type == 0 then  --世界地图攻打玩家/矿点才显示
        -- print("刷新粮食消耗信息   11")
        str,_ = self:getWorldNeedRes()
    else
        str = nil
    end

    local data = {}
    data.icon = 5
    data.str = str

    self:setTopState(5,data)
end

-- 计算粮食消耗
function UITeamMiPanel:getWorldNeedRes( ... )
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

function UITeamMiPanel:addButtonAction()
    if self._btnEffect == nil then
        self._btnEffect = UICCBLayer.new("rpg-button-light", self._maxFightBtn )
        local size = self._maxFightBtn:getContentSize()
        self._btnEffect:setPosition(size.width/2, size.height/2)
    else
        self._btnEffect:setVisible(true)
    end
end

function UITeamMiPanel:getTeamByPos(pos)
    for i = 1 ,6 do
        local item = self._movePanel:getChildByName("imgPos"..i)
        if item.pos == pos then
            return item
        end
    end  
end

function UITeamMiPanel:setTeamSuoStatus(pos,isShow,lv)
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
    --local AtlasLabel = item:getChildByName("AtlasLabel")  --数字标签
    local imgNum = item:getChildByName("imgNum")  
    if isShow == true then
        local suoLabel = suoImg:getChildByName("suoLabel")
        suoLabel:setString(lv..TextWords[7057])
        --AtlasLabel:setVisible(false)
        imgNum:setVisible(false)
    else
        --AtlasLabel:setString(item.pos)
        TextureManager:updateImageView(imgNum, "images/team/" .. item.pos .. ".png")
    end
end

function UITeamMiPanel:setOpenPosBylevel(level) -- 根据指挥官等级设置槽位的开放

    local index = 0
    for pos = 1,6 do
        local flag, notOpenInfo = self._soldierProxy:isTroopsOpen(pos)
        if flag then
            self._posMap[pos].isOpen = true
            self:setTeamSuoStatus(pos, false, notOpenInfo)
            index = index + 1
        else
            self._posMap[pos].isOpen = false
            self:setTeamSuoStatus(pos, true, notOpenInfo)
        end
        
        local item = self._movePanel:getChildByName("imgPos"..pos)
        --local atlasLabel = item:getChildByName("AtlasLabel")     
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
    self:onFirstSelect()
    
    if self.isTeamModule ~= true then
        self:setSolderCount()
    end
end

function UITeamMiPanel:onFirstSelect()
    for index = 1,6 do
        if self._posMap[index].isOpen == true then
            local item = self:getTeamByPos(index)
            if item ~= self._selectTeam then
                -- if self._selectTeam ~= nil then
                --     self:setTeamSelectStatusByTeam(self._selectTeam,false)
                -- end 
                self._selectTeam = item
                self:setTeamSelectStatusByTeam(item,false)
            end
            break
        end
    end
end

function UITeamMiPanel:setTeamSelectStatusByTeam(item,isShow)
    -- local selectImg = item:getChildByName("selectImg")
    -- selectImg:setVisible(isShow)
    ComponentUtils:setTeamSelectStatusByTeam(item,isShow)
end

--出战前检查数据 防止为空
--@param isSysMessage 如果没有出战单位，是否要飘提示，默认不飘
function UITeamMiPanel:checkFightPosMap(isSysMessage)
    isSysMessage = isSysMessage or false
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
    
    if isHaveSoldier and isSysMessage then
        self._parent:showSysMessage(TextWords[747])
        return
    end
    return data
end

function UITeamMiPanel:onPopTouch(pos)
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
        local serverListData = self._soldierProxy:onShowEveryPosCount(self._fightPosMap)
        if serverListData ~= nil then
            -- local adviserId
            local adviserData = self._consiProxy:getInfoById(self._consuId)
            -- if adviserData ~= nil then
            --     adviserId = adviserData.typeId
            -- end
            if self._UITeamMessPanel == nil then
                self._UITeamMessPanel = UITeamMessPanel.new(self,serverListData,pos, self.setPuppetById, adviserData)
            else
                self._UITeamMessPanel:updateData(serverListData, pos, adviserData)
            end
        end
    else
        self:setPuppetById(pos,0,0) --隐藏pupplt
    end
end

--更新点开套用阵型所需的数据
function UITeamMiPanel:updateSetTeamData(pos, num, typeid)
    -- self._setTeamData = self._setTeamData or {}
    -- for k,v in pairs(self._setTeamData) do
    --     if self._setTeamData[k].post == pos then
    --         self._setTeamData[k].num = num
    --         self._setTeamData[k].typeid = typeid
    --     end
    -- end
end

function UITeamMiPanel:getProxy(name)
    return self._parent:getProxy(name)
end

function UITeamMiPanel:changeTeamPos(team)
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
function UITeamMiPanel:onIsOpenConsu(isShowMsg,customMsg)  --24级开启军师
    local isUnlock = self._roleProxy:isFunctionUnLock(45,isShowMsg,customMsg)
    self:showIsUnlockConsu(isUnlock)
    return isUnlock
end

function UITeamMiPanel:showIsUnlockConsu(isUnlock)
    self:onShowConsuSuoImg(not isUnlock)

    local consuData = {}
    consuData.icon = 999
    consuData.infoImgShow = false
    consuData.suoImgShow = not isUnlock
    self:updateConsuPos(consuData)

end

function UITeamMiPanel:onShowConsuImgById(id, adviserLv)  --显示上阵军师的图片
    local icon = 999
    local name = ""
    local infoImgIsShow,starNo,quality
    if id then
        local consiData = self._consiProxy:getInfoById(id)
        if consiData ~= nil then
            self._consuId = id
            local typeId = consiData.typeId
            local configData = self._consiProxy:getDataById(typeId)
            infoImgIsShow = configData ~= nil
            starNo = adviserLv or consiData.lv
            print("... 显示军师 ", adviserLv,consiData.lv)
            if configData ~= nil then
                icon = 0
                name = configData.name
                quality = configData.quality
                infoImgIsShow = true
            end
            -- local configLvData = self._consiProxy:getConfLvById( id )
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

--驻军别人的军师ID自己没有那只军师
function UITeamMiPanel:setAdviserData(starNo, typeid)
    local configData = self._consiProxy:getDataById(typeid)
    if configData == nil then
        local consuData = {}
        consuData.icon = 999
        consuData.name = ""
        consuData.infoImgShow = false
        self:updateConsuPos(consuData)
        return
    end
    local consuData = {}
    consuData.icon = 0
    consuData.name = configData.name
    consuData.quality = configData.quality
    consuData.starNo = starNo
    consuData.infoImgShow = true
    self:updateConsuPos(consuData)
end

function UITeamMiPanel:onClickConsuHandle(sender)
    if self:onIsOpenConsu(true,TextWords:getTextWord(772)) == true then
        if self._consuId and self._consiProxy:getInfoById(self._consuId) ~= nil then
            -- print("................ -- 有军师 . ")
            local consuData = {}
            consuData.icon = 999
            consuData.infoImgShow = false
            self:updateConsuPos(consuData)
            self._consuId = nil

            self._soldierProxy:soldierMaxFightChange()
            -- --去掉军师，重算带兵量
            self._soldierProxy:setMaxFighAndWeight("")
            -- local data = nil
            -- if self._maxFightBtn:isVisible() then
            --     data = self._soldierProxy:getMaxWeight()
            -- else
            --     data = self._soldierProxy:getMaxFight()
            -- end
            self:updateSoliderNum()            

            self:setFirstNumber() --重新计算先手值
        else
            -- 弹窗选择军师上阵
            -- print("................ -- 弹窗选择军师上阵. ")
            if not self._uiAdviserListPanel then
                local strTitle = self._parent:getTextWord( 270072 )
                self._uiAdviserListPanel = UIAdviserList.new( self._parent, strTitle )
            end
            self._uiAdviserListPanel:show( self, self.onConsuGoCallback )
        end
    end
end

--侦查报告只发了typeid  要拿typeid来更新军师的信息
-- 只发了typeid，那暂不显示星级吧
function UITeamMiPanel:onUpdateAdviser(typeId, lv)
    local configData = self._consiProxy:getDataById(typeId)
    -- local consiInfo = self._consiProxy:getInfoByTypeId(typeId)

    if configData == nil then
        local consuData = {}
        consuData.icon = 999
        consuData.infoImgShow = false
        self:updateConsuPos(consuData)
        return
    end

    -- print("................. --侦查报告 ",typeId,configData.name)

    local consuData = {}
    consuData.icon = 0
    consuData.starNo = lv or 0
    consuData.infoImgShow = true
    consuData.name = configData.name
    consuData.quality = configData.quality
    self:updateConsuPos(consuData)
end

--军师显示信息
--[[
    -- 数据结构
    -- local consuData = {}
    -- consuData.icon = 军师图片 (0显示默认军师图片，999显示空图)
    -- consuData.name = 军师名字
    -- consuData.quality = 军师品质
    -- consuData.starNo = 星数 (0隐藏星数，大于0显示星数)
    -- consuData.infoImgShow = 是否显示军师信息
]]
function UITeamMiPanel:updateConsuPos(data)
    ComponentUtils:updateConsuPos(self._parent, self._consuImg, data)
end

-- 军师坑位点击状态
function UITeamMiPanel:setConsuPosEnable(enable)
    if self._consuImg and enable ~= nil then
        self._consuImg:setTouchEnabled(enable)
    end
end


-- 军师解锁图片
function UITeamMiPanel:onShowConsuSuoImg(status)
    local suoImg = self._consuImg:getChildByName("suoImg")
    suoImg:setVisible(status)
end

function UITeamMiPanel:onConsuGoCallback( AdviserInfo )
    local conf = self._consiProxy:getDataById( AdviserInfo.typeId )
    self:onConsuGoReq(AdviserInfo)
    return true
end

-------------------------------------------------------------------------------
-- 军师上阵显示处理 end
-------------------------------------------------------------------------------

function UITeamMiPanel:onShowConsuImg(data, adviserLv)
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
        self:onShowConsuImgById(id, adviserLv)
    end
end

function UITeamMiPanel:onConsuGoReq(data)  --军师上阵
    self._soldierProxy:soldierMaxFightChange()
    self._soldierProxy:setMaxFighAndWeight(data.id)
    self:onShowConsuImgById(data.id)
    -- self:setSoliderList()
    -- local info = nil
    -- if self._maxFightBtn:isVisible() then
    --     info = self._soldierProxy:getMaxWeight()
    -- else
    --     info = self._soldierProxy:getMaxFight()
    -- end
    -- self:setSoliderList(info)  --加上军师 计算战力
    self:updateSoliderNum()
    self:setFirstNumber() --重新计算先手值
end

function UITeamMiPanel:onCheckConsuData(data) --检查军师数据,防止军师都派出去了
    -- local info = clone(data)
    -- local id = nil
    -- for _,v in pairs(info) do
    --     if v.post == 9 or v.post == 19 then
    --         if v.pos ~= 0 then
    --             info[k] = nil
    --         end
    --         break
    --     end 
    -- end
    -- return info
end

function UITeamMiPanel:getParent()
    return self._parent
end

function UITeamMiPanel:getProxy(name)
    return self._parent:getProxy(name)
end

function UITeamMiPanel:onSetArenaUi()  --演武场ui的修改
    local TopPanel = self._uiSkin:getChildByName("TopPanel")
    self._squreBtn:setTitleText(TextWords:getTextWord(758))

    self:setTargetCity(TextWords:getTextWord(1908))
end

function UITeamMiPanel:onUpdateWinCount(count,isShow)
    self._tipTxt:setVisible(not isShow)
    self._winTxt:setVisible(isShow)
    self._countTxt:setVisible(isShow)
    if isShow then
        self._countTxt:setString(count)
    end
end


function UITeamMiPanel:onSetInfosUi()  --部队详情的界面特殊处理
    local DownPanel = self._uiSkin:getChildByName("DownPanel")
    DownPanel:removeFromParent()
    -- 部队界面要求留背景图...
    if self._type ~= 6 then
        local Image_105 = self._uiSkin:getChildByName("Image_105")
        Image_105:removeFromParent()
    end
end

function UITeamMiPanel:getUiSkin()
    return self._uiSkin
end

function UITeamMiPanel:onGetUIDownPanel()
    return self._uiSkin:getChildByName("DownPanel")
end

--世界boss特殊调整背景图尺寸
function UITeamMiPanel:adjustBgImg()
    local Image_105 = self._uiSkin:getChildByName("Image_105")
    Image_105:setVisible(false)
    -- local Image_105_0 = self._uiSkin:getChildByName("Image_105_0")
    -- Image_105_0:setVisible(true)
end

function UITeamMiPanel:adaptiveBgImg()  --背景图的自适应
    local upWidget = self.tabsPanel or self._posTopPanel
    NodeUtils:adaptivePanelBg(self._bgImg, GlobalConfig.downHeight, upWidget)
end

--选择了套用阵型，回调更新阵型的位置
function UITeamMiPanel:onUpdateTeamPos(data)
    if self._uiSkin:isVisible() ~= true then
        return
    end

    local info,_ = self:checkAdviserData(data)

    self:setSoliderList(nil)
    self:onShowConsuImg(info)
    self:setSoliderList(info)
    self:onProtectOwerCity()
    self:setFirstNumber()
end


--获取最大战力按钮
function UITeamMiPanel:getMaxFightBtn()
    return self._maxFightBtn
end

--获取出战按钮
function UITeamMiPanel:getFightBtn()
    return self._fightBtn
end

--获取出战按钮
function UITeamMiPanel:getProtectBtn()
    return self._protectBtn
end

--侦查战报，不能根据原来的逻辑来判断槽位是否开放，要额外处理
function UITeamMiPanel:updatePosOpenStatus(posData)
    for pos = 1,6 do

        -- local flag, notOpenInfo = self._soldierProxy:isTroopsOpen(pos)
        -- flag = (posData[pos] ~= false and posData[pos] ~= nil)
        -- self._posMap[pos].isOpen = flag
        self:setTeamSuoStatus(pos, false, notOpenInfo)
        local item = self._movePanel:getChildByName("imgPos"..pos)
        item:getChildByName("imgNum"):setVisible(true)
    end
end

-----
-- 设置翻转
function UITeamMiPanel:setTeamPanelFlip()
    local winSize = self._movePanel:getContentSize()
    local state = false
    -- 翻转开关限制,军师图标坐标
    if self._consuImg:getPositionX() == 3 then
        state = true
    end

    for i = 1, 6 do
        local item = self._movePanel:getChildByName("imgPos" .. i)
        if state then
            local diffPosX = item:getPositionX() - winSize.width / 2
            item:setPosition(item:getPositionX() - diffPosX * 2, item:getPositionY())
        end
        -- 翻转兵种
        item:getChildByName("dot"):setFlippedX(true)
    end

    if state then
        self._consuImg:setPosition(winSize.width - self._consuImg:getPositionX(), self._consuImg:getPositionY())
        self._consuImg:getChildByName("dot"):setFlippedX(true)
    end

end

-- 设置movepanel显示层的显示状态
function UITeamMiPanel:setMovePanelVisible(args)
    self._movePanel:setVisible(args)
end

--上阵军师和去掉军师的时候，更新兵力
function UITeamMiPanel:updateSoliderNum()
    local command = 0
    local firstValue = 0

    local data = self._consiProxy:getInfoById(self._consuId)
    if self._consuId == nil or data == nil then
        command = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)
    else
        firstValue = self._soldierProxy:getAdviserCommand(data)
        command = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)
    end

    if self._lastCommand == nil then
        self._lastCommand = firstValue
    end

    self._totalSolsiers = 0 --当前出战的总兵力
    self._currWeight = 0  --当前的载重
    self._currFight = 0   --当前的战力

    local allSoldierNum = {}
    for k,v in pairs(self._fightPosMap) do
        if v.post ~= 9 and v.post ~= 19 then
            allSoldierNum[v.typeid] = self._soldierProxy:getSoldierCountById(v.typeid)
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
            
            if firstValue == 0 then
                if v.num >= command then
                    v.num = command
                else
                    v.num = v.num - self._lastCommand
                    if v.num < 1 then
                        v.num = 1
                    end
                end
            elseif firstValue > 0 then
                if firstValue > self._lastCommand then
                    v.num = v.num + firstValue - self._lastCommand
                else
                    v.num = v.num + firstValue
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
            local fight = self._soldierProxy:getPosAllFight(v, AdviserInfo or {})
            self._currFight = self._currFight + fight
            self._currWeight = self._currWeight + self._soldierProxy:getOneSoldierWeightById(v.typeid) * v.num
            local team = self:getTeamByPos(v.post)
            ComponentUtils:updateSoliderPos(team, v.typeid, v.num, nil, nil, true, nil, false)
        end
    end

    self._lastCommand = firstValue

    
    --没兵的已经解锁的槽位也要计算军师战力
    for i=1,6 do
        if allPos[i] ~= true and self:getWhichPosEnable(i) then
            local AdviserInfo = self._consiProxy:getInfoById(self._consuId)
            self._currFight = self._currFight + self._soldierProxy:getPosAllFight({num = 0, typeid = 0, post = i}, AdviserInfo or {})
        end
    end

    self:setCurrFight()
    self:setSolderCount()    
    self:setCurrWeight()
    self:updateWorldNeedInfo() --刷新粮食消耗
end

--打开界面检查军师状态是否空闲
function UITeamMiPanel:checkAdviserData(data, isOpenArena)
    data = data or {}
    local info = clone(data)
    local adviserCommand = 0
    local adviserLv = nil
    --检查阵型中的军师是否处于非空闲状态，是的话去掉这个军师的数据，重新算先手值，减少兵的数量
    for k,v in pairs(info) do
        if v.post == 9 or v.post == 19 then
            local id = rawget(v, "id")
            if id == nil then
                id = rawget(v, "adviserId")
            end

            local advInfo = self._consiProxy:getInfoById(v.adviserId)  --获取最新的军师信息
            -- print("... 获取最新的军师信息",v.post,advInfo.lv,advInfo.pos,advInfo.typeId)

            if advInfo ~= nil then
                --[[ 先注释掉演武场上次阵型相关代码
                adviserLv = advInfo.lv
                print("... 是否有军师 ",adviserLv,isOpenArena)
                if isOpenArena then
                    if rawget(v, "lv") then
                        advInfo.lv = v.lv
                        adviserLv = v.lv
                        print("... --演武场阵型中的军师 ",v.adviserId,advInfo.lv,v.lv)
                    end
                end
                ]]

                if advInfo.pos ~= 0 then
                    adviserCommand = self._soldierProxy:getAdviserCommand(advInfo)
                    info[k] = nil
                    break
                end

            else
                local advInfo = {typeId = v.adviserId, lv = adviserLv}
                adviserCommand = self._soldierProxy:getAdviserCommand(advInfo)
                info[k] = nil
                break
            end


        end
    end

    if adviserCommand ~= 0 then
        for k,v in pairs(info) do
            -- print("...检测军师 佣兵数量变化？？", v.post, v.num, adviserCommand)
            v.num = v.num - adviserCommand
            v.num = v.num < 0 and 0 or v.num
        end
    end
    return info,adviserLv
end

--显示默认pve阵型: 战斗类型为（战役、远征、世界战斗、剿匪、乱军）时
function UITeamMiPanel:updatePveTeamPos(uiType)
    if uiType == nil or uiType == 2 then
        return
    end

    local isPve = self._soldierProxy:isPve(uiType)
    if isPve ~= true then
        logger:info("UITeamMiPanel 打印pve阵型信息 isPve=false ")
        return
    end

    local data = self._soldierProxy:getPveTeamInfo()
    -- for k,v in pairs(data.members) do
    --     logger:info("UITeamMiPanel 打印pve阵型信息 %d %d %d %d",k,v.typeid,v.num,v.post)
    -- end
    
    self:setSoliderList(nil)
    self:onShowConsuImg(data.members)
    self:setSoliderList(data.members)
end

function UITeamMiPanel:isShowRechargeUI(sender)
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
