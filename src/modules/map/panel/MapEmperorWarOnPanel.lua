-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
MapEmperorWarOnPanel = class("MapEmperorWarOnPanel", BasicPanel)
MapEmperorWarOnPanel.NAME = "MapEmperorWarOnPanel"



function MapEmperorWarOnPanel:ctor(view, panelName)
    local layer = view:getLayer(ModuleLayer.UI_TOP_LAYER)
    MapEmperorWarOnPanel.super.ctor(self, view, panelName, 800, layer)
end

function MapEmperorWarOnPanel:finalize()
    MapEmperorWarOnPanel.super.finalize(self)

    if self._earnBtnCcb ~= nil then
        self._earnBtnCcb:finalize()
    end
end

function MapEmperorWarOnPanel:initPanel()
	MapEmperorWarOnPanel.super.initPanel(self)
    self._systemProxy = self:getProxy(GameProxys.System)
    self._roleProxy = self:getProxy(GameProxys.Role)
    self._emperorCityProxy = self:getProxy(GameProxys.EmperorCity)
end

function MapEmperorWarOnPanel:registerEvents()
	MapEmperorWarOnPanel.super.registerEvents(self)
    self._mainPanel = self:getChildByName("mainPanel")
    self._panel01 = self._mainPanel:getChildByName("panel01")
    self._panel02 = self._mainPanel:getChildByName("panel02")
    self._panel03 = self._mainPanel:getChildByName("panel03")

    self._listView= self._panel02:getChildByName("listView")

    self._earnBtn = self._panel01:getChildByName("earnBtn")
    self:addTouchEventListener(self._earnBtn, self.onEarnBtn)

    self._attackBtn = self._panel03:getChildByName("attackBtn")
    self:addTouchEventListener(self._attackBtn, self.onAttackBtn)

    -- 帮助按钮
    self._helpBtn = self._mainPanel:getChildByName("helpBtn")
    self:addTouchEventListener(self._helpBtn, self.onHelpBtn)
end

function MapEmperorWarOnPanel:onShowHandler()
    -- 告诉服务端进入场景
    --self._systemProxy:onTriggerNet30105Req( { type = 0, scene = GlobalConfig.Scene[4]})


    self._cityId = self._emperorCityProxy:getCityId()
    self._configInfo = ConfigDataManager:getConfigById(ConfigData.EmperorWarConfig, self._cityId)

    self:onUpdataEmperorWarOnPanel()
end

function MapEmperorWarOnPanel:onEarnBtn()
    logger:info("点击查看收益")
    local cityType = self._configInfo.type
    local tipStr = self:getTextWord(550034) -- "（占领军营且民忠满值时对占领方生效增益，持续到更换占领方才会失效）"
    local data = StringUtils:jsonDecode(self._configInfo.occupyBuff)

    local uiShowEarnPanel = UIShowEarnPanel.new(self)
    uiShowEarnPanel:setView(data, cityType, tipStr)
end


function MapEmperorWarOnPanel:onUpdataEmperorWarOnPanel()
    local titleName = self._configInfo.cityName
    self:setTitle(true, titleName) -- 设置皇城名
    
    -- 设置静态显示
    self:setConfigShow(self._panel01)

    -- 设置网络显示
    self:setRespShow()

    -- 设置部队列表
    self:setListView()

    -- 设置收益/增益按钮显示
    self:setEarnBtnShow()

    -- 显示特效
    if self._configInfo.type == 1 then
        self:addEarnBtnCcb()
    end
end

-- 设置静态相关信息
function MapEmperorWarOnPanel:setConfigShow(panel)
    local nameImg = panel:getChildByName("nameImg")
    local cityImg = panel:getChildByName("cityImg")
    local posTxt  = panel:getChildByName("posTxt")

    local id = self._configInfo.ID
    local cityType = self._configInfo.type 

    TextureManager:updateImageView(nameImg, "images/emperorCityIcon/font_city_name"..id..".png")
    TextureManager:updateImageView(cityImg, "images/emperorCityIcon/icon_city"..cityType..".png")


    -- 设置坐标
    posTxt:setString( string.format("(%s, %s)",self._configInfo.dataX , self._configInfo.dataY) )
    
end


------
-- 网络数据
function MapEmperorWarOnPanel:setRespShow()
    -- 占领
    local legionNameTxt = self._panel01:getChildByName("legionNameTxt")
    local legionName = self._emperorCityProxy:getCityInfo().legionName
    if legionName == "" then
        legionNameTxt:setColor(ColorUtils.wordBadColor)
        legionNameTxt:setString(self:getTextWord(3108))
    else
        legionNameTxt:setColor(ColorUtils.wordNameColor)
        legionNameTxt:setString(legionName)
    end

    -- 状态
    local stateTxt = self._panel01:getChildByName("stateTxt")
    local status = self._emperorCityProxy:getCityStatus()
    stateTxt:setString(self:getTextWord(550002 + status))
    -- 行军时间
    local timeTxt = self._panel01:getChildByName("timeTxt")
    local marchTime = self._emperorCityProxy:getMarchTime()
    timeTxt:setString( TimeUtils:getStandardFormatTimeString8(marchTime))
    -- 坐标
    local posTxt = self._panel01:getChildByName("posTxt")
    local info = self._emperorCityProxy:getCityInfo()
    posTxt:setString( string.format("(%s, %s)",info.x , info.y))

    -- 防守同盟名
    local defLegionNameTxt = self._panel02:getChildByName("defLegionNameTxt") 
    local defLegionName = self._emperorCityProxy:getDefLegionName()
    local integralSpeed = self._emperorCityProxy:getIntegralSpeed() -- 民忠速度
    defLegionNameTxt:setString(integralSpeed == 0 and "" or defLegionName) -- 没防守部队不显示，npc守城不显示

    -- 进度条
    self:updateNumBar()
end

-- 设置进度条
function MapEmperorWarOnPanel:updateNumBar()
    local proBarTxt = self._panel01:getChildByName("proBarTxt")
    local proBar    = self._panel01:getChildByName("proBar")

    local curNum = self._emperorCityProxy:getOccupyNum() -- 当前占领值
    local maxNum = self._configInfo.occupyNum -- 最大占领
    local integralSpeed = self._emperorCityProxy:getIntegralSpeed() -- 民忠速度

    -- 预览时间s，进度颜色   
    local preTime = 0
    if integralSpeed > 0 then
        preTime = (maxNum - curNum)/( math.abs(integralSpeed)) 
        proBar:loadTexture("images/map/rich_value_bar.png",ccui.TextureResType.plistType)
    elseif integralSpeed < 0 then
        preTime = curNum/( math.abs(integralSpeed)) 
        proBar:loadTexture("images/map/rich_value_red_bar.png",ccui.TextureResType.plistType)
    elseif integralSpeed == 0 then -- 无防守队伍
--        local defLegionName = self._emperorCityProxy:getDefLegionName() 
--        local legionName = self._emperorCityProxy:getCityInfo().legionName
--        if defLegionName == legionName then
--            proBar:loadTexture("images/map/rich_value_bar.png",ccui.TextureResType.plistType)
--        else
--            proBar:loadTexture("images/map/rich_value_red_bar.png",ccui.TextureResType.plistType)
--        end

        proBar:loadTexture("images/map/rich_value_bar.png",ccui.TextureResType.plistType)
    end

    proBar:setPercent(curNum/maxNum *100)
    
    -- 进度已暂停
    local legionName = self._emperorCityProxy:getCityInfo().legionName
    if integralSpeed == 0 and legionName ~= "" then
        proBarTxt:setString(self:getTextWord(550032)) -- "进度已暂停"
    elseif integralSpeed == 0 and legionName == "" then   
        proBarTxt:setString("")
    elseif maxNum == curNum and integralSpeed > 0 then    
        proBarTxt:setString(self:getTextWord(550033)) -- "民忠值已满" 
    else
        proBarTxt:setString(self:getTextWord(550012)..TimeUtils:getStandardFormatTimeString8( math.floor(preTime))) -- .."  数值："..curNum)
    end
end

-- 刷新进度
function MapEmperorWarOnPanel:update()
    local proBarTxt = self._panel01:getChildByName("proBarTxt")
    local proBar    = self._panel01:getChildByName("proBar")

    local integralSpeed = self._emperorCityProxy:getIntegralSpeed() -- 民忠速度

    local legionName = self._emperorCityProxy:getCityInfo().legionName
    local defLegionName = self._emperorCityProxy:getDefLegionName() 
    if integralSpeed ~= 0 then
        -- 无占领处理
        proBarTxt:setVisible(true)
        proBar   :setVisible(true)

        local curNum = self._emperorCityProxy:getOccupyNum() -- 当前占领值
        local maxNum = self._configInfo.occupyNum -- 最大占领

        -- 满了后执行的中断
        local legionName = self._emperorCityProxy:getCityInfo().legionName
        if self._emperorCityProxy:getJudgeOccupyNum() >= maxNum and defLegionName == legionName then
            --logger:info("满了停止计时")
            return 
        end

        curNum = curNum + integralSpeed
        -- 临界值判断
        if curNum > maxNum then
            curNum = maxNum
        elseif curNum < 0 then
            curNum = 0
        end

        self._emperorCityProxy:setOccupyNum(curNum) -- 设置最新的占领值
        if curNum == 0 or curNum == maxNum then -- 满值的时候不发送？
            local function delayReq()
                local data = {}
                data.cityId = self._cityId
                self._emperorCityProxy:onTriggerNet550000Req(data)
            end
            self:updateNumBar() -- 刷新进度条

            -- 如果是军营，才发送同步，皇城已有推送
            delayReq()
        else
            self:updateNumBar() -- 刷新进度条
        end
    end
end



------
-- 设置防守部队
function MapEmperorWarOnPanel:setListView()
    local defTeamList = self._emperorCityProxy:getDefTeamList()
    local listData = clone(defTeamList)
    listData = TableUtils:splitData(listData, 4) -- 四份
    self:renderListView(self._listView, listData, self, self.renderItem)
end

function MapEmperorWarOnPanel:renderItem(itemPanel, data, index)
    index = index + 1
    for i = 1, 4 do
        local headPanel = itemPanel:getChildByName("headPanel".. i)
        local nameTxt = headPanel:getChildByName("nameTxt")
        if data[i] then
            headPanel:setVisible(true)
            -- todocity 玩家头像显示
            local headInfo = {}
            headInfo.icon = data[i].headId
            headInfo.pendant = 0
            headInfo.preName1 = "headIcon"
		    headInfo.preName2 = nil
            headInfo.playerId = rawget(data[i], "playerId")
            headInfo.isBattleHead = true

            if headPanel.head == nil then
                headPanel.head = UIHeadImg.new(headPanel, headInfo, self)
                headPanel.head:setScale(0.8)
            else
                headPanel.head:updateData(headInfo)
            end
            -- 玩家名字
            nameTxt:setString(data[i].name)
        else
            headPanel:setVisible(false)
        end
    end
end



-- 点击出战
function MapEmperorWarOnPanel:onAttackBtn(sender)
    logger:info("点击皇城出战")
    -- 出战限制判断
    local limitLevel = self._configInfo.playerLevel
    local myLevel    = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    
    if limitLevel > myLevel then
        self:showSysMessage( string.format(self:getTextWord(550029), limitLevel))
        return 
    else
        local legionLevel = self._configInfo.legionLevel
        local myLegionLevel = self._roleProxy:getLegionLevel()
        if legionLevel > myLegionLevel then
            self:showSysMessage( string.format(self:getTextWord(550030), legionLevel))
            return 
        end
    end

    -- 已有队伍不能出战
    local defTeamList = self._emperorCityProxy:getDefTeamList()
    local curMyTeamNum = 0
    for i, info in pairs(defTeamList) do
        local roleName = self._roleProxy:getRoleName()
        if info.name == roleName then
            curMyTeamNum = curMyTeamNum + 1
        end
    end
    local maxTeamNum = self._configInfo.troopsNum
    if curMyTeamNum >= maxTeamNum then
        self:showSysMessage(self:getTextWord(550031)) -- "可派遣防守部队数已达上限"
        return
    end

    local mapPanel = self:getPanel(MapPanel.NAME)
    mapPanel:onAttackEmperorCity(self._configInfo.dataX, self._configInfo.dataY, self._configInfo.cityName, "todocity")

    self:hide()
end


-- 设置收益/增益按钮显示
function MapEmperorWarOnPanel:setEarnBtnShow()
    local cityType = self._configInfo.type
    if cityType == 1 then
        self._earnBtn:loadTextures("images/map/btn_buff1.png", "images/map/btn_buff2.png", "", 1)
    else
        self._earnBtn:loadTextures("images/map/btn_earn1.png", "images/map/btn_earn2.png", "", 1)
    end
end


function MapEmperorWarOnPanel:onHideHandler()
    -- 离开场景
   -- self._systemProxy:onTriggerNet30105Req({type = 1, scene = GlobalConfig.Scene[4]})
end


------
-- 判断是否是守卫
function MapEmperorWarOnPanel:isDummy()
    local legionName = self._emperorCityProxy:getCityInfo().legionName

    return legionName == ""
end




------
-- 特效添加
function MapEmperorWarOnPanel:addEarnBtnCcb()
    if self._earnBtnCcb == nil then
        self._earnBtnCcb = self:createUICCBLayer("rgb-zjm-tubiao", self._earnBtn)
        self._earnBtnCcb:setPosition(-41, -71)
        self._earnBtnCcb:setScale(0.8)
    end

    local legionName = self._emperorCityProxy:getCityInfo().legionName
    local myLegionName = self._roleProxy:getLegionName()
    local curNum = self._emperorCityProxy:getOccupyNum() -- 当前占领值
    local maxNum = self._configInfo.occupyNum -- 最大占领
    if legionName == myLegionName and curNum == maxNum then
        self._earnBtnCcb:setVisible(true)
    else
        self._earnBtnCcb:setVisible(false)
    end
end

-- 点击跳转帮助
function MapEmperorWarOnPanel:onHelpBtn(sender)
    ModuleJumpManager:jump("EmperorCityModule", "EmperorCityHelpPanel")
    self:hide()
end