
-- Author: Jie
-- Date: 2017-08-29
-- 功能描述:在世界地图加多一个层,7573 【需求】- 四季特效表现

WorldMapSky = class("WorldMapSky", function (resConfig)
    return UIMapNodeExtend.extend(cc.Layer:create()) 
        -- UIMapNodeExtend.extend(cc.LayerColor:create(cc.c4b(255, 0, 255, 80)))
end)

WorldMapSky.__index = WorldMapSky

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
function WorldMapSky:ctor(mapPanel)
    if cc.PLATFORM_OS_IPHONE ~= targetPlatform and 
        cc.PLATFORM_OS_IPAD ~= targetPlatform and 
        cc.PLATFORM_OS_WINDOWS ~= targetPlatform then
        return
    end

    self._mapPanel = mapPanel
    self._seasonProxy = self._mapPanel:getProxy(GameProxys.Seasons)

    --测试
    -- self._test_season = 1
    -- self:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(10),cc.CallFunc:create(function()
    --     print("~~~~~~~~~~~~~~~~~~~WorldMapSky~~~~~~~~~~~~~~~~~~~~")
    --     print("~~~~~~~~~~~~~~~~~~~WorldMapSky~~~~~~~~~~~~~~~~~~~~")
    --     print("~~~~~~~~~~~~~~~~~~~WorldMapSky~~~~~~~~~~~~~~~~~~~~")
    --     print("~~~~~~~~~~~~~~~~~~~WorldMapSky~~~~~~~~~~~~~~~~~~~~")
    --     self:onUpdataMapSeason()
    -- end))))

    self:initSky()

end



function WorldMapSky:initSky()
    if not self._seasonProxy:isWorldSeasonOpen() then
        logger:error("~~~~~~~ 四季还没有开放,只播放夏天的阳光特效 ~~~~~~~")
        self:trySetSeason(SeasonsProxy.SeasonEnum.Summer)
        return
    end

    self:onUpdataMapSeason()
end

function WorldMapSky:saveCurSeason(season)
    self._pre_season = self._cur_season
    self._cur_season = season
end

function WorldMapSky:isChangeSeason()
    return self._pre_season ~= self._cur_season
end

-- 设置地图四季
function WorldMapSky:onUpdataMapSeason()
    if cc.PLATFORM_OS_IPHONE ~= targetPlatform and 
        cc.PLATFORM_OS_IPAD ~= targetPlatform and 
        cc.PLATFORM_OS_WINDOWS ~= targetPlatform then
        return
    end

    if not self._seasonProxy:isWorldSeasonOpen() then
        logger:error("~~~~~~~ 四季还没有开放,只播放夏天的阳光特效 ~~~~~~~")
        self:trySetSeason(SeasonsProxy.SeasonEnum.Summer)
        return
    end

    local season = self._seasonProxy:getCurSeason()

    --测试数据
    -- season = self._test_season % 4 + 1
    -- self._test_season = season


    self:trySetSeason(season)

end


function WorldMapSky:trySetSeason(season)
    self:saveCurSeason(season)

    if self:isChangeSeason() then
        self:setSeason(season)
    end
end



function WorldMapSky:setSeason(season)
    local seasonEffectConf = GlobalConfig:getMapSeasonEffectConf(season)

    local winsize = cc.Director:getInstance():getWinSize()

    if seasonEffectConf.effectBg then
        if self._season_effect_bg then
            self._season_effect_bg:removeFromParent()
        end
        self._season_effect_bg = TextureManager:createScale9Sprite(seasonEffectConf.effectBg, seasonEffectConf.S9Rect)
        self._season_effect_bg:setContentSize(cc.size(winsize.width,seasonEffectConf.S9Rect.height))
        -- self._season_effect_bg:setPosition(cc.p(winsize.width/2,winsize.height/2))
        self._season_effect_bg:setAnchorPoint(cc.p(0.5,1))
        -- self._season_effect_bg:setPositionX(winsize.width/2)
        -- NodeUtils:adaptiveTopY(self._season_effect_bg, 0)
        self:addChild(self._season_effect_bg)
         NodeUtils:adaptiveSetScreenPosition(self._season_effect_bg,winsize.width/2,winsize.height)

    else
        if self._season_effect_bg then
            self._season_effect_bg:removeFromParent()
            self._season_effect_bg = nil
        end
    end

    if seasonEffectConf.effectName then
        if self._season_ccb then
            self._season_ccb:finalize()
        end
        self._season_ccb = self._mapPanel:createUICCBLayer(seasonEffectConf.effectName, self)
        self._season_ccb:setPosition(cc.p(winsize.width/2,winsize.height/2))
        self._season_ccb:setLocalZOrder(5)
    else
        if self._season_ccb then
            self._season_ccb:finalize()
            self._season_ccb = nil
        end

    end
end

