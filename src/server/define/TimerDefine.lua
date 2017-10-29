module("server", package.seeall)
TimerDefine = {}

----******定时器类型**************/
TimerDefine.DEFAULT_ENERGY_RECOVER = 1  --恢复体力
TimerDefine.ADVENCE_REFRESH= 2  --副本探险次数
TimerDefine.BUILDING_LEVEL_UP= 3  --建筑升级
TimerDefine.DEFAULT_BOOM_RECOVER = 4  --恢复繁荣度
TimerDefine.DEFAULT_GET_PRESTIGE = 5  --登录领取声望
TimerDefine.TIMER_TYPE_RESOUCE = 6  --资源产出定时器
TimerDefine.FRIEND_BLESS = 7  --好友祝福获得体力
TimerDefine.BUY_ENERGY = 8  --购买体力
TimerDefine.BUILD_CREATE =10  --建筑生产
TimerDefine.TECHNOLOGY_LEVEL_UP = 11  --科技升级
TimerDefine.PERFORM_TASK = 12  --执行任务
TimerDefine.ITEM_BUFF = 13  --道具使用增加玩家buff
TimerDefine.DEFAULT_TODAYGET_PRESTIGE = 14  --今日授勋声望
TimerDefine.TIMIER_LOTTERY= 15  --武将抽奖次数//免费时间
TimerDefine.TIMIER_LOTTERY_TAOBAO= 16  --淘宝免费
TimerDefine.FRIEND_DAY_BLESS = 17  --每日的祝福可获取奖励的次数
TimerDefine.FRIEND_DAY_GET_BLESS = 18  --每日可领取祝福奖励的次数
TimerDefine.FRIEND_DAY_ACTIVITY = 19  --日常活跃
TimerDefine.FRIEND_DAY_MESSION= 20  --日常任务次数
TimerDefine.FRIEND_DAY_BE_BLESS = 21  --好友被祝福的定时器
TimerDefine.BUY_ADVANCE_TIMES = 22  --购买冒险次数
TimerDefine.ARENA_FIGHT = 23  --竞技场等待时间
TimerDefine.ARENA_TIMES = 24  --竞技场挑战次数
TimerDefine.ARENA_ADD_TIMES = 26  --竞技购买挑战次数
TimerDefine.TIMIER_LOTTERY_TODAY= 25  --武将抽奖免费今日抽过的次数
TimerDefine.LASTARENAREWAED= 27  --竞技场上期排名
TimerDefine.LOGIN_DAY_NUM = 28  --30天登录奖励
TimerDefine.LOGIN_LOTTERY = 29  --每日登录抽奖
TimerDefine.ARMYGROUP_SHOP = 30  --军团兑换商店
TimerDefine.ARMYGROUP_HALL_CONTIBUTE = 31  --军团大厅捐献金币,资源
TimerDefine.ARMYGROUP_TECH_CONTIBUTE = 32  --军团科技捐献金币,资源
TimerDefine.ARMYGROUP_WELFAREREWARD = 33  --军团福利院领取福利
TimerDefine.DAY_TASK_REST = 34  --日常任务重置次数
TimerDefine.LIMIT_CHANGET_TIMES = 35  --极限挑战次数
TimerDefine.LIMIT_CHANGET_REST = 36  --极限重置次数
TimerDefine.LIMIT_CHANGET_MOPPING = 37  --极限挑战扫荡
TimerDefine.ACTIVITY_REFRESH = 38  --活动每分钟刷新
TimerDefine.BUILD_AUTO_LEVLE_UP = 39  --建筑自动升级
TimerDefine.BUILD_DEGREE = 40  --繁荣度达到满值
TimerDefine.LEGION_ALLTIME_DONATE= 41  --总科技捐赠次数

 ----*时间定义**/
TimerDefine.DEFAULT_TIME_RECOVER = 30*60*1000  --恢复体力所需时间:30分钟
TimerDefine.DEFAULT_TIME_BOOM = 60*1000  --恢复繁荣度所需时间:1分钟
TimerDefine.ONE_DAY = 60*60*24*1000  --一天的毫秒数
TimerDefine.BUFF_MSEL = 60*1000  --道具buff的开始结束时间转为毫秒数
TimerDefine.ARENA_FIGHT_RESHTIME = 10*60*1000  --竞技场刷新毫秒数

TimerDefine.DEFAULT_TIME_RESOUCE = 60  --资源校验时间

 ----******次数定义********/
TimerDefine.ARENA_FIGHT_TIMES=5  --每天初始次数


 ----******定时器刷新类型**************/
TimerDefine.TIMER_REFRESH_NONE = -1  --不用每天刷新
TimerDefine.TIMER_REFRESH_ZERO= 0  --0点刷新(后面全部改为4点)
TimerDefine.TIMER_REFRESH_TWTEEN=12  --12点刷新(后面全部改为4点)
TimerDefine.TIMER_REFRESH_FOUR= 4  --4点刷新

 ----******自动升级开关********/
TimerDefine.BUILDAUTOLEVEL_OPEN = 1  --开启自动升级
TimerDefine.BUILDAUTOLEVEL_OFF = 0  --自动升级关掉
TimerDefine.BUILDAUTOLEVELPRICE = 238  --自动升级价格
TimerDefine.BUILDAUTOLEVEL_ADDTIME=4*60*60  --持续的时间 s

TimerDefine.RONCUOONEMINUTE=1*60*1000  --1分钟

-----------当前Trigger操作的时间----------------
TimerDefine.triggerTime = os.time()

