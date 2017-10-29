-- /**
--  * @Author:      fzw
--  * @DateTime:    2016-10-11 17:05:50
--  * @Description: 点击关卡信息通用弹窗
--  */

--[[
panel : 父panel
type :  副本类型
callback : 回调

副本类型type：
0=默认类型
1=匈奴
2=鲜卑
55=中原战役
6=军团副本
9=剿匪副本

]]

UICityInfoPanel = class("UICityInfoPanel")

function UICityInfoPanel:ctor(panel, data, type, callback)
    local uiSkin = UISkin.new("UICityInfoPanel")
    uiSkin:setParent(panel)
    self._uiSkin = uiSkin
    self._parent = panel

    self.type = type  --副本类型 不可为空
    self.callback = callback

    self:registerEvents()
    -- self:registerProxyEvents()
    self:updateData(data)
end

function UICityInfoPanel:finalize()
    -- self:removeProxyEvents()
    self._uiSkin:finalize()
end

function UICityInfoPanel:registerEvents()
    self._dungeonProxy = self._parent:getProxy(GameProxys.Dungeon)

    self.targetImg = self._uiSkin:getChildByName("mainPanel/topBgImg/targetImg")
    self.infoBgImg = self._uiSkin:getChildByName("mainPanel/topBgImg/infoBgImg")
    self.fightTxt = self._uiSkin:getChildByName("mainPanel/topBgImg/fightTxt")
    self.infoTxt = self._uiSkin:getChildByName("mainPanel/topBgImg/infoTxt")
    self.infoTxt:setString(TextWords:getTextWord(129))
    self.itemBgImg = self._uiSkin:getChildByName("mainPanel/itemBgImg")
    self.sleepBtn = self._uiSkin:getChildByName("mainPanel/sleepBtn")
    self.sleepBtn:setTitleText(TextWords:getTextWord(125))
    self.fightBtn = self._uiSkin:getChildByName("mainPanel/fightBtn")

    if self.type == 6 or self.type == 9 then
        self.sleepBtn:setVisible(false)
        self.fightBtn:setPositionX(self.fightBtn:getPositionX() - 160)
        NodeUtils:setEnable(self.sleepBtn,false)
        self.infoTxt:setVisible(false)
    else
        NodeUtils:setEnable(self.sleepBtn,true)
        self.infoTxt:setVisible(true)
    end

    ComponentUtils:addTouchEventListener(self.sleepBtn, self.onSleepBtnTouch, nil, self)
    ComponentUtils:addTouchEventListener(self.fightBtn, self.onFightBtnTouch, nil, self)
end


-- 挂机按钮
function UICityInfoPanel:onSleepBtnTouch(sender)
    if self.type == 6 or self.type == 9 then
        return
    end
    
    if self._star == nil or self._star < 3 then
        self._parent:showSysMessage(TextWords:getTextWord(200100))
        return
    end

    local roleProxy = self._parent:getProxy(GameProxys.Role)
    local viplv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel) or 0
    local config = ConfigDataManager:getInfoFindByOneKey(ConfigData.VipDataConfig, "level", viplv)
    if config.isonhook == 0 then
        self._parent:showSysMessage(TextWords:getTextWord(200101))
        return
    end

    self:jumptoTeam(2)
end

-- 挑战按钮
function UICityInfoPanel:onFightBtnTouch(sender)
    self:jumptoTeam(1)
end

-- -- 跳转到布阵界面
function UICityInfoPanel:jumptoTeam(btntype)
    if self.callback then
        local teamDetail = self._parent:getProxy(GameProxys.TeamDetail)
        teamDetail:setEnterTeamDetailType(btntype)
        self.callback(self._parent)
    end    
end


-- 渲染关卡战力等信息
function UICityInfoPanel:updateTopInfo(data)
    local monsterGroupConfig = ConfigDataManager:getInfoFindByOneKey("MonsterGroupConfig","ID",data._info.monstergroup)
    
    -- 星星
    local star = rawget(data,"star")
    self._star = star
    -- if self._monsterGroupConfig == monsterGroupConfig and self.sleepBtn.star == star then
    --     return
    -- end
    -- self._monsterGroupConfig = monsterGroupConfig
    if self.type == 6 or self.type == 9 then
        self:showStarByCount(true, 0)  --军团副本/剿匪只显示星星底图
    else
        self:showStarByCount(true, star)
    end

    -- 战力
    local force
    if self.type == GameConfig.battleType.legion then
        force = rawget(data,"force") or 0
        -- if force == nil or force == 0 then
        --     force = monsterGroupConfig.force  --做个容错
        -- end
    else
        force = monsterGroupConfig.force
    end
    
    local roleProxy = self._parent:getProxy(GameProxys.Role)
    local myFight = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_highestCapacity) or 0
    local color = myFight > force and ColorUtils:color16ToC3b(ColorUtils.commonColor.Green) or ColorUtils:color16ToC3b(ColorUtils.commonColor.Red)

    force = StringUtils:formatNumberByK3(force)
    self.fightTxt:setString(force)
    self.fightTxt:setColor(color)

end

-- 显示关卡星星
function UICityInfoPanel:showStarByCount(isShow, count)
    if isShow ~= true or count == nil then
        self.infoBgImg:setVisible(false)
        return
    else
        self.infoBgImg:setVisible(true)
        local _index = 0
        for i = 1,count do
            local starBg = self.infoBgImg:getChildByName("starBg"..i)
            local star = starBg:getChildByName("star")
            star:setVisible(true)
        end
        for i = count + 1 ,3 do
            local starBg = self.infoBgImg:getChildByName("starBg"..i)
            local star = starBg:getChildByName("star")
            star:setVisible(false)
        end
    end
end

-- 渲染掉落物品
function UICityInfoPanel:renderItem(data)
    for i=1,4 do
        local item = self.itemBgImg:getChildByName("item"..i)
        item:setVisible(data[i] ~= nil)
        if data[i] ~= nil then
            local info = data[i]
            if info.isTrue == true then
                if self.type == 6 then
                    nameStr = 350002--"挑战"
                else
                    nameStr = 350000--"必掉"
                end
            else
                if self.type == 6 then
                    nameStr = 350003--"击杀"
                else
                    nameStr = 350001--"概率"
                end
            end
            info.customNumStr = TextWords:getTextWord(nameStr)

            if item.icon == nil then
                item.icon = UIIcon.new(item, info, info.isShowNum, self._parent, false, true)
                local nameLab = item.icon:getNameChild()
                local y = nameLab:getPositionY()
                nameLab:setPositionY(y - 3)
            else
                item.icon:updateData(info)
            end

            local iconName = item.icon:getNameChild()
            if iconName then
                --iconName:setFontSize(18)
                if info.typeid == 10809 then
                    iconName:setString(TextWords:getTextWord(350004))
                end
            end
        end
    end

end


function UICityInfoPanel:maybeRewrd(data,tab)
    local itemInfos = {}
    
    if tab ~= nil then
        for i,v in ipairs(tab) do
            table.insert( itemInfos, v)
        end
    end

    -- 概率掉
    local rewards = StringUtils:jsonDecode(data.rewardshow)
    for _,reward in pairs(rewards) do
        local info = {}
        info.power = reward[1]
        info.typeid = reward[2]
        info.num = reward[3]
        info.isTrue = false  --概率
        info.isShowNum = true
        table.insert(itemInfos,info)
    end
    return itemInfos
end

-- 概率掉的数据和显示
function UICityInfoPanel:updateDataByType99(data)
    local itemInfos = self:maybeRewrd(data)
    self:renderItem(itemInfos)
end

-- -- 南越远征
-- function UICityInfoPanel:updateDataByType3(data)
--     -- 概率掉
--     local itemInfos = self:maybeRewrd(data)
--     self:renderItem(itemInfos)
-- end

-- -- 羌氐远征
-- function UICityInfoPanel:updateDataByType5(data)
--     -- 概率掉
--     local itemInfos = self:maybeRewrd(data)
--     self:renderItem(itemInfos)
-- end

-- -- 匈奴
-- function UICityInfoPanel:updateDataByType1(data)
--     -- 概率掉
--     local itemInfos = self:maybeRewrd(data)
--     self:renderItem(itemInfos)
-- end

-- 远征类型副本掉落
function UICityInfoPanel:updateDataByType2(data)
    local itemInfos = {}
    
    -- 首次通关必掉
    if self._star <= 0 then
        self:getRewardData(data.fixdrop, itemInfos)
    end
    
    -- 概率掉
    itemInfos = self:maybeRewrd(data,itemInfos)
    self:renderItem(itemInfos)
end

-- 军团
function UICityInfoPanel:updateDataByType6(data)
    local itemInfos = {}
    -- 挑战
    self:getRewardData(data.fixchandrop, itemInfos, true)
    -- 击杀
    self:getRewardData(data.fixkilldrop, itemInfos, false)

    self:renderItem(itemInfos)
end

-- 剿匪
function UICityInfoPanel:updateDataByType9(data)
    local itemInfos = {}
    -- 必掉
    self:getRewardData(data.firstreward, itemInfos, true)

    -- 概率掉
    itemInfos = self:maybeRewrd(data,itemInfos)
    self:renderItem(itemInfos)
end

-- 中原战役
function UICityInfoPanel:updateDataByType55(data)
    local itemInfos = {}
    
    -- 必掉
    local tmp = {}
    tmp.power = GamePowerConfig.Other
    tmp.typeid = 10809  --经验icon
    tmp.num = data.exp
    tmp.isTrue = true  --必掉
    tmp.isShowNum = true
    table.insert(itemInfos,tmp)

    -- 首次通关必掉
    if self._star <= 0 then
        self:getRewardData(data.firstfixdrop, itemInfos, true)
    end

    -- 概率掉
    itemInfos = self:maybeRewrd(data,itemInfos)

    self:renderItem(itemInfos)
end

-- 读取奖励数据
function UICityInfoPanel:getRewardData(dropList,itemInfos,isTrue,isShowNum)
    -- 概率
    local rewardID = StringUtils:jsonDecode(dropList)
    for _,ID in pairs(rewardID) do
        local info = {}
        info = ConfigDataManager:getRewardConfigById(ID)
        info.isTrue = isTrue or false
        info.isShowNum = isShowNum or true
        table.insert(itemInfos,info)
    end
    return itemInfos
end


function UICityInfoPanel:updateData(data,citytype)
    local curtype ,dunId = self._dungeonProxy:getCurrType()
    local cityId = self._dungeonProxy:getCurrCityType()
    -- print("副本onEventCity: type,cityId,dunId = ",curtype,cityId,dunId)

    local cityInfo = {}
    if self.type == 9 then  --剿匪副本  剿匪判定放前面
        cityInfo = data._info
    elseif curtype == 1 then      --中原战役
        cityInfo = ConfigDataManager:getInfoFindByOneKey("EventConfig","ID",cityId)
        self.type = 55
    elseif curtype == 2 then  --远征
        cityInfo = ConfigDataManager:getInfoFindByOneKey("AdventureEventConfig","ID",cityId)
        self.type = dunId
    elseif curtype == 6 then  --军团副本
        cityInfo = ConfigDataManager:getInfoFindByOneKey("LegionEventConfig","ID",cityId)
        self.type = curtype
    end

    self:updateTopInfo(data)

    -- print("......................updateData", self.type, curtype, citytype, self._star)

    local fun = self["updateDataByType"..self.type]
    if type(cityInfo) == "table" and  table.size(cityInfo) > 0 then
        if fun then
            fun(self,cityInfo)
        elseif curtype == 2 then --远征
            -- logger:info("远征掉落显示 : %d %d %d",self.type,curtype,cityId)
            self:updateDataByType2(cityInfo)
        else
            -- logger:info("默认掉落显示 : %d %d %d",self.type,curtype,cityId)
            self:updateDataByType99(cityInfo)
        end
    end


end


