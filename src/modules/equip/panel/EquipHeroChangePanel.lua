
EquipHeroChangePanel = class("EquipHeroChangePanel", BasicPanel)
EquipHeroChangePanel.NAME = "EquipHeroChangePanel"

function EquipHeroChangePanel:ctor(view, panelName)
    EquipHeroChangePanel.super.ctor(self, view, panelName,true)
    self._posMap = {}
end

function EquipHeroChangePanel:finalize()
    EquipHeroChangePanel.super.finalize(self)
end

function EquipHeroChangePanel:initPanel()
	EquipHeroChangePanel.super.initPanel(self)
	self:setTitle(true,"zhihuiwujiang",true)
	self.nilPanel = self:getChildByName("nilPanel")
	local mainPanel = self:getChildByName("mainPanel")
    self:setNewbgImg({Widget = mainPanel})
	self:initSixPanel()

    self.equipImg = self:getChildByName("mainPanel/equipImg")
    self.tujianImg = self:getChildByName("mainPanel/tujianImg")
    self.table = {1,2,3,4,5,6}

end

function EquipHeroChangePanel:registerEvents()
	EquipHeroChangePanel.super.registerEvents(self)
    self:addTouchEventListener(self.equipImg,self.onEquipImgTouch)
    self:addTouchEventListener(self.tujianImg,self.onTujianImgTouch)
end

function EquipHeroChangePanel:onClosePanelHandler()
	self:dispatchEvent(EquipEvent.HIDE_SELF_EVENT)
end

function EquipHeroChangePanel:onShowHandler()
    local equipProxy = self:getProxy(GameProxys.Equip)
    local attrs =  equipProxy:onGetSixAttrByPos(1)
    if attrs == nil then
        return  --还未获取到数据
    end

    self:updateRedPoint()
    self:updatePanelInfo()
end

function EquipHeroChangePanel:updateRedPoint()
    local redDot = self:getChildByName("mainPanel/equipImg/redDot")
    local numLab = redDot:getChildByName("num")
    local equipProxy = self:getProxy(GameProxys.Equip)
    local num = #equipProxy:getEquipAllHome()
    redDot:setVisible(num > 0)
    numLab:setString(num)
end

function EquipHeroChangePanel:onEquipImgTouch()
    local panel = self:getPanel(EquipAddPanel.NAME)
    panel:show(nil,self.NAME)
end

function EquipHeroChangePanel:onTujianImgTouch()
    self:dispatchEvent(EquipEvent.SHOW_OTHER_EVENT, ModuleName.EquipImgModule)
end

function EquipHeroChangePanel:initSixPanel()
    local function callback1(pos)
    	return self:getOpenPos(pos)
    end
    local function callback2(iteam) 
        --还原为初始状态
        local url = "images/equip/kapaiBg.png"
        iteam:setBackGroundImage(url,1)
        iteam:setScale(1)
    	local panel = self:getPanel(EquipMainPanelNewPanel.NAME)
    	panel:show(iteam.pos,self.NAME)
    end
    local function callback3(iteam)
    	--print(iteam.pos,"item")
        local url = "images/equip/kapaiBg.png"
        iteam:setBackGroundImage(url,1)
    	self:seqNetChange(iteam.pos)
    	self:change(iteam)
    end
    local function callback4(iteam, type)
        local url
        if type == 1 then 
            url = "images/equip/kapaiBg.png"
        elseif type == 2 then
            url = "images/equip/kapaiChooseBg.png"
        end
        --TextureManager:updateImageView(iteam,url)
        iteam:setBackGroundImage(url,1)
    end
    local mainPanel = self:getChildByName("mainPanel")
    for index = 1, 6 do
    	local iteam = self:getChildByName("mainPanel/itemPanels/itempanel"..index)
    	iteam.pos = index
    	local args = {}
        args["callback1"] = callback1
        args["callback2"] = callback2
        args["callback3"] = callback3
        args["callback4"] = callback4
        local HeroChangeUI = require("modules.equip.panel.HeroChangeUI")
        HeroChangeUI.new(iteam,args)
    end
end

function EquipHeroChangePanel:change(iteam)
	local infoPanel = iteam:getChildByName("infoPanel")
	local indexImg = infoPanel:getChildByName("indexImg")
    local url = "images/equip/num"..iteam.pos..".png"
    TextureManager:updateImageView(indexImg, url)
    -- local lvNamePanel = iteam:getChildByName("lvNamePanel")
    -- local nameLab = lvNamePanel:getChildByName("nameLab")
    -- local lvLab = lvNamePanel:getChildByName("lvLab")
    -- --nameLab:setString(self.tb[iteam.pos])
    -- local equipProxy = self:getProxy(GameProxys.Equip)
    -- local name,lv = equipProxy:getNameAndLvByPos(iteam.pos)
    -- nameLab:setString(name)
    -- lvLab:setString(lv)
end

function EquipHeroChangePanel:seqNetChange(pos)
	if self.pos1 == nil then
		self.pos1 = pos
	else
        self.table[pos], self.table[self.pos1]  = self.table[self.pos1],self.table[pos]
		self:dispatchEvent(EquipEvent.POS_EXCHANGE_REQ,{posione = self.pos1, positwo = pos})	
		self.pos1 = nil
	end
end

function EquipHeroChangePanel:getOpenPos(pos)
	local roleProxy = self:getProxy(GameProxys.Role)
	local level = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
	local troopsStartConfig = ConfigDataManager:getConfigData("TroopsStartConfig")
    local lv
	for _,v in pairs(troopsStartConfig) do
        self._posMap[v.troopsID] = false
        if level >= v.captainLv then
            self._posMap[v.troopsID] = true
        end
        if v.troopsID == pos then
            lv = v.captainLv
        end
    end	
    return self._posMap[pos], lv
end

function EquipHeroChangePanel:updatePanelInfo()
    for index = 1, 6 do
        local i = self.table[index]
        local lockPanel = self:getChildByName("mainPanel/itemPanels/itempanel"..i.."/lockPanel")
        local visible,lv = self:getOpenPos(i)
        lockPanel:setVisible(not visible)
        local str = "主公"..lv.."级开启"
        local lockLvLab = lockPanel:getChildByName("lockLvLab")
        lockLvLab:setString(str)
        local infoLab1 = self:getChildByName("mainPanel/itemPanels/itempanel"..i.."/infoPanel/infoLab1")
        local valueLab1 = self:getChildByName("mainPanel/itemPanels/itempanel"..i.."/infoPanel/valueLab1")
        local infoLab2 = self:getChildByName("mainPanel/itemPanels/itempanel"..i.."/infoPanel/infoLab2")
        local valueLab2 = self:getChildByName("mainPanel/itemPanels/itempanel"..i.."/infoPanel/valueLab2")
        local data = self:getinfosTb(index)   

        local value = (data[1].value)*100
        infoLab1:setString(self:getTextWord(720 + data[1].key))
        valueLab1:setString(value.."%")
        infoLab2:setString(self:getTextWord(720 + data[2].key))
        value = (data[2].value)*100
        valueLab2:setString(value.."%")


        local equipProxy = self:getProxy(GameProxys.Equip)
        local name,lv = equipProxy:getNameAndLvByPos(index)
        local nameLab = self:getChildByName("mainPanel/itemPanels/itempanel"..i.."/lvNamePanel/nameLab")
        local lvLab = self:getChildByName("mainPanel/itemPanels/itempanel"..i.."/lvNamePanel/lvLab")
        nameLab:setString(name)
        lvLab:setString(lv)
    end
end

function EquipHeroChangePanel:getinfosTb(index)
    local equipProxy = self:getProxy(GameProxys.Equip)
    local tmpData = {}
    local attrs =  equipProxy:onGetSixAttrByPos(index)
    tmpData[1] = {key = 12,value = attrs[12]}            
    tmpData[2] = {key = 11,value = attrs[11]}            
    tmpData[3] = {key = 4,value = attrs[4]}            
    tmpData[4] = {key = 5,value = attrs[5]}            
    tmpData[5] = {key = 6,value = attrs[6]}            
    tmpData[6] = {key = 7,value = attrs[7]}            
    table.sort(tmpData, function (a,b)
            return a.value > b.value
    end)
    return tmpData
end

