-- 邮件：报告
MailReportInfoPanel = class("MailReportInfoPanel", BasicPanel)
MailReportInfoPanel.NAME = "MailReportInfoPanel"
MailReportInfoPanel.FONTS_ICON_URL = "images/fontsIcon/"



function MailReportInfoPanel:ctor(view, panelName)
    MailReportInfoPanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function MailReportInfoPanel:finalize()

    MailReportInfoPanel.super.finalize(self)
end

function MailReportInfoPanel:initPanel()
	MailReportInfoPanel.super.initPanel(self)
	self:setBgType(ModulePanelBgType.NONE)
    self:setTitle(true,"baogao",true)
    
    self._mailProxy = self:getProxy(GameProxys.Mail)
    self._panelAdaptiveTop = self:getChildByName("panelAdaptiveTop")
    self._listview = self:getChildByName("ListView_2")
    self._listView_resource = self:getChildByName("ListView_resource")
    self._listView_system = self:getChildByName("ListView_system")
    self._listViewTown = self:getChildByName("listViewTown")
    

    -- 自适应
    self._downPanel = self:getChildByName("downPanel")
    self._downPanel:setVisible(true)
    
    self._worldProxy = self:getProxy(GameProxys.World)
    
    self._listview._index = 1
    self._listView_resource._index = 2 
    self._listView_system._index = 3

    self._fightInfoId = nil
    self._watchInfoId = nil
    self._systemInfoId = nil
     

    self:registerEvent()
    self:initRequire()

end

function MailReportInfoPanel:doLayout()
    self:adaptive()
end


function MailReportInfoPanel:adaptive()
    -- body
    -- 自适应
    local topAdaptivePanel = self._panelAdaptiveTop

    NodeUtils:adaptiveListView(self._listview, self._downPanel, topAdaptivePanel, -30)
    NodeUtils:adaptiveListView(self._listView_resource, self._downPanel, topAdaptivePanel)

    NodeUtils:adaptiveListView(self._listViewTown, self._downPanel, topAdaptivePanel)

    NodeUtils:adaptiveTopPanelAndListView(self._listView_system, nil,self._downPanel,topAdaptivePanel)

    local listView = self._listView_system:getChildByName("exterRewardPanel")
    local panel = self._listView_system:getChildByName("Panel_45")
    local tableBottomPanel = self._listView_system:getChildByName("Panel_20")

    NodeUtils:adaptiveListView(listView, tableBottomPanel, panel,0)
    NodeUtils:adaptiveDownPanel(self._downPanel)
    panel:getChildByName("imgBg_1"):setContentSize(listView:getContentSize().width, listView:getContentSize().height + 55)

    NodeUtils:adaptivePanelBg(self._uiPanelBg._bgImg5, 5, topAdaptivePanel)
    
    --NodeUtils:adaptiveListView(self._svRank,bottomPanel,titileBg, 20)
end


function MailReportInfoPanel:registerEvent()
    -- BtnPanel2
    self._btnPanel02  = self:getChildByName("downPanel/btnPanel2") -- 系统邮件用
    self._getExterBtn = self:getChildByName("downPanel/btnPanel2/getExterBtn")
    self._exDeleteBtn = self:getChildByName("downPanel/btnPanel2/exDeleteBtn")
    self:addTouchEventListener(self._getExterBtn,self.onGetExterHandle)
    self:addTouchEventListener(self._exDeleteBtn,self.onDeleteHandle)

    
    -- BtnPanel3
    self._btnPanel03  = self:getChildByName("downPanel/btnPanel3") -- 攻击用
    self._againBtn03  = self:getChildByName("downPanel/btnPanel3/againBtn")
    self._findBtn03   = self:getChildByName("downPanel/btnPanel3/findBtn")
    self._deleteBtn03 = self:getChildByName("downPanel/btnPanel3/deleteBtn")
    self._writeBtn03  = self:getChildByName("downPanel/btnPanel3/writeBtn")
    self:addTouchEventListener(self._againBtn03,self.onAgainHandle)
    self:addTouchEventListener(self._findBtn03,self.onFindHandle)
    self:addTouchEventListener(self._deleteBtn03,self.onDeleteHandle)
    self:addTouchEventListener(self._writeBtn03,self.onWriteHandle)

    -- BtnPanel4 
    self._btnPanel04  = self:getChildByName("downPanel/btnPanel4") -- 侦查用
    self._deleteBtn04 = self:getChildByName("downPanel/btnPanel4/deleteBtn")
    self._findBtn04   = self:getChildByName("downPanel/btnPanel4/findBtn")
    self._attackBtn04 = self:getChildByName("downPanel/btnPanel4/attackBtn")
    self:addTouchEventListener(self._deleteBtn04,self.onDeleteHandle)
    self:addTouchEventListener(self._findBtn04,self.onFindHandle)
    self:addTouchEventListener(self._attackBtn04,self.onAttackHandle)

    -- BtnPanel5
    self._btnPanel05  = self:getChildByName("downPanel/btnPanel5") -- 盟战用
    self._deleteBtn05 = self:getChildByName("downPanel/btnPanel5/deleteBtn")
    self._findBtn05   = self:getChildByName("downPanel/btnPanel5/findBtn")
    self:addTouchEventListener(self._deleteBtn05,self.onDeleteHandle)
    self:addTouchEventListener(self._findBtn05,self.onFindHandle)
end

function MailReportInfoPanel:onShareToHandle(sender)

end

function MailReportInfoPanel:onHideSharlPanelHandle(sender)
    sender:setVisible(false)
end
-- 领取附件
function MailReportInfoPanel:onGetExterHandle(sender)
    local  power = self._data.reward[1].power
    if power == GamePowerConfig.Hero then
        local heroProxy = self:getProxy(GameProxys.Hero)
        local heroNum = heroProxy:getAllHeroNum()
        if heroNum >= GameConfig.Hero.MaxNum then
            local function okcallbk()
                ModuleJumpManager:jump(ModuleName.HeroHallModule)
            end
            local str = self:getTextWord(290063)
            self:showMessageBox(str,okcallbk)
            return
        end
    end 
    self:dispatchEvent(MailEvent.GET_SYSREWARD_REQ,{mailId = self._data.id})
end

function MailReportInfoPanel:onDeleteHandle(sender)
    -- 系统附件流程
    if sender == self._exDeleteBtn then
        if self._data.extracted == 0 then  --未领取
            local function okcallbk()
                local data = {}
                data.idlist = {}
                table.insert(data.idlist, self._data.id)
                self:dispatchEvent(MailEvent.DELETE_MAIL_REQ,data)
            end
            self:showMessageBox(self:getTextWord(1223), okcallbk) -- 附件还未领取,确认要删除吗?
            return
        end
    end

    -- 两种不同的删除
    local data = {}
    local state = self._mailProxy:getIsInCollect( self._data.id)
    if state then
        local id   = {}
        data.id = id
        table.insert(id, self._data.id)
        self._mailProxy:onTriggerNet160009Req(data) -- 在收藏中删除
    else
        data.idlist = {}
        table.insert(data.idlist, self._data.id)
        self:dispatchEvent(MailEvent.DELETE_MAIL_REQ,data) -- 普通删除
    end

end
-- 查找
function MailReportInfoPanel:onFindHandle(sender)
    --print("点击查找方位")
    self:onGoToPosHandle()
end

function MailReportInfoPanel:onShareHandle(sender)
    if self._uiSharePanel == nil then
        self._uiSharePanel = UISharePanel.new(sender, self)
    end
    
    local data = {}
    data.type = ChatShareType.REPORT_TYPE 
    data.id = self._data.id
    self._uiSharePanel:showPanel(sender, data)
end

function MailReportInfoPanel:onWriteHandle(sender)

    local roleProxy = self:getProxy(GameProxys.Role)
    local lv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    if lv < GlobalConfig.chatMinLv then
        self:showSysMessage(string.format(TextWords:getTextWord(1238), GlobalConfig.chatMinLv))
        return
    end

    
    local panel = self:getPanel(MailDetailPanel.NAME)
    panel:show()
    -- if self._data.infos.mailType == 3 then
    --     panel:onExterWriteMail(self._data.infos.InfoPanel.aim)
    --     return
    -- end
    panel:onExterWriteMail(self._data.infos.InfoPanel.aim)
end

function MailReportInfoPanel:onAttackHandle(sender)
    if self._closeModule then        
        -- self._mailProxy:setCurrentState(true)
    end

    local data = {}
    data.moduleName = ModuleName.TeamModule
    data.extraMsg = {}
    data.extraMsg.type = "world"    
    data.extraMsg.tileX = self._data.infos.InfoPanel.posX
    data.extraMsg.tileY = self._data.infos.InfoPanel.posY
    data.extraMsg.otherCityStr = self._data.infos.InfoPanel.aim
    if self._data.infos.mailType == 1 and self._data.infos.cityPanel.defentIcon < 50 then
        data.extraMsg.otherCityStr = self._data.name
    end

    local mailShortData = self._mailProxy:getMailShortDataById(self._data.id)


    local rolePrxoy = self:getProxy(GameProxys.Role)
    local isHaveNotfight = rolePrxoy:getRoleAttrValue(PlayerPowerDefine.POWER_notFightState)
    -- 攻打矿点等级限制判断
    local attackRes = false
    if self._data.infos.isPerson == 0 then
        if self._data.infos.InfoPanel.aim ~= self._data.infos.InfoPanel.name then -- 被占领的资源
            attackRes = true

            data.extraMsg.isPlayerRes = true        
        end
    else
        attackRes = true
    end
    if attackRes then
        local curProcessrLevel = rolePrxoy:getRoleAttrValue(PlayerPowerDefine.POWER_ResLevel) -- 攻打等级进度
        local targetLevel = tonumber( string.sub(self._data.infos.InfoPanel.name, 1, 1))
        if targetLevel > curProcessrLevel + 1 then
            self:showSysMessage( string.format(self:getTextWord(8711), targetLevel - 1))
            return 
        end

        -- 如果攻打目标为资源，增加战损等级判断字段
        data.extraMsg.subBattleType = self._worldProxy:getSubBattleType(targetLevel)
    end

    

    if isHaveNotfight > 0 and mailShortData.targetType == 1 then
        local function useItem()
            self:dispatchEvent(MailEvent.MAIL_FIGHT_REQ,data)
            self:hide()
            self:dispatchEvent(MailEvent.HIDE_SELF_EVENT,{})
        end
        local function notUseItem()
        end
        local content = string.format(self:getTextWord(4019))
        self:showMessageBox(content, useItem, notUseItem,self:getTextWord(100),self:getTextWord(101))
    else
        self:dispatchEvent(MailEvent.MAIL_FIGHT_REQ,data)
        self:hide()
        self:dispatchEvent(MailEvent.HIDE_SELF_EVENT,{})
    end

end

function MailReportInfoPanel:onAgainHandle(sender) --重播
    self:dispatchEvent(MailEvent.SHOWFT_AGAIN_REQ,{battleId = self._data.infos.battleId})
end

function MailReportInfoPanel:getProxyByName(name)
    return self:getProxy(GameProxys[name])
end

------
-- 模块全包含和初始化
function MailReportInfoPanel:initRequire()
    self._panelMap = {}
    local panelMap = {"InfoPanel","cityPanel","lostSerPanel","resourcePanel","rewardPanel",
"exterInfoPanel","exterRewardPanel", "townReportPanel"} -- townReportPanel是盟战报告的层级
    for _,v in pairs(panelMap) do
        require("modules.mail.panel.reportInfo."..v)
        --local panel = self:getChildByName("modulePanel/"..v)
        --panel:setVisible(false)
        self._panelMap[v] = _G[v]
        self._panelMap[v]:ctor(nil,self)
    end
end

function MailReportInfoPanel:onClosePanelHandler()
    self:hide()
    if self._closeModule ~= nil then
        self._fightInfoId = nil
        self._watchInfoId = nil
        self._systemInfoId = nil
        self.view:hideModuleHandler()
    end
    self._closeModule = nil
end

function MailReportInfoPanel:onShowWhichLV(index)
    local listviewTb = {self._listview,self._listView_resource,self._listView_system, self._listViewTown}
    for _,v in pairs(listviewTb) do
        if v._index == index then
            v:setVisible(true)
        else
            v:setVisible(false)
        end
    end
end

function MailReportInfoPanel:onIsOpenLastTimes(srcId,newId)
    if srcId == newId then  --上次打开一样
    else
        srcId = newId
        return true
    end
end

function MailReportInfoPanel:updateListData(data,closeModule,tmp)  --tmp分享战报特有

    if tmp then
        self.tmp = tmp
    else
        self.tmp = nil
    end
    if self.view.isShow then
        self._closeModule = closeModule
        self.view.isShow = false
    else
        self._closeModule = nil
    end
    self._data = data

    self:showReportBtnPanel(data, tmp) -- 按钮层显示
    local panelMap = {}

    
    if data.type == 4 then   --报告( type， )
        ----------start---------------
        self._mailType = data.infos.mailType
        if self._mailType == 1 or self._mailType == 2 then --战斗（进攻1，防守2）
            if self:onIsOpenLastTimes(self._fightInfoId, data.id) == nil then
                return
            end
            local result = data.infos.InfoPanel.result -- 0胜利，1失败，3 采集成功
            if result ~= 3 then -- 不是采集
                
                if data.infos.isPerson ~= 3 then  -- 0=对方是玩家或被占领的资源，1=对方是资源，2=叛军，3=郡城
                    self:onShowWhichLV(1) -- 显示哪个ListView
                    panelMap = {"InfoPanel","resourcePanel","cityPanel","lostSerPanel", "rewardPanel" } 
                    -- 显示

                    for index,v in pairs(panelMap) do
                        local itemIndex = self._listview:getItem(index - 1)
                        if v == "InfoPanel" then
                            self._panelMap[v]:setParentHandler(self)
                        end
                        self._panelMap[v]:updateData(itemIndex,data)
                    end
                    self._listview:refreshView()
                else
                    -- 特殊的盟战报告逻辑
                    self:onShowWhichLV(4)
                    self._panelMap["townReportPanel"]:initPanel(data.infos, self._listViewTown)
                end

            else
                self:onShowWhichLV(2) -- 显示哪个ListView
                panelMap = {"InfoPanel", "resourcePanel"}
                for index,v in pairs(panelMap) do
                    if v == "InfoPanel" then
                        self._panelMap[v]:setParentHandler(self)
                    end
                    local itemIndex = self._listView_resource:getItem(index - 1)
                    self._panelMap[v]:updateData(itemIndex,data)
                end
                local soldierPanel = self._listView_resource:getChildByName("soldierPanel")
                soldierPanel:setVisible(false)
            end
        elseif self._mailType == 3 then -- 邮件侦查报告
            if self:onIsOpenLastTimes(self._watchInfoId,data.id) == nil then
                return
            end
            self:onShowWhichLV(2)

            local showInfo = data.infos.watchSerPanel.info -- PosInfo// 佣兵位置信息

            local showData = {}
            local AdviserId = 0
            local AdviserLv
            for k,v in pairs(showInfo) do
                local _info = {}
                _info.post = v.post
                _info.num = v.num
                _info.heroTypeId = v.heroTypeId
                if v.post ~= 9 then
                    local configInfo = nil
                    if v.typeid < 1000 then
                        configInfo = ConfigDataManager:getInfoFindByOneKey("ArmKindsConfig","ID",v.typeid)
                        if configInfo ~= nil then
                            _info.typeid = ConfigDataManager:getInfoFindByOneKey("ModelGroConfig","ID",configInfo.model).modelID
                        end
                    else
                        configInfo = ConfigDataManager:getInfoFindByOneKey("MonsterConfig","ID",v.typeid)
                        if configInfo ~= nil then
                            _info.typeid = ConfigDataManager:getInfoFindByOneKey("ModelGroConfig","ID",configInfo.model).modelID
                        end
                    end
                else
                    _info.typeid = v.typeid
                    _info.lv = v.lv
                    AdviserId = v.typeid
                    AdviserLv = v.lv
                end
                --print("_info.typeid", _info.typeid)
                showData[k] = _info
            end

            

            panelMap = {"InfoPanel","resourcePanel"}
            for index,v in pairs(panelMap) do
                if v == "InfoPanel" then
                    self._panelMap[v]:setParentHandler(self)
                end
                local itemIndex = self._listView_resource:getItem(index - 1)

                self._panelMap[v]:updateData(itemIndex,data)
            end

            --------- 新的阵型
            -- 设置属性 
            local soldierPanel = self._listView_resource:getChildByName("soldierPanel")
            soldierPanel:setVisible(true)
            self:initCheckSoldierPanel(soldierPanel, showData)
        end
        ----------report end---------------
    elseif data.type == 1 then  --系统
        if self:onIsOpenLastTimes(self._systemInfoId,data.id) == nil then
            return
        end
        panelMap = {"exterInfoPanel","exterRewardPanel"}
        self:onShowWhichLV(3)
        for index,v in pairs(panelMap) do
            self._panelMap[v]:updateData(self._listView_system:getChildByName(v),data)
        end
    end

end

function MailReportInfoPanel:onGoToPosHandle(isSelf,_x,_y) --防守方是资源点时候
    local data = {}
    data.moduleName = ModuleName.MapModule
    data.extraMsg = {}
    local xx,yy
    if isSelf ~= nil then  --自己
        local proxy = self:getProxy(GameProxys.Role)
        xx,yy = proxy:getWorldTilePos()
        if _x and _y then
            xx = _x
            yy = _y
        end
    else
        xx = self._data.infos.InfoPanel.posX
        yy = self._data.infos.InfoPanel.posY
    end
    data.extraMsg.tileX = xx
    data.extraMsg.tileY = yy
    if self.tmp then
        data.extraMsg.tileX = self._data.infos.InfoPanel.posX
        data.extraMsg.tileY = self._data.infos.InfoPanel.posY
        self:dispatchEvent(MailEvent.GOTO_MAPPOS_REQ,data)
    else
        self:dispatchEvent(MailEvent.GOTO_MAPPOS_REQ,data)
    end
    
    self:hide()
    self.view:hideModuleHandler()
end



function MailReportInfoPanel:onGetSysRewardResp(type)
    logger:info("有没有 邮件 "..#self._data.reward)
    if type ~= nil then
        self._getExterBtn:setTitleText(self:getTextWord(1218)) -- [[领取附件]]
        NodeUtils:setEnable(self._getExterBtn, true)
        self._getExterBtn:setVisible(true)
    else
        self._data.extracted = 1  --表示已领取
        self._getExterBtn:setTitleText(self:getTextWord(1112)) -- [[已领取]]
        NodeUtils:setEnable(self._getExterBtn, false)
        if #self._data.reward >0 then
            self._getExterBtn:setVisible(true)
        else
            self._getExterBtn:setVisible(false)
        end
    end


end

------
-- 设置侦查邮件，详情，阵型信息
function MailReportInfoPanel:initCheckSoldierPanel(panel, showData)
    
    local soldierPanel = panel
    local allNum = 0 
    for i = 1 , 6 do
        local posImg = soldierPanel:getChildByName("posImg"..i)
        local showEmpty = posImg:getChildByName("showEmpty")
        local numImg = showEmpty:getChildByName("numImg")
        local url = MailReportInfoPanel.FONTS_ICON_URL..i..".png"
        TextureManager:updateImageView(numImg, url)
        
        -- 隐藏标题图
        showEmpty:setVisible( showData[i].num == 0)
        
        -- 加图标
        local iconAddImg = posImg:getChildByName("iconAddImg")
        -- 名字文本
        local heroNameTxt = posImg:getChildByName("nameTxt")
        local iconHero = posImg:getChildByName("IconHero")
        iconHero:setVisible(true)
        heroNameTxt:setString("")
        if iconAddImg.uiIcon ~= nil then
            iconAddImg.uiIcon:finalize()
            iconAddImg.uiIcon = nil
        end

        if showData[i].num ~= 0 then
            local data = {}
            data.num = showData[i].num
            data.power = GamePowerConfig.Soldier
            data.typeid = showData[i].typeid 
            local uiIcon = UIIcon.new(iconAddImg, data, true, self, nil, false) -- 兵种图标
            uiIcon:setTouchEnabled(false) 
            iconAddImg.uiIcon = uiIcon
            allNum = allNum + showData[i].num -- -- 部队总数量
            local heroTypeId = showData[i].heroTypeId
            -- 武将名字设置
            if heroTypeId == 0 then
                heroNameTxt:setString("")
                iconHero:setVisible(true)
            else
                local configItem = ConfigDataManager:getInfoFindByOneKey(
                ConfigData.HeroConfig, "ID", heroTypeId)
                local heroName = configItem.name
                local color    = configItem.color
                heroNameTxt:setString( heroName )
                iconHero:setVisible(false)
                heroNameTxt:setColor( ColorUtils:getColorByQuality(color))
            end
        end
    end
    -- 部队总数量
    local allNumTxt = soldierPanel:getChildByName("allNumTxt")
    allNumTxt:setString(allNum)
    ---------------------------------------------------------------------
    -- 军师图片:槽位[7]
    local adviserImg = soldierPanel:getChildByName("posImg7")
    local nameTxt = adviserImg:getChildByName("nameTxt")
    nameTxt:setString("")

    -- 军师图标释放
    local iconAddImg = adviserImg:getChildByName("iconAddImg")
    if iconAddImg.uiIcon ~= nil then
        iconAddImg.uiIcon:finalize()
        iconAddImg.uiIcon = nil
    end

    local advicerStarImg = adviserImg:getChildByName("advicerStarImg")
    advicerStarImg:setVisible(false)

    local showEmpty = adviserImg:getChildByName("showEmpty")
    showEmpty:setVisible(true)

    -- 如果没军师数据，停止
    if table.size(showData) < 7 then
        return
    end

    -- 军师星级
    local advicerLevel = showData[7].lv
    if advicerLevel ~= 0 and advicerLevel ~= nil then
        advicerStarImg:setVisible(true)
        local levelImg = advicerStarImg:getChildByName("levelImg")
        local sStarUrl = string.format("images/newGui1/adviser_num_%d.png", advicerLevel)
        --print("军师星级为:"..advicerLevel)
        TextureManager:updateImageView(levelImg, sStarUrl)
    end

    
    local pos7Num = showData[7].num
    showEmpty = adviserImg:getChildByName("showEmpty")
    showEmpty:setVisible( pos7Num == 0)
    
    if pos7Num ~= 0 then
        local data = {}
        data.num = pos7Num
        data.power = GamePowerConfig.Counsellor
        data.typeid = showData[7].typeid 
        local uiIcon = UIIcon.new(iconAddImg, data, true, self,  nil,true)
        uiIcon:setTouchEnabled(true) 
        iconAddImg.uiIcon = uiIcon
        -- 名字设置
        local nameTxt = uiIcon:getNameChild()
        nameTxt:setFontSize(18)
        if advicerLevel ~= 0 and advicerLevel ~= nil then
            nameTxt:setPosition(-15, -57)
        else
            nameTxt:setPosition(0, -57)
        end
    end
    -----------------------------------------
end


------
-- 判断资源层要不要隐藏
--进攻世界未被占领矿点：不显示该模块；
--进攻成功：显示该模块，进攻失败，不显示该模块；
function MailReportInfoPanel:resourceIsVisible(item, data)
    local infos = data.infos
    item:retain()
    -- 1
    if infos.isPerson == 0 then
        -- 2
        if infos.InfoPanel.result ~= 0 then
            ComponentUtils:setListViewItemIndex(self._listView, 1, 6)
        end

    else
        ComponentUtils:setListViewItemIndex(self._listView, 1, 6)
    end
    
end

-- 判断收藏按钮
function MailReportInfoPanel:updataCollectShow(collectBtn, collectCancleBtn, id)
    -- 都是本身id
    self._collectBtn = collectBtn
    self._collectCancleBtn = collectCancleBtn
    collectBtn.id = id
    collectCancleBtn.id = id
    self:addTouchEventListener(collectBtn, self.onCollectBtn)
    self:addTouchEventListener(collectCancleBtn, self.onCollectCancleBtn)
    -- 显示状态
    local state = self._mailProxy:getIsInCollect(id)
    local dependData = self._mailProxy:getReadMailDependData(id) -- 为nil时表示分享
    -- 若点开来自分享邮件
    if dependData == nil then
        collectBtn:setVisible(false)
        collectCancleBtn:setVisible(false)
        return 
    end
    -- 来自别的模块
    if self.tmp ~= nil then
        collectBtn:setVisible(false)
        collectCancleBtn:setVisible(false)
        return 
    end

    if StringUtils:isFixed64Zero(dependData.collectId) then -- -- 为0说明未收藏，非0为链接id g
        collectBtn:setVisible(true)
        collectCancleBtn:setVisible(false)
    else
        collectBtn:setVisible(false)
        collectCancleBtn:setVisible(true)
    end
    if state then
        collectBtn:setVisible(false)
        collectCancleBtn:setVisible(true)
    end
end

-- 点击收藏
function MailReportInfoPanel:onCollectBtn(sender)
    --print("点击收藏")
    local data = {}
    data.id = sender.id
    self._mailProxy:onTriggerNet160008Req(data)
end

-- 点击取消收藏
function MailReportInfoPanel:onCollectCancleBtn(sender)
    --print("点击取消收藏")
    local dependData = self._mailProxy:getReadMailDependData(sender.id)
    local isInCollect = self._mailProxy:getIsInCollect(sender.id)
    local collectId = dependData.collectId -- 链接id 
    local selfId    = dependData.id -- 本身id

--    local data = {}
--    -- 如果从本身邮件取消就是链接id，如果是从收藏邮件就是收藏邮件的本身id
--    if isInCollect then
--        data.id = id
--        print("收藏内部邮件取消")
--    else
--        data.id = collectId
--        print("外部邮件取消")
--    end
--    self._mailProxy:onTriggerNet160009Req(data)

    local data = {}
    -- 如果从外部邮件取消就是发链接id，如果是从收藏邮件就是发收藏邮件的本身id
    local id   = {}
    data.id = id
    if isInCollect then
        table.insert(id, selfId)
        --print("收藏内部邮件取消")
    else
        table.insert(id, collectId)
        --print("外部邮件取消")
    end
    
    self._mailProxy:onTriggerNet160009Req(data)


end

-- 刷新按钮状态
function MailReportInfoPanel:refreshBtnState()
    self._collectBtn:setVisible(not self._collectBtn:isVisible())
    self._collectCancleBtn:setVisible(not self._collectCancleBtn:isVisible())
end

-- 显示分享界面
function MailReportInfoPanel:showShareView(sender)
    --print("点击分享")
    
    if self._uiSharePanel == nil then
        self._uiSharePanel = UISharePanel.new( self._downPanel, self)
    end
    local worldPos = sender:getWorldPosition()
    local nodePos  = self._downPanel:convertToNodeSpace(worldPos)
    
    local data = {}
    data.type = ChatShareType.REPORT_TYPE 
    data.id = sender.data.id
    self._uiSharePanel:showPanel(sender, data)
    self._uiSharePanel:rotationPanel()
    -- 偏差值修正
    nodePos.x = nodePos.x + 83
    nodePos.y = nodePos.y - 30
    self._uiSharePanel:setSharePanelPos( nodePos)
end


------
-- showReportBtnPanel
-- self._againBtn03 
-- self._findBtn03  
-- self._deleteBtn03
-- self._writeBtn03 
function MailReportInfoPanel:showReportBtnPanel(data, tmp)
    local function setBtnType(statusTb)
        local btnMap = {self._againBtn03, self._findBtn03, self._deleteBtn03, self._writeBtn03}
        for k,v in pairs(statusTb) do
            if v == true then
                NodeUtils:setEnable(btnMap[k], true)
            else
                NodeUtils:setEnable(btnMap[k], false)
            end
        end
    end
    local statusTb = {true,true,true,true}

    self._btnPanel02:setVisible(false)
    self._btnPanel03:setVisible(false)
    self._btnPanel04:setVisible(false)
    self._btnPanel05:setVisible(false)
    

    if data.type == 4 then -- 报告
        if data.infos.mailType == 3 then  -- 侦查
            -- 侦查
            self._btnPanel04:setVisible(true)
        else
            -- 攻打
            if data.infos.isPerson ~= 3 then
                self._btnPanel03:setVisible(true)
                if data.infos.haveBattle == 0 then  --无战斗
                    statusTb[1] = false  -- 无战斗就无法重播
                end

                if data.infos.isPerson == 1 or data.infos.isPerson == 2 then  --对方是没玩家占领的资源点或叛军
                    statusTb[4] = false -- 纯资源点无法邮件
                end
                setBtnType(statusTb)
            elseif data.infos.isPerson == 3 then -- 盟战报告
                self._btnPanel05:setVisible(true)

            end
        end
    else
        -- 系统
        self._btnPanel02:setVisible(true)
        if data.extracted == 0 then --未提取
            self:onGetSysRewardResp(true)
        else
            self:onGetSysRewardResp()
        end
    end

    if self._data.infos.InfoPanel.posX < 0 and self._data.infos.InfoPanel.posY < 0 then
        NodeUtils:setEnable(self._attackBtn04, false)
    else
        NodeUtils:setEnable(self._attackBtn04, true)
    end
    -------ceshi分享战报
    if tmp then
        local stateBtn = {false,false,false,false}
        if tmp.index == 1 then  --来自世界的分享
            if data.infos.mailType ~= 3 then -- 不为侦查
                stateBtn[1] = true -- 可重播
            end
        else  -- 来自军团
            if data.infos.mailType == 3 then --侦查
--                if data.infos.resourcePanel.cityIcon < 50 then --资源点
--                    --全都不能点
--                else
--                    self._btnPanel04:setVisible(true)
--                end
            else
                stateBtn[1] = true -- 可重播
                if data.infos.resourcePanel.cityIcon >= 50 then

                else
                    if data.infos.isPerson == 0 then
                        statusTb[1] = true
                    end
                end
            end
        end

        if data.infos.InfoPanel.posX < 0 and  data.infos.InfoPanel.posY < 0 then
            NodeUtils:setEnable(self._attackBtn04, false) -- 攻击不要
        end

        setBtnType(stateBtn) -- 点击
        NodeUtils:setEnable(self._exDeleteBtn, false) -- 删除按钮不可点开
        return
    else
        -- 不是分享，删除按钮状态还原
        NodeUtils:setEnable(self._exDeleteBtn, true) -- 删除按钮不可点开
    end
end

-------
-- 计算资源点怪物战力
function MailReportInfoPanel:getMonsterPowerInCheck(reportData)
    --print("计算纯资源点怪物的战力")
    local totalPower = 0
    local soldierProxy = self:getProxy(GameProxys.Soldier)
    local posInfo = reportData.watchSerPanel.info
    for k, v in pairs(posInfo) do
        if v.num ~= 0 then -- 空位置为0
            local typeId = v.typeid   
            local num    = v.num
            local realModelId = ConfigDataManager:getInfoFindByOneKey(
            ConfigData.MonsterConfig,"ID",typeId).model
            --print("兵种的TypeID：".. typeId)
            local oneNum  = soldierProxy:getOneSoldierFightById(realModelId)
            local multiNum = oneNum*num
            totalPower = totalPower + multiNum
        end
    end

    return totalPower
end

function MailReportInfoPanel:getMonsterPowerInFight(lostInfo)
    --print("计算纯资源点怪物的战力, 进攻")
    local totalPower = 0
    local soldierProxy = self:getProxy(GameProxys.Soldier)
    local posInfo = lostInfo
    for k, v in pairs(posInfo) do
        if v.allNum ~= 0 then -- 空位置为0
            local typeId = v.typeId   
            local num    = v.allNum
            local realModelId = ConfigDataManager:getInfoFindByOneKey(
            ConfigData.MonsterConfig,"ID",typeId).model
        
            local oneNum  = soldierProxy:getOneSoldierFightById(realModelId)
            local multiNum = oneNum*num
            totalPower = totalPower + multiNum
        end
    end

    return totalPower
end

-- 获取颜色参数
-- 直接是cc.c3b
function MailReportInfoPanel:getColorValueByLoyalty(loyaltyCount)
    return self._worldProxy:getColorValueByLoyalty(loyaltyCount)
end

------
-- 根据民忠值获取颜色
function MailReportInfoPanel:getColorByLoyalty(loyaltyCount)
    return self._worldProxy:getColorByLoyalty(loyaltyCount)
end


-- 获取加成系数
-- 直接是相关倍数
function MailReportInfoPanel:getPlusValueByLoyalty(loyaltyCount)
    return self._worldProxy:getPlusValueByLoyalty(loyaltyCount)
end

------
-- 获取vip采集加成
function MailReportInfoPanel:getVipSpeedUpCollectRes()
    return self._worldProxy:getVipSpeedUpCollectRes()
end