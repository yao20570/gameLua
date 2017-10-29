
EquipHeroUpPanel = class("EquipHeroUpPanel", BasicPanel)
EquipHeroUpPanel.NAME = "EquipHeroUpPanel"

function EquipHeroUpPanel:ctor(view, panelName)
    EquipHeroUpPanel.super.ctor(self, view, panelName,600)
    self._proxy = self:getProxy(GameProxys.Equip)
   	self.GeneralsConfig = require("excelConfig.GeneralsConfig")
   	self.ItemConfig = require("excelConfig.ItemConfig")
   	self.GeneralsExpConfig = require("excelConfig.GeneralsExpConfig")
   	self.uiicon = {}
end

function EquipHeroUpPanel:finalize()
    EquipHeroUpPanel.super.finalize(self)
end

function EquipHeroUpPanel:initPanel()
	EquipHeroUpPanel.super.initPanel(self)
	self:setTitle(true,"武将升级")
end

function EquipHeroUpPanel:registerEvents()
	EquipHeroUpPanel.super.registerEvents(self)
end

function EquipHeroUpPanel:onShowHandler(pos)
	self._pos = pos or self._pos
	self:updateView(pos)
end

function EquipHeroUpPanel:onHideHandler()
	TimerManager:remove(self.updateBar, self)
	self.loadingBar:stopAllActions()
	local panel = self:getPanel(EquipMainPanelNewPanel.NAME)
    panel:show()
	EquipHeroUpPanel.super.onClosePanelHandler(self)
end

function EquipHeroUpPanel:updateView(pos)
	self:updateTops(pos)
	self:updateNums()
end

function EquipHeroUpPanel:updateTops(pos)
-------左边各控件
	local HeroCardImg = self:getChildByName("mainPanel/topPanel/HeroCardImg") --品质匡
	local roleImg = self:getChildByName("mainPanel/topPanel/HeroCardImg/roleImg") --武将图片
	local lvAndNameImg = self:getChildByName("mainPanel/topPanel/HeroCardImg/lvAndNameImg") --名字和等级底图
	local lvLab = self:getChildByName("mainPanel/topPanel/HeroCardImg/lvAndNameImg/lvLab") --等级
	local nameLab = self:getChildByName("mainPanel/topPanel/HeroCardImg/lvAndNameImg/nameLab") --名字
	local info = self._proxy:getGeneralinfoByPos(self._pos)
	local quality = self.GeneralsConfig[info.generalId].color
	local url = "images/equip/wujiangBg"..quality..".png"
	TextureManager:updateImageView(HeroCardImg, url)
	url = "images/equip/tiao"..quality..".png"
	TextureManager:updateImageView(lvAndNameImg, url)
	local name = self.GeneralsConfig[info.generalId].name
	nameLab:setString(name)
-------右边各控件
	local nameLVLab = self:getChildByName("mainPanel/topPanel/infoPanel/nameLVLab") --名字和等级
	nameLVLab:setColor(ColorUtils:getColorByQuality(quality))
	local loadingBar = self:getChildByName("mainPanel/topPanel/infoPanel/loadingBar") --进度条
	local loadingLab = self:getChildByName("mainPanel/topPanel/infoPanel/loadingLab") --进度文字
	local daibingliangLab = self:getChildByName("mainPanel/topPanel/infoPanel/daibingPanel/daibingliangLab") --带兵量
	local daibingInfoLab = self:getChildByName("mainPanel/topPanel/infoPanel/daibingPanel/daibingInfoLab") --带兵量后面描述
	daibingInfoLab:setString("")
	local qianliLab = self:getChildByName("mainPanel/topPanel/infoPanel/qianliPanel/qianliLab") --剩余潜力数值
	local qianliInfoLab = self:getChildByName("mainPanel/topPanel/infoPanel/qianliPanel/qianliInfoLab") --潜力数值后面描述
	loadingLab:setString(info.exp.."/"..self.GeneralsExpConfig[info.generalLevel].expneed) 
	local function getPotential(info)
		local potential = 0
		if info.generalLevel ~= 1 then
			potential = self.GeneralsExpConfig[info.generalLevel-1].potentialpoint
		end
		for k,v in pairs(info.generalSoul) do
			potential = potential - v.num
		end
		return potential
	end
	local function getFrontLvValue(info)
		local frontLvValue = 0
		if self.GeneralsExpConfig[info.generalLevel-1] then
			frontLvValue = self.GeneralsExpConfig[info.generalLevel-1].potentialpoint
		end
		return frontLvValue
	end
	function setOldData()
		self.oldInfo = info
	end
	function setLastData()
		self.lastInfo = self.oldInfo
		self.currentMaxExp = self.GeneralsExpConfig[self.lastInfo.generalLevel].expneed
	end

	local function setState(info)
		local name = self.GeneralsConfig[info.generalId].name
		nameLVLab:setString(name.." Lv."..info.generalLevel)
		--self.loadingBar:setPercentage(100*info.exp/self.GeneralsExpConfig[info.generalLevel].expneed)
		loadingLab:setString(info.exp.."/"..self.GeneralsExpConfig[info.generalLevel].expneed) 
		self.currentMaxExp = self.GeneralsExpConfig[info.generalLevel].expneed
		daibingliangLab:setString(info.command)
		lvLab:setString(info.generalLevel)
		qianliLab:setString(getPotential(info))
		qianliInfoLab:setString("（下级+"..self.GeneralsExpConfig[info.generalLevel].potentialpoint - getFrontLvValue(info) ..")")
	end
	local function reSetDefault()
		setState(self.oldInfo)
		TimerManager:remove(self.updateBar, self)	
	end
	local function callBack(index)
		local infoCopy = {}
		for k,v in pairs(self.lastInfo) do
			infoCopy[k] = v
		end
		infoCopy.generalLevel =  infoCopy.generalLevel + index
		self:showSysMessage("武将升级成功!")
		setState(infoCopy) 
	end

	if not self.loadingBar then
		local EquipLoadingBar = require("modules.equip.panel.EquipLoadingBar")
		self.loadingBar = EquipLoadingBar.new({loaderBar = loadingBar,url = "images/newGui2/Progress_big.png",reSetDefault = reSetDefault})
	end
	--判断是否满级
	if not self.GeneralsExpConfig[info.generalLevel + 1] then 
		lvLab:setString(info.generalLevel)
		local name = self.GeneralsConfig[info.generalId].name
		nameLVLab:setString(name.." Lv."..info.generalLevel)
		qianliLab:setString(getPotential(info))
		daibingliangLab:setString(info.command)
		qianliInfoLab:setString("已满级")
		loadingLab:setString("已满级")
		loadingBar:setPercent(100)
		return
	end

	if pos then
		self.loadingBar:setPercentage(100*info.exp/self.GeneralsExpConfig[info.generalLevel].expneed)--dt
		setState(info)
		setOldData()
	else
		setLastData()
		TimerManager:remove(self.updateBar, self)
		self.loadingBar:stopAllActions()
		setState(self.oldInfo)
		self.loadingBar:runActions(100*info.exp/self.GeneralsExpConfig[info.generalLevel].expneed ,info.generalLevel -  self.oldInfo.generalLevel, callBack)
		TimerManager:add(60,self.updateBar,self)
		setOldData()
	end
end

function EquipHeroUpPanel:updateBar()
	if self.currentMaxExp then
		local loadingLab = self:getChildByName("mainPanel/topPanel/infoPanel/loadingLab") --进度文字
		local Percent =  self.loadingBar:getCurrentPercent()
		local str = math.floor(Percent * self.currentMaxExp/100).."/"..self.currentMaxExp
		loadingLab:setString(str)
	end
end

function EquipHeroUpPanel:updateNums()
	local danNums = self._proxy:getExpDan()
	for i = 1, 5 do
		local  data = {}
		data.typeid = 3400 + i
		data.num = danNums[i]
		data.power = 401
		local expPanle = self:getChildByName("mainPanel/downPanel/expPanle"..i)
		local touchPanel = self:getChildByName("mainPanel/downPanel/touchPanel"..i)
		if not self.uiicon[i] then
			self.uiicon[i] = UIIcon.new(expPanle,data,true)
			self.uiicon[i]:setPosition(40,80)
			local expLab = expPanle:getChildByName("expLab")
			local str = StringUtils:jsonDecode(self.ItemConfig[3400+i].effect)
			expLab:setString(str[1][1])
			expLab:setColor(ColorUtils:getColorByQuality(self.ItemConfig[3400+i].color))
			touchPanel.index = i
			self:addTouchEventListener(touchPanel,self.onExpPanleTouch)
		else
			self.uiicon[i]:updateData(data)
		end
	end
end

function EquipHeroUpPanel:onExpPanleTouch(sender)
	print(sender.index)
	local danNums = self._proxy:getExpDan()
	if danNums[sender.index] > 0 then
		local info = self._proxy:getGeneralinfoByPos(self._pos)
		if not self.GeneralsExpConfig[info.generalLevel + 1] then 
			self:showSysMessage("武将已满级!")
			return 
		end
		local data = {}
		data.id = info.generalId
		data.useId = 3400 + sender.index
		self:dispatchEvent(EquipEvent.LV_UP_HERO,data)
	else
		self:showSysMessage("当前此经验丹数量不足")
	end
end