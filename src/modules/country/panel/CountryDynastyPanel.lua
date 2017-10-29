-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
CountryDynastyPanel = class("CountryDynastyPanel", BasicPanel)
CountryDynastyPanel.NAME = "CountryDynastyPanel"

function CountryDynastyPanel:ctor(view, panelName)
    CountryDynastyPanel.super.ctor(self, view, panelName, 400)

end

function CountryDynastyPanel:finalize()
    CountryDynastyPanel.super.finalize(self)
end

function CountryDynastyPanel:initPanel()
	CountryDynastyPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(122), false) -- "系统信息"
    self._countryProxy = self:getProxy(GameProxys.Country)
end

function CountryDynastyPanel:registerEvents()
	CountryDynastyPanel.super.registerEvents(self)
    self._mainPanel = self:getChildByName("mainPanel")
    self._cancleBtn = self._mainPanel:getChildByName("cancleBtn")
    self._okBtn = self._mainPanel:getChildByName("okBtn")

    self:addTouchEventListener(self._cancleBtn, self.onCancleBtn)
    self:addTouchEventListener(self._okBtn, self.onOkBtn)

    self._nameTxt01 = self._mainPanel:getChildByName("nameTxt01")
    self._nameTxt02 = self._mainPanel:getChildByName("nameTxt02")

    self._editPanel01 = self._mainPanel:getChildByName("editPanel01")
    self._editPanel02 = self._mainPanel:getChildByName("editPanel02")

    self._textImg01 = self._mainPanel:getChildByName("textImg01")
    self._textImg02 = self._mainPanel:getChildByName("textImg02")

    self:addTouchEventListener(self._textImg01, self.onClick01)
    self:addTouchEventListener(self._textImg02, self.onClick02)
end

function CountryDynastyPanel:onShowHandler()
--    self._nameTxt01:setString(self._countryProxy:getDynastyName())
--    self._nameTxt02:setString(self._countryProxy:getEmperorName())
    self._nameTxt01:setString("")
    self._nameTxt02:setString("")

    -- 加editBox
    if self._commentEditBox01 == nil then
        local function callback()
            self:setContentToLabel01()
        end
        self._commentEditBox01 = ComponentUtils:addEditeBox(self._editPanel01, 1, "", callback)
    else
        self._commentEditBox01:setText("")
    end-- 加editBox

    if self._commentEditBox02 == nil then
        local function callback()
            self:setContentToLabel02()
        end
        self._commentEditBox02 = ComponentUtils:addEditeBox(self._editPanel02, 1, "", callback)
    else
        self._commentEditBox02:setText("")
    end

end


function CountryDynastyPanel:setContentToLabel01()
    local text = self._commentEditBox01:getText()
    self._nameTxt01:setString( string.sub(text, 1, 3))
end


function CountryDynastyPanel:setContentToLabel02()
    local text = self._commentEditBox02:getText()
    self._nameTxt02:setString( string.sub(text, 1, 3))
end


function CountryDynastyPanel:onClick01(sender)
	self._commentEditBox01:openKeyboard()
end

function CountryDynastyPanel:onClick02(sender)
	self._commentEditBox02:openKeyboard()
end

function CountryDynastyPanel:onCancleBtn(sender)
    self:hide()
end

function CountryDynastyPanel:onOkBtn(sender)
    local dynastyName = self._countryProxy:getDynastyName()
    if dynastyName ~= "" then
        -- 提示只能修改一次
        self:showSysMessage(self:getTextWord(560030))
         return 
    end

    -- 提示输入中文
    local dynastyNameCh = self:isChWord(self._nameTxt01:getString())
    local emperorNameCh = self:isChWord(self._nameTxt02:getString())
    if dynastyNameCh == false or emperorNameCh == false then
        self:showSysMessage(self:getTextWord(560032)) -- "请输入正确的中文"
        return 
    end

    
    
    local data = {}
    data.dynastyName = self._nameTxt01:getString()
    data.emperorName = self._nameTxt02:getString()
    -- 去掉空格
    data.dynastyName = StringUtils:trim(data.dynastyName)
    data.emperorName = StringUtils:trim(data.emperorName)

    if data.dynastyName == "" then
        self:showSysMessage(self:getTextWord(560009))
        return
    end

    if data.emperorName == "" then
        self:showSysMessage(self:getTextWord(560010))
        return
    end

    self._countryProxy:onTriggerNet561000Req(data)
    self:hide()
end


------
-- 是否都是中文
function CountryDynastyPanel:isChWord(str)
    local state = true 
    for ch in string.gmatch(str, "[\\0-\127\194-\244][\128-\191]*") do
        -- print(ch, #ch ~= 1)
        if #ch ~= 1 == false then
            state = false
            break
        end
    end
    return state
end
