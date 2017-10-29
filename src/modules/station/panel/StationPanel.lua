
-- StationPanel = class("StationPanel", BasicPanel)
-- StationPanel.NAME = "StationPanel"

-- function StationPanel:ctor(view, panelName)
--     StationPanel.super.ctor(self, view, panelName,true)
--     self._fightPosMap = {} --出战阵型的保存
--     self._selectTeam = nil --选中的team
--     self._totalKen = 0  --总共开放的坑数量
--     self._totalSolsiers = 0 --总共出战的佣兵数目

--     self._currWeight = 0  --当前的载重
--     self._currFight = 0   --当前的战力
-- end

-- function StationPanel:finalize()
--     StationPanel.super.finalize(self)
-- end

-- function StationPanel:onClosePanelHandler()
--     self.view:hideModuleHandler()
-- end

-- function StationPanel:initPanel()
--     StationPanel.super.initPanel(self)
--     -- self:setTitle(true, self:getTextWord(111))
--     self:setTitle(true,"zhujun",true)
--     self._totalFight = 0  --战力的计算
--     self:initPosImg()
--     self:registerEvent()
--     self._roleProxy = self:getProxy(GameProxys.Role)
--     self._soliderProxy = self:getProxy(GameProxys.Soldier)
--     self._dungeonProxy = self:getProxy(GameProxys.Dungeon)
--     self:setBgType(ModulePanelBgType.NONE)
-- end

-- function StationPanel:onShowHandler(_data)
--     self.stationData = _data
--     self:setSoliderList(nil)
--     -- if self._isShowMyCity == true then
--     --     self:setSoliderList(nil)
--     --     local data = self._dungeonProxy:onGetTeamInfo()
--     --     data = data[2].members
--     --     self:setSoliderList(data)
--     -- end
--     -- if self.view:getJumpToWorkPanel() == true then
--     --     self.view:setJumpToWorkPanel()
--         self:setBtnShow(1)
--     --     self:setTargetCity(true)
--     --     self:setSolidertime()  --行军时间
--         self:updateEquipAndParts()
--     -- end
--     local proxy = self:getProxy(GameProxys.Role)
--     local level = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)  --指挥官等级
--     self:setOpenPosBylevelOpenFun(level)
-- end    

-- function StationPanel:initPosImg()  --初始化获得6个位置
--     local movePanel = self:getChildByName("Panel_3/TopPanel/movePanel")
--     self._posMap = {}  --槽位的开放设置
--     local function callback1(pos)
--         return self:getWhichPosEnable(pos)
--     end
--     local function callback2(pos) --弹出到佣兵列表的界面
--         self:onPopTouch(pos)
--     end

--     local function callback3(team) --两个team成功交换pos之后
--         self:changeTeamPos(team)
--     end

--     for i = 1 ,6 do
--         local img = movePanel:getChildByName("imgPos"..i)
--         img.pos = i
--         local args = {}
--         args["objcet"] = self
--         args["callback1"] = callback1
--         args["callback2"] = callback2
--         args["callback3"] = callback3
--         IDrag.new(img,args)   --初始化各个坑位
--         self._posMap[i] = { isOpen = false } --test
--         local selectImg = img:getChildByName("selectImg")
--         -- local suoImg = img:getChildByName("suoImg")
--         selectImg:setVisible(false)
--         -- suoImg:setVisible(true)
--     end
--     self._solidercount = self:getChildByName("Panel_3/TopPanel/Solidercount")
-- end

-- function StationPanel:registerEvent()
--     self._squreBtn = self:getChildByName("Panel_3/DownPanel/SqureBtn")
--     self._maxFightBtn = self:getChildByName("Panel_3/DownPanel/maxFightBtn")
--     self._protectBtn = self:getChildByName("Panel_3/DownPanel/protectBtn")
--     self._fightBtn = self:getChildByName("Panel_3/DownPanel/fightBtn")
--     self._maxWeightBtn = self:getChildByName("Panel_3/DownPanel/maxWeightBtn")
--     self._equipBtn = self:getChildByName("Panel_3/TopPanel/EquipBtn")
--     self._sleepBtn = self:getChildByName("Panel_3/DownPanel/sleepBtn")
--     local PeijianBtn = self:getChildByName("Panel_3/TopPanel/PeijianBtn")

--     self._maxFightBtn.type = 1
--     self._maxWeightBtn.type = 2
    
--     self:addTouchEventListener(self._squreBtn, self.onBtnTouchHandle)
--     self:addTouchEventListener(self._maxFightBtn, self.onBtnTouchHandle)
--     self:addTouchEventListener(self._protectBtn, self.onBtnTouchHandle)
--     self:addTouchEventListener(self._fightBtn, self.onBtnTouchHandle)
--     self:addTouchEventListener(self._maxWeightBtn, self.onBtnTouchHandle)
--     self:addTouchEventListener(self._equipBtn, self.onBtnTouchHandle)
--     self:addTouchEventListener(PeijianBtn, self.onGotoPartsHandle)
--     self:addTouchEventListener(self._sleepBtn, self.onSleepHandle)
--     self:setBtnVisible(true,false)
-- end
-- function StationPanel:onSleepHandle(sender)
--     local data = self:checkFightPosMap()
--     if data ~= nil then
--         local panel = self:getPanel(TeamSleepPanel.NAME)
--         panel:show()
--         panel:startSend(self._type,self._cityId,data)
--     end
-- end

-- function StationPanel:checkFightPosMap()
--     local data = {}
--     for _, info in pairs(self._fightPosMap) do
--         if info.typeid > 0 and info.num > 0 then
--             table.insert(data, info)
--         end 
--     end
--     if #data == 0 then
--         self:showSysMessage(self:getTextWord(747))
--         return
--     end
--     return data
-- end

-- function StationPanel:onGotoPartsHandle(sender)
--     self:dispatchEvent(StationEvent.OPENPARTMODULE_EVENT)
-- end

-- function StationPanel:onBtnTouchHandle(sender)
--     if sender == self._fightBtn then  --出战请求
--         if self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_energy) <= 0 then  --体力值
--             self:showSysMessage(self:getTextWord(4022))
--             return
--         end
--         local data = {}
--         data.team = self:checkFightPosMap()
--         data.x = self.stationData.x
--         data.y = self.stationData.y
--         if data.team ~= nil then
--             -- self:dispatchEvent(StationEvent.STATION_REQ,data)
--             -- self:showSysMessage(self:getTextWord(4023))
--             -- self:onClosePanelHandler()
--             local function useItem()
--                 self:dispatchEvent(StationEvent.STATION_REQ,data)
--                 self:showSysMessage(self:getTextWord(4023))
--                 self:onClosePanelHandler()
--             end
--             local function notUseItem()
--             end
--             local content = string.format(self:getTextWord(4021))
--             self:showMessageBox(content, useItem, notUseItem,self:getTextWord(100),self:getTextWord(101))
--         else
--             self:showSysMessage(self:getTextWord(4020))
--         end
--     elseif self._squreBtn == sender then --点击套用阵型按钮
--         self:setSoliderList(nil) --首先清除一下全部的
--         --self:setSoliderList(self._dungeonProxy:getCheckData())
--     elseif self._protectBtn == sender then  --点击设置防守按钮
--         local sendData = {}
--         sendData.info = {}
--         sendData.info.type = 2
--         sendData.info.members = {}
--         for _, v in pairs(self._fightPosMap) do
--             if v.typeid > 0 then
--                 table.insert(sendData.info.members,v)
--             end
--         end
--         self:dispatchEvent(TeamEvent.KEEP_TEAM_REQ,sendData)
--         self:dispatchEvent(TeamEvent.HIDE_SELF_EVENT,sendData)
--     elseif self._maxFightBtn == sender or self._maxWeightBtn == sender then
--         self:setSoliderList(nil)
--         local data 
--         if sender == self._maxFightBtn then
--             data = self._soliderProxy:getMaxFight()
--             self:setBtnVisible(false,true)
--         else
--             data = self._soliderProxy:getMaxWeight()
--             self:setBtnVisible(true,false)
--         end
--         self:setSoliderList(data)
--     elseif self._equipBtn == sender then  --打开装备模块
--         self:dispatchEvent(StationEvent.OPEN_EQUIPMODULE)
--     end
-- end

-- function StationPanel:setBtnVisible(isShow,noshow)
--     self._maxFightBtn:setVisible(isShow)
--     self._maxWeightBtn:setVisible(noshow)
-- end

-- function StationPanel:setShowMyCityStatusOpenFun(type)
--     self._isShowMyCity = type
-- end

-- function StationPanel:updateTeamSet(Data,showType,isShowOtherCity, otherCityStr)
--     local data
--     local isShowMyCity = true
--     if Data == nil then
--         isShowMyCity = false
--         self._isShowMyCity = false
--     else
--         self._isShowMyCity = true
--     end
--     self:setSoliderList(Data)
--     self:setBtnShow(showType)
--     self:setTargetCity(isShowMyCity,isShowOtherCity, otherCityStr) --行军目标
--     self:setSolidertime()  --行军时间
--     self:updateEquipAndParts()
-- end

-- function StationPanel:setSoliderList(data)
--     if data == nil then
--         for index = 1 ,6 do
--             self:setPuppetById(index,0,0)
--         end
--         self._fightPosMap = {}
--     else
--         for _,v in pairs(data) do
--             --logger:info("######   %d    %d   %d",v.post,v.typeid,v.num)
--             self:setPuppetById(v.post,v.typeid,v.num)
--         end
--     end
-- end

-- function StationPanel:setPuppetById(pos,id,num)
--     local team = self:getTeamByPos(pos)
--     local dot = team:getChildByName("dot")
--     local infoImg = team:getChildByName("infoImg")
--     local name = infoImg:getChildByName("name")
--     local count = infoImg:getChildByName("count")
--     local fightItem = {}
    
--     ComponentUtils:updateSoliderPos(team, id, num)
    
--     if id == 0 or num == 0 then
--         team.isShowPuppet = false  --不显示pupprt
--         infoImg:setVisible(false)
--     else
--         team.modeId = id
--         team.isShowPuppet = true
--         team.num = num
--         count:setString(num)
--         infoImg:setVisible(true)
--     end
--     fightItem["post"] = pos
--     fightItem["typeid"] = id
--     fightItem["num"] = num
--     dot:setVisible(team.isShowPuppet)
--     self:setfightPosMap(fightItem)
-- end

-- function StationPanel:setfightPosMap(fightItem)
--     self._fightPosMap[fightItem["post"]] = fightItem

--     self._totalSolsiers = 0 --当前出战的总兵力
--     self._currWeight = 0  --当前的载重
--     self._currFight = 0   --当前的战力
--     for _,v in pairs(self._fightPosMap) do
--         if v.num > 0 then
--             self._totalSolsiers = self._totalSolsiers + v.num
--             self._currFight = self._currFight + self._soliderProxy:getPosAttr(v,v.post) * v.num
--             self._currWeight = self._currWeight + self._soliderProxy:getOneSoldierWeightById(v.typeid) * v.num
--         end
--     end
--     self:setSolderCountOpenFun()
--     self:setCurrFight()
--     self:setCurrWeight()
-- end

-- function StationPanel:getWhichPosEnable(pos)  --根据坑位判断当前的wight是否开放
--     return self._posMap[pos].isOpen    
-- end

-- function StationPanel:getTeamByPos(pos)
--     local movePanel = self:getChildByName("Panel_3/TopPanel/movePanel")
--     for i = 1 ,6 do
--         local item = movePanel:getChildByName("imgPos"..i)
--         if item.pos == pos then
--             return item
--         end
--     end  
-- end

-- function StationPanel:setTeamSelectStatusByTeam(item,isShow)
--     local selectImg = item:getChildByName("selectImg")
--     selectImg:setVisible(isShow)
-- end

-- function StationPanel:setTeamSelectStatusByPos(pos,isShow)
--     local item = self:getTeamByPos(pos)
--     local selectImg = item:getChildByName("selectImg")
--     selectImg:setVisible(isShow)
-- end

-- function StationPanel:setTeamSuoStatusOpenFun(pos,isShow,lv)
--     local function getItem(pos)
--         local movePanel = self:getChildByName("Panel_3/TopPanel/movePanel")
--         for i = 1 ,6 do
--             local item = movePanel:getChildByName("imgPos"..i)
--             if item.pos == pos then
--                 return item
--             end
--         end
--     end

--     local item = getItem(pos)   --self:getTeamByPos(pos)
--     local suoImg = item:getChildByName("suoImg")
--     --local infoImg = item:getChildByName("infoImg")
--     suoImg:setVisible(isShow)
--     --infoImg:setVisible(false)
--     -- if isShow == true then
--     --     local suoLabel = suoImg:getChildByName("suoLabel")
--     --     suoLabel:setString(lv.."级开锁")
--     -- end
--     local AtlasLabel = item:getChildByName("AtlasLabel")  --数字标签
--     if isShow == true then
--         local suoLabel = suoImg:getChildByName("suoLabel")
--         suoLabel:setString(lv..self:getTextWord(7057))
--         AtlasLabel:setVisible(false)
--     else
-- --        AtlasLabel:setVisible(true)
--         AtlasLabel:setString(item.pos)
--     end
-- end

-- function StationPanel:setOpenPosBylevelOpenFun(level) --根基指挥官等级设置槽位的开放

--     local index = 0
--     for pos = 1,6 do
--         local flag, notOpenInfo = self._soliderProxy:isTroopsOpen(pos)
--         if flag then
--             self._posMap[pos].isOpen = true
--             self:setTeamSuoStatusOpenFun(pos, false, notOpenInfo)
--             index = index + 1
--         else
--             self._posMap[pos].isOpen = false
--             self:setTeamSuoStatusOpenFun(pos, true, notOpenInfo)
--         end
--     end

--     self._totalKen = index
--     self:setSolderCountOpenFun()
--     self:onFirstSelectOpenFun()
-- end

-- function StationPanel:onFirstSelectOpenFun()
--     for index = 1,6 do
--         if self._posMap[index].isOpen == true then
--             local item = self:getTeamByPos(index)
--             if item ~= self._selectTeam then
--                 if self._selectTeam ~= nil then
--                     self:setTeamSelectStatusByTeam(self._selectTeam,false)
--                 end 
--                 self._selectTeam = item
--                 self:setTeamSelectStatusByTeam(item,true)
--             end
--             break
--         end
--     end
-- end

-- function StationPanel:onPopTouch(pos)
--     local item = self:getTeamByPos(pos)
--     if item ~= self._selectTeam then
--         if self._selectTeam ~= nil then
--             self:setTeamSelectStatusByTeam(self._selectTeam,false)
--         end 
--         self._selectTeam = item
--         self:setTeamSelectStatusByTeam(item,true)
--     end
--     if item.isShowPuppet == false then
--         local serverListData = self._soliderProxy:onShowEveryPosCount(self._fightPosMap)
--         if serverListData ~= nil then
--             local panel = self:getPanel(StationChoosePanel.NAME)
--             panel:show()
--             panel:onMakeCurrData(serverListData,self,pos)
--         end
--     else
--         self:setPuppetById(pos,0,0) --隐藏pupplt
--     end
-- end

-- function StationPanel:setBtnShow(index)
--     if index == 1 then
--         self._fightBtn:setVisible(true)
--         self._protectBtn:setVisible(false)
--         self._sleepBtn:setVisible(false)
--     elseif index == 2 then
--         self._fightBtn:setVisible(false)
--         self._protectBtn:setVisible(true)
--         self._sleepBtn:setVisible(false)
--     elseif index == 3 then
--         self._fightBtn:setVisible(false)
--         self._protectBtn:setVisible(false)
--         self._sleepBtn:setVisible(true)
--     end
-- end

-- function StationPanel:changeTeamPos(team)
--     if team.isShowPuppet == true then
--         self:setPuppetById(team.pos,team.modeId,team.num)
--     else
--         self:setPuppetById(team.pos,0,0)
--     end
--     local AtlasLabel = team:getChildByName("AtlasLabel")
--     AtlasLabel:setString(team.pos)
-- end

-- function StationPanel:setSolderCountOpenFun()  --带兵数量
--     self._everyKenMaxCount = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)  --每个坑位的佣兵出战上线数目
--     self._solidercount:setString(self._totalSolsiers.."/"..self._everyKenMaxCount*self._totalKen)
-- end

-- function StationPanel:setTargetCity(isShowMyCity, isShowOtherCity, otherCityStr) --行军目标
--     local targetCity = self:getChildByName("Panel_3/TopPanel/targetCity")
--     if isShowMyCity == true then
--         local x,y = self._roleProxy:getWorldTilePos()
--         targetCity:setString(self:getTextWord(705).."/"..x..","..y)
--     elseif isShowOtherCity == true then
--         targetCity:setString(otherCityStr)
--     else
--         local type ,dunId = self._dungeonProxy:getCurrType()
--         local cityId = self._dungeonProxy:getCurrCityType()
--         self._type = type
--         self._cityId = cityId
--         local info,cityInfo
--         print("type = "..type..",dunId = "..dunId)
--         if type == 1 then  --征战
--             info = ConfigDataManager:getInfoFindByOneKey("ChapterConfig","ID",dunId)
--             cityInfo = ConfigDataManager:getInfoFindByOneKey("EventConfig","ID",cityId)
--         elseif type == 2 then  --冒险
--             info = ConfigDataManager:getInfoFindByOneKey("AdventureConfig","ID",dunId)
--             cityInfo = ConfigDataManager:getInfoFindByOneKey("AdventureEventConfig","ID",cityId)
--         end
--         targetCity:setString(info.name.."/"..cityInfo.name)
--     end
-- end

-- function StationPanel:setSolidertime(_data) --行军时间
--     if _data then
--         self.stationData = _data
--     end
--     local Solidertime = self:getChildByName("Panel_3/TopPanel/Solidertime")
--     if self.stationData then
--         Solidertime:setString(TimeUtils:getStandardFormatTimeString6(self.stationData.time,true))
--         if self.stationData.x and self.stationData.y then
--             local _targetCity = self:getChildByName("Panel_3/TopPanel/targetCity")
--             local x, y = self.stationData.x, self.stationData.y
--             _targetCity:setString(self:getTextWord(705).."("..x..","..y..")")
--         end
--     else
--         Solidertime:setString("0")
--     end
-- end

-- function StationPanel:setCurrWeight()  --部队载重
--     local weight = self:getChildByName("Panel_3/TopPanel/weight")
--     weight:setString(StringUtils:formatNumberByK(self._currWeight))
-- end

-- function StationPanel:setCurrFight()  --战力的计算
--     local fightWight = self:getChildByName("Panel_3/TopPanel/fightWight")
--     fightWight:setString(StringUtils:formatNumberByK(self._currFight))
-- end

-- function StationPanel:updateEquipAndParts()
--     local img = self._equipBtn:getChildByName("img")
--     local count = img:getChildByName("count")
--     local proxy = self:getProxy(GameProxys.Equip)
--     local equipData = proxy:getEquipAllHome()
--     if #equipData == 0 then
--         img:setVisible(false)
--     else
--         img:setVisible(true)
--         count:setString(#equipData)
--     end
--     img = self:getChildByName("Panel_3/TopPanel/PeijianBtn/img")
--     count = self:getChildByName("Panel_3/TopPanel/PeijianBtn/img/count")
--     proxy = self:getProxy(GameProxys.Parts)
--     local partsData = proxy:getOrdnanceUnEquipInfos()
--     if partsData == nil then
--         img:setVisible(false)
--     else
--         img:setVisible(true)
--         count:setString(#partsData)
--     end
-- end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- 驻军的布阵
StationPanel = class("StationPanel", BasicPanel)
StationPanel.NAME = "StationPanel"

function StationPanel:ctor(view, panelName)
    StationPanel.super.ctor(self, view, panelName,true)
        
    self:setUseNewPanelBg(true)
end

function StationPanel:finalize()
	if self.uITeamMiPanel then
	    self.uITeamMiPanel:finalize()
	end
    StationPanel.super.finalize(self)
end

function StationPanel:onClosePanelHandler()
    self.view:hideModuleHandler()
end

function StationPanel:initPanel()
    StationPanel.super.initPanel(self)
    self:setTitle(true,"zhujun",true)
    self:setBgType(ModulePanelBgType.TEAM)
    local panel = self:getChildByName("Panel_3")
    if panel then
        panel:setVisible(false)
    end

    self._sendData = nil
end

function StationPanel:onShowHandler(data)
    self._uiType = 9
    if not self.uITeamMiPanel then
        -- self.uITeamMiPanel = UITeamMiPanel.new(self,data,self._uiType,nil,self:topAdaptivePanel())
        local tabsPanel = self:topAdaptivePanel2()
        self.uITeamMiPanel = UITeamMiPanel.new(self,data,self._uiType,nil,tabsPanel)
    else
        self.uITeamMiPanel:onUpdateData(data,self._uiType)
    end

end    

-- 刷新驻军信息
function StationPanel:setSolidertime( data )
    -- body
    self._sendData = data
    local time = rawget(data,"time") or 0
    if self.uITeamMiPanel then
        self:onShowHandler(data)
        self.uITeamMiPanel:setSolidertime(time)
    end
end

-- 驻军触摸事件
function StationPanel:onTouchProtectBtnHandle(sendData)
    -- body
    self._roleProxy = self:getProxy(GameProxys.Role)
    if self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_crusadeEnergy) <= 0 then  -- 驻军消耗讨伐令
        self:showSysMessage(self:getTextWord(4022))
        return
    end

    local function okCallback(  )
        self:onStationReq(sendData)
    end
    local content = string.format(self:getTextWord(4021))
    self:showMessageBox(content, okCallback)

end

-- 请求驻军
function StationPanel:onStationReq( sendData )
    -- body
    local data = {}
    data.team = sendData.info.members
    data.x = self._sendData.x
    data.y = self._sendData.y
    self:dispatchEvent(StationEvent.STATION_REQ,data)
end




