
--纹理管理器----
TextureManager = {}

function TextureManager:init()
    self.file_type = ".pvr.ccz"
    self.bg_type = ".webp" --背景的统一格式res\bg
    self.head_resouce_name = "ui_resouce_big"
    self.head_config_name = "ui_resouce_big_config"
    
    self.gameui = "ui/"
    
    local targetPlatform = GameConfig.targetPlatform
    if cc.PLATFORM_OS_IPHONE == targetPlatform or
        targetPlatform == cc.PLATFORM_OS_IPAD then
--        self.file_type = ".pvr.ccz"
    end

    self.effectTextureKeysMap = {}

    self.cacheIdMap = {}  --url --> id 只有需要改动动同路径的资源才使用
end

function TextureManager:getCacheId(url)
    return self.cacheIdMap[url]
end

function TextureManager:updeteCacheId(url)
    local id = self:getCacheId(url) or 1
    self.cacheIdMap[url] = id + 1
end

function TextureManager:setGameState(gameState)
    self._gameState = gameState
end

--获取UI纹理配置表
function TextureManager:getTextureConfig( url )
    local strArry = StringUtils:splitString(url, "/")
    local configPath = strArry[2]

    local config = nil
    local function prequire()
        config = require (self.gameui  .. configPath .. "_" .. self.head_config_name)
    end
    
    local status, _ = pcall(prequire)
    if status ~= true then
        config = nil
    end
    
    return config, configPath
end

--获取UI纹理配范围
function TextureManager:getTextureRect( url )
    local config, configPath = self:getTextureConfig( url )
    local rect = nil
    if config then
        local configData = config[url]
        if configData then
            local sx = configData[2]
            local sy = configData[3]
            local sw = configData[4]
            local sh = configData[5]
            rect = cc.rect(sx, sy, sw, sh)
        end
    end

    return rect
end

---------获取UI纹理
---UI路径由images相对路径开始
---返回纹理跟rect
function TextureManager:getUITexture( url )
    
    local strArry = StringUtils:splitString(url, "/")
    local headPath = strArry[1]
    local configPath = strArry[2]

    local config = nil
    local function prequire()
        config = require (self.gameui  .. configPath .. "_" .. self.head_config_name)
    end
    local status, _ = pcall(prequire)
    if status ~= true then
        return nil
    end

    local curConfig = config[url]
    if curConfig == nil then
        logger:info("获取的纹理资源不存在url:%s", url)
        return nil
    end
    local curidx = curConfig[1]
    local sx = curConfig[2]
    local sy = curConfig[3]
    local sw = curConfig[4]
    local sh = curConfig[5]
    local rect = cc.rect(sx, sy, sw, sh)

    local resFilename = self.gameui ..configPath .. "_" .. self.head_resouce_name .. "_" .. curidx .. self.file_type
    local texture = cc.Director:getInstance():getTextureCache():addImage(resFilename)

    
    return texture, rect, resFilename
end

function TextureManager:getUIPlist(url)
    local strArry = StringUtils:splitString(url, "/")
    local headPath = strArry[1]
    local configPath = strArry[2]
    
    local config = require (self.gameui  .. configPath .. "_" .. self.head_config_name)

    local curConfig = config[url]
    if curConfig == nil then
        return nil
    end
    local curidx = curConfig[1]
    
    local plist = self.gameui ..configPath .. "_" .. self.head_resouce_name .. "_" .. curidx .. ".plist"
    
    return plist
end

function TextureManager:loadPlistFrameByUrl(url)
    local plist = self:getUIPlist(url)
    cc.SpriteFrameCache:getInstance():addSpriteFrames(plist)
end

function TextureManager:getTextureFile(url)
    local strArry = StringUtils:splitString(url, "/")
    local headPath = strArry[1]
    local configPath = strArry[2]

    local config = require (self.gameui  .. configPath .. "_" .. self.head_config_name)
    
    local curConfig = config[url]
    if curConfig == nil then
        return nil
    end
    local curidx = curConfig[1]
    local sx = curConfig[2]
    local sy = curConfig[3]
    local sw = curConfig[4]
    local sh = curConfig[5]
    local rect = cc.rect(sx, sy, sw, sh)

    local resFilename = self.gameui ..configPath .. "_" .. self.head_resouce_name .. "_" .. curidx .. self.file_type

    return resFilename, rect
end

function TextureManager:createSprite(url, defaulturl)
    local texture, rect = self:getUITexture(url)
    if texture == nil then
        defaulturl = defaulturl or "images/itemIcon/101.png"
        texture, rect = self:getUITexture(defaulturl)
    end
    local sprite = cc.Sprite:createWithTexture(texture, rect)
    sprite.url = url
    return sprite
end

function TextureManager:createScale9Sprite(url, rect_table)
    local file, rect = self:getTextureFile( url )
    local sprite = cc.Scale9Sprite:create(file, rect ,rect_table)
    return sprite
end

function TextureManager:createImageView(url)
    local imageView = ccui.ImageView:create()
    self:updateImageView(imageView,url)
    return imageView
end

function TextureManager:createScale9ImageView(url, rect_table)
    local imageView = ccui.ImageView:create()
    self:updateImageView(imageView,url)
    imageView:setCapInsets(rect_table)
    imageView:setScale9Enabled(true)
    return imageView
    
end

function TextureManager:updateSprite(sprite, url, defaulturl)
    if sprite.url == url then
        return
    end
    sprite.url = url
    local texture, rect, textureUrl = self:getUITexture(url)
    if texture == nil then
        url = defaulturl or "images/itemIcon/101.png"
        texture, rect, textureUrl = self:getUITexture(url)
    end
    sprite:setTexture(texture)
    sprite:setTextureRect(rect)

    self:addTextureKey2TopModule(textureUrl)
end

function TextureManager:updateImageView(imageView, url, defaulturl, moduleName)

    if imageView.url == url then
        local size = imageView:getContentSize()
        return size.width, size.height
    end
    
    
    local texture, rect, textureUrl = self:getUITexture(url)
    if texture == nil then
        url = defaulturl or "images/itemIcon/101.png"
        texture, rect, textureUrl = self:getUITexture(url)
    end
    
    imageView.url = url
    
    self:loadPlistFrameByUrl(url)
    imageView:loadTexture(url, ccui.TextureResType.plistType)

    self:addTextureKey2TopModule(textureUrl, moduleName)
    
    return rect.width, rect.height
    
--    local sprite = imageView:getVirtualRenderer()
--    sprite = tolua.cast(sprite, "cc.Sprite")
--    self:updateSprite(sprite,url)
end


function TextureManager:isTextureExist(url)
    return cc.SpriteFrameCache:getInstance():getSpriteFrameByName()
end

--更新按钮的Normal状态图片
function TextureManager:updateButtonNormal(button, url, defaulturl)

    if button.url == url then
        return
    end
    button.url = url

    --self:loadPlistFrameByUrl(url)
    local texture, rect, textureUrl = self:getUITexture(url)
    if texture == nil then
        url = defaulturl or "images/itemIcon/101.png"
        texture, rect, textureUrl = self:getUITexture(url)
    end
    self:loadPlistFrameByUrl(url)
    button:loadTextureNormal(url, ccui.TextureResType.plistType)

    self:addTextureKey2TopModule(textureUrl)
end

--更新按钮的Pressed状态图片
function TextureManager:updateButtonPressed(button, url, defaulturl)

    if button.url == url then
        return
    end
    button.url = url

    --self:loadPlistFrameByUrl(url)
    local texture, rect, textureUrl = self:getUITexture(url)
    if texture == nil then
        url = defaulturl or "images/itemIcon/101.png"
        texture, rect, textureUrl = self:getUITexture(url)
    end
    self:loadPlistFrameByUrl(url)
    button:loadTexturePressed(url, ccui.TextureResType.plistType)

    self:addTextureKey2TopModule(textureUrl)
end

-- function TextureManager:updateBuildingBtnNormal(button, url)
--     local texture, rect = self:getUITexture(url)
--     if texture == nil then
--         url = "images/common/building54.png"
--         texture, rect = self:getUITexture(url)
--     end
--     self:loadPlistFrameByUrl(url)
--     button:loadTextureNormal(url, ccui.TextureResType.plistType)
-- end

function TextureManager:updateImageViewFile(imageView, url, moduleName)
--    local sprite = imageView:getVirtualRenderer()
--    sprite = tolua.cast(sprite, "cc.Sprite")

    local cacheId = self.cacheIdMap[url]

    if imageView.url == url and imageView.cacheId == cacheId then
        local size = imageView:getContentSize()
        return size.width, size.height
    end
    imageView.url = url
    imageView.cacheId = cacheId
    
    self:addTextureKey2TopModule(url, moduleName)
    imageView:loadTexture(url)
    local texture = cc.Director:getInstance():getTextureCache():addImage(url)
    local rect = cc.rect(0,0,texture:getPixelsWide(), texture:getPixelsHigh())
--    sprite:setTexture(texture)
--    sprite:setTextureRect(rect)
    
    return rect.width, rect.height
end

function TextureManager:createImageViewFile(url)
    self:addTextureKey2TopModule(url)
    local imageView = ccui.ImageView:create()
    imageView:loadTexture(url)
    return imageView
end

function TextureManager:createSpriteFile(url)
    self:addTextureKey2TopModule(url)
    local sprite = cc.Sprite:create(url)
    return sprite
end

--更新Sprite url
function TextureManager:updateSpriteFile(sprite, url)

    if sprite.url == url then
        return
    end
    sprite.url = url

    self:addTextureKey2TopModule(url)
    local texture = cc.Director:getInstance():getTextureCache():addImage(url)
    sprite:setTexture(texture)
    local rect = cc.rect(0,0,texture:getPixelsWide(), texture:getPixelsHigh())
    sprite:setTextureRect(rect)

end

--通过直接文件创建sprite或者imageView的，
--直接添加到最上层的模块，以便在模块关闭的时候，进行释放
--moduleName 直接添加到固定的模块名上
function TextureManager:addTextureKey2TopModule(url, moduleName)

    if string.find(url, ".plist") ~= nil then
        logger:error("~~~~~~~~~~~不把plist加入到释放队列中去~~~~:%s~~~~~~~~", url)
        return
    end

    local module = nil
    if moduleName ~= nil then
        module = self._gameState:getModule(moduleName)
        logger:info("~~~~~~~~~添加到自定义模块~~~~~url:%s~~~:%s~~~~~~~~~", url, moduleName)
    end

    if module == nil then  --找不到模块，就当到最上面
        module = self._gameState:getTopShowModule()
    end
    if module ~= nil then
        module:addTextureKey(url)
    end
    
    -- print("~~~~~~添加纹理资源到模块~~~~~~~~~", module.name, url)
end

function TextureManager:createButton(url)
    local button = ccui.Button:create()

    local plist = self:getUIPlist(url)
    cc.SpriteFrameCache:getInstance():addSpriteFrames(plist)

    button:loadTextureNormal(url, 1)
    
    return button
end

function TextureManager:onUpdateSoldierImg(img,icon)
    if img == nil then
        return
    end
    local url = "images/barrackIcon/"..icon..".png"
    img:setScale(0.8)
    self:updateImageView(img,url)
end

--预加载资源，plist
function TextureManager:preLoadImage(textures, plists, completeCallback)
    --预加载plist
    local maxPlistNum = 0
    local curPlistNum = 0
    local startPlistProgree = 50
    local function addSpriteFrames(objm, plist)
        cc.SpriteFrameCache:getInstance():addSpriteFrames(plist)
        curPlistNum = curPlistNum + 1
        -- local progree = startPlistProgree + (curPlistNum / maxPlistNum) * 10
        if curPlistNum >= maxPlistNum then
            if completeCallback ~= nil then
                completeCallback()
            end
        end
    end

    local maxNum = #textures
    local curNum = 0
    local startProgree = 20
    local plistList = plists
    local function imageLoaded(texture)
        curNum = curNum + 1
        -- local progree = startProgree + (curNum / maxNum) * 30
        if curNum >= maxNum then
            local index = 1
            for _, plist in pairs(plistList) do  --TODO 需要优化
                local tmp = {}
                TimerManager:addOnce(30 * index, addSpriteFrames, tmp, plist )
                index = index + 1
            end
            maxPlistNum = #plistList
            if maxPlistNum == 0 then
                if completeCallback ~= nil then
                    completeCallback()
                end
            end
        end
    end

    for _, url in pairs(textures) do
        cc.Director:getInstance():getTextureCache():addImageAsync(url, imageLoaded)
    end

    if #textures == 0 then
        imageLoaded()
    end
end

--添加 执行func 后，所增加的纹理
function TextureManager:addDiffTextureKey(func, isAddToModule)
    if isAddToModule == nil then
        isAddToModule = true
    end
    local beforeKeys = cc.Director:getInstance():getTextureCache():getAllTextureKey()
    local keyMap = {}
    for _,key in pairs(beforeKeys) do
        keyMap[key] = true
    end

    func()

    local afterKeys = cc.Director:getInstance():getTextureCache():getAllTextureKey()

    local addKeys = {}
    for _,key in pairs(afterKeys) do
        if keyMap[key] == nil then
            table.insert(addKeys, key)
        end
    end

    if isAddToModule then
        for _, url in pairs(addKeys) do
            self:addTextureKey2TopModule(url)
        end
    end
    

    return addKeys
end

--缓存特效的纹理key，供后面的使用
--会产生在主城的特效纹理是不能释放的，实际上，也只能如此
--moduleName 强制添加到具体 的模块上
function TextureManager:addEffectTextureKeys(effectName, keys, moduleName)
    local textureKeys = self.effectTextureKeysMap[effectName]
    if textureKeys == nil then
        self.effectTextureKeysMap[effectName] = keys
        textureKeys = keys
    end

    for _, url in pairs(textureKeys) do   
        -- print("~~~~~~~addEffectTextureKeys~~~~~~~~~~~~~", url)
        self:addTextureKey2TopModule(url, moduleName)
    end
    
end

--通过KEY去删除掉纹理内存资源，包括SpriteFrame
function TextureManager:removeTextureForKey(key)
    
    if GlobalConfig:isRersistRes(key) == true then
        logger:error("~~~持久资源，不释放:%s~~~~~~~~~~", key)
        return
    end

    logger:error("~~~~~~~释放资源:%s~~~~~~~~~~", key)
    
    local plist = string.gsub(key, self.file_type, ".plist")  --默认都有Plist，虽然一些是没有的
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(plist)
    cc.Director:getInstance():getTextureCache():removeTextureForKey(key)

    -- local texture = cc.Director:getInstance():getTextureCache():getTextureForKey(key)
    -- cc.SpriteFrameCache:getInstance():removeSpriteFramesFromTexture(texture)
    -- cc.Director:getInstance():getTextureCache():removeTexture(texture)
    
end

function TextureManager:writeCachedTextureInfo()
    local info = cc.Director:getInstance():getTextureCache():getCachedTextureInfo()
    logger:error("~~~~~~~~writeCachedTextureInfo:%s~~~~~~~~", info)
end

TextureManager:init()




