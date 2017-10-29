--[[
-----新的引导剧本
--]]
local Guide103 = class("Guide103",Guide)

function Guide103:ctor(gameState)
    Guide103.super.ctor(self, gameState)
    
    self.id = 103
    
    self:addActionName("new.GuideAction301") --主公，百姓夹道欢迎主公进城，我们抓紧进城，倾听下百姓的心声。
    self:addActionName("new.GuideAction302") --点击玩家主城 --TODO 需要确定初始化在那个模块
    self:addActionName("new.GuideAction303") --对话
    self:addActionName("new.GuideAction304") --对话
    --引导招兵
    self:addActionName("MoveSceneAction")     --移动主城步骤
    self:addActionName("new.GuideAction305")  --移动到主城兵营
    self:addActionName("new.GuideAction306")
    self:addActionName("new.GuideAction307")
    self:addActionName("new.GuideAction308")
    self:addActionName("new.GuideAction309") --加速
--    self:addActionName("new.GuideAction310") --加速确认框
    self:addActionName("new.GuideAction311")
    --引导剿匪
    self:addActionName("new.GuideAction312") --点击Toolbar世界按钮，通用
    self:addActionName("new.GuideAction313") --点击黄巾贼副本
    self:addActionName("new.GuideAction314") --对话
    self:addActionName("new.GuideAction315")
    self:addActionName("new.GuideAction316")
    self:addActionName("BattleAutoExitAction") --通用，等待战斗结束
    --引导升级主城
    self:addActionName("new.GuideAction317")
    self:addActionName("new.GuideAction318") --领取奖励，通用
    ---------此处有特效  升级   功能解锁
    self:addActionName("new.GuideAction319") --对话
    self:addActionName("new.GuideAction399") --点击Toolbar世界按钮，通用
    self:addActionName("MoveSceneAction") --移动主城步骤
    self:addActionName("new.GuideAction320")  --点击主城官邸
    self:addActionName("new.GuideAction321") --点击 官邸升级
    self:addActionName("new.GuideAction322") --点击免费（加速一个按钮）
    -- self:addActionName("new.GuideAction321") --点击 官邸升级
    -- self:addActionName("new.GuideAction322") ---点击加速 --这里有可能会直接
    -- self:addActionName("new.GuideAction322") --点击免费（加速一个按钮） 
    self:addActionName("new.GuideAction321") --点击 官邸升级
    self:addActionName("new.GuideAction323") --对话
    self:addActionName("new.GuideAction324") --点击加速
    self:addActionName("new.GuideAction324e") --5分钟加速使用
    self:addActionName("new.GuideAction324e1") --5分钟后，免费加速
    self:addActionName("new.GuideAction325") --对话  关闭建筑升级面板

    self:addActionName("new.GuideAction318") --领取奖励，通用
    ---------此处有特效  升级   功能解锁
    --引导武将上阵
    self:addActionName("new.GuideAction326") --对话
    --TODO 系统 自动弹出招募令使用界面 做在326步结束逻辑
    self:addActionName("new.GuideAction327") --TODO 招募令使用，先跳到背包，直接弹出使用弹窗

    --特效---新武将获取
    --确定获得新武将
    self:addActionName("new.GuideAction328") --对话

    self:addActionName("new.GuideAction329")   --点击阵容按钮 下面也会用到
    self:addActionName("new.GuideAction330")   --点击一号槽位
    self:addActionName("new.GuideAction331")   --点击上阵按钮 
    --特效  战力
    self:addActionName("new.GuideAction332") --对话 隐藏英雄模块
    self:addActionName("new.GuideAction318") --领取奖励，通用
    --特效 升级 功能解锁
    self:addActionName("new.GuideAction333") --对话
    self:addActionName("new.GuideAction334") -- 点击战役
    self:addActionName("new.GuideAction335") --点击第一章 101
    self:addActionName("new.GuideAction336") --点击第一个关卡 弹出队伍界面  --  自动设置最大战力
    self:addActionName("new.GuideAction337") --对话
    self:addActionName("new.GuideAction338") -- 点击挑战 关卡界面的通用
    self:addActionName("BattleAutoExitAction") --通用，等待战斗结束
    --特效 新武将获取
    self:addActionName("new.GuideAction339") --对话
    self:addActionName("new.GuideAction340") --点击第二个关卡 --  自动设置最大战力
    self:addActionName("new.GuideAction338") --  点击挑战   关卡界面的通用
    self:addActionName("BattleAutoExitAction") --通用，等待战斗结束
    self:addActionName("new.GuideAction341") --点击第三个关卡 --  自动设置最大战力
    self:addActionName("new.GuideAction338") --  点击挑战 关卡界面的通用
    self:addActionName("BattleAutoExitAction") --通用，等待战斗结束
    --特效 新武将获取
    self:addActionName("new.GuideAction342") --对话  --跳转到主城 隐藏副本相关模块 TODO在这步还有问题

    --特效 升级

    --兵营升级
    self:addActionName("MoveSceneAction")
    self:addActionName("new.GuideAction343")  --点击兵营
    self:addActionName("new.GuideAction344")  --点击升级按钮  2级
    self:addActionName("new.GuideAction345")  --点击免费 TODO 还未处理 需要判断如果时间到了怎么处理
    --特效 解锁武将上阵槽位 TODO
    self:addActionName("new.GuideAction344")  --点击升级按钮  3级
    self:addActionName("new.GuideAction345")  --点击免费 TODO 还未处理 需要判断如果时间到了怎么处理
    -- self:addActionName("new.GuideAction344")  --点击升级按钮  4级
    -- self:addActionName("new.GuideAction345")  --点击免费 TODO 还未处理 需要判断如果时间到了怎么处理
    --特效TODO 解锁武将上阵操作 解锁骑兵
    self:addActionName("new.GuideAction346") --对话
    -- self:addActionName("new.GuideAction347") --对话
    -- self:addActionName("new.GuideAction348")  --点击招兵标签按钮 
    -- self:addActionName("new.GuideAction349")  --点击骑兵  
    -- self:addActionName("new.GuideAction350")  --点击训练 
    -- self:addActionName("new.GuideAction351")  --点击加速  --TODO 可能需要直接加速完毕，而不弹框
--    self:addActionName("new.GuideAction310") --加速确认框
    self:addActionName("new.GuideAction352")  --点击返回
    --武将上阵
    self:addActionName("new.GuideAction329")   --点击阵容按钮 通用
    self:addActionName("new.GuideAction353")  --点击槽位2 TODO 有未上阵的，好像直接弹出武将选择了第二次
    self:addActionName("new.GuideAction354")  --点击上阵 
    self:addActionName("new.GuideAction355")  --点击槽位3 
    self:addActionName("new.GuideAction356")  --点击上阵 

    self:addActionName("new.GuideAction357") --对话  --隐藏英雄模块 直接跳转到主城
    self:addActionName("new.GuideAction318") --领取奖励，通用
    self:addActionName("new.GuideAction318") --领取奖励，通用
    self:addActionName("new.GuideAction358") --对话  --引导结束，弹出奖励模块

end

return Guide103