--[[
-----D版的引导剧本
--]]
local Guide104 = class("Guide104",Guide)

function Guide104:ctor(gameState)
    Guide104.super.ctor(self, gameState)

    self.id = 104
    -- 开始 0
    self:addActionName("newD.GuideAction2432")  -- 主公，百姓夹道欢迎主公进城，我们抓紧进城，倾听下百姓的心声。
    self:addActionName("newD.GuideAction402")   -- 点击玩家主城
    self:addActionName("newD.GuideAction2433")  -- 对话
    --引导招兵 3
    self:addActionName("MoveSceneAction")       -- 移动主城步骤
    self:addActionName("newD.GuideAction405")   -- 移动到主城兵营
    self:addActionName("newD.GuideAction406")   -- 前往招兵
    --self:addActionName("newD.GuideAction407")   -- 征召步兵 具体个数 征召10只步兵
    self:addActionName("newD.GuideAction408")   -- 征召10只步兵
    self:addActionName("newD.GuideAction409")   -- 加速
    self:addActionName("newD.GuideAction411")   -- 离开兵营 
    --引导剿匪 10
    self:addActionName("newD.GuideAction412")   --点击Toolbar世界按钮，通用 
    self:addActionName("newD.GuideAction413")   --点击黄巾贼副本
    self:addActionName("newD.GuideAction2434")  --对话 "讨伐会有战损，记得用最大的战力进行讨伐" 
    self:addActionName("newD.GuideAction415")   --最大战力
    self:addActionName("newD.GuideAction416")   --点击挑战
    self:addActionName("BattleAutoExitAction")  --通用，等待战斗结束
    --引导升级主城 16
    self:addActionName("newD.GuideAction2435")  --对话
    self:addActionName("newD.GuideAction418")   --领取奖励，通用
    ---------此处有特效  升级   功能解锁 18
    self:addActionName("newD.GuideAction2436")  --对话"主公，新任务是官邸达到3级哦！" 
    self:addActionName("newD.GuideAction499")   --点击Toolbar世界按钮，通用
    self:addActionName("MoveSceneAction")       --移动主城步骤
    self:addActionName("newD.GuideAction420")   --点击主城官邸
    self:addActionName("newD.GuideAction421")   --点击 官邸升级
    self:addActionName("newD.GuideAction422")   --点击免费（加速一个按钮）
    self:addActionName("newD.GuideAction421")   --点击 官邸升级
    self:addActionName("newD.GuideAction424")   --点击加速
    self:addActionName("newD.GuideAction424e")  --5分钟加速使用
    self:addActionName("newD.GuideAction424e1") --5分钟后，免费加速
    self:addActionName("newD.GuideAction2437")  --对话  关闭建筑升级面板
    self:addActionName("newD.GuideAction418")   --领取奖励，通用
    -- 打战役 30
    self:addActionName("newD.GuideAction2438") --对话 "终于可以打战役，通关战役招降更多武将哦！"
    self:addActionName("newD.GuideAction434")  -- 点击战役
    self:addActionName("newD.GuideAction435")  --点击第一章 101
    self:addActionName("newD.GuideAction436")  --点击第一个关卡 弹出队伍界面  --  自动设置最大战力
    self:addActionName("newD.GuideAction2439") --对话"战役挑战部队零战损，请尽情的征服中原。"
    self:addActionName("newD.GuideAction438")  -- 点击挑战 关卡界面的通用
    self:addActionName("BattleAutoExitAction") --通用，等待战斗结束 --这里断线重连出问题 
    -- 打战役 37
    self:addActionName("newD.GuideAction440")  --点击第二个关卡 --  自动设置最大战力
    self:addActionName("newD.GuideAction438")  --  点击挑战   关卡界面的通用
    self:addActionName("BattleAutoExitAction") --通用，等待战斗结束
    self:addActionName("newD.GuideAction2440") --对话  --跳转到主城 隐藏副本相关模块
    self:addActionName("newD.GuideAction418")  --领取奖励，通用
    self:addActionName("newD.GuideAction2441") --对话460
    self:addActionName("newD.GuideAction461")  --玩家头像
    self:addActionName("newD.GuideAction462")  --点击统率升级
    self:addActionName("newD.GuideAction462e") --点击统率升级
    self:addActionName("newD.GuideAction464")  --离开--
    --引导招兵 47
    self:addActionName("MoveSceneAction")      --移动主城步骤
    self:addActionName("newD.GuideAction405")  --移动到主城兵营
    self:addActionName("newD.GuideAction406e")  --前往招兵
    --self:addActionName("newD.GuideAction407e") --征召步兵 具体个数 征召20只步兵  需要不同步骤
    self:addActionName("newD.GuideAction408e") --征召步兵 具体个数 征召20只步兵
    self:addActionName("newD.GuideAction409")  --加速
    self:addActionName("newD.GuideAction411")  --离开兵营
    -- 打战役 54
    self:addActionName("newD.GuideAction434e") -- 点击战役 -  自动跳转到第一章
    self:addActionName("newD.GuideAction440")  -- 点击第二个关卡 --  自动设置最大战力
    self:addActionName("newD.GuideAction438")  -- 点击挑战   关卡界面的通用
    self:addActionName("BattleAutoExitAction") -- 通用，等待战斗结束
    self:addActionName("newD.GuideAction2442") -- 对话 470
    self:addActionName("newD.GuideAction441")  -- 点击第三个关卡 --  自动设置最大战力
    self:addActionName("newD.GuideAction438")  -- 点击挑战 关卡界面的通用
    self:addActionName("BattleAutoExitAction") -- 通用，等待战斗结束
    self:addActionName("newD.GuideAction471")  -- 点击第四个关卡 --  自动设置最大战力
    self:addActionName("newD.GuideAction438")  -- 点击挑战 关卡界面的通用
    self:addActionName("BattleAutoExitAction") -- 通用，等待战斗结束
    self:addActionName("newD.GuideAction2443") -- 对话GuideAction472 跳转到主城 隐藏副本相关模块 
    --兵营升级 66
    self:addActionName("MoveSceneAction")
    self:addActionName("newD.GuideAction443")  --点击兵营
    self:addActionName("newD.GuideAction444")  --点击升级按钮  2级
    self:addActionName("newD.GuideAction445")  --点击免费 
    --特效 解锁武将上阵槽位  -- 70
    self:addActionName("newD.GuideAction444")  --点击升级按钮  3级
    self:addActionName("newD.GuideAction445")  --点击免费 
    self:addActionName("newD.GuideAction448")  --点击招兵标签按钮 
    self:addActionName("newD.GuideAction449")  --点击骑兵  
    self:addActionName("newD.GuideAction450")  --点击训练  -- 30只
    self:addActionName("newD.GuideAction451")  --点击加速  -- 可能需要直接加速完毕，而不弹框
    self:addActionName("newD.GuideAction452")  --点击返回
    self:addActionName("newD.GuideAction434e") -- 点击战役 -  自动跳转到第一章
    self:addActionName("newD.GuideAction471")  --点击第四个关卡 --  自动设置最大战力
    self:addActionName("newD.GuideAction438")  --  点击挑战 关卡界面的通用
    self:addActionName("BattleAutoExitAction") --通用，等待战斗结束
    self:addActionName("newD.GuideAction2444") --对白GuideAction474
    self:addActionName("newD.GuideAction475")  --战役宝箱 
    self:addActionName("newD.GuideAction476")  --领取招募令
    -- 酒馆 84
    self:addActionName("newD.new.GuideAction480")  --点击点击酒馆
    self:addActionName("newD.new.GuideAction481")  --点击九连抽
    self:addActionName("newD.new.GuideAction482")  --点击酒令
    self:addActionName("newD.new.GuideAction483")  --点击良将令
    self:addActionName("newD.new.GuideAction2445") --剧情对白GuideAction484
    -- 上阵武将 89
    self:addActionName("newD.GuideAction429")  --点击阵容按钮 下面也会用到
    self:addActionName("newD.GuideAction430")  --点击一号槽位
    self:addActionName("newD.GuideAction431")  --点击上阵按钮 
    self:addActionName("newD.GuideAction418")  --领取奖励，通用
    self:addActionName("newD.GuideAction418")  --领取奖励，通用 --TODO 这里需要间隔
    self:addActionName("newD.GuideAction2446") --对话GuideAction458  --引导结束，弹出奖励模块
    -- 结束 95
end


return Guide104