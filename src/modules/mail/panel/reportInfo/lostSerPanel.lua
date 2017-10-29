lostSerPanel = {}
lostSerPanel.NAME = "lostSerPanel"

function lostSerPanel:ctor(panel,parent)
	self._panel = panel
	self._parent = parent
end

function lostSerPanel:updateData(panel,data)
	local haveBattle = data.infos.haveBattle
	local selfData = rawget(data.infos,self.NAME)
	local firstHand = selfData.firstHand
	if haveBattle == 0 then   --没有战斗
		firstHand = 2		  --没有先手	
	end
--	local attPanel = panel:getChildByName("nameInfoPanel")
--	if panel:getName() == "Panel_lostBegin" then
--		self:updateItem(attPanel,selfData.attackItem,firstHand, 0)
--		self:updateLostItem(panel,selfData.attackItem.ftLost)
--	elseif panel:getName() == "Panel_lostEnd" then
--		self:updateItem(attPanel,selfData.defentItem,firstHand, 1)
--		self:updateLostItem(panel,selfData.defentItem.ftLost)
--	end
    if panel:getName() == "teamInfoPanel" then
        -- 新的队伍对战情况设置
        self:onInitTeamInfo(data, panel)
    end
end


function lostSerPanel:updateItem(panel,data,firstHand,index)
	local name = panel:getChildByName("name")
	local quanityImg = panel:getChildByName("quanityImg")
	local noSoldier = panel:getChildByName("noSoldier")
	local exp = panel:getChildByName("exp")
	--local noteam = panel:getChildByName("noteam")
	local totalStr = nil
	if data.ftvip > 0 then
		totalStr = data.name.." VIP"..data.ftvip.." "
	else
		totalStr = data.name
	end
	
	if data.ftTeam ~= "" then
		totalStr = totalStr.."("..data.ftTeam..") "
	end
	if index == firstHand then
		--totalStr = totalStr.."[先手]"
		totalStr = totalStr..TextWords[1224]
	end
	name:setString(totalStr)
	exp:setString(data.fightExp)
	local fightSr = data.fightSr  --军师

	local proxy = self._parent:getProxy(GameProxys.Consigliere)

	local sName = panel:getChildByName("sName")
	local skillName = panel:getChildByName("skillName")
	local skillImg = panel:getChildByName("skillImg")
	local levelImg = panel:getChildByName("levelImg")
	

	local url = "images/newGui1/none.png"
	local starUrl = url
	local levelUrl = url
	local nameText = "无"
	local skillText = ""
	local color = cc.c3b(255,255,255)
	if fightSr ~= nil then
		local config = ConfigDataManager:getConfigById("CounsellorConfig", fightSr.typeid)
		nameText = config ~= nil and config.name or "无"
		if config ~= nil then
			color = ColorUtils:getColorByQuality(config.quality)
			local levelData = proxy:getLvData(fightSr.typeid, fightSr.level)
			if fightSr.level ~= 0 and fightSr.level ~= nil then
				levelUrl = string.format("images/newGui1/adviser_num_%d.png", fightSr.level)
				starUrl = "images/mail/adviser_star3.png"
			end

			local skillData = StringUtils:jsonDecode(levelData.skillID)
			for k,v in pairs(skillData) do
				local skillConfig = ConfigDataManager:getConfigById("CounsellorSkillConfig", v)
				if skillConfig ~= nil then
					url = "images/littleIcon/999.png"
					skillText = skillText == "" and "Lv." .. fightSr.level.. " " or skillText
					skillText = skillText .. skillConfig.name
				end
			end
		end
	end
	TextureManager:updateImageView(skillImg, url)
	TextureManager:updateImageView(quanityImg, starUrl)
	TextureManager:updateImageView(levelImg, levelUrl)

	sName:setString(nameText)
	sName:setColor(color)
	skillName:setString(skillText)

	local offset = 3
	local nameSize = sName:getContentSize()
	local namePosx = sName:getPositionX()
	skillImg:setPositionX(namePosx + nameSize.width + offset)

	local skillPosx = namePosx + nameSize.width + offset
	local skillSize = skillImg:getContentSize()
	skillName:setPositionX(skillSize.width + skillPosx + offset)

end

function lostSerPanel:updateLostItem(panel,data)
	if panel.m_scale == nil then
		panel.m_scale = 3
	end
	local scaleMuch = 0
	
	if table.size(data) <= 0 or data == nil then
		scale = 1
	elseif table.size(data) <= 3 then
		scale = 2
	else
		scale = 3
	end
    --print("panel:getName()   ",panel:getName(),panel.m_scale,scale)
    if panel.m_scale ~= scale then
        local distance = panel.m_scale - scale
		if distance == 2 then   --缩小两行
			scaleMuch = -166
		elseif distance == -2 then --增大两行
			scaleMuch = 166
		elseif distance == 1 then --缩小1行
			scaleMuch = -83
		elseif distance == -1 then --增大1行
			scaleMuch = 83
		end
		local conSize = panel:getContentSize()
		panel:setContentSize(conSize.width,conSize.height + scaleMuch)
		for _,v in pairs(panel:getChildren()) do
			local posY = v:getPositionY()
        	v:setPositionY(posY + scaleMuch)
		end
        panel.m_scale = scale
	end

	local index = 1
	for _,v in pairs(data) do
		local Image,lostNum
		if index <= 3 then
			lostNum = panel:getChildByName("Panel_lost1")
			Image = lostNum:getChildByName("Image"..index)
		else
			lostNum = panel:getChildByName("Panel_lost2")
			Image = lostNum:getChildByName("Image"..index)
		end
		local count = Image:getChildByName("count")
		local name = Image:getChildByName("name")
		local person = Image:getChildByName("person")
		if v.typeid < 1000 then
			info = ConfigDataManager:getInfoFindByOneKey("ArmKindsConfig","ID",v.typeid)
			realModelId = ConfigDataManager:getInfoFindByOneKey("ModelGroConfig","ID",info.model).modelID
		else
			info = ConfigDataManager:getInfoFindByOneKey("MonsterConfig","ID",v.typeid)
			realModelId = ConfigDataManager:getInfoFindByOneKey("ModelGroConfig","ID",info.model).modelID
		end
		if person.realModelId ~= realModelId then
			TextureManager:onUpdateSoldierImg(person,realModelId)
			person.realModelId = realModelId
		end
		count:setString(0 - v.num)
		name:setString(info.name)
		Image:setVisible(true)		
		index = index + 1
	end

	for i = index ,6 do
		local Image,lostNum
		if i <= 3 then
			lostNum = panel:getChildByName("Panel_lost1")
			Image = lostNum:getChildByName("Image"..i)
		else
			lostNum = panel:getChildByName("Panel_lost2")
			Image = lostNum:getChildByName("Image"..i)
		end
		Image:setVisible(false)
	end	
end


function lostSerPanel:onUpdateNoTeam(attPanel,denPanel,selfInfo)
	local selfData = selfInfo.lostSerPanel
	local attNoteam = attPanel:getChildByName("noteam")
	local defNoteam = denPanel:getChildByName("noteam")

	local attStatus = false
	local defStatus = false
	local attWord = ""
	local defWord = ""

	print("selfInfo.mailType===",selfInfo.mailType)
	print("#selfData.attackItem.ftLost===",#selfData.attackItem.ftLost)
	print("#selfData.defentItem.ftLost===",#selfData.defentItem.ftLost)

	if selfInfo.mailType == 1 then
		if #selfData.attackItem.ftLost <= 0 then
			if #selfData.defentItem.ftLost > 0 then
				--我是进攻方，进攻没损失
				attStatus = true
				attWord = TextWords[1225]
			end
		end
	else
		if #selfData.defentItem.ftLost <= 0 then
			if #selfData.attackItem.ftLost > 0 then
				--我是防守方，而且防守没损失
				defStatus = true
				defWord = TextWords[1225]
			end
		end
	end

    attNoteam:setVisible(attStatus)
	defNoteam:setVisible(defStatus)
	attNoteam:setString(attWord)
	defNoteam:setString(defWord)
end


-- 新的队伍对战情况设置
function lostSerPanel:onInitTeamInfo(data, panel) -- panel = teamInfoPanel
    local reportData = data.infos -- Report 结构体
    local lostSoldiersData = reportData.lostSerPanel -- lostSoldiers结构体
    local attackItemData = lostSoldiersData.attackItem -- 攻击损兵
    local defentItemData = lostSoldiersData.defentItem -- 防守损兵
    local firstHand      = lostSoldiersData.firstHand      -- 先手值， 0:攻击先出手,1:防守先出手
    local leftTeamImg    = panel:getChildByName("leftTeamImg")  -- 攻防队伍
    local rightTeamImg   = panel:getChildByName("rightTeamImg") -- 守方队伍

    -- 攻击方 数结构lostItem
    self:setTeamPos(attackItemData, leftTeamImg, UIWarBookFight.DirType_Left)
    -- 防守方
    self:setTeamPos(defentItemData, rightTeamImg, UIWarBookFight.DirType_Right)
end

------
-- itemData 为 
-- .attackItem -- 攻击损兵
-- .defentItem -- 防守损兵
function lostSerPanel:setTeamPos(itemData, teamImg, dirType)
    local soldierPanel = teamImg
    local showData    = itemData.ftLost --  PosInfo //佣兵位置信息
    local fightSrData = itemData.fightSr -- FightItem //军师信息
    local lostInfo    = itemData.lostInfo -- LostSoildierInfo//对应槽位损失以及出战总数量
    local teamCapacity = itemData.teamCapacity -- 出战部队战力
    local warBookFight = rawget(itemData, "warBookFight") -- 国策数据
    print("出战部队战力：".. teamCapacity)

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

        local uiWarBookFight = UIWarBookFight.new(self._parent, uiData, dirType)
        uiWarBookFight:updateUI(updateData)
    else
        panelWarBook:setVisible(false)
    end

    -- 初始化
    for i = 1 , 6 do
        local posImg = soldierPanel:getChildByName("posImg"..i)
        local showEmpty = posImg:getChildByName("showEmpty")
        local numImg = showEmpty:getChildByName("numImg")
        local url = MailReportInfoPanel.FONTS_ICON_URL..i..".png"
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
        if iconAddImg.uiIcon ~= nil then
            iconAddImg.uiIcon:finalize()
            iconAddImg.uiIcon = nil
        end
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
        iconHero:setVisible(true)
        if allNum ~= 0 then
            local data = {}
            data.num = allNum
            data.power = GamePowerConfig.Soldier
            data.typeid = self:getTrueTypeId(typeId)
            data.customNumStr = {{{ "-"..lostNum, 14, ColorUtils.wordRedColor16}, { "/"..allNum, 14, ColorUtils.wordWhiteColor16}  }}

            local uiIcon = UIIcon.new(iconAddImg, data, true, self, nil, false)
            uiIcon:setTouchEnabled(false) 
            iconAddImg.uiIcon = uiIcon
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
                iconHero:setVisible(false)
                heroNameTxt:setColor( ColorUtils:getColorByQuality(color))
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
    
    if fightSrData.level ~= 0 then
        advicerStarImg:setVisible(true)
        local levelImg = advicerStarImg:getChildByName("levelImg")
        local sStarUrl = string.format("images/newGui1/adviser_num_%d.png", fightSrData.level)
        TextureManager:updateImageView(levelImg, sStarUrl)
    end


    -- 军师图标释放
    local iconAddImg = adviserImg:getChildByName("iconAddImg")
    if iconAddImg.uiIcon ~= nil then
        iconAddImg.uiIcon:finalize()
        iconAddImg.uiIcon = nil
    end

    local showEmpty = adviserImg:getChildByName("showEmpty")
    showEmpty:setVisible(true)

    -- 组icon数据
    local adviserData = {}
    adviserData.num   = 1
    adviserData.power = GamePowerConfig.Counsellor -- 军师类型的
    adviserData.typeid = fightSrData.typeid -- 为空0的时候表示没有军师

    -- 加载
    if adviserData.typeid ~= 0 then
        local uiIcon = UIIcon.new(iconAddImg, adviserData, true, self,  nil,true)
        uiIcon:setTouchEnabled(false) 
        iconAddImg.uiIcon = uiIcon
        -- 名字设置
        local nameTxt = uiIcon:getNameChild()
        nameTxt:setFontSize(18)
        if fightSrData.level ~= 0 then
            nameTxt:setPosition(-15, -57)
        else
            nameTxt:setPosition(0, -57)
        end
    end
end

----------------------------------------------------------------------

------
-- 真实TypeId
function lostSerPanel:getTrueTypeId(typeId)
    local realModelId = typeId
    -- 判断位数
    if string.len(typeId) ~= 3 then
        realModelId = ConfigDataManager:getInfoFindByOneKey(
        ConfigData.MonsterConfig,"ID",typeId).model
    end
    return realModelId
end