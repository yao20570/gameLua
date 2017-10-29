
FightingCapMainPanel = class("FightingCapMainPanel", BasicPanel)
FightingCapMainPanel.NAME = "FightingCapMainPanel"

function FightingCapMainPanel:ctor(view, panelName)
    FightingCapMainPanel.super.ctor(self, view, panelName,true)
    
    self._highestEquipQuality = 4 --装备最高品质
    self._highestPartsQuality = 5 --配件最高品质
    self._highestPartsRemLv = 10  --配件最高改造等级
    self._roleFightingRanking = 0 --角色战力排名
    self._fightingRankLimit = 1   --战力排行榜上榜限制

    self:setUseNewPanelBg(true)
end

function FightingCapMainPanel:finalize()
    FightingCapMainPanel.super.finalize(self)
end

function FightingCapMainPanel:initPanel()
    FightingCapMainPanel.super.initPanel(self)
    self:setBgType(ModulePanelBgType.NONE)
    
    self:setTitle(true,"fightCap", true) --战斗力

    self:initConfigData()
    self:initPanelItems()
end

function FightingCapMainPanel:doLayout()
    
    local topPanel = self:getChildByName("topPanel")
    NodeUtils:adaptiveUpPanel(topPanel,nil,GlobalConfig.tabsHeight-50)
    NodeUtils:adaptiveListView(self._listView,GlobalConfig.downHeight, topPanel,0)
end

--显示界面时调用
function FightingCapMainPanel:onShowHandler(data)
    if self._listView ~= nil then
        self._listView:jumpToTop()
        self._roleInfo = self:getRoleInfo()
        self:updatePanel()
        self:updateRankHandler()
    end 
end 
--数据更新
function FightingCapMainPanel:updateData(data)
    self:updatePanel()
end 
function FightingCapMainPanel:updateRankHandler()
    local rankProxy = self:getProxy(GameProxys.Rank)
    local roleRankInfo = rankProxy:getPlayerData(1)
    local ranking = roleRankInfo.rank
    self._roleFightingRanking = ranking
--    print("role rank===",ranking)
    self:updateTopPanel()
end 
--初始化配置表数据
function FightingCapMainPanel:initConfigData()
    local fightingConfig = ConfigDataManager:getConfigData(ConfigData.FightValueConfig)
    for k,v in pairs(fightingConfig) do 
        if v.type == 10 then
            table.remove(fightingConfig,k)
            break
        end 
    end 
    table.sort(fightingConfig,function(a,b) return a.sort < b.sort end )
    self._fightingConfig = fightingConfig
end 
function FightingCapMainPanel:initPanelItems()
    self._fightImg = self:getChildByName("topPanel/fightImg")
    self._labelFighting = self:getChildByName("topPanel/Label_fighting")
    self._labelPower = self:getChildByName("topPanel/atlaPower")--国力
    self._labelRanking = self:getChildByName("topPanel/Label_ranking")
    local btnRankList = self:getChildByName("topPanel/Button_rankList")
    self._listView = self:getChildByName("ListView")
    self:addTouchEventListener(btnRankList,self.onBtnRankListClicked)
    btnRankList:setTitleText(self:getTextWord(139))
    local Label_2 = self:getChildByName("topPanel/Label_2")
    Label_2:setString(self:getTextWord(140))
    
    if not VersionManager:isShowRank() then
        btnRankList:setVisible(false)
    end
end 
function FightingCapMainPanel:updatePanel()
    self:updateTopPanel()
    self:updateListView()
end 
function FightingCapMainPanel:updateTopPanel()
    local roleInfo = self._roleInfo
    local fighting = roleInfo.fightingCap
    local limitRanking = self._fightingRankLimit
    local ranking = self._roleFightingRanking
    local fightingStr = fighting
    if fighting >= 1000 then
        local fighting2 = StringUtils:formatNumberByK3(fighting)
        fightingStr = string.format("%s(%s)",tostring(fighting),fighting2)
    end 
    local rankingStr = "NO."..ranking
    if ranking == 0 then
        rankingStr = self:getTextWord(1701)
    end 
    self._labelPower:setString(fighting)
    self._labelFighting:setString(fightingStr)
    self._labelRanking:setString(rankingStr)
    NodeUtils:alignNodeL2R(self._fightImg, self._labelFighting, 5)
end 
function FightingCapMainPanel:updateListView()
    if self._fightingConfig ~= nil then
        self:renderListView(self._listView, self._fightingConfig, self, self.renderItemPanel)
    end 
end 

function FightingCapMainPanel:renderItemPanel(itemPanel,info)
    local itemChildren = self:getItemChildren(itemPanel)
    --设置itemPanel的回调
    itemPanel.info = info
    self:addTouchEventListener(itemPanel,self.onItemClicked)
    
    --图标
    local iconInfo = {}
    iconInfo.power = GamePowerConfig.Other
    iconInfo.typeid = info.icon
    iconInfo.num = 0

    local icon = itemPanel.icon
    if icon == nil then
        local conImg = itemChildren.conImg
        icon = UIIcon.new(conImg,iconInfo,false)
        
        itemPanel.icon = icon
    else
        icon:updateData(iconInfo)
    end

    --名字
    itemChildren.labelName:setString(info.name)

    -- 感叹号
    local size = itemChildren.labelName:getContentSize()
    local x = itemChildren.labelName:getPositionX()
    itemChildren.tipImg:setPositionX(x + size.width + 20)
    
    itemChildren.tipImg:setEnabled(false)
    itemPanel.icon:setTouchEnabled(false)

    --进度条
    local percent = self:getProgressByType(info.type)
    itemChildren.progressBar:setPercent(percent)
    local pStr = string.format("%.1f%%",percent)
    itemChildren.labelPercent:setString(pStr)
    --描述
    local conTip = itemChildren.conTip
    local descStr = self:getItemDescByType(info)
    local size = conTip:getContentSize()
--    print("size ===",size.width,size.height)

    --TODO先屏蔽掉
    local labelDesc = conTip.labelDesc
    if labelDesc == nil then
        labelDesc = ComponentUtils:createRichLabel("",cc.size(size.width,0))
        labelDesc:setPosition(0, size.height)
        labelDesc:setAnchorPoint(cc.p(0,1))
        conTip:addChild(labelDesc)
        conTip.labelDesc = labelDesc
    end 
    labelDesc:setString(descStr)
    
    --按钮
    itemChildren.btnUpgrate.info = info
    
    if percent >= 100 then
        itemChildren.btnUpgrate:setEnabled(false)
    else
        itemChildren.btnUpgrate:setEnabled(true)
    end 
end 
--获取进度
function FightingCapMainPanel:getProgressByType(type)
    
    local roleInfo = self._roleInfo
    local roleLv = roleInfo.level
    local openPos = roleInfo.openPos --开启槽位数
    local partsOpenNum = roleInfo.openPartsNum
    if openPos == 0 then --没有开启容错
        openPos = 1
    end
    if partsOpenNum == 0 then
        partsOpenNum = 1
    end
    local percent = 0
    if     type == 1  then --统帅等级：统帅书
        local commanderLv = roleInfo.commanderLv  
        percent = commanderLv/roleLv 
    elseif type == 2  then --技能等级：技能书
        percent = roleInfo.avgSkillLv/roleLv
    elseif type == 3  then --装备品质： 仓库中的装备数
        percent = roleInfo.allQualitys == 0 and 0 or roleInfo.equipQualitys/roleInfo.allQualitys
    elseif type == 4  then --装备升级：<100:装备可升级，>=100,装备已满级
        percent = roleInfo.allEquipLvs == 0 and 0 or roleInfo.equipLvs/roleInfo.allEquipLvs
    elseif type == 5  then --配件品质：仓库中的配件数
        percent = roleInfo.partsQualitys/(self._highestPartsQuality*4*partsOpenNum)
    elseif type == 6  then --配件强化：所有穿戴的配件的强化等级、角色等级
        percent = roleInfo.partsStrenLvs/(roleLv*4*partsOpenNum)
    elseif type == 7  then --配件改造：所有穿戴配件的改造等级 == 10级
        percent = roleInfo.partsRemLvs/(self._highestPartsRemLv*4*partsOpenNum)
    elseif type == 8  then --科技等级：8项战斗科技等级、角色等级
        percent = roleInfo.avgScienceLv/roleLv
    elseif type == 9  then --主力部队：
        percent = roleInfo.strongestSoldiers/(roleInfo.maxSoldiers*roleInfo.openPos)
    elseif type == 10 then --部队编制：
    
    elseif type == 11 then --繁荣战力：
        percent = (roleInfo.booming/600)/10
    end 
    percent = percent*100
--    print("type,percent===",type,percent)
    if percent > 100 then
        percent = 100
    end 
    return percent
end 
--获取描述
function FightingCapMainPanel:getItemDescByType(info)
    local type = info.type
    local percent = self:getProgressByType(type)
    local roleInfo = self._roleInfo
    
    local line = {}
    if     type == 1 or type == 2 or type == 3 or type == 5 then
         --1统帅书、2技能书、3仓库装备、5仓库配件
        line[1] = {}
        line[2] = {}
        local num = roleInfo.comBookNum
        if type == 2 then
            num = roleInfo.skillBookNum
        elseif type == 3 then
            num = roleInfo.whEquipNum
        elseif type == 5 then
            num = roleInfo.whPartsNum
        end 
        line[1].content = info.info1
        line[1].foneSize = 20
        line[1].color = "#eed6aa"
        
        line[2].content = num
        line[2].foneSize = 20
        line[2].color = "#FFBD30"
    elseif type == 4 or type == 6 or type == 7 or type == 8 or type == 11 then 
        --4装备强化，6配件强化，7配件改造，8科技等级,11繁荣度
        line[1] = {}
        local tempStr = info.info2
        if percent >= 100 then
            tempStr = info.info3
        else
            if type == 4 then
                --材料不足
                if roleInfo.whEquipNum == 0 then
                    tempStr = info.info1
                end 
            elseif type == 8 then
                if roleInfo.isAllScienceOpen == false then
                    tempStr = info.info1
                end 
            end 
        end 
        line[1].content = tempStr
        line[1].foneSize = 20
        line[1].color = "#eed6aa"   
    elseif type == 9  then --主力部队：
        local soldierName = roleInfo.strongestSoldierName
        if soldierName == nil or percent >= 100 then
            local tempStr = info.info1
            if percent >= 100 then
                tempStr = info.info3
            end 
            line[1] = {}
            line[1].content = tempStr
            line[1].foneSize = 20
            line[1].color = "#eed6aa"
        else
            local max = roleInfo.maxSoldiers*roleInfo.openPos
            local short = max - roleInfo.strongestSoldiers
            
            local content1 = self:getTextWord(1703)
            local content2 = soldierName
            local content3 = self:getTextWord(1704)
            local content4 = short
            local content5 = self:getTextWord(1705)
            line[1] = {}
            line[1].content = content1
            line[1].foneSize = 20
            line[1].color = "#eed6aa"
            line[2] = {}
            line[2].content = content2
            line[2].foneSize = 20
            line[2].color = "#FFBD30"
            line[3] = {}
            line[3].content = content3
            line[3].foneSize = 20
            line[3].color = "#eed6aa"
            line[4] = {}
            line[4].content = content4
            line[4].foneSize = 20
            line[4].color = "#FFBD30"
            line[5] = {}
            line[5].content = content5
            line[5].foneSize = 20
            line[5].color = "#eed6aa"
        end 
        
    elseif type == 10 then --部队编制：
  
    end 
    local lines = {line}
--    local texts = StringUtils:getHtmlByLines(lines)
    return lines --texts
end 
--获取item的子节点
function FightingCapMainPanel:getItemChildren(item)
    local itemChildren = {}
    itemChildren.conImg= item:getChildByName("Image_icon")
    itemChildren.labelName = item:getChildByName("Label_name")
    itemChildren.progressBar = item:getChildByName("ProgressBar")
    itemChildren.labelPercent = item:getChildByName("Label_percent")
    itemChildren.conTip = item:getChildByName("con_tip")
    itemChildren.btnUpgrate = item:getChildByName("Button_upgrate")
    itemChildren.tipImg = item:getChildByName("tipImg")
    self:addTouchEventListener(itemChildren.btnUpgrate,self.onBtnUpgrateClicked)
    return itemChildren
end 
--获取角色数据
function FightingCapMainPanel:getRoleInfo()
    local data = {}
    local roleProxy = self:getProxy(GameProxys.Role)
    local soldierProxy = self:getProxy(GameProxys.Soldier)
    --角色等级
    data.level = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    --统帅等级
    data.commanderLv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_commandLevel)
    --最高战力
    data.fightingCap = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_highestCapacity)
    --繁荣度
    data.booming = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_boom)
    --带兵数量上限
    data.maxSoldiers = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)
    --开启槽位数
    data.openPos = #soldierProxy:getTroopsOpenPosList()
    --最强兵（战斗力最高）的数量及名字
    local soldier = self:getStrongestSoldier()
    data.strongestSoldiers = soldier.num
    data.strongestSoldierName = soldier.name
    --角色平均技能等级
    data.avgSkillLv = self:getRoleSkillInfo()
    --装备品质/等级总和
    local equipInfo = self:getWearEquipInfo()
    data.equipQualitys = equipInfo.qualitys
    data.equipLvs = equipInfo.equipLvs
    data.allQualitys = equipInfo.allQualitys
    data.allEquipLvs = equipInfo.allEquipLvs
    --仓库中装备数
    data.whEquipNum = equipInfo.whEquipNum
    --配件品质/等级/改造之和
    local partsInfo = self:getWearPartsInfo()
    data.partsQualitys = partsInfo.qualitys
    data.partsStrenLvs = partsInfo.strenLvs
    data.partsRemLvs   = partsInfo.remLvs
    --仓库的配件数
    data.whPartsNum = partsInfo.whPartsNum
    --配件开启部位数
    data.openPartsNum = self:getPartsOpenNum(data.level)
    --科技平均等级
    local scienceInfo = self:getAvgScienceLv()
    data.avgScienceLv = scienceInfo.avgScienceLv
    data.isAllScienceOpen = scienceInfo.isAllScienceOpen
    --统帅书，技能书
    data.comBookNum = roleProxy:getRolePowerValue(401,4013)
    data.skillBookNum = roleProxy:getRolePowerValue(401,4012)
    
    return data
end

--穿戴装备：品质/等级之和
function FightingCapMainPanel:getWearEquipInfo()
    local equipProxy = self:getProxy(GameProxys.Equip)
    local heroProxy = self:getProxy(GameProxys.Hero)
    local wearEquips = equipProxy:getWearEquips()--所有穿戴的装备
    local qualitys = 0 --当前上阵英雄的实际星数总和
    local equipLvs = 0 --当前上阵英雄的实际等级之和
    local allQualitys = 0 --当前上阵英雄的可以达到的最大星数之和
    local allEquipLvs = 0 --当前上阵英雄可以升的最大级数之和

    local warehouseEquip = heroProxy:getAllHeroData()
    local heroNum = 0
    for k,v in pairs(warehouseEquip) do
        if v.heroPosition == 0 and heroProxy:isExpCar(v) == false then
            heroNum = heroNum + 1
            local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, v.heroId)
            allQualitys = allQualitys + config.color
            allEquipLvs = allEquipLvs + config.lvmax
        end
    end
    local temp = {}
    temp.qualitys = qualitys
    temp.equipLvs = equipLvs
    temp.allQualitys = allQualitys
    temp.allEquipLvs = allEquipLvs
    temp.whEquipNum = heroNum
    return temp
end 
--穿戴配件：品质/等级/改造之和
function FightingCapMainPanel:getWearPartsInfo()
    local partsProxy = self:getProxy(GameProxys.Parts)
    local wearParts = partsProxy:getOrdnanceEquipedInfos()
    local whParts = partsProxy:getOrdnanceUnEquipInfos()
    local qualitys = 0
    local strenLvs = 0
    local remLvs = 0
    local whPartsNum = 0
    if whParts ~= nil then
        whPartsNum = #whParts
    end
    if wearParts ~= nil then
        for _,v in pairs(wearParts)do
            qualitys = qualitys + v.quality
            strenLvs = strenLvs + v.strgthlv
            remLvs   = remLvs   + v.remoulv
        end
    end 
    local temp = {}
    temp.qualitys = qualitys
    temp.strenLvs = strenLvs
    temp.remLvs = remLvs
    temp.whPartsNum = whPartsNum
    return temp
end 
--配件部位开启数量
function FightingCapMainPanel:getPartsOpenNum(level)
    local count = 0
    local configData = ConfigDataManager:getConfigData(ConfigData.OrdnancePartConfig)
    if configData ~= nil then
        for _,v in pairs(configData)do
            if level >= v.openlv then
                count = count + 1
            end 
        end
    end 
    return count
end 
--获取科技平均等级
function FightingCapMainPanel:getAvgScienceLv()
    local buildingProxy = self:getProxy(GameProxys.Building)
    local buildingInfo  = buildingProxy:getBuildingInfo(8, 12)
    local temp = {}
    if buildingInfo == nil then
        temp.avgScienceLv = 0
        temp.isAllScienceOpen = false
        return temp
    end 
    local detailInfo = buildingInfo.buildingDetailInfos
    local scienceMuseumLv = buildingInfo.level --科技馆等级
    local types = {2,3,5,6,8,9,11,12}
    local scienceLvs = 0
    local isAllScienceOpen = false
    local configData = ConfigDataManager:getConfigData(ConfigData.MuseumConfig)
    for _,v in pairs(types) do
        local limitLv = 1
        for _,cv in pairs(configData) do
            if cv.scienceType == v then
                limitLv = cv.reqSCenterLv
                break
            end 
        end 
        for _,dv in pairs(detailInfo) do
            if dv.typeid == v then
                scienceLvs = scienceLvs + dv.num
                if scienceMuseumLv >=limitLv and scienceMuseumLv > dv.num then
                    isAllScienceOpen = true
                end 
                break
            end 
        end 
    end 
    local avgScienceLv =  scienceLvs/8
    temp.avgScienceLv = avgScienceLv
    temp.isAllScienceOpen = isAllScienceOpen
    return temp
end 
--角色技能等级数据
function FightingCapMainPanel:getRoleSkillInfo()
    local skillProxy = self:getProxy(GameProxys.Skill)
    local skillList = skillProxy:getSkillListData()
    local avgSkillLv = 0
    if skillList ~= nil and #skillList > 0 then
        for _,v in pairs(skillList) do
            avgSkillLv = avgSkillLv + v.level
        end 
        avgSkillLv = avgSkillLv/#skillList
    end 
    return avgSkillLv
end 
--获取最强兵及数量
function FightingCapMainPanel:getStrongestSoldier()
    local temp = {}
    temp.num = 0
    local proxy = self:getProxy(GameProxys.Building)
    local dataList = proxy:getCanProductIdList(BuildingTypeConfig.BARRACK)
    local fightSort = {}
    if #dataList == 0 then
        return temp
    end
    local soldierProxy = self:getProxy(GameProxys.Soldier)
    for k,v in pairs(dataList) do    
        local fight = soldierProxy:getOneSoldierFightById(v)
        local num = soldierProxy:getSoldierCountById(v)
        table.insert(fightSort,{typeid = v,fight = fight,num = num})
--        print("fightSort===",k,v,fight,num)
    end
    table.sort(fightSort, function (a,b) return (a.fight > b.fight) end)
    if #fightSort > 0 then
        local data = fightSort[1]
        temp.num = data.num
        local configData = ConfigDataManager:getConfigData(ConfigData.ArmProductConfig)
        for _,v in pairs(configData) do 
            if v.ID == data.typeid then
                temp.name = v.name
                break
            end 
        end 
    end 
    return temp
end 
------------------回调函数定义-------------------
-- 排行榜按钮
function FightingCapMainPanel:onBtnRankListClicked(sender)
    -- print("onBtnRankListClicked")
    -- local data = {moduleName = "RankModule"}  --排行榜
    ModuleJumpManager:jump(ModuleName.RankModule)
end

-- 前往按钮 跳转
function FightingCapMainPanel:onBtnUpgrateClicked(sender)
--    print("onBtnUpgrateClicked",sender.info.name)
    local info = sender.info
    local limitLv = info.lvneed
    local roleProxy = self:getProxy(GameProxys.Role)
    --角色等级
    local roleLv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    if roleLv < limitLv then
        local tipWords = self:getTextWord(1702)
        local tipStr = string.format(tipWords,limitLv)
        self:showSysMessage(tipStr)
        return
    end 
    local module = info.linktype
    local panel = info.reaches
    local data = {}
    data.moduleName = module

    data.extraMsg = {}
    data.extraMsg.panel = panel


    if info.type == 8 or info.type == 9 or info.type == 10 then
        local buildingProxy = self:getProxy(GameProxys.Building)
        if info.type == 8 then 
            buildingProxy:setBuildingPos(8,12) 
            if self._roleInfo.isAllScienceOpen == false then
                data.extraMsg.panel = "ScienceBuildPanel"
            end
        else
            buildingProxy:setBuildingPos(9, 2)
        end
    end 
    -- self:dispatchEvent(FightingCapEvent.SHOW_OTHER_EVENT, data)
    -- print("module,index====",data.moduleName,data.extraMsg.panel)

    ModuleJumpManager:jump(data.moduleName, data.extraMsg.panel)

end


-- 战力列表tip
function FightingCapMainPanel:onItemClicked(sender)
   -- print("战力 onItemClicked name="..sender.info.name..",clickinfo"..sender.info.clickinfo)

    local content1 = sender.info.clickinfo
    local line1 = {{content = content1, foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}
    local lines = {}
    table.insert(lines, line1)   
    
    local parent = self:getParent()
    local uiTip = UITip.new(parent)
    uiTip:setAllTipLine(lines)  
    
end 

-- function FightingCapMainPanel:onClosePanelHandler()
--     self:hide()    
-- end
--发送关闭系统消息
function FightingCapMainPanel:onClosePanelHandler()
    self.view:dispatchEvent(FightingCapEvent.HIDE_SELF_EVENT)
end