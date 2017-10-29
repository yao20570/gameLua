local debug = {}    

function debug:init(state, key)    self._state = state
	if key == cc.KeyCode.KEY_D then --"d"
		self:startDebug()

	elseif key==cc.KeyCode.KEY_F1 then --"F1"		--gm命令面板
		self:showGmPanel()
	elseif key>=cc.KeyCode.KEY_1 and key<=cc.KeyCode.KEY_9 then --"1-9"	--添加  zb add 40x...
		local num = key-73
		self:showKeyboard( self:getBoardPlaceHolder( num ) )
	elseif key==cc.KeyCode.KEY_0 then --"0"  --  ...
		self:showKeyboard( "输入命令" )
	elseif key==cc.KeyCode.KEY_U then --"U"	 --客户端界面调试
		self:showUiPanel()
    elseif key==cc.KeyCode.KEY_F2 then -- 'F2'
        self:showCurCcb()
	end
end

function debug:getProxy(name)
    return self._state:getProxy(name)
end

function debug:getModule(name)
    return self._state:getModule(name)
end

function debug:getModulePanel(moduleName, panelName)
    local module = self:getModule(moduleName)
    return module:getPanel(panelName)
end

function debug:sendNotification(mainevent, subevent, data)
    self._state:sendNotification(mainevent, subevent, data)
end

function debug:showSysMessage(content, color, font)
	self._state:showSysMessage(content, color, font)
end
 
function debug:showMessageBox(content, okCallback, canCelcallback,okBtnName,canelBtnName)
	self._state:showMessageBox(content, okCallback, canCelcallback,okBtnName,canelBtnName)
end

function debug:showModule(data)
    logger:info("~~~~~~~~~~~~~~~~~debug:showModule(data)~~~~~~~~~~~~~~~~~~~~~~")
	self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
end

function debug:hideModule(data)
    logger:info("~~~~~~~~~~~~~~~~~debug:hideModule(data)~~~~~~~~~~~~~~~~~~~~~~")
	self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, data)
end

function debug:startDebug()

    -- TextureManager:removeTextureForKey("ccb/lizi_y.png")
    -- TextureManager:removeTextureForKey("ccb/fansheguang.png")

      local roleProxy = self:getProxy(GameProxys.Role)



      local index = roleProxy.testIndex 
      if index == nil then
        roleProxy.testIndex = 1
        index = 1
      else
        index = index + 1
        roleProxy.testIndex = index
      end

      local result = {}
   result[1] = {typeid = 4013, num = 2, power = 401}
   -- result[2] = {typeid = 206, num = 25, power = 407}
   -- result[3] = {typeid = 4012, num = 20, power = 401}
   -- result[4] = {typeid = 4013, num = 2, power = 401}
   -- result[5] = {typeid = 4013, num = 2, power = 401}
   -- result[6] = {typeid = 4012, num = 20, power = 401}
   -- result[7] = {typeid = 4013, num = 2, power = 401}
   -- result[8] = {typeid = 4013, num = 2, power = 401}
   -- result[9] = {typeid = 4013, num = 2, power = 401}
   -- result[10] = {typeid = 4013, num = 2, power = 401}
   -- result[11] = {typeid = 4013, num = 2, power = 401}
   -- result[12] = {typeid = 4013, num = 2, power = 401}

   local data = {}
   data.soldierList = {}
   data.itemList = {}
   data.odpInfos = {}
   data.equipinfos = {}
   data.heros = {}
   data.odInfos = {}
   table.insert(data.soldierList, {power = 406, typeid = 102, num = 100})
   table.insert(data.soldierList, {power = 406, typeid = 102, num = 100})
   table.insert(data.soldierList, {power = 406, typeid = 102, num = 100})
   table.insert(data.soldierList, {power = 406, typeid = 102, num = 100})
   table.insert(data.soldierList, {power = 406, typeid = 102, num = 100})
   table.insert(data.soldierList, {power = 406, typeid = 102, num = 100})

   -- roleProxy:onBagFreshFly(data, false)
   -- roleProxy:showRewardPanel(data, false)

   -- local parent = roleProxy:getLayer(GameLayer.topLayer)

   -- local function complete()
   --  print("~~~~~~~~complete~~~~")
   --  roleProxy.layer = nil
   -- end
   -- local layer = roleProxy.layer
   -- if layer == nil then
   --    layer = UICCBLayer.new("rgb-xslb-chuxian", parent, nil, complete, true) 
   --    layer:setPosition(320, 200)
   --    roleProxy.layer = layer
   --  else
   --    layer:finalize()
   --    roleProxy.layer = nil
   -- end
   



  -- roleProxy:showGetGoodsEffect(result)

  -- local buildingProxy = self:getProxy(GameProxys.Building)
  -- if buildingProxy.sssindex == nil then
  --   buildingProxy.sssindex = 0.01
  -- else
  --   buildingProxy.sssindex = buildingProxy.sssindex + 0.01
  -- end
  -- for key, obj in pairs(buildingProxy._remainTimeMap) do
  --   -- print("~!~~~~~~~~~~~~~~~~~", key)
  -- end
  -- local buildingInfo = buildingProxy:getBuildingInfo(8, 12)
  -- print("~~~~~~~~~~~~~~~~~~~~~~~~~~~", buildingInfo.levelTime)

  local soldierProxy = self:getProxy(GameProxys.Soldier)
  -- print("~~~~~~~~~~~~~~~~", soldierProxy:getTotalFirstnum())

  -- GuideManager:trigger(105, true)
  local guideId = 242
  package.loaded["guideData.guide.Guide" .. guideId] = nil
  -- package.loaded["guideData.action.g105.GuideAction501"] = nil

  local GuideClass = require("guideData.guide.Guide" .. guideId)
    if type(GuideClass) ~= type({}) then
        return
    end
    -- local guide = GuideClass.new(self._state)
    -- guide:onEnter(1, true)
    -- GuideManager:trigger(guideId, true)

    -- local dungeonProxy = self:getProxy(GameProxys.Dungeon)
    -- for k,v in pairs(dungeonProxy._allDungeonListInfos.dungeoInfos) do
    --   print(k,v.len, v.id)
    -- end

    print("~~~")
    
    -- local info = dungeonProxy:getDungeonById(101)
    -- print("~~~~~~~~~~~~~~~~~", info.len)


      local params = {}
      params.dt = 111111111
      params.fightingVar = 222222222
      params.fightingOldVar = 111111111

      -- local mainScenePanel = self:getModulePanel(ModuleName.MainSceneModule, "MainScenePanel")
      -- mainScenePanel._sceneMap:setScale(0.5 + buildingProxy.sssindex, cc.p(320, 320), true)
      -- print("~~~~~~~~~~~~~~~", params.dt)
      -- ComponentUtils:showCapactityAction(roleProxy, params, 320, 320)


      -- cc.Director:getInstance():getTextureCache():dumpCachedTextureInfo()

    --   local parent = roleProxy:getLayer(GameLayer.topLayer)
    -- local uiTip = UITip.new(parent)
    -- local text = {{{content = TextWords:getTextWord(270031), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}}
    --   uiTip:setAllTipLine(text)

      -- collectgarbage("collect")

   -- GameConfig.lastHeartbeatTime = 0
   -- _G["applicationWillEnterForeground"]()
   -- AudioManager._game:getNetChannel():onAutoCloseNet()
   -- AudioManager._game:getNetChannel()._transceiver:openNetCloseBox()

   -- AnimationFactory:playAnimationByName("CapactityAnimation", params)

   ModuleJumpManager:jump(ModuleName.PopularSupportModule, "PopularSupportPanel")
   -- local panel = self:getModulePanel(ModuleName.PopularSupportModule, "PopularSupportPanel")
   -- panel:registerEvents()

   -- ModuleJumpManager:jump(ModuleName.PersonInfoModule, "PersonInfoMRRewardPanel")
   -- TextureManager:writeCachedTextureInfo()

   local list = self._state._moduleList
   for _, module in pairs(list) do
     -- print("~~~~~~~~~~~~~~~~~~~", module.name)
     -- local module = self._state:getModule(moduleName)
     local map = module:getTextureKeyMap()
     for k,v in pairs(map) do
       -- local count = self._state._textureKeyMap[key]
       -- print(k,v)

     end
   end

   local map = self._state._textureKeyMap
   for k,v in pairs(map) do
     -- print(k,v)
   end

   local modelPool = SpineModelPool._modelPool
   for modelType, modelList in pairs(modelPool) do
       -- print("~~~~~~~~11~~~~~~~~~", modelType)
       for _, modelNode in pairs(modelList) do
            -- print("~~~~~~~~~~~~~~~~~", modelNode.pushTime)
       end
   end

   local spineList = SpineEffectPool._spineList
   for modelType, modelList in pairs(spineList) do
   end

   -- print("~~~!!~", GameConfig.createRoleTime)
--, 
   local modelList = {"gong01_atk", 
          "gong01_hit", "qi01_atk", "qiang01_atk",
            "qiang01_hit", "xuli_blue"} -- {101, 102, 103, 104, 105, 106, 401, 402, 403} 

    local parent = self._state.gameScene

    local function finalizeModel(obj, spineModel)
        -- spineModel:finalize()
    end

    local function createSpine(obj, modelType)
        local spineModel = SpineEffect.new(modelType, parent) -- SpineModel.new(modelType, parent)
        spineModel:setPosition(math.random(100,500), math.random(100, 800))
        TimerManager:addOnce(math.random(500, 5000), finalizeModel, {}, spineModel)
    end


    -- for i=1,100 do
    --     local modelType = modelList[math.random(1, #modelList)]
    --     TimerManager:addOnce(math.random(100, 300) * i, createSpine, {}, modelType)
    -- end

   -- SpineModelPool:finalize()

   -- _G["recorderComplete"]([[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]])

   -- TextureManager:removeTextureForKey("ui/littleIcon_ui_resouce_big_0.pvr.ccz")

--    self:hideModule(ModuleName.DungeonModule)
--    self:hideModule({moduleName = ModuleName.RegionModule})
--    ModuleJumpManager:jump(ModuleName.MainSceneModule, MainScenePanel.NAME)

   -- local roleProxy = self:getProxy(GameProxys.Role)
   --  roleProxy:setRoleAttrValue(PlayerPowerDefine.POWER_level, 18)
     -- self:showModule({moduleName = ModuleName.UnlockModule, extraMsg = {openType = 1, openLevel = 14}})

--     TimerManager:addOnce(30, self.showModule, self, {moduleName = ModuleName.UnlockModule})

--    ComponentUtils:playAction("BattleResultPanel", "battle_win")

   -- self:showModule( {moduleName = ModuleName.HeroGetModule, extraMsg = {1, 2, 3, 4} } )

   -- self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.ToolbarModule})
   -- self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.RoleInfoModule})
   -- self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.MainSceneModule})
  --  self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, { moduleName = ModuleName.RegionModule, unlink = true})
  -- self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, { moduleName = ModuleName.DungeonModule, unlink = true})
  --  self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.MainSceneModule})
end



--F1打开Gm命令面板
function debug:showGmPanel()

	local function getBackAction( isIn, fn )
		local scaleActio = cc.ScaleTo:create( isIn and 0.2 or 0.15, isIn and 1 or 0 )
		local ease = isIn and cc.EaseBackOut:create( scaleActio ) or cc.EaseBackIn:create( scaleActio )
		return cc.Sequence:create(
			cc.Spawn:create( ease, cc.FadeTo:create( 0.2, isIn and 255 or 0 )),
			cc.CallFunc:create( fn )
		)
	end
	local function createLayout( parentObj, w, h, opacity )
		local objSize = parentObj:getContentSize()
		local layout = ccui.Layout:create()
		layout:setBackGroundColorType(1)
		layout:setBackGroundColor( cc.c3b(0,0,0) )
		layout:setBackGroundColorOpacity( opacity )
		layout:setContentSize(cc.size(w,h))
		layout:setAnchorPoint( 0.5,0.5 )
		layout:setTouchEnabled( true )
		layout:setPosition( objSize.width*.5, objSize.height*.5 )
		parentObj:addChild( layout )
		return layout
	end
	local function _createText( parentObj, name, color, dx, dy, opacity )
		local btnSize = parentObj:getContentSize()
		local text = ccui.Text:create()
        text:setFontName(GlobalConfig.fontName)
		text:setPosition( btnSize.width*.5+dx, btnSize.height*.5+dy )
		text:setFontSize(18)
		text:setOpacity( opacity )
		text:setColor( color )
		text:setString( name )
		parentObj:addChild( text )
		return text
	end
	local function createText( parentObj, name, color, isOutline )
		if isOutline then
			local quality = 4
			for i=1, quality do
				local mod = (i%4)+1
				local deep = math.ceil(i/4)
				local flag = mod>2 and -1.3*deep or 1.3*deep
				local maxColor = math.max(color.r, color.g, color.b)
				local retColor = cc.c3b(
					maxColor==color.r and color.r/3 or color.r/10,
					maxColor==color.g and color.g/3 or color.g/10,
					maxColor==color.b and color.b/3 or color.b/10 )
				_createText( parentObj, name, retColor, (mod%2)*flag , ((mod+1)%2)*flag, 255/deep )
			end
		end
		return _createText( parentObj, name, color, 0,0, 255 )
	end



	local parent = self._state.gameScene
	--临时放一个变量, layout 释放时会删除
	if not parent.___showdebug_tmp then
		parent.___showdebug_tmp = true
	else
		return false
	end

	local lineN = 3  --一行按钮个数
	local btnPorp = self:gmBtnProp( lineN )
	local heightN = math.floor((#btnPorp-1)/lineN)
	local pSize = parent:getContentSize()

	local bg =  createLayout( parent, pSize.width, pSize.height, 60 )
	local box = createLayout( bg, 500, 80*(heightN+1)+40, 170)
	local function finalize()
		bg:runAction( getBackAction(false, function()
			bg:removeFromParent()
			parent.___showdebug_tmp = nil
		end) )
	end
	bg:setOpacity(0)
	bg:setScale(0)
	bg:runAction( getBackAction(true, function()
		ComponentUtils:addTouchEventListener( bg, finalize )
	end ) )

	--服务器时间
	local StrTime = os.date("server: %Y-%m-%d %X", GameConfig.serverTime)
	local timeText = createText( box, StrTime, ColorUtils.wordTitleColor )
	timeText:setAnchorPoint( 1,0 )
	timeText:setPosition( box:getContentSize().width-25, box:getContentSize().height-25 )
	timeText:runAction( cc.RepeatForever:create(cc.Sequence:create(
		cc.DelayTime:create(1),
		cc.CallFunc:create(function()
			timeText:setString( os.date("server: %Y-%m-%d %X", GameConfig.serverTime) )
		end)
	)))

	--按钮们
	for i,v in ipairs( btnPorp ) do

		local j = math.floor((i-1)/lineN)
		local color = ColorUtils:getColorByQuality( (j%7)+1 )
		local x = pSize.width/(lineN+1)*((i-1)%lineN+1)
		local y = pSize.height*0.5 + 80*( j-heightN*0.5)
		local btn = createLayout( bg, 130,65, 180 )
		btn:setPosition( x, y )
		btn:addTouchEventListener( function( sender, evenType )

			sender:setScale( evenType<ccui.TouchEventType.ended and 0.9 or 1 )

			if evenType~=ccui.TouchEventType.ended then
				return
			end

			if v.sendHolder then
				local placeHolder = v.sendHolder.."...\n输入...部分"
				self:showKeyboard( placeHolder, v.sendHolder )
				finalize()
				return
			end

			local ret = v.click and v.click() or nil
			if ret then
				finalize()
			end
		end )
		createText( btn, v.name, color, v.isOutline )
		if v.click2 then
			local btn2 = createLayout( bg, 20,65, 180 )
			btn2:setPosition( x+76.5, y )
			btn2:addTouchEventListener( function( sender, evenType )
				if evenType<ccui.TouchEventType.ended then return end
				local ret = v.click2()
				if ret then
					finalize()
				end
			end )
			createText( btn2, "+", color, true )
		end
	end
end

--打开快捷gm命令输入框 
function debug:showKeyboard( placeHolder, sendHolder )
	local editbox = nil
	local function callback()
		editbox:removeFromParent()
		editbox = nil
	end
	editbox = self:createEditBox( self._state.gameScene, placeHolder, sendHolder, callback )
	editbox:openKeyboard()
end
function debug:createEditBox( obj, placeHolder, sendHolder, callback )

  local resFilename, rect = TextureManager:getTextureFile("images/guiScale9/Bg_background.png")
  local editBox = cc.EditBox:create(cc.size(0,0), cc.Scale9Sprite:create(resFilename, rect))

  local function scriptEditBoxHandler(event)
    if event ~= "return" then
      return
    end
    local content =  editBox:getText()  
    if content~="" then
      sendHolder = sendHolder or ""
      local gm = {}
      if type(tonumber(string.sub( content, 0, 1)))=="number" then
        local arr = string.split( content, " " )
        for i=1,#arr,2 do
          table.insert( gm, sendHolder..(arr[i] or 0).." "..(arr[i+1] or 0) )
        end
      else
        gm = sendHolder..content
      end
      self:sendGm( gm )
    end
    if callback then callback() end
  end
	editBox:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
	editBox:setPlaceHolder( placeHolder )
	obj:addChild( editBox )
	editBox:registerScriptEditBoxHandler( scriptEditBoxHandler )
	return editBox
end
function debug:sendGm( cmds )
	if type( cmds )=="table" then
		for i,cmd in ipairs( cmds ) do
			TimerManager:addOnce(100*i, function()
				self:onSend( cmd )
			end, self)
		end
	else
		self:onSend( cmds )
	end
end
function debug:onSend( cmd )
	local fns = {"closeNet"}
	for _,fn in ipairs(fns) do
		if fn==cmd then
			self:closeNet()
			return
		end
	end

	logger:info("=====================\n     发送命令: "..cmd.."\n======================================================")
	self._state:showSysMessage( "发送命令: "..cmd )

	local data = {}
	data.context = cmd
	data.type = 1
	data.contextType = 1
	local chatProxy = self._state:getProxy( GameProxys.Chat ) 
	chatProxy:onTriggerNet140000Req(data)
end
function debug:closeNet()
	self._state:showSysMessage("重连后生效")
	TimerManager:addOnce(500, function()
		self:sendNotification(AppEvent.NET_EVENT, AppEvent.NET_AUTO_CLOSE_CONNECT, {})
	end, self)
end
function debug:sendOpenCustom( filename, defaultZB, openfile )
	local file,err=io.open( filename,"r+")
	if err then
		file = io.open( filename, "w")
		file:write( defaultZB or "" )
		file:close()
		file = io.open( filename,"r+")
	end

	local zbs = {}
	for l in file:lines() do
		if string.sub( l, 1,2 )~="--" then
			table.insert( zbs, l)
		end
	end
	self:sendGm( zbs )

	local path = cc.FileUtils:getInstance():getWritablePath()
	local str = path.."/"..filename.." 全部命令 已执行"
	logger:info( str )

	if err and openfile then
		TimerManager:addOnce(1200, function()
			io.popen( filename )
		end, self)
	end
	file:close()
end
--[[##############################################################################################################################################
###### 测 试 按 钮 ##############################################################################################################################
################################################################################################################################################]]
--gm按钮
function debug:gmBtnProp( lineN )
	local roleProxy = self._state:getProxy( GameProxys.Role )
	
	--功能类，非弹窗类==================================================================
	--btnPorp[n]
	--name        按钮标题
	--click       按钮事件  return true时关闭面板
	--click2      附加旁边的小按钮事件
	--sendHolder  Holder内容合并上输入框内容 发送命令
	--isOutline   是否描边
	local btnPorp = {
		{
			name = "添加道具\n(快捷键1)",
			sendHolder = "zb add 401 ",
		},{
			name = "自定义1",
			click = function()
				local defaultZBs = "--保存自定义命令，zb开头 可多行\nzb add 407 110 30\nzb charge 9999999 0\nzb addallres 99999999\nzb add 401 4012 1000\nzb as 100"
				self:sendOpenCustom( "custom_1.txt", defaultZBs, true )
				return true
			end,
			click2 = function()
				io.popen( "custom_1.txt" )
			end,
		},{
			name = "自定义2",
			click = function()
				local defaultZBs = "--保存自定义命令，zb开头 可多行\n--*游戏F5刷新之前，先关掉此文件，否则游戏会奔溃\nzb bl 1 1 33\nzb bl 9 2 33\ncloseNet"
				self:sendOpenCustom( "custom_2.txt", defaultZBs )
				return true
			end,
			click2 = function()
				io.popen( "custom_2.txt" )
			end,
		},

		{
			name = "断线重连",
			click = function()
				self:closeNet()
        return true
			end
		},{
			name = "+1 等级",
			click = function()
        local mylv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level )
        local addlv = math.min( 60-mylv, 1 )
        if addlv>0 then
          self:sendGm("zb add 407 110 "..addlv )
        end
			end,
			click2 = function()
        local mylv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level )
        local addlv = math.min( 60-mylv, 5 )
        if addlv>0 then
          self:sendGm("zb add 407 110 "..addlv )
        end
				-- local mylv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level )
				-- self:sendGm("zb add 407 110 "..(60-mylv) )
			end
		},{
			name = "-5 等级",
			click = function()
				local mylv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level )
				local addlv = math.min( mylv-1, 5 )
				if addlv>0 then
					self:sendGm("zb reduce 407 110 "..addlv)
				end
			end
		},

		{
			name = "充 100 壕币",
			click = function()
				self:sendGm("zb charge 100 0")
			end,
			click2 = function()
				self:sendGm("zb charge 9999999 0")
			end
		},{
			name = "+战法秘籍*10",
			isOutline = true,
			click = function()
				self:sendGm("zb add 401 4012 10")
			end,
			click2 = function()
				self:sendGm("zb add 401 4012 1000")
			end
		},{
			name = "+10K 五资源",
			click = function()
				self:sendGm( "zb addallres 9999" )
			end,
			click2 = function()
				self:sendGm( "zb addallres 99999999" )
			end,
		},


		{
			name = "清空 vip元宝",
			click = function()
				local haveGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold)
				local viplv = roleProxy:getRoleAttrValue( 114 )
				local vipexp = roleProxy:getRoleAttrValue( 103 )
				self:sendGm({
					"zb reduce 407 103 "..vipexp,
					"zb reduce 407 206 "..haveGold,
					"zb reduce 407 114 "..viplv,
				})
			end
		},{
			name = "清空 背包",
			click = function()
				self:sendGm("zb delItem")
			end
		},{
			name = "清空五资源",
			click = function()
				self:sendGm( "zb delallres" )
			end,
		},

		{
			name = "+各英雄*1",
			click = function()
				self:sendGm("zb addallhero")
				self:closeNet()
				return true
			end
		},{
			name = "+各英雄宝具*1",
			click = function()
				self:sendGm("zb addallbaoju")
			end
		},{
			name = "+各军师*1",
			click = function()
				self:sendGm("zb alljunshi 1")
			end
		},{
			name = "+各兵种军械*1",
			click = function()
				self:sendGm("zb addallod 1")
			end
		},{
			name = "+各兵种*10",
			click = function()
				self:sendGm("zb as 10")
			end,
			click2 = function()
				self:sendGm("zb as 200")
			end
		},{
			name = "清 兵",
			click = function()
				self:sendGm("zb addallod 1")
			end
		},
	}
	--以下作末尾=====================================
	local _addprop = {
		{
			name = "   设为当天晚\n"..os.date("%m-%d ", GameConfig.serverTime).."23:59:40",
			click = function()
				self:sendGm("zb changeTime "..os.date("%Y-%m-%d ", GameConfig.serverTime).."23:59:40" )
				self:closeNet()
				return true
			end
		},{
			name = "  加一天为\n"..os.date("%Y-%m-%d", GameConfig.serverTime+60*60*24),
			click = function()
				self:sendGm("zb changeTime "..os.date("%Y-%m-%d %X", GameConfig.serverTime+60*60*24) )
				self:closeNet()
				return true
			end,
			click2 = function()
				self:sendGm("zb changeTime "..os.date("%Y-%m-%d %X", GameConfig.serverTime+60*60*48) )
				self:closeNet()
				return true
			end,
		},{
			name = "   校准为本地\n"..os.date("%m-%d %X", os.time()),
			click = function()
				self:sendGm("zb changeTime "..os.date("%Y-%m-%d %X", os.time() ))
				self:closeNet()
				return true
			end
		}
	}
	--系统类，弹窗口类=====================================================================
	local prop2 = {

	}

	local mod = #btnPorp%lineN
	if mod~=0 then
		for i=1, lineN-mod do
			table.insert( btnPorp, {name=""} )
		end
	end
	for i,v in ipairs(_addprop) do
		table.insert( btnPorp, v )
	end
	return btnPorp, prop2
end

function debug:getBoardPlaceHolder( num )
	local sendHolder = "zb add 40"..num.." "
	local keyName = {
		"添加道具",
		"添加装备",
		"添加军械",
		"添加军械碎片",
		"添加谋士",
		"添加兵种",
		"添加资源",
		"添加武将",
		"添加英雄",}
	local strName = num and keyName[num] or ""
	local placeHolder = sendHolder.."...\n输入power value "..strName
  if num==1 then
    placeHolder = placeHolder.."\n如（4013 3）   或者（4013 1 4013 1 4013 1）"
  end
	return placeHolder, sendHolder
end



--本地调试界面用。--登陆界面 按 "U" 打开
function debug:showUiPanel()
  local moduleName = ModuleName.HeadAndPendantModule
  local path = "modules.headAndPendant.HeadAndPendantModule"
  local jumpToName = "PendantSettingPanel"

  -- local moduleName = ModuleName.CollectBlessModule
  -- local path = "modules.collectBless.CollectBlessModule"
  -- local jumpToName = "CollectBlessPanel"

  self._state:addModuleConfig( moduleName, path)
  ModuleJumpManager:jump( moduleName, jumpToName )
end

function debug:showCurCcb()

    local pauseMaps = {}
    local playMaps = {}
    local pauseNum = 0
    local playNum = 0

    for k, v in pairs (GlobalConfig.ccbMapInfos) do
        if v._isPause == true then
            pauseMaps[v._name] = (pauseMaps[v._name] or 0) + 1
       else
            playMaps[v._name] = (playMaps[v._name] or 0) + 1
        end        
    end

    for ccbname, v in pairs (pauseMaps) do
        logger:error("pause ccbname : %s --> %d", ccbname, v)
        pauseNum = pauseNum + v    
    end

    for ccbname, v in pairs (playMaps) do
        logger:error("play ccbname : %s --> %d", ccbname, v)   
        playNum = playNum + v   
    end

    logger:error("！！！！！！！！pause ccb num : %d", pauseNum)   
    logger:error("！！！！！！！！play ccb num : %d", playNum)   
end


return debug