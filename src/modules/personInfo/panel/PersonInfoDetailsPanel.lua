--个人信息详细界面
--FZW 
--2015/11/20
PersonInfoDetailsPanel = class("PersonInfoDetailsPanel", BasicPanel)  
PersonInfoDetailsPanel.NAME = "PersonInfoDetailsPanel"

function PersonInfoDetailsPanel:ctor(view, panelName)
    PersonInfoDetailsPanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function PersonInfoDetailsPanel:finalize()
    if self._UIBuyEnergy ~= nil then
        self._UIBuyEnergy:finalize()
        self._UIBuyEnergy = nil
    end

    if self._buttonEfc ~= nil then
        self._buttonEfc:finalize()
        self._buttonEfc = nil
    end


    PersonInfoDetailsPanel.super.finalize(self)
end

function PersonInfoDetailsPanel:initPanel()
    PersonInfoDetailsPanel.super.initPanel(self)

    COLOR1 = 3 --军械icon边框颜色 蓝
    COLOR2 = 4 --统帅icon边框颜色 紫

    BR = self:getTextWord(50059)
    self._energyMoney = 5

    self._listview = self:getChildByName("ListView_1")

    local item = self._listview:getItem(0)
    self._listview:setItemModel(item)
    item:setVisible(false)
    self._roleProxy = self:getProxy(GameProxys.Role)   

    --讨伐令的进度条和数量和倒计时文本
    self.crusadeBarBg = self:getChildByName("Panel_42/crusadeBarBg")
    self.energyBar = self:getChildByName("Panel_42/crusadeBarBg/energyBar")
    self.cursadeNumLab = self:getChildByName("Panel_42/cursadeNumLab")
    self.cursadeTimeLab = self:getChildByName("Panel_42/cursadeTime")
    self.cursadeTimeLab:setVisible(false)





	-- 自适应    
    
    -- local panelBg = self:getChildByName("Panel_42")
    -- NodeUtils:adaptiveListView(panelBg,self._listview,tabsPanel)
    -- NodeUtils:adaptiveTopPanelAndListView(panelBg, self._listview, GlobalConfig.downHeight, tabsPanel)

end

function PersonInfoDetailsPanel:doLayout()
    local panelBg = self:getChildByName("Panel_42")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(panelBg, self._listview, GlobalConfig.downHeight, tabsPanel)

    --//null
    Panel_1=self:getChildByName("ListView_1"):getParent()
    if Panel_1:getPositionY() ~= 20 then
    Panel_1:setPositionY(20)
    end

end

function PersonInfoDetailsPanel:onShowHandler(info)
	-- body

    local worldPos = self:getChildByName("Panel_42/Label_pos")
    local legName = self._roleProxy:getLegionName()
    legName = legName == "" and self:getTextWord(3129) or legName
    worldPos:setString("("..legName..")")

	self:onDetailsInfo({})
    -- self:update()
    
    --打开的时候再自适应一遍，解决从别的Panel进入时，这个Panel没有自适应成功
    -- local tabsPanel = self:getTabsPanel()
    -- local panelBg = self:getChildByName("Panel_42")
    -- NodeUtils:adaptiveTopPanelAndListView(panelBg, self._listview, GlobalConfig.downHeight, tabsPanel)
    self._isAdaptive = true
    
end

function PersonInfoDetailsPanel:registerEvents()
    -- 手动升级按钮
    self._levelUpBtn = self:getChildByName("Panel_42/levelUpBtn")
    self:addTouchEventListener(self._levelUpBtn, self.roleLevelUp) 
end

function PersonInfoDetailsPanel:getAllRoleAttrValue()
	local data = {}
	local roleProxy = self._roleProxy
    data.exp = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_exp) or 0
    data.level = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level) or 0
    data.icon = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_icon) or 0
    data.vipLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel) or 0
    data.areaId = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_areaId) or 0--服务器id
    -- data.command = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)--带兵量
    data.energy = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_energy) or 0--体力
    data.mr = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_militaryRank)--军衔
    data.boom = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_boom) or 0--繁荣值（cur）
	data.boomUpLimit = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_boomUpLimit) or 0--繁荣值（max）
    data.boomLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_boomLevel) or 0--繁荣等级
    data.commandLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_commandLevel) or 0--统帅等级

    data.prestigeLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_prestigeLevel) or 0--声望等级
    data.cursade = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_crusadeEnergy) or 0 --讨伐令


    data.prestige = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_prestige) or 0--声望
    if data.prestige ~= 0 and data.prestigeLevel ~= 0 and data.prestigeLevel <= GlobalConfig.prestigeMaxLv then
		local info = ConfigDataManager:getConfigById(ConfigData.PrestigeLvConfig, data.prestigeLevel + 1)
		data.prestige = data.prestige - info.needmin
    end
    


    data.gold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--金币
    data.highestCapacity = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_highestCapacity) or 0--最高战力
    data.WorldTileX,data.WorldTileY = roleProxy:getWorldTilePos() --玩家坐标
    data.name = roleProxy:getRoleName()--玩家名称
    data.boombook = roleProxy:getRolePowerValue(GamePowerConfig.Item,4013) or 0--统率令

    data.prestageState = roleProxy:getPrestigeState() --声望领取状态

    -- self:showSysMessage("data.energy = "..data.prestageState)
    return data
end

-- 获取全部数据
function PersonInfoDetailsPanel:getAllData()
	-- body
    local data = {}
    data = self:getAllRoleAttrValue()
    self._CurBoom = data.boom
    self._MaxBoom = data.boomUpLimit
	
	return data
end

-- -- 来自20000更新
function PersonInfoDetailsPanel:onDetailsInfo(data)
	-- body
	-- local data = {}
 --    data = self:getAllRoleAttrValue()
 --    self._CurBoom = data.boom
 --    self._MaxBoom = data.boomUpLimit
 	local data = self:getAllData()
    self._CurEnergy = data.energy
    self._MaxEnergy = 20

    self:onPanelInfoDetails(data)
    self:onDetailsListInfo(data)	
end

-- 来自PROXY_UPDATE_ROLE_INFO更新
function PersonInfoDetailsPanel:onUpdateDetailsInfo()
	-- body
    -- local data = {}
    -- data = self:getAllRoleAttrValue()
    -- self._CurBoom = data.boom
    -- self._MaxBoom = data.boomUpLimit
    local data = self:getAllData()

    self:onPanelInfoDetails(data)
    self:onDetailsListInfo(data)
end

-- 来自购买体力的更新test
function PersonInfoDetailsPanel:onUpdateEnergyTest(addEnergy)
	-- body
	local data = {}
    data = self:getAllRoleAttrValue()
    data.energy = data.energy + addEnergy
    self:onPanelInfoDetails(data)
end

-- 统率升级成功飘字(20002协议比20000协议晚推送)
function PersonInfoDetailsPanel:onDetailsCommandResp()
    -- 统率升级成功飘字
    local roleProxy = self._roleProxy
    local commandLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_commandLevel)--统帅等级
    commandLevelNext = commandLevel + 1
    local info1 = ConfigDataManager:getInfoFindByOneKey(self._CmdConfig,"commandlv",commandLevelNext)
    
    local cmd = 0
    if commandLevel <= 0 then
        cmd = info1.command
    else
        local info2 = ConfigDataManager:getInfoFindByOneKey(self._CmdConfig,"commandlv",commandLevel)
        cmd = info1.command - info2.command
    end
    self:showSysMessage(string.format(self:getTextWord(540), cmd))
    self:showUpActionByItemIndex(2) 

end

-- 军衔升级成功飘字
function PersonInfoDetailsPanel:onDetailsMRResp()
    self:showSysMessage(self:getTextWord(537))
    self:showUpActionByItemIndex(0) 

end

--统率令更新：更新统率按钮（解决按钮更新问题：统率令不足）
function PersonInfoDetailsPanel:onUpdateCMDBook()
	-- 统率
	-- print("统率令更新 PersonInfoDetailsPanel:onUpdateCMDBook()--------A---")
	if self._cmdBtn ~= nil then
		local boombook = self._roleProxy:getRolePowerValue(GamePowerConfig.Item,4013) or 0--统率令 数量
		-- print("统率令更新 PersonInfoDetailsPanel:onUpdateCMDBook()--------B---",boombook)
		local tmpIndex = 2 --2=统率的panel
		local item = self._listview:getItem(tmpIndex)
		
		local itemBtn = item:getChildByName("itemBtn")
		local tipBtn = itemBtn:getChildByName("tipBtn")
        tipBtn:setTouchEnabled(false)
		local upBtn = itemBtn:getChildByName("upBtn")
		local upGreyBtn = itemBtn:getChildByName("upGreyBtn")

		self:stopButtonAction(upBtn)			
		tipBtn.cmdBook = boombook
		upBtn.boombook = boombook
		item.boombook = boombook
        self["btn3"] = upBtn --item --
		self["item" .. tmpIndex] = item

		if boombook < 1 then
	    	-- 统率令不足
			upGreyBtn:setVisible(false)
		else
	    	-- 统率令足够
            -- 添加等级限制判断
            -- 统率等级
            local commandLevel = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_commandLevel) or 0 
            -- 人物等级
            local level = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level) or 0
            if commandLevel < level then
    		    self:addButtonAction(upBtn)
			    upGreyBtn:setVisible(false)
            end
		end
	end

end


function PersonInfoDetailsPanel:onDetailsEnergyResp()
	-- body
	self._energyMoney = self._energyMoney + 5
	-- local _roleProxy = self:getProxy(GameProxys.Role)
--	_roleProxy:setEnergyNeedMoney(self._energyMoney)
end

-- 个人信息 上部分面板
function PersonInfoDetailsPanel:onPanelInfoDetails(data)
	self._CurEnergy = data.energy


    local cursade = data.cursade
    local maxCurSade = GlobalConfig.maxCrusadeEnergy
    self.cursadeNumLab:setString(cursade .. "/" .. maxCurSade)

    local toAlignNodes = {self.cursadeNumLab}--保存要对齐的节点

    local cursade = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_crusadeEnergy) or 0
    self.cursadeTimeLab:setVisible(cursade < GlobalConfig.maxCrusadeEnergy)
    if cursade < GlobalConfig.maxCrusadeEnergy then
        local timeKey = self._roleProxy:getTimeKey(PlayerPowerDefine.POWER_crusadeEnergy)
        local time = self._roleProxy:getRemainTime(timeKey)

        if time > 0 then
            self.cursadeTimeLab:setVisible(true) 
            time = TimeUtils:getStandardFormatTimeString8(time)
            self.cursadeTimeLab:setString("("..time..")")  
            NodeUtils:alignNodeL2R(self.cursadeNumLab,self.cursadeTimeLab)
            -- NodeUtils:centerNodes(self.crusadeBarBg, {self.cursadeNumLab,self.cursadeTimeLab})
            table.insert(toAlignNodes,self.cursadeTimeLab)
        else
            self.cursadeTimeLab:setVisible(false) 
        end

    end
    NodeUtils:centerNodes(self.crusadeBarBg, toAlignNodes)

    local percent = cursade / maxCurSade * 100
    percent = percent > 100 and 100 or percent
    self.energyBar:setPercent(percent)   

    -- 玩家战力
    local fightImg = self:getChildByName("Panel_42/fightImg")
    local fightValue = self:getChildByName("Panel_42/fightValue")
    local Image_head = self:getChildByName("Panel_42/Image_head")

    fightValue:setString(StringUtils:formatNumberByK3(data.highestCapacity, nil))

    -- 玩家最大带兵
    local troopsMaxTxt = self:getChildByName("Panel_42/troopsMaxTxt")
    troopsMaxTxt:setString(self._roleProxy:maxCommandCount())

    -- 玩家名称
    local name = self:getChildByName("Panel_42/Label_name")
    name:setString(data.name)
    
    -- 玩家军团
    local worldPos = self:getChildByName("Panel_42/Label_pos")
    -- worldPos:setString("("..data.WorldTileX..","..data.WorldTileY..")")
    local legName = self._roleProxy:getLegionName()
    legName = legName == "" and self:getTextWord(3129) or legName
    worldPos:setString("("..legName..")")

    -- 军团文本对齐
    -- local size = name:getContentSize()
    -- local posx = name:getPositionX()
    -- local x = posx + size.width + 2
    -- worldPos:setPositionX(x)

    -- 头像
    self:onRoleHeadUpdate()

    -- VIP等级
    local Image_vip = self:getChildByName("Panel_42/Image_vip")
    local vipTxt = self:getChildByName("Panel_42/vipTxt")
    vipTxt:setString(data.vipLevel)

    -- VIP文本自适应对齐
    -- local Image_head = self:getChildByName("Panel_42/Image_head")
    -- local posx = Image_head:getPositionX()
    -- local sizeL = Image_vip:getContentSize()
    -- local sizeR = vipTxt:getContentSize()
    -- local allLen = sizeL.width + sizeR.width
    -- local x1 = posx/2 - (allLen/2 - sizeL.width/2) + 4
    -- local x2 = x1 + sizeL.width + 8
    -- Image_vip:setPositionX(x1)
    -- vipTxt:setPositionX(x2)
    -- print("allLen="..allLen..",sizeL.width="..sizeL.width..",sizeR.width="..sizeR.width..",posx="..posx)

    -- 玩家等级
    local lv = self:getChildByName("Panel_42/Label_lv")

    lv:setString(string.format(self:getTextWord(529),data.level))
    --NodeUtils:fixTwoNodePos(name, lv, 5)

    local curExp = 0
    local maxExp = 0
    local barPer = 0
    self._CmderConfig = "CommanderConfig"
    
    if data.level > 0 then
        local conf = ConfigDataManager:getConfigById(self._CmderConfig,data.level)
        curExp = data.exp
        maxExp = conf.exp
        barPer = curExp/maxExp*100
        if curExp >= maxExp then
            barPer = 100
        end
    end
--    	logger:error("---------玩家等级错误!!!等级不能是 %d----------",data.level)
--      logger:error("---------玩家等级错误!!!等级不能是 %d----------",data.level)
--      logger:error("---------当前最高等级是: %d----------",self._roleProxy:getRoleMaxLevel())
--      logger:error("---------当前最高等级是: %d----------",self._roleProxy:getRoleMaxLevel())

    self._curExp = curExp
    self._maxExp = maxExp

    -- 是否开放手动升级
    self._levelUpBtn:setVisible(self:isShowLevelUpBtn(data.level))
    NodeUtils:setEnable(self._levelUpBtn, curExp >= maxExp)

    -- 经验条
    local expBarBg = self:getChildByName("Panel_42/expBarBg")
    local expBar = self:getChildByName("Panel_42/expBarBg/expBar")
    expBar:setPercent(barPer)
    -- expBar:setVisible(false)

    -- 经验值
    local curExpSprite = self:getChildByName("Panel_42/curExp")
    local maxExpSprite = self:getChildByName("Panel_42/maxExp")
    -- curExpSprite:setString(curExp)
    -- maxExpSprite:setString("/"..maxExp)
    curExpSprite:setString(StringUtils:formatNumberByK4Ceil(curExp))
    maxExpSprite:setString("/".. StringUtils:formatNumberByK4Ceil(maxExp))
    NodeUtils:alignNodeR2L(curExpSprite,maxExpSprite)
    NodeUtils:centerNodes(expBarBg, {curExpSprite,maxExpSprite})

    -- -- 体力条
    local energyBar = self:getChildByName("Panel_42/energyBarBg/energyBar")
    local energyPer = nil
    if data.energy > 20 then
    	energyPer = 100
    else
    	energyPer = data.energy/20*100
    end
    energyBar:setPercent(energyPer)
    -- energyBar:setVisible(false)

    -- 体力值
    local curEnergy = self:getChildByName("Panel_42/curEnergy")
    local maxEnergy = self:getChildByName("Panel_42/maxEnergy")
    curEnergy:setString(data.energy)
    -- energy:setString("/".."20")


    -- 体力倒计时
    local energy_time = self:getChildByName("Panel_42/energyTime")
    local energyBarBg = self:getChildByName("Panel_42/energyBarBg")
    if data.energy < 20 then
	    energy_time:setVisible(true)
	    local remainTime = self:getEnergyRemainTime()
	    remainTime = TimeUtils:getStandardFormatTimeString8(remainTime)
	    energy_time:setString("("..remainTime..")")

    	-- 文本自适应对齐	
		-- local size = energy:getContentSize()
		-- local x = energy:getPositionX()
		-- x = x + size.width/2 + 2
		-- energy_time:setPositionX(x)
        NodeUtils:alignNodeL2R(curEnergy,maxEnergy,energy_time)
        NodeUtils:centerNodes(energyBarBg, {curEnergy,maxEnergy,energy_time})

	else
		energy_time:setVisible(false)
        NodeUtils:alignNodeR2L(curEnergy,maxEnergy)
        NodeUtils:centerNodes(energyBarBg, {curEnergy,maxEnergy})
	end
	
	
    local score_value = self:getChildByName("Panel_42/Label_score_value")-- 战绩
    -- local union_value = self:getChildByName("Panel_42/Label_union_value")-- 军团

    local roleProxy = self._roleProxy
    local legionId = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_LegionId)
    local honour = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_honour)
    
    score_value:setString(honour)

    local str = ""
    if legionId <= 0 then
    	str = self:getTextWord(3123)
    else
	    local legionProxy = self:getProxy(GameProxys.Legion)     
	    local mineInfo = legionProxy:getMineInfo()        
		if mineInfo ~= nil then
			str = mineInfo.name
		else
			str = self:getTextWord(3123)	
			legionProxy:onTriggerNet220200Req()
		end
    end
    -- union_value:setString(str)
    self._union_value = worldPos

	-- 购买体力按钮
    local btnPower = self:getChildByName("Panel_42/Button_110")
    self:addTouchEventListener(btnPower,self.onTouchEnergyBuy)
    
    
end

-- 军团信息更新
function PersonInfoDetailsPanel:onLegionInfoUpdate()
	-- body
    local legionProxy = self:getProxy(GameProxys.Legion)     
    local mineInfo = legionProxy:getMineInfo()        
	str = mineInfo.name	
    str = str == "" and self:getTextWord(3129) or str
	self._union_value:setString("("..str..")")
end

-- -- 个人信息的列表
-- function PersonInfoDetailsPanel:onDetailsListInfo(data)
-- 	for index=0,3 do
-- 		local item = self._listview:getItem(index)
-- 		if item == nil then 
-- 			self._listview:pushBackDefaultItem()
-- 			item = self._listview:getItem(index)
-- 		end
-- 		self:registerItemEvents(item,data,index)
-- 	end
-- end

-- 个人信息的列表
function PersonInfoDetailsPanel:onDetailsListInfo(data)
	for index=0,3 do
		self:updateOneItemView(data, index) 
	end
end

-- 是否显示手动升级按钮
function PersonInfoDetailsPanel:isShowLevelUpBtn(lv)
    local configInfo = ConfigDataManager:getConfigById(ConfigData.NewFunctionOpenConfig, 56)
    local openLevel = configInfo.need
    return lv >= openLevel
end


-- 按钮动画
function PersonInfoDetailsPanel:addButtonAction(sprite)
    local ccbLayer = sprite.ccbLayer
    if ccbLayer == nil then
        local ccbLayer = self:createUICCBLayer("rgb-button-efc", sprite)        
        -- local ccbLayer = UICCBLayer.new("rgb-grade-promotion", sprite)        
        local size = sprite:getContentSize()
        ccbLayer:setPosition(size.width/2,size.height/2)
        sprite.ccbLayer = ccbLayer
        self._buttonEfc = ccbLayer
    else
        ccbLayer:setVisible(true)
    end    

end

function PersonInfoDetailsPanel:stopButtonAction(sprite)
    if sprite.ccbLayer ~= nil then
        sprite.ccbLayer:setVisible(false)
    end
end

function PersonInfoDetailsPanel:showUpActionByItemIndex( index )
    local item = self._listview:getItem(index)
    if item == nil then 
        self._listview:pushBackDefaultItem()
        item = self._listview:getItem(index)
    end
    self:showUpAction(item)
end

-- 官职、统率icon播放升级特效
function PersonInfoDetailsPanel:showUpAction( itempanel )
    -- body
    local iconEffect = itempanel.iconEffect
    if iconEffect ~= nil then
        iconEffect:finalize()
    end
    
    local itemBtn = itempanel:getChildByName("itemBtn")
    local iconImg = itemBtn:getChildByName("iconImg")
    iconEffect = UICCBLayer.new("rpg-button", iconImg)
    local size = iconImg:getContentSize()
    iconEffect:setPosition(size.width/2, size.height/2)
    itempanel.iconEffect = iconEffect
end

-- 个人信息的列表
function PersonInfoDetailsPanel:registerItemEvents(item,data,index)
	if item == nil or data == nil then
		return
	end
	item.index = index
	item:setVisible(true)
	item:setTouchEnabled(true)
	
	self["item" .. index] = item

	self._MRConfig = ConfigData.MilitaryRankConfig
	self._BoomConfig = ConfigData.BoomLevelConfig
	self._PresConfig = ConfigData.PrestigeLvConfig
	self._CmdConfig = ConfigData.CommandLvConfig

	local itemBtn = item:getChildByName("itemBtn")
	local Label_name = itemBtn:getChildByName("Label_name")

	-- 军衔
	if index == 0 then
        local Label_detail = itemBtn:getChildByName("Label_detail")
		local Label_info = itemBtn:getChildByName("Label_info")
		local tipBtn = itemBtn:getChildByName("tipBtn")
        tipBtn:setTouchEnabled(false)
		local upBtn = itemBtn:getChildByName("upBtn")
		local upGreyBtn = itemBtn:getChildByName("upGreyBtn")

		self:stopButtonAction(upBtn)
		local info = ConfigDataManager:getConfigById(self._MRConfig,data.mr)
		
		local iconInfo = {}
		iconInfo.power = GamePowerConfig.Other
		iconInfo.typeid = info.icon
		iconInfo.num = 0
        iconInfo.color= info.quality

	    local icon = item.icon
	    if icon == nil then
			local iconImg = itemBtn:getChildByName("iconImg")
	        icon = UIIcon.new(iconImg,iconInfo,false)
	        -- icon = UIIcon.new(iconImg,iconInfo,false,nil,nil,nil,nil,COLOR1)
	        
	        item.icon = icon
	    else
	        icon:updateData(iconInfo)
	    end
	    icon:setTouchEnabled(false)  --自身不响应触摸事件，将触摸事件传递给父级节点

		Label_name:setString(info.name)
        Label_detail:setString(string.format(self:getTextWord(509),info.prestige))
		Label_info:setString(info.info)
		
		local roleProxy = self._roleProxy
    	local tael = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_tael) or 0

		if info.captainLv == 0 then
			-- 军衔满级
			local str = self:getTextWord(549)
			upGreyBtn:setVisible(false)
            NodeUtils:setEnable(upBtn,false)
			-- upBtn.index = index
			-- upBtn.str = str
			-- self:addTouchEventListener(upBtn,self.onTouchBlackItemBtn)

		elseif data.level < info.captainLv then
			-- 等级不足
			local str = string.format(self:getTextWord(548), info.captainLv)
            upGreyBtn:setVisible(false)
            NodeUtils:setEnable(upBtn,false)
			-- upBtn.index = index
			-- upBtn.str = str
			-- self:addTouchEventListener(upBtn,self.onTouchBlackItemBtn)

		elseif tael < info.crysneed then
			-- 银两不足
			local str = self:getTextWord(547)
			upGreyBtn:setVisible(false)
            NodeUtils:setEnable(upBtn,false)
			-- upBtn.index = index
			-- upBtn.str = str
			-- self:addTouchEventListener(upBtn,self.onTouchBlackItemBtn)

		else
			-- 正常状态
            upGreyBtn:setVisible(false)
            NodeUtils:setEnable(upBtn,true)
            self:addButtonAction(upBtn)
			upBtn.index = index
			self:addTouchEventListener(upBtn,self.onTouchItemBtnCallBack)
			
		end

		self:adaptiveTipBtnPosX(Label_name,tipBtn)
		itemBtn.index = index
		itemBtn.mr = data.mr
		itemBtn.level = data.level
		self:addTouchEventListener(itemBtn,self.onTouchTipBtnCallBack)

	end

	-- 繁荣
	if index == 1 then
		local Label_detail122 = itemBtn:getChildByName("Label_detail122")
		local Label_detail123 = itemBtn:getChildByName("Label_detail123")
		local Label_detail123R = itemBtn:getChildByName("Label_detail123R")
		local Label_detail124 = itemBtn:getChildByName("Label_detail124")
		local tipBtn = itemBtn:getChildByName("tipBtn")
        tipBtn:setTouchEnabled(false)
		local upBtn = itemBtn:getChildByName("upBtn")
		-- local upGreyBtn = itemBtn:getChildByName("upGreyBtn")
        local labLv = itemBtn:getChildByName("labLv")

		self:stopButtonAction(upBtn)
		local iconInfo = {}
		iconInfo.power = GamePowerConfig.Other
		iconInfo.typeid = 10205
		iconInfo.num = 0

	    local icon = item.icon
	    if icon == nil then
			local iconImg = itemBtn:getChildByName("iconImg")
	        icon = UIIcon.new(iconImg,iconInfo,false)
	        
	        item.icon = icon
	    else
	        icon:updateData(iconInfo)
	    end
	    icon:setTouchEnabled(false)

		local info = ConfigDataManager:getInfoFindByOneKey(self._BoomConfig,"boomlv",data.boomLevel)
		-- Label_name:setString(string.format(self:getTextWord(513),data.boomLevel))
        Label_name:setString(string.format(self:getTextWord(513)))
		-- Label_detail122:setString(self:getTextWord(511)..info.command)
        labLv:setString(string.format("Lv.%d",data.boomLevel))
		Label_detail122:setString("+"..info.command)
        Label_detail122:setColor(ColorUtils.wordGoodColor)  
		-- print("繁荣 带兵量+"..info.command)

		-- Label_detail123:setString(self:getTextWord(512)..data.boom.."/"..data.boomUpLimit)
		Label_detail123:setString(data.boom)
		Label_detail123R:setString("/"..data.boomUpLimit)

		local posx = Label_detail123:getPositionX()
		local size = Label_detail123:getContentSize()
		local x = posx + size.width
		Label_detail123R:setPositionX(x)		

		-- 获取繁荣度状态
		local roleProxy = self._roleProxy
		local isDestroy,destroyBoom = roleProxy:getBoomState()
		if isDestroy == true then
		    Label_detail123:setColor(ColorUtils.wordRedColor)
		else
		    Label_detail123:setColor(ColorUtils.wordGoodColor)          --//null 字体颜色统一暗绿 原先的 ColorUtil.wordGreenColor弃用
		end

		if data.boom >= data.boomUpLimit then
			-- 若b = c，则提升按钮改为灰色不可点击
			Label_detail124:setVisible(false)
			
		    NodeUtils:setEnable(upBtn,false)
   --          upBtn.boom = data.boom
   --          upBtn.boomUpLimit = data.boomUpLimit
   --          upBtn.index = index
			-- self:addTouchEventListener(upBtn,self.onTouchBtnBuyBoom)


		else
			-- 若b＜c时，d才显示，提升按钮弹窗购买繁荣度
			local remainTime = self:getBoomRemainTime()
			remainTime = TimeUtils:getStandardFormatTimeString8(remainTime)
		    Label_detail124:setString("("..remainTime..")")
		    Label_detail124:setColor(ColorUtils.commonColor.Red) --倒计时红色
			-- 文本自适应对齐
			local size = Label_detail123R:getContentSize()
			local x = Label_detail123R:getPositionX()
			x = x + size.width + 0
			Label_detail124:setPositionX(x)

		    -- upGreyBtn:setTouchEnabled(false)
			-- upGreyBtn:setVisible(false)

			upBtn.boom = data.boom
			upBtn.boomUpLimit = data.boomUpLimit
			upBtn.index = index

            NodeUtils:setEnable(upBtn,true)
			self:addTouchEventListener(upBtn,self.onTouchBtnBuyBoom)
		end

		-- self:adaptiveTipBtnPosX(Label_name,tipBtn)
        NodeUtils:alignNodeL2R(Label_name,labLv,tipBtn)
		itemBtn.index = index
		itemBtn.boomlv = data.boomLevel
		self:addTouchEventListener(itemBtn,self.onTouchTipBtnCallBack)

	end

	-- 声望
	if index == 3 then
		local tmpIndex = 2
		local Image_97 = itemBtn:getChildByName("Image_97")
		local ProgressBar_98 = Image_97:getChildByName("ProgressBar_98")
		local Label_99 = ProgressBar_98:getChildByName("Label_99")
		local tipBtn = itemBtn:getChildByName("tipBtn")
        tipBtn:setTouchEnabled(false)
		local upBtn = itemBtn:getChildByName("upBtn") --可以升级按钮
		-- local upGreyBtn = itemBtn:getChildByName("upGreyBtn") --不可升级按钮
		local Label_max = itemBtn:getChildByName("Label_max")
        local labLv = itemBtn:getChildByName("labLv")--等级

		self:stopButtonAction(upBtn)
		local iconInfo = {}
		iconInfo.power = GamePowerConfig.Other
		iconInfo.typeid = 10521
		iconInfo.num = 0
        iconInfo.color = 4

	    local icon = item.icon
	    if icon == nil then
			local iconImg = itemBtn:getChildByName("iconImg")
	        icon = UIIcon.new(iconImg,iconInfo,false)
	        
	        item.icon = icon
	    else
	        icon:updateData(iconInfo)
	    end
	    icon:setTouchEnabled(false)

		local info = ConfigDataManager:getInfoFindByOneKey(self._PresConfig,"prestigelv",data.prestigeLevel)
		-- Label_name:setString(string.format(self:getTextWord(514),data.prestigeLevel))
        Label_name:setString(string.format(self:getTextWord(514)))
        labLv:setString(string.format("Lv.%d",data.prestigeLevel))


		-- local maxLv = 80 --声望最高级
		local isMaxLv = false
		if data.prestigeLevel >= GlobalConfig.prestigeMaxLv then
			-- 满级
			isMaxLv = true

			Label_max:setString(self:getTextWord(553))
			Label_max:setVisible(true)
			Image_97:setVisible(false)
			ProgressBar_98:setVisible(false)
			Label_99:setVisible(false)
		else
			-- 未满级
			Label_max:setVisible(false)
			Image_97:setVisible(true)
			ProgressBar_98:setVisible(true)
			Label_99:setVisible(true)
			ProgressBar_98:setPercent(data.prestige/info.prestigeneed*100)
			-- print("data.prestige=====",data.prestige)
			Label_99:setString(data.prestige.."/"..info.prestigeneed)

		end

		-- self:adaptiveTipBtnPosX(Label_name,tipBtn)
        NodeUtils:alignNodeL2R(Label_name,labLv,tipBtn)
		itemBtn.index = tmpIndex
		self:addTouchEventListener(itemBtn,self.onTouchTipBtnCallBack)

		if data.prestageState ~= nil and data.prestageState == 1 then
			-- 已封赏
			-- upBtn.isMaxLv = isMaxLv
			-- upBtn.index = tmpIndex
			-- self:addTouchEventListener(upBtn,self.onTouchItemBtnCallBack)

		elseif data.prestageState ~= nil and data.prestageState == 0 then
			-- 未封赏
			self:addButtonAction(upBtn)
			
            -- upBtn.isMaxLv = isMaxLv
            -- upBtn.index = tmpIndex
            -- self:addTouchEventListener(upBtn,self.onTouchItemBtnCallBack)
        end
		upBtn.isMaxLv = isMaxLv
		upBtn.index = tmpIndex
		self:addTouchEventListener(upBtn,self.onTouchItemBtnCallBack)

	end

	-- 统率
	if index == 2 then
		local tmpIndex = 3
		local Label_128 = itemBtn:getChildByName("Label_128")
		local Label_128R = itemBtn:getChildByName("Label_128R")
		local tipBtn = itemBtn:getChildByName("tipBtn")
        tipBtn:setTouchEnabled(false)
		local upBtn = itemBtn:getChildByName("upBtn")
		local upGreyBtn = itemBtn:getChildByName("upGreyBtn")
        local labLv = itemBtn:getChildByName("labLv")



		local iconInfo = {}
		iconInfo.power = GamePowerConfig.Other
		iconInfo.typeid = 10206
		iconInfo.num = 0

	    local icon = item.icon
	    if icon == nil then
			local iconImg = itemBtn:getChildByName("iconImg")
	        icon = UIIcon.new(iconImg,iconInfo,false,nil,nil,nil,nil,COLOR2)
	        item.icon = icon
	    else
	        icon:updateData(iconInfo)
	    end
		icon:setTouchEnabled(false)

		-- Label_name:setString(string.format(self:getTextWord(515),data.commandLevel))
        Label_name:setString(string.format(self:getTextWord(515)))

        labLv:setString(string.format("Lv.%d",data.commandLevel))

	    if data.commandLevel < 0 or data.commandLevel > GlobalConfig.commandMaxLv then
			logger:error("---------统率等级错误!!!等级不能是%d----------",data.commandLevel)
	    else  
            local info = ConfigDataManager:getInfoFindByOneKey(self._CmdConfig,"commandlv",data.commandLevel)
		    local conf = ConfigDataManager:getConfigById(self._CmderConfig,data.level)
		    
		    Label_128:setString(conf.command)
		    Label_128R:setString("+"..info.command)
		    -- print("统帅 带兵量+"..info.command)

		    local posx = Label_128:getPositionX()
		    local size = Label_128:getContentSize()
		    local x = posx + size.width
		    Label_128R:setPositionX(x)

		    upBtn.index = tmpIndex
		    upBtn.boombook = data.boombook
		    upBtn.price = info.price
		    upBtn.cmdlevel = data.commandLevel
		    upBtn.level = data.level
		    item.price = info.price
		    item.boombook = data.boombook
		    item.cmdlevel = data.commandLevel
		    item.level = data.level
		    item.index = tmpIndex
		    self:addTouchEventListener(upBtn,self.onTouchBtnCallBack3)
		    -- self:addTouchEventListener(item,self.onTouchItemCallBack)

            self["btn3"] = upBtn
		    
		    
		    if data.level <= data.commandLevel or data.boombook < 1 then
		    	-- 升级需求不足                
		        self:stopButtonAction(upBtn)
		    else
		    	-- 升级需求足够
	        	self:addButtonAction(upBtn)
		    end

            if data.commandLevel >= data.level then
	        	-- 统率等级==主公等级 不可升级
		    	NodeUtils:setEnable(upBtn,false)
		    else
		    	NodeUtils:setEnable(upBtn,true)
            end
	    end

	    -- self:adaptiveTipBtnPosX(Label_name,tipBtn)
        NodeUtils:alignNodeL2R(Label_name,labLv,tipBtn)
		itemBtn.index = tmpIndex
		itemBtn.cmdlv = data.commandLevel
		itemBtn.cmdBook = data.boombook
		itemBtn.level = data.level
		self:addTouchEventListener(itemBtn,self.onTouchTipBtnCallBack)

	end

end

function PersonInfoDetailsPanel:adaptiveTipBtnPosX(nameLabel,tipBtn)
	-- body

	if nameLabel ~= nil and tipBtn ~= nil then
		-- tipBtn坐标偏移
		-- logger:info("-- tipBtn坐标偏移 00")
		local size = nameLabel:getContentSize()
		local x = nameLabel:getPositionX() + size.width + 20
		tipBtn:setPositionX(x)
		tipBtn:setTouchEnabled(false)
	end
end
-- -- 刷新声望按钮 没有用到
-- function PersonInfoDetailsPanel:onUpdateItem(data)
-- 	local index = 2
-- 	local item = self._listview:getItem(index)
-- 	if item == nil then 
-- 		self._listview:pushBackDefaultItem()
-- 		item = self._listview:getItem(index)
-- 	end
-- 	self:registerItemEvents(item,data,index)
-- end


-- 点击灰色按钮
function PersonInfoDetailsPanel:onTouchBlackItemBtn(sender)
	-- body
	local index = sender.index
	local str = sender.str

	if index == 0 then
		self:showSysMessage(str)
	elseif index == 1 then
		self:showSysMessage(str)
	elseif index == 2 then
		self:showSysMessage(str)
	elseif index == 3 then
		self:showSysMessage(str)
	end

end

--  购买统率令升级 对话框
function PersonInfoDetailsPanel:MessageBox(sender)
	-- body
	local function okCallBack()
		local function callFunc()
			local data = {}
			data.type = 1
			data.index = sender.index
			self.view:onSendItemBtn(data)			
		end
		sender.callFunc = callFunc
		sender.money = sender.price
		self:isShowRechargeUI(sender)
	end
	local content = string.format(self:getTextWord(531),sender.price)
	self:showMessageBox(content,okCallBack)

end

-- 购买繁荣
function PersonInfoDetailsPanel:onTouchBtnBuyBoom(sender)
	-- body
	if sender.boom >= sender.boomUpLimit then
		self:showSysMessage(self:getTextWord(534))
		return
	end



-- -- a.     繁荣度上限*0.41 ＜ 600时，废墟取该值，当前繁荣度小于（繁荣度上限*0.41）为废墟状态
-- -- b.     繁荣度上限*0.41 ≥ 600时，废墟值取600，当前繁荣度小于600为废墟状态
	local curBoom = sender.boom
	local maxBoom = sender.boomUpLimit

	-- 获取繁荣度状态
	local roleProxy = self:getProxy(GameProxys.Role)
	local isDestroy,destroyBoom = roleProxy:getBoomState()
	-- print("废墟值 destroyBoom="..destroyBoom)

	local money = 0
	if isDestroy then
		-- 废墟花费
		money = math.ceil((destroyBoom - curBoom)*0.02)
        money = money * 2
--		money = money + math.ceil((maxBoom - destroyBoom)*0.02)
	else
		-- 正常恢复花费
		money = math.ceil((maxBoom - curBoom)*0.02)
	end
	logger:info("curBoom="..curBoom..",maxBoom="..maxBoom..",destroyBoom="..destroyBoom..",boom money = "..money)


    local function okCallBack()
		local function func()
			local data = {}
			data.index = sender.index
			self.view:onSendItemBtn(data)
		end

		sender.money = money
		sender.callFunc = func
		self:isShowRechargeUI(sender)
    end
    local function cancelCallBack()
    end
	    
    local content = string.format(self:getTextWord(530),money)
    self:showMessageBox(content,okCallBack)
end

-- 是否弹窗元宝不足
function PersonInfoDetailsPanel:isShowRechargeUI(sender)
	-- body
	local needMoney = sender.money

	local roleProxy = self._roleProxy
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

-- 点击统率升级按钮
function PersonInfoDetailsPanel:onTouchBtnCallBack3(sender)
	-- body
	-- print("统率升级···sender.boombook="..sender.boombook)
	
	local boombook = self._roleProxy:getRolePowerValue(GamePowerConfig.Item,4013) or 0--统率令

	if sender.index == 3 and boombook > 0 then
		self._cmdBtn = sender
		local data = {}
		data.type = 0
		data.index = sender.index
		-- self.view:onSendItemBtn(data)

		TimerManager:addOnce(30, self.onSendCMDItemBtn, self, data)
	elseif sender.index == 3 and boombook <= 0 then
		self._cmdBtn = sender
		self:MessageBox(sender)
	end
end

function PersonInfoDetailsPanel:onSendCMDItemBtn(data)
	-- body
	self.view:onSendItemBtn(data)	
end


-- 点击购买体力按钮 判定是否弹框
function PersonInfoDetailsPanel:onTouchEnergyBuy(sender)
	-- self.view:onSendCanEnergyBuy({})

	-- local function callFunc()
	-- 	self.view:onSendCanEnergyBuy({})
	-- end
	-- sender.callFunc = callFunc
	-- sender.money = self._energyMoney
	-- self:isShowRechargeUI(sender)
	-- local roleProxy = self._roleProxy

    -- self._roleProxy:getBuyEnergyBox(self)
    if self._UIBuyEnergy == nil then
        self._UIBuyEnergy = UIBuyEnergy.new(self,false)
    else
        self._UIBuyEnergy:show()
    end
    -- local panel = self:getPanel(PersonInfoBuyPanel.NAME)
    -- panel:show()

end

-- 购买体力弹框
function PersonInfoDetailsPanel:onEnergyBuy()
    -- local roleProxy = self._roleProxy
	self._energyMoney = self._roleProxy:getEnergyNeedMoney()

    local function okCallBack()
   		-- local function callFunc()
   		-- 	self.view:onSendEnergyBuy({})
   		-- end
   		-- sender.callFunc = callFunc
   		-- sender.money = self._energyMoney
   		-- self:isShowRechargeUI(sender)

   		self.view:onSendEnergyBuy({})
    end

    local content = string.format(self:getTextWord(507),self._energyMoney)
    self:showMessageBox(content,okCallBack)
end

------
-- 点击手动升级
function PersonInfoDetailsPanel:roleLevelUp(sender)
    if self._curExp < self._maxExp then
        self:showSysMessage(self:getTextWord(510000))
        return
    end 
    self._roleProxy:onTriggerNet20808Req()
end


-- 军衔tip
function PersonInfoDetailsPanel:onTipContentMR(lv,mr)
	-- body
	local content1 = ""
	local content2 = ""
	local content3 = ""
	local content4 = ""
	local content5 = ""
    local content6 = ""
    local content7 = ""
	local content8 = ""
	local info,tabLength = ConfigDataManager:getConfigById2(self._MRConfig,mr)
	local needLv = info.captainLv
	local crysneed = info.crysneed
	content1 = info.name
	content2 = string.format(self:getTextWord(509),info.prestige)

    local CurActiveadd = StringUtils:jsonDecode(info.activeadd)

	local color1 = ColorUtils.commonColor.Green
	local color2 = ColorUtils.commonColor.Green

	if mr ~= nil and mr < tabLength then
		info = ConfigDataManager:getConfigById(self._MRConfig,mr+1)
		content3 = info.name
		content4 = string.format(self:getTextWord(509),info.prestige)
		content5 = string.format(self:getTextWord(50005),needLv)
        content6 = string.format(self:getTextWord(50006),crysneed)

        local NextActiveadd = StringUtils:jsonDecode(info.activeadd)
        content7 = string.format(self:getTextWord(50061),CurActiveadd[1][2])
		content8 = string.format(self:getTextWord(50061),NextActiveadd[1][2])

        
        if lv < needLv then
            color1 = ColorUtils.commonColor.Red
        end
    	local tael = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_tael) or 0
		if tael < crysneed then
			color2 = ColorUtils.commonColor.Red
		end

	else
		content3 = self:getTextWord(50007)  --当前已是最高官职等级！
	end


	local parent = self:getParent()
    local uiTip = UITip.new(parent)
    uiTip:setTitle(self:getTextWord(50206))
    local line1 = {{content = self:getTextWord(50000), foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.FuBiaoTi}, {content = content1, foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.White}}
    local line2 = {{content = self:getTextWord(50001), foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.FuBiaoTi}, {content = content2, foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.MiaoShu}}
    local line3 = {{content = self:getTextWord(50002), foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.FuBiaoTi}, {content = BR..content3, foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.White}}
    local line4 = {{content = self:getTextWord(50003), foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.FuBiaoTi}, {content = content4, foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.MiaoShu}}
    local line5 = {{content = self:getTextWord(50004), foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.FuBiaoTi}, {content = BR..content5, foneSize = ColorUtils.tipSize16, color = color1}}
    local line6 = {{content = content6, foneSize = ColorUtils.tipSize16, color = color2}}
    local line7 = {{content = self:getTextWord(50060), foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.FuBiaoTi}, {content = content7, foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.MiaoShu}}
    local line8 = {{content = self:getTextWord(50062), foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.FuBiaoTi}, {content = content8, foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.MiaoShu}}

    local lines = {}
    table.insert(lines, line1)
    table.insert(lines, line2)
    table.insert(lines, line7)	    
    table.insert(lines, line3)      
    table.insert(lines, line4)	    
    table.insert(lines, line8)	    
    table.insert(lines, line5)      
    table.insert(lines, line6)      
    uiTip:setAllTipLine(lines)	
end

-- 繁荣tip
function PersonInfoDetailsPanel:onTipContentBoom(boomlv)
	-- body
	local info,lastData = ConfigDataManager:getInfoFindByOneKey2(self._BoomConfig,"boomlv",boomlv)

	-- local content1 = string.format(self:getTextWord(50027),boomlv,info.numneed) --繁荣要求2000

	--繁荣0级 繁荣要求(0)
	local content1 = self:getTextWord(50042)
	local content101 = boomlv
	local content102 = self:getTextWord(50043)
	local content103 = info.numneed
	local content104 = self:getTextWord(50044)

	 --带兵量+000
	local content2 = self:getTextWord(50040)
	local content002 = string.format(self:getTextWord(50041),info.command)

	--编制经验+0%
	-- local content3 = self:getTextWord(50045)
	-- local content301 = string.format(self:getTextWord(50046),math.floor(info.estExpAddRate)) --编制经验+12%

	-- 纯文本
	local content4 = self:getTextWord(50029)
	local content5 = self:getTextWord(50030)
	local content6 = self:getTextWord(50031)
	local content7 = self:getTextWord(50032)
	local content8 = self:getTextWord(50033)
	local content9 = self:getTextWord(50034)
	local content10 = self:getTextWord(50035)
	local content11 = self:getTextWord(50036)
	local content12 = self:getTextWord(50037)
	local content13 = self:getTextWord(50023)
	local content14 = self:getTextWord(50024)
	local content15 = self:getTextWord(50025)
	local content16 = self:getTextWord(50026)

	-- 下一等级
	local content21 = self:getTextWord(50038)
	local content22 = ""
	local content23 = ""
	local content24 = ""
	local content2202 = ""
	local content2301 = ""
	local content2401 = ""
	local content2402 = ""
	local content2403 = ""
	local content2404 = ""

	if boomlv < lastData.boomlv then
		local lv = boomlv + 1
		local info2 = ConfigDataManager:getInfoFindByOneKey(self._BoomConfig,"boomlv",lv)

		--繁荣0级 繁荣要求(0)
		content24 = self:getTextWord(50042)
		content2401 = lv
		content2402 = self:getTextWord(50043)
		content2403 = info2.numneed
		content2404 = self:getTextWord(50044)

		 --带兵量+000
		content22 = self:getTextWord(50040)
		content2202 = string.format(self:getTextWord(50041),info2.command)

		--编制经验+0%
		-- content23 = self:getTextWord(50045)
		-- content2301 = string.format(self:getTextWord(50046),math.floor(info2.estExpAddRate)) --编制经验+12%


	else
		content24 = self:getTextWord(50039)
	end


	local parent = self:getParent()
    local uiTip = UITip.new(parent)
    uiTip:setTitle(self:getTextWord(50205))

    local tipSize = ColorUtils.tipSize16
    local line1 = {{content = content13, foneSize = tipSize, color = ColorUtils.commonColor.FuBiaoTi}, 
    	{content = content1, foneSize = tipSize, color = ColorUtils.commonColor.White},
    	{content = content101, foneSize = tipSize, color = ColorUtils.commonColor.BiaoTi},
    	{content = content102, foneSize = tipSize, color = ColorUtils.commonColor.White},
    	{content = content103, foneSize = tipSize, color = ColorUtils.commonColor.Green},
    	{content = content104, foneSize = tipSize, color = ColorUtils.commonColor.White}
	}
    local line2 = {{content = content2, foneSize = tipSize, color = ColorUtils.commonColor.White},{content = content002, foneSize = tipSize, color = ColorUtils.commonColor.BiaoTi}}
    -- local line3 = {{content = content3, foneSize = tipSize, color = ColorUtils.commonColor.MiaoShu},{content = content301, foneSize = tipSize, color = ColorUtils.commonColor.Green}}



    local line21 = {{content = content21, foneSize = tipSize, color = ColorUtils.commonColor.FuBiaoTi}, 
    	{content = BR..content24, foneSize = tipSize, color = ColorUtils.commonColor.White},
    	{content = BR..content2401, foneSize = tipSize, color = ColorUtils.commonColor.BiaoTi},
    	{content = BR..content2402, foneSize = tipSize, color = ColorUtils.commonColor.White},
    	{content = BR..content2403, foneSize = tipSize, color = ColorUtils.commonColor.Red},
    	{content = BR..content2404, foneSize = tipSize, color = ColorUtils.commonColor.White}
	}

    local line22 = {{content = content22, foneSize = tipSize, color = ColorUtils.commonColor.White},{content = content2202, foneSize = tipSize, color = ColorUtils.commonColor.BiaoTi}}
    -- local line23 = {{content = content23, foneSize = tipSize, color = ColorUtils.commonColor.MiaoShu},{content = content2301, foneSize = tipSize, color = ColorUtils.commonColor.Green}}



    
    local line4 = {{content = content14, foneSize = tipSize, color = ColorUtils.commonColor.FuBiaoTi}}
    local line41 = {{content = content4, foneSize = tipSize, color = ColorUtils.commonColor.MiaoShu}}
    local line5 = {{content = content15, foneSize = tipSize, color = ColorUtils.commonColor.FuBiaoTi}}
    local line51 = {{content = content5, foneSize = tipSize, color = ColorUtils.commonColor.MiaoShu}}

    local line6 = {{content = content16, foneSize = tipSize, color = ColorUtils.commonColor.FuBiaoTi}}
    local line7 = {{content = content6, foneSize = tipSize, color = ColorUtils.commonColor.MiaoShu}}
    local line8 = {{content = content7, foneSize = tipSize, color = ColorUtils.commonColor.MiaoShu}}
    local line9 = {{content = content8, foneSize = tipSize, color = ColorUtils.commonColor.MiaoShu}}

    local line10 = {{content = content9, foneSize = tipSize, color = ColorUtils.commonColor.FuBiaoTi}}
    local line11 = {{content = content10, foneSize = tipSize, color = ColorUtils.commonColor.MiaoShu}}
    local line12 = {{content = content11, foneSize = tipSize, color = ColorUtils.commonColor.MiaoShu}}
    local line13 = {{content = content12, foneSize = tipSize, color = ColorUtils.commonColor.MiaoShu}}


    local lines = {}
    table.insert(lines, line1)
    table.insert(lines, line2)
    -- table.insert(lines, line3)	    
    table.insert(lines, line21)
    table.insert(lines, line22)
    -- table.insert(lines, line23)	    
    table.insert(lines, line4)	    
    table.insert(lines, line41)	    
    table.insert(lines, line5)	    
    table.insert(lines, line51)	    
    table.insert(lines, line6)	    
    table.insert(lines, line7)	    
    table.insert(lines, line8)	    
    table.insert(lines, line9)	    
    table.insert(lines, line10)	    
    table.insert(lines, line11)	    
    table.insert(lines, line12)	    
    table.insert(lines, line13)	    
    uiTip:setAllTipLine(lines)	
end

-- 声望tip
function PersonInfoDetailsPanel:onTipContentPRE()
	-- body
	local content1 = self:getTextWord(50018)
	local content2 = self:getTextWord(50019)
	local content3 = self:getTextWord(50020)
	local content4 = self:getTextWord(50021)
	local content5 = self:getTextWord(50022)

	local parent = self:getParent()
    local uiTip = UITip.new(parent)
    uiTip:setTitle(self:getTextWord(50203))
    local line1 = {{content = content1, foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.MiaoShu}}
    local line2 = {{content = BR..content2, foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.FuBiaoTi}}
    local line3 = {{content = content3, foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.MiaoShu}}
    local line4 = {{content = content4, foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.MiaoShu}}
    local line5 = {{content = content5, foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.MiaoShu}}

    local lines = {}
    table.insert(lines, line1)
    table.insert(lines, line2)
    table.insert(lines, line3)	    
    table.insert(lines, line4)	    
    table.insert(lines, line5)	    
    uiTip:setAllTipLine(lines)	
end

-- 统率tip
function PersonInfoDetailsPanel:onTipContentCMD(playerlv,cmdlv,cmdBook)
	-- body
	local content1 = ""
	local content2 = ""
	local content3 = ""
	local content4 = ""
	local content5 = ""
	local content6 = ""

	-- local roleProxy = self._roleProxy
    local cmdBook = self._roleProxy:getRolePowerValue(GamePowerConfig.Item,4013) or 0--统率令

	-- local tabLength = 80 --统率最高80级
	local color1 = ColorUtils.commonColor.Green
	local color2 = ColorUtils.commonColor.Green
	if cmdlv ~= nil and cmdlv < GlobalConfig.commandMaxLv then
		local i = cmdlv + 1
		local info1 = ConfigDataManager:getInfoFindByOneKey(self._CmdConfig, "commandlv", cmdlv)
		local info = ConfigDataManager:getInfoFindByOneKey(self._CmdConfig, "commandlv", i)
		local rate = math.floor(info1.rate / 10)

		content1 = string.format(self:getTextWord(50012),i)
		content2 = string.format(self:getTextWord(50013),info.command)
		content3 = string.format(self:getTextWord(50014),rate)
		content4 = string.format(self:getTextWord(50015),info1.captainLv)
		content5 = string.format(self:getTextWord(50016),cmdBook)

		if  playerlv < info1.captainLv then
			color1 = ColorUtils.commonColor.Red
		end
		if  cmdBook < 1 then
			color2 = ColorUtils.commonColor.Red
		end
	else
		content1 = self:getTextWord(50017)
	end

	local parent = self:getParent()
    local uiTip = UITip.new(parent)
    uiTip:setTitle(self:getTextWord(50204))
    local line1 = {{content = self:getTextWord(50008), foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.MiaoShu}}
    local line2 = {{content = BR..self:getTextWord(50009), foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.FuBiaoTi}, {content = BR..content1, foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.BiaoTi}}
    local line3 = {{content = self:getTextWord(50202), foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.FuBiaoTi}, {content = content2, foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.MiaoShu}}
    local line4 = {{content = self:getTextWord(50010), foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.FuBiaoTi}, {content = content3, foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.MiaoShu}}
    local line5 = {{content = self:getTextWord(50011), foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.FuBiaoTi}, {content = BR..content4, foneSize = ColorUtils.tipSize16, color = color1}}
    local line6 = {{content = content5, foneSize = ColorUtils.tipSize16, color = color2}}

    local lines = {}
    table.insert(lines, line1)
    table.insert(lines, line2)
    table.insert(lines, line3)	    
    table.insert(lines, line4)	    
    table.insert(lines, line5)	    
    table.insert(lines, line6)	    
    uiTip:setAllTipLine(lines)	
end

function PersonInfoDetailsPanel:onTouchTipBtnCallBack(sender)
	-- body
	local index = sender.index
	if index == 0 then
		self:onTipContentMR(sender.level, sender.mr)
		elseif index == 1 then
			self:onTipContentBoom(sender.boomlv)
			elseif index == 2 then
				self:onTipContentPRE()
				elseif index == 3 then
					self:onTipContentCMD(sender.level, sender.cmdlv, sender.cmdBook)
				end
end

-- 点击列表项的回调
function PersonInfoDetailsPanel:onTouchItemBtnCallBack(sender)
	-- body
	local data = {}
	data.index = sender.index

	if data.index == 0 then
		self.view:onSendItemBtn(data)
	elseif data.index == 1 then
			self.view:onSendItemBtn(data)
		elseif data.index == 2 then
				-- data.isMaxLv = sender.isMaxLv
				-- data._rewardFlag = sender.prestageState
				-- self.view:onShowMRPanel(data) --打开声望封赏界面
				self.view:onShowMRPanel() --打开声望封赏界面
			elseif data.index == 3 then
					data.type = 0
					self.view:onSendItemBtn(data)
	end

end

-- 点击列表项
function PersonInfoDetailsPanel:onTouchItemCallBack(sender, callArg)
	-- body
	if sender.index == 0 then
		self:onTouchItemBtnCallBack(sender)

	elseif sender.index == 1 then
		self:onTouchBtnBuyBoom(sender)

    elseif sender.index == 2 then
			self:onTouchItemBtnCallBack(sender)

	elseif sender.index == 3 and sender.boombook <= 0 then
		self:MessageBox(sender)
	elseif sender.index == 3 then
	    if callArg ~= nil then ---引导用的
            local data = {}
            data.type = 0
            data.index = sender.index
            self.view:onSendItemBtn(data)
        end
	end
end


-------------------------------------------------------------------------------
-- 定时器的相关界面刷新
-------------------------------------------------------------------------------
-- 刷新繁荣OR体力列表项
function PersonInfoDetailsPanel:updateRolePowerHandler(data)
	-- body

	if data.power == PlayerPowerDefine.POWER_boom then
		-- 刷新繁荣
		local data = self:getAllData()
		self:updateOneItemView(data, 1) --index=1 繁荣

	elseif data.power == PlayerPowerDefine.POWER_energy then
		-- 刷新体力
		local data = self:getAllData()
		self:onPanelInfoDetails(data)

	end

end

-- 渲染单个列表项
function PersonInfoDetailsPanel:updateOneItemView(data, index)
	-- body
	-- print("渲染···PersonInfoDetailsPanel:updateOneItemView(data, index) index",index)
	local item = self._listview:getItem(index)
	if item == nil then 
		self._listview:pushBackDefaultItem()
		item = self._listview:getItem(index)
	end
	self:registerItemEvents(item,data,index)
end

-------------------------------------------------------------------------------
-- 定时器update
-------------------------------------------------------------------------------
function PersonInfoDetailsPanel:renderRemainTime(remainTime,isShow)
	-- body
    -- 体力倒计时
    local energy_time = self:getChildByName("Panel_42/energyTime")
    local curEnergy = self:getChildByName("Panel_42/curEnergy")
    local maxEnergy = self:getChildByName("Panel_42/maxEnergy")
    local energyBarBg = self:getChildByName("Panel_42/energyBarBg")


    if isShow == false then
    	energy_time:setVisible(false)
        NodeUtils:alignNodeR2L(curEnergy,maxEnergy)
        NodeUtils:centerNodes(energyBarBg, {curEnergy,maxEnergy})
    else
	    energy_time:setVisible(true)
    	remainTime = TimeUtils:getStandardFormatTimeString8(remainTime)
    	energy_time:setString("("..remainTime..")")

		-- local energy = self:getChildByName("Panel_42/Label_bar2")
    	-- 文本自适应对齐	
		-- local size = energy:getContentSize()
		-- local x = energy:getPositionX()
		-- x = x + size.width/2 + 2
		-- energy_time:setPositionX(x)
        NodeUtils:alignNodeL2R(curEnergy,maxEnergy,energy_time)
        NodeUtils:centerNodes(energyBarBg, {curEnergy,maxEnergy,energy_time})

    end
end

function PersonInfoDetailsPanel:renderBoomRemainTime(remainTime,isShow)
	-- body
    -- 繁荣倒计时
    -- print("渲染繁荣倒计时 remainTime",remainTime)

    local index = 1
	local item = self._listview:getItem(index)
	if item == nil then 
		self._listview:pushBackDefaultItem()
		item = self._listview:getItem(index)
	end
   	local itemBtn = item:getChildByName("itemBtn")
	local boom_time = itemBtn:getChildByName("Label_detail124")
	local Label_detail123R = itemBtn:getChildByName("Label_detail123R")

    if isShow == false then
    	boom_time:setVisible(false)
    else
	    boom_time:setVisible(true)
    	remainTime = TimeUtils:getStandardFormatTimeString8(remainTime)
    	boom_time:setString("("..remainTime..")")

		-- 文本自适应对齐
		local size = Label_detail123R:getContentSize()
		local x = Label_detail123R:getPositionX()
		x = x + size.width + 0
		boom_time:setPositionX(x)
    end
end

-- 取体力倒计时
function PersonInfoDetailsPanel:getEnergyRemainTime()
	-- body
	-- local systemProxy = self:getProxy(GameProxys.System)
	-- local remainTime = systemProxy:getRemainTime( SystemTimerConfig.DEFAULT_ENERGY_RECOVER, 0, 0 )

	local remainTime = self._roleProxy:getRemainTimeByPower(PlayerPowerDefine.POWER_energy)

	-- local energy = self._MaxEnergy - self._CurEnergy
	-- if energy > 1 then
	-- 	remainTime = remainTime + (energy-1)*60*30
	-- end

	-- print("体力倒计时···remainTime="..remainTime)
	return remainTime
end

-- 取繁荣倒计时
function PersonInfoDetailsPanel:getBoomRemainTime()
	-- body
	local remainTime = self._roleProxy:getBoomRemainTime()
	-- print("繁荣倒计时···remainTime = "..remainTime)
	return remainTime
end

function PersonInfoDetailsPanel:update()
    -- print("update()··· _CurEnergy, _MaxEnergy, _CurBoom, _MaxBoom", self._CurEnergy, self._MaxEnergy, self._CurBoom, self._MaxBoom)
	
	if self._CurEnergy < self._MaxEnergy then   
    	local remainTime = self:getEnergyRemainTime()
    	self:renderRemainTime(remainTime,true)
    else
    	self:renderRemainTime(nil,false)
    end

	if self._CurBoom < self._MaxBoom then   
    	local remainTime = self:getBoomRemainTime()
    	self:renderBoomRemainTime(remainTime,true)
    else
    	self:renderBoomRemainTime(nil,false)
    end

    local cursade = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_crusadeEnergy) or 0
    self.cursadeTimeLab:setVisible(cursade < GlobalConfig.maxCrusadeEnergy)
    if cursade < GlobalConfig.maxCrusadeEnergy then
        local timeKey = self._roleProxy:getTimeKey(PlayerPowerDefine.POWER_crusadeEnergy)
        local time = self._roleProxy:getRemainTime(timeKey)
        self.cursadeTimeLab:setVisible(time > 0) 
        time = TimeUtils:getStandardFormatTimeString8(time)
        self.cursadeTimeLab:setString("("..time..")")  


        NodeUtils:alignNodeL2R(self.cursadeNumLab,self.cursadeTimeLab)
        NodeUtils:centerNodes(self.crusadeBarBg, {self.cursadeNumLab,self.cursadeTimeLab})
    end

end

function PersonInfoDetailsPanel:updateLegionName()
    local worldPos = self:getChildByName("Panel_42/Label_pos")
    local legName = self._roleProxy:getLegionName()
    legName = legName == "" and self:getTextWord(3129) or legName
    worldPos:setString("("..legName..")")
end

-- 头像
function PersonInfoDetailsPanel:onTouchedBtnHead(sender)
    local data = {}
    data.moduleName = ModuleName.HeadAndPendantModule 
    self:dispatchEvent(PersonInfoEvent.SHOW_OTHER_EVENT,data)
end

function PersonInfoDetailsPanel:onRoleHeadUpdate()
    -- 玩家头像
    local Image_head = self:getChildByName("Panel_42/Image_head")
    local roleProxy = self._roleProxy
    local headId = roleProxy:getHeadId()
    local pendantId = roleProxy:getPendantId()
    
    local headInfo = {}
    headInfo.icon = headId
    headInfo.pendant = pendantId
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = "headPendant"
    headInfo.isCreatPendant = true
    --headInfo.isCreatButton = true
    --headInfo.isCreatCover = true
    headInfo.playerId = self._roleProxy:getPlayerId()

    local head = self._head
    if head == nil then
        head = UIHeadImg.new(Image_head,headInfo,self)
        
        self._head = head
    else
        head:updateData(headInfo)
    end
    -- 点击头像响应事件
    if self._head then
        self._headBtn = self._head:getButton()
        self:addTouchEventListener(self._headBtn, self.onTouchedBtnHead)
    end
end