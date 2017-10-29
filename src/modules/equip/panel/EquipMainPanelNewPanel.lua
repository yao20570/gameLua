
EquipMainPanelNewPanel = class("EquipMainPanelNewPanel", BasicPanel)
EquipMainPanelNewPanel.NAME = "EquipMainPanelNewPanel"
--require("modules.equip.panel.SimplePageView")
function EquipMainPanelNewPanel:ctor(view, panelName)
    EquipMainPanelNewPanel.super.ctor(self, view, panelName, true)
    self._equipProxy = self:getProxy(GameProxys.Equip)
    self._curentPageIndex = 1 --当前页
    self._posMap = {} --6个位置是否解锁
end

function EquipMainPanelNewPanel:finalize()
    EquipMainPanelNewPanel.super.finalize(self)
end

function EquipMainPanelNewPanel:initPanel()
    EquipMainPanelNewPanel.super.initPanel(self)
    self:setTitle(true,1,true)
    local topPanel = self:getChildByName("topPanel")
    self:setNewbgImg({Widget = topPanel})
    self.EquipInfo = self:getChildByName("equipInfoPanel")
    self.btnOneKey = self:getChildByName("topPanel/btnOneKey")
    self["yijianBtn"] = self.btnOneKey  --新手引导
    -- 升级
    self.lvUpImg = self:getChildByName("topPanel/infosPanel/btnsImg/lvUpImg")
    -- 武魂
    self.wuhunImg = self:getChildByName("topPanel/infosPanel/btnsImg/wuhunImg")
    TextureManager:updateButtonNormal(self.wuhunImg, "images/equip/RoleMid.png")
    self.wuhunImg:loadTexturePressed("images/equip/RoleMid.png", ccui.TextureResType.plistType)
    --换将
    self.changeImg = self:getChildByName("topPanel/infosPanel/btnsImg/changeImg")
    self.maskBgPanel = self:getChildByName("maskBgPanel")
    self.taozhuangPanel = self:getChildByName("taozhuangPanel")
	self.letfBtn = self:getChildByName("topPanel/letfBtn")
	self.rightBtn = self:getChildByName("topPanel/rightBtn")

    self.closeBtn = self:getChildByName("equipInfoPanel/closeBtn")
    self.changeBtn = self:getChildByName("equipInfoPanel/changeBtn")
    self.upBtn = self:getChildByName("equipInfoPanel/upBtn")
    self["upBtn"] = self.upBtn

    self.taozhuangImg = self:getChildByName("topPanel/page/taozhuangImg")
    self.tochpanel = self:getChildByName("topPanel/page/maskPanel")
    local img12 = self:getChildByName("topPanel/page/img12")
    self["pos12"] = img12

    self.layer = self:getChildByName("topPanel/page/touchPanel")
end

function EquipMainPanelNewPanel:registerEvents()
    EquipMainPanelNewPanel.super.registerEvents(self)
    self:addTouchEventListener(self.btnOneKey,self.onOneKeyTouch)
    self:addTouchEventListener(self.taozhuangPanel,self.onTaozhuangTouch)
    self:addTouchEventListener(self.letfBtn,self.leftBtnTouch)
    self:addTouchEventListener(self.rightBtn,self.rightBtnTouch)
    self:addTouchEventListener(self.closeBtn, self.onCloseEquipInfoTouch)
    self:addTouchEventListener(self.upBtn, self.onUpEquipHandle)
    self:addTouchEventListener(self.changeBtn,self.onGotoChangeHandle)

    self:addTouchEventListener(self.wuhunImg, self.openSoulModule)
    self:addTouchEventListener(self.lvUpImg, self.showEquipHeroUpPanel)
    self:addTouchEventListener(self.changeImg, self.onChangeImgTouch)
    
    self:addTouchEventListener(self.taozhuangImg,self.onTaozhuangTouch)
    local numbers = {12,6,4,7,5,11}
    for _, v in pairs(numbers) do
        local item = self:getChildByName("topPanel/page/img"..v)
        self:addTouchEventListener(item,self.itemTouch)
    end
end

function EquipMainPanelNewPanel:onShowHandler(index)
    self:setOpenPosBylevel()--设置是否开启
    self._curentPageIndex = index or self._curentPageIndex --设置初始页 
    self:updateInfosByPos(index) --刷新界面
    TimerManager:addOnce(30, self.addEventTochLayer, self)
end

--更换装备
function EquipMainPanelNewPanel:onGotoChangeHandle(sender)
    self:onCloseEquipInfoTouch()
    local panel = self:getPanel(EquipSelectPanel.NAME)
    panel:show(nil,self.NAME)
    panel:updateTopInfo(sender.data,self._curentPageIndex)
    panel:updateListData(sender.attr,self._curentPageIndex)
end

--升级装备
function EquipMainPanelNewPanel:onUpEquipHandle(sender)
    self:onCloseEquipInfoTouch()
    local panel = self:getPanel(EquipUpNewPanel.NAME)
    panel:show(nil,self.NAME)
    panel:onOpenUpPanel(sender.id)
end

--关闭按钮
function EquipMainPanelNewPanel:onClosePanelHandler()
    self:removeEventTouchLayer()
    EquipMainPanelNewPanel.super.onClosePanelHandler(self)
    self:hide()
end

function EquipMainPanelNewPanel:onCloseEquipInfoTouch()
	self.EquipInfo:setVisible(false)
	self.maskBgPanel:setVisible(false)
end

function EquipMainPanelNewPanel:leftBtnTouch()
    self._curentPageIndex = self._curentPageIndex - 1
    if self._curentPageIndex == 0 then
        self._curentPageIndex = 6
    end
    --self:updateInfosByPos(self._curentPageIndex)
    self:runAction()
end

function EquipMainPanelNewPanel:rightBtnTouch()
    self._curentPageIndex = self._curentPageIndex + 1
    if self._curentPageIndex == 7 then
        self._curentPageIndex = 1
    end
    --self:updateInfosByPos(self._curentPageIndex)
    self:runAction()
end

function EquipMainPanelNewPanel:runAction()
    local numbers = {12,6,4,7,5,11}
    for _, v in pairs(numbers) do
        local person = self:getChildByName("topPanel/page/img"..v.."/person")
        person:stopAllActions()
        person:setScale(1.0)
        person:setOpacity(255)
        local action1 = cc.FadeTo:create(GameConfig.Equip.EquipFadeTime1, 0)
        local temp = cc.ScaleTo:create(GameConfig.Equip.EquipFadeTime1,GameConfig.Equip.EquipScale)
        action1 = cc.Spawn:create(action1,temp)
        
        temp = cc.ScaleTo:create(GameConfig.Equip.EquipFadeTime2, 1)
        local action2 = cc.FadeTo:create(GameConfig.Equip.EquipFadeTime2, 255)
        action2 = cc.Spawn:create(action2,temp)
        local action = cc.Sequence:create(action1, action2)
        person:runAction(action)
    end
    local function callback()
        self:updateInfosByPos(self._curentPageIndex)
    end    
    local heroImg = self:getChildByName("topPanel/page/heroImg")
    heroImg:stopAllActions()
    heroImg:setScale(1.0)
    heroImg:setOpacity(255)
    local action1 = cc.FadeTo:create(GameConfig.Equip.RoleFadeTime1, 0)
    local temp = cc.ScaleTo:create(GameConfig.Equip.RoleFadeTime1,GameConfig.Equip.RoleScale)
    action1 = cc.Spawn:create(action1,temp)

    action1 = cc.Sequence:create(action1, cc.CallFunc:create(callback))
    local action2 = cc.FadeTo:create(GameConfig.Equip.RoleFadeTime2, 255)
    temp = cc.ScaleTo:create(GameConfig.Equip.RoleFadeTime2, 1)
    action2 = cc.Spawn:create(action2,temp)
    local action = cc.Sequence:create(action1, action2)    
    local nameImgAction = action:clone()
    heroImg:runAction(action)
    local nameImg = self:getChildByName("topPanel/page/nameImg")
    nameImg:runAction(nameImgAction)
end

function EquipMainPanelNewPanel:updateInfosByPos(pos)
    local pos = pos or self._curentPageIndex
    self:setTitle(true,pos,true)
    self:setInfos(pos)
    self:setEquipPage(pos)
end

--------设置属性--------------
function EquipMainPanelNewPanel:setInfos(pos)
    
    local info = self._equipProxy:getGeneralinfoByPos(self._curentPageIndex)
    local otherInfo = nil
    if info then
        local curId = info.generalId
        otherInfo = self._equipProxy:getPlusById(curId)
    else
        print("武将未上阵")
    end

	local topPanel = self:getChildByName("topPanel/infosPanel")
    local value =  self._equipProxy:onGetSixAttrByPos(pos)
    for k,v in pairs(value) do
        local attribute = topPanel:getChildByName("attribute"..k)
        local count = attribute:getChildByName("count")
        local all = nil
        if otherInfo ~= nil and otherInfo[k] ~= nil then 
            all = v*100 --+ otherInfo[k]
        else
            all = v*100
        end
        count:setString("+"..(all).."%")
    end
end

---------设置武将-------------
function EquipMainPanelNewPanel:setEquipPage(pos)
    local nameLab = self:getChildByName("topPanel/page/nameImg/nameLab")
	local lvLab = self:getChildByName("topPanel/page/nameImg/lvLab")
    local name ,lv = self._equipProxy:getNameAndLvByPos(pos)
    nameLab:setString(name)
    lvLab:setString(lv)
    local tabozhuangLab = self:getChildByName("topPanel/page/taozhuangLab")
    local taozhuangTb = self._equipProxy:getTaozhuang(pos)
    tabozhuangLab:setString(taozhuangTb.max.."/6")
    local soldierList = self._equipProxy:getSoldiersByPos(pos)
    local numbers = 
    {
        12,     --攻击
        6,      --暴击
        4,      --命中
        7,      --抗暴
        5,      --闪避
        11,     --生命
    }
    for index, number in pairs(numbers) do
        self:setDefaultEquipByUpproperty(index,number,pos)
    end

    for _, data in pairs(soldierList) do
        self:updateEquipByUpproperty(data)
    end
    local text1Lab = self:getChildByName("topPanel/page/heroImg/text1Lab")
    local LvLab = self:getChildByName("topPanel/page/heroImg/LvLab")
    local text3Lab = self:getChildByName("topPanel/page/heroImg/text3Lab")
    --更新武将角色
    local visible =  not self._posMap[pos]
    text1Lab:setVisible(visible) 
    text3Lab:setVisible(visible)
    local lv = 0
    local troopsStartConfig = ConfigDataManager:getConfigData("TroopsStartConfig")
    for _,v in pairs(troopsStartConfig) do
        if v.troopsID == self._curentPageIndex then
            lv = v.captainLv
        end
    end 
    LvLab:setString(lv.."级")
    LvLab:setVisible(visible) 
    local heroImg = self:getChildByName("topPanel/page/heroImg")
    local url = "images/equip/heroMa.png"
    if visible then
        url = "images/equip/heroLock.png"
    end
    TextureManager:updateImageView(heroImg, url)
end

--获取初始状态下小红点个数
function EquipMainPanelNewPanel:getRedNumByUpproperty(upproperty)
    local homeEquipList = self._equipProxy:getEquipAllHome()
    local index = 0 
    for _, v in pairs(homeEquipList) do
        if v.upproperty == upproperty then
            index = index + 1
        end
    end
    return index
end

--将所有装备格子设置为初始状态
function EquipMainPanelNewPanel:setDefaultEquipByUpproperty(index, upproperty,pos)
    local item = self:getChildByName("topPanel/page/img"..upproperty)
    self:updateMovieChip(item,{})
    item.data = nil
    item.upproperty = upproperty
    local person = item:getChildByName("person")
    local lvLab = person:getChildByName("name")
    lvLab:setVisible(false)
    local title = person:getChildByName("title")
    title:setVisible(false)
    local redDot = person:getChildByName("redDot")
    local numLab = redDot:getChildByName("num")
    local num = self:getRedNumByUpproperty(upproperty)
    numLab:setString(num)
    -- pos已开启和数量大于0 才显示小红点
    redDot:setVisible(num > 0 and self._posMap[pos])
    local url = "images/equip/equiptype"..index..".png"
    TextureManager:updateImageView(person, url)
    url = "images/gui/Frame_character1_none.png"
    item:loadTextureNormal(url,1)--初始化装备框

end

--设置装备格子
function EquipMainPanelNewPanel:updateEquipByUpproperty(data)
    local item = self:getChildByName("topPanel/page/img"..data.upproperty)
    item.data = data
    local person = item:getChildByName("person")
    local lvLab = person:getChildByName("name")
    lvLab:setVisible(true)
    local title = person:getChildByName("title")
    title:setVisible(true)
    local redDot = person:getChildByName("redDot")
    redDot:setVisible(false)
    lvLab:setString(data.level)
    local config = ConfigDataManager:getInfoFindByOneKey("WarriorsConfig","ID",data.typeid)
    local url = "images/general/"..config.icon..".png"
    TextureManager:updateImageView(person, url)
    url = "images/gui/Frame_character"..config.quality.."_none.png"
    item:loadTextureNormal(url,1)
    --ToDo装备加特效
    self:updateMovieChip(item,config)
end

function EquipMainPanelNewPanel:setOpenPosBylevel()
    local roleProxy = self:getProxy(GameProxys.Role)
    local level = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    local troopsStartConfig = ConfigDataManager:getConfigData("TroopsStartConfig")
    for _,v in pairs(troopsStartConfig) do
        if level >= v.captainLv then
            self._posMap[v.troopsID] = true
        end
    end 
end

function EquipMainPanelNewPanel:onOneKeyTouch(sender)
	local name = sender:getName()
	if self._posMap[self._curentPageIndex] then
    	local data = {}
		data.type = 2
		data.position = self._curentPageIndex
		self:dispatchEvent(EquipEvent.WEAR_EQUIP_REQ,data)
	else
		local lv = 0
		local troopsStartConfig = ConfigDataManager:getConfigData("TroopsStartConfig")
		for _,v in pairs(troopsStartConfig) do
			if v.troopsID == self._curentPageIndex then
				lv = v.captainLv
			end
		end
		self:showSysMessage(string.format("%d号将将领,角色等级%d开放！",self._curentPageIndex,lv))
	end
end
-- old特效
function EquipMainPanelNewPanel:updateMovieChip(parent,config)
    if config.effectbigframe ~= nil then
        if parent.movieChip ~= nil then
            if parent.effectbigframe ~= config.effectbigframe then
                parent.movieChip:finalize()
                local movieChip = UIMovieClip.new(config.effectbigframe)
                movieChip:setParent(parent)
                movieChip:setNodeAnchorPoint(cc.p(0.06, 0.1))
                movieChip:setScale(1.0)
                parent.movieChip = movieChip
                parent.effectbigframe = config.effectbigframe
            end
            	parent.movieChip:play(true)
        else
            local movieChip = UIMovieClip.new(config.effectbigframe)
            movieChip:setParent(parent)
            movieChip:setNodeAnchorPoint(0.06, 0.1)
            movieChip:play(true)
            movieChip:setScale(1.0)
            parent.movieChip = movieChip
            parent.effectbigframe = config.effectbigframe
        end
    else
        if parent.movieChip ~= nil then
            parent.movieChip:finalize()
            parent.movieChip = nil
            parent.effectbigframe = nil
        end 
    end
end

function EquipMainPanelNewPanel:onTaozhuangTouch(sender)
    local taozhuangPanel = self:getChildByName("taozhuangPanel")
    if taozhuangPanel == sender then
        taozhuangPanel:setVisible(false)
    else
        taozhuangPanel:setVisible(true)
        local taozhuangTb = self._equipProxy:getTaozhuang(self._curentPageIndex)
        local title = taozhuangPanel:getChildByName("title")
        title:setString("无")
        local tb = {"龙鳞套","麒麟套","凤舞套"}
        for i = 1, 3 do
            local lab = taozhuangPanel:getChildByName("count"..i)
            lab:setString("("..taozhuangTb[i].."/6)")
            if taozhuangTb[i] == 6 then
                title:setString(tb[i])
            end
        end
    end
end

function EquipMainPanelNewPanel:itemTouch(sender)
    if sender.data == nil then
        local panel = self:getPanel(EquipSelectPanel.NAME)
        panel:show(nil,self.NAME)
        panel:updateTopInfo(nil,self._curentPageIndex)
        panel:updateListData(sender.upproperty,self._curentPageIndex)
    else
        self.EquipInfo:setVisible(true)
        self.maskBgPanel:setVisible(true)
        self:updateEquipInfo(sender.data)
        self.changeBtn.data = sender.data
        self.changeBtn.attr = sender.upproperty
        self.upBtn.id = sender.data.id
    end
end

function EquipMainPanelNewPanel:showEquipHeroUpPanel()

    local info = self._equipProxy:getGeneralinfoByPos(self._curentPageIndex)
    if info then
        local panel = self:getPanel(EquipHeroUpPanel.NAME)
        panel:show(self._curentPageIndex)
    else
        self:showSysMessage("请上阵武将！")
    end
end

function EquipMainPanelNewPanel:onChangeImgTouch()
    local panel = self:getPanel(EquipHeroGenghuanPanel.NAME)
    panel:show(self._curentPageIndex,self.NAME)
end

-- 武将弹框信息
function EquipMainPanelNewPanel:updateEquipInfo(data)
    local name_0 = self.EquipInfo:getChildByName("name_0")      --装备名称等级
    local shuxing = self.EquipInfo:getChildByName("Label_51")   --属性名
    local plus = self.EquipInfo:getChildByName("plus")          --属性值
    local info = self.EquipInfo:getChildByName("info")          --装备描述
    local person = self.EquipInfo:getChildByName("person")      --装备图
    local img4_0 = self.EquipInfo:getChildByName("img4_0")      --装备框

    local config = ConfigDataManager:getInfoFindByOneKey("WarriorsConfig","ID",data.typeid)
    local config1 = ConfigDataManager:getInfoFindByTwoKey("WarriorProConfig","lv",data.level,"quality",data.quality)
    name_0:setString(config.name.." Lv."..data.level)
    name_0:setColor(ColorUtils:getColorByQuality(config.quality))
    shuxing:setString(self:getTextWord(720+data.upproperty))
    local value = config1[SoliderPowerDefine.equipAttribute[data.upproperty]] / 100
    value =" +"..value.."%"
    plus:setString(value)
    info:setString(config.info)
    local url = "images/general/"..config.icon..".png"
    TextureManager:updateImageView(person, url)
    self:updateMovieChip(img4_0,config)
    url = "images/gui/Frame_character"..config.quality.."_none.png"
    TextureManager:updateImageView(img4_0, url)
end

--创建触摸
function EquipMainPanelNewPanel:addEventTochLayer()
    local x = 0
    self.layer:setVisible(true)
    if self.listenner then
        self:removeEventTouchLayer()
    end
    self.listenner = cc.EventListenerTouchOneByOne:create()
    self.listenner:setSwallowTouches(false)
    self.listenner:registerScriptHandler(function(touch, event)    
    local location = touch:getLocation()   
    x = location.x
    return true    
    end, cc.Handler.EVENT_TOUCH_BEGAN )  
    self.listenner:registerScriptHandler(function(touch, event)    
    local location = touch:getLocation() 
    if location.x - x > 30 then
        -- print("leftBtnTouch")
        self:leftBtnTouch()
    elseif location.x - x < -30 then
        -- print("rightBtnTouch")
        self:rightBtnTouch()
    end
    end, cc.Handler.EVENT_TOUCH_ENDED ) 
    local eventDispatcher = self.layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.listenner, self.layer)
end
--移除触摸
function EquipMainPanelNewPanel:removeEventTouchLayer()
    local eventDispatcher = self.layer:getEventDispatcher()
    eventDispatcher:removeEventListenersForTarget(self.layer)
    self.listenner = nil
end

function EquipMainPanelNewPanel:openSoulModule(sender)
    self:removeEventTouchLayer()
    self._equipProxy:setCurrentPos(self._curentPageIndex)
    local isOpen = self._equipProxy:getGeneralinfoByPos(self._curentPageIndex)
    if not isOpen then
        self:showSysMessage("武将未上阵")
        return
    end
    self:dispatchEvent(EquipEvent.SHOW_OTHER_EVENT, ModuleName.EquipSoulModule)
end