-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
MilitaryProjectPanel = class("MilitaryProjectPanel", BasicPanel)
MilitaryProjectPanel.NAME = "MilitaryProjectPanel"
-- 数据池排序：1骑兵，2刀兵，3枪兵，4弓兵

MilitaryProjectPanel.NameImgUrl = "images/military/font_name%d.png"
MilitaryProjectPanel.RankImgUrl = "images/military/font_rank%d.png"
MilitaryProjectPanel.IconMidUrl = "images/military/icon_mid%d.png"
MilitaryProjectPanel.SoldierTypeUrl = "images/newGui1/IconBingYing%d.png"
MilitaryProjectPanel.IconStageUrl = "images/military/icon_stage%s.png"

MilitaryProjectPanel.MaxRank = 6
MilitaryProjectPanel.MaxStagePos = 8

function MilitaryProjectPanel:ctor(view, panelName)
    MilitaryProjectPanel.super.ctor(self, view, panelName)
end

function MilitaryProjectPanel:finalize()
    MilitaryProjectPanel.super.finalize(self)
    
    if self._leftBtnEffect ~= nil then
        self._leftBtnEffect:finalize()
        self._leftBtnEffect = nil
    end
    if self._rightBtnEffect ~= nil then
        self._rightBtnEffect:finalize()
        self._rightBtnEffect = nil
    end
end

function MilitaryProjectPanel:initPanel()
	MilitaryProjectPanel.super.initPanel(self)
    self._isHide = true

    self._militaryProxy = self:getProxy(GameProxys.Military)
    self._roleProxy     = self:getProxy(GameProxys.Role)

    -- index和配置的类型不一样，所以要这个表格写死索引
    self._indexToTypeMap = {}
    self._indexToTypeMap[1] = 2  -- name = "刀兵"}
    self._indexToTypeMap[2] = 1  -- name = "骑兵"}
    self._indexToTypeMap[3] = 3  -- name = "枪兵"}
    self._indexToTypeMap[4] = 4  -- name = "弓兵"}

    -- 亮点特效对应表
    self._typeToLightCcb = {}
    self._typeToLightCcb[1] = "rgb-jgs-lianghuang" -- 黄
    self._typeToLightCcb[2] = "rgb-jgs-lianglan"   -- 蓝
    self._typeToLightCcb[3] = "rgb-jgs-lianglv"    -- 绿
    self._typeToLightCcb[4] = "rgb-jgs-lianghong"  -- 红

    -- 进阶激活循环特效对应表
    self._typeToJiHuoForCcb = {}
    self._typeToJiHuoForCcb[1] = "rgb-jgs-jhhuang" -- 黄
    self._typeToJiHuoForCcb[2] = "rgb-jgs-jhlan"   -- 蓝
    self._typeToJiHuoForCcb[3] = "rgb-jgs-jhlv"    -- 绿
    self._typeToJiHuoForCcb[4] = "rgb-jgs-jhhong"  -- 红


    -- 进阶激活爆炸特效
    self._typeToJiHuoCcb = {}
    self._typeToJiHuoCcb[1] = "rgb-jgs-jihuohuang" -- 黄
    self._typeToJiHuoCcb[2] = "rgb-jgs-jihuolan"   -- 蓝
    self._typeToJiHuoCcb[3] = "rgb-jgs-jihuolv"    -- 绿
    self._typeToJiHuoCcb[4] = "rgb-jgs-jihuohong"  -- 红

    -- 待机特效
    self._typeToStandbyCcb01 = {}
    self._typeToStandbyCcb01[1] = "rgb-jgs-huanghuo" -- 黄
    self._typeToStandbyCcb01[2] = "rgb-jgs-lanhuo"   -- 蓝
    self._typeToStandbyCcb01[3] = "rgb-jgs-lvhuo"    -- 绿
    self._typeToStandbyCcb01[4] = "rgb-jgs-honghuo"  -- 红

    self._typeToStandbyCcb02 = {}
    self._typeToStandbyCcb02[1] = "rgb-jgs-huangqian" -- 黄
    self._typeToStandbyCcb02[2] = "rgb-jgs-lanqian"   -- 蓝
    self._typeToStandbyCcb02[3] = "rgb-jgs-lvqian"    -- 绿
    self._typeToStandbyCcb02[4] = "rgb-jgs-hongqian"  -- 红

    local materialPanel = self:getChildByName("mainPanel/materialPanel")
    local reinforceBtn  = self:getChildByName("mainPanel/reinforceBtn")

    NodeUtils:adaptiveUpPanel(reinforceBtn, materialPanel, 55)

    --//null  7119 测试说按钮还原位置
    reinforceBtn:setPositionX(320)
end

function MilitaryProjectPanel:registerEvents()
	MilitaryProjectPanel.super.registerEvents(self)
    self._mainPanel = self:getChildByName("mainPanel")
    self._indexPanel = self._mainPanel:getChildByName("indexPanel")
    self._leftBtn = self._indexPanel:getChildByName("leftBtn")
    self._rightBtn = self._indexPanel:getChildByName("rightBtn")
    -- 添加按钮特效
    self:initSideBtn()

    self:addTouchEventListener(self._leftBtn, self.onLeftBtn)
    self:addTouchEventListener(self._rightBtn, self.onRightBtn)

    self._materialPanel = self._mainPanel:getChildByName("materialPanel")
    self._listView = self._materialPanel:getChildByName("listView")
    self._maxRankTxt = self._materialPanel:getChildByName("maxRankTxt")

    self._reinforceBtn = self._mainPanel:getChildByName("reinforceBtn")
    self:addTouchEventListener(self._reinforceBtn, self.onReinforceBtn)
    self._showTxt = self._reinforceBtn:getChildByName("showTxt")
    self._attributePanel = self._mainPanel:getChildByName("attributePanel")
        

    self._lastCtrlBtn = self._mainPanel:getChildByName("lastCtrlBtn")
    self._lastCtrlTxt = self._lastCtrlBtn:getChildByName("lastCtrlTxt")
    self._nextCtrlTxt = self._lastCtrlBtn:getChildByName("nextCtrlTxt")

    self:addTouchEventListener(self._lastCtrlBtn, self.onLastCtrlBtn)

    self._touchDirPanel = self._mainPanel:getChildByName("touchDirPanel")
    self:addTouchEventListener(self._touchDirPanel, self.endPanelTouch, nil, nil, nil, nil,nil, true) 
end

function MilitaryProjectPanel:onShowHandler()
    MilitaryProjectPanel.super.onShowHandler(self)
    self:initPageView()
    self:setAttriNameIcon() -- 属性图标
    self:setAttriUpCcb() -- 增加特效

end

function MilitaryProjectPanel:initPageView()
    if self._expandPageView == nil then
        local dataList = self._militaryProxy:getMilitaryInfos() 
        self._pageView = self:getChildByName("mainPanel/pageView")
        self._expandPageView = UIExpandPageView.new(self._pageView)
        self._expandPageView:setPageCallback(self.pageCallBack)
        self._expandPageView:renderPage(dataList, self)
        -- 初始化page
        for i = 1, #dataList do
            local page = self._pageView:getPage( i - 1)
            local soldierType = self:indexToType(page.index + 1)
            local militaryInfo = self._militaryProxy:getMilitaryInfoByType(soldierType)
            self:setPagePanelShow(page, militaryInfo)
        end
        self._expandPageView:onPageViewListenerHandler() 
    else
        self:pageCallBack()
    end

    if self._isHide then
        -- 打开层级隐藏
        self._mainPanel:setVisible(false)
    end
end


function MilitaryProjectPanel:endPanelTouch(sender, value, dir)
    if dir == 1 then
        self:onLeftBtn()
        
    elseif dir == -1 then
        self:onRightBtn()
    end
end




-- 左右按钮
function MilitaryProjectPanel:initSideBtn()
    if self._leftBtnEffect == nil then
        self._leftBtnEffect = self:createUICCBLayer("rgb-fanye", self._leftBtn)
        local size = self._leftBtn:getContentSize()
        self._leftBtnEffect:setPosition(size.width/2, size.height/2)
    end
    if self._rightBtnEffect == nil then
        self._rightBtnEffect = self:createUICCBLayer("rgb-fanye", self._rightBtn)
        local size = self._rightBtn:getContentSize()
        self._rightBtnEffect:setPosition(size.width/2, size.height/2)
    end
end



function MilitaryProjectPanel:pageCallBack()
    local pagePanel = self._expandPageView:getCurDataPage()
    local curDataIndex = self._expandPageView:getCurDataIndex()
    logger:info("当前军工页面的数据index ： ".. curDataIndex)

    -- 设置当前的page状态
    local soldierType = self:indexToType(curDataIndex)
    local militaryInfo = self._militaryProxy:getMilitaryInfoByType(soldierType)
    self._militaryInfo = militaryInfo

    -- 中间信息的设置
    self:setPagePanelShow(pagePanel, militaryInfo)   

    -- 设置页面移动亮点标记
    self:setIndexPanelShow(curDataIndex)

    -- 设置升级材料
    self:setMaterialPanelShow(curDataIndex)

    
end 

-- 设置兵纹
function MilitaryProjectPanel:setSoldierNameImg(pagePanel, militaryInfo)
    local nameImg = pagePanel:getChildByName("nameImg")
    local urlStr = string.format(MilitaryProjectPanel.NameImgUrl, militaryInfo.type) 
    TextureManager:updateImageView(nameImg, urlStr)
end

-- 设置阶级图
function MilitaryProjectPanel:setSoldierRankImg(pagePanel, militaryInfo)
    local rankImg = pagePanel:getChildByName("rankImg")
    local urlStr = string.format(MilitaryProjectPanel.RankImgUrl, militaryInfo.rank) 
    TextureManager:updateImageView(rankImg, urlStr)
end

-- 设置显示中间复杂图形
function MilitaryProjectPanel:setMidCardShow(pagePanel, militaryInfo)
    local rank = militaryInfo.rank -- 阶数
    local bgRank 
    for i = 1, MilitaryProjectPanel.MaxRank do
        local bgRankTmp = pagePanel:getChildByName("bgRank"..i)
        if i == rank then
            bgRankTmp:setVisible(true)
            bgRank = bgRankTmp
        else
            bgRankTmp:setVisible(false)
        end
    end
    if bgRank == nil then
        return 
    end

    if not self._isRespUpdate then 
        -- 等级显示
        self:setBgRankLevel(bgRank, militaryInfo)
    end

    -- 中间点的显示
    self:setBgRankMidIcon(bgRank, militaryInfo)


    if self._isRespUpdate then
        -- 更新小点的显示特效(bgRank, )
        self:updateBgRankStagePos(bgRank, militaryInfo)
    else
        -- 小点的翻页刷新
        self:setBgRankStagePos(bgRank, militaryInfo)
    end
end

------
-- 等级显示
function MilitaryProjectPanel:setBgRankLevel(bgRank, militaryInfo)
    local levelTxt = bgRank:getChildByName("levelTxt")
    local str01 = self:getTextWord(510020)
    local curlevel = militaryInfo.level
    local configInfo = self._militaryProxy:getRankConfiInfo(militaryInfo.type, militaryInfo.rank)
    local maxLevel = configInfo.levelMax
    local str02 = curlevel.."/"..maxLevel
    levelTxt:setString(str01..str02)
end

-- 中间点的显示
function MilitaryProjectPanel:setBgRankMidIcon(bgRank, militaryInfo)
    -- 类型背景图
    local midIcon = bgRank:getChildByName("midIcon")
    local urlStr = string.format(MilitaryProjectPanel.IconMidUrl, militaryInfo.type) 
    TextureManager:updateImageView(midIcon, urlStr)


    local pagePanel = bgRank:getParent()

    -- 类型图
    local typeIcon = midIcon:getChildByName("typeIcon")
    local urlStr01 = string.format(MilitaryProjectPanel.SoldierTypeUrl, pagePanel.index + 1) 
    TextureManager:updateImageView(typeIcon, urlStr01)

    if pagePanel.jihuoForCcb ~= nil then
        pagePanel.jihuoForCcb:finalize()
        pagePanel.jihuoForCcb = nil
    end

    -- 是否显示升阶循环特效
    local actionType = self._militaryProxy:getActionStateByType(militaryInfo.type)
    if actionType == 3 then
        pagePanel.jihuoForCcb = self:createUICCBLayer(self._typeToJiHuoForCcb[militaryInfo.type], midIcon)
        local size = midIcon:getContentSize()
        pagePanel.jihuoForCcb:setPosition(size.width/2 , size.height/2)
        pagePanel.jihuoForCcb:setLocalZOrder(2)
    end
end





-- 小点的显示初始化
function MilitaryProjectPanel:setBgRankStagePos(bgRank, militaryInfo)
    local type    = militaryInfo.type    -- 类型（1骑兵，2刀兵，3枪兵，4弓兵） 
    local segment = militaryInfo.segment -- 段数
    local level   = militaryInfo.level   -- 等级
    local rank    = militaryInfo.rank    -- 阶数

    -- 翻页后则清除特效bgRank上的所有特效
    for i = 1, MilitaryProjectPanel.MaxStagePos do 
        local stagePos = bgRank:getChildByName("stagePos".. i)
        if stagePos ~= nil then
            -- 熄灭状态 
            stagePos.lightState = 0
            local id = self._militaryProxy:getStagePosImgId(type, rank, stagePos.lightState, i)
            local url = string.format(MilitaryProjectPanel.IconStageUrl, id) 
            TextureManager:updateImageView(stagePos, url)
            -- 去除小点ccb
            if stagePos.ccb ~= nil then
                stagePos.ccb:finalize()
                stagePos.ccb = nil
            end
        end
    end
    
    for i = 1, self._militaryProxy:getMaxStagePosByType(type) do 
        if i <= segment then
            local stagePos = bgRank:getChildByName("stagePos".. i)
            self:addCcbToStagePos(type, stagePos)
        end
    end
end


-- 更新小点的显示(bgRank, )
function MilitaryProjectPanel:updateBgRankStagePos(bgRank, militaryInfo)
    local type    = militaryInfo.type    -- 类型（1骑兵，2刀兵，3枪兵，4弓兵） 
    local segment = militaryInfo.segment -- 段数
    local level   = militaryInfo.level   -- 等级
    local rank    = militaryInfo.rank    -- 阶数


    if self._actionType == 1 then -- 升段1
        local stagePos = bgRank:getChildByName("stagePos".. segment)
        --
        local function addOnceFun() 
            self:addCcbToStagePos(type, stagePos)
            NodeUtils:removeSwallow()
            self._isRespUpdate = false -- 结束状态还原
        end
        NodeUtils:addSwallow()

        self:addCcbDianLiang(stagePos)
        TimerManager:addOnce(300, addOnceFun, self)
    elseif self._actionType == 2 then -- 升级2
        local stagePos = bgRank:getChildByName("stagePos".. self._militaryProxy:getMaxStagePosByType(type)) -- 最后一个
        
        local function shuaxinCallFun() -- 延迟刷新等级
            self:setBgRankLevel(bgRank, militaryInfo) 
        end
        
        local function overCall()
            self:setBgRankStagePos(bgRank, militaryInfo)
            self:addCcbShuaXin(bgRank:getChildByName("levelTxt"), shuaxinCallFun) -- 升级刷新特效
            -- 完成升级是否触发激活升阶爆炸特效
            if self._militaryProxy:getActionStateByType(militaryInfo.type) == 3 then
                self:addCcbJiHuoOnce(bgRank:getChildByName("midIcon"), militaryInfo.type)
            end
            NodeUtils:removeSwallow()
            self._isRespUpdate = false -- 结束状态还原
        end
        
        local function addOnceFun() 
            self:addCcbToStagePos(type, stagePos)
            TimerManager:addOnce(200, overCall, self)
        end

        NodeUtils:addSwallow()
        self:addCcbDianLiang(stagePos) -- 点亮炸开特效
        TimerManager:addOnce(300, addOnceFun, self)
    elseif self._actionType == 3 then -- 升阶
        -- 点击升阶特效
        local function addOnceFun()
            self:setBgRankStagePos(bgRank, militaryInfo)
            self:setBgRankLevel(bgRank, militaryInfo) 
            NodeUtils:removeSwallow()
            self._isRespUpdate = false -- 结束状态还原
        end

        NodeUtils:addSwallow()
        local midIcon = bgRank:getChildByName("midIcon")
        local levelTxt = bgRank:getChildByName("levelTxt")
        levelTxt:setString("")
        self:addCcbRankUp(midIcon)
        TimerManager:addOnce(300, addOnceFun, self)
    end
end

------
-- 加特效 ， 标记设为1
function MilitaryProjectPanel:addCcbToStagePos(soldierType, stagePos)
    if stagePos == nil then -- 判空
        return 
    end
    
    if stagePos.ccb == nil then
        stagePos.ccb = self:createUICCBLayer(self._typeToLightCcb[soldierType], stagePos)
        local size = stagePos:getContentSize()
        stagePos.ccb:setPosition(size.width/2, size.height/2)
    end
    stagePos.lightState = 1
end

------
-- 加点亮特效
function MilitaryProjectPanel:addCcbDianLiang(stagePos)
    if stagePos then
        local showCcb = self:createUICCBLayer("rgb-jgs-dianliang", stagePos, nil, nil, true)
        local size = stagePos:getContentSize()
        showCcb:setPosition(size.width/2, size.height/2)
    end
end

------
-- 等级刷新特效
function MilitaryProjectPanel:addCcbShuaXin(levelTxt, callFun)
    local showCcb = self:createUICCBLayer("rgb-jgs-shuaxin", levelTxt, nil, nil, true, callFun)
    local size = levelTxt:getContentSize()
    showCcb:setPosition(size.width/2, - 140)
end

------
-- 完成升级是否触发激活升阶爆炸特效
function MilitaryProjectPanel:addCcbJiHuoOnce(midIcon, soldierType)
    local showCcb = self:createUICCBLayer(self._typeToJiHuoCcb[soldierType], midIcon, nil, nil, true)
    local size = midIcon:getContentSize()
    showCcb:setPosition(size.width/2, size.height/2)
end

------
-- 点击升阶特效
function MilitaryProjectPanel:addCcbRankUp(midIcon)
    local showCcb = self:createUICCBLayer("rgb-jgs-sj", midIcon, nil, nil, true)
    local size = midIcon:getContentSize()
    showCcb:setPosition(size.width/2, size.height/2)
end


-- 设置当前的page状态，中间的信息状态
function MilitaryProjectPanel:setPagePanelShow(pagePanel, militaryInfo)  
    if militaryInfo == nil then
        return
    end
    local type    = militaryInfo.type    -- 类型（1骑兵，2刀兵，3枪兵，4弓兵）
    local segment = militaryInfo.segment -- 段数
    local level   = militaryInfo.level   -- 等级
    local rank    = militaryInfo.rank    -- 阶数
    
    local indexTxt = pagePanel:getChildByName("indexTxt")
    -- indexTxt:setString(string.format("%s == 段数%s, 等级%s, 阶数%s", self:getTextWord(510020 + type), segment, level, rank))
    indexTxt:setString("")
    -- 设置兵纹
    self:setSoldierNameImg(pagePanel, militaryInfo)

    -- 设置阶级图
    self:setSoldierRankImg(pagePanel, militaryInfo)

    -- 设置显示中间复杂图形
    self:setMidCardShow(pagePanel, militaryInfo)

    -- 设置待机特效，
    self:setStandByCcbShow(pagePanel, militaryInfo)
end



-- 设置待机特效
function MilitaryProjectPanel:setStandByCcbShow(pagePanel, militaryInfo)
    if self._isRespUpdate == true then
        return 
    end
    
    -- 后面
    local soldierType = militaryInfo.type
    if pagePanel.standByCcb01 ~= nil then
        pagePanel.standByCcb01:finalize()
        pagePanel.standByCcb01 = nil
    end

    if pagePanel.standByCcb01 == nil then
        pagePanel.standByCcb01 = self:createUICCBLayer(self._typeToStandbyCcb01[soldierType], pagePanel)
        pagePanel.standByCcb01:setPosition(319, 104)
        pagePanel.standByCcb01:setLocalZOrder(-1)
    end

    -- 前面
    local bgRank = pagePanel:getChildByName("bgRank"..militaryInfo.rank)

    if pagePanel.standByCcb02 ~= nil then
        pagePanel.standByCcb02:finalize()
        pagePanel.standByCcb02 = nil
    end

    if pagePanel.standByCcb02 == nil then
        local midIcon = bgRank:getChildByName("midIcon")
        pagePanel.standByCcb02 = self:createUICCBLayer(self._typeToStandbyCcb02[soldierType], midIcon)
        pagePanel.standByCcb02:setPosition(midIcon:getContentSize().width/2, midIcon:getContentSize().height/2)
    end
end

-- 设置页面亮点标记
function MilitaryProjectPanel:setIndexPanelShow(curDataIndex)
    local showIcon = self._indexPanel:getChildByName("showIcon")
    for i = 1, self._expandPageView:getPageCount() do
        if i ==  curDataIndex then
            local indexIcon = self._indexPanel:getChildByName("indexIcon".. i)
            showIcon:setPositionX(indexIcon:getPositionX())
            break
        end
    end
end

-- 设置消耗材料-- 和限制条件
function MilitaryProjectPanel:setMaterialPanelShow(curDataIndex)
    -- 初始化
    self._reinforceBtn:setVisible(true)
    self._listView:setVisible(true)
    self._showTxt:setVisible(true)

    self._nextCtrlTxt:setString("") -- 下一次升阶文本

    self._state  = true
    self._showStr= ""
    self._tipStr = ""

    
    local soldierType = self:indexToType(curDataIndex)
    local militaryInfo = self._militaryProxy:getMilitaryInfoByType(soldierType)
    local segment = militaryInfo.segment -- 段数 
    local level   = militaryInfo.level   -- 等级
    local rank    = militaryInfo.rank    -- 阶数

    -- 是否可以升级，读取当前等级的下一级
    local configInfo = ConfigDataManager:getInfoFindByThreeKey(ConfigData.MilitaryLevelConfig , "type", soldierType, "level", level + 1, "rank", rank)
    

    -- 增加的总四维属性
    if self._isRespUpdate == true and (self._actionType == 2 or self._actionType == 3) then
        self:setAllAttriShowWithCcb(militaryInfo, soldierType)
    else
        self:setAllAttriShow(militaryInfo, soldierType)
    end

    -- 增加的总后制
    self:setAllLastCtrlShow()

    -- 判断是否满阶满级显示提示
    self:maxRankLevelShow(militaryInfo)
    
    if configInfo ~= nil then
        -- 下一级增加的属性
        if self._isRespUpdate == true and (self._actionType == 2 or self._actionType == 3) then
            self:setDiffAttriShowWithCcb(soldierType)
        else
            self:setDiffAttriShow(soldierType)
        end

        -- 设置按钮文字
        self._reinforceBtn:setTitleText(self:getTextWord(510002))

        -- 设置消耗物品
        local consumeInfos = StringUtils:jsonDecode(configInfo.consume)
        self:renderListView(self._listView, TableUtils:splitData(consumeInfos, 2), self, self.renderItem, nil, nil, 0)
        
        -- 升级数据相关
        self._state, self._showStr, self._tipStr = self:isCanLevelUp(configInfo)
        self._showTxt:setString(self._showStr)
    else
        -- 升阶无下一级属性
        self:setDiffAttriShow(soldierType)

        configInfo = ConfigDataManager:getInfoFindByTwoKey(ConfigData.MilitaryInstituteConfig, "type", soldierType, "rank", rank + 1)
        if configInfo ~= nil then -- 下一阶
            -- 设置按钮文字
            self._reinforceBtn:setTitleText(self:getTextWord(510003))
            
            -- 设置消耗物品
            local consumeInfos = StringUtils:jsonDecode(configInfo.consume)
            self:renderListView(self._listView, TableUtils:splitData(consumeInfos, 2), self, self.renderItem, nil, nil, 0)
        
            -- 升阶数据相关
            self._state, self._showStr, self._tipStr = self:isCanRankUp(configInfo)
            self._showTxt:setString(self._showStr)

            -- 下一次升阶加成后制值
            self:setNextCtrlShow(soldierType)
        elseif configInfo == nil then
            logger:info("已满阶，已满级")
            self._reinforceBtn:setVisible(false)
            -- 设置消耗物品
            self._listView:setVisible(false)
            -- 数据相关
            self._showTxt:setVisible(false)
        end
    end
end

------
-- 根据页面的index获取兵种类型
function MilitaryProjectPanel:indexToType(index)
    return self._indexToTypeMap[index]
end

------
-- 点击按钮
function MilitaryProjectPanel:onReinforceBtn(sender)
    -- 条件不足直接谈提示
    if self._state == false then
        self:showSysMessage(self._tipStr)
        return 
    end
    
    local data = {}
    data.type = self:getCurSoldierType()
    logger:info("当前操作类型:"..data.type)
    
    local titleText = sender:getTitleText()
    if titleText == self:getTextWord(510002) then
        -- 升段
        self._militaryProxy:onTriggerNet510000Req(data)
    else
        -- 升阶
        self._militaryProxy:onTriggerNet510001Req(data)
    end

    -- 设置状态 
    self._actionType = self._militaryProxy:getActionStateByType(data.type)
    logger:info("按钮，当前状态为："..self._actionType)
end

------
-- 获取当前兵种类型
function MilitaryProjectPanel:getCurSoldierType()
    local curDataIndex = self._expandPageView:getCurDataIndex()
    local soldierType = self:indexToType(curDataIndex)
    return soldierType
end


------
-- 更新材料
function MilitaryProjectPanel:onUpdateListView()
    local level       = self._militaryInfo.level   -- 等级
    local rank        = self._militaryInfo.rank    -- 阶数
    local soldierType = self._militaryInfo.type
    local configInfo = ConfigDataManager:getInfoFindByThreeKey(ConfigData.MilitaryLevelConfig , "type", soldierType, "level", level + 1, "rank", rank)
    
    if configInfo ~= nil then
        -- 设置消耗物品
        local consumeInfos = StringUtils:jsonDecode(configInfo.consume)
        self:renderListView(self._listView, TableUtils:splitData(consumeInfos, 2), self, self.renderItem, nil, nil, 0)
    else
        configInfo = ConfigDataManager:getInfoFindByTwoKey(ConfigData.MilitaryInstituteConfig, "type", soldierType, "rank", rank + 1)
        if configInfo ~= nil then -- 下一阶
            -- 设置消耗物品
            local consumeInfos = StringUtils:jsonDecode(configInfo.consume)
            self:renderListView(self._listView, TableUtils:splitData(consumeInfos, 2), self, self.renderItem, nil, nil, 0)

        elseif configInfo == nil then
        end
    end
end



------
-- 设置消耗材料
function MilitaryProjectPanel:renderItem(item, data, index)
    for i = 1, 2 do
        local panel = item:getChildByName("panel0"..i)
        local info = data[i]
        if info then
            panel:setVisible(true)
            self:setIconAndTxt(panel, info)
            local nameTxt = panel:getChildByName("nameTxt")
            local hadTxt  = panel:getChildByName("hadTxt")
            local needTxt = panel:getChildByName("needTxt")

            nameTxt:setString(ConfigDataManager:getConfigByPowerAndID(info[1], info[2]).name)

            local hadNum = self._roleProxy:getRolePowerValue(info[1], info[2])
            
            local numColor = ColorUtils.wordGreenColor
            if hadNum < info[3] then
                numColor = ColorUtils.wordRedColor
            end
            hadTxt:setColor(numColor)
            hadTxt:setString( StringUtils:formatNumberByK3(hadNum) )
            needTxt:setString( "/"..StringUtils:formatNumberByK3(info[3]))
            NodeUtils:fixTwoNodePos(hadTxt, needTxt)
        else
            panel:setVisible(false)
        end
    end
end


function MilitaryProjectPanel:setIconAndTxt(panel, info)
    local iconData = {}
    iconData.power  = info[1]
    iconData.typeid = info[2]
    iconData.num    = self._roleProxy:getRolePowerValue(info[1], info[2])
    if panel.uiIcon == nil then
        panel.uiIcon = UIIcon.new(panel, iconData, false, self, nil, false)
        panel.uiIcon:setPosition(60, 50)
    else
        panel.uiIcon:updateData(iconData)
    end
end

------
-- 网络回调
function MilitaryProjectPanel:onUpdateProjecePanel()
    self._isRespUpdate = true
    self:pageCallBack()
    -- self._isRespUpdate = false
end

------
-- 设置差异属性显示
function MilitaryProjectPanel:setDiffAttriShow(soldierType)
    -- 下一级增加的属性，必有值
    local textShow = self._militaryProxy:getDiffAttriTable(soldierType)
    local attriTmpKeyList = self:getAttriInitKeyList()

    for i = 1, #attriTmpKeyList do
        local attrAddNum = self._attributePanel:getChildByName("attrAddNum"..i)
        if textShow[attriTmpKeyList[i]] == nil then
            attrAddNum:setString("")
        else
            local showStr = self._roleProxy:attriToShowStr( attriTmpKeyList[i], textShow[attriTmpKeyList[i]] )
            attrAddNum:setString( string.format(self:getTextWord(510011), showStr))
        end
        local attrAllNum = self._attributePanel:getChildByName("attrAllNum"..i)

        local ccbSp = self._attributePanel:getChildByName("ccbSp"..i)
        ccbSp:setVisible(attrAddNum:getString() ~= "")

        NodeUtils:fixTwoNodePos(attrAllNum, ccbSp, 10)
        NodeUtils:fixTwoNodePos(ccbSp, attrAddNum, 10)
    end
end

------
-- 设置属性显示， 特效同步
function MilitaryProjectPanel:setDiffAttriShowWithCcb(soldierType)
    -- 下一级增加的属性，必有值
    local textShow = self._militaryProxy:getDiffAttriTable(soldierType)
    local attriTmpKeyList = self:getAttriInitKeyList()

    local function setDiffAttri()
        for i = 1, #attriTmpKeyList do
            local attrAddNum = self._attributePanel:getChildByName("attrAddNum"..i)
            if textShow[attriTmpKeyList[i]] == nil then
                attrAddNum:setString("")
            else
                local showStr = self._roleProxy:attriToShowStr( attriTmpKeyList[i], textShow[attriTmpKeyList[i]] )
                attrAddNum:setString( string.format(self:getTextWord(510011), showStr))
            end
        end
    end
    TimerManager:addOnce(700, setDiffAttri, self)
end


------ 
-- 增加的总四维属性
function MilitaryProjectPanel:setAllAttriShow(militaryInfo, soldierType)
    local textShow = {}
    
    local segment = militaryInfo.segment -- 段数
    local level   = militaryInfo.level   -- 等级
    local rank    = militaryInfo.rank    -- 阶数

    textShow = self._militaryProxy:getCurAttriTable(soldierType)
    local attriTmpKeyList = self:getAttriInitKeyList()
    -- 设置属性
    for i = 1, #attriTmpKeyList do
        local attrAddNum = self._attributePanel:getChildByName("attrAllNum"..i)
        if textShow[attriTmpKeyList[i]] == nil then
            attrAddNum:setString("+"..0)
        else
            local showStr = self._roleProxy:attriToShowStr( attriTmpKeyList[i], textShow[attriTmpKeyList[i]] )
            attrAddNum:setString("+"..showStr)
        end
    end

end

-- 增加的总四维属性添加特效版本
function MilitaryProjectPanel:setAllAttriShowWithCcb(militaryInfo, soldierType)
    local textShow = {}

    local segment = militaryInfo.segment -- 段数
    local level   = militaryInfo.level   -- 等级
    local rank    = militaryInfo.rank    -- 阶数

    textShow = self._militaryProxy:getCurAttriTable(soldierType)
    local attriTmpKeyList = self:getAttriInitKeyList()

    --- 设置
    local function setAllAttri()
        for i = 1, #attriTmpKeyList do
            local attrName = self._attributePanel:getChildByName("attrName"..i)
            local attrAllNum = self._attributePanel:getChildByName("attrAllNum"..i)
            local attrAddNum = self._attributePanel:getChildByName("attrAddNum"..i)

            if textShow[attriTmpKeyList[i]] == nil then
                attrAllNum:setString("+"..0)
            else
                local showStr = self._roleProxy:attriToShowStr( attriTmpKeyList[i], textShow[attriTmpKeyList[i]] )
                attrAllNum:setString("+"..showStr)
            end


            local ccbSp = self._attributePanel:getChildByName("ccbSp"..i)
            ccbSp:setVisible(attrAddNum:getString() ~= "")
            NodeUtils:fixTwoNodePos(attrAllNum, ccbSp, 10)
            NodeUtils:fixTwoNodePos(ccbSp, attrAddNum, 10)
        end
    end
    
    local function showCcb()
        for i = 1, #attriTmpKeyList do
            local attrName = self._attributePanel:getChildByName("attrName"..i)
            local showCcb = self:createUICCBLayer("rgb-jgs-shuaxin", attrName, nil, nil, true)
            showCcb:setPosition(100, - 140)
        end
    end
    TimerManager:addOnce(500, showCcb, self)
    TimerManager:addOnce(700, setAllAttri, self)
end

-- 增加的总后制
function MilitaryProjectPanel:setAllLastCtrlShow()
    self._lastCtrlTxt:setString(self._militaryProxy:getAllLastCtrlNum())
end


-- 下一次升阶后置加成
function MilitaryProjectPanel:setNextCtrlShow(soldierType)
    local nextCtrl = self._militaryProxy:getNextLastCtrlByType(soldierType)

    self._nextCtrlTxt:setString("+"..nextCtrl)
    
    NodeUtils:fixTwoNodePos(self._lastCtrlTxt, self._nextCtrlTxt, 2)
end

function MilitaryProjectPanel:getRankConfiInfo(soldierType, rank)
    return ConfigDataManager:getInfoFindByTwoKey(ConfigData.MilitaryInstituteConfig, "type", soldierType, "rank", rank)
end

------
-- 状态和描述
function MilitaryProjectPanel:isCanLevelUp(configInfo)
    local preRank	= StringUtils:jsonDecode(configInfo.preRank ) -- 前置阶级
    local condition = configInfo.condition -- 升级条件
    
    local state   = true -- 状态
    local showStr = ""   -- 显示条件
    local tipStr  = ""   -- 点击提示

    if #preRank > 0 then
        local curRank    = self._militaryProxy:getSoldierRank(preRank[1])
        local targetRank = preRank[2]
        
        if curRank < targetRank then
            showStr = string.format(self:getTextWord(510004), self:getTextWord(510020 + preRank[1]), targetRank)
            tipStr = self:getTextWord(510006) -- "指定兵种阶级不足，无法升级"
            state = false 
        end
    end

    local roleLevel = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    local targetLevel = condition
    if roleLevel < targetLevel then
        showStr = string.format(self:getTextWord(510005), targetLevel) -- "需要主公等级达到%s级"
        tipStr = self:getTextWord(510007) -- "主公的等级不够，无法升级"
        state = false
    end

    return state, showStr, tipStr
end

------
-- 是否达到可升阶条件
function MilitaryProjectPanel:isCanRankUp(configInfo)
    local state   = true -- 状态
    local showStr = ""   -- 显示条件
    local tipStr  = ""   -- 点击提示

    local armKindsConfig = ConfigDataManager:getConfigData(ConfigData.ArmKindsConfig)

    local condition = StringUtils:jsonDecode(configInfo.condition) 
    for i = 1, #condition do
        local info = condition[i]
        local soldierId = info[1] -- 兵种表id
        local soldierNum = info[2] -- 兵种数量
        local soldierName = armKindsConfig[soldierId].name
        local soldierHadNum = self._roleProxy:getRolePowerValue(406, soldierId) 
        local str = string.format(self:getTextWord(510009), soldierName, soldierNum, soldierHadNum) -- "%s数量达到%s（已有%s）"
        showStr = showStr..str
        -- 拥有兵种数量
        local curNum = self._roleProxy:getRolePowerValue(GamePowerConfig.Soldier, soldierId)
        if curNum < soldierNum then
            if state then
                state = false
            end
        end
    end
    if state == false then
        tipStr = self:getTextWord(510010)
    else
        showStr = ""
        tipStr  = ""
    end
    return state, showStr, tipStr
end

function MilitaryProjectPanel:onLeftBtn()
    local index = self._pageView:getCurPageIndex()
    local targetIndex = index - 1
    if targetIndex < 0 then
        targetIndex = 0
    end
    self._pageView:scrollToPage(targetIndex)

    local function handler()
        self._expandPageView:onPageViewListenerHandler() 
    end
    TimerManager:addOnce(200, handler, self)
end


function MilitaryProjectPanel:onRightBtn()
    local index = self._pageView:getCurPageIndex()
    local targetIndex = index + 1
    if targetIndex > 3 then
        targetIndex = 3
    end
    self._pageView:scrollToPage(targetIndex)

    local function handler()
        self._expandPageView:onPageViewListenerHandler() 
    end
    TimerManager:addOnce(200, handler, self)
end

function MilitaryProjectPanel:onLastCtrlBtn()
    local panel = self:getPanel(MilitaryLastCtrlPanel.NAME)
    panel:show()
end

function MilitaryProjectPanel:onAfterActionHandler()
    self._mainPanel:setVisible(true)
end

-- 判断是否满阶满级显示提示
function MilitaryProjectPanel:maxRankLevelShow(militaryInfo)
    local type    = militaryInfo.type -- 类型 
    local level   = militaryInfo.level   -- 等级
    local rank    = militaryInfo.rank    -- 阶数
    
    local maxLevel = self._militaryProxy:getMaxLevelByType(type, MilitaryProjectPanel.MaxRank)
    if maxLevel == level and MilitaryProjectPanel.MaxRank == rank then
        self._maxRankTxt:setString(self:getTextWord(510020 + type).. self:getTextWord(510025))
    else
        self._maxRankTxt:setString("")
    end
end

-- 获取属性排序表
function MilitaryProjectPanel:getAttriTmpKeyList(data)
    local tmpKey = {}
    for key, value in pairs(data) do
        table.insert(tmpKey, key)
    end 

    table.sort(tmpKey,
    function (a , b)
        return a<b
    end
    )
    return tmpKey
end

function MilitaryProjectPanel:getAttriInitKeyList()
    local configInfo = ConfigDataManager:getConfigById(ConfigData.MilitaryLevelConfig, 1)
    local textShow = self._militaryProxy:getAttriTableByConfigInfo(configInfo)
    local attriTmpKeyList = self:getAttriTmpKeyList(textShow) 
    return attriTmpKeyList
end

-- 属性图标和名字设置
function MilitaryProjectPanel:setAttriNameIcon() 
    local attriTmpKeyList = self:getAttriInitKeyList() 
    
    for i = 1 , #attriTmpKeyList do
        local attriType = attriTmpKeyList[i]
        local info = ConfigDataManager:getConfigById(ConfigData.ResourceConfig, attriType)
        local nameTxt = self._attributePanel:getChildByName("attrName"..i)
        nameTxt:setString(info.name)
        
        local attriImg = self._attributePanel:getChildByName("attr"..i)
        local dot = attriImg:getChildByName("dot")
        local url = string.format("images/newGui1/%s.png", GlobalConfig.SmallIconRefPath[info.icon])
        TextureManager:updateImageView(dot, url)
    end
end


-- 设置增加特效
function MilitaryProjectPanel:setAttriUpCcb()
    for i = 1, 4 do
        local ccbSp = self._attributePanel:getChildByName("ccbSp"..i)
        if ccbSp.jiantou == nil then
            local ccb = self:createUICCBLayer("rgb-jiantou", ccbSp)
            ccbSp:setScale(0.75)
            ccbSp.jiantou = ccb
        end
    end
end


function MilitaryProjectPanel:onHideHandler()
--    local pageView = self:getChildByName("mainPanel/pageView")
--    local pages = pageView:getPages()
--    for i, pagePanel in pairs(pages) do
--        if pagePanel.jihuoForCcb ~= nil then
--            pagePanel.jihuoForCcb:finalize()
--            pagePanel.jihuoForCcb = nil
--        end
--        if pagePanel.standByCcb01 ~= nil then
--            pagePanel.standByCcb01:finalize()
--            pagePanel.standByCcb01 = nil
--        end
--        if pagePanel.standByCcb02 ~= nil then
--            pagePanel.standByCcb02:finalize()
--            pagePanel.standByCcb02 = nil
--        end
--    end
end
