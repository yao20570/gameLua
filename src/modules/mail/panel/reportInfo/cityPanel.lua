cityPanel = {}
cityPanel.NAME = "cityPanel"
-- 战斗报告专用
function cityPanel:ctor(panel,parent)
    self._panel = panel
    self._parent = parent
end

function cityPanel:updateData(panel,data)
	if rawget(data.infos,self.NAME) ~= nil then
        --local clonePanel = self._panel:clone()
        self:updateFtPanel(panel,data)
        self:updatePtPanel(panel,data)
        --return clonePanel
	end
end

-- 攻击方
function cityPanel:updateFtPanel(clonePanel,data)
	local selfData = rawget(data.infos,self.NAME)
    --local attackImg = clonePanel:getChildByName("attackImg")
	local name = clonePanel:getChildByName("name")
	local frong = clonePanel:getChildByName("frong")
	local add = clonePanel:getChildByName("add")
	local targetBtn = clonePanel:getChildByName("targetBtn")
	local ProgressBar = clonePanel:getChildByName("ProgressBar")
    -- 改版文本
    local legionTxt     = clonePanel:getChildByName("legionTxt01")
    local boomTxt1      = clonePanel:getChildByName("boomTxt01")
    local powerTitleTxt = clonePanel:getChildByName("powerTitleTxt01")
    local beatTitleTxt  = clonePanel:getChildByName("beatTitleTxt01")
    local powerTxt      = clonePanel:getChildByName("powerTxt01")
    --local beatTxt       = clonePanel:getChildByName("beatTxt01")
    local imgFirstLeft       = clonePanel:getChildByName("imgFirstLeft")
    
    -- [同盟]字段
    local legionName = data.infos.lostSerPanel.attackItem.ftTeam -- 取损失
    if legionName == "" then
        legionTxt:setString("")
    else
        legionTxt:setString( string.format("[%s]", legionName))
    end
   
    -- 战斗: 字段  0:攻击先出手,1:防守先出手
    local firstHand = data.infos.lostSerPanel.firstHand 
    if firstHand == 0 then
        --beatTxt:setString(TextWords:getTextWord(1246))
        imgFirstLeft:setVisible(true)
    else
        imgFirstLeft:setVisible(false)
        --beatTxt:setString(TextWords:getTextWord(1247))
    end
    -- 战力 字段
    local powerNum = data.infos.lostSerPanel.attackItem.teamCapacity

    powerTxt:setString( StringUtils:formatNumberByK3(powerNum))

    if selfData.attackAddBoom < 0 then
        -- 减的>总的
        if math.abs(selfData.attackAddBoom) > selfData.attackTotalBoom then
            selfData.attackAddBoom = selfData.attackTotalBoom - selfData.attackTotalBoom*2
        end
    elseif selfData.attackAddBoom > 0 then
        -- 加的溢出
        local boom = selfData.attackCurrBoom + selfData.attackAddBoom
        if boom > selfData.attackTotalBoom then
            selfData.attackAddBoom = selfData.attackTotalBoom - selfData.attackCurrBoom
        end
    end
    if selfData.attackAddBoom >= 0 then
        add:setString("+"..selfData.attackAddBoom)
    else
        add:setString(selfData.attackAddBoom)
    end
	
    if selfData.attackAddBoom >= 0 then
        add:setColor(ColorUtils:color16ToC3b("#25ef3c"))
    else
        add:setColor(ColorUtils:color16ToC3b("#ff1212"))
    end
	local boom = rawget(selfData,"attackCurrBoom")
	if boom ~= nil then
		frong:setVisible(true)
        -- 加成后，上限满繁荣
        local boom = boom + selfData.attackAddBoom
        if boom > selfData.attackTotalBoom then
            boom = selfData.attackTotalBoom
        elseif boom < 0 then
            boom = 0
        end
        frong:setString(boom.."/"..selfData.attackTotalBoom)
        ProgressBar:setPercent(boom * 100 / selfData.attackTotalBoom)
	else
		frong:setVisible(false)
	end
	
	local _name,isSelf 
    if data.infos.mailType == 1 then  --攻击
		local roleProxy = self._parent:getProxyByName("Role")
		_name = roleProxy:getRoleName()
		isSelf = true
    else
    	_name = selfData.oName
    	isSelf = nil
    end
    if data.infos.mailType == 1 then
        name:setString(selfData.myName)
    else
        name:setString(selfData.oName)
    end

    local function onGotoPos( sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			self._parent:onGoToPosHandle(isSelf)
		end
	end
    targetBtn:setEnabled(true)
	targetBtn:addTouchEventListener(onGotoPos)
    -----ceshi share
    if self._parent.tmp then
        if self._parent.tmp.index == 1 then
            --NodeUtils:setEnable(targetBtn, false)
            targetBtn:setEnabled(false)
        else
            if data.infos.mailType == 1 then
                if data.infos.resourcePanel.cityIcon < 50 then
                    --NodeUtils:setEnable(targetBtn, false)
                    targetBtn:setEnabled(false)
                end
            elseif data.infos.mailType == 3 then
                if data.infos.resourcePanel.cityIcon < 50 then
                    --NodeUtils:setEnable(targetBtn, false)
                    targetBtn:setEnabled(false)
                end
            end
        end
        if data.infos.mailType ~= 2 then
            targetBtn:setEnabled(false)
        end
    end
    -----ceshi share
	if selfData.attackIcon > 0 then
    	local url = ComponentUtils:getWorldBuildingUrl(selfData.attackIcon)
        TextureManager:updateButtonNormal(targetBtn, url,"images/common/building54.png")
    end
    targetBtn:setScale(GlobalConfig.worldMapBuildScale)
end

-- 防守方
function cityPanel:updatePtPanel(clonePanel,data)
	local selfData = rawget(data.infos,self.NAME)
    --local defentImg = clonePanel:getChildByName("defentImg")
	local name = clonePanel:getChildByName("defname")
	local frong = clonePanel:getChildByName("deffrong")  --防守方的繁荣度
	local add = clonePanel:getChildByName("defadd")
	local targetBtn = clonePanel:getChildByName("deftargetBtn")
	local ProgressBar = clonePanel:getChildByName("defProgressBar")  --进度条
    local ProgressBg = clonePanel:getChildByName("defprogressBg") --进度背景

    -- 改版文本
    local legionTxt = clonePanel:getChildByName("legionTxt02")
    local boomTxt = clonePanel:getChildByName("boomTxt02")
    local powerTitleTxt = clonePanel:getChildByName("powerTitleTxt02")
    local beatTitleTxt = clonePanel:getChildByName("beatTitleTxt02")
    local powerTxt = clonePanel:getChildByName("powerTxt02")
    --local beatTxt = clonePanel:getChildByName("beatTxt02")
    local imgFirstRight = clonePanel:getChildByName("imgFirstRight")

    -- 同盟字段
    local legionName = data.infos.lostSerPanel.defentItem.ftTeam -- 取损失
    if legionName == "" then
        legionTxt:setString("")
    else
        legionTxt:setString( string.format("[%s]", legionName))
    end
    
    -- 先攻字段  0:攻击先出手,1:防守先出手
    local firstHand = data.infos.lostSerPanel.firstHand 
    if firstHand == 1 then
        --beatTxt:setString(TextWords:getTextWord(1246))
        imgFirstRight:setVisible(true)
    else
        imgFirstRight:setVisible(false)
        --beatTxt:setString(TextWords:getTextWord(1247))
    end
    -- 战力 字段
    local powerNum = data.infos.lostSerPanel.defentItem.teamCapacity
    powerTxt:setString( StringUtils:formatNumberByK3(powerNum))
    -- DID如果 防守方是资源点，客户端计算
    if powerNum == 0 then
        local name = data.infos.lostSerPanel.defentItem.name
        local num = string.sub(name, 1, 1)
		local isCity =  not tonumber(num) -- 是否是主城
        if isCity then
        else

        end

    end

    if selfData.defentAddBoom < 0 then
        -- 减的>总的
        if math.abs(selfData.defentAddBoom) > selfData.defentTotalBoom then
            selfData.defentAddBoom = selfData.defentTotalBoom - selfData.defentTotalBoom*2
        end
    elseif selfData.defentAddBoom > 0 then
        -- 加的溢出
        local boom = selfData.defentCurrBoom + selfData.defentAddBoom
        if boom > selfData.defentTotalBoom then
            selfData.defentAddBoom = selfData.defentTotalBoom - selfData.defentCurrBoom
        end
    end
    if selfData.defentAddBoom >= 0 then
        add:setString("+"..selfData.defentAddBoom)
    else
        add:setString(selfData.defentAddBoom)
    end
    if selfData.defentAddBoom >= 0 then
        add:setColor(ColorUtils:color16ToC3b("#25ef3c"))
    else
        add:setColor(ColorUtils:color16ToC3b("#ff1212"))
    end
	local boom = rawget(selfData,"defentCurrBoom")
	if boom ~= nil then
		frong:setVisible(true)
        -- 加成后，上限满繁荣，下限为0
        local boom = boom + selfData.defentAddBoom
        if boom > selfData.defentTotalBoom then
            boom = selfData.defentTotalBoom
        elseif boom < 0 then
            boom = 0
        end
        frong:setString(boom.."/"..selfData.defentTotalBoom)
        ProgressBar:setPercent(boom * 100 / selfData.defentTotalBoom)
	else
		frong:setVisible(false)
	end
	---资源点的时候不显示繁荣
    if selfData.defentIcon < 50 then
        ProgressBg:setVisible(false)
        ProgressBar:setVisible(false)
        frong:setString("")
    else
        ProgressBg:setVisible(true)
        ProgressBar:setVisible(true)
    end
    local isResource = 0
	local _name,isSelf
    if data.infos.mailType == 2 then  --防守
		local roleProxy = self._parent:getProxyByName("Role")
		_name = roleProxy:getRoleName()
		isSelf = true
        if selfData.defentIcon < 50 then
            isResource = 1
        end
    else
    	_name = selfData.oName
    	isSelf = nil
    end
    if data.infos.mailType == 2 then
        name:setString(selfData.myName)
    else
        name:setString(selfData.oName)
    end


    local function onGotoPos( sender, eventType)
		if eventType == ccui.TouchEventType.ended then
            if isResource == 1 then
                self._parent:onGoToPosHandle(isSelf, selfData.defenPox,selfData.defenPoy)
            else
                self._parent:onGoToPosHandle(isSelf)
            end
		end
	end
    targetBtn:setEnabled(true)
	targetBtn:addTouchEventListener(onGotoPos)
    -----ceshi share
    if self._parent.tmp then
        if self._parent.tmp.index == 1 then
            --NodeUtils:setEnable(targetBtn, false)
            targetBtn:setEnabled(false)
        else
            if data.infos.mailType == 1 then
                if data.infos.resourcePanel.cityIcon < 50 then
                    -- NodeUtils:setEnable(targetBtn, false)
                    targetBtn:setEnabled(false)
                end
            elseif data.infos.mailType == 3 then
                if data.infos.resourcePanel.cityIcon < 50 then
                    -- NodeUtils:setEnable(targetBtn, false)
                    targetBtn:setEnabled(false)
                end
            end
        end
        if data.infos.mailType ~= 1 then
            targetBtn:setEnabled(false)
        end
    end

    -----ceshi share
    local targetType = nil
	local url = nil
	if selfData.defentIcon > 0 then
        if data.infos.isPerson == 2 then  --叛军
            url = string.format("images/map/rebels%d.png", data.infos.rebelArmyIcon)
    	elseif data.infos.isPerson == 1 then  --资源点
            targetType = 1
    		local pointInfo = {}
    		local info = ConfigDataManager:getConfigData(ConfigData.ResourcePointConfig)
    		for k, v in pairs(info) do
    			if v.name == data.infos.InfoPanel.name then
    				pointInfo = v
    				break
    			end
    		end
    		if v ~= nil then
    			url = ComponentUtils:getWorldBuildingUrl(pointInfo.icon,true)
    		else
    			url = ComponentUtils:getWorldBuildingUrl(selfData.defentIcon,true)
    		end
    	else
            targetType = 2
    		if selfData.defentIcon >= 50 then
    			url = ComponentUtils:getWorldBuildingUrl(selfData.defentIcon)
    		else
    			url = ComponentUtils:getWorldBuildingUrl(selfData.defentIcon,true)
    		end
    		-- url = ComponentUtils:getWorldBuildingUrl(selfData.defentIcon)
    	end
        TextureManager:updateButtonNormal(targetBtn, url,"images/common/building54.png")
    end

    self:setIconScale(targetBtn,targetType)
end

-- icon缩放大小
function cityPanel:setIconScale(targetBtn,targetType)
    -- body
    local scale = 1
    if targetType == 1 then --资源缩放
        -- scale = GlobalConfig.worldMapResScaleConf[2][3]
    else  --建筑缩放        
        scale = GlobalConfig.worldMapBuildScale
    end
    targetBtn:setScale(scale)
end