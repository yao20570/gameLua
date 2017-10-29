
require "AudioEngine" 

AudioManager = {}

AudioManager.defaultSoundType = "ogg" --默认的音乐格式
AudioManager.soundPath = "sounds/"
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
if cc.PLATFORM_OS_IPHONE == targetPlatform or cc.PLATFORM_OS_IPAD == targetPlatform then
    AudioManager.defaultSoundType = "aac"
    AudioManager.soundPath = "sounds_ios/"
end

AudioManager.recorderSoundType = "mp3" --默认的录音格式

AudioManager._effectEnable = false
AudioManager._battleEffectEnable = false

AudioManager.isPlayRecorder = false --是否在播放语音，如果在播放，神马都不播放

function AudioManager:init(game)
    self._game = game
end

----------------------------------------------------------------

_G["applicationWillEnterForeground"] = function()
    if AudioManager:getMusicEnable() == true then
        AudioEngine.resumeMusic()
    else
    end
    
    logger:error("====从后台回来了===:%d========", os.time())
    local time = os.time()
    if GameConfig.enterBackgroundTime ~= nil and time - GameConfig.enterBackgroundTime > 60 then
        -- GameConfig.lastHeartbeatTime = GameConfig.lastHeartbeatTime - 60 * 3 --直接断线了
        AudioManager._game:getNetChannel():onAutoCloseNet()
    elseif GameConfig.enterBackgroundTime == nil and time - GameConfig.lastHeartbeatTime > 60 then
        --没有回到后台的时间，且心跳超过了1分钟了
        -- GameConfig.lastHeartbeatTime = GameConfig.lastHeartbeatTime - 60 * 3 --直接断线了
        AudioManager._game:getNetChannel():onAutoCloseNet()
        --强制断网
    else
        GameConfig.lastHeartbeatTime = os.time()
    end
    
    GameConfig.enterBackgroundTime = nil

    -- if _G["loginApplicationDidEnterBackground"] ~= nil then
    --     _G["loginApplicationDidEnterBackground"]()
    -- end
end

--触发回到后台
_G["applicationDidEnterBackground"] = function()
    logger:error("====回到后台=====:%d=====", os.time())
    GameConfig.enterBackgroundTime = os.time()
end

--录音结束
_G["recorderComplete"] = function(result)

    logger:error("=======录音结束=========:%s=====", tostring(AudioManager.recorderCompleteCallback))
    if AudioManager.recorderCompleteCallback ~= nil then
        if result == "" then
            logger:error("~~~~~~~~~没有录音数据~~~~~~~~~~~~~~~")
            return
        end
        local comResult = result --compress(result)
        AudioManager.recorderCompleteCallback(comResult)
    end
    
    -- self:playRecorderSound(result) --测试，直接先播放录音
end

--释放录音相关
function AudioManager:finalizeRecorder()
    self._audioImg = nil
    self._lastAudioImg = nil
end

--清理语音缓存
--无脑删除昨天的文件夹
function AudioManager:clearAudioCache()
    local preTime = os.time() - 60 * 60 * 24
    local tab = os.date("*t", preTime)
    local time = tab.year .. "" .. tab.month .. "" .. tab.day
    local path = AppFileUtils:getWritablePath() .. "chat" .. time
    deleteDownloadDir(path)
end

--获取缓存路径
function AudioManager:getAudioCachePath()
    local tab = os.date("*t", os.time())
    local time = tab.year .. "" .. tab.month .. "" .. tab.day
    local folder = "chat" .. time .. "/"
    local path = AppFileUtils:getWritablePath() .. folder
    if createAbsoluteDir ~= nil then
        createAbsoluteDir(path)
    end
    return path
end

--获取音效绝对路径
function AudioManager:getAudioFileName(chatId)
    local filename = self:getAudioCachePath() .. "chat" .. chatId .. "." .. AudioManager.recorderSoundType
    return filename
end

--停止播放的录音音效
--isForce强制停止的，不清空_audioImg
function AudioManager:stopRecorderSound(isForce, isResumeMusic)
    TimerManager:remove(self.stopRecorderSound, self)
    self.isPlayRecorder = false

    if isResumeMusic ~= false then  --是否需要充值背景音乐 顶替的是否，不需要
        self:resumeMusic()
    end
    
    
    if self._recorderSound ~= nil then
        AudioEngine.stopEffect(self._recorderSound)
    end

    if isForce then --强制关闭的
        if self._lastAudioImg ~= nil then
            self._lastAudioImg:stopAllActions() --
            self._lastAudioImg:setOpacity(255)
            self._lastAudioImg = nil
        end
        if self._audioImg ~= nil then
            self._audioImg:stopAllActions() --
            self._audioImg:setOpacity(255)
            self._audioImg = nil
        end
    end

    self._recorderSound = nil
end

--真正播放语音接口
function AudioManager:realPlayRecorderSound(filename, aduioSec)
    -- if self.isPlayRecorder == true then
    --     return
    -- end
    self:stopRecorderSound(false) --直接停止之前的录音了
    if self._lastAudioImg ~= nil then
        self._lastAudioImg:stopAllActions() --TODO 这里还要确认这个 self._audioImg会不会释放掉
        self._lastAudioImg:setOpacity(255)
        self._lastAudioImg = nil
    end

    self.isPlayRecorder = true
    self:pauseMusic()  --播放语音，暂停背景音乐 
    --TODO 这里还要停止正在播放的音效

    self._recorderSound = AudioEngine.playEffect(filename)

    TimerManager:addOnce(aduioSec * 1000, self.stopRecorderSound, self)
end

--播放录音数据
--aduioSec 音效长度
function AudioManager:playRecorderSound(chatId, recorder, aduioSec, audioImg)
    self._lastAudioImg = self._audioImg 
    self._audioImg = audioImg
    aduioSec = aduioSec or 1
    if aduioSec <= 0 then
        aduioSec = 1
    end
    local filename = self:getAudioFileName(chatId)
    local isFileExist = cc.FileUtils:getInstance():isFileExist(filename)
    if isFileExist == true then --文件存在，直接播放
        self:realPlayRecorderSound(filename, aduioSec)
    else
        if recorder == nil then
            self:stopRecorderSound(true)  --播放到没有录音的，也强制关闭播放，这时候是去请求网络数据的
            return false
        end

        self:saveRecorderSound(chatId, recorder)  --先保存记录，再播放音效
        self:realPlayRecorderSound(filename, aduioSec)
    end

    return true
end

--保存录音数据
function AudioManager:saveRecorderSound(chatId, recorder)
    local filename = self:getAudioFileName(chatId)
    local isFileExist = cc.FileUtils:getInstance():isFileExist(filename)
    if isFileExist == true then --文件存在，直接播放
        return --已经保存过了
    end

    if recorder == nil then
        return false
    end
    local unComp = recorder --uncompress(recorder) 压缩，改协议用Byte类型
    local recorderData = base64_decode(unComp)
    local file = io.open(filename,'wb')
    if file ~= nil then
        file:write(recorderData)
        file:flush()
        file:close()
    end

    return true
end

--录音结束 设置回调  
function AudioManager:setRecorderEndCallback(handler)
    self.recorderCompleteCallback = handler
end

function AudioManager:playBattleEffect(name)
    if self._battleEffectEnable ~= true then
        return
    end
    --self:playEffect(name)
end

function AudioManager:playEffect(name, filetype)
    if self._effectEnable ~= true then
        return
    end

    if self.isPlayRecorder == true  then --正在播放音效
        return
    end
--    if name == "Button" then
--        return
--    end

    -- print("~~~~~~~~AudioManager:playEffect~~~~~~~~~~~~~~~", name, debug.traceback())

    filetype = filetype or AudioManager.defaultSoundType
    local effectPath = cc.FileUtils:getInstance():fullPathForFilename(self.soundPath .. name .. "." .. filetype)
    AudioEngine.playEffect(effectPath)
end

function AudioManager:playButtonEffect()
    if self._effectEnable ~= true then
        return
    end
    local name = "Button"
    local effectPath = cc.FileUtils:getInstance():fullPathForFilename(self.soundPath .. name .. "." .. AudioManager.defaultSoundType)
    AudioEngine.playEffect(effectPath)
end

function AudioManager:playMusic(name, filetype, forcePlay)

    if self._musicName == name and forcePlay ~=  true then
        return  -- 正在播放同一首歌，直接返回
    end

    if self.isPlayRecorder == true  then --正在播放音效
        return
    end

    self._musicName = name
    if self._musicEnable ~= true then
        return
    end
    name = name or 'scene'
    self._musicName = name
    filetype = filetype or AudioManager.defaultSoundType
    local musicPath = cc.FileUtils:getInstance():fullPathForFilename(self.soundPath .. name .. "." .. filetype)

    if cc.PLATFORM_OS_IPHONE == targetPlatform or cc.PLATFORM_OS_IPAD == targetPlatform then
        if name == "BGM_login" then  --IOS特殊处理了 由于加载界面
            musicPath = cc.FileUtils:getInstance():fullPathForFilename(name .. "." .. filetype)
        end
    end
    
    
    AudioEngine.playMusic(musicPath, true)

    -- AudioEngine.setMusicVolume(0.7)
end

--延后播放音效，处理卡顿的问题
function AudioManager:delayPlayMusic(musicPath)
    AudioEngine.playMusic(musicPath, true)
end

--预加载音乐
function AudioManager:preloadMusic(name, filetype)
    filetype = filetype or AudioManager.defaultSoundType
    local musicPath = cc.FileUtils:getInstance():fullPathForFilename(self.soundPath .. name .. "." .. filetype)
    AudioEngine.preloadMusic(musicPath)
end

function AudioManager:resumePlayMusic()
    if self._musicName ~= nil then
        self:playMusic(self._musicName, nil, true) --还原，强制播放
    end
end

--TODO !!场景相关的还需要
function AudioManager:playSceneMusic()
    self:playMusic("BGM_city")
end

function AudioManager:playWorldMusic()
    self:playMusic("BGM_dungeon")
end

function AudioManager:playDungeonMusic()
    self:playMusic("battle_fb01")
end

function AudioManager:playBattleMusic(mapId)
    local key = string.format("Battle%02d", mapId)
    --self:playMusic(key)
end

function AudioManager:playUnionWarMusic()
    --self:playMusic("shouwei")
end

function AudioManager:stopMusic()
    --AudioEngine.stopMusic()
end

function AudioManager:battleEffectEnable(enable)
    self._battleEffectEnable = enable
end

function AudioManager:effectEnable(enable)
    self._effectEnable = enable
    if enable == true then
        --AudioEngine.resumeAllEffects()
    else
        --AudioEngine.pauseAllEffects()
    end
end

function AudioManager:musicEnable(enable)
    self._musicEnable = enable
    if enable == true then
        AudioEngine.resumeMusic()
        self:isMusicPlaying()
    else
        AudioEngine.pauseMusic()
    end
end

function AudioManager:pauseMusic()
    if self._musicEnable ~= true then
        return
    end
    AudioEngine.pauseMusic()
end

function AudioManager:resumeMusic()
    if self._musicEnable ~= true then
        return
    end
    AudioEngine.resumeMusic()
end

function AudioManager:getMusicEnable()
    return self._musicEnable
end

-- 判定背景音乐是否正在播放
function AudioManager:isMusicPlaying()
    -- body
    local state = AudioEngine.isMusicPlaying()
    if state == false then
        self:resumePlayMusic()
    end
end

function AudioManager:playEffectByType(type)  --武将上阵
    if type == 1 then --男
        self:playEffect("yx05")
    elseif type ==2 then --女
        self:playEffect("yx04")
    elseif type == 0 then 
    end
end