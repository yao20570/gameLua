
EquipAddPanel = class("EquipAddPanel", BasicPanel)
EquipAddPanel.NAME = "EquipAddPanel"

function EquipAddPanel:ctor(view, panelName)
    EquipAddPanel.super.ctor(self, view, panelName,true)

end

function EquipAddPanel:finalize()
    EquipAddPanel.super.finalize(self)
end

function EquipAddPanel:initPanel()
	EquipAddPanel.super.initPanel(self)
	self:setTitle(true,"equiphouse",true)
	local downPanel = self:getChildByName("downPanel")
	local mainPanel = self:getChildByName("mainPanel")
    self:setNewbgImg({Widget = mainPanel})
	self.addBtn = self:getChildByName("mainPanel/addBtn")
    self.maskPanel = self:getChildByName("maskPanel")
    self.infoPanel = self:getChildByName("infoPanel")
    self.upBtn = self:getChildByName("infoPanel/upBtn")
    self.changeBtn = self:getChildByName("infoPanel/changeBtn")
    self.closeBtn = self:getChildByName("infoPanel/closeBtn")
end

function EquipAddPanel:onShowHandler()
	self:updateListData()
	self:updateNums()
end

function EquipAddPanel:updateNums(count)
	local roleProxy = self:getProxy(GameProxys.Role)
	count = count or roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_EQUIPCOUNT)
	local maxNumLab = self:getChildByName("mainPanel/numPanel/maxNumLab")
	maxNumLab:setString("/"..count..")")
	local currentNumLab = self:getChildByName("mainPanel/numPanel/currentNumLab")
	local equipProxy = self:getProxy(GameProxys.Equip)
	local data = equipProxy:getEquipAllHome()
	local currentNum = #data or 0
	currentNumLab:setString(currentNum)
end

function EquipAddPanel:registerEvents()
	EquipAddPanel.super.registerEvents(self)
    self:addTouchEventListener(self.addBtn,self.onIncreaseHandle)
    self:addTouchEventListener(self.upBtn,self.onUpBtnTouch)
    self:addTouchEventListener(self.changeBtn,self.onChangeBtnTouch)
	self:addTouchEventListener(self.closeBtn,self.onCloseBtnTouch)
end

function EquipAddPanel:onUpBtnTouch()
    local equipProxy = self:getProxy(GameProxys.Equip)
    local tmpData = equipProxy:getEquipAllHome()
    for k,v in pairs(tmpData) do
        if v.id == self.id and v.upproperty == 0 then
            self:showSysMessage("不能强化经验券!")
            return
        end
    end


    self:onCloseBtnTouch()
    local panel = self:getPanel(EquipUpNewPanel.NAME)
    panel:show(nil,self.NAME)
    panel:onOpenUpPanel(self.id)
end

function EquipAddPanel:onChangeBtnTouch()
    self:onCloseBtnTouch()
    local panel = self:getPanel(EquipMainPanelNewPanel.NAME)
    panel:show(nil,self.NAME)
end

function EquipAddPanel:onCloseBtnTouch()
    self.maskPanel:setVisible(false)
    self.infoPanel:setVisible(false)

end

function EquipAddPanel:onClosePanelHandler()
	EquipAddPanel.super.onClosePanelHandler(self)
    self:hide()
end

function EquipAddPanel:updateListData()
	local data = self:getAddPanelData()
	local listView = self:getChildByName("mainPanel/ListView")
	self:renderListView(listView, data, self, self.renderItem)
end

function EquipAddPanel:renderItem(item,data,index)
    local item1 = item:getChildByName("item1")
    local item2 = item:getChildByName("item2")
    self:updateItemImg(item1,data[1])
    if #data == 1 then
        item2:setVisible(false)
    else
        item2:setVisible(true)
        self:updateItemImg(item2,data[2])    
    end
end

function EquipAddPanel:updateItemImg(node,data)
	local config1 = ConfigDataManager:getInfoFindByOneKey("WarriorsConfig","ID",data.typeid)
    local describleLab = node:getChildByName("describleLab")
    describleLab:setString(config1.massage)
	local name = node:getChildByName("nameLvLab")
	name:setColor(ColorUtils:getColorByQuality(data.quality))
	local equipImg = node:getChildByName("equipImg")
	self:updateMovieChip(equipImg,config1)
	local person = equipImg:getChildByName("person")
	local url = "images/general/"..config1.icon..".png"
    TextureManager:updateImageView(person, url)
    url = "images/gui/Frame_character"..config1.quality.."_none.png"
	TextureManager:updateImageView(equipImg, url)
	local valueLab = node:getChildByName("valueLab")
    local shuxingLab = node:getChildByName("shuxingLab")
	config = ConfigDataManager:getInfoFindByTwoKey("WarriorProConfig","lv",data.level,"quality",data.quality)
    if data.upproperty ~= 0 then
		name:setString(config1.name.." Lv."..data.level)
	    local value = config[SoliderPowerDefine.equipAttribute[data.upproperty]] / 100
	    value = "+"..value.."%"
	    valueLab:setString(value)
	    value = self:getTextWord(720+data.upproperty)
	    shuxingLab:setString(value)
	else
		valueLab:setVisible(false)
		shuxingLab:setVisible(false)
		name:setString(config1.name)
	end

    node.data = data
    self:addTouchEventListener(node,self.showInfo)
end

function EquipAddPanel:showInfo(sender)
    self.infoPanel:setVisible(true)
    self.maskPanel:setVisible(true)
    local data = sender.data
    self.id = data.id
    local config1 = ConfigDataManager:getInfoFindByOneKey("WarriorsConfig","ID",data.typeid)
    local config = ConfigDataManager:getInfoFindByTwoKey("WarriorProConfig","lv",data.level,"quality",data.quality)
    local nameAndLvLab = self:getChildByName("infoPanel/nameAndLvLab")
    local shuxingLab = self:getChildByName("infoPanel/shuxingLab")
    local valueLab = self:getChildByName("infoPanel/valueLab")
    local describleLab = self:getChildByName("infoPanel/describleLab")
    local heroImg = self:getChildByName("infoPanel/heroImg")
    local heroBgImg = self:getChildByName("infoPanel/heroBgImg")
    describleLab:setString(config1.info)
    local url = "images/general/"..config1.icon..".png"
    TextureManager:updateImageView(heroImg, url)
    local visible = false
    nameAndLvLab:setColor(ColorUtils:getColorByQuality(data.quality))
    if data.upproperty ~= 0 then
        nameAndLvLab:setString(config1.name.." Lv."..data.level)
        local value = config[SoliderPowerDefine.equipAttribute[data.upproperty]] / 100
        value = "+"..value.."%"
        valueLab:setString(value)
        value = self:getTextWord(720+data.upproperty)
        shuxingLab:setString(value)
        visible = true
    else
        nameAndLvLab:setString(config1.name)
    end
    self:updateMovieChip(heroBgImg,config1)
    valueLab:setVisible(visible)
    shuxingLab:setVisible(visible)
end

function EquipAddPanel:getAddPanelData()
	local equipProxy = self:getProxy(GameProxys.Equip)
	local tmpData = equipProxy:getEquipAllHome()
	local data = {}
	for i = 1, #tmpData do
		local index = math.floor((i + 1)/2)
		if not data[index] then
			data[index] = {}
			data[index][1] = tmpData[i]
		else 
			data[index][2] = tmpData[i]
		end
	end
	return data
end

-- 元宝扩充将军府仓库
function EquipAddPanel:onIncreaseHandle(sender)
    local function okcallbk()
        local function callFunc()
            self:onIncreaseReq()
        end
        sender.callFunc = callFunc
        sender.money = 50
        self:isShowRechargeUI(sender)
    end
    self:showMessageBox(self:getTextWord(745),okcallbk)
end

function EquipAddPanel:onIncreaseReq()
    self:dispatchEvent(EquipEvent.BIG_HOUSE_REQ)
end


-- 是否弹窗元宝不足
function EquipAddPanel:isShowRechargeUI(sender)
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


function EquipAddPanel:updateMovieChip(parent,config)
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
