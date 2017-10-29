
ArenaMailInfoPanel = class("ArenaMailInfoPanel", BasicPanel)
ArenaMailInfoPanel.NAME = "ArenaMailInfoPanel"

function ArenaMailInfoPanel:ctor(view, panelName)
    ArenaMailInfoPanel.super.ctor(self, view, panelName,true)

    self:setUseNewPanelBg(true)
end

function ArenaMailInfoPanel:finalize()
    ArenaMailInfoPanel.super.finalize(self)
end

function ArenaMailInfoPanel:initPanel()
	ArenaMailInfoPanel.super.initPanel(self)
    self:setTitle(true,"yanwuchangReport",true)
    
    --[[6624
    	由于重新getChildByName的节点是找不到以前保存下来的icon对象
    	导致addCCB不断增加
    --]]
    self._iconTable = {}
    
    self:setBgType(ModulePanelBgType.NONE)

    self._listview = self:getChildByName("listView")
    self:onInitItem()
    self:registerEvent()
end

function ArenaMailInfoPanel:doLayout()
    local pnlAdtTop = self:getChildByName("pnlAdtTop")
    -- local pnlAdtBottom = self:getChildByName("pnlAdtBottom")
	-- NodeUtils:adaptiveListView(self._listview, 
	-- 					self:getChildByName("downPanel"), GlobalConfig.topHeight6)
	-- NodeUtils:adaptiveListView(self._listview, self:getChildByName("downPanel"), GlobalConfig.topHeight)
	NodeUtils:adaptiveListView(self._listview, self:getChildByName("downPanel"), pnlAdtTop)

end


function ArenaMailInfoPanel:onClosePanelHandler()
    
	self:hide()
	if self._close ~= nil then
		self._close = nil
		self.view:hideModuleHandler()
	end
end

function ArenaMailInfoPanel:registerEvent()
	local deleteBtn = self:getChildByName("downPanel/deleteBtn")
	local shareBtn = self:getChildByName("downPanel/shareBtn")
	local againBtn = self:getChildByName("downPanel/againBtn")
	shareBtn.type = 1
	self:addTouchEventListener(deleteBtn,self.onDeleteHandle)
	self:addTouchEventListener(shareBtn,self.onShareBtnHandle)
	self:addTouchEventListener(againBtn,self.onAgainBtnHandle)

	-- local sharePanel = self:getChildByName("sharePanel")
	-- local teamBtn = sharePanel:getChildByName("teamBtn")
	-- teamBtn.type = 1
	-- local worldBtn = sharePanel:getChildByName("worldBtn")
	-- self:addTouchEventListener(sharePanel,self.onShareBtnHandle)
	-- self:addTouchEventListener(teamBtn,self.onShareToReqHandle)
	-- self:addTouchEventListener(worldBtn,self.onShareToReqHandle)
	local modulePanel = self:getChildByName("modulePanel")
	modulePanel:setVisible(false)
end

function ArenaMailInfoPanel:onShareToReqHandle(sender)
	if sender.type == 1 then
	else
	end
end

function ArenaMailInfoPanel:onAgainBtnHandle(sender)
	self:dispatchEvent(ArenaMailEvent.FIGHT_AGAIN_REQ,{battleId = self._data.battleId})
end

function ArenaMailInfoPanel:onShareBtnHandle(sender)
	-- local sharePanel = self:getChildByName("sharePanel")
	-- if sender.type == 1 then
	-- 	sharePanel:setVisible(true)
	-- else
	-- 	sharePanel:setVisible(false)
	-- end

	if self._uiSharePanel == nil then
        self._uiSharePanel = UISharePanel.new(self.parent, self)
    end
    
    local data = {}
    data.type = ChatShareType.ARENA_TYPE 
    data.id = self._data.id
    self._uiSharePanel:showPanel(sender, data)

    local panel = self._uiSharePanel:getSharePanel()
    panel:setPositionX(panel:getPositionX()+85*2)
end

function ArenaMailInfoPanel:onDeleteHandle()
	local data = {}
	data.id = {self._data.id}
	self:dispatchEvent(ArenaMailEvent.DELETE_MAILS_REQ,data)
	self:hide()
end

function ArenaMailInfoPanel:onInitItem()
	
	-- self:setBgType(ModulePanelBgType.WHITE)
	self._PanelInfo = self:getChildByName("modulePanel/PanelInfo")
	self._PanelTou = self:getChildByName("modulePanel/PanelTou")
	self._Paneltail = self:getChildByName("modulePanel/Paneltail")
	self._PanelRew = self:getChildByName("modulePanel/PanelRew")
	self._PanelSoldier = self:getChildByName("modulePanel/PanelSoldier")
    self._PanelCity = self:getChildByName("modulePanel/PanelCity")
    self._PanelTeamInfo = self:getChildByName("modulePanel/PanelTeamInfo")
	
    self._PanelInfo:setVisible(false)
	self._PanelTou:setVisible(false)
	self._Paneltail:setVisible(false)
	self._PanelRew:setVisible(false)
	self._PanelSoldier:setVisible(false)
    self._PanelCity:setVisible(false)
    self._PanelTeamInfo:setVisible(false)
end

-- readType = 1 查看个人战报 readType = 2 查看全服战报
function ArenaMailInfoPanel:onUpdateData(data,isClose,readType)
	self._close = isClose
	local shareBtn  = self:getChildByName("downPanel/shareBtn")
	local deleteBtn = self:getChildByName("downPanel/deleteBtn")
--	local btnStatus1 = true
--	local btnStatus2 = true

--	if data.type == 3 or readType == 2 then --全服
--		btnStatus1 = false
--	end

--	if isClose ~= nil then --分享
--		btnStatus1 = false
--		btnStatus2 = false
--	end
--	NodeUtils:setEnable(shareBtn,btnStatus1) -- 按钮状态修改 
--	NodeUtils:setEnable(deleteBtn,btnStatus2)


	if readType == 2 then
		local roleProxy = self:getProxy(GameProxys.Role)
		local myName = roleProxy:getRoleName()
--		if data.attack.name == myName then
--			deleteBtn:setVisible(false)
--		end

        shareBtn:setVisible(false)
        deleteBtn:setVisible(false)

	else
		shareBtn:setVisible(true)
		deleteBtn:setVisible(true)		
	end


	self._listview:removeAllItems() -- 清除
	self._data = data
	local panelTb = {}
	--战斗信息
	self._listview:pushBackCustomItem(self:updatePanelInfo())
	--战斗损失
--	local touPanel = self:updatePanelTou()
--	self._listview:pushBackCustomItem(touPanel)
--	if #data.attack.lost > 0 then
--		--兵
--		for _,v in pairs(self:updatePanelSoldier(data.attack.lost)) do
--			self._listview:pushBackCustomItem(v)
--		end
--	end
--    -- 
--	local detailPanel = self:updatePanelTou(true)
--	self._listview:pushBackCustomItem(detailPanel)
--	self:onUpdateNoTeam(touPanel,detailPanel)
--	if #data.protect.lost > 0 then
--		for _,v in pairs(self:updatePanelSoldier(data.protect.lost)) do
--			self._listview:pushBackCustomItem(v)
--		end
--	end
    
    -- 攻防city
    local cityPanel = self:updatePanelCity()
    self._listview:pushBackCustomItem(cityPanel)
    -- 对战panel
    local teamInfoPanel = self:updatePanelTeamInfo()
    self._listview:pushBackCustomItem(teamInfoPanel)


    --战斗奖励
	local deleteBtn = self:getChildByName("downPanel/deleteBtn")
	if data.type == 1 or data.type == 2 then
		--战利品
		self._listview:pushBackCustomItem(self:updatePanelRew())
		-- deleteBtn:setVisible(true)
	else
		-- deleteBtn:setVisible(false)
	end
    
end

function ArenaMailInfoPanel:updatePanelInfo()
	local panel = self._PanelInfo:clone()
	local name = panel:getChildByName("name")
	local timeTxt = panel:getChildByName("timeTxt")
	local iconResult = panel:getChildByName("IconResult")
	local IconResult_win = panel:getChildByName("IconResult_win")
	local nameStr,result
	if self._data.result == 1 then
		--result = "进攻胜利"
		--result = self:getTextWord(200003)
        --TextureManager:updateImageView(iconResult, "images/battle/Txt_victory.png")
        IconResult_win:setVisible(true)
        iconResult:setVisible(false)
	else
		--result = "进攻失败"
		--result = self:getTextWord(200004)
        --TextureManager:updateImageView(iconResult, "images/battle/Txt_fail.png")
        IconResult_win:setVisible(false)
        iconResult:setVisible(true)
	end
	if self._data.type == 3 then  --全服
		nameStr = self._data.attack.name.." vs "..self._data.protect.name
	elseif  self._data.type == 1 then  --个人进攻
		--nameStr = "我的部队 挑战 "..self._data.protect.name
		nameStr = self:getTextWord(200005)..self._data.protect.name
	elseif  self._data.type == 2 then  --个人防守
		--nameStr = "我的部队 遭到 "..self._data.attack.name.." 的挑战"
		nameStr = self:getTextWord(200006)..self._data.attack.name..self:getTextWord(200007)
		if self._data.result == 1 then
			--result = "防守失败"
			--result = self:getTextWord(200008)   
            --TextureManager:updateImageView(iconResult, "images/battle/Txt_victory.png")
            IconResult_win:setVisible(false)
            iconResult:setVisible(true)
		else
			--result = "防守胜利"
            --TextureManager:updateImageView(iconResult, "images/battle/Txt_fail.png")
            IconResult_win:setVisible(true)
            iconResult:setVisible(false)
		end 
	end
	name:setString(nameStr)
	timeTxt:setString(TimeUtils:setTimestampToString6(self._data.time))
	panel:setVisible(true)
    iconResult:setScale(0.7)
	return panel
end

function ArenaMailInfoPanel:updatePanelTou(srcPanel)

	--军师数据代理
	local dataProxy = self:getProxy(GameProxys.Consigliere)

	local panel,dataInfo
	local first = "" 
	if srcPanel == nil then 
		panel = self._PanelTou:clone()
		dataInfo = self._data.attack
		if self._data.first == 0 then
			--first = "(先手)"
			first = self:getTextWord(200010)
		end
	else
		panel = self._Paneltail:clone()
		dataInfo = self._data.protect
		if self._data.first == 1 then
			--first = "(先手)"
			first = self:getTextWord(200010)
		end
	end
	local info = panel:getChildByName("info")


	--[[
		    required string name = 1;
		    required int32 vip = 2;
		    required string team = 3;//所属军团,若无则为""
		    required string boss = 4;//将领名称,若无则为""
		    required string bossSkill = 5;//将领的技能名称,若无则为""
		    repeated LostInfos lost = 6;//战损



		    required string name = 1;
		    required int32 vip = 2;
		    optional int32 typeid = 3; //军师数据表id
		    optional int32 level = 4;//军师实际星级
		    required string team = 5;//所属军团,若无则为""
		    repeated LostInfos lost = 6;//战损
	]]


	local colorImg = panel:getChildByName("colorImg")
	--local noTeam = panel:getChildByName("noTeam")
	local noBoss = panel:getChildByName("noBoss")

	local nameStr = dataInfo.name
	if dataInfo.vip > 0 then
		nameStr = nameStr.."VIP"..dataInfo.vip
	end
	if dataInfo.team ~= "" then
		nameStr = nameStr.."("..dataInfo.team..")"
	end
	nameStr = nameStr..first
	info:setString(nameStr)

	noBoss:setVisible(dataInfo.typeid == nil or dataInfo.typeid == 0)

	local levelImg = panel:getChildByName("levelImg")
	local bossName = panel:getChildByName("bossName")

	colorImg:setVisible(dataInfo.level ~= 0 and dataInfo.level ~= nil)
	levelImg:setVisible(dataInfo.level ~= 0 and dataInfo.level ~= nil)
	bossName:setVisible(dataInfo.typeid ~= nil and dataInfo.typeid ~= 0)

	local skillName = panel:getChildByName("skillName")
	local skillImg = panel:getChildByName("skillImg")


	local url = "images/newGui1/none.png"
	local skillText = ""
	if dataInfo.typeid ~= nil and dataInfo.typeid ~= 0 then
		
		local config = dataProxy:getDataById(dataInfo.typeid)
		if config ~= nil then
			bossName:setString(config.name)
			local color = ColorUtils:getColorByQuality(config.quality)
			bossName:setColor(color)
		end

		--军师星级图标
		if dataInfo.level ~= 0 and dataInfo.level ~= nil then
			local levelUrl = string.format("images/newGui1/adviser_num_%d.png", dataInfo.level)
			TextureManager:updateImageView(levelImg, levelUrl)
		end

		local levelData = dataProxy:getLvData(dataInfo.typeid, dataInfo.level)
		local skillData = StringUtils:jsonDecode(levelData.skillID)
		for k,v in pairs(skillData) do
			local skillConfig = ConfigDataManager:getConfigById("CounsellorSkillConfig", v)
			if skillConfig ~= nil then
				url = "images/littleIcon/999.png"
				skillText = skillText == "" and "Lv." .. dataInfo.level.. " " or skillText
				skillText = skillText .. skillConfig.name
			end
		end
		
	end
	TextureManager:updateImageView(skillImg, url)
	skillName:setString(skillText)

	local offset = 3
	local namePosx = bossName:getPositionX()
	local nameSize = bossName:getContentSize()
	skillImg:setPositionX(namePosx + nameSize.width + offset)

	local skillPosx = namePosx + nameSize.width + offset
	local skillSize = skillImg:getContentSize()
	skillName:setPositionX(skillPosx + offset + skillSize.width)

	panel:setVisible(true)
	return panel
end

function ArenaMailInfoPanel:onUpdateNoTeam(attPanel,denPanel,selfData)
	local attNoteam = attPanel:getChildByName("noTeam")
	local defNoteam = denPanel:getChildByName("noTeam")

	local attStatus = false
	local defStatus = false
	local attWord
	local defWord

	if #self._data.protect.lost <= 0 then  --无防守部队或者防守方零损兵
		if #self._data.attack.lost > 0 then  --守方0损兵，攻方有损兵
			defStatus = true
			--defWord = "零损兵获胜"
			defWord = self:getTextWord(200011)
		else--守方无部队，攻方无战斗获胜
			attStatus = true
			defStatus = true
			--attWord = "攻方无战斗获胜"
			attWord = self:getTextWord(200012)
			--defWord = "无防守部队"
			defWord = self:getTextWord(200013)
		end
	else  --防守方有损兵
		if #self._data.attack.lost > 0 then --攻方有损兵
		else--攻方无损兵
			attStatus = true
			--attWord = "零损兵获胜"
			attWord = self:getTextWord(200011)
		end
	end

	if attStatus == false then
		attNoteam:setVisible(fasle)
	else
		attNoteam:setVisible(true)
		attNoteam:setString(attWord)
	end

	if defStatus == false then
		defNoteam:setVisible(fasle)
	else
		defNoteam:setVisible(true)
		defNoteam:setString(defWord)
	end
end


function ArenaMailInfoPanel:updatePanelSoldier(lost)
	local panMap = {}
	local function updateItem(_panel,data,index)
		local item
		if index % 3 == 0 then
			item = _panel:getChildByName("item3")
		else
			item = _panel:getChildByName("item"..(index % 3))
		end
		local name = item:getChildByName("name")
		local num = item:getChildByName("num")
		local person = item:getChildByName("person")
		num:setString( 0 - data.num)
		local info,realModelId
		if data.typeid < 1000 then
			info = ConfigDataManager:getInfoFindByOneKey("ArmKindsConfig","ID",data.typeid)
			realModelId = ConfigDataManager:getInfoFindByOneKey("ModelGroConfig","ID",info.model).modelID
		else
			info = ConfigDataManager:getInfoFindByOneKey("MonsterConfig","ID",data.typeid)
			realModelId = ConfigDataManager:getInfoFindByOneKey("ModelGroConfig","ID",info.model).modelID
		end
		TextureManager:onUpdateSoldierImg(person,realModelId)
		name:setString(info.name)
		item:setVisible(true)
	end
	local panel
	local temptable = {}
	for k1, v1 in pairs(lost) do
		if temptable[v1.typeid] == nil then
			temptable[v1.typeid] = v1.num
		else
			temptable[v1.typeid] = temptable[v1.typeid] + v1.num
		end
	end
	lost = {}
	local index = 1
	for k,v in pairs(temptable) do
		lost[index] = {typeid = k, num = v}
		index = index + 1
	end
	for k,v in pairs(lost) do
		if k % 3 == 1 then
			panel = self._PanelSoldier:clone()
			panel:setVisible(true)
			table.insert(panMap,panel)
		end
		updateItem(panel,v,k)
	end
	return panMap
end

function ArenaMailInfoPanel:updatePanelRew()
	local panel = self._PanelRew:clone()
	local index = 1
	for index = 1, 6 do
		local item = panel:getChildByName("item"..index)
		item:setVisible(fasle)
	end
	for _,v in pairs(self._data.reward) do
		local item = panel:getChildByName("item"..index)
		local name = item:getChildByName("name")
		local num = item:getChildByName("num")
		local person = item:getChildByName("person")
		local bg = item:getChildByName("bg")
		num:setString(v.num)
		local config = ConfigDataManager:getConfigByPowerAndID(v.power,v.typeid)
		name:setString(config.name)
		name:setColor(ColorUtils:getColorByQuality(config.color))
		TextureManager:updateImageView(person,config.url)
		-- local url = "images/gui/Frame_prop_"..config.color..".png"
		local url = "images/newGui2/Frame_prop_1.png"
        TextureManager:updateImageView(bg,url)
		item:setVisible(true)
		index = index + 1
	end
	panel:setVisible(true)
	return panel
end

function ArenaMailInfoPanel:onHideHandler()
	for key,val in pairs(self._iconTable) do
		val:finalize()
	end
    self._iconTable = {}
    
	local proxy = self:getProxy(GameProxys.Arena)
	if proxy:onSetMailIsRead(self._data.type,self._data.id) == true then
		local panel
		if self._data.type == 3 then
			panel = self:getPanel(ArenaMailAllPanel.NAME)
		else
			panel = self:getPanel(ArenaMailPerPanel.NAME)
		end
		panel:onShowHandler()
	end
end

-- 攻防cityPanel
function ArenaMailInfoPanel:updatePanelCity()
    local clonePanel = self._PanelCity:clone()

    self:setAttackInfo(clonePanel, self._data) -- 进攻方
    self:setDefenseInfo(clonePanel, self._data) -- 防守方
    clonePanel:setVisible(true)
    return clonePanel
end

-- 进攻方  
function ArenaMailInfoPanel:setAttackInfo(clonePanel,data)
    -- PerDetailInfos
    local selfData = data.attack
    local name          = clonePanel:getChildByName("name")
    local legionTxt     = clonePanel:getChildByName("legionTxt01")
    --local powerTitleTxt = clonePanel:getChildByName("powerTitleTxt01")
    local powerTxt      = clonePanel:getChildByName("powerTxt01")
    --local beatTitleTxt  = clonePanel:getChildByName("beatTitleTxt01")
    local imgFirstLeft  = clonePanel:getChildByName("imgFirstLeft")

    -- 名字
    local myName = selfData.name
    name:setString(myName)

    -- 同盟
    local legionName = selfData.team
    if legionName == "" then
        legionTxt:setString("")
    else
        legionTxt:setString( string.format("[%s]", legionName))
    end
    -- 战力
    local powerNum = selfData.teamCapacit
    powerTxt:setString( StringUtils:formatNumberByK3(powerNum))

    -- 先后手，0:攻击先手,1:防守先手
    local firstHand = data.first
    if firstHand == 0 then
        imgFirstLeft:setVisible(true)
        --beatTxt:setString(TextWords:getTextWord(1246))
    else
        imgFirstLeft:setVisible(false)
        --beatTxt:setString(TextWords:getTextWord(1247))
    end

end

-- 防守方
function ArenaMailInfoPanel:setDefenseInfo(clonePanel,data)
    local selfData = data.protect

    local name          = clonePanel:getChildByName("defname")
    local legionTxt     = clonePanel:getChildByName("legionTxt02")
    --local powerTitleTxt = clonePanel:getChildByName("powerTitleTxt02")
    local powerTxt      = clonePanel:getChildByName("powerTxt02")
    --local beatTitleTxt  = clonePanel:getChildByName("beatTitleTxt02")
    local imgFirstRight  = clonePanel:getChildByName("imgFirstRight")

    -- 名字
    local myName = selfData.name
    name:setString(myName)

    -- 同盟
    local legionName = selfData.team
    if legionName == "" then
        legionTxt:setString("")
    else
        legionTxt:setString( string.format("[%s]", legionName))
    end

    -- 战力
    local powerNum = selfData.teamCapacit
    powerTxt:setString( StringUtils:formatNumberByK3(powerNum))
    -- 先后手，0:攻击先手,1:防守先手
    local firstHand = data.first
    if firstHand == 1 then
        imgFirstRight:setVisible(true)
        --beatTxt:setString(TextWords:getTextWord(1246))
    else
        imgFirstRight:setVisible(false)
        --beatTxt:setString(TextWords:getTextWord(1247))
    end
    

end

-------------------
-- 对战层
function ArenaMailInfoPanel:updatePanelTeamInfo()
    local clonePanel = self._PanelTeamInfo:clone()

    local attackItemData = self._data.attack.lostInfo -- 攻击损兵
    local defentItemData = self._data.protect.lostInfo -- 防守损兵
    
    local attackTypeId = self._data.attack.typeid
    local attackLevel  = self._data.attack.level

    local defentTypeId = self._data.protect.typeid
    local defentLevel  = self._data.protect.level

    local attackWarBook = rawget(self._data.attack, "warBookFight")
    local defentWarBook = rawget(self._data.protect, "warBookFight")

    local leftTeamImg    = clonePanel:getChildByName("leftTeamImg")  -- 攻防队伍
    local rightTeamImg   = clonePanel:getChildByName("rightTeamImg") -- 守方队伍
    -- 攻击方 
    self:setTeamPos(attackItemData, leftTeamImg, attackTypeId, attackLevel, attackWarBook, UIWarBookFight.DirType_Left)
    -- 防守方
    self:setTeamPos(defentItemData, rightTeamImg, defentTypeId, defentLevel, defentWarBook, UIWarBookFight.DirType_Right)

    clonePanel:setVisible(true)
    return clonePanel
end


function ArenaMailInfoPanel:setTeamPos(lostInfo, teamImg, advicerTypeId, advicerLevel, warBookFight, dirType)
    local soldierPanel = teamImg

    -- 国策
    local panelWarBook = soldierPanel:getChildByName("panelWarBook")
    if warBookFight ~= nil then
        local uiData = {
            isShowFirstAtkUI = false,
            rootUI = panelWarBook
        }
        local updateData = {}    
        local warBookFightCfgData = ConfigDataManager:getConfigById(ConfigData.WarBookFightConfig, warBookFight.warBookFightId)
        if warBookFightCfgData then        
            updateData.warBookFightCfgData = warBookFightCfgData
            updateData.skillLevel = { warBookFight.skillLevel1, warBookFight.skillLevel2 };
        end
        local uiWarBookFight = UIWarBookFight.new(self, uiData, dirType)
        uiWarBookFight:updateUI(updateData)
    else
        panelWarBook:setVisible(true)
    end

    -- 初始化
    for i = 1 , 6 do
        local posImg = soldierPanel:getChildByName("posImg"..i)
        local showEmpty = posImg:getChildByName("showEmpty")
        local numImg = showEmpty:getChildByName("numImg")
        local url = "images/fontsIcon/"..i..".png"
        TextureManager:updateImageView(numImg, url)

        -- 隐藏标题图
        showEmpty:setVisible(true)
        -- 名字文本
        local nameTxt = posImg:getChildByName("nameTxt")
        nameTxt:setString("")
        local iconHero = posImg:getChildByName("IconHero")
        iconHero:setVisible(true)
        -- 去图标
        local iconAddImg = posImg:getChildByName("iconAddImg")
        --6624
        -- if iconAddImg.uiIcon ~= nil then
        --     iconAddImg.uiIcon:finalize()
        --     iconAddImg.uiIcon = nil
        -- end
    end

    for i, lostInfoItem in pairs(lostInfo) do
        local post    = lostInfoItem.post     -- 槽位位置
        local posImg = soldierPanel:getChildByName("posImg"..post)
        local showEmpty = posImg:getChildByName("showEmpty")
        local numImg = showEmpty:getChildByName("numImg")
        -- 数据
        local typeId  = lostInfoItem.typeId   -- 配置表id
        local lostNum = lostInfoItem.lostNum  -- 兵种损失数量
        local allNum  = lostInfoItem.allNum   -- 兵种总数量
        local heroTypeId = lostInfoItem.heroTypeId -- 英雄的配置表id (类型optional，如果没下发下来被点出来则变成0)
        print("英雄的配置表id:".. heroTypeId)
        local remianNum  = allNum - lostNum
        -- 隐藏标题图
        showEmpty:setVisible( allNum == 0)

        local iconAddImg = posImg:getChildByName("iconAddImg")
        local heroNameTxt = posImg:getChildByName("nameTxt") -- 英雄名txt
        local iconHero = posImg:getChildByName("IconHero")
        if allNum ~= 0 then
            local data = {}
            data.num = allNum
            data.power = GamePowerConfig.Soldier
            data.typeid = self:getTrueTypeId(typeId)
            data.customNumStr = {{{ "-"..lostNum, 14, ColorUtils.wordRedColor16}, { "/"..allNum, 14, ColorUtils.wordWhiteColor16}  }}

            if iconAddImg.uiIcon == nil then
                local uiIcon = UIIcon.new(iconAddImg, data, true, self, nil, false)
                uiIcon:setTouchEnabled(false) 
                iconAddImg.uiIcon = uiIcon
            else
                iconAddImg.uiIcon:updateData(data)
            end
            table.insert(self._iconTable,iconAddImg.uiIcon)
            -- 武将名字设置
            if heroTypeId == 0 then
                heroNameTxt:setString("")
                iconHero:setVisible(true)
            else
                local configItem = ConfigDataManager:getInfoFindByOneKey(
                ConfigData.HeroConfig, "ID", heroTypeId)
                local heroName = configItem.name
                local color    = configItem.color
                heroNameTxt:setString( heroName )
                heroNameTxt:setColor( ColorUtils:getColorByQuality(color))
                iconHero:setVisible(false)
            end
        end
    end
    ---------------------------------------------------------------------
    -- 军师图片:槽位[7]
    local adviserImg = soldierPanel:getChildByName("posImg7")
    local nameTxt = adviserImg:getChildByName("nameTxt")
    nameTxt:setString("")
    -- 军师星级
    local advicerStarImg = adviserImg:getChildByName("advicerStarImg")
    advicerStarImg:setVisible(false)

    if advicerLevel ~= 0 then
        advicerStarImg:setVisible(true)
        local levelImg = advicerStarImg:getChildByName("levelImg")
        local sStarUrl = string.format("images/newGui1/adviser_num_%d.png", advicerLevel)
        TextureManager:updateImageView(levelImg, sStarUrl)
    end

    -- 军师图标释放
    local iconAddImg = adviserImg:getChildByName("iconAddImg")
    --6624
    -- if iconAddImg.uiIcon ~= nil then
    --     iconAddImg.uiIcon:finalize()
    --     iconAddImg.uiIcon = nil
    -- end

    local showEmpty = adviserImg:getChildByName("showEmpty")
    showEmpty:setVisible(true)

    -- 组icon数据
    local adviserData = {}
    adviserData.num   = 1
    adviserData.power = GamePowerConfig.Counsellor -- 军师类型的
    adviserData.typeid = advicerTypeId -- 为空0的时候表示没有军师

    -- 加载
    if adviserData.typeid ~= 0 then
        local uiIcon
        if iconAddImg.uiIcon == nil then
            --print("-----------------------------Name--::"..adviserData.name)
            uiIcon = UIIcon.new(iconAddImg, adviserData, true, self,  nil,true)
            uiIcon:setTouchEnabled(false) 
            iconAddImg.uiIcon = uiIcon
        else
            iconAddImg.uiIcon:updateData(adviserData)
        end
		table.insert(self._iconTable,iconAddImg.uiIcon)
        -- 名字设置
        local nameTxt = uiIcon:getNameChild()
        nameTxt:setFontSize(18)
        if advicerLevel ~= 0 then
            nameTxt:setPosition(-15, -57)
        else
            nameTxt:setPosition(0, -57)
        end
    end

end

------
-- 真实TypeId
function ArenaMailInfoPanel:getTrueTypeId(typeId)
    local realModelId = typeId
    -- 判断位数
    if string.len(typeId) ~= 3 then
        realModelId = ConfigDataManager:getInfoFindByOneKey(
        ConfigData.MonsterConfig,"ID",typeId).model
    end
    return realModelId
end