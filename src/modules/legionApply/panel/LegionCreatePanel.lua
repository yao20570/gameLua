
LegionCreatePanel = class("LegionCreatePanel", BasicPanel)
LegionCreatePanel.NAME = "LegionCreatePanel"

function LegionCreatePanel:ctor(view, panelName)
    LegionCreatePanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function LegionCreatePanel:finalize()
    LegionCreatePanel.super.finalize(self)
end

function LegionCreatePanel:initPanel()
    LegionCreatePanel.super.initPanel(self)
    -- self:setBgType(ModulePanelBgType.LEGIONCRE)

    
    local tipTxt = self:getChildByName("mainPanel/upPanel/tipTxt")
    tipTxt:setString("("..self:getTextWord(3156)..")")
    
    -- local function callback()
    --     self._editeBox:setText(self._editeBox:getText())
    -- end

    --输入框
    local inputPanel = self:getChildByName("mainPanel/upPanel/inputPanel")

    local function callback()
        if self._editeBox:getText()=="" then
            tipTxt:setVisible(true)
        else
            tipTxt:setVisible(false)
        end
    end

    local defualtTxt = ""--self:getTextWord(3156)
    local url = "images/newGui9Scale/SpKeDianJiBg.png"
    self._editeBox = ComponentUtils:addEditeBox(inputPanel,5,defualtTxt,callback,nil,url)

    --加入条件复选框组
    local join1Box = self:getChildByName("mainPanel/upPanel/joinPanel/join1Box")
    local join2Box = self:getChildByName("mainPanel/upPanel/joinPanel/join2Box")
    local list = {join1Box, join2Box}
    local joinRadioGroup = UIRadioGroup.new(list, 1)
    self._joinRadionGroup = joinRadioGroup
    --创建方式复选框组
    local create1Box = self:getChildByName("mainPanel/upPanel/createPanel/create1Box")
    local create2Box = self:getChildByName("mainPanel/upPanel/createPanel/create2Box")
    local list = {create1Box, create2Box}
    local createRadioGroup = UIRadioGroup.new(list, 1)
    self._createRadioGroup = createRadioGroup
    self:initCreateCost()
end

function LegionCreatePanel:doLayout()

    -- 自适应
    local tabsPanel = self:getTabsPanel()
    local mainPanel = self:getChildByName("mainPanel")
    local downPanel = self:getChildByName("downPanel")
    -- NodeUtils:adaptiveTopPanelAndListView(mainPanel, nil, downPanel, tabsPanel)

    local LegionApplyPanel = self:getPanel(LegionApplyPanel.NAME)
    if LegionApplyPanel ~= nil then
        -- NodeUtils:adaptivePanelBg(panel, 20, mainpanel:getBestPanel())
        NodeUtils:adaptiveUpPanel(mainPanel,LegionApplyPanel:getAdtNode(),0)
        NodeUtils:adaptiveCenterPanel(downPanel,mainPanel,10)
    else
        -- NodeUtils:adaptivePanelBg(panel, 20, GlobalConfig.topHeight)
        NodeUtils:adaptivePanelBg(panel, 20, self:topAdaptivePanel():getPositionY()-85)
    end

end

function LegionCreatePanel:onTabChangeEvent(tabControl)
    local downWidget = self:getChildByName("downPanel")
    LegionCreatePanel.super.onTabChangeEvent(self, tabControl, downWidget)
end

function LegionCreatePanel:registerEvents()
    LegionCreatePanel.super.registerEvents(self)
    local createBtn = self:getChildByName("downPanel/createBtn")
    self:addTouchEventListener(createBtn,self.onCreateBtnTouch)
end
function LegionCreatePanel:onShowHandler(data)
    LegionCreatePanel.super.onShowHandler(self)
    self:resetPanel()
    self:updateCreateCost() --更新资源颜色
end 
function LegionCreatePanel:initCreateCost()
    --local createPanel = self:getChildByName("mainPanel/upPanel/createPanel/")
    local labelGold = self:getChildByName("mainPanel/upPanel/createPanel/need1Panel/needPanel1/needTxt")
    local label1 = self:getChildByName("mainPanel/upPanel/createPanel/need2Panel/needPanel1/needTxt")
    local label2 = self:getChildByName("mainPanel/upPanel/createPanel/need2Panel/needPanel2/needTxt")
    local label3 = self:getChildByName("mainPanel/upPanel/createPanel/need2Panel/needPanel3/needTxt")
    local label4 = self:getChildByName("mainPanel/upPanel/createPanel/need2Panel/needPanel4/needTxt")
    local label5 = self:getChildByName("mainPanel/upPanel/createPanel/need2Panel/needPanel5/needTxt")

        
    -- goldNum = 50   
    self.needTab = {}
    self.needTab["POWER_tael"] = 300000    
    self.needTab["POWER_iron"] = 300000    
    self.needTab["POWER_stones"] = 300000    
    self.needTab["POWER_wood"] = 300000    
    self.needTab["POWER_food"] = 300000    
    self.needTab["POWER_gold"] = 50    

    -- self.labelGold = labelGold
    self.labelTab = {}
    self.labelTab["POWER_tael"] = label1    
    self.labelTab["POWER_iron"] = label2    
    self.labelTab["POWER_stones"] = label3    
    self.labelTab["POWER_wood"] = label4    
    self.labelTab["POWER_food"] = label5   
    self.labelTab["POWER_gold"] = labelGold


    labelGold:setString(StringUtils:formatNumberByK(self.needTab["POWER_gold"],0))
    label1:setString(StringUtils:formatNumberByK(self.needTab["POWER_tael"],0))
    label2:setString(StringUtils:formatNumberByK(self.needTab["POWER_iron"],0))
    label3:setString(StringUtils:formatNumberByK(self.needTab["POWER_stones"],0))
    label4:setString(StringUtils:formatNumberByK(self.needTab["POWER_wood"],0))
    label5:setString(StringUtils:formatNumberByK(self.needTab["POWER_food"],0))
 
end 

-- 更新资源颜色
function LegionCreatePanel:updateCreateCost()
    -- body
    local powerTab = {}
    powerTab["POWER_tael"] = PlayerPowerDefine.POWER_tael        -- 银两
    powerTab["POWER_iron"] = PlayerPowerDefine.POWER_iron        -- 铁锭
    powerTab["POWER_stones"] = PlayerPowerDefine.POWER_stones    -- 石料
    powerTab["POWER_wood"] = PlayerPowerDefine.POWER_wood        -- 木材
    powerTab["POWER_food"] = PlayerPowerDefine.POWER_food        -- 粮食
    powerTab["POWER_gold"] = PlayerPowerDefine.POWER_gold        -- 元宝

    
    local roleProxy = self:getProxy(GameProxys.Role)
    -- 元宝
    -- local POWER_gold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--金币

    for k,v in pairs(powerTab) do
        -- print("更新资源颜色···k="..k..",v="..v)
        local color = nil
        local value = nil
        if k == "POWER_gold" then
            value = roleProxy:getRoleAttrValue(v)   --当前拥有量
        else            
            value = roleProxy:getRolePowerValue(GamePowerConfig.Resource, v)   --当前拥有量
        end
        -- print("已有值···value="..value)
        if self.needTab[k] <= value then
            -- 足够
            color = ColorUtils.wordColorLight03
        else
            -- 不足够
            color = ColorUtils.wordColorLight04
        end
        -- print("000000000000000000000//////////////////")
        self.labelTab[k]:setColor(color)
    end

end


--重置面板
function LegionCreatePanel:resetPanel()
    --输入框内容重置
    self._editeBox:setText("")
    --加入方式复选框组重置
    self._joinRadionGroup:setSelectIndex(1)
    --创建方式复选框重置
    self._createRadioGroup:setSelectIndex(1)
end 

-----回调函数定义---------
function LegionCreatePanel:onCreateBtnTouch(sender)
    --创建军团
    local joinWay = self._joinRadionGroup:getCurSelectIndex()
    local createWay = self._createRadioGroup:getCurSelectIndex()
    local name = self._editeBox:getText()
    print("joinWay,createWay,name",joinWay,createWay,name)
    --没有输入军团名
    if name == "" then
        local tempStr = self:getTextWord(3140)
        self:showSysMessage(tempStr)
        return
    end
    --没有选择加入条件
    if joinWay == 0 then
        local tempStr = self:getTextWord(3143)
        self:showSysMessage(tempStr)
        return
    end
    --没有选择创建方式
    if createWay == 0 then
        local tempStr = self:getTextWord(3144)
        self:showSysMessage(tempStr)
        return
    end

    if not StringUtils:checkStringSize(name) then
        self:showSysMessage(self:getTextWord(3156))
        return
    end


    if createWay == 1 then
        -- 元宝创建军团
        local price = 50 --费用50元宝
        local function okcallbk()
            local function callFunc()
                -- 请求
                local data = {joinway = joinWay,way = createWay, name = name }
                self:dispatchEvent(LegionApplyEvent.LEGION_CREATE_REQ, data)
            end
            sender.callFunc = callFunc
            sender.money = price
            self:isShowRechargeUI(sender)
        end
        local str = string.format(self:getTextWord(3120), price)
        self:showMessageBox(str,okcallbk)
    else
        -- 资源创建军团
        if self:isResEnough() then
            local data = {joinway = joinWay,way = createWay, name = name }
            self:dispatchEvent(LegionApplyEvent.LEGION_CREATE_REQ, data)
        else
            self:showSysMessage(self:getTextWord(3208))
        end
    end
end

-- 是否弹窗元宝不足
function LegionCreatePanel:isShowRechargeUI(sender)
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

-- 判断资源是否足够
function LegionCreatePanel:isResEnough()
    local isEnough = true
    local roleProxy = self:getProxy(GameProxys.Role)
    for i = 201, 205 do
        local res = roleProxy:getRoleAttrValue(i)
        --print(res)
        if res < 300000 then
            isEnough = false
            break
        end
    end
    return isEnough
end

