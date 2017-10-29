
CreateRolePanel = class("CreateRolePanel", BasicPanel)
CreateRolePanel.NAME = "CreateRolePanel"

function CreateRolePanel:ctor(view, panelName)
    CreateRolePanel.super.ctor(self, view, panelName)

end

function CreateRolePanel:finalize()
    for _, model in pairs(self._modelList) do
        model:finalize(true)
    end

    self._nameTxt:removeFromParent()
    self._nameTxt = nil

    CreateRolePanel.super.finalize(self)
end

function CreateRolePanel:initPanel()
	CreateRolePanel.super.initPanel(self)
	
	local function callback()
	    self:fixEditBoxCenterPos()
	end

    local createBtn = self:getChildByName("mainPanel/createBtn")

    local inputPanel = self:getChildByName("mainPanel/inputPanel")  --images/createRole/Bg_Namebox.png

    --5515 【git包】创角界面，先点击名字输入框后快速点进入游戏，进入游戏后会闪退
    inputPanel.touchBeganCallback = function() 
        createBtn:setTouchEnabled(false)
        local d1 = cc.DelayTime:create(1)
        local cf1 = cc.CallFunc:create(function() createBtn:setTouchEnabled(true) end)
        local seq = cc.Sequence:create(d1, cf1)
        inputPanel:stopAllActions()
        inputPanel:runAction(seq)
    end

    self._editBox = ComponentUtils:addEditeBox(inputPanel, 5, self:getTextWord(203), callback, nil, "images/newGui1/none.png")
    self._editBox:setVisible(false)
    
    self._nameTxt = self:getChildByName("mainPanel/nameTxt")
    self._nameTxt:setLocalZOrder(100)

    self._editBox:setFontName("system")
    self._editBox:setFontSize(26)
    
    self._curSelectSex = 1
    self:setRandomName()
    
    local bgImg = self:getChildByName("bgPanel/bgImg")
    TextureManager:updateImageViewFile(bgImg,"bg/createRole/bg.jpg")
    NodeUtils:adaptiveXCenter(bgImg)
    
    self._modelList = {}
    self:initSpineModel()
end

function CreateRolePanel:initSpineModel()
    for index=1, 2 do
        local url = string.format("mainPanel/iconPanel%d/selectImg/iconContainer",index)
        local iconContainer = self:getChildByName(url)
        local model = SpineModel.new(10000 + index, iconContainer)
        model:playAnimation("animation", true)
        table.insert(self._modelList, model)
    end
end

function CreateRolePanel:registerEvents()
    local createBtn = self:getChildByName("mainPanel/createBtn")    
    self:addTouchEventListener(createBtn, self.onCreateBtnTouch)
    
    local infoPanel1 = self:getChildByName("mainPanel/iconPanel1")
    local infoPanel2 = self:getChildByName("mainPanel/iconPanel2")
    
    infoPanel1.sex = 1
    infoPanel2.sex = 2
    self:addTouchEventListener(infoPanel1, self.onCreateSexTouch)
    self:addTouchEventListener(infoPanel2, self.onCreateSexTouch)
    
    local randomBtn = self:getChildByName("mainPanel/randomBtn")
    self:addTouchEventListener(randomBtn, self.onRandomBtnTouch)

    self._sprite = cc.Sprite:create()
    local mainPanel = self:getChildByName("mainPanel")
    mainPanel:addChild(self._sprite)
    self._sprite:setPosition(randomBtn:getPosition())
end


function CreateRolePanel:onCreateSexTouch(sender)
    local sex = sender.sex
    self:onSelectSex(sex)
end

function CreateRolePanel:onRandomBtnTouch(sender)
    self:reSetRandomName(sender)
end


function CreateRolePanel:onSelectSex(sex)
    if self._curSelectSex == sex then
        return
    end
    
    local oldPanel = self:getChildByName("mainPanel/iconPanel" .. self._curSelectSex)
    self:renderIconPanel(oldPanel, false)
    
    local newPanel = self:getChildByName("mainPanel/iconPanel" .. sex)
    self:renderIconPanel(newPanel, true)
    
    self._curSelectSex = sex
    
    
end

function CreateRolePanel:renderIconPanel(iconPanel, isSelect)
    local selectImg = iconPanel:getChildByName("selectImg")
    local noSelectImg = iconPanel:getChildByName("noSelectImg")
    
    selectImg:setVisible(isSelect)
    noSelectImg:setVisible(not isSelect)
end

--创建角色
function CreateRolePanel:onCreateBtnTouch(sender)
    local data = {}
    data.sex = self._curSelectSex
    data.name = self._editBox:getText()
    
    if data.name == "" then
        self:showSysMessage(self:getTextWord(204))
        return
    end
    
    if not StringUtils:checkStringValid(data.name) then
        self:showSysMessage(self:getTextWord(205))
        return
    end
    if not StringUtils:checkStringSize(data.name) then
        self:showSysMessage(self:getTextWord(219))
        return
    end

    -- 设置不能点击(点击了创角后，再点击名称输入会弹出输入框(android), 并且关不掉)
    local inputPanel = self:getChildByName("mainPanel/inputPanel")
    inputPanel:setTouchEnabled(false)

    -- 1秒后启用点击(防止当创角失败后无法点击输入名称)
    local d1 = cc.DelayTime:create(1)
    local cf1 = cc.CallFunc:create(function() inputPanel:setTouchEnabled(true) end)
    local seq = cc.Sequence:create(d1, cf1)
    inputPanel:stopAllActions()
    inputPanel:runAction(seq)

    self:dispatchEvent(CreateRoleEvent.CREATE_ROLE_REQ, data)    
end

function CreateRolePanel:setRandomName()
    local fullName = self:getRandomFullName(self._curSelectSex)
    self._editBox:setText(fullName)
    
    self:fixEditBoxCenterPos()
end


function CreateRolePanel:reSetRandomName(sender)
    sender:setVisible(false)
    local step = 0
    local function shark()
        step = step + 1
        local fullName = self:getRandomFullName(self._curSelectSex)
        self._editBox:setText(fullName)
        self:fixEditBoxCenterPos()
        if step == 5 then
            TimerManager:remove(self.shark, self)
            sender:setVisible(true)
        end
    end
    self.shark = shark
    TimerManager:add(90, self.shark, self, 5)
    local effect = UICCBLayer.new("rbg-shazi", self._sprite, nil, nil, true)
end

function CreateRolePanel:fixEditBoxCenterPos()
    --不去调整居中了，直接放多个居中的Label在上面，省心省力 
    local text = self._editBox:getText()
    text = text or ""
    self._nameTxt:setString(text)
end


function CreateRolePanel:getRandomFullName(sex)
    local surnameTable
    if sex == 1 then
        surnameTable = NameLibrary["manSurname"]
    else
        surnameTable = NameLibrary["womanSurname"]
    end
    local surnameLen = #surnameTable
    local surnameIndex = math.random(1, surnameLen)
    local surname = surnameTable[surnameIndex]

    local nameTable = nil
    if sex == 1 then
        nameTable = NameLibrary["manName"]
    else
        nameTable = NameLibrary["womanName"]
    end
    local nameLen = #nameTable
    local nameIndex = math.random(1, nameLen)
    local name = nameTable[nameIndex]

    local fullname = surname .. name  

    logger:info("====获取随机名字==%s=======", fullname)
    return fullname
end

--检测名字是否有效
function CreateRolePanel:checkRoleNameValid(name)
    local flag1 = StringUtils:checkStringSize(name)
    local flag2 = StringUtils:checkStringValid(name)
    return flag1 and flag2
end




