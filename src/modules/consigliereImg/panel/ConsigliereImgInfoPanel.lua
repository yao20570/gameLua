
-- ConsigliereImgInfoPanel = class("ConsigliereImgInfoPanel", BasicPanel)
-- ConsigliereImgInfoPanel.NAME = "ConsigliereImgInfoPanel"

-- function ConsigliereImgInfoPanel:ctor(view, panelName)
--     ConsigliereImgInfoPanel.super.ctor(self, view, panelName, 370)

-- end

-- function ConsigliereImgInfoPanel:finalize()
--     ConsigliereImgInfoPanel.super.finalize(self)
-- end

-- function ConsigliereImgInfoPanel:initPanel()
-- 	ConsigliereImgInfoPanel.super.initPanel(self)
--     self:setTitle(true, self:getTextWord(270018))
-- end

-- -- function ConsigliereImgInfoPanel:registerEvents()
-- -- 	ConsigliereImgInfoPanel.super.registerEvents(self)
-- 	-- local closeBtn = self:getChildByName("Panel_63/btn_close")
-- 	-- closeBtn.index = 1
-- 	-- self:addTouchEventListener(closeBtn, self.touchItem)
-- 	-- local bigPanel = self:getChildByName("Panel_Info")
-- 	-- bigPanel.index = 2
-- 	-- self:addTouchEventListener(bigPanel, self.touchItem)
-- -- end

-- function ConsigliereImgInfoPanel:onShowHandler(data)
-- 	local icon = self:getChildByName("Panel_63/img_icon")
-- 	local name = self:getChildByName("Panel_63/nameBg/name")
-- 	local skillContainer = self:getChildByName("Panel_63/sk_icon")
-- 	local lab_skname = self:getChildByName("Panel_63/lab_skname")
--     local skillDesc = self:getChildByName("Panel_63/skillDesc")
-- 	local url = string.format("images/consigliereImg/101.png")
--     skillDesc:setString(data.getinfo)
-- 	if icon.iconImg == nil then
--         icon.iconImg = TextureManager:createImageView(url)
--         icon.iconImg:setLocalZOrder(2)
--         icon:addChild(icon.iconImg)
--     else
--         TextureManager:updateImageView(icon.iconImg,url)
--     end
--     name:setString(data.name)
--     local star = {}
--     for i = 1, 5 do
--     	star[i] = self:getChildByName("Panel_63/starPanel/star_"..i)
--     	if i <= data.quality then
--     		star[i]:setVisible(true)
--     	else
--     		star[i]:setVisible(false)
--     	end
--     end
--     local label= {}
--     for i = 1, 10 do
--     	label[i] = self:getChildByName("Panel_63/lab_"..i)
--         if data.propertyinfo[i] ~= nil then
--             local isHaveData = false
--             for k,v in pairs(data.propertyinfo[i]) do
--                 isHaveData = true
--                 break
--             end
--             if isHaveData == true then
--                 label[i]:setString(data.propertyinfo[i].txt)
--                 label[i]:setColor(ColorUtils:color16ToC3b(data.propertyinfo[i].color))
--                 label[i]:setFontSize(data.propertyinfo[i].font)
--             else
--                 label[i]:setString("")
--             end
--         else
--             label[i]:setString("")
--         end
--     end
    
--     if data.skillID <= 0 then
--     	skillContainer:removeAllChildren()
--     	lab_skname:setVisible(false)
--     	return
--     end
--     lab_skname:setVisible(true)
--     local tmp = {typeid = 1,num = 1,color = 1, panel = self, skillID = data.skillID}
--     local skillIcon = skillContainer.skillIcon
--     if skillIcon == nil then
--         skillIcon = UISkillIcon.new(skillContainer, tmp)
--         skillContainer.skillIcon = skillIcon
--    	else
--         skillIcon:updateData(tmp)
--     end
-- end

-- -- function ConsigliereImgInfoPanel:touchItem(sender)
-- -- 	if sender.index == 1 or sender.index == 2 then
-- -- 		self:hide()
-- -- 	end
-- -- end

-- --










ConsigliereImgInfoPanel = class("ConsigliereImgInfoPanel", BasicPanel)
ConsigliereImgInfoPanel.NAME = "ConsigliereImgInfoPanel"

function ConsigliereImgInfoPanel:ctor(view, panelName)
    ConsigliereImgInfoPanel.super.ctor(self, view, panelName, 400)

    self:setUseNewPanelBg(true)
end

function ConsigliereImgInfoPanel:finalize()
    ConsigliereImgInfoPanel.super.finalize(self)
end

function ConsigliereImgInfoPanel:initPanel()
    ConsigliereImgInfoPanel.super.initPanel(self)

    self:setLocalZOrder( PanelLayer.UI_Z_ORDER_3 )

    self.proxy = self:getProxy(GameProxys.Consigliere)

    local panel = self:getChildByName("Panel_Info/Panel_63")
    self.panel_skill = panel:getChildByName("panel_skill")
    self.img_icon = panel:getChildByName("Panel_icon")
    self.panel_skill:setBackGroundColorType(0)
end

--上阵
function ConsigliereImgInfoPanel:onGoBattleHandle(sender)
    self.proxy:sendNotification(AppEvent.PROXY_CONSUGOREQ,sender.data)
    self:hide()
    self.view:hideModuleHandler()
end

function ConsigliereImgInfoPanel:registerEvents()
    ConsigliereImgInfoPanel.super.registerEvents(self)
end

--[[ _data接口
    _data.panelUserId   当前界面的 谋士的 id
    _data.tBtnfn     界面下方按钮组的回调函数
]]
function ConsigliereImgInfoPanel:onShowHandler( _data )
    local tBtnfn = _data.tBtnfn
    self:setTitle(true, _data.title or "")

    local infoData = self.proxy:getInfoById(  _data.panelUserId ) or {}

    local typeId = infoData and infoData.typeId or _data.panelUserId
    local conf = self.proxy:getDataById( typeId ) or {}

    --self.view:updateSkills( self.panel_skill, conf.skillID, {showLv=true} )

    local leftStr = ""
    local rightStr = ""
    local ResourceConfig = ConfigDataManager:getConfigData( ConfigData.ResourceConfig )
    local propertys = StringUtils:jsonDecode( conf.property )

    for i,v in ipairs(propertys) do
        for kv, vul in pairs(v) do
            if kv%2==1 then
                local conf = ResourceConfig[vul] or {}
                local str = conf.name and (conf.name..": ") or ""
                leftStr = leftStr..str.."\n"
            else
                local str = vul or 0
                rightStr = rightStr..vul.."%\n"
            end
        end
    end
    local mLeftLable = self:getChildByName("Panel_Info/Panel_63/lab_1_0")
    local mRightLable = self:getChildByName("Panel_Info/Panel_63/lab_1_num_0")
    mLeftLable:setString( leftStr )
    mRightLable:setString( rightStr )


    ComponentUtils:renderConsigliereItem( self.img_icon, typeId )
    self.proxy:Reset()
    self.proxy:addData( typeId )

    --按钮组回调  参数一：当前界面的 谋士id
    local panel = self:getChildByName( "Panel_Info/Panel_63" )
    local len = 0
    for i=1,3 do
        local btn = panel:getChildByName("btn_"..i)
        if btn and tBtnfn and tBtnfn[i] then
            len = len + 1
            btn:setTitleText( tBtnfn[i].name or "" )
            self:addTouchEventListener( btn, function()
                if tBtnfn[i].click then
                    tBtnfn[i].click( _data.obj, _data.panelUserId )
                end
                if tBtnfn[i].clickhide then
                    self:hide()
                end
            end )
            btn:setVisible(true)
        else
            btn:setVisible(false)
        end
    end
end