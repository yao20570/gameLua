-- 阵型加成

UIWarBookFight = class("UIWarBookFight", BasicComponent)
UIWarBookFight.DirType_Left = 1
UIWarBookFight.DirType_Right = 2
UIWarBookFight.ResPathArr = {"images/newGui1/TxtZhenQiDao.png", "images/newGui1/TxtZhenDaoQiang.png", "images/newGui1/TxtZhenQiangGong.png"}
UIWarBookFight.SkillIconPathArr = {"images/newGui1/IconShuXingXuanYun.png", "images/newGui1/IconShuXingXiXue.png", "images/newGui1/IconShuXingFanShang.png",
                                    "images/newGui1/IconShuXingQuSan.png", "images/newGui1/IconShuXingHuiXue.png", "images/newGui1/IconShuXingRanShao.png"}

-- uiData结构
-- {
--    isShowFirstAtkUI = false, --是否显示先手
--    rootUI = nil,
-- }
function UIWarBookFight:ctor(panel, uiData, dirType)
    self._panel = panel

    self._dirType = dirType

    self._isShowFirstAtkUI = uiData.isShowFirstAtkUI

    -- 是否显示先手
    local rootUI = uiData.rootUI
    self._rootUI = rootUI
        
    -- 先手UI
    self._firstAtkUI = rootUI:getChildByName("labFirstAtk")

    -- 先手UI背景
    self._firstAtkBgUI = rootUI:getChildByName("imgFirstAtk")

    -- 军阵名称
    self._imgZhen = rootUI:getChildByName("imgZhen")
    self._imgZhenBg = rootUI:getChildByName("imgZhen_0")

    -- 技能图标
    self._skillIconUI = { rootUI:getChildByName("skillIcon1"), rootUI:getChildByName("skillIcon2") }

    -- 技能名称
    self._skillNameUI = { rootUI:getChildByName("txtSkillName1"), rootUI:getChildByName("txtSkillName2") }

    -- 技能等级
    self._skillLevelUI = { rootUI:getChildByName("txtSkillLevel1"), rootUI:getChildByName("txtSkillLevel2") }

    -- 技能背景
    self._skillBgUI = { rootUI:getChildByName("imgBg1"), rootUI:getChildByName("imgBg2") }
end

function UIWarBookFight:finalize()

end

-- 更新自己的国策UI(根据自己的兵种类型)
function UIWarBookFight:updateUIBySelfData(types, isCheckLock)

    -- 更新数据
    local updateData = { }

    -- 先手
    local talentProxy = self._panel:getProxy(GameProxys.Talent)
    updateData.sequenceIcon = talentProxy:getCurSequenceIcon()    

    -- 战斗表现配置数据
    updateData.warBookFightCfgData = nil
    local tempflags = self:getNewFlag()
    for k, v in pairs(types) do
        tempflags[v] = 1
    end
    local warBookFightConfig = ConfigDataManager:getConfigData(ConfigData.WarBookFightConfig)
    for k, v in pairs(warBookFightConfig) do
        if self:checkSoldierType(v.soldier1, tempflags) then
            updateData.warBookFightCfgData = v
            break;
        end
    end

    -- 技能等级
    if updateData.warBookFightCfgData then
        local talentProxy = self._panel:getProxy(GameProxys.Talent)
        updateData.skillLevel = { }
        for i = 1, 2 do
            local talentInfo = talentProxy:getTalentInfoById(updateData.warBookFightCfgData["skill" .. i])
            updateData.skillLevel[i] = talentInfo and talentInfo.talentLv or 0
        end
    end

    updateData.isCheckLock = true

    self:updateUI(updateData)

end

-- updateData
-- {
--  sequenceIcon = 0;//激活的天赋Id
--  warBookFightCfgData = nil;//国策战斗表现配置数据
--  skillLevel = {0, 0};//技能等级
--  isCheckLock = false
-- }
function UIWarBookFight:updateUI(updateData)
    
    local roleProxy = self._panel:getProxy(GameProxys.Role)

    if updateData.isCheckLock == true then 
        local isUnLock = roleProxy:isFunctionUnLock( 47, false )
        if isUnLock == false then
            self._rootUI:setVisible(false)
            return
        end
    end

    if updateData == nil then
        self._rootUI:setVisible(false)
        return
    else
        self._rootUI:setVisible(true)
    end

    updateData.sequenceIcon = updateData.sequenceIcon or 0

    local txtSpace = 10

    -- 先手
    local firstAtkArr = self._panel:getProxy(GameProxys.Battle):getFirstAtkArr()
    if self._isShowFirstAtkUI then
        if updateData.sequenceIcon <= #firstAtkArr then
            --local url = nil
            local str = nil
            if updateData.sequenceIcon == 0 then
                --url = "images/common/firstAtk1.png"
                str = firstAtkArr[1]
            else
                --url = "images/common/firstAtk" .. updateData.sequenceIcon .. ".png"
                str = firstAtkArr[updateData.sequenceIcon]
            end
            --TextureManager:updateImageView(self._firstAtkUI, url)
            self._firstAtkUI:setString(str)
            --print(firstAtkArr[updateData.sequenceIcon])
        end
    end
    self._firstAtkUI:setVisible(self._isShowFirstAtkUI)
    self._firstAtkBgUI:setVisible(self._isShowFirstAtkUI)


    -- 显示或隐藏阵型UI
    local isShow = updateData.warBookFightCfgData ~= nil
    self._imgZhen:setVisible(isShow)
    if self._imgZhenBg then
        self._imgZhenBg:setVisible(isShow)
    end
    for i = 1, 2 do
        self._skillIconUI[i]:setVisible(isShow)
        self._skillNameUI[i]:setVisible(isShow)
        self._skillLevelUI[i]:setVisible(isShow)
        self._skillBgUI[i]:setVisible(isShow)
    end

    if updateData.warBookFightCfgData ~= nil then
        -- 设置阵型名称UIWarBookFight.ResPathArr
        --TextureManager:updateImageView(self._imgZhen, "images/common/zhen" .. updateData.warBookFightCfgData.icon .. ".png")
        TextureManager:updateImageView(self._imgZhen, UIWarBookFight.ResPathArr[updateData.warBookFightCfgData.icon])


        for i = 1, 2 do
            --技能图标
            --TextureManager:updateImageView(self._skillIconUI[i], "images/common/skillIcon" .. updateData.warBookFightCfgData["skill" .. i .. "Icon"] .. ".png")
            TextureManager:updateImageView(self._skillIconUI[i], UIWarBookFight.SkillIconPathArr[updateData.warBookFightCfgData["skill" .. i .. "Icon"]])

            -- 技能名称
            self._skillNameUI[i]:setString(updateData.warBookFightCfgData["skill" .. i .. "Name"]);
            local nameUISize = self._skillNameUI[i]:getContentSize()

            -- 技能等级
            self._skillLevelUI[i]:setString(updateData.skillLevel[i] .. "级");
            local levelUISize = self._skillLevelUI[i]:getContentSize()

            -- 修正等级的位置
            if self._dirType == UIWarBookFight.DirType_Left then
                self._skillLevelUI[i]:setPositionX(self._skillNameUI[i]:getPosition() + nameUISize.width + txtSpace)
            else
                self._skillLevelUI[i]:setPositionX(self._skillNameUI[i]:getPosition() - nameUISize.width - txtSpace)
            end

            -- 修正背景的大小
            --local bgWidth = nameUISize.width + txtSpace * 3 + levelUISize.width
            --self._skillBgUI[i]:setContentSize(bgWidth, self._skillBgUI[i]:getContentSize().height)
        end
    end
end



-- 检查是否对应的阵型
function UIWarBookFight:checkSoldierType(soldierTypeJson, tempflag)
    local configflags = self:getNewFlag()
    local configTypes = StringUtils:jsonDecode(soldierTypeJson)
    for k, v in pairs(configTypes) do
        configflags[v] = 1;
    end


    for k, v in pairs(configflags) do
        if (tempflag[k] ~= v) then
            return false
        end
    end

    return true
end

function UIWarBookFight:getNewFlag()
    -- 支持4种类型的兵种,多了会错
    local bitFlags = { 0, 0, 0, 0 }
    return bitFlags
end