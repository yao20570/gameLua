
LoaderPanel = class("LoaderPanel", BasicPanel)
LoaderPanel.NAME = "LoaderPanel"

function LoaderPanel:ctor(view, panelName)
    LoaderPanel.super.ctor(self, view, panelName)

end

function LoaderPanel:finalize()
    if self._model ~= nil then
        self._model:finalize(false)
    end
    if self._barCcb ~= nil then
        self._barCcb:finalize()
    end
    
    if self._ccb01 ~= nil then
        self._ccb01:finalize()
    end

    if self._ccb02 ~= nil then
        self._ccb02:finalize()
    end

    LoaderPanel.super.finalize(self)
end

function LoaderPanel:initPanel()
	LoaderPanel.super.initPanel(self)
	
    local mainPanel = self:getChildByName("bgPanel")

    local x, y = NodeUtils:getCenterPosition()
    local layer01 = UICCBLayer.new("rgb-piantou-kaiji", mainPanel)
    layer01:setPosition(x, y * 2 - 1138 / 2)
    self._ccb01 = layer01

    local layer02 = UICCBLayer.new("rgb-piantou-logo", mainPanel) 
    layer02:setPosition(x, y * 2 - 250 / 2 - 45)
    self._ccb02 = layer02

    self._model = model
    
    local versionTxt = self:getChildByName("versionTxt")
    versionTxt:setString(string.format(self:getTextWord(116), VersionManager:getVersionStr()))

    local isbnTxt = self:getChildByName("isbnTxt")
    isbnTxt:setString(VersionManager:getISBNName())

    local warnTxt = self:getChildByName("warnTxt")
    warnTxt:setString(self:getTextWord(132))

    self._ccbSp = self:getChildByName("mainPanel/ccbPanel/ccbSp")

    --NodeUtils:enableShadow(versionTxt)
    --NodeUtils:enableShadow(isbnTxt)
    --NodeUtils:enableShadow(warnTxt)

--    if ccexp.VideoPlayer ~= nil then
--        local videoPlayer = ccexp.VideoPlayer:create()
--        videoPlayer:setFileName("video/cg.mp4")
--        videoPlayer:play()
--        videoPlayer:setLocalZOrder(1)
--        root:addChild(videoPlayer)
--    end
    
    self:addLoadProgress()

    
    local stateBarPosX, stateBarPosY = self._actionProgressBar:getPosition()
    local size = self._actionProgressBar:getContentSize()
    
    self._stateBarPosX = stateBarPosX
    self._stateBarPosY = stateBarPosY
    self._stateBarPosWidth = size.width
    
    local stateTxt = self:getChildByName("mainPanel/stateTxt")
    stateTxt:setVisible(false)

    self._barCcb = self:createUICCBLayer("rgb-jdt-huang", self._ccbSp)
    self._ccbSp:setVisible(true)
    
    self._isUpdateLoader = false
end

function LoaderPanel:pauseModel()
    self._model:pause()
end

function LoaderPanel:setIsUpdateLoader(value)
    self._isUpdateLoader = value
end

--获取进度条的问题
function LoaderPanel:getPosBarByPercent(percent)
    local pos = self._stateBarPosWidth * (percent / 100)
    return pos
end

function LoaderPanel:setUpdateFileSize(filesize, percent)
    if self._isUpdateLoader ~= true then
        return
    end
    filesize = filesize or 0
    local vstr = VersionManager:getVersionName()
    local str = string.format(self:getTextWord(114), vstr, filesize / 1024 / 1024, percent)
    local stateTxt = self:getChildByName("mainPanel/stateTxt")
    stateTxt:setString(str)
    stateTxt:setVisible(true)
    
    self._filesize = filesize
end

function LoaderPanel:setProgress(percent, noAction, delay)
    local loadTime = delay or 0.2
    if self._isUpdateLoader == true then
        loadTime = 0.02
    end
    
    if noAction == true then
        self._actionProgressBar:stopAllActions()
        self._actionProgressBar:setPercentage(percent)
        --
        self._ccbSp:stopAllActions()
        local posX01 = self:getPosBarByPercent(percent)
        self._ccbSp:setPosition(posX01, self._ccbSp:getPositionY())
    else
        if percent == 90 then
            percent = percent + 10
        end
        self._actionProgressBar:stopAllActions()
        local progressFrom = self._actionProgressBar:getPercentage()
        self._actionProgressBar:setPercentage(progressFrom)
        local to = cc.ProgressFromTo:create(loadTime, progressFrom, percent)
        self._actionProgressBar:runAction(to)

        --
        self._ccbSp:stopAllActions()
        local posX01 = self:getPosBarByPercent(self._actionProgressBar:getPercentage())
        self._ccbSp:setPosition(posX01, self._ccbSp:getPositionY())

        local posX02 = self:getPosBarByPercent(percent)
        local targetPos =  cc.p(posX02, self._ccbSp:getPositionY())
        local moveTo = cc.MoveTo:create(loadTime, targetPos)
        self._ccbSp:runAction(moveTo)
    end
    
    
    self:setUpdateFileSize(self._filesize,percent)
    
end

function LoaderPanel:setStateLabel(label)
end

function LoaderPanel:addLoadProgress()
    local progressBar = self:getChildByName("mainPanel/stateBar")
    local posx, posy = progressBar:getPosition()
    local zOrder = progressBar:getLocalZOrder()
    local parent = progressBar:getParent()
    parent:removeChild(progressBar, true)
    local sprite = TextureManager:createSprite("images/loader/Bg_bar2.png")
    local actionProgressBar = cc.ProgressTimer:create(sprite)
    actionProgressBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    actionProgressBar:setMidpoint(cc.p(0,0))
    actionProgressBar:setBarChangeRate(cc.p(1, 0))
    actionProgressBar:setPercentage(0)
    actionProgressBar:setPosition(posx, posy)
    actionProgressBar:setLocalZOrder(zOrder)
    parent:addChild(actionProgressBar)

    self._actionProgressBar = actionProgressBar
end

