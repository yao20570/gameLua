--
-- Author: zlf
-- Date: 2016年12月13日16:41:36
-- 英雄分解预览

HeroResolve = class("HeroResolve", BasicPanel)
HeroResolve.NAME = "HeroResolve"

function HeroResolve:ctor(view, panelName)
    HeroResolve.super.ctor(self, view, panelName, 400)
    
    self:setUseNewPanelBg(true)
end

function HeroResolve:finalize()
    HeroResolve.super.finalize(self)
end

function HeroResolve:initPanel()
	HeroResolve.super.initPanel(self)
    self:setTitle(true, self:getTextWord(290025))
--    local heroInfoPanel = UIHeroInfoPanel.new(self._parent, sender.data, nil, true, self._canResolve)
--	heroInfoPanel:setLocalZOrder(120) 
    self:setLocalZOrder(121) -- 层级调整，由于UIHeroPanel的父节点和HeroResolve相同
    self._proxy = self:getProxy(GameProxys.Hero)

    self.listView = self:getChildByName("Panel_1/ListView_4")


    local cancelBtn = self:getChildByName("Panel_1/cancelBtn")
    self:addTouchEventListener(cancelBtn, self.hide)
    local sureBtn = self:getChildByName("Panel_1/sureBtn")
    self:addTouchEventListener(sureBtn, self.sendResolveReq)
    sureBtn:setTitleText(self:getTextWord(290070))
    local Label_2 = self:getChildByName("Panel_1/Label_2")
    Label_2:setString(self:getTextWord(290071))
end

function HeroResolve:onShowHandler(data)
	-- if id == nil then
	-- 	self:hide()
	-- 	return
	-- end
 --    local heroData = self._proxy:getInfoById(id)
 --    if heroData == nil then
 --    	self:hide()
	-- 	return
 --    end
 --    local data = self:getResolveData(heroData)
 --    if data == nil then
 --    	self:hide()
 --    	return
 --    end
 --    self._heroDbId = heroData.heroDbId
    data = TableUtils:splitData(data, 2)
    self:renderListView(self.listView, data, self, self.renderMethod)

end

-- --获得分解返回的东西
-- function HeroResolve:getResolveData(heroData)
-- 	local allData = {}
-- 	-- local keys = {"wexpoffer", "gexpoffer", "bexpoffer", "pexpoffer", "oexpoffer"}
--  --    local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, heroData.heroId)
--  --    local levelData = ConfigDataManager:getConfigById(ConfigData.HeroLevelConfig, heroData.heroLv)

--  --    if levelData ~= nil then
-- 	--     local key = keys[config.color]
-- 	--     local heroExp = levelData[key]
-- 	--     local expConfig = ConfigDataManager:getConfigData(ConfigData.ExperienceReturnConfig)
-- 	--     for i=#expConfig, 1, -1 do
-- 	--     	local v = expConfig[i]
-- 	--     	local num = math.floor(heroExp/v.experience)
-- 	--     	if num > 0 then
-- 	--     		table.insert(allData, {num = num, power = 409, typeid = v.experienceID})
-- 	--     		heroExp = heroExp - num*v.experience
-- 	--     	end
-- 	--     end
-- 	-- end

--     local starConfig = ConfigDataManager:getInfoFindByTwoKey(ConfigData.DecomposeConfig, "heroID", heroData.heroId, "star", heroData.heroStar)
--     if starConfig ~= nil then
-- 	    local itemData = StringUtils:jsonDecode(starConfig.remouldback)
-- 	    for k,v in pairs(itemData) do
-- 	    	table.insert(allData, {num = v[3], power = v[1], typeid = v[2]})
-- 	    end
-- 	end

-- 	local strategicsInfo = {}
-- 	for k,v in pairs(heroData.strategicsInfo) do
-- 		strategicsInfo[v.strategicsId] = v.strategicsLv
-- 	end


--     for k,v in pairs(strategicsInfo) do
--     	local strategicsData = ConfigDataManager:getInfoFindByTwoKey(ConfigData.StrategicsLvConfig, "StrategicsID", k, "lv", v)
--     	local returnData = StringUtils:jsonDecode(strategicsData.lvupneed)
--     	for _,info in pairs(returnData) do
--     		table.insert(allData, {num = info[3], power = info[1], typeid = info[2]})
--     	end
--     end

--     if #allData == 0 then
--     	return
--     end

--     --去重
--     local repeatData = {}
--     for k,v in pairs(allData) do
--     	repeatData[v.power] = repeatData[v.power] or {}
--     	if repeatData[v.power][v.typeid] == nil then
--     		repeatData[v.power][v.typeid] = v.num
--     	else
--     		repeatData[v.power][v.typeid] = repeatData[v.power][v.typeid] + v.num
--     	end
--     end

--     local data = {}
--     for powerValue,datas in pairs(repeatData) do
--     	for id, number in pairs(datas) do
--     		table.insert(data, {power = powerValue, typeid = id, num = number})
--     	end
--     end

--     return data
-- end

function HeroResolve:renderMethod(item, data)
	for i=1,2 do
		local v = data[i]
		local node = item:getChildByName("item"..i)
		node:setVisible(v ~= nil)
		if v ~= nil then
			local iconImg = node:getChildByName("iconImg")
			local numLab = node:getChildByName("numLab")
			local nameLab = node:getChildByName("nameLab")
			local icon = iconImg.uiIcon
			if icon == nil then
				icon = UIIcon.new(iconImg, v, true, self)
				iconImg.uiIcon = icon
			else
				icon:updateData(v)
			end

			local name = icon:getName()
			nameLab:setString(name)
			local quality = icon:getQuality()
			local color = ColorUtils:getColorByQuality(quality)
			nameLab:setColor(color)
			numLab:setString(v.num)
		end
	end
end

function HeroResolve:sendResolveReq(sender)
	local resolveId = self._proxy:getResolveId()
	self._proxy:onTriggerNet300101Req({id = resolveId})
end