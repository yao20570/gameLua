
ArenaMainPanel = class("ArenaMainPanel", BasicPanel)
ArenaMainPanel.NAME = "ArenaMainPanel"

function ArenaMainPanel:ctor(view, panelName)
    ArenaMainPanel.super.ctor(self, view, panelName)
    self._coldTime = 0

    self:setUseNewPanelBg(true)
end

function ArenaMainPanel:finalize()
    if self._watchPlayInfoPanel ~= nil then
        self._watchPlayInfoPanel:finalize()
    end

    self._watchPlayInfoPanel = nil
    ArenaMainPanel.super.finalize(self)

end

function ArenaMainPanel:initPanel()
    ArenaMainPanel.super.initPanel(self)

    self._topPanel = self:getChildByName("topPanel")
    self._middlePanel = self._topPanel:getChildByName("middlePanel")
    self._downPanel = self:getChildByName("downPanel")

    -- local tabsPanel = self:getTabsPanel()  --TODO 获取不到tabsPanel

    self._timeTxt = self._topPanel:getChildByName("coldTime")
    self._timeTxt:setVisible(false)

    self:registerEvent()
    self:setHelpPanel(false)
end

function ArenaMainPanel:doLayout()
    local panel = self:getPanel(ArenaPanel.NAME)
    local tabsPanel = panel:getOwnTabsPanel()  --TODO 获取不到tabsPanel
    
    self._topPanel = self:getChildByName("topPanel")
    self._middlePanel = self._topPanel:getChildByName("middlePanel")
    self._downPanel = self:getChildByName("downPanel")
    --NodeUtils:adaptiveTopPanelAndListView(self._topPanel, nil, self._downPanel, tabsPanel)  

    NodeUtils:adaptiveUpPanel(self._downPanel,self._middlePanel,45 )
    --local topAdaptivePanel = self:topAdaptivePanel2()
    --NodeUtils:adaptiveUpPanel(self._downPanel, topAdaptivePanel,50 )
end

function ArenaMainPanel:onShowHandler()
    self:setBtnStatus(1)
    local soldierPorxy = self:getProxy(GameProxys.Soldier)

    local arenaPorxy = self:getProxy(GameProxys.Arena)
    arenaPorxy:onTriggerNet200000Req({})

    local proxy = self:getProxy(GameProxys.Role)
    local myName = proxy:getRoleName()

    local teamFight = soldierPorxy:getArenaTeamFight()
    if teamFight ~= nil then
        for i=1,6 do
            local team = self._middlePanel:getChildByName("team"..i)
            if team:isVisible() and team.data ~= nil then
                if rawget(team.data, "name") == myName then
                    local fight = team:getChildByName("fight")
                    fight:setString(StringUtils:formatNumberByK3(teamFight))
                    local attackBtn = team:getChildByName("attackBtn")
                    local myInfoImg = team:getChildByName("myInfoImg")
                    attackBtn:setVisible(false)
                    myInfoImg:setVisible(true)
                    break
                end
            end
        end
    end
end


function ArenaMainPanel:onTabChangeEvent(tabControl)
    local downPanel = self:getChildByName("downPanel")
    ArenaMainPanel.super.onTabChangeEvent(self, tabControl, downPanel)
end


function ArenaMainPanel:onClickItemHandle(sender)   --优化:不需要每次点击同一个人个人信息都请求140001,数据放在ArenaProxy中
    local function call()
        if self._currItem ~= nil then
            local selectImg = self._currItem:getChildByName("selectImg")
            selectImg:setVisible(false)
        end
    end
    if sender == nil then
        call()
    else
        local proxy = self:getProxy(GameProxys.Role)
        local myName = proxy:getRoleName()
        if sender.data == nil then
            return
        end
        if myName ~= sender.data.name then
            call()
            self._currItem = sender
            local selectImg = self._currItem:getChildByName("selectImg")
            selectImg:setVisible(true)
            
            local data = {}
            data.playerId =  sender.data.playerId
            if StringUtils:isFixed64Minus(data.playerId) == true then
                return
            end
            self:dispatchEvent(ArenaEvent.PERSON_INFO_REQ,data)
        end
    end
end

function ArenaMainPanel:onChatPersonInfoResp(data)
    if self._watchPlayInfoPanel == nil then
        self._watchPlayInfoPanel = UIWatchPlayerInfo.new(self:getParent(), self, false, false)
    end
    -- self._watchPlayInfoPanel:setMialShield(true) 
    self._watchPlayInfoPanel:showAllInfo(data)
end

function ArenaMainPanel:onAddBtnHandle(sender)
    if self._data == nil then return end
    local function okcallbk()
        -- self:dispatchEvent(ArenaEvent.BUY_COUNT_REQ)

        local function callFunc()
            -- 请求
            self:dispatchEvent(ArenaEvent.BUY_COUNT_REQ)
        end
        sender.callFunc = callFunc
        sender.money = self._data.money
        self:isShowRechargeUI(sender)
    end
    local str = self:getTextWord(19003)..self._data.money..self:getTextWord(19004)
    self:showMessageBox(str,okcallbk)
end

-- 是否弹窗元宝不足
function ArenaMainPanel:isShowRechargeUI(sender)
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

function ArenaMainPanel:onHelpBtnHandle(sender)
    local parent = self:getParent()
    local uiTip = UITip.new(parent)
    local line = {}
    local lines = {}
    for i=1,9 do
        line[i] = {{content = self:getTextWord(18112+i), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
        table.insert(lines, line[i])
    end
    uiTip:setAllTipLine(lines)
end

function ArenaMainPanel:setHelpPanel(status)
end

function ArenaMainPanel:onUpdateInfo(data)
    local proxy = self:getProxy(GameProxys.Role)
    local myName = proxy:getRoleName()

    self._data = data
    self:onBuyCountResp(data)
    local index = 1
    table.sort(data.fightInfos, function (a,b) return a.rank < b.rank end)
    for _,v in pairs(data.fightInfos) do
        local team = self._middlePanel:getChildByName("team"..index)
        local score = team:getChildByName("score")
        local name = team:getChildByName("name")
        local level = team:getChildByName("level")
        local fight = team:getChildByName("fight")
        local attackBtn = team:getChildByName("attackBtn")
        local myInfoImg = team:getChildByName("myInfoImg")
        score:setString(v.rank)
        local IconRank = team:getChildByName("imgNum")
        if IconRank then
            IconRank:setVisible(false)
        end
        
        if v.rank < 4 and IconRank then
            IconRank:setVisible(true)
            -- 重新获取对应的图片
            local imgUrl = string.format("images/newGui2/IconNum_%s.png", v.rank)
            TextureManager:updateImageView(IconRank, imgUrl)
        end

        name:setString(v.name)
        level:setString(v.level)
        fight:setString(StringUtils:formatNumberByK3(v.capity))

        if v.name == myName then
            self.curFight = v.capity
            attackBtn:setVisible(false)
            myInfoImg:setVisible(true)
        else
            attackBtn:setVisible(true)
            myInfoImg:setVisible(false)
        end
        team.data = v
        team:setVisible(true)
        attackBtn.data = v
        self:addItemTouchHandle(attackBtn)
        index = index + 1
    end
    for i = index ,6 do
        local team = self._middlePanel:getChildByName("team"..i)
        team:setVisible(false)
    end
end

function ArenaMainPanel:addItemTouchHandle(attackBtn)
    if attackBtn.isAdd == true then
        return
    end
    attackBtn.isAdd = true
    self:addTouchEventListener(attackBtn,self.onBeginFight,nil,nil,1000)
end

function ArenaMainPanel:onCountTime(sender)
    local money = math.ceil(self._coldTime / 60)
    local function okcallbk()
        -- self:dispatchEvent(ArenaEvent.BUY_COLDTIME_REQ)

        local function callFunc()
            -- 请求
            self:dispatchEvent(ArenaEvent.BUY_COLDTIME_REQ)
        end
        sender.callFunc = callFunc
        sender.money = money
        self:isShowRechargeUI(sender)
    end
    local str = self:getTextWord(19003)..money..self:getTextWord(19005)
    self:showMessageBox(str,okcallbk)
end

function ArenaMainPanel:onBeginFight(sender)
    local function fightFun()
        local data = {}
        data.rank = sender.data.rank--sender.data.playerId
        self:dispatchEvent(ArenaEvent.FIGHT_REQ,data) --请求挑战
    end
    if self._coldTime <= 0 then  --冷却时间
        if self._data.challengetimes <= 0 then  --次数不够
            self:onAddBtnHandle(self._addBtn)
        else
            fightFun()
        end
    else
        if self._data.challengetimes <= 0 then  --次数不够
            self:onAddBtnHandle(self._addBtn)
        else
            self:onCountTime(self._addBtn)
        end
    end
end

------
-- 刷新次数回调
function ArenaMainPanel:onBuyCountResp(data)
    local count = self._topPanel:getChildByName("count")
    count:setString(data.challengetimes)
end


function ArenaMainPanel:update()
    local proxy = self:getProxy(GameProxys.Arena)--System)
    self._coldTime = proxy:getRemainTime("ArenaProxy_RemainTime")--getRemainTime(23,0,0)
    if self._coldTime > 0 then
        local timeStr = TimeUtils:getStandardFormatTimeString(self._coldTime)
        self._timeTxt:setString(timeStr)
        self._timeTxt:setVisible(true)
    else
        self._timeTxt:setVisible(false)
    end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- downWidget codes
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ArenaMainPanel:registerEvent()
    local helpBtn = self._topPanel:getChildByName("helpBtn")
    helpBtn.isShow = true
    self:addTouchEventListener(helpBtn,self.onHelpBtnHandle)

    self._addBtn = self._topPanel:getChildByName("addBtn")
    self:addTouchEventListener(self._addBtn,self.onAddBtnHandle)

    for index =1 ,6 do
        local item = self._middlePanel:getChildByName("team"..index)
        -- self:addTouchEventListener(item,self.onClickItemHandle)
        item:addTouchEventListener(function(sender, eventType)
        self:onItemPanelBtn(sender, eventType)
        end)
    end


    self._hisBtn = self:getChildByName("downPanel/hisBtn")
    self._scoreBtn = self:getChildByName("downPanel/scoreBtn")
    self._rewBtn = self:getChildByName("downPanel/rewBtn")
    self._maxFightBtn = self:getChildByName("downPanel/maxFightBtn")
    self._saveBtn = self:getChildByName("downPanel/saveBtn")

    self:addTouchEventListener(self._maxFightBtn,self.onClickMaxBtnHandle)
    self:addTouchEventListener(self._saveBtn,self.onSaveBtnHandle)
    self:addTouchEventListener(self._rewBtn,self.onRewardBtnHandle)
    self:addTouchEventListener(self._scoreBtn,self.onScoreBtnHandle)
    self:addTouchEventListener(self._hisBtn,self.onHisBtnHandle)

    self._equipBtn = self._saveBtn:getChildByName("EquipBtn")
    self:addTouchEventListener(self._equipBtn, self.onOpenEquipHandle)
    self._PeijianBtn = self._saveBtn:getChildByName("PeijianBtn")
    self:addTouchEventListener(self._PeijianBtn, self.onGotoPartsHandle)
end

function ArenaMainPanel:onHisBtnHandle()
    self:dispatchEvent(ArenaEvent.SHOW_OTHER_EVENT,ModuleName.ArenaMailModule)
end

function ArenaMainPanel:onScoreBtnHandle()
    self:dispatchEvent(ArenaEvent.OPEN_ARENASHOP)
end

function ArenaMainPanel:onRewardBtnHandle(sender)
    local panel = self:getPanel(ArenaRewPanel.NAME)
    panel:show()
end

function ArenaMainPanel:onClickMaxBtnHandle()
    local proxy = self:getProxy(GameProxys.Soldier)
    local panel = self:getPanel(ArenaSqurePanel.NAME)
    panel:onCLickMaxBtn()
    panel:setSoliderList(nil)
    local data = proxy:getMaxFight()
    panel:setSoliderList(data)
end

function ArenaMainPanel:onSaveBtnHandle()
    local panel = self:getPanel(ArenaSqurePanel.NAME)
    panel:onSaveSqureHandle()
end

function ArenaMainPanel:setBtnStatus(type)
    downPanel = self:getChildByName("downPanel")
    local show
    local noShow
    if type == 1 then
        show = true
        noShow = false
    else
        show = false
        noShow = true
    end
    self._scoreBtn:setVisible(true)
    self._rewBtn:setVisible(true)
    self._maxFightBtn:setVisible(false)
    self._saveBtn:setVisible(false)

    downPanel:setVisible(show)
end

function ArenaMainPanel:onUpdateDownInfo(data)
    local hisTxt = self._hisBtn:getChildByName("hisTxt")
    local scoreTxt = self._scoreBtn:getChildByName("scoreTxt")
    local rewTxt = self._rewBtn:getChildByName("rewTxt")

    hisTxt:setString(data.wintimes)
    if data.lasttimes == -1 then
        rewTxt:setString(self:getTextWord(19002))
        rewTxt:setColor(ColorUtils.wordColorDark04)
    else
        rewTxt:setString(data.lasttimes)
        rewTxt:setColor(ColorUtils.wordColorDark03)
    end
    
    local proxy = self:getProxy(GameProxys.Role)
    local count = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_arenaGrade)
    scoreTxt:setString(count)

    self:onUpdateDotCount(data.lastReward)
end

function ArenaMainPanel:updateScoreTxt()
    local scoreTxt = self._scoreBtn:getChildByName("scoreTxt")
    local proxy = self:getProxy(GameProxys.Role)
    local count = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_arenaGrade)
    scoreTxt:setString(count)
end

-- 小红点显示更新
function ArenaMainPanel:onUpdateDotCount(isShow)
    -- body
    local dotBg = self._rewBtn:getChildByName("dotBg")
    local dot = dotBg:getChildByName("dot")

    if isShow == 1 then
        -- 可领取
        dotBg:setVisible(true)
        dot:setString("1") --默认显示1
    else
        -- 不可领取
        dotBg:setVisible(false)
    end
end

function ArenaMainPanel:updateEquipAndParts()
    local img = self._equipBtn:getChildByName("img")
    local count = self._equipBtn:getChildByName("count")
    local Image_35 = self._equipBtn:getChildByName("Image_35")
    local proxy = self:getProxy(GameProxys.Equip)
    local equipData = proxy:getEquipAllHome()
    if #equipData == 0 or (not equipData) then
        count:setVisible(false)
        Image_35:setVisible(false)
    else
        count:setVisible(true)
        Image_35:setVisible(true)
        count:setString(#equipData)
    end
    count = self._PeijianBtn:getChildByName("count")
    local Image_36 = self._PeijianBtn:getChildByName("Image_36")
    proxy = self:getProxy(GameProxys.Parts)
    local partsData = proxy:getOrdnanceUnEquipInfos()
    if partsData == nil or #partsData == 0 then
        count:setVisible(false)
        Image_36:setVisible(false)
    else
        count:setVisible(true)
        Image_36:setVisible(true)
        count:setString(#partsData)
    end
end

function ArenaMainPanel:onOpenEquipHandle(sender)
    self:dispatchEvent(ArenaEvent.OPEN_EQUIPMODULE)
end

function ArenaMainPanel:onGotoPartsHandle(sender)
    local proxy = self:getProxy(GameProxys.Role)
    local level = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    if level < 18 then
        self:showSysMessage(self:getTextWord(250007))
        return
    end
    self:dispatchEvent(ArenaEvent.OPEN_PARTS_MODULE)
end
-- 监听列表的子控件
function ArenaMainPanel:onItemPanelBtn(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local function call()
            if self._currItem ~= nil then
                -- local selectImg = self._currItem:getChildByName("selectImg")
                -- selectImg:setVisible(false)
            end
        end
        if sender == nil then
            call()
        else
            local senderSelectImg = sender:getChildByName("selectImg")
            senderSelectImg:setVisible(false)
            
            local proxy = self:getProxy(GameProxys.Role)
            local myName = proxy:getRoleName()
            if sender.data == nil then
                return
            end
            if myName ~= sender.data.name then
                call()
                self._currItem = sender
                -- local selectImg = self._currItem:getChildByName("selectImg")
                -- selectImg:setVisible(true)
                
                local data = {}
                data.playerId =  sender.data.playerId
                if StringUtils:isFixed64Minus(data.playerId) == true then
                    return
                end
                self:dispatchEvent(ArenaEvent.PERSON_INFO_REQ,data)
            end

        end
    elseif eventType == ccui.TouchEventType.began then
        local senderSelectImg = sender:getChildByName("selectImg")
        senderSelectImg:setVisible(true)

    elseif eventType == ccui.TouchEventType.canceled then
        local senderSelectImg = sender:getChildByName("selectImg")
        senderSelectImg:setVisible(false)
    end
end