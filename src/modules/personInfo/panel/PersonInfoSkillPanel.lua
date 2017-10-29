--个人信息战法界面
--FZW 
--2015/11/20
PersonInfoSkillPanel = class("PersonInfoSkillPanel", BasicPanel)  
PersonInfoSkillPanel.NAME = "PersonInfoSkillPanel"

function PersonInfoSkillPanel:ctor(view, panelName)
    PersonInfoSkillPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function PersonInfoSkillPanel:finalize()
    PersonInfoSkillPanel.super.finalize(self)
end

function PersonInfoSkillPanel:initPanel()
    PersonInfoSkillPanel.super.initPanel(self)

    self._listview = {}
    self._SkillConfig = ConfigData.SkillConfig
    -- self._SkillLvConfig = ConfigData.SkillLevelConfig
    self._LISTVIEW = self:getChildByName("ListView_1")
    
    
    

    self._skillProxy = self:getProxy(GameProxys.Skill)
    self._skillConf = self._skillProxy:getSkillConfData()

    _SkillLvConf = ConfigDataManager:getConfigDataBySortId(ConfigData.SkillLevelConfig)
    _SkillConf = ConfigDataManager:getConfigData(ConfigData.SkillConfig)


    self._roleProxy = self:getProxy(GameProxys.Role)
    _playerLevel = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    _skillBook = self:getSkillBookNumber()
end

function PersonInfoSkillPanel:doLayout()
    local upWidget = self:getTabsPanel()
    local downWidget = self:getChildByName("downPanel")
    NodeUtils:adaptiveListView(self._LISTVIEW,downWidget,upWidget,GlobalConfig.topTabsHeight)
end

function PersonInfoSkillPanel:onTabChangeEvent(tabControl)
    local downWidget = self:getChildByName("downPanel")
    PersonInfoSkillPanel.super.onTabChangeEvent(self, tabControl, downWidget)
end


function PersonInfoSkillPanel:onHide()
    -- print("关闭战法界面-------------onHideHandler")
    self._LISTVIEW:jumpToTop()
    _skillBook = self:getSkillBookNumber()
    _playerLevel = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    self:hide()
end

function PersonInfoSkillPanel:onShowHandler(info)
    -- body
    if #self._listview > 0 then
        local playerLevel = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
        local skillBook = self:getSkillBookNumber()

        -- 玩家等级和战法秘籍都没变，则不刷新界面
        -- print("打开战法界面onShowHandler--->_playerLevel,playerLevel,_skillBook,skillBook",_playerLevel,playerLevel,_skillBook,skillBook)
        if _playerLevel == playerLevel and _skillBook == skillBook then
            -- print("-- 玩家等级和战法秘籍都没变，则不刷新战法界面")
            -- self._LISTVIEW:jumpToTop()
            return
        end
    end

    self:onSkillListResp({})
    self:renderListView(self._LISTVIEW, self._skillConf, self, self.onRenderListViewInfo,nil,nil,GlobalConfig.listViewRowSpace)
    self:onUpdateSkillInfo()
end

function PersonInfoSkillPanel:onRenderListViewInfo(itempanel,info,index)
    -- body
    itempanel:setVisible(true)

    local itemBtn = itempanel:getChildByName("itemBtn")
    local Label_name = itemBtn:getChildByName("Label_name")
    local labLv = itemBtn:getChildByName("labLv")
    local Label_detail122 = itemBtn:getChildByName("Label_detail122")
    local tipBtn = itemBtn:getChildByName("tipBtn")
    local upBtn = itemBtn:getChildByName("upBtn")

    local iconInfo = {}
    iconInfo.power = GamePowerConfig.Skill
    iconInfo.typeid = info.ID
    iconInfo.num = 0
    
    -- print("技能···_SkillConf[info.ID].icon=".._SkillConf[info.ID].icon..",info.ID="..info.ID)

    local icon = itempanel.icon
    if icon == nil then
        local iconImg = itemBtn:getChildByName("iconImg")
        icon = UIIcon.new(iconImg,iconInfo,false)
        
        itempanel.icon = icon
    else
        icon:updateData(iconInfo)
    end
    
    local skillInfo = self:onGetSkillInfo(info.ID)
    local skillLv = skillInfo.level
    Label_name:setString(info.name.." ")--(info.name.." "..string.format(self:getTextWord(529),skillLv))
    Label_detail122:setString(info.desc)
    labLv:setString(string.format(self:getTextWord(529),skillLv))
    NodeUtils:alignNodeL2R(Label_name,labLv,tipBtn)

    -- tipBtn坐标偏移
    -- local size = Label_name:getContentSize()
    -- local x = Label_name:getPositionX() + size.width + 30
    -- tipBtn:setPositionX(x)
    
    -- local roleProxy = self:getProxy(GameProxys.Role)
    local playerLevel = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    local skillBook = self:getSkillBookNumber()

    -- local conf,lastData = ConfigDataManager:getInfoFindByOneKey2(self._SkillLvConfig,"skilllevel",skillLv)
    local conf = _SkillLvConf[skillLv+1]
    local lastData = _SkillLvConf[#_SkillLvConf]



    if skillLv < lastData.skilllevel then        
        local itemneed = StringUtils:jsonDecode(conf.itemneed)
        if playerLevel < conf.captainlv then
            NodeUtils:setEnable(upBtn,false)
            itempanel:setTouchEnabled(false)
        else
            NodeUtils:setEnable(upBtn,true)
            upBtn.ID = info.ID
            upBtn.needbook = itemneed[2]
            self:addTouchEventListener(upBtn,self.onTouchUpBtn)
            -- self:addTouchEventListener(itempanel,self.onTouchUpBtn)
            itempanel.ID = info.ID
            itempanel.needbook = itemneed[2]
        end
        upBtn:setTitleText(self:getTextWord(580))
    else
        NodeUtils:setEnable(upBtn,false)
        upBtn:setTitleText(self:getTextWord(581))
    end

    tipBtn.info = info
    self:addTouchEventListener(tipBtn,self.onTouchTipBtn)
    itemBtn.info = info
    self:addTouchEventListener(itemBtn,self.onTouchTipBtn)

    self._listview[info.ID] = itempanel
    local index = self._LISTVIEW:getIndex(itempanel)
    self["item" .. (index + 1)] = upBtn --itempanel --
end

function PersonInfoSkillPanel:getSkillBookNumber()
    -- body
   local ItemProxy = self:getProxy(GameProxys.Item)
   local skillBook = ItemProxy:getItemNumByType(4012)--战法秘籍   
   return skillBook
end

function PersonInfoSkillPanel:registerEvents()
    local downPanel = self:getChildByName("downPanel")
    local Label_85 = downPanel:getChildByName("Label_85")
    local Label_86 = downPanel:getChildByName("Label_86")
    local Label_86L = downPanel:getChildByName("Label_86L")
    local Label_86R = downPanel:getChildByName("Label_86R")
    local Button_83 = downPanel:getChildByName("Button_83")
    local Button_84 = downPanel:getChildByName("Button_84")
    
    local price = GlobalConfig.skillResetPrice
    local skillBook = self:getSkillBookNumber()
    -- Label_85:setString(string.format(self:getTextWord(508),price))
    Label_85:setString(tostring(price))
    -- Label_86:setString(string.format(self:getTextWord(517),skillBook))
    Label_86:setString(tostring(skillBook))
    
    local posx = Label_86:getPositionX()
    local size = Label_86:getContentSize()
    local x1 = posx - size.width/2
    local x2 = posx + size.width/2
    Label_86L:setPositionX(x1)
    Label_86R:setPositionX(x2)



    Button_83.index = 2
    Button_83.price = price
    self:addTouchEventListener(Button_83,self.onTouchResetBtn)
    self:addTouchEventListener(Button_84,self.onTouchBuyBtn)
end

function PersonInfoSkillPanel:onUpdateSkillBook()
    local downPanel = self:getChildByName("downPanel")
    local Label_86 = downPanel:getChildByName("Label_86")    
    local Label_86L = downPanel:getChildByName("Label_86L")
    local Label_86R = downPanel:getChildByName("Label_86R")
    local skillBook = self:getSkillBookNumber()
    -- Label_86:setString(string.format(self:getTextWord(517),skillBook))
    Label_86:setString(tostring(skillBook))
    
    local posx = Label_86:getPositionX()
    local size = Label_86:getContentSize()
    local x1 = posx - size.width/2
    local x2 = posx + size.width/2
    Label_86L:setPositionX(x1)
    Label_86R:setPositionX(x2)
end

function PersonInfoSkillPanel:onTouchUpBtn(sender)
    -- body
    local needbook = sender.needbook
    local skillBook = self:getSkillBookNumber()

    if needbook == nil or skillBook == nil then
        return
    end

    if skillBook < needbook then
        sender.price = (needbook - skillBook) * 9
        self:skillUpMessageBox(sender, 1)
    else
        self:onSendSkillMsg(sender, 0)
    end

end

function PersonInfoSkillPanel:onSendSkillMsg(sender, type)
    -- body
        sender.type = type
        sender.index = 0
        self.view:onSendSkill(sender)
        self._skillProxy:setSelectedSkillID(sender.ID)
end

--  战法秘籍不足 对话框
function PersonInfoSkillPanel:skillUpMessageBox(sender, type)
    -- body
    local function okCallBack()

        local function callFunc()
            self:onSendSkillMsg(sender, type)
        end
        sender.callFunc = callFunc
        sender.money = sender.price
        self:isShowRechargeUI(sender)
    end

    local function cancelCallBack()
    end
    local content = string.format(self:getTextWord(546),sender.price)
    self:showMessageBox(content,okCallBack,cancelCallBack,self:getTextWord(100),self:getTextWord(101))
end

-- 是否弹窗元宝不足
function PersonInfoSkillPanel:isShowRechargeUI(sender)
    -- body
    local needMoney = sender.money

    -- local roleProxy = self:getProxy(GameProxys.Role)
    local haveGold = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝

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

function PersonInfoSkillPanel:onTouchResetBtn(sender)
    -- body
    -- sender.index = 1
    -- self.view:onSendSkill(sender)
    self:ResetMessageBox(sender)
end

--  重置技能 对话框
function PersonInfoSkillPanel:ResetMessageBox(sender)
    -- body
    local function okCallBack()
        local function callFunc()
            sender.index = 1
            self.view:onSendSkill(sender)
        end
        sender.callFunc = callFunc
        sender.money = sender.price
        self:isShowRechargeUI(sender)
    end
    local function cancelCallBack()
    end
    local content = string.format(self:getTextWord(536),sender.price)
    self:showMessageBox(content,okCallBack,cancelCallBack,self:getTextWord(100),self:getTextWord(101))
end

-- 购买战法秘籍 跳转到商店
function PersonInfoSkillPanel:onTouchBuyBtn(sender)    
    ModuleJumpManager:jump(ModuleName.ShopModule,"ShopGrowUpPanel")
end

function PersonInfoSkillPanel:onSkillListResp(data)
    -- body
    self._skillInfos = self._skillProxy:getSkillListData()
end

function PersonInfoSkillPanel:onGetSkillLv(skillId)
    -- body
    for k,v in pairs(self._skillInfos) do
        if v.skillId == skillId then
            return v.level
        end
    end
    return 0
end

function PersonInfoSkillPanel:onGetSkillInfo(skillId)
    -- body
    for k,v in pairs(self._skillInfos) do
        if v.skillId == skillId then
            return v
        end
    end
    return 0
end

function PersonInfoSkillPanel:onSetSkillInfo(skillId,info)
    -- body
    for k,v in pairs(self._skillInfos) do
        if v.skillId == skillId then
            self._skillInfos[k] = info
            return
        end
    end
end


function PersonInfoSkillPanel:onRenderOneItem(data,itempanel)
    -- body
    local itemBtn = itempanel:getChildByName("itemBtn")
    local upBtn = itemBtn:getChildByName("upBtn")
    local Label_name = itemBtn:getChildByName("Label_name")
    local labLv = itemBtn:getChildByName("labLv")
    local tipBtn = itemBtn:getChildByName("tipBtn")
    local level_string = string.format(self:getTextWord(529),data.level)

    local conf = self._skillConf[data.skillId]
    Label_name:setString(conf.name.." ")
    labLv:setString(level_string)
    NodeUtils:alignNodeL2R(Label_name,labLv,tipBtn)

    -- local roleProxy = self:getProxy(GameProxys.Role)
    local playerLevel = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    local skillBook = self:getSkillBookNumber()
    -- local conf = ConfigDataManager:getInfoFindByOneKey(self._SkillLvConfig,"skilllevel",data.level)
    local conf = _SkillLvConf[data.level+1]
    
    local itemneed = StringUtils:jsonDecode(conf.itemneed)

    upBtn:setTitleText(self:getTextWord(580))
    if playerLevel < conf.captainlv then
        NodeUtils:setEnable(upBtn,false)
    else
        NodeUtils:setEnable(upBtn,true)
        upBtn.needbook = itemneed[2]
        self:addTouchEventListener(upBtn,self.onTouchUpBtn)
    end 

    if _SkillLvConf[data.level+2] == nil then --满级了
        NodeUtils:setEnable(upBtn,false)
        upBtn:setTitleText(self:getTextWord(581))
    end
end

function PersonInfoSkillPanel:onUpdateOneItem(data)
    -- body
    local info = data
    for k,v in pairs(self._listview) do
        if k == info.skillId then
            self:onSetSkillInfo(k,info)
            self:onRenderOneItem(info,v)
            return
        end
    end
end

-- 升级成功飘字
function PersonInfoSkillPanel:onSkillUpResp(data)
    -- body
    local info,conf = self._skillProxy:getSkillUpData()
    local senderID = self._skillProxy:getSelectedSkillID()

    if info.skillId == senderID then
        for k,v in pairs(self._listview) do
            if k == info.skillId then
                self:onRenderOneItem(info,v)
                self:showUpAction(v)
                break
            end
        end        
    end    
    self:showSysMessage(string.format(self:getTextWord(542), conf.name))
end

-- icon播放升级特效
function PersonInfoSkillPanel:showUpAction( itempanel )
    -- body
    local iconEffect = itempanel.iconEffect
    if iconEffect ~= nil then
        iconEffect:finalize()
    end
    
    local itemBtn = itempanel:getChildByName("itemBtn")
    local iconImg = itemBtn:getChildByName("iconImg")
    iconEffect = UICCBLayer.new("rpg-button", iconImg)
    local size = iconImg:getContentSize()
    iconEffect:setPosition(size.width/2, size.height/2)
    itempanel.iconEffect = iconEffect
end

function PersonInfoSkillPanel:onUpdateResetAll(data)
    -- body
    local info = data
    for k,v in pairs(self._listview) do
        self:onRenderOneItem(info[k],v)
    end
end

function PersonInfoSkillPanel:onSkillResetResp(data)
    -- body
    self:showSysMessage(self:getTextWord(543))
    self._skillInfos = self._skillProxy:getSkillListData()
    self:onUpdateResetAll(self._skillInfos)
end

function PersonInfoSkillPanel:onUpdateSkillInfo()
    -- body
    self:onUpdateSkillBook()

    --//null 很难受的代码 我也没办法
    local skillProxy = self:getProxy(GameProxys.Skill)
    skillProxy:isLevelUpSkill()
end

function PersonInfoSkillPanel:onTouchTipBtn(sender)
    -- body
    self:onTipContent(sender.info)
end

-- 技能tip
function PersonInfoSkillPanel:onTipContent(info)
    -- body
    -- local roleProxy = self:getProxy(GameProxys.Role)
    local playerLevel = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    local skillBook = self:getSkillBookNumber()
    local skillInfo = self:onGetSkillInfo(info.ID)
    -- local conf,lastData = ConfigDataManager:getInfoFindByOneKey2(self._SkillLvConfig,"skilllevel",skillInfo.level)
    local conf = _SkillLvConf[skillInfo.level+1]
    local lastData = _SkillLvConf[#_SkillLvConf]

    
    if skillInfo.level < lastData.skilllevel then 
        local itemneed = StringUtils:jsonDecode(conf.itemneed)
        local content1 = string.format(self:getTextWord(50100), skillInfo.level)
        local content2 = info.desc
        local content3 = self:getTextWord(50102)
        local content4 = string.format(self:getTextWord(50103),conf.captainlv)
        local content5 = string.format(self:getTextWord(50104),itemneed[2])

        local parent = self:getParent()
        local uiTip = UITip.new(parent)
        local line1 = {{content = info.name, foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.White}, {content = content1, foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.BiaoTi}}
        local line2 = {{content = content2, foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.MiaoShu}}
        local line3 = {{content = content3, foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.FuBiaoTi}}

        local color1 = nil
        local color2 = nil
        if playerLevel < conf.captainlv then
            color1 = ColorUtils.commonColor.Red
        else
            color1 = ColorUtils.commonColor.Green
        end
        if skillBook < itemneed[2] then
            color2 = ColorUtils.commonColor.Red
        else
            color2 = ColorUtils.commonColor.Green
        end

        local line4 = {{content = content4, foneSize = ColorUtils.tipSize16, color = color1}}
        local line5 = {{content = content5, foneSize = ColorUtils.tipSize16, color = color2}}

        local lines = {}
        table.insert(lines, line1)
        table.insert(lines, line2)
        table.insert(lines, line3)      
        table.insert(lines, line4)      
        table.insert(lines, line5)      
        uiTip:setAllTipLine(lines)  

    else
        -- 技能满级tip
        local content1 = self:getTextWord(50101)
        local parent = self:getParent()
        local uiTip = UITip.new(parent)
        local line1 = {{content = content1, foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.FuBiaoTi}}
        local lines = {}
        table.insert(lines, line1)
        uiTip:setAllTipLine(lines)  
    end

end