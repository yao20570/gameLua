-- /**
--  * @DateTime:    2016-01-14 11:07:18
--  * @Description: 军团信息-编辑
--  */

LegionEditPanel = class("LegionEditPanel", BasicPanel)
LegionEditPanel.NAME = "LegionEditPanel"
LegionEditPanel.LIMIT_LEN = 120 -- 一个中文3个字符

LegionEditPanel.NOTICE_LIMIT_LEN = 40 -- 中文英文和符号都设定为1个字符
LegionEditPanel.AFFICHE_LIMIT_LEN = 70 -- 中文英文和符号都设定为1个字符

function LegionEditPanel:ctor(view, panelName)
    LegionEditPanel.super.ctor(self, view, panelName, 800)
    
    self:setUseNewPanelBg(true)
end

function LegionEditPanel:finalize()
    LegionEditPanel.super.finalize(self)
end

function LegionEditPanel:initPanel()
	LegionEditPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(3020))
	
    local join1Box = self:getChildByName("mainPanel/joinPanel/join1Box")
    local join2Box = self:getChildByName("mainPanel/joinPanel/join2Box")
    local list = {join1Box, join2Box}
    local joinTypeRadioGroup = UIRadioGroup.new(list, 1)
    self._joinTypeRadioGroup = joinTypeRadioGroup
    
    self._numKeyBoard = UINumKeyBoard.new(self, 99999999, self.onNumKeyBoardCallback)
    

    local inputPanel = self:getChildByName("mainPanel/inputPanel")
    local inputPanel1 = self:getChildByName("mainPanel/inputPanel1")

    --宣言
    self._noticeTxt = self:getChildByName("mainPanel/noticeTxt")
    local noticeTip = self:getChildByName("mainPanel/Label_112_0")
    --公告
    self._gongTxt = self:getChildByName("mainPanel/gongTxt")
    local gongTip = self:getChildByName("mainPanel/Label_112_1")
    -- 提示字段
    noticeTip:setString(self:getTextWord(3039))
    gongTip:setString(self:getTextWord(3040))
    local function callback()
        self:setContentToLabel()
    end
    local function callback1()
        self:setContentGong()
    end
    -- 宣言
    self._editBox = ComponentUtils:addEditeBox(inputPanel, LegionEditPanel.NOTICE_LIMIT_LEN, "", callback, nil, "images/newGui9Scale/SpKeDianJiBg.png")
    -- 公告
    self._editBox1 = ComponentUtils:addEditeBox(inputPanel1, LegionEditPanel.AFFICHE_LIMIT_LEN, "", callback1, nil, "images/newGui9Scale/SpKeDianJiBg.png")
    
    self._joinCondPanelMap = {}
    for index=1, 2 do
        local condPanel = self:getChildByName("mainPanel/joinCondPanel/condPanel" .. index)
        self._joinCondPanelMap[index] = condPanel
    end
end

--设置宣言
function LegionEditPanel:setContentToLabel()
    local text = self._editBox:getText()
    if string.len(text) == 0 then
        self._noticeTxt:setString(self:getTextWord(3007))
    else
        self._noticeTxt:setString(text)
    end
    self._editBox:setText("")
end

--设置公告
function LegionEditPanel:setContentGong()
    local text = self._editBox1:getText()
    if string.len(text) == 0 then
        self._gongTxt:setString(self:getTextWord(3006))
    else
        self._gongTxt:setString(text)
    end
    self._editBox1:setText("")
    -- end

end

function LegionEditPanel:onAfterActionHandler()
    self:onShowHandler()
end

function LegionEditPanel:onShowHandler()
    if self:isModuleRunAction() then
        return
    end

    --先设置文本
    self:setContentToLabel()
    
    local legionProxy = self:getProxy(GameProxys.Legion)
    local mineInfo = legionProxy:getMineInfo()
    local mainPanel = self:getChildByName("mainPanel")
    self:renderMainPanel(mainPanel, mineInfo)
end

function LegionEditPanel:renderMainPanel(mainPanel, mineInfo)
    self._joinTypeRadioGroup:setSelectIndex(mineInfo.joinType)
    
    local joinCondPanel = mainPanel:getChildByName("joinCondPanel")
    self:renderJoinCondPanel(joinCondPanel, mineInfo)
end

function LegionEditPanel:renderJoinCondPanel(joinCondPanel, mineInfo)
    for index, condPanel in pairs(self._joinCondPanelMap) do
        local value = mineInfo["joinCond" .. index]
        self:renderCondPanel(condPanel, value)
    end
    
    
    --宣言
    if mineInfo.notice=="" then
        self._noticeTxt:setString( self:getTextWord(3007) )
    else
        self._noticeTxt:setString( mineInfo.notice )
    end
    --公告
    if mineInfo.affiche=="" then
        self._gongTxt:setString( self:getTextWord(3006) )
    else
        self._gongTxt:setString( mineInfo.affiche )
    end
end

function LegionEditPanel:renderCondPanel(condPanel, condValue)
    local condBox = condPanel:getChildByName("condBox")
    condBox:setSelectedState(condValue > 0)
    local numTxt = condPanel:getChildByName("numTxt")
    numTxt:setString(condValue)
    
end

-------------------------
--打开数字面板
function LegionEditPanel:onTouchImgTouch(sender)
    if sender.index == 1 then  
        -- 等级
        self._numKeyBoard:setMaxNum(99)
    else   
        -- 战力
        self._numKeyBoard:setMaxNum(99999999)
    end
    self._numKeyBoard:show(sender)
end

function LegionEditPanel:onNumKeyBoardCallback(sender, num)
    local numTxt = sender.numTxt
    numTxt:setString(num)
end

function LegionEditPanel:registerEvents()
	LegionEditPanel.super.registerEvents(self)
    local saveBtn = self:getChildByName("mainPanel/saveBtn")
    self:addTouchEventListener(saveBtn, self.onSaveBtnTouch)
    
    -- local closeBtn = self:getChildByName("mainPanel/closeBtn")
    -- self:addTouchEventListener(closeBtn, self.onCloseBtnTouche)
    
    
    for index, condPanel in pairs(self._joinCondPanelMap) do
        local touchImg = condPanel:getChildByName("touchImg")
        local numTxt = condPanel:getChildByName("numTxt")
        touchImg.numTxt = numTxt
        touchImg.index = index
        self:addTouchEventListener(touchImg, self.onTouchImgTouch)
    end
end

function LegionEditPanel:onSaveBtnTouch(sender)
    --TODO 军团编辑保存处理 这里需要做一层校验 只筛选出有改变过的
    local data = {}
    local joinType = self._joinTypeRadioGroup:getCurSelectIndex()
    
    -- print("joinType = "..joinType)
    if joinType == 0 then
        -- self:onCloseBtnTouche(sender)
        self:showSysMessage(self:getTextWord(3043))
        return
    end

    data["joinType"] = joinType
    -- for index=1, 2 do
        for index, condPanel in pairs(self._joinCondPanelMap) do
            local condBox = condPanel:getChildByName("condBox")
            if condBox:getSelectedState() == false then
                data["joinCond" .. index] = 0
            else
                local numTxt = condPanel:getChildByName("numTxt")
                data["joinCond" .. index] = tonumber(numTxt:getString())
            end
        end
    -- end
    -- local noticeTxt = self:getChildByName("mainPanel/noticeTxt")
    -- data.notice = noticeTxt:getText()

    local text = self._noticeTxt:getString()
    local gongtxt = self._gongTxt:getString()
    
    data.notice = text 
    data.affiche = gongtxt -- 公告 

--    local noticeLen = #StringUtils:separate(data.notice)
--    local afficheLen = #StringUtils:separate(data.affiche)
--    logger:error("当前noticeLen:"..noticeLen)
--    logger:error("当前afficheLen:"..afficheLen)

--    if noticeLen > LegionEditPanel.NOTICE_LIMIT_LEN then -- 宣言
--        self:showSysMessage(self:getTextWord(3042))
--        return
--    elseif afficheLen > LegionEditPanel.AFFICHE_LIMIT_LEN then -- 公告
--        self:showSysMessage(self:getTextWord(3041))
--        return
--    end


    local legionProxy = self:getProxy(GameProxys.Legion)
    legionProxy:onTriggerNet220210Req(data)
end

function LegionEditPanel:onCloseBtnTouche(sender)
    self:hide()
end




