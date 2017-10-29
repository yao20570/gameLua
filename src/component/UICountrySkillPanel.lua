UICountrySkillPanel = class("UICountrySkillPanel")

------
-- @param  panel [obj] 界面
-- @param  callback [func] 点击使用后的回调函数
function UICountrySkillPanel:ctor(panel, callback)
    local uiSkin = UISkin.new("UICountrySkillPanel")
    
    uiSkin:setParent(panel:getParent())


    self._uiSkin = uiSkin
    self._uiSkin:setLocalZOrder(PanelLayer.UI_Z_ORDER_10)
    self._panel = panel
    self._parent = parent


    local secLvBg = UISecLvPanelBg.new(self._uiSkin:getRootNode(), self)
    self._secLvBg = secLvBg
    secLvBg:setBackGroundColorOpacity(120)
    secLvBg:setTitle(TextWords:getTextWord(560029)) -- "技能信息"
    secLvBg:setContentHeight(300)
    
    -- 确定按钮回调函数
    self._useCallback = callback

    self:registerEvents()

    self:initPanel()
end


function UICountrySkillPanel:registerEvents()
    local mainPanel = self._uiSkin:getChildByName("mainPanel")
    self._useBtn = mainPanel:getChildByName("useBtn")

    self._skillImg       = mainPanel:getChildByName("skillImg")      
    self._nameTxt        = mainPanel:getChildByName("nameTxt")       
    self._tipTxt         = mainPanel:getChildByName("tipTxt")        
    self._descriptionTxt = mainPanel:getChildByName("descriptionTxt")

    ComponentUtils:addTouchEventListener(self._useBtn, self.onUseBtn, nil, self)
end

function UICountrySkillPanel:initPanel()
    NodeUtils:setEnable(self._useBtn, true)
    self._useBtn:setVisible(self._useCallback ~= nil)
end


function UICountrySkillPanel:finalize()
    self._uiSkin:finalize()
end

function UICountrySkillPanel:hide()
    TimerManager:addOnce(1, self.finalize, self)
end


function UICountrySkillPanel:updateSkillPanel(skillId, remainTime, times, cdTime)
    self._skillId   = skillId   
    self._times = times
    self._cdTime = cdTime
    local configInfo = ConfigDataManager:getConfigById(ConfigData.CountrySkillConfig, skillId)
    if remainTime then
        --self._tipTxt:setString( TimeUtils:getStandardFormatTimeString8(remainTime))
        self._tipTxt:setString( remainTime)
    elseif times ~= nil and cdTime ~= nil then
        local maxTimes = configInfo.useTime
        local str = string.format( TextWords:getTextWord(560028), times, maxTimes)
        
        local cdStr = ""
        if cdTime > 0 then -- 时间大于0才显示
            cdStr = string.format( TextWords:getTextWord(560039), TimeUtils:getStandardFormatTimeString8(cdTime))
        end

        self._tipTxt:setString(str..cdStr)
    elseif times then
        local maxTimes = configInfo.useTime
        local str = string.format( TextWords:getTextWord(560028), times, maxTimes)
        self._tipTxt:setString(str)
    else
        self._tipTxt:setString("")
    end

    -- 静态显示
    self:setConfigMsg(configInfo)
end


function UICountrySkillPanel:setConfigMsg(configInfo)
    self._nameTxt:setString(configInfo.skillName)

    self._descriptionTxt:setString(configInfo.description)

    local url = string.format("images/countryIcon/skill_iocn%s.png", configInfo.Icon)
    TextureManager:updateImageView(self._skillImg, url)
end


function UICountrySkillPanel:onUseBtn(sender)
    if self._useCallback then
        if self._times == 0 then
            -- 提示次数不足
            self._panel:showSysMessage(TextWords:getTextWord(560027)) -- "技能使用次数不足"
            return 
        end

        if self._cdTime then
            if self._cdTime > 0 then
                self._panel:showSysMessage(TextWords:getTextWord(560040)) -- "技能还在冷却中"
                return
            end
        end

        self._useCallback(self._panel, self._skillId)
    end
end

function UICountrySkillPanel:setUseBtnEnable(state)
    NodeUtils:setEnable(self._useBtn, state)
end
















