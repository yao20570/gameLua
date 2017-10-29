
EquipUpNewPanel = class("EquipUpNewPanel", BasicPanel)
EquipUpNewPanel.NAME = "EquipUpNewPanel"

function EquipUpNewPanel:ctor(view, panelName)
    EquipUpNewPanel.super.ctor(self, view, panelName,true)
    -- local state = self.view:getState()
    -- state:onSubcontractPanel("EquipModule",function () end,13)
    self._equipProxy = self:getProxy(GameProxys.Equip)
end

function EquipUpNewPanel:finalize()
    EquipUpNewPanel.super.finalize(self)
end

function EquipUpNewPanel:updateBar()
	if self.currentMaxExp then
		local lodingValueLab = self:getChildByName("mainPanle/topPanel/lodingBgImg/lodingValueLab")
		local Percent =  self.lodingBar:getCurrentPercent()
		local str = math.floor(Percent * self.currentMaxExp/100).."/"..self.currentMaxExp
		lodingValueLab:setString(str)
		local Percent = Percent/100
		-- self.barEffrct:setPosition(Percent * 300,20)
	end	
end

function EquipUpNewPanel:initPanel()
    self:onSubcontractPanel()
	EquipUpNewPanel.super.initPanel(self)
	self:setTitle(true,"equipup",true)
    local downPanel = self:getChildByName("downPanel")
    local mainPanle = self:getChildByName("mainPanle")
    self:setNewbgImg({Widget = mainPanle})
   	self._upBtn = self:getChildByName("mainPanle/lastPanel/upBtn")
   	self._chooseBtn = self:getChildByName("mainPanle/lastPanel/chooseBtn")

   	self._cancelBtn = self:getChildByName("chooseTypePanel/cancelBtn")
   	self._closeBtn = self:getChildByName("chooseTypePanel/closeBtn")
   	self._submitBtn = self:getChildByName("chooseTypePanel/submitBtn")
   	self._colorTb = {"whiteBtn","greenBtn","blueBtn","violetBtn","orangeBtn","allBtn"}
   	self.typeBtns = {}
   	self.typeBtns[1] = self:getChildByName("chooseTypePanel/whiteBtn")
   	self.typeBtns[2] = self:getChildByName("chooseTypePanel/greenBtn")
   	self.typeBtns[3] = self:getChildByName("chooseTypePanel/blueBtn")
   	self.typeBtns[4] = self:getChildByName("chooseTypePanel/violetBtn")
   	self.typeBtns[5] = self:getChildByName("chooseTypePanel/orangeBtn")
   	self.typeBtns[6] = self:getChildByName("chooseTypePanel/allBtn")

   	--加火特效
   	local movieBG = self:getChildByName("mainPanle/topPanel") 
   	local fireEffect = UIMovieClip.new("rpg-small-fire")
   	fireEffect:setParent(movieBG)
   	fireEffect:setPosition(294,117)
   	fireEffect:play(true)
   	--加进度条特效
   	local effectPanel = self:getChildByName("mainPanle/topPanel/lodingBgImg/effectPanel")
   	-- self.barEffrct = UIMovieClip.new("rpg-particles-of-light")
   	-- self.barEffrct:setParent(effectPanel)
   	-- self.barEffrct:play(true)
   	-- self.barEffrct:setPosition(0, 20)
   	--加升级特效
   	self.shengjiEffect = UIMovieClip.new("rpg-the-light-beam")
   	self.shengjiEffect:setParent(effectPanel)
   	self.shengjiEffect:setPosition(175, 20)
end

function EquipUpNewPanel:onSubcontractPanel()
	--local state = self.view:getState()
    --state:onSubcontractPanel("EquipModule",function () end,13)
end

--130001协议接收播放此特效
function EquipUpNewPanel:playEquipLvUpEffect()
	local movieBG = self:getChildByName("mainPanle/topPanel/roleBgImg/roleImg")
	if not self.lvUpEffect then
		self.lvUpEffect = UIMovieClip.new("rpg-blasting")
		self.lvUpEffect:setParent(movieBG)
		self.lvUpEffect:setPosition(40,75)
	end
	local function callBack()
		self.lvUpEffect:setVisible(false)
	end
	self.lvUpEffect:setVisible(true)
	self.lvUpEffect:play(false,callBack)
end

function EquipUpNewPanel:registerEvents()
	EquipUpNewPanel.super.registerEvents(self)
	self:addTouchEventListener(self._upBtn,self.onUpBtnTouch)
	self:addTouchEventListener(self._chooseBtn,self.onChooseBtnTouch)


	self:addTouchEventListener(self._cancelBtn,self.onCancelBtnTouch)
	self:addTouchEventListener(self._closeBtn,self.onCloseBtnTouch)
	self:addTouchEventListener(self._submitBtn,self.onSubmitBtnTouch)
	for i = 1, 6 do
		self:addTouchEventListener(self.typeBtns[i],self.chooseTouch)
	end
end

function EquipUpNewPanel:onOpenUpPanel(id)
	self._currId = id or self._currId
	self:updateTopInfo(id)
	self:updateListData()
end

function EquipUpNewPanel:onClosePanelHandler()
	TimerManager:remove(self.updateBar, self)
	self.lodingBar:stopAllActions()
    EquipUpNewPanel.super.onClosePanelHandler(self)
    self:hide()
end

function EquipUpNewPanel:updateTopInfo(mark)
	local id = self._currId
	local data = self._equipProxy:getSoldierById(id)
-----------装备名字和等级-----------------------------
	local nameLvLab = self:getChildByName("mainPanle/topPanel/nameLvLab") --装备名称和等级
	local config = self:getConfigName(data.typeid)
	local str = config.name.."Lv."..data.level
	nameLvLab:setString(str)
	nameLvLab:setColor(ColorUtils:getColorByQuality(config.quality))
-------------装备Icon---------------------------------
	local roleBgImg = self:getChildByName("mainPanle/topPanel/roleBgImg") --装备框
	local url = "images/gui/Frame_character"..config.quality.."_none.png"
	self:updateMovieChip(roleBgImg,config)
	TextureManager:updateImageView(roleBgImg,url)
	local roleImg = self:getChildByName("mainPanle/topPanel/roleBgImg/roleImg") --装备图片
	local url = "images/general/"..config.icon..".png"
	TextureManager:updateImageView(roleImg,url)
-------------等级加成------------------------------------
	local rsConfig = self:getConfigPlus(data)
	local currentEffectLab = self:getChildByName("mainPanle/topPanel/currentImg/effectLab")--当前等级状态
	local currentValueLab = self:getChildByName("mainPanle/topPanel/currentImg/valueLab")--当前状态百分比
	local nextEffectLab = self:getChildByName("mainPanle/topPanel/nextImg/effectLab")--下一级等级状态
	local nexValueLab = self:getChildByName("mainPanle/topPanel/nextImg/valueLab")--下一级状态百分比
	currentEffectLab:setString(self:getTextWord(720+data.upproperty).."：")
	currentValueLab:setString(rsConfig.value)
	local lodingValueLab = self:getChildByName("mainPanle/topPanel/lodingBgImg/lodingValueLab")--进度百分比文字
	local lodingBar = self:getChildByName("mainPanle/topPanel/lodingBgImg/lodingBar")--进度条百分比
	local nextValue
	local percentStr 
	--判断是否满级
	if rsConfig.config.expneed ~= 0 then
		self._upBtn.isFull = false
		nextEffectLab:setString(self:getTextWord(720+data.upproperty).."：")
		local nextConfig = ConfigDataManager:getInfoFindByOneKey("WarriorProConfig","ID",rsConfig.config.ID + 1)
		nextValue = nextConfig[SoliderPowerDefine.equipAttribute[data.upproperty]] / 100 .."%"
		nexValueLab:setString(nextValue)
---------------进度条---------------------------------	
		percentStr = data.exp.."/"..rsConfig.config.expneed
		lodingValueLab:setString(percentStr)
		--lodingBar:setPercent(100*data.exp / rsConfig.config.expneed)

		local function reSetDefault()
			nameLvLab:setString(self.oldData.str)
			currentValueLab:setString(self.oldData.currentVale)
			nexValueLab:setString(self.oldData.nextValue)
			self.lodingBar:setPercentage(self.oldData.percent)
			lodingValueLab:setString(self.oldData.percentStr)
			TimerManager:remove(self.updateBar, self)
		end
		local function setOldData()
			self.oldData = {}
			self.oldData.lv = data.level
			self.oldData.str = str
			self.oldData.currentVale = rsConfig.value
			self.oldData.nextValue = nextValue
			self.oldData.percentStr = percentStr
			self.oldData.percent = 	100*data.exp / rsConfig.config.expneed	
			self.oldData.ID = rsConfig.config.ID
		end
		if not self.lodingBar then
			local EquipLoadingBar = require("modules.equip.panel.EquipLoadingBar")

			self.lodingBar = EquipLoadingBar.new({loaderBar = lodingBar,url = "images/equip/lodingbar.png",reSetDefault = reSetDefault})
		end
		--判断是否需要执行动作
		if mark then
			self.lodingBar:setPercentage(100*data.exp / rsConfig.config.expneed)
			setOldData()
		else
		--强制打断动作
			local lastData = {}
			reSetDefault()
			lastData = self.oldData
			TimerManager:remove(self.updateBar, self)
			self.lodingBar:stopAllActions()
			setOldData()
			local function callBack(index)
				local function callBack()
					self.shengjiEffect:setVisible(false)
				end
				self.shengjiEffect:setVisible(true)
				self.shengjiEffect:play(false,callBack)
				local lv = lastData.lv + index
				nameLvLab:setString(config.name.."Lv."..lv)
				local tmpConfig = ConfigDataManager:getInfoFindByOneKey("WarriorProConfig","ID",lastData.ID + index)
				local tmpcurrentValue = tmpConfig[SoliderPowerDefine.equipAttribute[data.upproperty]] / 100 .."%"
				currentValueLab:setString(tmpcurrentValue)
				tmpConfig = ConfigDataManager:getInfoFindByOneKey("WarriorProConfig","ID",lastData.ID + index + 1)
				tmpcurrentValue = tmpConfig[SoliderPowerDefine.equipAttribute[data.upproperty]] / 100 .."%"
				nexValueLab:setString(tmpcurrentValue)
				local tmpData = {}
				tmpData.level = lv
				tmpData.quality = data.quality
				tmpData.upproperty = data.upproperty
				local tempConfig2 = self:getConfigPlus(tmpData)
				self.currentMaxExp = tempConfig2.config.expneed
				--local loadingStr = tempConfig2.config.expneed.."/"..tempConfig2.config.expneed
				--lodingValueLab:setString(loadingStr)
			end
			TimerManager:add(60,self.updateBar,self)
			self.lodingBar:runActions(self.oldData.percent, self.oldData.lv - lastData.lv, callBack)
		end
		self.currentMaxExp = rsConfig.config.expneed
		--self.lodingBar:runActions()
	else
		nexValueLab:setString("已满级")
		lodingValueLab:setString("满级")
		--lodingBar:setPercent(100)
		self._upBtn.isFull = true
	end
end

function EquipUpNewPanel:getchooseItem(tb)
	local datas = self._equipProxy:getEquipAllHome()
	for k,v in pairs(datas) do
		if tb[v.quality] then
			self:useidsManage(1, v.id)
		end
	end
	self:resetExpValue()
end

function EquipUpNewPanel:updateListData(tb)
	self.tb = tb or {}
	self.useids = {}    --初始化已选择武将的id
	self:getchooseItem(self.tb)
	local allExpLab = self:getChildByName("mainPanle/lastPanel/allExpLab")
	allExpLab:setString(0)--选择置0
	local data = self:getDataforList()
	local listView = self:getChildByName("mainPanle/listPanel/listView")

	self:renderListView(listView, data, self, self.registerItemEvents)
end



function EquipUpNewPanel:registerItemEvents(item,data,index)
	local items = {}
	for i = 1, 4 do
		items[i]  = item:getChildByName("roleBgImg"..i)
		items[i]:setVisible(i < #data + 1)
	end
	for i = 1, #data do
		local config = self:getConfigName(data[i].typeid)
		local roleImg = items[i]:getChildByName("roleImg")  --装备图片
		local url = "images/general/"..config.icon..".png"
		TextureManager:updateImageView(roleImg,url)
		url = "images/gui/Frame_character"..config.quality.."_none.png"
		TextureManager:updateImageView(items[i], url)   -- 设置装备品质框
		self:updateMovieChip(items[i],config)
		local expLab = items[i]:getChildByName("expLab")  --经验值
		expLab:setString("经验"..self:getExp(data[i]))
		local lvLab = items[i]:getChildByName("lvLab")
		lvLab:setProperty("1234567890", "ui/images/fonts/equipLv.png", 18, 22, "0")
		--local lvLab = lvPanel:getChildByName("lvLab")
		lvLab:setString(data[i].level)
		local chooseImg = items[i]:getChildByName("chooseImg")
		items[i].data = data[i]
		self:addTouchEventListener(items[i],self.onItemTouchRsp)
		if self.tb[data[i].quality] then
			items[i].choose = true
			chooseImg:setVisible(true)
			--self:useidsManage(1,data[i].id)
		else
			chooseImg:setVisible(false)
			items[i].choose = false
		end
	end
end

function EquipUpNewPanel:onItemTouchRsp(sender)
	if sender.choose then
		sender.choose = false
		self:useidsManage(2,sender.data.id)
	else
		sender.choose = true
		self:useidsManage(1,sender.data.id)
	end
	local chooseImg = sender:getChildByName("chooseImg")
	chooseImg:setVisible(sender.choose)
	self:resetExpValue()
end

function EquipUpNewPanel:getExp(data)
	if data.type == 1 then
		config = ConfigDataManager:getInfoFindByTwoKey("WarriorProConfig","lv",data.level,"quality",data.quality)
		return config.exp
	else
		config = self:getConfigName(data.typeid)
		return config.eatedExp
	end
end

function EquipUpNewPanel:getDataforList()
	local infos = self._equipProxy:getEquipAllHome() or {}
	local tempData = {}
	local index = 1 
	for k,v in pairs(infos) do
		--去掉自己
		if v.id ~= self._currId then
			tempData[index] = v
			index = index + 1
		end
	end
	local data = {}
	for i = 1, #tempData, 4 do
		local index = math.floor((i + 3)/4)
		data[index] = {}
		for j = 1, 4 do
			data[index][j] = tempData[i + j - 1]
		end
	end
	return data
end

function EquipUpNewPanel:getConfigName(typeid)
    local config = ConfigDataManager:getInfoFindByOneKey("WarriorsConfig","ID",typeid)
    return config
end

function EquipUpNewPanel:getConfigPlus(data)
    local config = ConfigDataManager:getInfoFindByTwoKey("WarriorProConfig","lv",data.level,"quality",data.quality)
    local value = config[SoliderPowerDefine.equipAttribute[data.upproperty]] / 100 .. "%"
    return {value = value ,config = config}
end

--类型为1的时候增加 2的时候删除
function EquipUpNewPanel:useidsManage(type,id)
	if type == 1 then
		table.insert(self.useids,id)
	elseif type == 2 then
		for k,v in pairs(self.useids) do
			if v == id then
				table.remove(self.useids,k)
			end
		end
	end
end

function EquipUpNewPanel:resetExpValue()
	local expValue = 0
	local data = self._equipProxy:getEquipAllHome() or {}
	for k,id in pairs(self.useids) do
		for _, v in pairs(data) do
			if id == v.id then
				expValue = self:getExp(v) + expValue
			end
		end
	end
	local allExpLab = self:getChildByName("mainPanle/lastPanel/allExpLab")
	
	local function delaySetExp()
		allExpLab:setString(expValue)
	end
	TimerManager:addOnce(30,delaySetExp, self)
end

function EquipUpNewPanel:onUpBtnTouch(sender)
	if sender.isFull then
		self:showSysMessage("该装备已达到最大等级！")
		return
	end
	if  _G.next(self.useids) == nil then
		self:showSysMessage("请选择你需要吞噬的装备！")
	else
		local data = {}
		data.id = self._currId
		data.useids = self.useids
		for k, v in pairs(data.useids) do
			if v == data.id then
				table.remove(data.useids,k)
			end
		end
		local function callBack()
			self:dispatchEvent(EquipEvent.UP_EQUIP_REQ,data)
		end
		local tips = false
		local datas = self._equipProxy:getEquipAllHome()
		for _, v in pairs(datas) do
			for _, id in pairs(self.useids) do
				if v.id == id then
					if v.quality >= 4 and  v.upproperty ~= 0 then
						tips = true
					end 
				end
			end
		end
		if tips then
			self:showMessageBox("提示：您要吞噬的强化材料中含有紫色品质的装备，是否确认消耗进行强化操作？",callBack)
		else
			callBack()
		end
	end
end

function EquipUpNewPanel:onChooseBtnTouch()
	self:choosePanelVisible(true)
	self:updateTypePanel()
end

function EquipUpNewPanel:updateTypePanel()
	self.choosePanel = {}
	for i = 1, 6 do
		self.typeBtns[i].choose = nil
		local img = self.typeBtns[i]:getChildByName("img")
		img:setVisible(false)
	end
end

function EquipUpNewPanel:chooseTouch(sender)
	for k, v in pairs(self._colorTb) do
		if sender:getName() == v then
			if k ~= 6 then
				sender.choose =  not sender.choose
				local img = sender:getChildByName("img")
				img:setVisible(sender.choose)
				self.choosePanel[k] = sender.choose
				img = self.typeBtns[6]:getChildByName("img")
				img:setVisible(false)
			else
				for i = 1, 6 do
					local img = self.typeBtns[i]:getChildByName("img")
					self.typeBtns[i].choose = true
					img:setVisible(true)
					self.choosePanel[i] = true
				end
			end
		end
	end
	self.choosePanel[6] = false
end

function EquipUpNewPanel:onCancelBtnTouch()
	self:choosePanelVisible(false)
end

function EquipUpNewPanel:onCloseBtnTouch()
	self:choosePanelVisible(false)
end

function EquipUpNewPanel:onSubmitBtnTouch()
	self:choosePanelVisible(false)
	--根据需求刷新界面
	self:updateListData(self.choosePanel)
end

function EquipUpNewPanel:choosePanelVisible(visible)
	local maskPanel = self:getChildByName("maskPanel")
	maskPanel:setVisible(visible)
	local chooseTypePanel = self:getChildByName("chooseTypePanel")
	chooseTypePanel:setVisible(visible)
end


function EquipUpNewPanel:updateMovieChip(parent,config)
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
