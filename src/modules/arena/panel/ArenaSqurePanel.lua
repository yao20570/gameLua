
ArenaSqurePanel = class("ArenaSqurePanel", BasicPanel)
ArenaSqurePanel.NAME = "ArenaSqurePanel"

-- function ArenaSqurePanel:ctor(view, panelName)
--     ArenaSqurePanel.super.ctor(self, view, panelName)
--     self._fightPosMap = {}
--     self._totalKen = 0 
-- end

-- function ArenaSqurePanel:finalize()
--     ArenaSqurePanel.super.finalize(self)
-- end

-- function ArenaSqurePanel:initPanel()
-- 	ArenaSqurePanel.super.initPanel(self)
-- 	self._roleProxy = self:getProxy(GameProxys.Role)
--     self._soliderProxy = self:getProxy(GameProxys.Soldier)
-- 	self:initPosImg()
-- 	self:registerEvent()
-- end

-- function ArenaSqurePanel:onTabChangeEvent(tabControl)
--     local panel = self:getPanel(ArenaMainPanel.NAME)
--     local downWidget = panel:getChildByName("Panel_68")
--     ArenaSqurePanel.super.onTabChangeEvent(self, tabControl, downWidget)
-- end

-- function ArenaSqurePanel:initPosImg()  --初始化获得6个位置
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
--         --local suoImg = img:getChildByName("suoImg")
--         selectImg:setVisible(false)
--         --suoImg:setVisible(true)
--     end
--     self._solidercount = self:getChildByName("Panel_3/TopPanel/Solidercount")
-- end

-- function ArenaSqurePanel:registerEvent()
--     -- self._equipBtn = self:getChildByName("DownPanel/EquipBtn")
--     -- self:addTouchEventListener(self._equipBtn, self.onOpenEquipHandle)
--     -- local PeijianBtn = self:getChildByName("DownPanel/PeijianBtn")
--     -- self:addTouchEventListener(PeijianBtn, self.onGotoPartsHandle)

--     self._consuImg = self:getChildByName("Panel_3/Image_94")
--     self._consuImg:setTouchEnabled(true)
--     self._consuImg.infoImg = self._consuImg:getChildByName("infoImg")
--     self._consuImg.suoImg = self._consuImg:getChildByName("suoImg")
--     self._consuImg.dot = self._consuImg:getChildByName("dot")
--     self._consuImg.urlPic = "images/newGui1/none.png"

--     self:addTouchEventListener(self._consuImg, self.onClickConsuHandle)
-- end

-- function ArenaSqurePanel:onShowHandler()
-- 	local panel = self:getPanel(ArenaMainPanel.NAME)
-- 	panel:setBtnStatus(2)
--     self:setSoliderList(nil)
-- 	local forxy = self:getProxy(GameProxys.Soldier)
-- 	local data = forxy:onGetTeamInfo()
-- 	data = data[3].members
--     self:onShowConsuImg(data)   --军师图片
-- 	self:setSoliderList(data)
-- 	if self._firstOpen == nil then
--         self:setOpenPosBylevel(self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level))
-- 	   self._firstOpen = true
-- 	end
--     --self:updateEquipAndParts()
-- end

-- function ArenaSqurePanel:onGotoPartsHandle(sender)
--     local proxy = self:getProxy(GameProxys.Role)
--     local level = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
--     if level < 18 then
--         self:showSysMessage(self:getTextWord(250007))
--         return
--     end
--     self:dispatchEvent(ArenaEvent.OPEN_PARTS_MODULE)
-- end

-- function ArenaSqurePanel:onOpenEquipHandle(sender)
-- 	self:dispatchEvent(ArenaEvent.OPEN_EQUIPMODULE)
-- end

-- function ArenaSqurePanel:onSaveSqureHandle()
-- 	local sendData = {}
-- 	sendData.info = {}
-- 	sendData.info.type = 3
-- 	sendData.info.members = {}
-- 	for _, v in pairs(self._fightPosMap) do
-- 		if v.typeid > 0 and v.num > 0 then
-- 			table.insert(sendData.info.members,v)
-- 		end
-- 	end
-- 	if #sendData.info.members <= 0 then
-- 	   self:setSoliderList(nil)
--        local forxy = self:getProxy(GameProxys.Soldier)
--        local data = forxy:onGetTeamInfo()
--        data = data[3].members
--        self:setSoliderList(data)
--        self:showSysMessage(self:getTextWord(19006))
--        return
-- 	end

--     if self._consuId then  --加上军师
--         table.insert(sendData.info.members,{typeid = self._consuId,post = 9,num = 1})
--     end
	
-- 	self:dispatchEvent(ArenaEvent.KEEP_TEAM_REQ,sendData)
-- end

-- function ArenaSqurePanel:setSoliderList(data)
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

-- function ArenaSqurePanel:setPuppetById(pos,id,num)
--     if pos == 9 or pos == 19 then
--         return
--     end
--     local team = self:getTeamByPos(pos)
--     local dot = team:getChildByName("dot")
--     local infoImg = team:getChildByName("infoImg")
--     local name = infoImg:getChildByName("name")
--     local count = infoImg:getChildByName("count")
--     local typeBg = team:getChildByName("Image_93")
--     local fightItem = {}
    
--     ComponentUtils:updateSoliderPos(team, id, num)
    
--     if id == 0 or num == 0 then
--         team.isShowPuppet = false  --不显示pupprt
--         infoImg:setVisible(false)
--         typeBg:setVisible(false)
--     else
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

-- function ArenaSqurePanel:setfightPosMap(fightItem)
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
-- end

-- function ArenaSqurePanel:setOpenPosBylevel(level)
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

-- function ArenaSqurePanel:getWhichPosEnable(pos)  --根据坑位判断当前的wight是否开放
--     return self._posMap[pos].isOpen    
-- end

-- function ArenaSqurePanel:onPopTouch(pos)
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
--             -- local panel = self:getPanel(ArenaChoosePanel.NAME)
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

-- function ArenaSqurePanel:getTeamByPos(pos)
--     local movePanel = self:getChildByName("Panel_3/TopPanel/movePanel")
--     for i = 1 ,6 do
--         local item = movePanel:getChildByName("imgPos"..i)
--         if item.pos == pos then
--             return item
--         end
--     end  
-- end

-- function ArenaSqurePanel:setTeamSelectStatusByTeam(item,isShow)
--     local selectImg = item:getChildByName("selectImg")
--     selectImg:setVisible(isShow)
-- end

-- function ArenaSqurePanel:changeTeamPos(team)
--     if team.isShowPuppet == true then
--         self:setPuppetById(team.pos,team.modeId,team.num)
--     else
--         self:setPuppetById(team.pos,0,0)
--     end
--     local AtlasLabel = team:getChildByName("AtlasLabel")
--     AtlasLabel:setString(team.pos)
-- end

-- function ArenaSqurePanel:setTeamSuoStatus(pos,isShow,lv)
--     local item = self:getTeamByPos(pos)
--     local suoImg = item:getChildByName("suoImg")
--     suoImg:setVisible(isShow)
--     local AtlasLabel = item:getChildByName("AtlasLabel")  --数字标签
--     if isShow == true then
--         local suoLabel = suoImg:getChildByName("suoLabel")
--         suoLabel:setString(lv..self:getTextWord(19007))
--         AtlasLabel:setVisible(false)
--     else
-- --        AtlasLabel:setVisible(true)
--         AtlasLabel:setString(item.pos)
--     end
-- end

-- function ArenaSqurePanel:onFirstSelect()
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

-- function ArenaSqurePanel:setSolderCount()  --带兵数量
--     local count = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)  --每个坑位的佣兵出战上线数目
--     self._solidercount:setString(self._totalSolsiers.."/"..count*self._totalKen)
-- end

-- function ArenaSqurePanel:setCurrFight()  --战力的计算
--     local fightWight = self:getChildByName("Panel_3/TopPanel/fightWight")
--     fightWight:setString(StringUtils:formatNumberByK(self._currFight))
-- end

-- function ArenaSqurePanel:updateEquipAndParts()
--     local img = self._equipBtn:getChildByName("img")
--     local count = self._equipBtn:getChildByName("count")
--     local Image_35 = self._equipBtn:getChildByName("Image_35")
--     local proxy = self:getProxy(GameProxys.Equip)
--     local equipData = proxy:getEquipAllHome()
--     if #equipData == 0 or (not equipData) then
--         count:setVisible(false)
--         Image_35:setVisible(false)
--     else
--         count:setVisible(true)
--         Image_35:setVisible(true)
--         count:setString(#equipData)
--     end
--     count = self:getChildByName("DownPanel/PeijianBtn/count")
--     local Image_36 = self:getChildByName("DownPanel/PeijianBtn/Image_36")
--     proxy = self:getProxy(GameProxys.Parts)
--     local partsData = proxy:getOrdnanceUnEquipInfos()
--     if partsData == nil or #partsData == 0 then
--         count:setVisible(false)
--         Image_36:setVisible(false)
--     else
--         count:setVisible(true)
--         Image_36:setVisible(true)
--         count:setString(#partsData)
--     end
-- end

-- function ArenaSqurePanel:onCLickMaxBtn()
--     local consuProxy = self:getProxy(GameProxys.Consigliere)
--     local consuId = consuProxy:getMaxConsuId()
--     self:onShowConsuImgById(consuId)
-- end

-- function ArenaSqurePanel:onIsOpenConsu()  --24级开启军师
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

-- function ArenaSqurePanel:onClickConsuHandle(sender)
--     if self:onIsOpenConsu() == true then
--         local name = ""
--         if self._consuId then
--             TextureManager:updateImageView(self._consuImg.dot,self._consuImg.urlPic)
--             self._consuImg.infoImg:setVisible(false)
--             self._consuId = nil
--             self:setSoliderList(self._fightPosMap)   --去掉军师,计算当前战力
--         else
--             self:dispatchEvent(ArenaEvent.OPEN_COUNSEMODULE,{moduleName = ModuleName.ConsigliereModule})
--         end
--     else
--         self:showSysMessage("24级开启军师上阵功能！")
--     end
-- end

-- function ArenaSqurePanel:onShowConsuImgById(id)
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

-- function ArenaSqurePanel:onShowConsuImg(data)
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

-- function ArenaSqurePanel:onConsuGoReq(data)  --军师上阵
--     self:onShowConsuImgById(data.typeId)
--     self:setSoliderList(self._fightPosMap)  --加上军师 计算战力
-- end







----------------------------------------------------------------------
function ArenaSqurePanel:ctor(view, panelName)
    ArenaSqurePanel.super.ctor(self, view, panelName)

    self:setUseNewPanelBg(true)
end

function ArenaSqurePanel:finalize()
    if self.uITeamMiPanel then
        self.uITeamMiPanel:finalize()
    end
    ArenaSqurePanel.super.finalize(self)
end

function ArenaSqurePanel:initPanel()
    ArenaSqurePanel.super.initPanel(self)
end

function ArenaSqurePanel:onTabChangeEvent(tabControl)
    local panel = self:getPanel(ArenaMainPanel.NAME)
    if panel:isInitUI() then
        local downWidget = panel:getChildByName("downPanel")
        ArenaSqurePanel.super.onTabChangeEvent(self, tabControl, downWidget)
    end
end

function ArenaSqurePanel:onShowHandler()
    if self.uITeamMiPanel == nil then
        local panel = self:getPanel(ArenaPanel.NAME)
        local tabsPanel = panel:getOwnTabsPanel()  --TODO 
        self.uITeamMiPanel =  UITeamMiPanel.new(self,nil,3,nil,tabsPanel)
        self.uITeamMiPanel:onSetArenaUi()

        self["maxFightBtn"] = self.uITeamMiPanel:getMaxFightBtn()
        self["fightBtn"] = self.uITeamMiPanel:getFightBtn()
        self["protectBtn"] = self.uITeamMiPanel:getProtectBtn()
    else
        self.uITeamMiPanel:onUpdateData(nil,3)
    end

    local count = self.view:onGetCount()
    if count == nil then
        count = 0
    end
    self.uITeamMiPanel:onUpdateWinCount(count,true)
end


function ArenaSqurePanel:onTouchProtectBtnHandle(sendData) --保存防守阵型
    self:dispatchEvent(ArenaEvent.KEEP_TEAM_REQ,sendData)
end