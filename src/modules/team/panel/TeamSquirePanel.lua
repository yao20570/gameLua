TeamSquirePanel = class("TeamSquirePanel", BasicPanel)
TeamSquirePanel.NAME = "TeamSquirePanel"

-- function TeamSquirePanel:ctor(view, panelName)
--     TeamSquirePanel.super.ctor(self, view, panelName)
--     self._fightPosMap = {}  --要发给服务器的数据
--     self._totalSolsiers = 0 --总共出战的佣兵数目
--     self._totalKen = 0  --总共开放的坑数量
--     self._currWeight = 0  --当前的载重
--     self._currFight = 0   --当前的战力
--     self._consuId = nil  --军师出战ID
-- end

-- function TeamSquirePanel:finalize()
--     TeamSquirePanel.super.finalize(self)
--     self._consuId = nil  --军师出战ID
-- end

-- function TeamSquirePanel:initPanel()
-- 	TeamSquirePanel.super.initPanel(self)
--     self._roleProxy = self:getProxy(GameProxys.Role)
--     self._soliderProxy = self:getProxy(GameProxys.Soldier)
-- 	self:initPosImg()
-- 	self:registerEvent()
	
--     local TopPanel = self:getChildByName("Panel_3/TopPanel")
--     TopPanel:setTouchEnabled(false)
--     local Panel_3 = self:getChildByName("Panel_3")
--     Panel_3:setTouchEnabled(false)
-- end

-- function TeamSquirePanel:onHideHandler()
--     self:setBtnVisible(true)
-- end

-- function TeamSquirePanel:initPosImg()  --初始化获得6个位置
--     local movePanel = self:getChildByName("Panel_3/TopPanel/movePanel")
--     self._posMap = {}  --槽位的开放设置
--     local function callback1(pos)
--         return self:getWhichPosEnable(pos)
--     end
--     local function callback2(pos)
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
--     self:setTargetCity()
--     self:setSolidertime()
-- end
-- function TeamSquirePanel:registerEvent()
-- 	self._keepBtn = self:getChildByName("DownPanel/KeepBtn")
--     self:addTouchEventListener(self._keepBtn, self.onBtnTouchTouch)
--     self._maxWeightBtn = self:getChildByName("DownPanel/maxWeightBtn")
--     self:addTouchEventListener(self._maxWeightBtn, self.onBtnTouchTouch)
--     self._maxFightBtn = self:getChildByName("DownPanel/maxFightBtn")
--     self:addTouchEventListener(self._maxFightBtn, self.onBtnTouchTouch)
--     self._equipBtn = self:getChildByName("DownPanel/EquipBtn")
--     self:addTouchEventListener(self._equipBtn, self.onOpenEquipHandle)
--     local PeijianBtn = self:getChildByName("DownPanel/PeijianBtn")
--     self:addTouchEventListener(PeijianBtn, self.onGotoPartsHandle)

--     self._consuImg = self:getChildByName("Panel_3/Image_94")
--     self._consuImg:setTouchEnabled(true)
--     self._consuImg.infoImg = self._consuImg:getChildByName("infoImg")
--     self._consuImg.suoImg = self._consuImg:getChildByName("suoImg")
--     self._consuImg.dot = self._consuImg:getChildByName("dot")
--     self._consuImg.urlPic = "images/newGui1/none.png"

--     self:addTouchEventListener(self._consuImg, self.onClickConsuHandle)

--     self:setBtnVisible(true)
-- end

-- function TeamSquirePanel:onTabChangeEvent(tabControl)
--     local downWidget = self:getChildByName("DownPanel")
--     TeamSquirePanel.super.onTabChangeEvent(self, tabControl, downWidget)
-- end

-- function TeamSquirePanel:onGotoPartsHandle(sender)
--     self:dispatchEvent(TeamEvent.OPEN_PARTS_MODULE)
-- end

-- function TeamSquirePanel:onOpenEquipHandle(sender)
-- 	self:dispatchEvent(TeamEvent.OPEN_EQUIPMODULE)
-- end

-- function TeamSquirePanel:setBtnVisible(isShowFight)
-- 	if isShowFight == true then
-- 		self._maxFightBtn:setVisible(true)
-- 		self._maxWeightBtn:setVisible(false)
-- 	else
-- 		self._maxFightBtn:setVisible(false)
-- 		self._maxWeightBtn:setVisible(true)
-- 	end
-- end

-- function TeamSquirePanel:onBtnTouchTouch(sender)
-- 	local proxy = self:getProxy(GameProxys.Soldier)
--     local consuProxy = self:getProxy(GameProxys.Consigliere) --加上军师信息
    

-- 	if sender == self._keepBtn then
-- 		local sendData = {}
-- 		sendData.info = {}
-- 		sendData.info.type = 1
-- 		sendData.info.members = {}
-- 		for _, v in pairs(self._fightPosMap) do
-- 			if v.typeid > 0 then
-- 				table.insert(sendData.info.members,v)
-- 			end
-- 		end
--         if self._consuId then  --加上军师
--             table.insert(sendData.info.members,{typeid = self._consuId,post = 9,num = 1})
--         end
-- 		self:dispatchEvent(TeamEvent.KEEP_TEAM_REQ,sendData)
-- 	elseif sender == self._maxFightBtn then
-- 		self:setBtnVisible(false)
-- 		self:setSoliderList(nil)
--         local consuId = consuProxy:getMaxConsuId()
--         self:onShowConsuImgById(consuId)
--         local data = proxy:getMaxFight()
-- 		self:setSoliderList(data)
-- 	elseif sender == self._maxWeightBtn then
-- 		self:setBtnVisible(true)
-- 		self:setSoliderList(nil)
--         local consuId = consuProxy:getMaxConsuId()
--         self:onShowConsuImgById(consuId)
--         local data = proxy:getMaxWeight()
-- 		self:setSoliderList(data)		
-- 	end
-- end

-- function TeamSquirePanel:onShowHandler()
--     self:setSoliderList(nil)
-- 	local forxy = self:getProxy(GameProxys.Soldier)
-- 	local data = forxy:onGetTeamInfo()
-- 	data = data[1].members
--     self:onShowConsuImg(data)   --军师图片
-- 	self:setSoliderList(data)
-- 	--if self._firstOpen == nil then
--         self:setOpenPosBylevel(self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level))
-- 	   --self._firstOpen = true
-- 	--end
--     self:updateEquipAndParts()
-- end

-- function TeamSquirePanel:setSoliderList(data)
-- 	if data == nil then
--         for index = 1 ,6 do
--             self:setPuppetById(index,0,0)
--         end
--         self._fightPosMap = {}
--     else
--         for _,v in pairs(data) do
--             self:setPuppetById(v.post,v.typeid,v.num)
--         end
--     end
-- end

-- function TeamSquirePanel:setPuppetById(pos,id,num)
--     if pos == 9 or pos == 19 then
--         return
--     end
--     local team = self:getTeamByPos(pos)
--     local dot = team:getChildByName("dot")
--     local infoImg = team:getChildByName("infoImg")
--     local name = infoImg:getChildByName("name")
--     local count = infoImg:getChildByName("count")
--     local typeBg = team:getChildByName("Image_93")
--     local typeImg = typeBg:getChildByName("Image_94")
--     local fightItem = {}
    
--     ComponentUtils:updateSoliderPos(team, id, num)
    
--     if id == 0 or num == 0 then
--         team.isShowPuppet = false  --不显示pupprt
--         infoImg:setVisible(false)
--         typeBg:setVisible(false)
--     else
--         typeBg:setVisible(true)
--         -- local isNew = false
--         -- local puppet
--         -- if team.puppet ~= nil then
--         --     if team.puppet.modeId ~= id then
--         --         team.puppet:finalize()
--         --         team.puppet = nil
--         --         team.modeId = nil
--         --         isNew = true
--         --     end
--         -- else
--         --     isNew = true
--         -- end
        
--         -- if isNew == true then
--         --     local info = ConfigDataManager:getInfoFindByOneKey("ArmKindsConfig","ID",id)
--         --     local realModelId = ConfigDataManager:getInfoFindByOneKey("ModelGroConfig","ID",info.model).modelID
--         --     puppet = SpineModel.new(realModelId,dot)
--         --     puppet:playAnimation("wait",true)
--         --     team.puppet = puppet
--         --     team.modeId = id
--         --     name:setString(info.name)
--         -- end
--         -- team.num = num

--         if dot.url ~= id then
            
--         end
--         team.modeId = id
--         team.num = num
--         team.isShowPuppet = true
--         count:setString(num)
--         infoImg:setVisible(true)
--     end
--     fightItem["post"] = pos
--     fightItem["typeid"] = id
--     fightItem["num"] = num
--     dot:setVisible(team.isShowPuppet)
--     self:setfightPosMap(fightItem)
-- end

-- function TeamSquirePanel:setfightPosMap(fightItem)
--     self._fightPosMap[fightItem["post"]] = fightItem
--     self._totalSolsiers = 0 --当前出战的总兵力
--     self._currWeight = 0  --当前的载重
--     self._currFight = 0   --当前的战力
--     for _,v in pairs(self._fightPosMap) do
--         if v.num > 0 then
--             self._totalSolsiers = self._totalSolsiers + v.num
--             self._currFight = self._currFight + self._soliderProxy:getPosAttr(v,v.post,self._consuId) * v.num
--             self._currWeight = self._currWeight + self._soliderProxy:getOneSoldierWeightById(v.typeid) * v.num
--         end
--     end
--     self:setSolderCount()
--     self:setCurrFight()
--     self:setCurrWeight()
-- end

-- function TeamSquirePanel:setOpenPosBylevel(level)
-- 	local troopsStartConfig = ConfigDataManager:getConfigData("TroopsStartConfig")
--     local index = 0 
--     for _,v in pairs(troopsStartConfig) do
--         if level >= v.captainLv then
--             self._posMap[v.troopsID].isOpen = true
--             self:setTeamSuoStatus(v.troopsID,false,v.captainLv)
--             index = index + 1
--         else
--             self._posMap[v.troopsID].isOpen = false
--             self:setTeamSuoStatus(v.troopsID,true,v.captainLv)
--         end
--     end
--     self._totalKen = index
--     self:setSolderCount()
--     self:onFirstSelect()
-- end

-- function TeamSquirePanel:onFirstSelect()
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


-- function TeamSquirePanel:getWhichPosEnable(pos)  --根据坑位判断当前的wight是否开放
--     return self._posMap[pos].isOpen    
-- end

-- function TeamSquirePanel:onPopTouch(pos)
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
--             -- local panel = self:getPanel(TeamChoosePanel.NAME)
--             -- panel:show()
--             -- panel:onMakeCurrData(serverListData,self,pos)
--             if self._UITeamMessPanel == nil then
--                 self._UITeamMessPanel = UITeamMessPanel.new(self,serverListData,pos,self.setPuppetById)
--             else
--                 self._UITeamMessPanel:updateData(serverListData,pos)
--             end
--         end
--     else
--         self:setPuppetById(pos,0,0) --隐藏pupplt
--     end
-- end

-- function TeamSquirePanel:getTeamByPos(pos)
--     local movePanel = self:getChildByName("Panel_3/TopPanel/movePanel")
--     for i = 1 ,6 do
--         local item = movePanel:getChildByName("imgPos"..i)
--         if item.pos == pos then
--             return item
--         end
--     end  
-- end

-- function TeamSquirePanel:setTeamSelectStatusByTeam(item,isShow)
--     local selectImg = item:getChildByName("selectImg")
--     selectImg:setVisible(isShow)
-- end

-- function TeamSquirePanel:changeTeamPos(team)
--     if team.isShowPuppet == true then
--         self:setPuppetById(team.pos,team.modeId,team.num)
--     else
--         self:setPuppetById(team.pos,0,0)
--     end
--     local AtlasLabel = team:getChildByName("AtlasLabel")
--     AtlasLabel:setString(team.pos)
-- end

-- function TeamSquirePanel:setTeamSuoStatus(pos,isShow,lv)
--     local item = self:getTeamByPos(pos)
--     local suoImg = item:getChildByName("suoImg")
--     --local infoImg = item:getChildByName("infoImg")
--     suoImg:setVisible(isShow)
--     --infoImg:setVisible(false)
--     local AtlasLabel = item:getChildByName("AtlasLabel")  --数字标签
--     if isShow == true then
--         local suoLabel = suoImg:getChildByName("suoLabel")
--         suoLabel:setString(lv..self:getTextWord(7057))
--         AtlasLabel:setVisible(false)
--     else
--         --AtlasLabel:setVisible(true)
--         AtlasLabel:setString(item.pos)
--     end
-- end

-- function TeamSquirePanel:setTargetCity() --行军目标
--     local targetCity = self:getChildByName("Panel_3/TopPanel/targetCity")
--     local x,y = self._roleProxy:getWorldTilePos()
--     targetCity:setString(self:getTextWord(705).."/"..x..","..y)
-- end

-- function TeamSquirePanel:setSolidertime() --行军时间
--     local Solidertime = self:getChildByName("Panel_3/TopPanel/Solidertime")
--     Solidertime:setString("0")
-- end

-- function TeamSquirePanel:setSolderCount()  --带兵数量
--     self._everyKenMaxCount = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)  --每个坑位的佣兵出战上线数目
--     self._solidercount:setString(self._totalSolsiers.."/"..self._everyKenMaxCount*self._totalKen)
-- end

-- function TeamSquirePanel:setCurrWeight()  --部队载重
--     local weight = self:getChildByName("Panel_3/TopPanel/weight")
--     weight:setString(StringUtils:formatNumberByK(self._currWeight))
-- end

-- function TeamSquirePanel:setCurrFight()  --战力的计算
--     local fightWight = self:getChildByName("Panel_3/TopPanel/fightWight")
--     fightWight:setString(StringUtils:formatNumberByK(self._currFight))
-- end

-- function TeamSquirePanel:updateEquipAndParts()
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
--     img = self:getChildByName("DownPanel/PeijianBtn/img")
--     count = self:getChildByName("DownPanel/PeijianBtn/img/count")
--     proxy = self:getProxy(GameProxys.Parts)
--     local partsData = proxy:getOrdnanceUnEquipInfos()
--     if partsData == nil or #partsData == 0 then
--         img:setVisible(false)
--     else
--         img:setVisible(true)
--         count:setString(#partsData)
--     end
-- end

-- function TeamSquirePanel:onIsOpenConsu()  --24级开启军师
--     local level = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
--     if level < 24 then
--         self._consuId = nil
--         TextureManager:updateImageView(self._consuImg.dot,self._consuImg.urlPic)
--         self._consuImg.infoImg:setVisible(false)
--         self._consuImg.suoImg:setVisible(true)
--         return false
--     else
--         self._consuImg.suoImg:setVisible(false)
--     end
--     return true
-- end

-- function TeamSquirePanel:onClickConsuHandle(sender)
--     if self:onIsOpenConsu() == true then
--         local name = ""
--         if self._consuId then
--             TextureManager:updateImageView(self._consuImg.dot,self._consuImg.urlPic)
--             self._consuImg.infoImg:setVisible(false)
--             self._consuId = nil
--             self:setSoliderList(self._fightPosMap)   --去掉军师,计算当前战力
--         else
--             self:dispatchEvent(TeamEvent.OPEN_COUNSEMODULE,{moduleName = ModuleName.ConsigliereModule})
--         end
--     else
--         self:showSysMessage("24级开启军师上阵功能！")
--     end
-- end

-- function TeamSquirePanel:onShowConsuImgById(id)
--     local proxy = self:getProxy(GameProxys.Consigliere)
--     local url = self._consuImg.urlPic
--     local name = ""
--     if id then
--         local configData = proxy:getDataById(id)
--         url = "images/consigliereImg/" .. configData.icon .. ".png"
--         name = configData.name
--         self._consuImg.infoImg:setVisible(true)
--     else
--         self._consuImg.infoImg:setVisible(false)
--     end
--     self._consuId = id
--     TextureManager:updateImageView(self._consuImg.dot,url)
--     local nameLabel = self._consuImg.infoImg:getChildByName("nameLabel")
--     nameLabel:setString(name)
-- end

-- function TeamSquirePanel:onShowConsuImg(data)
--     if self:onIsOpenConsu() == true then
--         local id = nil
--         if data then
--             for _,v in pairs(data) do
--                 if v.post == 9 or v.post == 19 then  --特殊位置
--                     if v.num > 0 then
--                         id = v.typeid
--                     end
--                     break 
--                 end
--             end
--         end
--         self:onShowConsuImgById(id)
--     end
-- end

-- function TeamSquirePanel:onConsuGoReq(data)  --军师上阵
--     self:onShowConsuImgById(data.typeId)
--     self:setSoliderList(self._fightPosMap)  --加上军师 计算战力
-- end






-----------------------------------------------------------------------------------------
function TeamSquirePanel:ctor(view, panelName)
    TeamSquirePanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function TeamSquirePanel:finalize()
	if self.uITeamMiPanel then
	    self.uITeamMiPanel:finalize()
	end
	if self._uiSetTeamPanel ~= nil then
		self._uiSetTeamPanel:finalize()
		self._uiSetTeamPanel = nil
	end
    TeamSquirePanel.super.finalize(self)
end

function TeamSquirePanel:initPanel()
    TeamSquirePanel.super.initPanel(self)

end

function TeamSquirePanel:onShowHandler()
    if self.uITeamMiPanel then
        self.uITeamMiPanel:onUpdateData(nil,1)
    else
    	local tabsPanel = self:getTabsPanel()
        self.uITeamMiPanel =  UITeamMiPanel.new(self,nil,1,nil,tabsPanel)
    end
end

function TeamSquirePanel:onTouchProtectBtnHandle(sendData) --保存防守阵型
	if self._uiSetTeamPanel == nil then
		self._uiSetTeamPanel = UISetTeamPanel.new(self, sendData.info.members, 2)
	else
		self._uiSetTeamPanel:show(sendData.info.members, 2)
	end	
    -- self:dispatchEvent(TeamEvent.KEEP_TEAM_REQ,sendData)
end