-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local socket = require("socket")

ProfileUtils = { }

function ProfileUtils:startTotal()
    
    print("\n")
    print("Profile===============================> start:")
    ProfileUtils._startTime = socket.gettime()  
    ProfileUtils._endTime = 0
    ProfileUtils._previousTime = ProfileUtils._startTime
    ProfileUtils._isStart = true
    
    ProfileUtils._timeList = {}
end

function ProfileUtils:PrintTime(key)

    if ProfileUtils._isStart ~= true then
        --logger:info("ProfileUtils is not start", debug.traceback())
        return
    end

    ProfileUtils._endTime = socket.gettime()  
    local timeSpan = ProfileUtils._endTime - ProfileUtils._previousTime

    local str = string.format("Profile============>tag:%2d, timeSpan:%.3f", key, timeSpan * 1000)
    table.insert( ProfileUtils._timeList, str )

   

    ProfileUtils._previousTime = ProfileUtils._endTime
end

function ProfileUtils:endTotal()

    ProfileUtils._endTime = socket.gettime()  
    local timeAll = ProfileUtils._endTime - ProfileUtils._startTime  

    ProfileUtils._startTime = 0
    ProfileUtils._endTime = 0
    ProfileUtils._previousTime = 0
    ProfileUtils._isStart = false

    for k, str in pairs(ProfileUtils._timeList) do
        print(str)
    end
    print(string.format("Profile============> timeAll:%0.3f", timeAll * 1000))
    print("Profile================================>end\n")
    print("\n")

    return timeAll * 1000
end

-- endregion
