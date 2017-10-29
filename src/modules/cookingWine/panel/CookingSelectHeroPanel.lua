-- /**
--  * @Author:    luzhuojian
--  * @DateTime:    2017-01-06
--  * @Description: 限时活动 煮酒论英雄 更换选择英雄页
--  */
CookingSelectHeroPanel = class("CookingSelectHeroPanel", BasicPanel)
CookingSelectHeroPanel.NAME = "CookingSelectHeroPanel"

function CookingSelectHeroPanel:ctor(view, panelName)
    CookingSelectHeroPanel.super.ctor(self, view, panelName,700)

end

function CookingSelectHeroPanel:finalize()
    CookingSelectHeroPanel.super.finalize(self)
end

function CookingSelectHeroPanel:initPanel()
	CookingSelectHeroPanel.super.initPanel(self)
	self._listview = self:getChildByName("mainPanel/bgListView")
	self.proxy = self:getProxy(GameProxys.Activity)
    self:setTitle(true, self:getTextWord(420008))

end
function CookingSelectHeroPanel:onShowHandler(sendData)
    --类型,0表示免费更换,1表示付费更换
    self.paymentType = sendData.paymentType
    self.pos = sendData.pos
    CookingSelectHeroPanel.super.onShowHandler(self)
    self:updateListView()
    -- print(self.paymentType)
end 
function CookingSelectHeroPanel:updateListView()
	local myData = self.proxy:getCurActivityData()
	local cookingWineConfig = ConfigDataManager:getConfigById(ConfigData.CookingWineConfig, myData.effectId)
	local changeHeroJason = cookingWineConfig.changeHero
    local tipsLab = self:getChildByName("mainPanel/tipsLab")
    local sureBtn = self:getChildByName("mainPanel/sureBtn")
    local goldIcon = self:getChildByName("mainPanel/Image_33")
	if self.paymentType == 0 then
		tipsLab:setString(string.format(self:getTextWord(420013),cookingWineConfig.changePrice))
        tipsLab:setPositionX(295)
		sureBtn:setTitleText(self:getTextWord(420019))
        goldIcon:setVisible(false)
	else
		--tipsLab:setString(string.format(self:getTextWord(420017),cookingWineConfig.changePrice))
		tipsLab:setString(cookingWineConfig.changePrice)
        tipsLab:setPositionX(310)
		sureBtn:setTitleText(self:getTextWord(420018))
        goldIcon:setVisible(true)
	end

	local changeHeroAry = StringUtils:jsonDecode(changeHeroJason)
	local changeHeroAryClone = clone(changeHeroAry)
	--去除已经宴请的英雄
	local cookInfo = self.proxy:getCookInfoyId(myData.activityId)
	local existTypeIdAry = {}
	for k,val in pairs(cookInfo.info) do
		for i,v in ipairs(changeHeroAryClone) do
			if v == val.typeId then
				table.remove(changeHeroAryClone,i)
				break
			end
		end
	end
	--4776 【优化】- 修改煮酒论英雄玩家选择英雄的机制(只能选自己拥有武魂的武将，或者已经拥有的武将)
	local realHeroTypeIdAry = {}
	local heroProxy = self:getProxy(GameProxys.Hero)
	for _,typeid in ipairs(changeHeroAryClone) do
    	local num = heroProxy:getHeroPieceNumByID(typeid)
    	local status = heroProxy:findHeroWithTypeId(typeid)
    	if  num > 0 or status == true then
    		table.insert(realHeroTypeIdAry, typeid)
    	end
	end
	--武将选择的排序,玩家已拥有在前，没拥有在后
	self:sortAry(realHeroTypeIdAry)

    local temp = {}
    local count = 0
    local t 
    for k,v in pairs(realHeroTypeIdAry)do
        if v ~= nil then
            if count == 0 then
                t = {}
            end 
            table.insert(t,v)
            count = count + 1
            if k == #realHeroTypeIdAry then
                table.insert(temp,t)
            else
                if count == 2 then
                    table.insert(temp,t)
                    count = 0
                end
            end 
        end
    end 
    self:renderListView(self._listview, temp, self, self.renderItemPanel)
end


function CookingSelectHeroPanel:renderItemPanel(itemPanel, info, index)
    for i=1,2 do
        --print("i=========",i)
        local nameStr = "itemPanel"..i
        local cell = itemPanel:getChildByName(nameStr)
        cell:setVisible(true)
        local iconImg = cell:getChildByName("iconImg")
        local nameLab = cell:getChildByName("nameLab")
        local noGotLab = cell:getChildByName("noGotLab")
        local starPanel = cell:getChildByName("starPanel")
        local suiLab = cell:getChildByName("suiLab")
        local pieceNumLab = cell:getChildByName("pieceNumLab")
        local pieceNumLabTxt = cell:getChildByName("pieceNumLabTxt")
        
        

        --初始化cell
        local typeId = info[i]
        if typeId ~= nil then
        	local config = 1
        	local heroConfig = ConfigDataManager:getConfigById(ConfigData.HeroConfig,typeId)
			local heroProxy = self:getProxy(GameProxys.Hero)
			local  heroData = heroProxy:getHeroDataWithTypeId(typeId)
			if heroData then
				noGotLab:setVisible(false)
				starPanel:setVisible(true)
				--拥有武将
			    local starUrl = "images/newGui1/IconStarMini.png"
			    local drakUrl = "images/newGui1/IconStarMiniBg.png"
			    local stars = {}
			    for i=1,5 do
			        stars[i] = starPanel:getChildByName("starImg"..i)
			    end

			    ComponentUtils:renderStar(stars, heroData.heroStar, starUrl, drakUrl, heroConfig.starmax)
			    --碎片数量显示
			    if heroData.heroStar == heroConfig.starmax then
			    	--满星处理
			    	suiLab:setString(self:getTextWord(420010))
			    	pieceNumLab:setVisible(false)
                    pieceNumLabTxt:setVisible(false)
			    else
			   		--不满时(遍历是否需要碎片,不需要则找下一条是否需要碎片)
			    	suiLab:setString(self:getTextWord(420009))
			    	pieceNumLab:setVisible(true)
                    pieceNumLabTxt:setVisible(true)
			    	local upStarDataAry
			    	for i=1,5 do
				   		local nextStarData = ConfigDataManager:getInfoFindByTwoKey(ConfigData.HeroStarConfig, "heroID", typeId, "star", heroData.heroStar + i)
						local itemneedAry = StringUtils:jsonDecode(nextStarData.itemneed)
						for k,v in pairs(itemneedAry) do
							if v[1] == GamePowerConfig.HeroFragment then
								upStarDataAry = v
							end
						end
						if upStarDataAry then
							break
						end
			    	end

			    	local roleProxy = self:getProxy(GameProxys.Role)
			    	local playerGetNum = roleProxy:getRolePowerValue(upStarDataAry[1], upStarDataAry[2])

			    	pieceNumLab:setString( "/" .. upStarDataAry[3])
			    	pieceNumLabTxt:setString(playerGetNum)
                    if playerGetNum >= upStarDataAry[3] then
                        pieceNumLabTxt:setColor(ColorUtils.commonColor.c3bGreen)
                    else
                        pieceNumLabTxt:setColor(ColorUtils.commonColor.c3bRed)
                    end
                    NodeUtils:alignNodeL2R(pieceNumLabTxt, pieceNumLab)
			    end
			else
				--未获得武将
				noGotLab:setVisible(true)
				starPanel:setVisible(false)

				local compoundNeedNum = ConfigDataManager:getInfoFindByOneKey(ConfigData.HeroPieceConfig, "compound", typeId).num

				local roleProxy = self:getProxy(GameProxys.Role)
				local playerGetNum = roleProxy:getRolePowerValue(GamePowerConfig.HeroFragment, typeId)
				suiLab:setString(self:getTextWord(420009))
				pieceNumLab:setVisible(true)
				pieceNumLabTxt:setVisible(true)
				pieceNumLab:setString("/" .. compoundNeedNum)
			    pieceNumLabTxt:setString(playerGetNum)
                if playerGetNum >= compoundNeedNum then
                    pieceNumLabTxt:setColor(ColorUtils.commonColor.c3bGreen)
                else
                    pieceNumLabTxt:setColor(ColorUtils.commonColor.c3bRed)
                end
                NodeUtils:alignNodeL2R(pieceNumLabTxt, pieceNumLab)
			end
			cell.typeid = typeId
        	self:addTouchEventListener(cell, self.onCellClicked)
        	local data = {}
            data.power = GamePowerConfig.Hero
			data.num = 1
            data.typeid = typeId
            if cell.uiIcon == nil then
                local uiIcon = UIIcon.new(cell,data,false, self)
                uiIcon:setPosition(iconImg:getPositionX(), iconImg:getPositionY())
                cell.uiIcon = uiIcon
            else
                cell.uiIcon:updateData(data)
                -- 设置文本
                nameLab:setString(data.name)
                nameLab:setColor(ColorUtils:getColorByQuality(data.color))
                -- memoTxt:setString(data.num)
            end

            -- memoTxt:setString(cell.uiIcon._data.num)

            -- 设置文本
            nameLab:setString(heroConfig.name)
            nameLab:setColor(ColorUtils:getColorByQuality(data.color))
        else
            if cell.uiIcon then
                cell.uiIcon:finalize()
                cell.uiIcon = nil
            end 
			cell:setVisible(false)
        end

    end 
end
function CookingSelectHeroPanel:registerEvents()
	CookingSelectHeroPanel.super.registerEvents(self)
	local sureBtn = self:getChildByName("mainPanel/sureBtn")
	self:addTouchEventListener(sureBtn, self.onSureBtnHandler)
end
--点击cell
function CookingSelectHeroPanel:onCellClicked(sender)
	if self._selectHeroTypeid == sender.typeid then
		return
	end
	self._selectHeroTypeid = sender.typeid
	if self._selectImg ~= nil and tolua.isnull(self._selectImg) == false then
		self._selectImg:setVisible(false)
	end
	self._selectImg = sender:getChildByName("selectImg")
	self._selectImg:setVisible(true)
	-- print(sender.typeid)
end 
--点击确认更换
function CookingSelectHeroPanel:onSureBtnHandler(sender)
	if self._selectHeroTypeid == nil then
		self:showSysMessage(self:getTextWord(420011))
	else
		if self.paymentType == 0 then
			local sendData = {}
			sendData.activityId = self.proxy:getCurActivityData().activityId
			sendData.pos = self.pos
			sendData.typeId = self._selectHeroTypeid
			self.proxy:onTriggerNet230033Req(sendData)
			--把选中框去掉
			if self._selectImg ~= nil and tolua.isnull(self._selectImg) == false then
				self._selectImg:setVisible(false)
			end
			self._selectHeroTypeid = nil
		else

	    	local roleProxy = self:getProxy(GameProxys.Role)
		    local curNum = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝
		    local needNum = ConfigDataManager:getConfigById(ConfigData.CookingWineConfig, self.proxy:getCurActivityData().effectId).changePrice
		    if needNum > curNum then
		        local parent = self:getParent()
		        local panel = parent.panel
		        if panel == nil then
		            local panel = UIRecharge.new(parent, self)
		            parent.panel = panel
		        else
		            panel:show()
		        end
		    else
	        	local function sureFun()
					local sendData = {}
					sendData.activityId = self.proxy:getCurActivityData().activityId
					sendData.pos = self.pos
					sendData.typeId = self._selectHeroTypeid
					self.proxy:onTriggerNet230033Req(sendData)
					--把选中框去掉
					if self._selectImg ~= nil and tolua.isnull(self._selectImg) == false then
						self._selectImg:setVisible(false)
					end
					self._selectHeroTypeid = nil
	        	end
	        	self:showMessageBox(string.format(self:getTextWord(420012),needNum),sureFun)
		    end
		end
	end
end 
--武将选择的排序,玩家已拥有在前，没拥有在后
function CookingSelectHeroPanel:sortAry(heroAry)
	local heroProxy = self:getProxy(GameProxys.Hero)
	local tempMap = {}
	for k,v in pairs(heroAry) do
		local status = heroProxy:findHeroWithTypeId(v)
		if status == true then
			tempMap[v] = 999 + v
		else
			tempMap[v] = v
		end	
	end
	
	local function sortFun( a,b )
		return tempMap[a] > tempMap[b]
	end

	table.sort(heroAry,sortFun)

end

