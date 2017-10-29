-- /**
--  * @Author:    fzw
--  * @DateTime:    2017-01-05 14:02:00
--  * @Description: 大军基地
--  */
BigStationPanel = class("BigStationPanel", BasicPanel)
BigStationPanel.NAME = "BigStationPanel"

function BigStationPanel:ctor(view, panelName)
    BigStationPanel.super.ctor(self, view, panelName, true)

    self:setUseNewPanelBg(true)
end

function BigStationPanel:finalize()
    BigStationPanel.super.finalize(self)
end

function BigStationPanel:initPanel()
	BigStationPanel.super.initPanel(self)
	self:setTitle(true, "bigStation", true)


	self:setBgType(ModulePanelBgType.BIGSTATION)
	-- self._bgImg = self:getChildByName("bgImg")
	-- TextureManager:updateImageViewFile( self._bgImg,"bg/bigStation/bg.jpg")

	self._mainPanel = self:getChildByName("bgImg2")
	self._posPanel = self:getChildByName("posPanel")


	self._posPanelMap = {}
	self:initAllPos()

end


function BigStationPanel:registerEvents()
	BigStationPanel.super.registerEvents(self)
end

function BigStationPanel:doLayout()
	-- local topPanel = self:topAdaptivePanel()
	--NodeUtils:adaptivePanelBg( self._bgImg, GlobalConfig.downHeight, topPanel )
	-- NodeUtils:adaptivePanelBg( self._mainPanel, GlobalConfig.downHeight-5, topPanel )
    -- NodeUtils:adaptiveTopPanelAndListView(self._bgImg, nil, nil, GlobalConfig.topHeight2)


	-- NodeUtils:adaptiveTopPanelAndListView(self._bgImg, nil, GlobalConfig.downHeight-5, topPanel)
	-- NodeUtils:adaptiveTopPanelAndListView(self._mainPanel, nil, GlobalConfig.downHeight-5, topPanel)
end

function BigStationPanel:onAfterActionHandler()
	self:onShowHandler()
end

function BigStationPanel:onShowHandler()
	if self:isModuleRunAction() then
		return
	end


	-- self:setBgPanelZorder(1000)

	self:updateAllPos()

end

function BigStationPanel:getConfig()
	local config = {}
	local allConfig = ConfigDataManager:getConfigData(ConfigData.ArmKindsConfig)
	for k,v in pairs(allConfig) do
		if v.show == 2 and v.gradation >= 6 then  --显示场地：大军基地, 6阶+
			-- v.scale = v.scale / 100  --TODO 表暂缺的字段
			table.insert(config,v)
		end
	end


	-- 排序规则
	-- 106,206,306,406,
	-- 107,207,307,407,
	-- 108,208,308,408,
	-- 109,209,309,409,
	local function sortFunc(a, b)
		if a.gradation < b.gradation then
			return true
		elseif a.gradation == b.gradation then
			if a.ID < b.ID then
				return true
			end
		end
		return false
	end
	table.sort( config, sortFunc )  --排序

	return config
end

function BigStationPanel:initAllPos()
	local config = self:getConfig()
	self._config = config

	for i=1, #config do
		local ID = config[i].ID
		local posPanel = self._mainPanel:getChildByName("pos"..i)
		if posPanel then

			local x,y = posPanel:getPosition()
			posPanel:setVisible(false)

			local panel = self._posPanel:clone()
			panel:setVisible(false)
			panel:setPosition(x,y)
			self._mainPanel:addChild(panel)
			panel.curNum = -1  --初始化的数量为-1
			self._posPanelMap["pos"..ID] = panel

		end
	end

	if #config < 16 then
		for i=#config+1,16 do
			local posPanel = self._mainPanel:getChildByName("pos"..i)

			if posPanel then
				local x,y = posPanel:getPosition()
				posPanel:setVisible(false)

				local panel = self._posPanel:clone()
				panel:setVisible(false)
				panel:setPosition(x,y)
				self._mainPanel:addChild(panel)

				local iconImg = panel:getChildByName("iconImg")
				TextureManager:updateImageView(iconImg,"images/bigStation/black.png")
			end
						
		end
	end

end

function BigStationPanel:updateAllPos()

	local config = self._config

	for i=1, #config do
		local info = config[i]
		local ID = info.ID
		local posPanel = self._posPanelMap["pos"..ID]
		if posPanel then
			local soldierProxy = self:getProxy(GameProxys.Soldier)
			local num = soldierProxy:getSoldierCountById(ID)

			local curNum = posPanel.curNum
			if curNum ~= num then --数量有变化才刷新
				posPanel.curNum = num
				self:updatePosInfo(posPanel, info,i)
			end

		end
	end
end


function BigStationPanel:updatePosInfo(posPanel,info,idx)
	posPanel:setVisible(true)
	posPanel.info = info
	local num = posPanel.curNum
	local ID = info.ID
	local scale = info.scale/100 or 1

	--第一行缩小30%
	--第二行缩小20%
	if math.floor((idx-1)/4) == 0 then
		scale = scale * 0.7
	elseif math.floor((idx-1)/4) == 1 then
		scale = scale * 0.8
	end


	local iconImg = posPanel:getChildByName("iconImg")
	local infoImg = posPanel:getChildByName("infoImg")
	if iconImg == nil then
		return
	end


	local model = iconImg.model
	if num > 0 then		
		if model == nil then
			TextureManager:updateImageView(iconImg,"images/newGui1/none.png")
			-- if self:isHaveHighModel(info.model) ~= true then
			-- 	return  --不创建了
			-- end  ---先显示默认的，这块还是有问题

			local model = SpineModel.new(info.model, iconImg)
			iconImg.model = model

			model:playAnimation("wait", true)  --默认循环播放 wait 动作
			model:setScale(scale)  --缩放

			-- 坐标偏移 ：ArmKinds表新增json类型deviation字段
			local devPos = StringUtils:jsonDecode(info.deviation)
			if devPos then
				model:setPosition(devPos[1], devPos[2])
			end
		end

		infoImg:setVisible(true)
		local count = infoImg:getChildByName("count")
		local typeImg = infoImg:getChildByName("typeImg")
		local typeLVImg = infoImg:getChildByName("typeLVImg")
		count:setString(num)

		local url1 = string.format("images/newGui2/Icon_bg_level%d.png", info.gradation % 5)
		local url2 = string.format("images/newGui2/Icon_level%d.png", info.gradation)
		TextureManager:updateImageView(typeImg, url1)
		TextureManager:updateImageView(typeLVImg, url2)  --阶级
		
	else
		if model then
			model:finalize()  --数量不足，移除模型
			iconImg.model = nil
		end
		TextureManager:updateImageView(iconImg,"images/bigStation/black.png")
		infoImg:setVisible(false)
	end


	if posPanel.addEvent == nil then
		posPanel.addEvent = true
		self:addTouchEventListener(posPanel,self.onPosBtnTouch)
	end

end

function BigStationPanel:isHaveHighModel(modelType)
	-- 容错处理：6阶+模型不存在时，用5阶的模型替代
    local function getFileUrl(modelType)
        -- body
        local json = "model/" .. modelType .. "/skeleton.json"
        local atlas = "model/" .. modelType .. "/skeleton.atlas"
        return json,atlas
    end
    
    if (modelType % 100) > 5 then --
    	local json,atlas = getFileUrl(modelType)
        local jsonF = cc.FileUtils:getInstance():isFileExist(json)
        local atlasF = cc.FileUtils:getInstance():isFileExist(atlas)

        if jsonF == false or atlasF == false then
        	logger:error("找不到高阶兵的资源 ：%d",modelType)
        	return false
        end
    end
    return true
end

function BigStationPanel:onPosBtnTouch(sender)
	local info = sender.info
	local num = sender.curNum
	-- print("... 点击一个兵！！！ ...",info.ID,num)
	
	if num > 0 then
		local typeid = info.ID

		local soldierProxy = self:getProxy(GameProxys.Soldier)
		local soldier = soldierProxy:getSoldier(typeid)

		if self._uiSoldierInfo == nil then
		    local parent = self:getLayer(ModuleLayer.UI_TOP_LAYER)
		    self._uiSoldierInfo = UISoldierInfo.new(parent, self)
		end
		self._uiSoldierInfo:updateSoldierInfo(typeid, soldier)
	end
	
end

function BigStationPanel:onClosePanelHandler()
	self:dispatchEvent(BigStationEvent.HIDE_SELF_EVENT, {})
end

