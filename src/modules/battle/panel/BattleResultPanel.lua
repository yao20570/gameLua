BattleResultPanel = class("BattleResultPanel", BasicPanel)
BattleResultPanel.NAME = "BattleResultPanel"
BattleResultPanel.PANEL_ACTION_TIME = 1500 -- 界面动作执行时间
function BattleResultPanel:ctor(view, panelName)
    BattleResultPanel.super.ctor(self, view, panelName)
    self.btnModuleList = {
        ModuleName.HeroModule,                 --武将
        ModuleName.ScienceMuseumModule,         --科技ScienceMuseumModule
        ModuleName.BarrackModule,               --兵营
        ModuleName.PersonInfoModule,            --主公
        ModuleName.TeamModule                   --部队
    }
    --self.movieStar = {}
    self:setUseNewPanelBg(true)

    -- self.isAllKill = nil
end

function BattleResultPanel:finalize()
    -- self._spineModel:finalize()
    -- self.isAllKill = nil
    BattleResultPanel.super.finalize(self)
end

function BattleResultPanel:initPanel()
    BattleResultPanel.super.initPanel(self)

    self._vBg_bg = self:getChildByName("panelContainer/panelNode/mainPanel/vBg_bg")
    self._fBg_bg = self:getChildByName("panelContainer/panelNode/mainPanel/fBg_bg")
--    self._vImg = self:getChildByName("panelContainer/panelNode/mainPanel/vImg")
    self._winBgImg = self:getChildByName("panelContainer/panelNode/mainPanel/winBgImg")
    self._winBgImg0 = self:getChildByName("panelContainer/panelNode/mainPanel/winBgImg_0")
    self._winWordImg1 = self:getChildByName("panelContainer/panelNode/mainPanel/winWordImg_1")
    self._winWordImg2 = self:getChildByName("panelContainer/panelNode/mainPanel/winWordImg_2")
    self._fImg = self:getChildByName("panelContainer/panelNode/mainPanel/fImg")
    self._mainPanel = self:getChildByName("panelContainer/panelNode/mainPanel")
    self._boy = self:getChildByName("panelContainer/panelNode/mainPanel/Panel_boy")
    self._girl = self:getChildByName("panelContainer/panelNode/mainPanel/Panel_girl")

    self._failTxt = self:getChildByName("panelContainer/panelNode/mainPanel/rewardPanel/failTxt")

    self._newLostShow=self:getChildByName("panelContainer/panelNode/mainPanel/newLostShow")
end

function BattleResultPanel:playAnimation(data, callback)
    -- body
    if data == 0 then
        self:playAction("battle_win", callback)
        --self:setWinLight()--根据需求已经弃用
        self._vBg_bg:setLocalZOrder(0)
    else
        self:playAction("battle_lose", callback)
        self._fBg_bg:setLocalZOrder(0)
    end
end

function BattleResultPanel:onHideHandler()
    self["exitBtn"] = nil
end

function BattleResultPanel:isLostTipsVisible(isLose)
    --for i=1, 5 do
    --    self._button[i]:setVisible(isLose)
    --    self._buttonBg[i]:setVisible(isLose)
    --end
--    self._img2:setVisible(isLose)
--    self._img3:setVisible(isLose)
    local isShowLoseTips = isLose and (self._failTxt:isVisible() == false)
    self._loseTipsTxt:setVisible(isShowLoseTips)
    self._loseTipsTxt:stopAllActions()
    if isShowLoseTips == true then
        self._loseTipsTxt:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 50), cc.FadeTo:create(0.5, 255))))
    end
end

function BattleResultPanel:_onLoseBtnTouch(sender)
    self:isLostTipsVisible(false)
    self:dispatchEvent(BattleEvent.HIDE_SELF_EVENT, {})
   if sender.index == 3 then   --兵营
        ModuleJumpManager:jump(self.btnModuleList[sender.index]..9, "BarrackRecruitPanel")
    elseif sender.index == 2 then  --太学院
        ModuleJumpManager:jump(self.btnModuleList[sender.index], "ScienceResearchPanel")
    elseif sender.index == 5 then   --部队
        local function _delayShowTeam()
            ModuleJumpManager:jump( ModuleName.TeamModule, "TeamReparePanel")
            _delayShowTeam = nil        
        end
        TimerManager:addOnce(500, _delayShowTeam,sender)
    else
        self.view:dispatchEvent(BattleEvent.SHOW_OTHER_EVENT, self.btnModuleList[sender.index])
    end
end

function BattleResultPanel:loseTips()
    --战斗失败将奖励的item隐藏掉
    local rewardPanel = self:getChildByName("panelContainer/panelNode/mainPanel/rewardPanel")
    for index=1, 4 do
        local iconContainer = rewardPanel:getChildByName("item" .. index)
        iconContainer:setVisible(false)
    end
    self._newLostShow:setVisible(true)

    --//null 增加酒馆和兵营的跳转
    local winebtn=self._newLostShow:getChildByName("wineBtn")
    self:addTouchEventListener(winebtn,self.wine)
    local soiderClubBtn=self._newLostShow:getChildByName("soiderClubBtn")
    self:addTouchEventListener(soiderClubBtn,self.soidler)
    --if self._button == nil then
    --    self._button = {}
    --    self._buttonBg = {}
    --    local url = {}
    --    url[1] = "images/battleIcon/Icon_Generals_none.png"
    --    url[2] = "images/battleIcon/Icon_Research.png"
    --    url[3] = "images/battleIcon/Icon_train.png"
    --    url[4] = "images/battleIcon/Icon_master.png"
    --    url[5] = "images/battleIcon/Icon_force_none.png"
    --    for i=1, 5 do
    --        self._buttonBg[i] = ccui.ImageView:create()
    --        --有合适背景图再换上
    --        -- self._buttonBg[i]:loadTexture("images/toolbar/Frame_square.png", ccui.TextureResType.plistType)
    --        self._buttonBg[i]:setAnchorPoint(cc.p(0.5, 0.5))
    --        self._buttonBg[i]:setPosition(20 + 100 * i,10)
    --        rewardPanel:addChild(self._buttonBg[i])
    --        self._button[i] = ccui.Button:create()
    --        self._button[i].index = i
    --        self._button[i]:loadTextures(url[i], url[i], "", 1)
    --        self._button[i]:setAnchorPoint(cc.p(0.5, 0.5))
    --        self._button[i]:setPosition(20 + 100 * i,10)
    --        rewardPanel:addChild(self._button[i])
    --        self:addTouchEventListener(self._button[i],self._onLoseBtnTouch)
    --    end
        self._loseTipsTxt = ccui.Text:create()
        self._loseTipsTxt:setFontName(GlobalConfig.fontName)
        self._loseTipsTxt:setFontSize(20)
        self._loseTipsTxt:setColor(ColorUtils:color16ToC3b("#2BA532"))
        --self._loseTipsTxt:setAnchorPoint(cc.p(0, 0.5))
        self._loseTipsTxt:setPosition(320, -300)
        self._loseTipsTxt:setString("尝试提升战力吧")        
        self._newLostShow:addChild(self._loseTipsTxt)
    --    rewardPanel:addChild(self._loseTipsTxt)
--        local imgUrl2 =  "images/toolbar/Info_Research.png"
--        local imgUrl3 =  "images/toolbar/Info_Train.png"
--        self._img2 = ccui.ImageView:create()
--        self._img3 = ccui.ImageView:create()
--        self._img2:loadTexture(imgUrl2, ccui.TextureResType.plistType)
--        self._img3:loadTexture(imgUrl3, ccui.TextureResType.plistType)
--        self._img2:setAnchorPoint(cc.p(0.5, 0.5))
--        self._img3:setAnchorPoint(cc.p(0.5, 0.5))
--        self._img2:setPosition(200, -15)
--        self._img3:setPosition(300, -15)
--        rewardPanel:addChild(self._img2)
--        rewardPanel:addChild(self._img3)
    
--    end
     self:isLostTipsVisible(true)
end

function BattleResultPanel:wine(sender)
    self:dispatchEvent(BattleEvent.HIDE_SELF_EVENT, {})
    self.view:dispatchEvent(BattleEvent.SHOW_OTHER_EVENT, ModuleName.PubModule)
end

function BattleResultPanel:soidler(sender)
    self:dispatchEvent(BattleEvent.HIDE_SELF_EVENT, {})
    ModuleJumpManager:jump(ModuleName.BarrackModule, "BarrackRecruitPanel")
end
function BattleResultPanel:onReplayReq(sender)
    if sender.id == nil then
        return
    end
    local battleProxy = self:getProxy(GameProxys.Battle)
    local battleData = battleProxy:getBattleDataById(sender.id)
    if battleData ~= nil then
        local data2 = {}
        battleProxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.BattleModule})
        battleProxy:onTriggerNet50000Resp(battleData)
    end
    
    -- local battleId = StringUtils:int32ToFixed64(sender.id)
    -- mailProxy:onTriggerNet160005Req({battleId = battleId})
end

function BattleResultPanel:onUpdateBattleResult(data)
    self.battleType=data.battle.type

    local replayBtn = self:getChildByName("panelContainer/panelNode/mainPanel/replayBtn")
    replayBtn.id = data.battle.id
    self:addTouchEventListener(replayBtn, self.onReplayReq)

    local roleProxy = self:getProxy(GameProxys.Role)
    local name = roleProxy:getRoleName()   
    if name == "" or GameConfig.isNewPlayer == true then
        replayBtn:setVisible(false)  --新手阶段屏蔽重播按钮
    else
        if data.saveTraffic == 1 then --不看战斗, 隐藏重播按钮
            replayBtn:setVisible(false)
        else
            replayBtn:setVisible(true)
        end
    end


    local vBg_bg = self._vBg_bg 
    local fBg_bg = self._fBg_bg 
--    local vImg = self._vImg
    local fImg = self._fImg
    local winBgImg = self._winBgImg 
    local winBgImg0 = self._winBgImg0
    local winWordImg1 = self._winWordImg1
    local winWordImg2 = self._winWordImg2

    local newLostShow = self._newLostShow
    local rc = data.rc
    self._failTxt:setVisible(rc == 1 and data.failed == 1)

    if rc == 0 then
        AudioManager:playEffect("battle_win")
--        vImg:setVisible(true)
        fImg:setVisible(false)
        vBg_bg:setVisible(true)
        fBg_bg:setVisible(false)
        winBgImg:setVisible(true)
        winBgImg0:setVisible(true)
        winWordImg1:setVisible(true)
        winWordImg2:setVisible(true)
        newLostShow:setVisible(false)
      
    else
        AudioManager:playEffect("battle_lose")
--        vImg:setVisible(false)
        fImg:setVisible(true)
        vBg_bg:setVisible(false)
        fBg_bg:setVisible(true)
        winBgImg:setVisible(false)
        winBgImg0:setVisible(false)
        winWordImg1:setVisible(false)
        winWordImg2:setVisible(false)
        newLostShow:setVisible(true)
        if data.battle.type ~= GameConfig.battleType.legion 
            and data.battle.type ~= GameConfig.battleType.world_boss 
            and data.battle.type ~= GameConfig.battleType.arena then
            self:loseTips()
            self:flushNewLose()
            --战斗失败
        end
    end
    self:updateView(data)
    -- 不是世界boss战斗
    if data.battle.type ~= GameConfig.battleType.world_boss  then
        local battle = data.battle
        local numTxt = self:getChildByName("panelContainer/panelNode/mainPanel/numTxt")
        local loseTxt = self:getChildByName("panelContainer/panelNode/mainPanel/loseTxt")
        local dodgeTxt = self:getChildByName("panelContainer/panelNode/mainPanel/dodgeTxt")
        local critTxt = self:getChildByName("panelContainer/panelNode/mainPanel/critTxt")
        numTxt:setVisible(true)
        numTxt:setString(0)
        loseTxt:setString(0 .. "%")
        dodgeTxt:setString(0 .. "%")
        critTxt:setString(0 .. "%")
        local function beginSetNum()
            StringUtils:rollToTargetNum(numTxt, battle.totalSoldierNum, nil, 10, 20)
            StringUtils:rollToTargetNum(loseTxt,  battle.loseSoldierPercent, nil, 10, 20, "%")
            StringUtils:rollToTargetNum(dodgeTxt, battle.dodgePercent, nil, 10, 20, "%")
            StringUtils:rollToTargetNum(critTxt,  battle.critPercent, nil, 10, 20, "%")
        end
        -- 胜利界面动画执行时间1200
        TimerManager:addOnce(BattleResultPanel.PANEL_ACTION_TIME, beginSetNum, self)
        

        local rewardPanel = self:getChildByName("panelContainer/panelNode/mainPanel/rewardPanel")
        rewardPanel:setPositionY(-115)
        self:renderReward(rewardPanel, battle.reward, rc)
        --else
        --local replayBtn = self:getChildByName("panelContainer/panelNode/mainPanel/replayBtn")
        --local exitBtn = self:getChildByName("panelContainer/panelNode/mainPanel/exitBtn")
        --local fBg_bg = self:getChildByName("panelContainer/panelNode/mainPanel/fBg_bg")
        local Label_11=self:getChildByName("panelContainer/panelNode/mainPanel/Label_11")
        local numTxt=self:getChildByName("panelContainer/panelNode/mainPanel/numTxt")
        local txt=self:getChildByName("panelContainer/panelNode/mainPanel/txt")
        local txt_2=self:getChildByName("panelContainer/panelNode/mainPanel/txt_2")
        local txt_3=self:getChildByName("panelContainer/panelNode/mainPanel/txt_3")
        local loseTxt=self:getChildByName("panelContainer/panelNode/mainPanel/loseTxt")
        local dodgeTxt=self:getChildByName("panelContainer/panelNode/mainPanel/dodgeTxt")
        local critTxt=self:getChildByName("panelContainer/panelNode/mainPanel/critTxt")
        Label_11:setFontSize(20)
        numTxt:setFontSize(20)
        txt:setFontSize(20)
        txt_2:setFontSize(20)
        txt_3:setFontSize(20)
        loseTxt:setFontSize(20)
        dodgeTxt:setFontSize(20)
        critTxt:setFontSize(20)

     --   for i=1, 3 do
     --local starImg =self:getChildByName(string.format("panelContainer/panelNode/mainPanel/starImg%d_bg", i))
     --starImg:setVisible(false)
     --     end
        local tipTxt = self:getChildByName("panelContainer/panelNode/mainPanel/rewardPanel/tipTxt")
        tipTxt:setVisible(false)
  
    end

         --//null 判断是什么类型的失败
    if rc~=0 then
        print("------------------当前是什么类型的战斗失败"..data.battle.type)
        if data.battle.type ~= GameConfig.battleType.arena
            and data.battle.type ~= GameConfig.battleType.world_boss 
            and data.battle.type ~= GameConfig.battleType.legion 
            and data.battle.type ~= GameConfig.battleType.world_def
            and data.battle.type ~= GameConfig.battleType.qunxiong then
            self:showOtherLosePanel(true)
        else
            self:showOtherLosePanel(false)
        end
    else
        print("--------------------------------当前是什么类型的战斗胜利",data.battle.type)
        -- if data.battle.type == GameConfig.battleType.kill then
        --     local banditDungeonProxy = self:getProxy(GameProxys.BanditDungeon)
        --     self.isAllKill = banditDungeonProxy:getIsAllKill()
        -- end 
    end

--GameConfig.battleType.level = 1 --战役
--GameConfig.battleType.explore = 2 --探险
--GameConfig.battleType.arena = 3 --演武场
--GameConfig.battleType.world = 4 --世界战斗
--GameConfig.battleType.world_def = 5 --世界战斗防守
--GameConfig.battleType.legion = 6 --军团试炼场
--GameConfig.battleType.world_boss = 7 --世界Boss
--GameConfig.battleType.qunxiong = 8 --群雄逐鹿
--GameConfig.battleType.kill = 9 --剿匪
--GameConfig.battleType.west = 10 --西域远征


    self["exitBtn"] = nil
    local function callback()
        local exitBtn = self:getChildByName("panelContainer/panelNode/mainPanel/exitBtn")
    end

    self:playAnimation(rc, callback)
end

function BattleResultPanel:showOtherLosePanel(isNew)
        local replayBtn = self:getChildByName("panelContainer/panelNode/mainPanel/replayBtn")
        local exitBtn = self:getChildByName("panelContainer/panelNode/mainPanel/exitBtn")
        local fBg_bg = self:getChildByName("panelContainer/panelNode/mainPanel/fBg_bg")
        local Label_11=self:getChildByName("panelContainer/panelNode/mainPanel/Label_11")
        local numTxt=self:getChildByName("panelContainer/panelNode/mainPanel/numTxt")
        local txt=self:getChildByName("panelContainer/panelNode/mainPanel/txt")
        local txt_2=self:getChildByName("panelContainer/panelNode/mainPanel/txt_2")
        local txt_3=self:getChildByName("panelContainer/panelNode/mainPanel/txt_3")
        local loseTxt=self:getChildByName("panelContainer/panelNode/mainPanel/loseTxt")
        local dodgeTxt=self:getChildByName("panelContainer/panelNode/mainPanel/dodgeTxt")
        local critTxt=self:getChildByName("panelContainer/panelNode/mainPanel/critTxt")

        local newLostShow=self:getChildByName("panelContainer/panelNode/mainPanel/newLostShow")

        if isNew == true then
            Label_11:setVisible(false)
            numTxt:setVisible(false)
            txt:setVisible(false)
            txt_2:setVisible(false)
            txt_3:setVisible(false)
            loseTxt:setVisible(false)
            dodgeTxt:setVisible(false)
            critTxt:setVisible(false)

            newLostShow:setVisible(true)
        else

            Label_11:setVisible(true)
            Label_11:setFontSize(24)
            Label_11:setPositionY(60)

            numTxt:setVisible(true)
            numTxt:setPositionY(60)
            numTxt:setFontSize(24)

            txt:setVisible(true)
            txt:setPositionY(60)
            txt:setFontSize(24)

            txt_2:setVisible(true)
            txt_2:setPositionY(-30)
            txt_2:setFontSize(24)

            txt_3:setVisible(true)
            txt_3:setPositionY(-30)
            txt_3:setFontSize(24)

            loseTxt:setVisible(true)
            loseTxt:setPositionY(60)
            loseTxt:setFontSize(24)

            dodgeTxt:setVisible(true)
            dodgeTxt:setPositionY(-30)
            dodgeTxt:setFontSize(24)

            critTxt:setVisible(true)
            critTxt:setPositionY(-30)
            critTxt:setFontSize(24)

            local rewardPanel = self:getChildByName("panelContainer/panelNode/mainPanel/rewardPanel")
            rewardPanel:setPositionY(-165)

            newLostShow:setVisible(false)
        end
end

--//null 刷新实现数据 新版战斗失败界面
function BattleResultPanel:flushNewLose()
    self._roleInfo = self:getRoleInfo()                                                           --//null 获取角色信息
    local config
    local newLostShow=self:getChildByName("panelContainer/panelNode/mainPanel/newLostShow")
    local index
    for index=1,4 do
    local item=newLostShow:getChildByName("item"..index)
      local nameLab=item:getChildByName("nameLab")
      local haveLab=item:getChildByName("haveLab")
      local ProgressBar=item:getChildByName("ProgressBar")
      local perLab=item:getChildByName("perLab")
      
      if index==1 then
        config = ConfigDataManager:getConfigById(ConfigData.FightValueConfig,1)                     
        nameLab:setString(config.name)                                                            --//null name
        haveLab:setString(config.info1)                                                           --//null haveLab

        local numLab=item:getChildByName("numLab")
        local commanderLv = self._roleInfo.comBookNum
        numLab:setString(commanderLv)

        NodeUtils:alignNodeL2R(haveLab,numLab)

        local percent = self:getProgressByType(config.type)
        ProgressBar:setPercent(percent)
        local pStr = string.format("%.1f%%",percent)
        perLab:setString(pStr)

      elseif index == 2 then
        config = ConfigDataManager:getConfigById(ConfigData.FightValueConfig,7)
        nameLab:setString(config.name)
        local nameLab1=item:getChildByName("namelab1")
        local nameLab2=item:getChildByName("nameLab2")
        local nameLab3=item:getChildByName("nameLab3")
        local nameLab4=item:getChildByName("nameLab4")

        nameLab:setString(config.name)
        local percent = self:getProgressByType(config.type)
        ProgressBar:setPercent(percent)
        local pStr = string.format("%.1f%%",percent)
        perLab:setString(pStr)

        if percent >= 100 then
        haveLab:setString(config.info3)
        nameLab1:setVisible(false)
        nameLab2:setVisible(false)
        nameLab3:setVisible(false)
        nameLab4:setVisible(false)
        else
        nameLab1:setVisible(true)
        nameLab2:setVisible(true)
        nameLab3:setVisible(true)
        nameLab4:setVisible(true)

        haveLab:setString("最强制造兵:")
        local max = self._roleInfo.maxSoldiers*self._roleInfo.openPos
        local short = max - self._roleInfo.strongestSoldiers                                        --//最强兵还差数量            
        nameLab3:setString(short)                                                                   --//最强兵
        nameLab3:setColor(ColorUtils.wordYellowColor)
        local strongestSoldierName=self._roleInfo.strongestSoldierName
        nameLab1:setColor(ColorUtils.wordYellowColor)
        nameLab1:setString(strongestSoldierName)

        NodeUtils:alignNodeL2R(haveLab,nameLab1)
        NodeUtils:alignNodeL2R(nameLab1,nameLab2)
        NodeUtils:alignNodeL2R(nameLab2,nameLab3)
        NodeUtils:alignNodeL2R(nameLab3,nameLab4)
        end
      elseif index==3 then
        config = ConfigDataManager:getConfigById(ConfigData.FightValueConfig,2)
        nameLab:setString(config.name)
        haveLab:setString(config.info1)
        local numLab=item:getChildByName("numLab")

        local percent = self:getProgressByType(config.type)
        ProgressBar:setPercent(percent)
        local pStr = string.format("%.1f%%",percent)
        perLab:setString(pStr)

        local skillBookNum = self._roleInfo.skillBookNum
        numLab:setString(skillBookNum)

        NodeUtils:alignNodeL2R(haveLab,numLab)

      elseif index==4 then 
        config = ConfigDataManager:getConfigById(ConfigData.FightValueConfig,6)
        local numLab=item:getChildByName("numLab")
        nameLab:setString(config.name)
        numLab:setVisible(false)

        local percent = self:getProgressByType(config.type)
        ProgressBar:setPercent(percent)
        local pStr = string.format("%.1f%%",percent)
        perLab:setString(pStr)
      end
    end

end

--//null 参照国力界面 获角色信息
function BattleResultPanel:getRoleInfo()
    local data = {}
    local roleProxy = self:getProxy(GameProxys.Role)
    local soldierProxy = self:getProxy(GameProxys.Soldier)
    --角色等级
    data.level = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    --统帅等级
    data.commanderLv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_commandLevel)
    --最高战力
    data.fightingCap = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_highestCapacity)
    --繁荣度
    data.booming = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_boom)
    --带兵数量上限
    data.maxSoldiers = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)
    --开启槽位数
    data.openPos = #soldierProxy:getTroopsOpenPosList()
    --最强兵（战斗力最高）的数量及名字
    local soldier = self:getStrongestSoldier()
    data.strongestSoldiers = soldier.num
    data.strongestSoldierName = soldier.name
    --角色平均技能等级
    data.avgSkillLv = self:getRoleSkillInfo()
    --科技平均等级
    local scienceInfo = self:getAvgScienceLv()
    data.avgScienceLv = scienceInfo.avgScienceLv
    data.isAllScienceOpen = scienceInfo.isAllScienceOpen
    --统帅书，技能书
    data.comBookNum = roleProxy:getRolePowerValue(401,4013)
    data.skillBookNum = roleProxy:getRolePowerValue(401,4012)
    
    return data
end

--角色技能等级数据
function BattleResultPanel:getRoleSkillInfo()
    local skillProxy = self:getProxy(GameProxys.Skill)
    local skillList = skillProxy:getSkillListData()
    local avgSkillLv = 0
    if skillList ~= nil and #skillList > 0 then
        for _,v in pairs(skillList) do
            avgSkillLv = avgSkillLv + v.level
        end 
        avgSkillLv = avgSkillLv/#skillList
    end 
    return avgSkillLv
end 

--//null 获取百分比 参照国力界面
function BattleResultPanel:getProgressByType(type)
    
    local roleInfo = self._roleInfo
    local roleLv = roleInfo.level
    local openPos = roleInfo.openPos --开启槽位数
    local partsOpenNum = roleInfo.openPartsNum
    if openPos == 0 then --没有开启容错
        openPos = 1
    end
    if partsOpenNum == 0 then
        partsOpenNum = 1
    end
    local percent = 0
    if     type == 1  then --统帅等级：统帅书
        local commanderLv = roleInfo.commanderLv  
        percent = commanderLv/roleLv 
    elseif type == 2  then --技能等级：技能书
        percent = roleInfo.avgSkillLv/roleLv
    elseif type == 3  then --装备品质： 仓库中的装备数
        percent = roleInfo.allQualitys == 0 and 0 or roleInfo.equipQualitys/roleInfo.allQualitys
    elseif type == 4  then --装备升级：<100:装备可升级，>=100,装备已满级
        percent = roleInfo.allEquipLvs == 0 and 0 or roleInfo.equipLvs/roleInfo.allEquipLvs
    elseif type == 5  then --配件品质：仓库中的配件数
        percent = roleInfo.partsQualitys/(self._highestPartsQuality*4*partsOpenNum)
    elseif type == 6  then --配件强化：所有穿戴的配件的强化等级、角色等级
        percent = roleInfo.partsStrenLvs/(roleLv*4*partsOpenNum)
    elseif type == 7  then --配件改造：所有穿戴配件的改造等级 == 10级
        percent = roleInfo.partsRemLvs/(self._highestPartsRemLv*4*partsOpenNum)
    elseif type == 8  then --科技等级：8项战斗科技等级、角色等级
        percent = roleInfo.avgScienceLv/roleLv
    elseif type == 9  then --主力部队：
        percent = roleInfo.strongestSoldiers/(roleInfo.maxSoldiers*roleInfo.openPos)
    elseif type == 10 then --部队编制：
    
    elseif type == 11 then --繁荣战力：
        percent = (roleInfo.booming/600)/10
    end 
    percent = percent*100
--    print("type,percent===",type,percent)
    if percent > 100 then
        percent = 100
    end 
    return percent
end 

--//null 最强兵 参照国力界面
function BattleResultPanel:getStrongestSoldier()
    local temp = {}
    temp.num = 0
    local proxy = self:getProxy(GameProxys.Building)
    local dataList = proxy:getCanProductIdList(BuildingTypeConfig.BARRACK)
    local fightSort = {}
    if #dataList == 0 then
        return temp
    end
    local soldierProxy = self:getProxy(GameProxys.Soldier)
    for k,v in pairs(dataList) do    
        local fight = soldierProxy:getOneSoldierFightById(v)
        local num = soldierProxy:getSoldierCountById(v)
        table.insert(fightSort,{typeid = v,fight = fight,num = num})
--        print("fightSort===",k,v,fight,num)
    end
    table.sort(fightSort, function (a,b) return (a.fight > b.fight) end)
    if #fightSort > 0 then
        local data = fightSort[1]
        temp.num = data.num
        local configData = ConfigDataManager:getConfigData(ConfigData.ArmProductConfig)
        for _,v in pairs(configData) do 
            if v.ID == data.typeid then
                temp.name = v.name
                break
            end 
        end 
    end 
    return temp
end 

--//null 获取科技的平均等级
function BattleResultPanel:getAvgScienceLv()
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo  = buildingProxy:getBuildingInfo(8, 12)
    local temp = {}
    if buildingInfo == nil then
        temp.avgScienceLv = 0
        temp.isAllScienceOpen = false
        return temp
    end 
    local detailInfo = buildingInfo.buildingDetailInfos
    local scienceMuseumLv = buildingInfo.level --科技馆等级
    local types = {2,3,5,6,8,9,11,12}
    local scienceLvs = 0
    local isAllScienceOpen = false
    local configData = ConfigDataManager:getConfigData(ConfigData.MuseumConfig)
    for _,v in pairs(types) do
        local limitLv = 1
        for _,cv in pairs(configData) do
            if cv.scienceType == v then
                limitLv = cv.reqSCenterLv
                break
            end 
        end 
        for _,dv in pairs(detailInfo) do
            if dv.typeid == v then
                scienceLvs = scienceLvs + dv.num
                if scienceMuseumLv >=limitLv and scienceMuseumLv > dv.num then
                    isAllScienceOpen = true
                end 
                break
            end 
        end 
    end 
    local avgScienceLv =  scienceLvs/8
    temp.avgScienceLv = avgScienceLv
    temp.isAllScienceOpen = isAllScienceOpen
    return temp
end 



function BattleResultPanel:updateView(data)
    local curBtType = data.battle.type
    local MyDamage = data.damage
    local Label_11 = self:getChildByName("panelContainer/panelNode/mainPanel/Label_11")
    local numTxt = self:getChildByName("panelContainer/panelNode/mainPanel/numTxt")
    local txt_2 = self:getChildByName("panelContainer/panelNode/mainPanel/txt_2")
    local txt_3 = self:getChildByName("panelContainer/panelNode/mainPanel/txt_3")
    local txt = self:getChildByName("panelContainer/panelNode/mainPanel/txt")
    local loseTxt = self:getChildByName("panelContainer/panelNode/mainPanel/loseTxt")
    local dodgeTxt = self:getChildByName("panelContainer/panelNode/mainPanel/dodgeTxt")
    local critTxt = self:getChildByName("panelContainer/panelNode/mainPanel/critTxt")
    local tipTxt = self:getChildByName("panelContainer/panelNode/mainPanel/rewardPanel/tipTxt")
    local Label_11_0 = self:getChildByName("panelContainer/panelNode/mainPanel/Label_11_0")
    local txt_2_0 = self:getChildByName("panelContainer/panelNode/mainPanel/txt_2_0")


    -- 暂时屏蔽的2个按钮
    local collectBtn = self:getChildByName("panelContainer/panelNode/mainPanel/collectBtn")
    
    collectBtn:setVisible(false)
    -- replayBtn:setVisible(false)

    txt_3:setVisible(curBtType ~= GameConfig.battleType.world_boss)
    txt:setVisible(curBtType ~= GameConfig.battleType.world_boss)
    loseTxt:setVisible(curBtType ~= GameConfig.battleType.world_boss)
    dodgeTxt:setVisible(curBtType ~= GameConfig.battleType.world_boss)
    critTxt:setVisible(curBtType ~= GameConfig.battleType.world_boss)
    tipTxt:setVisible(curBtType ~= GameConfig.battleType.world_boss)
    Label_11:setVisible(curBtType ~= GameConfig.battleType.world_boss)
    Label_11_0:setVisible(curBtType == GameConfig.battleType.world_boss)
    txt_2_0:setVisible(curBtType == GameConfig.battleType.world_boss)
    txt_2:setVisible(curBtType ~= GameConfig.battleType.world_boss)
    if data.rc == 1 then
        self._fImg:setVisible(curBtType ~= GameConfig.battleType.world_boss)
        for i=1,3 do
            self:getChildByName(string.format("panelContainer/panelNode/mainPanel/starImg%d_bg", i)):setVisible(curBtType ~= GameConfig.battleType.world_boss)
            self:getChildByName(string.format("panelContainer/panelNode/mainPanel/starImg%d", i)):setVisible(curBtType ~= GameConfig.battleType.world_boss)
        end
    end
    -- 世界boss战斗中的数值显示
    if curBtType == GameConfig.battleType.world_boss then
        numTxt:setString(0) 
        local function beginSetNum()
            StringUtils:rollToTargetNum(numTxt, data.damage, nil, 10, 20)
        end
        -- 胜利界面动画执行时间
        TimerManager:addOnce(BattleResultPanel.PANEL_ACTION_TIME, beginSetNum, self)
        local rewardInfo = data.battle.reward.rewardInfo
        for i=1,4 do
            local rewardItem = self:getChildByName("panelContainer/panelNode/mainPanel/rewardPanel/item"..i)
 --           rewardItem:setVisible(rewardInfo[i] ~= nil)
            rewardItem:setVisible(true)
            if rewardInfo[i] ~= nil then
                local icon = rewardItem.icon
                if icon == nil then
                    icon = UIIcon.new(rewardItem, rewardInfo[i], true, self, _, _, _, _, BattleResultPanel.PANEL_ACTION_TIME)
                    rewardItem.icon = icon
                else
                    icon:updateData(rewardInfo[i])
                end
                icon:setIconCenter()
                icon:setShowName(true)
            end
        end
        --if data.rc == 1 then
        --    local index = 1
        --    while true do 
        --        if self.movieStar[index] ~= nil then
        --            self.movieStar[index]:setVisible(false)
        --        else
        --            break
        --        end
        --        index = index + 1
        --    end
        --else
        --    self:playAudio(data.battle.reward.star)
        --end
        self:playAudio(data.battle.reward.star)
    end
end


local handleWithArg = function(func,arg)
    local arg = arg
    local func = func
    return function(ref)
        func(ref,arg)
    end
end

function BattleResultPanel:playAudio(times)

    self.callFuncArg =  self.callFuncArg or {
        {actionName = "xing_1"},
        {actionName = "xing_2"},
        {actionName = "xing_3"},
    }


    local function starAction(node, value)
        self:playAction(value.actionName) 
    end
    local function audioEffect()
        AudioManager:playEffect("yx_PutStar")   
    end
    local function starLight(node, value)
        self:setStarLight(value.star) 
    end

    self._vBg_bg:stopAllActions()
   if times == 1 then
        local starAction1 = cc.Spawn:create(cc.CallFunc:create(handleWithArg(starAction, self.callFuncArg[1])), 
                                            cc.CallFunc:create(audioEffect), 
                                            cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(starLight, {star = 1})))
        self._vBg_bg:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), starAction1))
        --callback1()
    elseif times == 2 then
        --callback1()
        local starAction1 = cc.Spawn:create(cc.CallFunc:create(handleWithArg(starAction, self.callFuncArg[1])), 
                                            cc.CallFunc:create(audioEffect), 
                                            cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(starLight, {star = 1})))
        local starAction2 = cc.Spawn:create(cc.CallFunc:create(handleWithArg(starAction, self.callFuncArg[2])), 
                                            cc.CallFunc:create(audioEffect), 
                                            cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(starLight, {star = 2})))
        self._vBg_bg:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), starAction1, cc.DelayTime:create(0.1), starAction2))
    elseif times == 3 then
        --callback1()
        local starAction1 = cc.Spawn:create(cc.CallFunc:create(handleWithArg(starAction, self.callFuncArg[1])), 
                                            cc.CallFunc:create(audioEffect), 
                                            cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(starLight, {star = 1})))
        local starAction2 = cc.Spawn:create(cc.CallFunc:create(handleWithArg(starAction, self.callFuncArg[2])), 
                                            cc.CallFunc:create(audioEffect), 
                                            cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(starLight, {star = 2})))
        local starAction3 = cc.Spawn:create(cc.CallFunc:create(handleWithArg(starAction, self.callFuncArg[3])), 
                                            cc.CallFunc:create(audioEffect), 
                                            cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(starLight, {star = 3})))
        self._vBg_bg:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), starAction1, cc.DelayTime:create(0.1), starAction2, cc.DelayTime:create(0.1), starAction3))
    end
end

function BattleResultPanel:renderReward(rewardPanel, reward, rc)
    local star = reward.star
    local function callback()
        self:playAudio(star)
    end
    local noAction = cc.MoveBy:create(0.3, cc.p(0, 0))
    self._vBg_bg:runAction(cc.Sequence:create(noAction, cc.CallFunc:create(callback)))
    
--    for index=1, 3 do
--    	local starImg = self:getChildByName("panelContainer/panelNode/mainPanel/starImg" .. index)
--    	starImg:setVisible(false)
--        local positionX , positionY = starImg:getPosition()
--        if self.movieStar[index] == nil then
--            self.movieStar[index] = UIMovieClip.new("rpg-Thestars")
--            self.movieStar[index]:setParent(self._mainPanel)
--            self.movieStar[index]:setPosition(positionX, positionY)
--            self.movieStar[index]:setLocalZOrder(100)
--        end
--        self.movieStar[index]:setVisible(false)
--    end
    
    for index=1, 4 do 
        local iconContainer = rewardPanel:getChildByName("item" .. index)
        iconContainer:setVisible(false)
    end
    
    local tipTxt = rewardPanel:getChildByName("tipTxt")
    tipTxt:setVisible(false) --战役胜利结算才显示tip
    --tipTxt:setFontSize(24)

    local btProxy = self:getProxy(GameProxys.Battle)
    local curBtType = btProxy:getCurBattleType()
    local rewardInfos = reward.rewardInfo
    
    if rc ~= 0 and curBtType ~= GameConfig.battleType.legion and curBtType ~= GameConfig.battleType.arena then
        rewardInfos = {}
    end
    
    local index = 1
    for _, rewardInfo in pairs(rewardInfos) do
        local iconContainer = rewardPanel:getChildByName("item" .. index)
        if iconContainer ~= nil then
            iconContainer:setVisible(true)
            local icon = iconContainer.icon
            if icon == nil then
                if curBtType == GameConfig.battleType.level then
                    icon = UIIcon.new(iconContainer, rewardInfo, true, self, false, true, _, _, BattleResultPanel.PANEL_ACTION_TIME)
                    if rc == 0 then
                        tipTxt:setVisible(true)
                        tipTxt:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 50), cc.FadeTo:create(0.5, 255))))
                    end
                else
                    icon = UIIcon.new(iconContainer, rewardInfo, true, self, _, _, _, _, BattleResultPanel.PANEL_ACTION_TIME)
                    icon:setShowName(true)
                end
                iconContainer.icon = icon
            else
                icon:updateData(rewardInfo)
                icon:setShowName(true)
                if curBtType ~= GameConfig.battleType.level then
                    -- icon:setShowName(false)
                else
                    -- icon:setShowName(true)
                    if rc == 0 then
                        tipTxt:setVisible(true)
                        tipTxt:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 50), cc.FadeTo:create(0.5, 255))))
                    end
                end
            end
            iconContainer.icon:setIconCenter()
        end
        index = index + 1
    end
    
    --战斗失败将胜利的星星隐藏掉
    --if rc ~= 0 then
    --    local mainPanel = self:getChildByName("panelContainer/mainPanel")
    --    for index=1, 3 do
    --        local star = mainPanel:getChildByName("starImg" .. index)
    --        star:setVisible(false)
    --    end
    --end
end

function BattleResultPanel:registerEvents()
    local exitBtn = self:getChildByName("panelContainer/panelNode/mainPanel/exitBtn")
    self:addTouchEventListener(exitBtn, self.onExitBattleTouch)

    -- -- 暂时屏蔽的按钮
    -- local collectBtn = self:getChildByName("panelContainer/panelNode/mainPanel/collectBtn")
    -- local replayBtn = self:getChildByName("panelContainer/panelNode/mainPanel/replayBtn")
    -- collectBtn:setVisible(false)
    -- replayBtn:setVisible(false)

end

function BattleResultPanel:onExitBattleTouch(sender, callArg)
    if self._button then
        self:isLostTipsVisible(false)
    end
    if callArg == nil then
        TimerManager:addOnce(40, self.delayHideSelf, self)
    else
        self:dispatchEvent(BattleEvent.HIDE_SELF_EVENT, {})
    end

    --是否击杀所有黄巾军(服务器给的状态不在这  但是在这里做的处理)
    -- if self.isAllKill then
    --     local banditDungeonProxy = self:getProxy(GameProxys.BanditDungeon)
    --     local openData = {}
    --     openData.moduleName = ModuleName.TellTheWorldModule
    --     openData.extraMsg = {}
    --     banditDungeonProxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, openData)
    --     banditDungeonProxy:setIsAllKill(false) --避免重复弹出
    -- end 
end

--专给引导用的
function BattleResultPanel:onBattleEndOpenFun()
    if self:isInitUI() ~= true then
        return
    end
    local exitBtn = self:getChildByName("panelContainer/panelNode/mainPanel/exitBtn")
    self["exitBtn"] = exitBtn
end

function BattleResultPanel:delayHideSelf()
    self:dispatchEvent(BattleEvent.HIDE_SELF_EVENT, {})
end

---------------------------------------------------------------------
------
-- 播放炸星星动画， 随音效一起调用
function BattleResultPanel:setStarLight(index)
    local starImg = self:getChildByName( string.format("panelContainer/panelNode/mainPanel/starImg%d_bg", index))
    -- 只播放一次
    local ccbStar = UICCBLayer.new("rgb-xing",  self._mainPanel, nil, nil, true)
    ccbStar:setLocalZOrder(100)
    ccbStar:setPosition(starImg:getPosition())
end

------
-- 播放炸胜利动画，
function BattleResultPanel:setWinLight()
    local ccbWin = UICCBLayer.new("rgp-finally-win", self._mainPanel, nil, nil, true)
    local size = self._mainPanel:getContentSize()
    ccbWin:getLayer():setLocalZOrder(100)
    ccbWin:setPosition(size.width/2, size.height/2 + 110)
    --ccbWin:setPosition(0,  110)
end