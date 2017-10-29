--佣兵弹框选择界面
UITeamMessPanel = class("UITeamMessPanel", BasicComponent)
--consuId上阵军师id也要传进来计算带兵量
function UITeamMessPanel:ctor(panel,data,pos,callBack,consuData, isWithoutHero)
    UITeamMessPanel.super.ctor(self)
    local uiSkin = UISkin.new("UITeamMessPanel")
    self._uiSkin = uiSkin
    local father = panel:getParent()
    local grandFather = father:getParent()
    -- uiSkin:setParent(panel:getParent())
    uiSkin:setParent(grandFather)
    self._panel = panel

    self._currPanel = nil

    uiSkin:setTouchEnabled(false)

    -- --start 二级弹窗 -------------------------------------------------------------------
    local extra = {}
    extra["closeBtnType"] = 1
    extra["callBack"] = self.onHideSelfTouch
    extra["obj"] = self

    -- self.secLvBg = UISecLvPanelBg.new(uiSkin:getRootNode(), self, extra)
    self.secLvBg = UISecLvPanelBg.new(grandFather, self, extra)
    self.secLvBg:setContentHeight(800)
    self.secLvBg:setTitle("teamNew7",true)
    self.secLvBg:setLocalZOrder(5)
    self.secLvBg:setBackGroundColorOpacity(120)
    self.secLvBg:setTouchEnabled(true)
    -- uiSkin:getRootNode():setLocalZOrder(5)
    -- --end 二级弹窗 --------------------------------------------------------------------

    -- -- 自适应分辨率
    -- local scale = NodeUtils:getAdaptiveScale()
    -- local winSize = cc.Director:getInstance():getWinSize()
    -- self._uiSkin:setScale(1/scale)
    -- self._uiSkin:setPosition(winSize.width*(1 - 1/scale), winSize.height*(1 - 1/scale)/2)



    self._roleProxy = panel:getProxy(GameProxys.Role)
    self._soliderProxy = panel:getProxy(GameProxys.Soldier)
    self._heroProxy = panel:getProxy(GameProxys.Hero)
    self._currPos = pos
    self._callBack = callBack

    self:registerEvent()

    self:updateData(data, pos, consuData, isWithoutHero)
    self._uiSkin:setLocalZOrder(100)
    
end


function UITeamMessPanel:finalize()
    self._uiSkin:finalize()
    UITeamMessPanel.super.finalize(self)
end

function UITeamMessPanel:registerEvent()
    local listview = self._uiSkin:getChildByName("mainPanel/ListView_6")
    local item = listview:getItem(0)
    listview:setItemModel(item)
    item:setVisible(false)

    local giveUpBtn = self._uiSkin:getChildByName("mainPanel/giveUpBtn")
    self._sureBtn = self._uiSkin:getChildByName("mainPanel/sureBtn")
    self._useCount = self._uiSkin:getChildByName("mainPanel/useCount")
    local exitBtn = self._uiSkin:getChildByName("mainPanel/exitBtn")
    -- local exitBtn = self._uiSkin:getChildByName("bgPanel/frameTop/closeBtn")
    
    giveUpBtn:setTouchEnabled(true)
    self._sureBtn:setTouchEnabled(true)
    exitBtn:setTouchEnabled(false)
    
    ComponentUtils:addTouchEventListener(giveUpBtn, self.onHideSelfTouch, nil, self)
    ComponentUtils:addTouchEventListener(self._sureBtn, self.onHideSelfTouch, nil, self)
    ComponentUtils:addTouchEventListener(exitBtn, self.onHideSelfTouch, nil, self)

    local MovebtnPanel = self._uiSkin:getChildByName("mainPanel/MovebtnPanel")
    self._moveBtn = UIMoveBtn.new(MovebtnPanel,{count = 1,moveCallback = self.setMoveCount,moveCallobj = self})
end

function UITeamMessPanel:updateData(data, pos, consuData, isWithoutHero)
    consuData = consuData or {}
    local command = self._soliderProxy:getAdviserCommand(consuData) or 0
    self._maxFightCount = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command) + command
    
    -- 如果有屏蔽武将：
    if isWithoutHero then
        self._maxFightCount = self._maxFightCount - self._heroProxy:getHerosCommand()
    end

    --城主战 有个削弱带兵量的效果要校验
    local lordCityProxy = self._panel:getProxy(GameProxys.LordCity)
    if lordCityProxy:isLordCityTeamUI() == true then
        local curPercent = lordCityProxy:getCommandPercentAfterSub() or 100  --100%容错
        logger:info("before : command,curPercent = %d %d",command,curPercent)
        command = math.floor(command * curPercent / 100)
        logger:info("after : command,curPercent = %d %d",command,curPercent)
    end

    self._currPos = pos

    local listview = self._uiSkin:getChildByName("mainPanel/ListView_6")
    listview:jumpToTop()

    local sortData = {}
    local index = 1
    local count = 1
    local _index
    for _,v in pairs(data) do
        local j = count % 3
        if j == 1 then
            sortData[index] = {}
            _index = index
            index = index + 1
        elseif j == 0 then
            j = 3
        end
        sortData[_index][j] = v
        count = count + 1
    end

    self:onShowAction()
    --local function call()
        self:renderListView(listview, sortData, self, self.registerItemEvents)
    --end
    --TimerManager:addOnce(60,call,self)
    self:setCurrPos()
end

function UITeamMessPanel:setSelectImgStatus(panel,isShow)
    local Image_19 = panel:getChildByName("Image_19")
    local selectImg = Image_19:getChildByName("selectImg")
    selectImg:setVisible(isShow)
    -- local rest = panel:getChildByName("rest")
    -- rest:setVisible(isShow)
end

function UITeamMessPanel:onHideSelfTouch(sender)
    if sender ~= nil and sender == self._sureBtn then
        self._callBack(self._panel,self._currPos,sender.modleId,sender.count)
    end
    self:setSelectImgStatus(self._currPanel,false)
    --self._uiSkin:setVisible(false)
    --self:onHideAction()
    TimerManager:addOnce(60,self.onHideAction,self)
end

function UITeamMessPanel:setMoveCount(count)
    if self._currPanel == nil then
        return
    end

    -- local rest = self._currPanel:getChildByName("rest")
    -- local select = self._currPanel:getChildByName("select")
    -- rest:setString(self._currPanel.data.num - count)
    -- select:setString(count)
    local infoImg = self._currPanel:getChildByName("infoImg")
    local rest = infoImg:getChildByName("rest")    
    rest:setString(self._currPanel.data.num - count)

    self._sureBtn.count = count
    self._useCount:setString(count)
end

-- 重置未选中坑位的剩余数量
function UITeamMessPanel:onResetRestNumber(panel)
    if panel == nil or panel.data == nil then
        return
    end

    local num = panel.data.num
    -- print("重置坑位 num",num)
    local infoImg = panel:getChildByName("infoImg")
    local rest = infoImg:getChildByName("rest")    
    rest:setString(num)
end

function UITeamMessPanel:onReaderEveryPanel(panel,data,index)
    panel:setVisible(true)
    panel.index = index
    panel:setVisible(true)
    panel.data = data
    -- print("坑位 num,index",data.num,index)
    local infoImg = panel:getChildByName("infoImg")
    local rest = infoImg:getChildByName("rest")    
    rest:setString(data.num)
    
    local dot = panel:getChildByName("dot")
    if dot.doScale == nil then
        dot:setScale(0.8)  --佣兵图片缩放
        dot.doScale = true
    end

    -- if index >= 3 then
        -- local dotPositionY = dot:getPositionY()
        -- dot:setPositionY(dotPositionY - 30)  --模型偏移量Y，加了的给他减回来  ??????
    -- end
    ComponentUtils:updateSoliderPos(panel,data.typeid, nil, nil, nil, nil, nil, nil, nil, true)
    
    local team = panel:getChildByName("Image_19")
    local selectImg = team:getChildByName("selectImg")
    selectImg:setVisible(false)
    self:addTouchEvent(panel)
end

function UITeamMessPanel:registerItemEvents(item,data,index)
    if item == nil or data == nil then
        return
    end

    local i = 0
    for key,v in pairs(data) do
        if type(key) == type(1) then  --reSet update
            local panel = item:getChildByName("panel"..i)
            self:onReaderEveryPanel(panel,v,index)
            i = i + 1
            if i > 3 then
                logger:error("选择的佣兵数据有问题！！！！！！！！！！！！！！")
            end
        end
    end

    if i == 0 then
        item:setVisible(false)
        return
    else
        for j = i,2 do
            local panel = item:getChildByName("panel"..j)
            panel:setVisible(false)
        end
    end
    item:setVisible(true)
    
end

function UITeamMessPanel:addTouchEvent(team)
    if team.isAdd == true then
        return
    end
    team.isAdd = true
    ComponentUtils:addTouchEventListener(team, self.onItemTouch,nil,self)
end

function UITeamMessPanel:onItemTouch(sender)
    if self._currPanel ~= sender then
        self:setSelectImgStatus(self._currPanel,false)
        self:onResetRestNumber(self._currPanel)
        self._currPanel = sender
        self:setSelectImgStatus(self._currPanel,true)
    end

    local changeCount = 0
    changeCount = sender.data.num
    local maxCount = self._maxFightCount
    if changeCount >  maxCount then
        changeCount = maxCount
    end
    self._moveBtn:setEnterCount(changeCount)
    self._sureBtn.count = changeCount
    self._sureBtn.modleId = sender.data.typeid
    self._useCount:setString(changeCount)
end

function UITeamMessPanel:setCurrPos()
    local listview = self._uiSkin:getChildByName("mainPanel/ListView_6")
    local item = listview:getItem(0)
    local panel = item:getChildByName("panel0")

    local infoImg = panel:getChildByName("infoImg")
    local rest = infoImg:getChildByName("rest")    
    rest:setString("0")

    local changeCount = 0
    changeCount = panel.data.num
    local maxCount = self._maxFightCount
    if changeCount >  maxCount then
        changeCount = maxCount
    end
    self._useCount:setString(changeCount)
    self._currPanel = panel
    self:onItemTouch(panel)
    self:setSelectImgStatus(panel,true)
end

function UITeamMessPanel:onShowAction()

    self._uiSkin:setVisible(true)
    self.secLvBg:setVisible(true)
    
    -- local mainPanel = self._uiSkin:getChildByName("mainPanel")
    -- if mainPanel.srcScale == nil then
    --      mainPanel.srcScale = mainPanel:getScale()
    -- end
    -- if self._isScale == nil then
    --     mainPanel:setScale(0.1)
    -- end
    
    -- self._uiSkin:setVisible(true)
    -- self.secLvBg:setVisible(true)
    -- local scale = cc.ScaleTo:create(0.1, mainPanel.srcScale)
    -- mainPanel:runAction(scale)
end

function UITeamMessPanel:onHideAction()
    self._uiSkin:setVisible(false)
    self.secLvBg:setVisible(false)

    -- local mainPanel = self._uiSkin:getChildByName("mainPanel")
    -- local function call()
    --     self._isScale = true
    --     self._uiSkin:setVisible(false)
    --     self.secLvBg:setVisible(false)
    -- end
    -- local scale = cc.ScaleTo:create(0.1,0.1)
    -- local fun = cc.CallFunc:create(call)
    -- mainPanel:runAction(cc.Sequence:create(scale,fun))
end