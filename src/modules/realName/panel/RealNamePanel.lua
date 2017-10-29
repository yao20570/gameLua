-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 实名认证
--  */
RealNamePanel = class("RealNamePanel", BasicPanel)
RealNamePanel.NAME = "RealNamePanel"

function RealNamePanel:ctor(view, panelName)
    local layer = view:getLayer(ModuleLayer.UI_Z_ORDER_5)
    RealNamePanel.super.ctor(self, view, panelName, 550, layer)
end

function RealNamePanel:finalize()
    RealNamePanel.super.finalize(self)
end

function RealNamePanel:initPanel()
	RealNamePanel.super.initPanel(self)
    self:setTitle(true,self:getTextWord(461011))
    self._realNameProxy = self:getProxy(GameProxys.RealName)
end

function RealNamePanel:registerEvents()
	RealNamePanel.super.registerEvents(self)
    self._mainPanel = self:getChildByName("mainPanel")
    self._proveBtn  = self._mainPanel:getChildByName("proveBtn")
    self:addTouchEventListener(self._proveBtn, self.onProveBtn)

    self._bottomImg = self._mainPanel:getChildByName("bottomImg")
    self._contentTxt = self._bottomImg:getChildByName("memoTxt")
    self._holdTxt    = self._bottomImg:getChildByName("holdTxt")
    self._clickPanel = self._bottomImg:getChildByName("clickPanel")
    self._editPanel  = self._bottomImg:getChildByName("editPanel") -- 隐藏的

    self._contentTxt01 = self._bottomImg:getChildByName("memoTxt01")
    self._holdTxt01    = self._bottomImg:getChildByName("holdTxt01")
    self._clickPanel01 = self._bottomImg:getChildByName("clickPanel01")
    self._editPanel01  = self._bottomImg:getChildByName("editPanel01") -- 隐藏的

    self:addTouchEventListener(self._clickPanel, self.onClickPanelHandler)
    self:addTouchEventListener(self._clickPanel01, self.onClickPanel01Handler)
end

function RealNamePanel:onHideHandler()
    self:dispatchEvent(RealNameEvent.HIDE_SELF_EVENT)
end

function RealNamePanel:onShowHandler()
    -- 刷到最新
    local state = 0
    if GameConfig.isOpenRealNameVerify then
        state = 1
    end
    local realNameProxy = self:getProxy(GameProxys.RealName)
    realNameProxy:onTriggerNet460001Req({switchState = state})
end

function RealNamePanel:onUpdatePanel()
    self._realNameInfo = self._realNameProxy:getRealNameInfo()
    self._name         = self._realNameInfo.name      
    self._idNum        = self._realNameInfo.idNum     
    self._state        = self._realNameInfo.state     
    self._onlineTime   = self._realNameInfo.onlineTime
    self._recharge     = self._realNameInfo.recharge -- 单位:元
    logger:info("今日已充值的金额："..self._recharge)  
    self._debuff       = self._realNameInfo.debuff

    self:showNoProvePanel()
end


function RealNamePanel:onProveBtn(sender)
    local data = {}
    data.name = self._commentEditBox:getText()
    data.idNum = self._commentEditBox01:getText()
    
    -- 输入判空
    if data.name == "" then
        self:showSysMessage(self:getTextWord(461001))
        return 
    end
    if data.idNum == "" then
        self:showSysMessage(self:getTextWord(461002))
        return
    end

    -- 长度校验
    local isNice = StringUtils:checkStringLenght(data.name, 1, 4)
    if isNice ~= true then
        self:showSysMessage(self:getTextWord(461009))
        return
    end
    isNice = StringUtils:checkStringLenght(data.idNum, 18, 18)
    if isNice ~= true then
        self:showSysMessage(self:getTextWord(461010))
        return
    end

    -- 信息是否有改动
    if self._oldName ~= data.name or self._oldIdNum ~= data.idNum then
        self._realNameProxy:onTriggerNet460000Req(data)
    end
    self:hide()
end


function RealNamePanel:showNoProvePanel()
    self._maxSize = 8
    self._maxIdSize = 18

    self._contentTxt:setString(self._name) -- 默认空字符串
    
    -- 姓名
    if self._commentEditBox == nil then
        local function callback()
            self:setContentToLabel()
        end
        self._commentEditBox = ComponentUtils:addEditeBox(self._editPanel, self._maxSize, "", callback, false)
        self._commentEditBox:setText(self._name)
    else
        self._commentEditBox:setText(self._name)
    end

    -- 设置占位符
    self._holdTxt:setVisible(true)
    local tipStr = string.format(self:getTextWord(461012))
    if self._commentEditBox:getText() == "" then
        self._holdTxt:setString(tipStr)
    else
        self._holdTxt:setString("")
    end

    -- 身份证号
    self._contentTxt01:setString(self._idNum) -- 默认空字符串
    if self._commentEditBox01 == nil then
        local function callback()
            self:setContentToLabel01()
        end
        self._commentEditBox01 = ComponentUtils:addEditeBox(self._editPanel01, self._maxIdSize, "", callback, false)
        self._commentEditBox01:setText(self._idNum)
    else
        self._commentEditBox01:setText(self._idNum)
    end

    -- 设置占位符
    self._holdTxt01:setVisible(true)
    local tipStr = string.format(self:getTextWord(461013))
    if self._commentEditBox01:getText() == "" then
        self._holdTxt01:setString(tipStr)
    else
        self._holdTxt01:setString("")
    end

    -- 其他显示
    self:showOtherState()

    -- 存储旧的名字和数字
    self._oldName  = self._commentEditBox:getText()
    self._oldIdNum = self._commentEditBox01:getText()
end

function RealNamePanel:onClickPanelHandler(sender)
	self._commentEditBox:openKeyboard()
end

function RealNamePanel:onClickPanel01Handler(sender)
	self._commentEditBox01:openKeyboard()
end

-- 
function RealNamePanel:setContentToLabel()
    if self._contentTxt then
        
        local text = self._commentEditBox:getText()
        -- 为空显示占位
        if string.len(text) == 0 then
            self._holdTxt:setVisible(true)
        else
            self._holdTxt:setVisible(false)
        end

        self._contentTxt:setString(text)
	end
end

function RealNamePanel:setContentToLabel01()
    if self._contentTxt01 then
        
        local text = self._commentEditBox01:getText()
        -- 为空显示占位
        if string.len(text) == 0 then
            self._holdTxt01:setVisible(true)
        else
            self._holdTxt01:setVisible(false)
        end

        self._contentTxt01:setString(text)
	end
end

function RealNamePanel:showOtherState()
    local topImg = self:getChildByName("mainPanel/topImg")
    local titleTxt = topImg:getChildByName("titleTxt")
    local infoTxt = topImg:getChildByName("infoTxt")
    local newInfoTxt = topImg:getChildByName("newInfoTxt")
    local tipTxt    = self:getChildByName("mainPanel/tipTxt")
   
    if newInfoTxt.changePos == nil then
        newInfoTxt.changePos = true
        newInfoTxt:setPositionY(newInfoTxt:getPositionY()+24)
    end

    newInfoTxt:setString("")
    if self._state == 1 then -- 未实名
        self:setTitle(true, self:getTextWord(461000)) -- "未实名认证"
        self._proveBtn:setTitleText(self:getTextWord(461022))
        tipTxt:setString(self:getTextWord(461007)) -- "完成下列实名认证可解除惩罚"

--        titleTxt:setString(self:getTextWord(461004)) -- "未实名惩罚"
--        local hours = math.floor(self._onlineTime / 3600)
--        local infoStr = {
--            {{"1."..self:getTextWord(461014), 20, "#E3DACF"},},
--            {{"2."..string.format(self:getTextWord(461015), hours, self._debuff), 20, "#E3DACF"},},
--        }

--        infoTxt:setString("")
--        local richLabel = infoTxt.richLabel
--        if richLabel == nil then
--            richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
--            infoTxt:addChild(richLabel)
--            infoTxt.richLabel = richLabel
--        end
--        richLabel:setString(infoStr)

        titleTxt:setString("")
        infoTxt:setString("")
        --newInfoTxt:setString( StringUtils:getStringAddBackEnter(self:getTextWord(461024), 26))
        newInfoTxt:setString( self:getTextWord(461024))
    elseif self._state == 2 then -- 实名未成年
        self:setTitle(true, self:getTextWord(461003)) -- "未成年实名认证"
        self._proveBtn:setTitleText(self:getTextWord(461023))
        titleTxt:setString(self:getTextWord(461005)) -- "未成年限制"
        tipTxt:setString(self:getTextWord(461008)) -- "更换实名认证可解除惩罚"

        local roleProxy = self:getProxy(GameProxys.Role)
        --local money = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_today_charge) or 0 -- 元宝，个
        local maxGold = self._realNameProxy:getMaxDailyCharge() -- 人名币，元

        local hours = math.floor(self._onlineTime / 3600)
        local infoStr = {
            {{"1."..self:getTextWord(461019), 20, "#E3DACF"},{self._recharge, 20, "#66ff00"},{"/"..maxGold, 20, "#ffffff"}},
            {{"2.".. string.format(self:getTextWord(461015), hours, self._debuff), 20, "#E3DACF"},},
        }

        infoTxt:setString("")
        local richLabel = infoTxt.richLabel
        if richLabel == nil then
            richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
            infoTxt:addChild(richLabel)
            infoTxt.richLabel = richLabel
        end
        richLabel:setString(infoStr)

    elseif self._state == 3 then -- 3：实名已成年
        self:setTitle(true,self:getTextWord(461011)) -- "未成年实名认证"

    end

end

