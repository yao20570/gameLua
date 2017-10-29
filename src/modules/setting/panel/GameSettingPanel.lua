
GameSettingPanel = class("GameSettingPanel", BasicPanel)
GameSettingPanel.NAME = "GameSettingPanel"

function GameSettingPanel:ctor(view, panelName)
    GameSettingPanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function GameSettingPanel:finalize()
    GameSettingPanel.super.finalize(self)
end

function GameSettingPanel:initPanel()
	GameSettingPanel.super.initPanel(self)
	self:setBgType(ModulePanelBgType.NONE)
    self:setTitle(true,"setting", true)
    
	

	self._listView = {}
end

function GameSettingPanel:doLayout()
	local Panel_top = self:getChildByName("Panel_top")
	local panel = self:topAdaptivePanel()
    NodeUtils:adaptiveUpPanel(Panel_top,nil,GlobalConfig.tabsHeight)

    local titleBg = self:getChildByName("Panel_top/titleBg")
    local ListView_1 = self:getChildByName("Panel_top/Image_1/ListView_1")
    NodeUtils:adaptiveListView(ListView_1, GlobalConfig.downHeight, titleBg)

end

function GameSettingPanel:onShowHandler()
	-- body
	-- 已存在列表，不在渲染
	if self._listView ~= nil and #self._listView > 0 then
		--return
	end


	self:onTopPanel()
	
	-- 当前版本暂时屏蔽通知设置
	-- self:onButtomPanel()

end

function GameSettingPanel:onGetSettingData(type)
	local settingProxy = self:getProxy(GameProxys.Setting)
	local tabData = settingProxy:getSettingDataByType(type)
	return tabData
end

function GameSettingPanel:onTopPanel()
	local tabData = self:onGetSettingData(1)

	local ListView_1 = self:getChildByName("Panel_top/Image_1/ListView_1")
    self:renderListView(ListView_1, tabData, self, self.onRenderItem)
end

-- function GameSettingPanel:onButtomPanel()
-- 	local tabData = self:onGetSettingData(2)

-- 	local ListView_1 = self:getChildByName("Panel_buttom/Image_1/ListView_1")
--     self:renderListView(ListView_1, tabData, self, self.onRenderItem)
-- end


function GameSettingPanel:onRenderItem(itempanel, info, index)
	-- body
	itempanel:setVisible(true)
	
	local Label_7 = itempanel:getChildByName("Label_7")
	local Label_7_0 = itempanel:getChildByName("Label_7_0")
	local Button_open = itempanel:getChildByName("Button_open")
	local Button_close = itempanel:getChildByName("Button_close")
	local Image_line = itempanel:getChildByName("Image_line")

	-- local var = index%2
	-- if var == 0 then
	-- 	Image_line:setVisible(false)
	-- else
	-- 	Image_line:setVisible(true)
	-- end

	local strNumber = info.name
	Label_7:setString(self:getTextWord(strNumber))
	Label_7:setColor(ColorUtils.riceColor)

	local size = Label_7:getContentSize()
	local x = Label_7:getPositionX() + size.width + 10
	Label_7_0:setPositionX(x)

	local isOpen = info.status
	if isOpen == 1 then
		-- 已开启
		Label_7_0:setString(self:getTextWord(1406))
		Label_7_0:setColor(ColorUtils.wordGreenColor)
		Button_close:setTitleText(self:getTextWord(1411))
		Button_close:setVisible(true)
		Button_open:setVisible(false)
		Button_close.info = info
		self:addTouchEventListener(Button_close, self.onSwitchBtn)
	else
		-- 已关闭
		Label_7_0:setString(self:getTextWord(1407))
		Label_7_0:setColor(ColorUtils.wordRedColor)
		Button_open:setTitleText(self:getTextWord(1410))
		Button_open:setVisible(true)
		Button_close:setVisible(false)
		Button_open.info = info
		self:addTouchEventListener(Button_open, self.onSwitchBtn)
	end

	itempanel.info = info
	table.insert(self._listView, itempanel)

end

function GameSettingPanel:onUpdateItem(id, status)
	-- body

	for k,v in pairs(self._listView) do
		local info = v.info
		if info.id == id then
			-- info.status = self:getLocalData(info.key, info.isGloble)
			local status = self:getLocalData(info.key, info.isGloble)
			info.status = tonumber(status)
			-- info.status = status
			v.info = info
			self:onRenderItem(v,v.info,k-1)
			return
		end
	end

end

function GameSettingPanel:onSwitchBtn(sender)
	-- body

	local info = sender.info
	local key = info.key
	local value = info.status
	local id = info.id

	if value == 1 then
		value = 0
	else
		value = 1
	end
	self:setLocalData(key, value, true) -- 缓存数据：true 全局有效，false 当前账号有效
	
	local settingProxy = self:getProxy(GameProxys.Setting)
	if id <= 5 then
		settingProxy:onSwitchSettingByKey(key)
		-- self:onSwitchSetting(key) -- 设置游戏性功能
	else
		settingProxy:onTriggerNet20300Req(id-5)
	end
	-- self:onSwitchSetting(key) -- 设置游戏性功能
	

	self:onUpdateItem(id, value) -- 更新界面
end



function GameSettingPanel:onClosePanelHandler()
    self:hide()
end
