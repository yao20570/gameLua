module("server", package.seeall)

ResFunBuilding = class("ResFunBuilding")

function ResFunBuilding:ctor()
    self.bigType = 0  --//建筑大类
    self.smallType = 0  --;//建筑类型
    self.index = 0  --;//建筑位置
    self.level = 0  --;
    self.nextLevelTime = 0 --;//下一级升级完成时间
    self.lastBlanceTime = 0 --;//上次结算时间
    self.state = 0  --;//0功能未开启
end