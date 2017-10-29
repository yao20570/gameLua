
LegionHelpPanel = class("LegionHelpPanel", BasicPanel)
LegionHelpPanel.NAME = "LegionHelpPanel"

function LegionHelpPanel:ctor(view, panelName)
    LegionHelpPanel.super.ctor(self, view, panelName,true)
    
    self:setUseNewPanelBg(true)
end

function LegionHelpPanel:finalize()
    LegionHelpPanel.super.finalize(self)
end

function LegionHelpPanel:initPanel()
	LegionHelpPanel.super.initPanel(self)
	self:setBgType(ModulePanelBgType.NONE)
	self:setTitle(true,"juntuanbangzhu",true)	
	self.helpAllBtn = self:getChildByName("downPanel/helpAllBtn")

	local listView = self:getChildByName("mainPanel/listView")
	listView:setVisible(false)
end

function LegionHelpPanel:doLayout()
	local listView = self:getChildByName("mainPanel/listView")
	local downPanel = self:getChildByName("downPanel")
	local tabsPanel = self:topAdaptivePanel2()
	NodeUtils:adaptiveListView(listView, downPanel, tabsPanel)
end

function LegionHelpPanel:registerEvents()
	LegionHelpPanel.super.registerEvents(self)
	self:addTouchEventListener(self.helpAllBtn,self.onHelpAllBtnTouch)
end

function LegionHelpPanel:onClosePanelHandler()
	self:dispatchEvent(LegionHelpEvent.HIDE_SELF_EVENT)
end

function LegionHelpPanel:updateBuildHelpInfos(infos)
	local legionProxy = self:getProxy(GameProxys.Legion)
	local legionHelpProxy = self:getProxy(GameProxys.LegionHelp)
	local listView = self:getChildByName("mainPanel/listView")
	self.infos = infos
	local roleProxy = self:getProxy(GameProxys.Role)
	local name = roleProxy:getRoleName()
	local tmpdata = {}
    for k,v in pairs(self.infos) do
    	if v.name == name then
    		self.infos[k].sortnum = 1
    	else
    		self.infos[k].sortnum = 2
    	end
    	if legionHelpProxy:getMaxHelp() > v.helpnum then
    		table.insert(tmpdata,v)
    	end
    end
    self.infos = tmpdata
    local function func(x, y)
    	if x.sortnum ~= y.sortnum then
			return x.sortnum < y.sortnum 
		end
		return x.buildtype > y.buildtype	 
    end
    table.sort(self.infos, func)

	self:renderListView(listView, self.infos, self, self.renderItem)
    listView:setVisible(true)

end

function LegionHelpPanel:renderItem(item, data, index)
	item:setVisible(true)
	local roleProxy = self:getProxy(GameProxys.Role)
	local legionProxy = self:getProxy(GameProxys.Legion)
	local legionHelpProxy = self:getProxy(GameProxys.LegionHelp)
	local maxHelp = legionHelpProxy:getMaxHelp()
	local nameLab = item:getChildByName("nameLab")	
	local discribleLab = item:getChildByName("discribleLab")	
	local loadingLab = item:getChildByName("loadingLab")	
	local loadingLab1 = item:getChildByName("loadingLab1")	
	local loadingbar = item:getChildByName("loadingbar")	
	local helpBtn = item:getChildByName("helpBtn")	
	nameLab:setString(data.name)
	local buildOpenConfig = require("excelConfig.BuildOpenConfig")
	local buildName = 1
	for k,v in pairs(buildOpenConfig) do
		if v.type == data.buildtype then
			buildName = v.name 
		end
	end
	local buildResourceConfig = require("excelConfig.BuildResourceConfig")
	if buildName == 1 then
		for k,v in pairs(buildResourceConfig) do
			if v.type == data.buildtype then
				buildName = v.name 
				break
			end
		end
	end
	discribleLab:setString("帮他升级"..buildName)
	loadingLab:setString(data.helpnum)
	loadingLab1:setString("/"..maxHelp)
	NodeUtils:alignNodeL2R(loadingLab,loadingLab1)

	if data.helpnum == 0 then
		loadingLab:setColor(ColorUtils.commonColor.c3bWhite)
	else
		loadingLab:setColor(ColorUtils.commonColor.c3bGreen)
	end

	loadingbar:setPercent(100*data.helpnum/maxHelp)
	self:addTouchEventListener(helpBtn,self.onHelpBtnTouch)
	helpBtn.id = data.id
	local name = roleProxy:getRoleName()
	helpBtn:setVisible( name ~= data.name) 
	local personPanel = item:getChildByName("personPanel") 
	local headInfo = {}
    headInfo.icon = data.icon
    headInfo.pendant = data.icon
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = "headPendant"
    headInfo.isCreatPendant = false
    headInfo.playerId = rawget(data, "playerId")
    local head = item.head
    if head == nil then
    	-- print("----------------------------------------------------------------------------------")
        head = UIHeadImg.new(personPanel,headInfo,self)
        -- head:setHeadTransparency()
        item.head = head
    else
        head:updateData(headInfo)
    end 

end

function LegionHelpPanel:onHelpBtnTouch(sender)
	local legionHelpProxy = self:getProxy(GameProxys.LegionHelp)
	local data = {}
	data.ids = {}
	data.ids[1] = sender.id
	for k,v in pairs(self.infos) do
		if v.id == sender.id then
			table.remove(self.infos, k)
		end
	end
	local roleProxy = self:getProxy(GameProxys.Role)
	local name = roleProxy:getRoleName()
	legionHelpProxy:onTriggerNet220501Req(data)
	legionHelpProxy:removinfo(sender.id)
	self:updateBuildHelpInfos(self.infos)
end

function LegionHelpPanel:onHelpAllBtnTouch()
	local data = {}
	data.ids = {}
	local tmpInfos = {}
	local roleProxy = self:getProxy(GameProxys.Role)
	for k,v in pairs(self.infos) do
		local name = roleProxy:getRoleName()
		if name ~= v.name then
			table.insert(data.ids,v.id)
		else
			table.insert(tmpInfos, v)
		end
	end
	self.infos = tmpInfos
	if #data.ids > 0 then
		local legionHelpProxy = self:getProxy(GameProxys.LegionHelp)
		legionHelpProxy:helpOthersBuildings()
	else
		self:showSysMessage("还没收到任何请求帮助信息！")
	end

	self:updateBuildHelpInfos(self.infos)
end

