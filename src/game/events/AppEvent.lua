
AppEvent = {}

--模块事件
AppEvent.MODULE_EVENT = "module_event"  
AppEvent.MODULE_OPEN_EVENT = "module_open_event" 
AppEvent.MODULE_LOADING_OPEN_EVENT = "module_loading_open_event" --通过加载界面打开模块
AppEvent.MODULE_CLOSE_EVENT = "module_close_event"  
AppEvent.MODULE_FINALIZE_EVENT = "module_finalize_event" --模块释放事件

--状态事件
AppEvent.STATE_EVENT = "state_event"
AppEvent.STATE_CHANGE_EVENT = "state_change_event"

--场景事件
AppEvent.SCENE_EVENT = "scene_event"
AppEvent.SCENE_ENTER_EVENT = "scene_enter_event"
AppEvent.SCENEMAP_MOVE_UPDATE = "scenemap_move_update"  --更新主城地图坐标

--游戏事件
AppEvent.GAME_EVENT = "game_event"
AppEvent.GAME_LOGOUT_EVENT = "game_logout_event"
AppEvent.GAME_SCENE_LOGIN_EVENT = "game_scene_login_event" --在场景中登录游戏

--网络事件
AppEvent.NET_EVENT = "net_event"
AppEvent.NET_SEND_DATA = "net_send_data" --发送数据
AppEvent.NET_START_CONNECT = "net_start_connect" --开始网络链接
AppEvent.NET_SUCCESS_CONNECT = "net_success_connect" --成功连接上网络
AppEvent.NET_FAIL_CONNECT = "net_fail_connect" --连接失败
AppEvent.NET_SUCCESS_RECONNECT = "net_success_reconnect" --重新连接成功
AppEvent.NET_HAND_CLOSE_CONNECT = "net_hand_close_connect" --请求手动网络关闭
AppEvent.NET_AUTO_CLOSE_CONNECT = "net_auto_close_connect" --自动关闭网络，需要重连
AppEvent.NET_FAILURE_RECONNECT = "net_failure_reconnect" --重连失败

-------------loader event -----
AppEvent.LOADER_MAIN_EVENT = "loader_main_event" --加载事件
AppEvent.LOADER_UPDATE_PROGRESS = "loader_update_progress" --进度更新
AppEvent.LOADER_UPDATE_STATE = "loader_update_state" --更新状态

------------m2m event------模块间通讯事件------
AppEvent.M2M_MAIN_EVENT = "m2m_main_event"
AppEvent.WATCH_WORLD_TILE = "watch_world_tile" --查看世界某个格子

--接受到的具体协议，数字对应相应的协议号
AppEvent.NET_M1 = 1  --登录协议
AppEvent.NET_M1_C8888 = 8888 --心跳

AppEvent.NET_M1_C9988 = 9988 --退出排队系统
AppEvent.NET_M1_C9998 = 9998 --通知异地登陆
AppEvent.NET_M1_C9999 = 9999 --登录网关
AppEvent.NET_M1_C10000 = 10000 --登录游戏
AppEvent.NET_M1_C10001 = 10001
AppEvent.NET_M1_C10002 = 10002 --登录后的事件ID 只能记录登录成功的


AppEvent.NET_M2 = 2  --角色信息协议
AppEvent.NET_M2_C20000 = 20000  --角色属性信息
AppEvent.NET_M2_C20001 = 20001  --角色军衔升级
AppEvent.NET_M2_C20002 = 20002  --角色属性更改
-- AppEvent.NET_M2_C20002 = 20002  --角色power修改推送
AppEvent.NET_M2_C20003 = 20003  --角色繁荣等级升级
AppEvent.NET_M2_C20004 = 20004  --角色统帅等级升级
AppEvent.NET_M2_C20005 = 20005  --角色授勋领取声望
AppEvent.NET_M2_C20007 = 20007  --发送各种背包刷新
AppEvent.NET_M2_C20008 = 20008  --创建角色
AppEvent.NET_M2_C20009 = 20009  --奖励飘字
AppEvent.NET_M2_C20010 = 20010  --领取状态
AppEvent.NET_M2_C20011 = 20011  --购买体力
AppEvent.NET_M2_C20012 = 20012  --设置头像
AppEvent.NET_M2_C20013 = 20013  --是否可购买体力  
AppEvent.NET_M2_C20014 = 20014  --设置玩家坐标
AppEvent.NET_M2_C20015 = 20015  --开服礼包的信息
AppEvent.NET_M2_C20016 = 20016  --每日等了礼包的信息
AppEvent.NET_M2_C20017 = 20017  --每日登陆首次领取声望状态
AppEvent.NET_M2_C20018 = 20018  --野外讨伐令购买
AppEvent.NET_M2_C20200 = 20200  --主界面的提示
AppEvent.NET_M2_C20201 = 20201  --更新军团名字
AppEvent.NET_M2_C20300 = 20300  --设置通知选项
AppEvent.NET_M2_C20301 = 20301  --领取新手礼包
AppEvent.NET_M2_C20400 = 20400  --最近联系人
AppEvent.NET_M2_C20500 = 20500  --繁荣定时器
AppEvent.NET_M2_C20501 = 20501  --体力定时器
AppEvent.NET_M2_C20502 = 20502  --讨伐令定时器
AppEvent.NET_M2_C20600 = 20600  --民心刷新奖励
AppEvent.NET_M2_C20601 = 20601  --领取奖励
AppEvent.NET_M2_C20802 = 20802  --称号选择
AppEvent.NET_M2_C20800 = 20800  --服务器主动推送称号
AppEvent.NET_M2_C20805 = 20805  --选择头像框
AppEvent.NET_M2_C20806 = 20806  --服务器主动推送称号

AppEvent.NET_M2_C20807 = 20807  --推送已双倍充值的额度
AppEvent.NET_M2_C20808 = 20808  --手动升级

AppEvent.NET_M3 = 3
AppEvent.NET_M3_C30000 = 30000 --系统定时器
AppEvent.NET_M3_C30100 = 30100 --获取客户端保存在服务端的缓存信息
AppEvent.NET_M3_C30101 = 30101 --更新客户端保存在服务端的缓存信息
AppEvent.NET_M3_C30102 = 30102 --充值成功推送
AppEvent.NET_M3_C30103 = 30103 --凌晨四点刷新好友列表和祝福列表
AppEvent.NET_M3_C30104 = 30104
AppEvent.NET_M3_C30105 = 30105
AppEvent.NET_M3_C30200 = 30200 --请求版本信息

AppEvent.NET_M4 = 4
AppEvent.NET_M4_C40000 = 40000 --佣兵修改的推送
AppEvent.NET_M4_C40001 = 40001 --战损佣兵列表
AppEvent.NET_M4_C40002 = 40002 --修复佣兵

AppEvent.NET_M5 = 5 --战斗相关协议
AppEvent.NET_M5_C50000 = 50000 --请求战斗
AppEvent.NET_M5_C50001 = 50001 --请求战斗结束

AppEvent.NET_M8 = 8
AppEvent.NET_M8_C80000 = 80000 --查看坐标周围的格子信息
AppEvent.NET_M8_C80001 = 80001 --进攻某个点
AppEvent.NET_M8_C80002 = 80002 --侦查某个格子
AppEvent.NET_M8_C80003 = 80003 --部队任务
AppEvent.NET_M8_C80004 = 80004 --部队加速
AppEvent.NET_M8_C80005 = 80005 --搬家
AppEvent.NET_M8_C80006 = 80006 --查看坐标
AppEvent.NET_M8_C80007 = 80007 --被攻击


AppEvent.NET_M8_C80008 = 80008 --
AppEvent.NET_M8_C80009 = 80009 --
AppEvent.NET_M8_C80010 = 80010 --
AppEvent.NET_M8_C80011 = 80011 --随机迁城
AppEvent.NET_M8_C80012 = 80012 --行军时间
AppEvent.NET_M8_C80013 = 80013 --前往驻守
AppEvent.NET_M8_C80014 = 80014 --选择为防守
AppEvent.NET_M8_C80015 = 80015 --被攻击
AppEvent.NET_M8_C80016 = 80016 --请求客户端刷新保护罩
AppEvent.NET_M8_C80103 = 80103 --任务时间到
AppEvent.NET_M8_C80104 = 80104 --新增加一个任务
AppEvent.NET_M8_C80107 = 80107 --校验被攻击
AppEvent.NET_M8_C80108 = 80108 --新增加一个任务(被攻击)
--AppEvent.NET_M8_C80018 = 80018 --请求单个矿点信息
AppEvent.NET_M8_C80017 = 80017 --请求撤军
AppEvent.NET_M8_C80018 = 80018 --首次攻打世界玩家成功推送
AppEvent.NET_M8_C80019 = 80019 --协助驻军id
AppEvent.NET_M8_C80020 = 80020 --废墟时系统随机迁城
AppEvent.NET_M8_C80100 = 80100 --同步请求，当前在世界上，所有的简要队伍信息
AppEvent.NET_M8_C80101 = 80101 --实时推送，当前在世界上的队伍信息更新

AppEvent.NET_M9 = 9  --道具信息协议
AppEvent.NET_M9_C90000 = 90000 --道具推送
AppEvent.NET_M9_C90001 = 90001 --道具使用
AppEvent.NET_M9_C90002 = 90002 --buff倒计时完成后请求
AppEvent.NET_M9_C90003 = 90003 --道具buffer
AppEvent.NET_M9_C90004 = 90004 --特殊道具的使用
AppEvent.NET_M9_C90005 = 90005 --外观道具的使用
AppEvent.NET_M9_C90006 = 90006 --发送公告道具的使用
AppEvent.NET_M9_C90007 = 90007 --增加军团贡献度
AppEvent.NET_M9_C90008 = 90008 --合成道具
AppEvent.NET_M9_C90010 = 90010 --合成道具


AppEvent.NET_M6 = 6           --关卡界面
AppEvent.NET_M6_C60000 = 60000
AppEvent.NET_M6_C60001 = 60001
AppEvent.NET_M6_C60002 = 60002
AppEvent.NET_M6_C60003 = 60003
AppEvent.NET_M6_C60004 = 60004
AppEvent.NET_M6_C60005 = 60005
AppEvent.NET_M6_C60006 = 60006
AppEvent.NET_M6_C60100 = 60100
AppEvent.NET_M6_C60101 = 60101
AppEvent.NET_M6_C60102 = 60102
AppEvent.NET_M6_C60103 = 60103
AppEvent.NET_M6_C60104 = 60104
AppEvent.NET_M6_C60105 = 60105
AppEvent.NET_M6_C60106 = 60106

AppEvent.NET_M7 = 7   --部队协议
AppEvent.NET_M7_C70000 = 70000
AppEvent.NET_M7_C70001 = 70001
AppEvent.NET_M7_C70002 = 70002
AppEvent.NET_M7_C70003 = 70003  --修改阵型名称

AppEvent.NET_M10 = 10   --业务建筑统一协议逻辑
AppEvent.NET_M10_C100000 = 100000 --建筑信息
AppEvent.NET_M10_C100001 = 100001 --建筑升级 包括建造（0级升1级）
AppEvent.NET_M10_C100002 = 100002 --相关建筑更新信息  服务端主动推送，比如生产完毕了一个
AppEvent.NET_M10_C100003 = 100003 --取消升级
AppEvent.NET_M10_C100004 = 100004 --加速升级
AppEvent.NET_M10_C100005 = 100005 --建筑拆除
AppEvent.NET_M10_C100006 = 100006 --建筑生产
AppEvent.NET_M10_C100007 = 100007 --建筑资源/仓库资源 购买
AppEvent.NET_M10_C100008 = 100008 --商店购买协议
AppEvent.NET_M10_C100009 = 100009 --请求购买建筑位
AppEvent.NET_M10_C100010 = 100010 --vip购买建筑位
AppEvent.NET_M10_C100011 = 100011 --购买自动升级建筑
AppEvent.NET_M10_C100012 = 100012 --自动升级建筑开关


AppEvent.NET_M12 = 12   --技能协议
AppEvent.NET_M12_C120000 = 120000 --技能信息
AppEvent.NET_M12_C120001 = 120001 --技能升级
AppEvent.NET_M12_C120002 = 120002 --技能重置

AppEvent.NET_M13 = 13   --装备协议
AppEvent.NET_M13_C130000 = 130000
AppEvent.NET_M13_C130001 = 130001
AppEvent.NET_M13_C130002 = 130002
AppEvent.NET_M13_C130003 = 130003
AppEvent.NET_M13_C130004 = 130004
AppEvent.NET_M13_C130005 = 130005
AppEvent.NET_M13_C130006 = 130006
AppEvent.NET_M13_C130007 = 130007
AppEvent.NET_M13_C130100 = 130100
AppEvent.NET_M13_C130101 = 130101
AppEvent.NET_M13_C130102 = 130102
AppEvent.NET_M13_C130103 = 130103
AppEvent.NET_M13_C130104 = 130104
AppEvent.NET_M13_C130105 = 130105
AppEvent.NET_M13_C130106 = 130106
AppEvent.NET_M13_C130107 = 130107
AppEvent.NET_M13_C130108 = 130108
AppEvent.NET_M13_C130109 = 130109
AppEvent.NET_M13_C130110 = 130110  --晶石兑换物品

AppEvent.NET_M14 = 14    --聊天协议
AppEvent.NET_M14_C140000 = 140000  --获取聊天信息
AppEvent.NET_M14_C140100 = 140100  --请求语音信息
AppEvent.NET_M14_C140001 = 140001  --获取玩家信息
AppEvent.NET_M14_C140002 = 140002  --私聊
AppEvent.NET_M14_C140003 = 140003  --接收到私聊
AppEvent.NET_M14_C140004 = 140004  --单独私聊
AppEvent.NET_M14_C140005 = 140005  --添加到屏蔽列表
AppEvent.NET_M14_C140006 = 140006  --屏蔽列表请求
AppEvent.NET_M14_C140007 = 140007  --移除屏蔽请求
AppEvent.NET_M14_C140008 = 140008  --全服公告
AppEvent.NET_M14_C140009 = 140009  --自己的类型
AppEvent.NET_M14_C140010 = 140010  --举报玩家获取该玩家5分钟内10条聊天信息
AppEvent.NET_M14_C140011 = 140011  --举报提交
AppEvent.NET_M14_C140200 = 140200  --请求是否可以进行自定义头像操作
AppEvent.NET_M14_C140201 = 140201  --头像上传成功，通知服务端进行扣除元宝操作，服务端头像进入审核状态
AppEvent.NET_M14_C140203 = 140203  --头像还原请求，当玩家审核失败

AppEvent.NET_M15 = 15    --抽装备协议
AppEvent.NET_M15_C150000 = 150000  
AppEvent.NET_M15_C150001 = 150001  
AppEvent.NET_M15_C150002 = 150002  
AppEvent.NET_M15_C150003 = 150003  
AppEvent.NET_M15_C150004 = 150004  --战将信息
AppEvent.NET_M15_C150005 = 150005  --战将开宝箱
AppEvent.NET_M15_C150006 = 150006  --战将探宝刷新奖励
AppEvent.NET_M15_C150007 = 150007  --战将探宝抽取奖励
AppEvent.NET_M15_C150008 = 150008  --战将探关闭探宝

AppEvent.NET_M16 = 16    --邮箱协议
AppEvent.NET_M16_C160000 = 160000
AppEvent.NET_M16_C160001 = 160001
AppEvent.NET_M16_C160002 = 160002
AppEvent.NET_M16_C160003 = 160003
AppEvent.NET_M16_C160004 = 160004
AppEvent.NET_M16_C160005 = 160005
AppEvent.NET_M16_C160006 = 160006
AppEvent.NET_M16_C160008 = 160008 -- 收藏邮件
AppEvent.NET_M16_C160009 = 160009 -- 取消收藏邮件
AppEvent.NET_M16_C160011 = 160011 -- 一件领取邮件附件
AppEvent.NET_M16_C160012 = 160012 -- 将邮件状态设置为已阅

AppEvent.NET_M17 = 17    --好友协议
AppEvent.NET_M17_C170000 = 170000  --获取好友列表
AppEvent.NET_M17_C170001 = 170001  --请求添加好友
AppEvent.NET_M17_C170002 = 170002  --搜索
AppEvent.NET_M17_C170003 = 170003  --删除好友请求
AppEvent.NET_M17_C170004 = 170004  --祝福请求
AppEvent.NET_M17_C170005 = 170005  --祝福通知
AppEvent.NET_M17_C170006 = 170006  --请求领取祝福

AppEvent.NET_M19 = 19    --任务协议
AppEvent.NET_M19_C190000 = 190000  --获取任务列表
AppEvent.NET_M19_C190001 = 190001  --任务领取
AppEvent.NET_M19_C190002 = 190002  --日常任务操作
AppEvent.NET_M19_C190003 = 190003  --领取日常活跃
AppEvent.NET_M19_C190004 = 190004  --领取战功活跃

AppEvent.NET_M20 = 20    --竞技场
AppEvent.NET_M20_C200000 = 200000
AppEvent.NET_M20_C200001 = 200001
AppEvent.NET_M20_C200002 = 200002
AppEvent.NET_M20_C200003 = 200003
AppEvent.NET_M20_C200004 = 200004
AppEvent.NET_M20_C200005 = 200005
AppEvent.NET_M20_C200006 = 200006
AppEvent.NET_M20_C200100 = 200100
AppEvent.NET_M20_C200101 = 200101
AppEvent.NET_M20_C200102 = 200102
AppEvent.NET_M20_C200103 = 200103
AppEvent.NET_M20_C200104 = 200104
AppEvent.NET_M20_C200105 = 200105
AppEvent.NET_M20_C200106 = 200106

AppEvent.NET_M21 = 21    --排行榜
AppEvent.NET_M21_C210000 = 210000  --获取分类排行榜
AppEvent.NET_M21_C210001 = 210001  --获取征矿榜数据

AppEvent.NET_M22 = 22    --军团

AppEvent.NET_M22_C220100 = 220100 --军团列表
AppEvent.NET_M22_C220101 = 220101 --查询军团详细信息
AppEvent.NET_M22_C220102 = 220102 --军团申请 取消申请
AppEvent.NET_M22_C220103 = 220103 --创建军团
AppEvent.NET_M22_C220104 = 220104 --军团搜索
AppEvent.NET_M22_C220105 = 220105 --军团搜索

AppEvent.NET_M22_C220200 = 220200 --军团信息
AppEvent.NET_M22_C220201 = 220201 --军团成员操作
AppEvent.NET_M22_C220202 = 220202 --查看审批列表
AppEvent.NET_M22_C220203 = 220203 --同意加入军团
AppEvent.NET_M22_C220204 = 220204 --清空申请列
AppEvent.NET_M22_C220205 = 220205 --审批队列数量

AppEvent.NET_M22_C220210 = 220210 --军团编辑
AppEvent.NET_M22_C220211 = 220211 --军团公告修改

AppEvent.NET_M22_C220220 = 220220 --职位编辑
AppEvent.NET_M22_C220221 = 220221 --升职 任命 
AppEvent.NET_M22_C220002 = 220002 --军团商店

AppEvent.NET_M22_C220012 = 220012 --福利院信息
AppEvent.NET_M22_C220013 = 220013 --福利院升级
AppEvent.NET_M22_C220014 = 220014 --福利院福利领取
AppEvent.NET_M22_C220015 = 220015 --军团活跃资源领取
AppEvent.NET_M22_C220016 = 220016 --战事福利列表
AppEvent.NET_M22_C220017 = 220017 --分配福利

AppEvent.NET_M22_C220010 = 220010 --军团科技大厅升级
AppEvent.NET_M22_C220009 = 220009 --军团科技捐献
AppEvent.NET_M22_C220008 = 220008 --军团大厅捐献
AppEvent.NET_M22_C220007 = 220007 --军团大厅升级
AppEvent.NET_M22_C220000 = 220000 --军团建筑等级
AppEvent.NET_M22_C220300 = 220300 --军团情报站
AppEvent.NET_M22_C220400 = 220400 --军团招募

AppEvent.NET_M22_C220500 = 220500 --获取军团帮助列表
AppEvent.NET_M22_C220501 = 220501 --军团帮助
AppEvent.NET_M22_C220502 = 220502 --更新帮助信息
AppEvent.NET_M22_C220503 = 220503 --解散军团
AppEvent.NET_M22_C220600 = 220600 --初始化军团信息
AppEvent.NET_M22_C220700 = 220700 --军团公告请求推送

AppEvent.NET_M22_C220800 = 220800 --郡城信息推送
AppEvent.NET_M22_C220803 = 220803 --都城信息推送
AppEvent.NET_M22_C220804 = 220804 --皇城信息推送
AppEvent.NET_M22_C220801 = 220801 --个人分红奖励推送
AppEvent.NET_M22_C220802 = 220802 --单个城池状态刷新
AppEvent.NET_M22_C220810 = 220810 --城池奖励小红点推送

AppEvent.NET_M23 = 23   --活动
AppEvent.NET_M23_C230000 = 230000 --活动列表
AppEvent.NET_M23_C230001 = 230001 --领奖\购买
AppEvent.NET_M23_C230002 = 230002 --限时活动列表
AppEvent.NET_M23_C230003 = 230003 --拉霸活动信息
AppEvent.NET_M23_C230004 = 230004
AppEvent.NET_M23_C230005 = 230005 --获取有福同享礼包列表
AppEvent.NET_M23_C230006 = 230006 --领取奖励
AppEvent.NET_M23_C230007 = 230007
AppEvent.NET_M23_C230008 = 230008 --活动关闭
AppEvent.NET_M23_C230009 = 230009 --新增一个限时活动
AppEvent.NET_M23_C230010 = 230010 
AppEvent.NET_M23_C230011 = 230011 
AppEvent.NET_M23_C230012 = 230012 
AppEvent.NET_M23_C230013 = 230013 
AppEvent.NET_M23_C230014 = 230014 
AppEvent.NET_M23_C230015 = 230015
AppEvent.NET_M23_C230016 = 230016
AppEvent.NET_M23_C230017 = 230017
AppEvent.NET_M23_C230018 = 230018
AppEvent.NET_M23_C230019 = 230019
AppEvent.NET_M23_C230020 = 230020
AppEvent.NET_M23_C230021 = 230021
AppEvent.NET_M23_C230022 = 230022
AppEvent.NET_M23_C230023 = 230023
AppEvent.NET_M23_C230024 = 230024
AppEvent.NET_M23_C230025 = 230025
AppEvent.NET_M23_C230026 = 230026 --爆竹酉礼领取
AppEvent.NET_M23_C230027 = 230027 --抢红包
AppEvent.NET_M23_C230028 = 230028 --红包功能推送新增跟消失 
AppEvent.NET_M23_C230029 = 230029 --红包数量变更服务器3秒主动推送，当检查有数据更变的时候
AppEvent.NET_M23_C230030 = 230030
AppEvent.NET_M23_C230031 = 230031
AppEvent.NET_M23_C230032 = 230032 --武学讲坛学习
AppEvent.NET_M23_C230033 = 230033 --煮酒论英雄更换煮酒英雄
AppEvent.NET_M23_C230034 = 230034 --煮酒论英雄敬酒
AppEvent.NET_M23_C230036 = 230036 --校验活动在线时间
AppEvent.NET_M23_C230037 = 230037 --连续充值补签
AppEvent.NET_M23_C230038 = 230038 --连续充值领取奖励
AppEvent.NET_M23_C230039 = 230039 --活动商店-特卖
AppEvent.NET_M23_C230040 = 230040 --活动商店-请求购买特卖物品
AppEvent.NET_M23_C230041 = 230041 --礼贤下士-请求礼贤

AppEvent.NET_M23_C230042 = 230042 --国之重器收集
AppEvent.NET_M23_C230043 = 230043 --国之重器指定槽位购买
AppEvent.NET_M23_C230044 = 230044 --国之重器组装
AppEvent.NET_M23_C230045 = 230045 --雄狮轮盘征召
AppEvent.NET_M23_C230046 = 230046 --精绝古城购买（去蒙板）
AppEvent.NET_M23_C230047 = 230047 --精绝古城抽奖
AppEvent.NET_M23_C230048 = 230048 --精绝古城手动重置
AppEvent.NET_M23_C230049 = 230049 --精绝古城兑换
AppEvent.NET_M23_C230050 = 230050 --充值返利转盘
AppEvent.NET_M23_C230051 = 230051 --充值返利领取返利
AppEvent.NET_M23_C230052 = 230052 --服务器主动推送 充值后返利信息
AppEvent.NET_M23_C230053 = 230053 --领取同盟致富任务奖励
AppEvent.NET_M23_C230054 = 230054 --查看同盟成员采集信息
AppEvent.NET_M23_C230055 = 230055 --服务器主动推送 任务完成
AppEvent.NET_M23_C230056 = 230056 --打开同盟致富活动界面

AppEvent.NET_M23_C230057 = 230057 --幸运轮盘抽奖
AppEvent.NET_M23_C230059 = 230059 --招财转运抽奖


AppEvent.NET_M24 = 24
AppEvent.NET_M24_C240000 = 240000

AppEvent.NET_M25 = 25 --分享
AppEvent.NET_M25_C250000 = 250000

AppEvent.NET_M26 = 26 --军师府
AppEvent.NET_M26_C260000 = 260000
AppEvent.NET_M26_C260001 = 260001
AppEvent.NET_M26_C260002 = 260002
AppEvent.NET_M26_C260003 = 260003
AppEvent.NET_M26_C260004 = 260004
AppEvent.NET_M26_C260005 = 260005
AppEvent.NET_M26_C260006 = 260006
AppEvent.NET_M26_C260007 = 260007
AppEvent.NET_M26_C260008 = 260008



AppEvent.NET_M27 = 27 --军团副本
AppEvent.NET_M27_C270000 = 270000
AppEvent.NET_M27_C270001 = 270001
AppEvent.NET_M27_C270002 = 270002
AppEvent.NET_M27_C270003 = 270003
AppEvent.NET_M27_C270004 = 270004
-- AppEvent.NET_M27_C270005 = 270005

AppEvent.NET_M28 = 28 --新的建筑协议
AppEvent.NET_M28_C280001 = 280001 --建筑请求升级 包括建造（0级升1级）
AppEvent.NET_M28_C280002 = 280002 --请求完成升级, 正常升级
AppEvent.NET_M28_C280003 = 280003 --取消建筑升级
AppEvent.NET_M28_C280004 = 280004 --建筑加速升级, 加速升级
AppEvent.NET_M28_C280005 = 280005 --野外建筑拆除
AppEvent.NET_M28_C280006 = 280006 --建筑生产 包括 兵营，校场，工匠坊，科技
AppEvent.NET_M28_C280007 = 280007 --请求生产完成
AppEvent.NET_M28_C280008 = 280008 --取消生产 
AppEvent.NET_M28_C280009 = 280009 --加速生产
AppEvent.NET_M28_C280011 = 280011 --VIP购买建筑位
AppEvent.NET_M28_C280012 = 280012 --购买自动升级建筑
AppEvent.NET_M28_C280013 = 280013 --自动升级建筑开关
AppEvent.NET_M28_C280014 = 280014 --完成自动升级建筑 升级建筑倒计时已经结束
AppEvent.NET_M28_C280015 = 280015
AppEvent.NET_M28_C280016 = 280016
AppEvent.NET_M28_C280017 = 280017

AppEvent.NET_M29 = 29 -- 武将协议
AppEvent.NET_M29_C290001 = 290001 --更换武将
AppEvent.NET_M29_C290003 = 290003 --升级武将
AppEvent.NET_M29_C290004 = 290004 --将魂加点(升级)
AppEvent.NET_M29_C290005 = 290005 --将魂加点重置

AppEvent.NET_M30 = 30 -- 英雄协议
AppEvent.NET_M30_C300000 = 300000 --武将上阵或更换
AppEvent.NET_M30_C300001 = 300001 --武将升级/升星
AppEvent.NET_M30_C300002 = 300002 --阵法升级
AppEvent.NET_M30_C300003 = 300003 --武将兵法升级
AppEvent.NET_M30_C300005 = 300005 --武将交换位置
AppEvent.NET_M30_C300006 = 300006 --英雄宝具槽位升阶
AppEvent.NET_M30_C300007 = 300007 --请求完成英雄图鉴任务
AppEvent.NET_M30_C300100 = 300100 --武将碎片合成
AppEvent.NET_M30_C300101 = 300101 --英雄分解
AppEvent.NET_M30_C300102 = 300102 --英雄分解预览
AppEvent.NET_M30_C300103 = 300103 --经书出售

AppEvent.NET_M31 = 31 -- 战斗类活动协议

AppEvent.NET_M32 = 32 -- 世界Boss协议
AppEvent.NET_M32_C320000 = 320000 --boss活动
AppEvent.NET_M32_C320001 = 320001 --攻击
AppEvent.NET_M32_C320002 = 320002 --鼓舞
AppEvent.NET_M32_C320003 = 320003 --设置阵型
AppEvent.NET_M32_C320004 = 320004 --排行榜数据
AppEvent.NET_M32_C320005 = 320005 --排行榜数据
AppEvent.NET_M32_C320006 = 320006 --进入退出场景通知
AppEvent.NET_M32_C320007 = 320007 --进入退出场景通知
AppEvent.NET_M32_C320008 = 320008 --进入退出场景通知
AppEvent.NET_M32_C320009 = 320009 --进入退出场景通知

AppEvent.NET_M33 = 33 -- 群雄涿鹿协议
AppEvent.NET_M33_C330000 = 330000
AppEvent.NET_M33_C330001 = 330001
AppEvent.NET_M33_C330002 = 330002
AppEvent.NET_M33_C330003 = 330003
AppEvent.NET_M33_C330004 = 330004
AppEvent.NET_M33_C330005 = 330005
AppEvent.NET_M33_C330006 = 330006
AppEvent.NET_M33_C330007 = 330007
AppEvent.NET_M33_C330008 = 330008
AppEvent.NET_M33_C330009 = 330009
AppEvent.NET_M33_C330010 = 330010
AppEvent.NET_M33_C330101 = 330101

AppEvent.NET_M34 = 34 --剿匪副本
AppEvent.NET_M34_C340000 = 340000   --副本数据同步，休整时间结束后，才会请求
AppEvent.NET_M34_C340001 = 340001   --请求剿匪副本战斗
AppEvent.NET_M34_C340002 = 340002   --剿匪副本全体刷新

AppEvent.NET_M35 = 35 -- 宝具协议
AppEvent.NET_M35_C350000 = 350000 --宝具穿戴（穿上，卸下，更换）
AppEvent.NET_M35_C350001 = 350001 --宝具洗练
AppEvent.NET_M35_C350002 = 350002 --宝具洗练属性恢复
AppEvent.NET_M35_C350003 = 350003 --宝具分解
AppEvent.NET_M35_C350004 = 350004 --宝具碎片分解
AppEvent.NET_M35_C350005 = 350005 --宝具碎片合成宝具

AppEvent.NET_M37 = 37 -- 科举协议
AppEvent.NET_M37_C370000 = 370000 --查看具体的乡试信息
AppEvent.NET_M37_C370001 = 370001 --乡试开始答题
AppEvent.NET_M37_C370002 = 370002 --乡试提交答题
AppEvent.NET_M37_C370003 = 370003 --乡试排行榜
AppEvent.NET_M37_C370004 = 370004 --领取本次乡试积分奖励
AppEvent.NET_M37_C370005 = 370005 --乡试在场景时间到了请求下一题倒计时到0时
AppEvent.NET_M37_C370100 = 370100 --查看具体的殿试信息
AppEvent.NET_M37_C370101 = 370101 --殿试通知开启答题了
AppEvent.NET_M37_C370102 = 370102 --殿试提交答题
AppEvent.NET_M37_C370103 = 370103 --殿试排行榜 在殿试关闭状态才会请求 且请求一次就好了
AppEvent.NET_M37_C370104 = 370104 --领取殿试排行榜

AppEvent.NET_M38 = 38 -- vip特供
AppEvent.NET_M38_C380000 = 380000 --基本信息
AppEvent.NET_M38_C380001 = 380001 --领取

AppEvent.NET_M39 = 39 -- 国策、兵法
AppEvent.NET_M39_C390000 = 390000 --基本信息
AppEvent.NET_M39_C390001 = 390001 --天赋升级
AppEvent.NET_M39_C390002 = 390002 --天赋重置
AppEvent.NET_M39_C390003 = 390003 --天赋激活

AppEvent.NET_M40 = 40 -- 叛军
AppEvent.NET_M40_C400000 = 400000 --叛军列表
AppEvent.NET_M40_C400001 = 400001 --叛军活动当前周的信息
AppEvent.NET_M40_C400002 = 400002 --叛军活动上一周的信息
AppEvent.NET_M40_C400003 = 400003 --领取奖励（上一周的奖励 ）

AppEvent.NET_M41 = 41 -- 洛阳闹市
AppEvent.NET_M41_C410000 = 410000 --打折商人
AppEvent.NET_M41_C410001 = 410001 --黑市商人
AppEvent.NET_M41_C410002 = 410002 --特卖商人
AppEvent.NET_M41_C410003 = 410003 --购买商品
AppEvent.NET_M41_C410004 = 410004 --抢优惠券

AppEvent.NET_M42 = 42 -- 点评系统
AppEvent.NET_M42_C420000 = 420000 -- 获得评论信息列表
AppEvent.NET_M42_C420001 = 420001 -- 发送点评
AppEvent.NET_M42_C420002 = 420002 -- 点赞

AppEvent.NET_M43 = 43 -- 热卖礼包
AppEvent.NET_M43_C430000 = 430000 --购买后刷新活动
AppEvent.NET_M43_C430001 = 430001 --检测一个热卖活动是否开启
AppEvent.NET_M43_C430002 = 430002 --检测一个热卖活动是否可以购买

AppEvent.NET_M45 = 45 -- 酒馆协议
AppEvent.NET_M45_C450000 = 450000 --获取酒馆小宴信息
AppEvent.NET_M45_C450001 = 450001 --获取酒馆盛宴信息
AppEvent.NET_M45_C450002 = 450002 --小宴购买女儿红
AppEvent.NET_M45_C450003 = 450003 --盛宴购买竹叶青
AppEvent.NET_M45_C450004 = 450004 --小宴单抽（购买）
AppEvent.NET_M45_C450005 = 450005 --酒馆小宴九抽（购买）
AppEvent.NET_M45_C450006 = 450006 --酒馆盛宴单抽（购买）
AppEvent.NET_M45_C450007 = 450007 --酒馆盛宴九抽购买
AppEvent.NET_M45_C450008 = 450008 --酒令兑换（购买）
AppEvent.NET_M45_C450009 = 450009 --小宴界面公告
AppEvent.NET_M45_C450010 = 450010 --盛宴界面公告
AppEvent.NET_M45_C450011 = 450011 --获取酒令兑换信息

AppEvent.NET_M46 = 46 -- 实名制协议
AppEvent.NET_M46_C460000 = 460000 --申请实名制
AppEvent.NET_M46_C460001 = 460001 --客户端通知服务端后台实名制开关状态

AppEvent.NET_M47 = 47 -- 盟战州城
AppEvent.NET_M47_C470000 = 470000 -- 查看某个州城
AppEvent.NET_M47_C470100 = 470100 -- 盟城宣战

AppEvent.NET_M47_C470002 = 470002 -- 请求该州的全服战报
AppEvent.NET_M47_C470003 = 470003 -- 请求空闲队伍

AppEvent.NET_M47_C470005 = 470005 -- 请求州排名

AppEvent.NET_M47_C470006 = 470006 -- 请求州城信息

AppEvent.NET_M47_C470007 = 470007 -- 请求州的贸易信息
AppEvent.NET_M47_C470009 = 470009 -- 请求兑换
AppEvent.NET_M47_C470201 = 470201 -- 请求天下大势信息

AppEvent.NET_M48 = 48 -- 四季协议
AppEvent.NET_M48_C480000 = 480000 --推送世界等级功能开放
AppEvent.NET_M48_C480001 = 480001 --暂时没有用到这条协议
AppEvent.NET_M48_C480002 = 480002 --推送/请求 季节变换相关
AppEvent.NET_M48_C480003 = 480003 --推送/请求 目前的世界玩家等级上限


AppEvent.NET_M49 = 49 -- 周卡协议
AppEvent.NET_M49_C490000 = 490000 --购买充值卡
AppEvent.NET_M49_C490001 = 490001 --领取每日奖励
AppEvent.NET_M49_C490002 = 490002 --推送功能开放

AppEvent.NET_M51 = 51 -- 军工所
AppEvent.NET_M51_C510000 = 510000 -- 升段
AppEvent.NET_M51_C510001 = 510001 -- 升阶
AppEvent.NET_M51_C510002 = 510002 -- 升级后开放功能时推送

AppEvent.NET_M53 = 53 -- 军功玩法
AppEvent.NET_M53_C530000 = 530000 -- 打开宝箱
AppEvent.NET_M53_C530001 = 530001 -- 手动重置
AppEvent.NET_M53_C530002 = 530002 -- 军功变动时推送


AppEvent.NET_M54 = 54 --红包相关
AppEvent.NET_M54_C540000 = 540000 --发红包
AppEvent.NET_M54_C540001 = 540001 --抢红包
AppEvent.NET_M55 = 55 -- 皇城战
AppEvent.NET_M55_C550000 = 550000 -- 点击皇城
AppEvent.NET_M55_C551000 = 551000 -- 同步推送
AppEvent.NET_M55_C550001 = 550001 -- 打开皇城界面获取信息
AppEvent.NET_M55_C551001 = 551001 -- 点击领取资源
AppEvent.NET_M55_C550002 = 550002 -- 获取历史战报
AppEvent.NET_M55_C550003 = 550003 -- 获取排名
AppEvent.NET_M55_C551003 = 551003 -- 领取排名奖励
AppEvent.NET_M55_C550004 = 550004 -- 获取单独显示用，活动状态和倒计时,特惠令下发
AppEvent.NET_M55_C550005 = 550005 -- 购买特惠讨伐令
AppEvent.NET_M55_C550007 = 550007 -- 战报已读
------------------------------------------

AppEvent.NET_M57 = 57 --富贵豪庄
AppEvent.NET_M57_C570000 = 570000 --开局或改命
AppEvent.NET_M57_C570001 = 570001 --确定点数
AppEvent.NET_M57_C570002 = 570002 --兑换物品


AppEvent.NET_M56 = 56 -- 国家系统
AppEvent.NET_M56_C560000 = 560000 -- 主界面上的雕像信息
AppEvent.NET_M56_C560001 = 560001 -- 皇族界面信息
AppEvent.NET_M56_C560002 = 560002 -- 监狱界面信息
AppEvent.NET_M56_C560003 = 560003 -- 获取同盟所有成员的简要信息
AppEvent.NET_M56_C560005 = 560005 -- 获取玩家单个技能信息数据
AppEvent.NET_M56_C561000 = 561000 -- 国家信息修改
AppEvent.NET_M56_C562001 = 562001 -- 任命官职
AppEvent.NET_M56_C563001 = 563001 -- 通缉玩家
AppEvent.NET_M56_C563002 = 563002 -- 撤销通缉
AppEvent.NET_M56_C563003 = 563003 -- 卸任官职
AppEvent.NET_M56_C563004 = 563004 -- 使用技能
AppEvent.NET_M56_C563005 = 563005 -- 使用流放

AppEvent.NET_M58 = 58 --中原玩法
AppEvent.NET_M54_C580000 = 580000 --领取任务奖励
AppEvent.NET_M54_C580001 = 580001 --领取章节奖励
AppEvent.NET_M54_C580002 = 580002 --章节信息推送

AppEvent.NET_M59 = 59 --同盟任务
AppEvent.NET_M59_C590000 = 590000 --完成任务时推送一次同盟任务信息

AppEvent.NET_M60 = 60 --财源广进
AppEvent.NET_M60_C600000 = 600000 --博彩
AppEvent.NET_M60_C600001 = 600001 --兑换

AppEvent.NET_M61 = 61 --聚宝盆
AppEvent.NET_M61_C610000 = 610000 --抽奖

------------------------------------------
--网络协议等待 loading界面Map  waitTime等待的秒数
NetWaitingMap = {}
--------------------------------M1------------------------------------
NetWaitingMap[AppEvent.NET_M1_C10001] = {waitTime = 0.4} --创建角色

--------------------------------M2------------------------------------
NetWaitingMap[AppEvent.NET_M2_C20001] = {waitTime = 0.4} --角色升官
NetWaitingMap[AppEvent.NET_M2_C20003] = {waitTime = 0.4} --购买恢复繁荣
NetWaitingMap[AppEvent.NET_M2_C20004] = {waitTime = 0.4} --统帅等级升级
NetWaitingMap[AppEvent.NET_M2_C20005] = {waitTime = 0.4} --授勋领取声望
NetWaitingMap[AppEvent.NET_M2_C20008] = {waitTime = 0.4} --创建角色
NetWaitingMap[AppEvent.NET_M2_C20011] = {waitTime = 0.4} --购买体力
NetWaitingMap[AppEvent.NET_M2_C20014] = {waitTime = 0.4} --设置玩家坐标
NetWaitingMap[AppEvent.NET_M2_C20015] = {waitTime = 0.4} --30天登录奖励
NetWaitingMap[AppEvent.NET_M2_C20016] = {waitTime = 0.4} --每日登录抽奖
NetWaitingMap[AppEvent.NET_M2_C20301] = {waitTime = 0.4} --新手礼包领取

--------------------------------M4------------------------------------
NetWaitingMap[AppEvent.NET_M4_C40001] = {waitTime = 0.4} --战损佣兵列表
NetWaitingMap[AppEvent.NET_M4_C40002] = {waitTime = 0.4} --修复佣兵

--------------------------------M5------------------------------------
NetWaitingMap[AppEvent.NET_M5_C50001] = {waitTime = 0.4} --请求战斗结束

--------------------------------M6------------------------------------
NetWaitingMap[AppEvent.NET_M6_C60003] = {waitTime = 0.4} --副本宝箱领取
NetWaitingMap[AppEvent.NET_M6_C60004] = {waitTime = 0.4} --vip购买冒险次数
NetWaitingMap[AppEvent.NET_M6_C60006] = {waitTime = 0.4} --更新副本列表信息
NetWaitingMap[AppEvent.NET_M6_C60101] = {waitTime = 0.4} --极限重置
NetWaitingMap[AppEvent.NET_M6_C60102] = {waitTime = 0.4} --开始极限扫荡
NetWaitingMap[AppEvent.NET_M6_C60103] = {waitTime = 0.4} --停止极限扫荡

--------------------------------M7------------------------------------
NetWaitingMap[AppEvent.NET_M7_C70001] = {waitTime = 0.4} --队伍设置

--------------------------------M8------------------------------------
--NetWaitingMap[AppEvent.NET_M8_C80000] = {waitTime = 0.4} --查看坐标周围的格子信息
NetWaitingMap[AppEvent.NET_M8_C80001] = {waitTime = 0.4} --进攻某个点
NetWaitingMap[AppEvent.NET_M8_C80002] = {waitTime = 0.4} --侦查某个格子
NetWaitingMap[AppEvent.NET_M8_C80003] = {waitTime = 0.4} --服务端新增任务列表推送
NetWaitingMap[AppEvent.NET_M8_C80104] = {waitTime = 0.4} --新增加一个任务
NetWaitingMap[AppEvent.NET_M8_C80004] = {waitTime = 0.4} --加速完成任务部队时间
NetWaitingMap[AppEvent.NET_M8_C80005] = {waitTime = 0.4} --搬家
NetWaitingMap[AppEvent.NET_M8_C80108] = {waitTime = 0.4} --新的被攻击任务
NetWaitingMap[AppEvent.NET_M8_C80008] = {waitTime = 0.4} --进行收藏
NetWaitingMap[AppEvent.NET_M8_C80009] = {waitTime = 0.4} --删除收藏
NetWaitingMap[AppEvent.NET_M8_C80011] = {waitTime = 0.4} --随机迁城令
NetWaitingMap[AppEvent.NET_M8_C80013] = {waitTime = 0.4} --前往驻守
NetWaitingMap[AppEvent.NET_M8_C80015] = {waitTime = 0.4} --世界搜索

--------------------------------M9------------------------------------
NetWaitingMap[AppEvent.NET_M9_C90001] = {waitTime = 0.4} --道具使用
--NetWaitingMap[AppEvent.NET_M9_C90003] = {waitTime = 0.4} --buff加成效果只推送新增、更新的(初始化)
NetWaitingMap[AppEvent.NET_M9_C90004] = {waitTime = 0.4} --道具使用发红包改名卡

--------------------------------M10------------------------------------
--NetWaitingMap[AppEvent.NET_M10_C100000] = {waitTime = 0.4} --新信息服务端主动推送，比如生产完毕了一个
NetWaitingMap[AppEvent.NET_M10_C100001] = {waitTime = 0.4} --建筑升级包括建造（0级升1级）
NetWaitingMap[AppEvent.NET_M10_C100003] = {waitTime = 0.4} --取消升级
NetWaitingMap[AppEvent.NET_M10_C100004] = {waitTime = 0.4} --加速升级
NetWaitingMap[AppEvent.NET_M10_C100005] = {waitTime = 0.4} --建筑拆除
NetWaitingMap[AppEvent.NET_M10_C100006] = {waitTime = 0.4} --建筑生产
NetWaitingMap[AppEvent.NET_M10_C100007] = {waitTime = 0.4} --建筑资源购买使用
NetWaitingMap[AppEvent.NET_M10_C100008] = {waitTime = 0.4} --商店购买道具
NetWaitingMap[AppEvent.NET_M10_C100009] = {waitTime = 0.4} --请求购买建筑位
NetWaitingMap[AppEvent.NET_M10_C100010] = {waitTime = 0.4} --VIP购买建筑位
NetWaitingMap[AppEvent.NET_M10_C100011] = {waitTime = 0.4} --购买自动升级建筑
NetWaitingMap[AppEvent.NET_M10_C100012] = {waitTime = 0.4} --自动升级建筑开关

--------------------------------M12------------------------------------
NetWaitingMap[AppEvent.NET_M12_C120001] = {waitTime = 0.4} --技能升级
NetWaitingMap[AppEvent.NET_M12_C120002] = {waitTime = 0.4} --技能重置 

--------------------------------M13------------------------------------
NetWaitingMap[AppEvent.NET_M13_C130001] = {waitTime = 0.4} --装备升级
NetWaitingMap[AppEvent.NET_M13_C130002] = {waitTime = 0.4} --穿戴装备
NetWaitingMap[AppEvent.NET_M13_C130003] = {waitTime = 0.4} --卸下装备
NetWaitingMap[AppEvent.NET_M13_C130005] = {waitTime = 0.4} --装备出售
NetWaitingMap[AppEvent.NET_M13_C130006] = {waitTime = 0.4} --装备曹调换位置
NetWaitingMap[AppEvent.NET_M13_C130007] = {waitTime = 0.4} --装备背包扩充
NetWaitingMap[AppEvent.NET_M13_C130102] = {waitTime = 0.4} --军械碎片合成军械
NetWaitingMap[AppEvent.NET_M13_C130103] = {waitTime = 0.4} --军械碎片分解
NetWaitingMap[AppEvent.NET_M13_C130104] = {waitTime = 0.4} --穿上军械
NetWaitingMap[AppEvent.NET_M13_C130105] = {waitTime = 0.4} --卸下军械
NetWaitingMap[AppEvent.NET_M13_C130106] = {waitTime = 0.4} --分解军械
NetWaitingMap[AppEvent.NET_M13_C130107] = {waitTime = 0.4} --强化军械
NetWaitingMap[AppEvent.NET_M13_C130108] = {waitTime = 0.4} --改造军械
NetWaitingMap[AppEvent.NET_M13_C130109] = {waitTime = 0.4} --进化军械

--------------------------------M13------------------------------------
NetWaitingMap[AppEvent.NET_M15_C150001] = {waitTime = 0.4} --装备抽奖
NetWaitingMap[AppEvent.NET_M15_C150002] = {waitTime = 0.4} --探宝
NetWaitingMap[AppEvent.NET_M15_C150003] = {waitTime = 0.4} --淘宝购买幸运币

--------------------------------M14------------------------------------
--NetWaitingMap[AppEvent.NET_M14_C140000] = {waitTime = 0.4} --聊天不需要
NetWaitingMap[AppEvent.NET_M14_C140002] = {waitTime = 0.4} --私聊
NetWaitingMap[AppEvent.NET_M14_C140003] = {waitTime = 0.4} --接收到私聊
NetWaitingMap[AppEvent.NET_M14_C140005] = {waitTime = 0.4} --添加到屏蔽列表
NetWaitingMap[AppEvent.NET_M14_C140006] = {waitTime = 0.4} --屏蔽列表请求
NetWaitingMap[AppEvent.NET_M14_C140007] = {waitTime = 0.4} --移除屏蔽请求
NetWaitingMap[AppEvent.NET_M14_C140008] = {waitTime = 0.4} --喇叭
NetWaitingMap[AppEvent.NET_M14_C140010] = {waitTime = 0.4} --举报玩家获取该玩家5分钟内10条聊天信息

--------------------------------M15------------------------------------
NetWaitingMap[AppEvent.NET_M15_C150001] = {waitTime = 0.4} --装备抽奖
NetWaitingMap[AppEvent.NET_M15_C150002] = {waitTime = 0.4} --探宝
NetWaitingMap[AppEvent.NET_M15_C150003] = {waitTime = 0.4} --探宝购买幸运币
NetWaitingMap[AppEvent.NET_M15_C150005] = {waitTime = 0.4} --战将开宝箱
NetWaitingMap[AppEvent.NET_M15_C150006] = {waitTime = 0.4} --战将探宝刷新奖励
NetWaitingMap[AppEvent.NET_M15_C150007] = {waitTime = 0.4} --战将探宝抽取奖励

--------------------------------M16------------------------------------
NetWaitingMap[AppEvent.NET_M16_C160000] = {waitTime = 0.4} --获取邮件列表
NetWaitingMap[AppEvent.NET_M16_C160001] = {waitTime = 0.4} --查看邮件
NetWaitingMap[AppEvent.NET_M16_C160003] = {waitTime = 0.4} --发送邮件
NetWaitingMap[AppEvent.NET_M16_C160004] = {waitTime = 0.4} --删除邮件
--NetWaitingMap[AppEvent.NET_M16_C160005] = {waitTime = 0.4} --请求请求战斗播放 请求成功，服务器是不返回的
NetWaitingMap[AppEvent.NET_M16_C160011] = {waitTime = 0.4} -- 一件领取邮件附件
NetWaitingMap[AppEvent.NET_M16_C160012] = {waitTime = 0.4} -- 将邮件状态设置为已阅

--------------------------------M17------------------------------------
NetWaitingMap[AppEvent.NET_M17_C170002] = {waitTime = 0.4} --搜索玩家信息
NetWaitingMap[AppEvent.NET_M17_C170001] = {waitTime = 0.4} --请求添加好友
NetWaitingMap[AppEvent.NET_M17_C170003] = {waitTime = 0.4} --请求删除好友
NetWaitingMap[AppEvent.NET_M17_C170004] = {waitTime = 0.4} --请求祝福
NetWaitingMap[AppEvent.NET_M17_C170006] = {waitTime = 0.4} --请求领取祝福


--------------------------------M19------------------------------------
--NetWaitingMap[AppEvent.NET_M19_C190000] = {waitTime = 0.4} --任务初始化信息更新
NetWaitingMap[AppEvent.NET_M19_C190001] = {waitTime = 0.4} --任务领取
NetWaitingMap[AppEvent.NET_M19_C190002] = {waitTime = 0.4} --日常任务操作
NetWaitingMap[AppEvent.NET_M19_C190003] = {waitTime = 0.4} --领取日常活跃

--------------------------------M20------------------------------------
NetWaitingMap[AppEvent.NET_M20_C200000] = {waitTime = 0.4} --竞技场挑战信息
NetWaitingMap[AppEvent.NET_M20_C200001] = {waitTime = 0.4} --请求战斗
NetWaitingMap[AppEvent.NET_M20_C200003] = {waitTime = 0.4} --增加挑战次数
NetWaitingMap[AppEvent.NET_M20_C200004] = {waitTime = 0.4} --竞技场商店购买
NetWaitingMap[AppEvent.NET_M20_C200005] = {waitTime = 0.4} --领取竞技场上期排名奖励
NetWaitingMap[AppEvent.NET_M20_C200006] = {waitTime = 0.4} --消除竞技场挑战时间
NetWaitingMap[AppEvent.NET_M20_C200100] = {waitTime = 0.4} --竞技场战报列表
NetWaitingMap[AppEvent.NET_M20_C200101] = {waitTime = 0.4} --查看战报详细信息,服务器不需要推送200100(优化)
NetWaitingMap[AppEvent.NET_M20_C200102] = {waitTime = 0.4} --删除个人战报,服务器不需要推送200100(优化)
--NetWaitingMap[AppEvent.NET_M20_C200103] = {waitTime = 0.4} --请求战斗播放

--------------------------------M22------------------------------------
NetWaitingMap[AppEvent.NET_M22_C220002] = {waitTime = 0.4} --军团商店物品兑换
NetWaitingMap[AppEvent.NET_M22_C220100] = {waitTime = 0.4} --军团列表
NetWaitingMap[AppEvent.NET_M22_C220101] = {waitTime = 0.4} --查询军团详细信息
NetWaitingMap[AppEvent.NET_M22_C220102] = {waitTime = 0.4} --军团申请取消申请
NetWaitingMap[AppEvent.NET_M22_C220103] = {waitTime = 0.4} --创建军团
NetWaitingMap[AppEvent.NET_M22_C220104] = {waitTime = 0.4} --军团搜索
NetWaitingMap[AppEvent.NET_M22_C220105] = {waitTime = 0.4} --军团搜索
NetWaitingMap[AppEvent.NET_M22_C220202] = {waitTime = 0.4} --查看审批列表
NetWaitingMap[AppEvent.NET_M22_C220204] = {waitTime = 0.4} --清空申请列
NetWaitingMap[AppEvent.NET_M22_C220205] = {waitTime = 0.4} --军团申请数量
NetWaitingMap[AppEvent.NET_M22_C220211] = {waitTime = 0.4} --军团公告
NetWaitingMap[AppEvent.NET_M22_C220220] = {waitTime = 0.4} --职位编辑
NetWaitingMap[AppEvent.NET_M22_C220012] = {waitTime = 0.4} --福利院信息
NetWaitingMap[AppEvent.NET_M22_C220013] = {waitTime = 0.4} --福利院升级,领取福利
NetWaitingMap[AppEvent.NET_M22_C220015] = {waitTime = 0.4} --资源福利领取
NetWaitingMap[AppEvent.NET_M22_C220016] = {waitTime = 0.4} --战事福利列表
NetWaitingMap[AppEvent.NET_M22_C220017] = {waitTime = 0.4} --分配福利
NetWaitingMap[AppEvent.NET_M22_C220007] = {waitTime = 0.4} --军团大厅升级
NetWaitingMap[AppEvent.NET_M22_C220008] = {waitTime = 0.4} --军团大厅捐献
NetWaitingMap[AppEvent.NET_M22_C220009] = {waitTime = 0.4} --科技捐献
NetWaitingMap[AppEvent.NET_M22_C220010] = {waitTime = 0.4} --科技大厅升级
NetWaitingMap[AppEvent.NET_M22_C220000] = {waitTime = 0.4} --军团建筑等级信息
NetWaitingMap[AppEvent.NET_M22_C220300] = {waitTime = 0.4} --情报站信息
NetWaitingMap[AppEvent.NET_M22_C220400] = {waitTime = 0.4} --军团招募

--------------------------------M23------------------------------------
NetWaitingMap[AppEvent.NET_M23_C230000] = {waitTime = 0.4} --获取活动列表
NetWaitingMap[AppEvent.NET_M23_C230001] = {waitTime = 0.4} --领取、购买
NetWaitingMap[AppEvent.NET_M23_C230002] = {waitTime = 0.4} --获取限时活动列表
NetWaitingMap[AppEvent.NET_M23_C230003] = {waitTime = 0.4} --获取拉霸活动信息
NetWaitingMap[AppEvent.NET_M23_C230006] = {waitTime = 0.4} --请求领取有福同享宝箱奖励
NetWaitingMap[AppEvent.NET_M23_C230057] = {waitTime = 0.4} --请求幸运轮盘
NetWaitingMap[AppEvent.NET_M23_C230059] = {waitTime = 0.4} --请求招财转运

--------------------------------M25------------------------------------
--NetWaitingMap[AppEvent.NET_M25_C250000] = {waitTime = 0.4} --分享功能

--------------------------------M26------------------------------------
NetWaitingMap[AppEvent.NET_M26_C260000] = {waitTime = 0.4} --军师信息用于初始化请求
NetWaitingMap[AppEvent.NET_M26_C260001] = {waitTime = 0.4} --军师进阶
NetWaitingMap[AppEvent.NET_M26_C260002] = {waitTime = 0.4} --军师升级
NetWaitingMap[AppEvent.NET_M26_C260003] = {waitTime = 0.4} --军师分解
NetWaitingMap[AppEvent.NET_M26_C260005] = {waitTime = 0.4} --军师抽奖
NetWaitingMap[AppEvent.NET_M26_C260006] = {waitTime = 0.4} --军师一键进阶
NetWaitingMap[AppEvent.NET_M26_C260007] = {waitTime = 0.4} --设置内政
NetWaitingMap[AppEvent.NET_M26_C260008] = {waitTime = 0.4} --卸任内政

--------------------------------M27------------------------------------
NetWaitingMap[AppEvent.NET_M27_C270001] = {waitTime = 0.4} --关卡挑战
NetWaitingMap[AppEvent.NET_M27_C270003] = {waitTime = 0.4} --关卡宝箱领取

--------------------------------M28------------------------------------
NetWaitingMap[AppEvent.NET_M28_C280001] = {waitTime = 0.4} --建筑请求升级 包括建造（0级升1级）
NetWaitingMap[AppEvent.NET_M28_C280003] = {waitTime = 0.4}--取消建筑升级
NetWaitingMap[AppEvent.NET_M28_C280004] = {waitTime = 0.4} --建筑加速升级
NetWaitingMap[AppEvent.NET_M28_C280005] = {waitTime = 0.4} --野外建筑拆除
NetWaitingMap[AppEvent.NET_M28_C280006] = {waitTime = 0.4}--建筑生产 包括 兵营，校场，工匠坊，科技
-- NetWaitingMap[AppEvent.NET_M28_C280007] = {waitTime = 0.4} --请求生产完成
NetWaitingMap[AppEvent.NET_M28_C280008] = {waitTime = 0.4} --取消生产 
NetWaitingMap[AppEvent.NET_M28_C280009] = {waitTime = 0.4} --加速生产
NetWaitingMap[AppEvent.NET_M28_C280011] = {waitTime = 0.4} --VIP购买建筑位
NetWaitingMap[AppEvent.NET_M28_C280012] = {waitTime = 0.4} --购买自动升级建筑
NetWaitingMap[AppEvent.NET_M28_C280013] = {waitTime = 0.4} --自动升级建筑开关

--29
NetWaitingMap[AppEvent.NET_M29_C290001] = {waitTime = 0.4} --更换武将
NetWaitingMap[AppEvent.NET_M29_C290003] = {waitTime = 0.4} --升级武将

--------------------------------M42------------------------------------
NetWaitingMap[AppEvent.NET_M42_C420000] = {waitTime = 0.4} --请求点评列表

--------------------------------M46------------------------------------
NetWaitingMap[AppEvent.NET_M46_C460001] = {waitTime = 0.4} --请求实名制信息

--------------------------------M47郡城相关------------------------------------
NetWaitingMap[AppEvent.NET_M47_C470002] = {waitTime = 0.4} --请求战报信息
NetWaitingMap[AppEvent.NET_M47_C470005] = {waitTime = 0.4} --请求战报信息
------------------------------------------
----------------proxy event----------
AppEvent.PROXY_GET_ROLE_INFO = "proxy_get_role_info"
AppEvent.PROXY_UPDATE_ROLE_INFO = "proxy_update_role_info" --人物信息修改
AppEvent.PROXT_UPDATE_FIGHT_WEIGHT = "proxt_update_fight_weight" --更新人物的最大载重信息
AppEvent.PROXY_UPDATE_ROLE_NAME = "proxy_update_role_name" --人物名字修改
AppEvent.PROXY_UPDATE_ROLE_HEAD = "proxy_update_role_head" --人物头像修改
AppEvent.PROXY_UPDATE_ROLE_CUSTOM_HEAD = "proxy_update_role_custom_head" --人物自定义头像上传成功
AppEvent.PROXY_ITEMINFO_UPDATE = "proxy_iteminfo_update"  --物品信息修改
AppEvent.PROXY_ITEM_COIN_COUNT_UPDATE = "proxy_item_coin_count_update" -- 硬币数量改变回调刷新红点
AppEvent.PROXY_BAG_UPDATE = "proxy_bag_update"
AppEvent.PROXY_SHOW_BAG_NUM = "proxy_show_bag_num"
AppEvent.PROXY_SKILL_INFO_UPDATE = "proxy_skill_info_update"	--技能信息更新
AppEvent.PROXY_UPDATE_ROLE_POWER = "proxy_update_role_power"    --人物信息更新
AppEvent.PROXY_UPDATE_RECHARGE_INFO = "proxy_update_recharge_info" --推送已双倍充值的额度
AppEvent.PROXY_UPDATE_ICON_EFFECT = "proxy_update_icon_effect"  --技能信息更新导致特效图标提示更新

AppEvent.PROXY_UPDATE_BUFF_NUM = "proxy_update_buff_num"    --增益道具数量的变化

AppEvent.PROXY_BUYEVENT_UPDATE = "proxy_buyevent_update"

AppEvent.PROXY_SOLIDER_INFO = "proxy_solider_info" --佣兵列表的获取
AppEvent.PROXY_SOLIDER_MOFIDY = "proxy_solider_mofidy"  --佣兵列表的变化推送
AppEvent.PROXY_SETTEAM_UPDATE = "proxy_setteam_update"  --设置阵型回调
AppEvent.PROXY_TEAMPOS_UPDATE = "proxy_teampos_update"  --选择套用阵型回调
AppEvent.PROXY_DEFTEAM_UPDATE = "proxy_defteam_update"  --防守阵型刷新


AppEvent.PROXY_GET_CHAT_INFO = "proxy_get_chat_info"    --获取聊天信息
AppEvent.PROXY_GET_CHATPERSON_INFO = "proxy_get_chatperson_info" --获取聊天个人信息
AppEvent.PROXY_GET_PERSON_NOT_MAP = "proxy_get_person_not_map" -- 非地图查看个人信息
AppEvent.PROXY_GET_CHATPERSON_INFO_BY_ONESELF = "proxy_get_chatperson_by_oneself"--接收私聊回复
AppEvent.PROXY_GET_CHAT_INFO_BARRAGE = "proxy_get_chat_info_barrge"              --弹幕信息

AppEvent.PROXY_PRIVATECHAT_REDPOINT = "proxy_privatechat_redpoint" --私聊总红点
AppEvent.PROXY_PRIVATECHAT = "proxy_privatechat" --发送私聊请求
AppEvent.PROXY_PRIVATECHAT_INFO = "proxy_privatechat_info" --发送私聊信息请求
AppEvent.PROXY_SHIELDCHAT = "proxy_shieldchat"--添加到屏蔽列表
AppEvent.PROXY_SHIELDCHAT_INFO = "proxy_shieldchat_info"--屏蔽列表请求
AppEvent.PROXY_CHAT_RESP = "proxy_chat_resp" --私聊对方的回复
AppEvent.ENTER_PRIVATE = "proxy_private_enter" --进入私聊界面,全局事件
AppEvent.CLEAR_TOOLBAR_CMD = "clear_cmd"

---------------系统SystemProxy
AppEvent.PROXY_SYSTEM_LOGINGATE = "proxy_system_logingate" --网关登录
AppEvent.PROXY_SYSTEM_OTHERLOGIN = "proxy_system_otherlogin" --被动退出
AppEvent.PROXY_SYSTEM_HEARTBEAT = "proxy_system_heartbeat" --心跳
AppEvent.PROXY_SYSTEM_LOGIN = "proxy_system_login" --登录
AppEvent.PROXY_SYSTEM_CHARGESUCESS = "proxy_system_chargesucess" --充值成功

----building
AppEvent.PROXY_BUILDING_UPDATE = "proxy_building_update"  --建筑信息更新 更新一个建筑的消息 点对点
AppEvent.PROXY_BUILDING_MULT_UPDATE = "proxy_building_mult_update" --多个建筑更新，多个建筑逻辑点的地方监听
AppEvent.PROXY_BUILDING_ALL_UPDATE = "proxy_building_all_update" --所有的建筑同步更新
AppEvent.BUILDING_UP_REQ = "building_up_req" --建筑升级请求
AppEvent.BUILDING_CANCEL_REQ = "building_cancel_req" --建筑取消升级 或者生产
AppEvent.BUILDING_ISCANBUYBUILDING = "building_isCanbuyBuilding" --通知toolbar可否购买建筑位
AppEvent.BUILDING_SUCCESS_UPDATE = "building_success_update" --购买成功后的刷新
AppEvent.BUILDING_AUTO_UPGRATE = "building_auto_upgrate" --自动升级建筑
AppEvent.TIME_AUTO_UPGRATE = "time_auto_upgrate" --自动升级建筑倒计时
AppEvent.PROXY_BUILDING_BUY_FIELD = "proxy_building_buy_field" --购买建筑位弹窗
AppEvent.BUILDING_LEVEL_UP = "building_level_up" -- 升级播放特效
AppEvent.PROXY_BUILDING_PROD_UPDATE = "proxy_building_prod_update" --生产通知切换标签显示
AppEvent.BUILDING_CANCEL_UPDATE = "building_cancel_update" --建筑取消升级 刷新界面


--国策兵法
AppEvent.PROXY_TALENT_UPDATE = "proxy_talent_update"--国策刷新界面
AppEvent.PROXY_TALENT_UPDATE_SINGLE = "proxy_talent_update_single"--国策刷新单个
AppEvent.PROXY_TALENT_USED = "proxy_talent_used"--国策激活成功

AppEvent.PROXY_REWARD_RESP = "proxy_reward_resp"  --奖励

AppEvent.PROXY_BUILDING_MOVE = "proxy_building_move"


------------battle------------------------
AppEvent.PROXY_BATTLE_END = "proxy_battle_end" --战斗结束
AppEvent.POWER_VALUE_UPDATE = "power_value_update" --属性变化

----friend---
AppEvent.PROXY_FRIEND_INFO_UPDATE = "proxy_friend_info_update" --好友信息更新
AppEvent.PROXY_FRIEND_SEARCH = "proxy_friend_search"  --好友搜索
AppEvent.PROXY_FRIEND_BLESS_UPDATE = "proxy_friend_bless_update" --好友祝福信息更新

----task---
AppEvent.PROXY_TASK_INFO_UPDATE = "proxy_task_info_update" --任务信息更新
AppEvent.PROXY_TASK_GUIDE = "proxy_task_guide" --主线任务引导关闭panel

----聊天
AppEvent.NET_CHATNOTICE = "noseechat"
AppEvent.CHAT_NOSEE_UPDATE = "chat_nosee_update" --没有读的消息通知toolbar显示

--新手引导通知toolbar
AppEvent.GUIDE_NOTICE = "guide_notice"
AppEvent.ACTIVITE_SHOW_BTN = "activite_show_btn"
AppEvent.TOOLBAR_SHOW_BTN = "toolbar_show_btn"

----rank---
AppEvent.PROXY_RANK_INFO_UPDATE = "proxy_rank_info_update" --排行榜信息更新
AppEvent.PROXY_RESRANK_INFO_UPDATE = "proxy_resrank_info_update" --征矿榜信息更新
AppEvent.PROXY_OPENSERVERGIFT_INFO_UPDATE = "proxy_openServerGift_info_update" --开服礼包面板更新
AppEvent.PROXY_EVERYDAYLOGGIFT_INFO_UPDATE = "proxy_everyDayLogGift_info_update" --每日礼包面板更新
AppEvent.PROXY_LEGION_CONTRIBUTE_UPDATE = "proxy_legion_contribute_update" --军团捐献更新（科技和大厅的捐献）

---------legion军团信息----------------
AppEvent.PROXY_LEGION_INFO_UPDATE = "proxy_legion_info_update" --自身的军团信息更新
AppEvent.PROXY_LEGION_MEMBER_UPDATE = "proxy_legion_member_update" --自身的军团成员更新
AppEvent.PROXY_LEGION_SHOP_INFO_UPDATE = "proxy_legion_shop_info_update" --军团商店更新
AppEvent.PROXY_LEGION_SCITECH_UPDATE = "proxy_legion_scitech_update" --军团科技更新
AppEvent.PROXY_LEGION_EXIT_INFO = "proxy_legion_exit_info"           --退出军团
AppEvent.PROXY_LEGION_BUILDING_UPDATE = "proxy_legion_building_update"    --军团里面的建筑更新
AppEvent.PROXY_LEGION_MAINSCENE_BUILDING_UPDATE = "proxy_legion_mainscene_building_update"    --主城军团建筑信息更新
AppEvent.PROXY_LEGION_ADVICE_INFO_UPDATE = "proxy_legion_advice_info_update"    --情报站更新
AppEvent.PROXY_LEGION_APPROVE_POINT_UPDATE = "proxy_legion_approve_point_update"    --审批小红点更新
AppEvent.PROXY_LEGION_ALLOT_UPDATE = "proxy_legion_allot_update"    --战事福利列表
AppEvent.PROXY_LEGION_ALLOT_MEMBER_UPDATE = "proxy_legion_allot_member_update" --分配界面刷新
AppEvent.PROXY_LEGION_UPDATE_RECOMMEND = "proxy_legion_update_recommend" -- 推荐列表刷新
AppEvent.PROXY_LEGION_UPDATE_WELFARE_TIP = "proxy_legion_update_welfare_tip"-- 更新每日福利感叹号220012/220013
AppEvent.PROXY_LEGION_UPDATE_MAINSCENE_TIP = "proxy_legion_update_mainscene_tip"-- 加入/退出/创建军团回调
AppEvent.PROXY_LEGION_CLOSE_UPDATE_MAINSCENE_TIP = "proxy_legion_close_update_mainscene_tip"-- 关闭军团界面刷新感叹号
AppEvent.PROXY_LEGION_INIT_APPLY_INFO = "proxy_legion_init_apply_info" --初始化审批列表[220202]
AppEvent.PROXY_LEGION_INIT_APPLY_INFO_CHANGE = "proxy_legion_init_apply_info_change" -- 修改审批列表返回[220203]
AppEvent.PROXY_LEGION_INFO_INIT = "proxy_legion_info_init" --自身的军团信息更新


AppEvent.PROXY_SELF_WRITEMAIL = "proxy_self_writemail"  --在邮箱模块中个人信息写邮件

AppEvent.PROXY_UPDATE_CUR_POS = "proxy_update_cur_pos" --如果map模块是打开的，跳转到指定位置

---------抽奖信息变化----------
AppEvent.PROXY_LOTTERY_INFOS_CHANGE = "proxy_lottery_infos_change"
AppEvent.PROXY_BUY_LOTTERY = "proxy_buy_lottery"

---------背包----------
AppEvent.PROXY_BAG_SURFACEGOODSUSE = "proxy_bag_surfacegoodsuse"  --背包中外观道具的使用通知
AppEvent.PROXY_BAG_CHANGEPOINT = "proxy_bag_changepoint"  --随机迁移城市
AppEvent.PROXY_BAG_LEGIONCONTRIBUTE = "proxy_bag_legioncontribute"  --增加军团贡献度
AppEvent.PROXY_BAG_ESPECIALUSE = "proxy_bag_especialuse"  --道具使用发红包、改名卡
AppEvent.PROXY_BAG_OPENMAP = "proxy_bag_openmap"  --道具使用发红包、改名卡

--------邮件-------------
AppEvent.PROXY_MAIL_INFO = "proxy_mail_mailinfo"  --邮件总信息
AppEvent.PROXY_MAIL_CHECKINFO = "proxy_mail_checkinfo"  --查看邮件
AppEvent.PROXY_MAIL_NEWMAIL = "proxy_mail_newmail"  --新邮件通知
AppEvent.PROXY_MAIL_SENDMAIL = "proxy_mail_sendmail"  --发送邮件
AppEvent.PROXY_MAIL_REMOVEMAIL = "proxy_mail_removemail"  --删除邮件
AppEvent.PROXY_MAIL_RUNBATTLE = "proxy_mail_runbattle"  --请求战斗播放
AppEvent.PROXY_MAIL_PICKUP_MAIL = "proxy_mail_pickup_mail"  --提取附件
AppEvent.PROXY_MAIL_UPDATE_COLLECT = "proxy_mail_update_collect"  -- 刷新收藏列表
AppEvent.PROXY_MAIL_REMOVE_COLLECT = "proxy_mail_remove_collect"  -- 取消收藏刷新
AppEvent.PROXY_MAIL_READ_ALL = "proxy_mail_read_all"  -- 一键已阅
AppEvent.PROXY_MAIL_GET_ALL = "proxy_mail_get_all"    -- 一键领取

--------活动-----------
AppEvent.PROXY_ACTIVITY_INFO = "proxy_activity_info"  --活动总信息
AppEvent.PROXY_LABA_INFO = "proxy_laba_info"  --拉霸总信息

AppEvent.PROXY_PKG_INFO = "proxy_pkg_info"  --获取礼包列表
AppEvent.PROXY_GET_REWARD = "proxy_get_reward"  --领取奖励||||||| .r12553
AppEvent.PROXY_LEGION_GIFT = "proxy_legion_gift" --军团好礼
AppEvent.PROXY_UPDATE_ONE = "proxy_update_one" --刷新单个活动
AppEvent.PROXY_LEGION_HELP_POINT_UPDATE = "proxy_legion_help_point_update"

AppEvent.PROXY_JUMP_POS = "proxy_jump_pos"
AppEvent.PROXY_RESET_TTDATA = "proxy_reset_ttdata"  --4点重置转盘信息

AppEvent.PROXY_ACTIVITY_CANBUY_WEEKCARD = "proxy_activity_canbuy_weekcard"  --可以购买周卡通知
AppEvent.PROXY_ACTIVITY_WEEKCARD_UPDATE = "proxy_activity_weekcard_update" --周卡数据刷新


AppEvent.PROXY_UPDATE_ZPVIEW = "proxy_update_zpview"--更新转盘面板信息


AppEvent.PROXY_REMOVE_ACT = "proxy_remove_act"  --删除活动
AppEvent.PROXY_NEW_ACT = "proxy_new_act"  --新增限时活动

AppEvent.PROXY_UPDATE_LIMIT = "proxy_update_limit"  --更新限时活动按钮
AppEvent.PROXY_UPDATE_COUNT = "proxy_update_count"  --更新限时活动按钮
AppEvent.PROXY_UPDATE_ACTVIEW_SMASHEGG = "proxy_update_actview_samshegg"  --砸鸡蛋
AppEvent.PROXY_UPDATE_ACTVIEW_DAYRECHARGE = "proxy_update_actview_dayrecharge" --更新连续充值
AppEvent.PROXY_UPDATE_ACTVIEW_TIMEOVER = "proxy_update_actview_timeover"  --0点过后，活动刷新
AppEvent.PROXY_UPDATE_ACTVIEW = "proxy_update_actview"  --更新红包派送信息
AppEvent.PROXY_SHOW_REDPKGVIEW = "proxy_show_redpkgview"  --更新红包派送信息
AppEvent.PROXY_UPDATE_VIPBOXVIEW = "proxy_update_vipboxview"  --更新vip特权宝箱
AppEvent.PROXY_UPDATE_VIPREBATEVIEW = "proxy_update_viprebateview"  --更新vip总动员视图
AppEvent.PROXY_UPDATE_VIPSUPPLYVIEW = "proxy_udata_vipsupplyview"--更新领取按钮
AppEvent.PROXY_UPDATE_VIPSUPPLY_RECEIVE = "proxy_udata_vipsupply_receive" --vip特供领取
AppEvent.PROXY_UPDATE_VIPSUPPLY_TIMECOMPLEC = "proxy_udata_vipsupply_timecomplec" --倒计时回调
AppEvent.PROXY_UPDATE_VIPSUPPLY_POINT = "proxy_udata_vipsupply_point" --通知更新红点


AppEvent.PROXY_UPDATE_ACTIVITY_RANK = "proxy_update_activity_rank"  --更新活动排行版

AppEvent.PROXY_SHOW_PERSON_RED_VIEW = "proxy_show_person_red_view" --更新抢私人红包界面

AppEvent.UPDATE_COUNT = "updatecount"  --更新限时活动可领取数量
AppEvent.SET_PGK_NUM = "set_pkg_num"



AppEvent.UPDATE_RAD = "updaterad"
AppEvent.UP_RAD_COUNT = "up_rad_count"

AppEvent.PROXY_GET_CONINFO = "proxy_get_coninfo"--军师府信息
AppEvent.PROXY_CONSIGRECRUIT = "proxy_recruit"--军师招募
AppEvent.PROXY_ADVANCED = "proxy_advanced"--军师进阶
AppEvent.PROXY_RESOLVE = "proxy_resolve"--军师分解
AppEvent.PROXY_UPGRADE = "proxy_upgrade"--军师升级
AppEvent.PROXY_ONEKEY = "proxy_onekey"--一键进阶
AppEvent.PROXY_CONSUGOREQ = "proxy_consugoreq" --军师上阵
AppEvent.PROXY_CONSIGRE_FOREIGN = "proxy_consigre_foreign" --军师上任
AppEvent.PROXY_CONSIGRE_FOREIGN_RELIEV = "proxy_consigre_foreign_reliev" --军师卸任
AppEvent.PROXY_UPDATE_BUY_VIEW = "proxy_update_buy_view" --价格变化刷新招募界面
AppEvent.PROXY_OPEN_BUILD_CONSIGRE = "proxy_open_build_consigre" -- 军师模块解锁

AppEvent.PROXY_ACTIVITY_SHOP_SELLER_INFO_REQ = "proxy_activity_shop_seller_info_req"  --洛阳闹市商人信息
AppEvent.PROXY_ACTIVITY_SHOP_UPDATE_SELLER_DISCOUNT = "proxy_activity_shop_update_seller_discount"  --洛阳闹市打折商人信息
AppEvent.PROXY_ACTIVITY_SHOP_UPDATE_SELLER_BLACK_MARKET = "proxy_activity_shop_update_seller_black_market"  --洛阳闹市黑市商人信息
AppEvent.PROXY_ACTIVITY_SHOP_UPDATE_SELLER_SPECIAL = "proxy_activity_shop_update_seller_special"  --洛阳闹市特卖商人信息
AppEvent.PROXY_ACTIVITY_SHOP_BUY_RESULT = "proxy_activity_shop_buy_result"  --洛阳闹市商品购买结果
AppEvent.PROXY_ACTIVITY_SHOP_COUPONS_UPDATE = "proxy_activity_shop_coupons_update"  --优惠券更新


---------副本-----------
AppEvent.PROXY_DUNGEON_LIST_INFO_UPDATE = "proxy_dungeon_list_info_update" --副本列表信息更新
AppEvent.PROXY_DUNGEON_GET_INFOS = "proxy_dungeon_get_infos"  --副本关卡详情
AppEvent.PROXY_DUNGEON_FIGHT_OVER = "proxy_dungeon_fight_over"  --战斗结束
AppEvent.PROXY_DUNGEON_GET_BOXREWARD ="proxy_dungeon_get_boxreward"  --宝箱
AppEvent.PROXY_DUNGEON_BUY_TIMES = "proxy_dungeon_buy_times"   ---购买次数
AppEvent.PROXY_DUNGEON_FIRST_PASS = "proxy_dungeon_first_pass"  --第一次通过
AppEvent.PROXY_DUNGEON_GET_NEWGIFT = "proxy_dungeon_get_newGift"  --新手结束得到的奖品
AppEvent.PROXY_DUNGEON_RESET_DATA = "proxy_dungeon_reset_data"
AppEvent.PROXY_LIMIT_INFO_UPDATE = "proxy_limit_info_update"  --西域远征更新
AppEvent.PROXY_TILI_UPDATE = "proxy_tili_update" --挂机副本刷新体力
AppEvent.PROXY_COLSE_EVENT = "proxy_colose_event" --碎片跳转的时候先关闭副本

---------部队佣兵-----------
AppEvent.TASK_TEAM_INFO_UPDATE = "task_team_info_update" --任务部队列表信息更新
AppEvent.BAD_SOLDIER_LIST_UPDATE = "bad_soldier_list_update" --伤病列表更新

---------增益信息------------
AppEvent.GAIN_INFO_UPDATE = "gain_info_update"    --增益信息更新
AppEvent.ITEM_BUFF_UPDATE = "item_buff_update"    --buff道具信息更新
AppEvent.BUFF_SHOW_UPDATE = "buff_show_update"	  --荣誉更新

---------军团副本------------
AppEvent.PROXY_DUNGEONX_BOX_UPDATE = "proxy_dungeonx_box_update"    --关卡宝箱更新
AppEvent.PROXY_DUNGEONX_EVENT_UPDATE = "proxy_dungeonx_event_update"    --据点信息更新
AppEvent.PROXY_DUNGEONX_EVENT_ANSWER = "proxy_dungeonx_event_answer"    --挑战询问返回
AppEvent.PROXY_DUNGEONX_CHAPTER_UPDATE = "proxy_dungeonx_chapter_update"    --章节信息更新
AppEvent.PROXY_DUNGEONX_TIP_UPDATE     = "proxy_dungeonx_tip_update"   -- 关卡宝箱感叹号更新/剩余挑战次数更新

---------小红点变化--------
AppEvent.PROXY_REDPOINT_UPDATE = "proxy_redpoint_update"    --小红点改变通知

---------竞技场------------
AppEvent.PROXY_ARENA_ALLINFOS = "proxy_arena_allinfos"
AppEvent.PROXY_ARENA_GETREWARD = "proxy_arena_getreward"

----------部队-------------
AppEvent.PROXY_TEAM_BEATTACTION = "proxy_team_beattaction"               ---部队被袭击

----------队伍面板上面的信息刷新通知-------------
AppEvent.PROXY_UPDATE_TEAM_OTHER_INFO = "proxy_update_team_other_info"-- 武将变化

AppEvent.PROXY_UPDATE_All_EQUIPS = "proxy_update_all_equips"
AppEvent.PROXY_UPDATE_ALL_HERO = "proxy_update_all_hero"

AppEvent.PROXY_UPDATE_IMG_VIEW = "proxy_update_img_view" --刷新武将图鉴界面
AppEvent.PROXY_UPDATE_EQUIP_VIEW = "proxy_update_equip_view" --刷新武魂图鉴界面
AppEvent.PROXY_UPDATE_EQUIP_MAINVIEW = "proxy_update_equip_mainview" --刷新武魂图鉴界面
AppEvent.PROXY_UPDATE_TOUCH_STATE = "proxy_update_touch_state"

----------竞技场-------------
AppEvent.PROXY_ARENA_ALLMAILS_UPDATE = "proxy_arena_allmails_update"   --竞技场全服邮件刷新
AppEvent.PROXY_ARENA_PERMAILS_UPDATE = "proxy_arena_permails_update"   --竞技场个人邮件刷新
AppEvent.PROXY_ARENA_READMAIL = "proxy_arena_readmail"   --竞技场战报邮件的阅读
AppEvent.PROXY_ARENA_REFRESHTIME = "proxy_arena_freshtime"  --竞技场0点 4点刷新请求

AppEvent.PROXY_ACTIVITY_PARTSGOD_GETREWARD = "proxy_activity_partsgod_getreward"  --军械神将锻造获得物品
AppEvent.PROXY_ACTIVITY_PARTSGOD_SETFREE = "proxy_activity_partsgod_setfree"  --军械神将重置免费
AppEvent.PROXY_ACTIVITY_PARTSGOD_UPDATERANKDATA = "proxy_activity_partsgod_updaterankdata"  --更新神将排行榜信息



AppEvent.PROXY_BATTLEACTIVITY_UPDATE_LISTVIEW = "proxy_battleactivity_update_listview"  --刷新战斗类活动列表

AppEvent.PROXY_WORLDBOSS_UPDATE_AUTOBATTLE = "proxy_worldboss_update_autobattle"  --世界boss自动战斗通知
AppEvent.PROXY_WORLDBOSS_UPDATE_INSPIREVIEW = "proxy_worldboss_update_inspireview"  --世界boss鼓舞通知
AppEvent.PROXY_WORLDBOSS_UPDATE_BOSSINFO = "proxy_worldboss_update_bossinfo"  --世界boss信息变化通知
AppEvent.PROXY_WORLDBOSS_SHOW_VIEW = "proxy_worldboss_show_view"  --世界boss信息变化通知
AppEvent.PROXY_WORLDBOSS_UPDATE_RANKVIEW = "proxy_worldboss_update_rankview"  --世界boss排行榜更新
AppEvent.PROXY_WORLDBOSS_SHOW_MYATTACK = "proxy_worldboss_show_myattack"  --世界boss玩家攻击通知
AppEvent.PROXY_WORLDBOSS_SET_TEAM = "proxy_worldboss_set_team"  --世界boss设置阵型通知
AppEvent.PROXY_WORLDBOSS_BOSS_DIED = "proxy_worldboss_boss_died"  --世界boss死亡通知
AppEvent.PROXY_WORLDBOSS_CANCEL_COLDDOWN = "proxy_worldboss_cancel_colddown"  --世界boss取消冷却时间通知
AppEvent.PROXY_WORLDBOSS_ACTIVITY_END = "proxy_worldboss_activity_end"  --世界boss撤军通知
AppEvent.PROXY_BATTLE_ACTIVITY_UPDATE = "proxy_battle_activity_update"  --全服活动通知

AppEvent.PROXY_FIGHTREPORTS_CHANGE = "proxy_fightreports_change"    --群雄涿鹿的战场信息刷新
AppEvent.PROXY_WARLORDSSIGN_OPEN = "proxy_warlordssign_open"        --群雄涿鹿的状态请求
AppEvent.PROXY_GETLEGIONLISTS = "proxy_getlegionlists"              --群雄涿鹿的报名的军团列表
AppEvent.PROXY_GETMYLEGIONLISTS = "proxy_getmylegionlists"          --群雄涿鹿玩家所在的军团的成员报名信息
AppEvent.PROXY_SETSIGNSUCCEED = "proxy_getsignsucceed"              --群雄涿鹿设置报名或者取消报名
AppEvent.PROXY_GETFIGHTINFOS = "proxy_getfightinfos"                --群雄涿鹿获取阵型数据
AppEvent.PROXY_WINSRANKMEMBERS = "proxy_winsrankmembers"            --群雄涿鹿连胜排行榜数据
AppEvent.PROXY_WINSRANKLEGIONS = "proxy_winsranklegions"			--群雄涿鹿军团排行榜榜数据
AppEvent.PROXY_OPENWARLORDS = "proxy_openwarlords"                  --打开群雄涿鹿模块
AppEvent.PROXY_WARLORDSFAILED = "proxy_warlordsfailed"             --活动开启失败
AppEvent.PROXY_WARLORDSWORLD = "proxy_warlordsworld"               --主城的百团大战入口图标
AppEvent.PROXY_WARLORDSCOMBAT = "proxy_warlordscombat"              --军团混战进度信息
--------------------------乡试科举------------------------------------
AppEvent.PROXY_PROVEXAM_SHOW_VIEW = "proxy_provexam_show_view"  --乡试科举信息变化通知
AppEvent.PROXY_PROVEXAM_RANK_UPDATE = "proxy_provexam_rank_update"  --乡试科举排行榜信息更新通知
AppEvent.PROXY_PROVEXAM_REWARD_UPDATE = "proxy_provexam_reward_update"  --乡试科举奖励领取后刷新页面通知
AppEvent.PROXY_PROVEXAM_CORRECT = "proxy_provexam_correct"  --乡试科举答对了通知特效
AppEvent.PROXY_PROVEXAM_WRONG = "proxy_provexam_wrong"  --乡试科举答错了通知特效
AppEvent.PROXY_PROVEXAM_PASS_QUES = "proxy_provexam_pass_ques"  --乡试科举换题目时通知
AppEvent.PROXY_PROVEXAM_TIP_NO_ANSWER = "proxy_provexam_tip_no_answer"  --乡试科举没答题提示
--------------------------殿试科举------------------------------------
AppEvent.PROXY_PALACEEXAM_SHOW_VIEW = "proxy_palaceexam_show_view"  --殿试科举信息变化通知
AppEvent.PROXY_PALACEEXAM_RANK_UPDATE = "proxy_palaceexam_rank_update"  --殿试科举排行榜信息更新通知
AppEvent.PROXY_PALACEEXAM_REWARD_UPDATE = "proxy_palaceexam_reward_update"  --殿试科举奖励领取后刷新页面通知
AppEvent.PROXY_PALACEEXAM_ANSWER = "proxy_palaceexam_answer"  --殿试科举答题了传递选中以及正确与否通知
AppEvent.PROXY_PALACEEXAM_PASS_QUES = "proxy_palaceexam_pass_ques"  --殿试科举换题目时通知
AppEvent.PROXY_PALACEEXAM_TIP_NO_ANSWER = "proxy_palaceexam_tip_no_answer"  --殿试科举没答题提示
AppEvent.PROXY_PALACEEXAM_NUM_ONE_UPDATE = "proxy_palaceexam_num_one_update"  --殿试第一名信息变更

--------------------------叛军出没------------------------------------
AppEvent.PROXY_REBELS_ACTIVITY_INFO = "proxy_rebels_activity_info"  --叛军出没活动信息
AppEvent.PROXY_REBELS_RANK_UPDATE = "proxy_rebels_rank_update"  --消灭叛军排名
AppEvent.PROXY_REBELS_OPEN_MAP_AND_JUMP_TO_TILE = "proxy_rebels_open_map_and_jump_to_tile"  --地图跳转
AppEvent.PROXY_REBELS_GO_TO_TILE = "proxy_rebels_go_to_tile"  --地图跳转



--------------------剿匪副本----------------
AppEvent.PROXY_BANDIT_DUNGEON_UPDATE = "proxy_bandit_dungeon_update"  --剿匪副本更新
AppEvent.PROXY_BANDIT_IS_ALL_KILL = "proxy_bandit_is_all_kill" --击杀所有黄巾贼

-------------------------------------------------------------------------------
-- 副本布阵相关
AppEvent.PROXY_BUY_TIMES_UPDATE = "proxy_buy_times_update"  --购买挑战次数
AppEvent.PROXY_GO_FIGHT = "proxy_go_fight"                  --询问成功可以挑战军团副本


--英雄
AppEvent.PROXY_HERO_UPDATE_INFO = "proxy_hero_update_info"  --英雄信息变更通知
AppEvent.PROXY_HEROLVUP_UPDATE_VIEW = "proxy_herolvup_update_view"  --英雄升级面板更新通知
AppEvent.PROXY_HEROBF_UPDATE_VIEW = "proxy_herobf_update_view"  --英雄兵法升级更新通知
AppEvent.PROXY_HEROZF_UPDATE_VIEW = "proxy_herozf_update_view"  --英雄阵法升级更新通知
AppEvent.PROXY_HEROSZ_UPDATE_VIEW = "proxy_herosz_update_view"  --英雄上阵更新通知
AppEvent.PROXY_HERO_POS_CHANGE = "proxy_hero_pos_change"  --英雄换位更新通知
AppEvent.PROXY_HERO_POS_RESOLVE = "proxy_hero_pos_resolve"  --英雄分解更新通知
AppEvent.PROXY_HERO_SHOW_RESOLVE = "proxy_hero_show_resolve"  --英雄分解通知
AppEvent.PROXY_HEROPIECE_UPDATE_INFO = "proxy_heropiece_update_info"  --英雄碎片变更通知
AppEvent.PROXY_HERO_UPDATE_IMG = "proxy_hero_update_img"  --英雄碎片变更通知
AppEvent.PROXY_HERO_LVUPDATE = "proxy_hero_lvupdate"  --英雄升级失败通知

-------------------------------------------------------------------------------
-- 酒馆(战将探宝点兵)相关
AppEvent.PROXY_HEROLOTTERY_REWARD_UPDATE = "proxy_herolottery_reward_update"  --抽奖获得奖励通知
AppEvent.PROXY_HEROLOTTERY_UPDATE = "proxy_herolottery_update"                --战将探宝更新通知

AppEvent.PROXY_BUYGOODS_UPDATE = "proxy_buygoods_update"                --战将探宝更新通知

AppEvent.PROXY_PUB_NORINFO_UPDATE = "proxy_pub_norinfo_update"      --M450000获取酒馆小宴信息成功通知
AppEvent.PROXY_PUB_SPEINFO_UPDATE = "proxy_pub_speinfo_update"      --M450001获取酒馆盛宴信息成功通知
AppEvent.PROXY_PUB_BUY_NORITEM = "proxy_pub_buy_noritem"      --M450002购买女儿红成功通知
AppEvent.PROXY_PUB_BUY_SPEITEM = "proxy_pub_buy_speitem"      --M450003购买竹叶青成功通知
AppEvent.PROXY_PUB_NOR_ONE_OPEN = "proxy_pub_nor_one_open" --M450004小宴单抽（购买）成功通知
AppEvent.PROXY_PUB_NOR_NINE_OPEN = "proxy_pub_nor_nine_open" --M450005小宴九抽（购买）成功通知
AppEvent.PROXY_PUB_SPE_ONE_OPEN = "proxy_pub_spe_one_open" --M450006盛宴单抽（购买）成功通知
AppEvent.PROXY_PUB_SPE_NINE_OPEN = "proxy_pub_spe_nine_open" --M450007盛宴九抽(购买)成功通知
AppEvent.PROXY_PUB_NOR_HISTORY_UPDATE = "proxy_pub_nor_history_update" --M450009小宴界面公告(跑马灯历史数据)
AppEvent.PROXY_PUB_SPE_HISTORY_UPDATE = "proxy_pub_spe_history_update" --M450010盛宴界面公告(跑马灯历史数据)
AppEvent.PROXY_PUB_SHOP_UPDATE = "proxy_pub_shop_update"  --M450008酒令兑换完刷新
AppEvent.PROXY_PUB_ALL_UPDATE = "proxy_pub_all_update"  --零点重置让界面刷新

AppEvent.PROXY_PUB_NOR_NINE_450005 = "proxy_pub_nor_nine_450005" --M450005小宴九抽成功失败都会通知
AppEvent.PROXY_PUB_SPE_NINE_450007 = "proxy_pub_spe_nine_450007" --M450007盛宴九抽成功失败都会通知

AppEvent.PROXY_PUB_NOR_BUYITEM_450002 = "proxy_pub_nor_buyitem_450002" --M450002小宴购买女儿红成功失败都会通知
AppEvent.PROXY_PUB_SPE_BUYITEM_450003 = "proxy_pub_spe_buyitem_450003" --M450003盛宴购买竹叶青成功失败都会通知
-------------------------------------------------------------------------------
--宝具
AppEvent.PROXY_TREASURE_UPDATE_INFO = "proxy_treasure_update_info"  --宝具信息变更通知
AppEvent.PROXY_TREASURE_PUT = "proxy_treasure_put"  --穿上卸下之后关闭穿戴面板通知
AppEvent.PROXY_TREASURE_PIECE_UPDATE_INFO = "proxy_treasure_piece_update_info"  --宝具碎片信息变更通知
AppEvent.PROXY_TREASURE_PURIFY_SUCCESS = "proxy_treasure_purify_success"  --宝具洗炼成功通知播放动画
AppEvent.PROXY_TREASURE_POSTINFOS_UPDATE = "proxy_treasure_postInfos_update"  --英雄槽位上的宝具槽位信息（等阶，祝福值）变更通知
AppEvent.PROXY_TREASURE_ADVANCE_SUCCESS = "proxy_treasure_advance_success"--槽位进阶成功通知播放动画
AppEvent.PROXY_TREASURE_ADVANCE_FAIL = "proxy_treasure_advance_fail"--槽位进阶失败通知播放动画


--军械消息更新
AppEvent.PROXY_PARTS_STRENG = "proxy_parts_streng"  --军械强化更新
AppEvent.PROXY_PARTS_CHANGE = "proxy_parts_change"  --军械改造

AppEvent.PARTS_UPDATE_BUILD_TIP = "parts_update_build_tip"  -- 军械感叹号tip更新
AppEvent.PARTS_NUM_ADD_UPDATE = "parts_num_add_update" -- 军械数量增加
AppEvent.PARTS_EQUIP_IN_HOUSE = "parts_equip_in_house" -- 在仓库穿戴军械
AppEvent.PARTS_PIECE_CHANGE_INFO = "parts_piece_change_info" -- 军械数量增加
AppEvent.PARTS_SPAR_CHANGE_INFO = "parts_spar_change_info" -- 晶石兑换信息变更

-- 称号事件
AppEvent.PROXY_TITLE_CHANGE  = "proxy_title_change" -- 称号更换
AppEvent.PROXY_TITLE_ADD_GOT = "proxy_title_add_got"-- 称号获得

-- 头像框事件
AppEvent.PROXY_FRAME_CHANGE  = "proxy_frame_change" -- 称号更换
AppEvent.PROXY_FRAME_ADD_GOT = "proxy_frame_add_got"-- 称号获得

AppEvent.QUEUEBTN_STATE_EVENT = "queuebtn_state_event" -- toolbar的queueBtn按键隐藏与显示
--AppEvent.PROXY_CREATE_NEW_BUILD_PANEL = "proxy_create_new_build_panel" -- 显示创建界面

--限时活动爆竹酉礼
AppEvent.PROXY_UPDATE_SQUIBINFO = "proxy_update_squibinfo" -- 客户端爆竹位置信息更新
AppEvent.PROXY_SQUIB_AFTER_KINDLE = "proxy_squib_after_kindle" -- 领取后爆竹点燃特效

--新红包，抢红包功能
AppEvent.PROXY_UPDATE_REDBAGINFOS = "proxy_update_redbaginfos" -- 抢红包信息变更通知
AppEvent.PROXY_REDBAGI_OPEN = "proxy_redbag_open" -- 抢红包后打开红包奖励弹窗通知

--武学讲堂
AppEvent.PROXY_UPDATE_MARTIALINFO = "proxy_update_martialinfo" -- 武学讲堂信息变更通知
AppEvent.PROXY_AFTER_MARTIALLEARN = "proxy_after_martiallearn"  -- 学习成功通知特效

--煮酒论英雄
AppEvent.PROXY_UPDATE_COOKINFO = "proxy_update_cookinfo" -- 煮酒论英雄信息变更通知
AppEvent.PROXY_CLOSE_COOKSELECTPANEL = "proxy_close_cookselectpanel" -- 更换英雄成功关闭选择面板
AppEvent.PROXY_AFTER_TOAST = "proxy_after_toast" -- 敬酒成功通知特效

--国之重器
AppEvent.PROXY_UPDATE_BROADSEALINFO = "proxy_update_broadsealinfo" -- 国之重器信息变更通知
AppEvent.PROXY_BROADSEAL_COLLECT = "proxy_broadseal_collect" -- 国之重器收集后表现特效
AppEvent.PROXY_BROADSEAL_COMPOSE = "proxy_broadseal_compose" -- 国之重器组装后表现特效

--礼贤下士
AppEvent.PROXY_UPDATE_CONSORT_INFO = "proxy_update_consort_info"  --礼贤下士活动信息
AppEvent.PROXY_PLAY_CONSORT_ANIMA = "proxy_play_consort_anima"  --礼贤下士动画

--幸运轮盘
AppEvent.PROXY_UPDATE_LUCK_TURNTABLE_INFO = "proxy_update_luck_turntable_info"  --幸运轮盘活动信息

--招财转运
AppEvent.PROXY_UPDATE_CHANGE_LUCK_INFO = "proxy_update_change_luck_info" -- 招财转运数据刷新后通知

--雄狮轮盘
AppEvent.PROXY_LIONTURN_CONSCRIPT = "proxy_lionturn_conscript" -- 雄狮轮盘征召后通知
AppEvent.PROXY_UPDATE_LIONTURNINFO = "proxy_update_lionturninfo" -- 雄狮轮盘数据刷新后通知

--精绝古城
AppEvent.PROXY_JINGJUECITY_OPEN = "proxy_jingjuecity_open" -- 精绝古城单次或全部开启后通知
AppEvent.PROXY_JINGJUECITY_OPEN_ONEPOS = "proxy_jingjuecity_open_onepos" -- 精绝古城单次开启点击某位置后通知
AppEvent.PROXY_JINGJUECITY_UPDATE = "proxy_jingjuecity_update" -- 精绝古城数据刷新后通知界面刷新
AppEvent.PROXY_JINGJUECITY_OPEN_ALL = "proxy_jingjuecity_open_all" -- 精绝古城单次或全部开启后通知(错误码多少也通知)

-- 点评系统
AppEvent.PROXY_COMMENT_ON_SHOW     = "proxy_comment_on_show" -- 获取点评数据显示点评
AppEvent.PROXY_COMMENT_DID_COMMENT = "proxy_comment_did_comment" -- 点评返回
AppEvent.PROXY_COMMENT_DID_LIKE    = "proxy_comment_did_like"   -- 点赞返回

--MainScenePanel通知ToolbarPanel建筑按钮提示免费加速特效
AppEvent.PROXY_BUILDFREE_TOOLBARTIP = "proxy_buildfree_toolbartip" 

--热卖礼包
AppEvent.PROXY_GIFTBAGINFOS_UPDATE = "proxy_giftbaginfos_update" -- 热卖礼包刷新数据通知
AppEvent.PROXY_GIFTBAG_CAN_BUY = "proxy_giftbag_can_buy" -- 热卖礼包通知礼包可以购买

--皇帝的封赏
AppEvent.PROXY_UPDATE_EMPERPRAWARD = "proxy_update_emperraward" -- 皇帝的封赏刷新数据通知

--返利大放送
AppEvent.PROXY_RECHARGEREBATE_AFTER_TURN = "proxy_rechargerebate_after_turn" -- 返利大放送点击开始转盘成功后通知
AppEvent.PROXY_RECHARGEREBATE_INFO_UPDATE = "proxy_rechargerebate_info_update" -- 返利大放送信息刷新通知
AppEvent.PROXY_RECHARGEREBATE_230050 = "proxy_rechargerebate_230050" -- 返利大放送转盘协议返回通知

--同盟致富
AppEvent.PROXY_LEGIONRICH_UPDATE_VIEW = "proxy_legionrich_update_view" --同盟致富数据刷新通知
AppEvent.PROXY_LEGIONRICH_GOTOWORLD = "proxy_legionrich_gotoworld" --同盟致富前往世界通知
AppEvent.PROXY_LEGIONRICH_UPDATE_MEMBERVIEW = "proxy_legionrich_update_memberview" --同盟致富成员采集数据刷新通知
AppEvent.PROXY_LEGIONRICH_CLOSE_MODULE = "proxy_legionrich_close_module" --同盟致富关闭模块



--实名认证系统
AppEvent.PROXY_REALNAME_UPDATE = "proxy_realname_update"  --实名认证信息的刷新
--AppEvent.PROXY_OPEN_REAL_NAME_MODULE = "proxy_open_real_name_module" -- 打开实名制界面

AppEvent.ATTACK_TIMES_UPDATE = "attack_times_update"  --首次攻打世界玩家成功推送
AppEvent.PROXY_QUEPANEL_HIDE = "proxy_quepanel_hide"  --通知隐藏queuepanel界面

--M47 盟战州城系统
AppEvent.PROXY_WARCITY_UPDATE = "proxy_warcity_update"  -- 查看州城刷新界面
AppEvent.PROXY_WARCITY_BATTLE_REPORT = "proxy_warcity_battle_report" -- 获取全服战报
AppEvent.PROXY_WARCITY_SPARE_TEAM = "proxy_warcity_spare_team" -- 获取空闲队伍信息
AppEvent.PROXY_WARCITY_TOWN_RANK = "proxy_warcity_town_rank" -- 获取州排名

AppEvent.PROXY_WARCITY_TOWN_TRADE = "proxy_warcity_town_trade" -- 获取贸易信息
AppEvent.PROXY_WARCITY_TOWN_TRADE_END = "proxy_warcity_town_trade_end" -- 执行贸易兑换

AppEvent.PROXY_WARCITY_TOWN_MINE = "proxy_warcity_town_mine" -- 我方州城信息
AppEvent.PROXY_WARCITY_RED_POINT = "proxy_warcity_red_point" -- 刷新红点
AppEvent.PROXY_WARCITY_MINI_FLAG = "proxy_warcity_mini_flag" -- 刷新天下大势

--M48 四季系统
AppEvent.PROXY_SEASONS_UPDATE = "proxy_seasons_update"  -- 季节更新
AppEvent.PROXY_SEASONS_UPDATE_WORLDLEVEL = "proxy_seasons_update_worldlevel"  -- 刷新世界等级

-- M51 军工所系统
AppEvent.PROXY_MILITARY_UPDATE = "proxy_military_update" -- 军工所刷新


-- M53 军功玩法
AppEvent.PROXY_MAP_MILITARY_UPDATE = "proxy_map_military_update" -- 军功玩法刷新
AppEvent.PROXY_MAP_MILITARY_PLAY_ANIM = "proxy_map_military_play_anim" -- 军功玩法播放动画
-- M55 皇城战系统
AppEvent.PROXY_EMPEROR_CITY_MAP_CLICK = "proxy_emperor_city_map_click" -- 点击皇城
AppEvent.PROXY_EMPEROR_CITY_GET_REPORT = "proxy_emperor_city_get_report" -- 点击查看历史战绩
AppEvent.PROXY_EMPEROR_CITY_RANK_UPDATE = "proxy_emperor_city_rank_update" -- 点击查看排名
AppEvent.PROXY_EMPEROR_CITY_RANK_REWARD = "proxy_emperor_city_rank_reward" -- 点击领取排名奖励
AppEvent.PROXY_EMPEROR_CITY_WARON_UPDATE = "proxy_emperor_city_waron_update" -- 争夺界面刷新
AppEvent.PROXY_EMPEROR_CITY_INFO_UPDATE = "proxy_emperor_city_info_update" -- 皇城界面信息刷新
AppEvent.PROXY_EMPEROR_CITY_UPDATE_WORLD = "proxy_emperor_city_update_world" -- 皇城事件推送刷新
AppEvent.PROXY_EMPEROR_CITY_SHOW_STATE = "proxy_emperor_city_show_state" -- 单独显示用，活动状态和倒计时
AppEvent.PROXY_EMPEROR_CITY_BOUGHT_FIGHT = "proxy_emperor_city_bought_fight" -- 购买特惠讨伐令
AppEvent.PROXY_EMPEROR_CITY_READ_REPORT = "proxy_emperor_city_read_report" -- 读取了个人战报
AppEvent.PROXY_EMPEROR_CITY_READ_REPORT_ACT = "proxy_emperor_city_read_report_act" -- 读取了个人战报

--M57 富贵豪庄
AppEvent.PROXY_RICH_POWERFUL_START_CHANGE_RESP = "proxy_rich_powerful_start_change_resp"
AppEvent.PROXY_RICH_POWERFUL_COMFIRM_RESP = "proxy_rich_powerful_comfirm_resp"
AppEvent.PROXY_RICH_POWERFUL_EXCAHNGE_RESP = "proxy_rich_powerful_excahnge_resp"


-- M56 国家系统
AppEvent.PROXY_COUNTRY_CHANGE_DYNASTY = "proxy_country_change_dynasty" -- 改朝
AppEvent.PROXY_COUNTRY_ALL_ROYAL = "proxy_country_all_royal" -- 获取王族
AppEvent.PROXY_COUNTRY_ROLE_INFO_UPDATE = "proxy_country_role_info_update" -- 填名字刷新回去
AppEvent.PROXY_COUNTRY_APPOINT_SUCCEED = "proxy_country_appoint_succeed" -- 任命成功
AppEvent.PROXY_COUNTRY_REMOVE_SUCCEED = "proxy_country_remove_succeed" -- 卸任成功
AppEvent.PROXY_CHOOSE_LEGION_MEMBERS = "proxy_choose_legion_members" -- 获取成员列表成功
AppEvent.PROXY_COUNTRY_ALL_PRISON = "proxy_country_all_prison" -- 获取监狱列表成功
AppEvent.PROXY_COUNTRY_WANTED_SUCCEED = "proxy_country_wanted_succeed" -- 通缉成功
AppEvent.PROXY_COUNTRY_REMOVE_WANTED = "proxy_country_remove_wanted" -- 撤销成功
AppEvent.PROXY_COUNTRY_GET_SKILLINFO = "proxy_country_get_skillInfo" -- 获取技能信息
AppEvent.PROXY_COUNTRY_USED_SKILL = "proxy_country_used_skill" -- 使用技能
-- M58 中原目标
AppEvent.PROXY_MAP_MILITARY_PLAINSCHAPTER_UPDATE = "proxy_map_military_plainschapter_update" --中原目标数据更新
--M59 同盟任务
AppEvent.PROXY_LEGION_TASKINFO_UPDATE = "proxy_legion_taskinfo_update" --同盟任务信息更新

AppEvent.PROXY_LEGION_TASKINFO_JUMPTO = "proxy_legion_taskinfo_jumpto" --同盟任务信息跳转到

--M60 财源广进
AppEvent.PROXY_GETLOTOFMONEY_UPDATE = "proxy_getlotofmoney_update" --财源广进数据更新
--M61 聚宝盆
AppEvent.PROXY_CORNUCOPIA_UPDATE = "proxy_cornucopia_update" --聚宝盆数据更新


--test 
AppEvent.UNLOCK= "unlock"                                  --挂机开始事件
AppEvent.UNLCOK_EVENT ="unlock_event"

AppEvent.UNLOCK_BEGIN = "unlock_begin"                     --触摸开始事件
AppEvent.UNLOCK_BEGIN_EVENT="unlock_begin_event"



AppEvent.PROXY_M220800_TOWN = "proxy_m220800_town"         --郡城信息推送 刷新
AppEvent.PROXY_M220803_CAPITAL = "proxy_m220803_capital"   --都城信息推送 刷新
AppEvent.PROXY_M220804_IMPERIAL= "proxy_m220804_imperial"  --皇城信息推送 刷新
AppEvent.PROXY_M220801_REWARD  = "proxy_m220801_reward"    --个人奖励分红 刷新
AppEvent.PROXY_M220802_CITYINFO= "proxy_m220802_cityinfo"  --单个城池状态 刷新
AppEvent.PROXY_M220810_REWARDREDPOINT = "proxy_m220810_rewardredpoint" --城池小红点刷新

