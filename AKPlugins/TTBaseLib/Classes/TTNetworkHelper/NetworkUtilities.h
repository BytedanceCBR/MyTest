//
//  Created by David Alpha Fox on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


/**
 * @file NetworkUtilites
 * @author David<gaotianpo@songshulin.net>
 *
 * @brief 网络辅助工具
 * 
 * @details 网络辅助工具
 * 
 */

typedef NS_OPTIONS(NSInteger, TTNetworkFlags) {
    TTNetworkFlagWifi   = 1,
    TTNetworkFlag4G     = 1 << 1,
    TTNetworkFlag3G     = 1 << 2,
    TTNetworkFlag2G     = 1 << 3,
    TTNetworkFlagMobile = 1 << 4
};

extern TTNetworkFlags TTNetworkGetFlags(void);

/**
 * @brief 当前网络是否联通的
 */
BOOL TTNetworkConnected(void);

/**
 * @brief 是否是通过wifi链接的
 */
BOOL TTNetworkWifiConnected(void);

/**
 * @brief 是否有蜂窝网络连接，注: 此方法与是否有 wifi 连接并不互斥，即用户移动网络和 wifi 都连接的情况下，此方法也会返回 YES
 */
BOOL TTNetowrkCellPhoneConnected(void);

/**
 @brief 仅对 ios >= 7.0有效，对于ios <= 6.0, 返回 TTNetowrkCellPhoneConnected(void)
 */
BOOL TTNetwork2GConnected(void);

/**
 @brief 仅对 ios >= 7.0有效，对于ios <= 6.0, 返回 NO
 */
BOOL TTNetwork3GConnected(void);

/**
 @brief 仅对 ios >= 7.0有效，对于ios <= 6.0, 返回 NO
 */
BOOL TTNetwork4GConnected(void);


/**
 检查 App 是否关闭了蜂窝数据网络权限
 对于国行 iPhone，如果设置成 关闭无线局域网和蜂窝数据网络，也认为关闭了蜂窝数据网络权限
 
 注：Apple 未提供 App 网络权限状态的 API，TTNetworkIsCellularDisabled() 和 
 TTNetworkIsCellularAndWLANDisabled() 都是通过排除法确定是否关闭了权限，
 仅在 App 无法联网时方便上层业务逻辑给用户相应提示。
 
 @return 返回 YES 表示准确检测出 App 关闭了权限，返回 NO 表示无法准确检测，不代表 App 没有关闭权限
 */
BOOL TTNetworkIsCellularDisabled(void);

/**
 检查 App 是否关闭了无线局域网和蜂窝数据网络权限（国行 iPhone 特供功能）
 
 @return 返回 YES 表示准确检测出 App 关闭了权限，返回 NO 表示无法准确检测，不代表 App 没有关闭权限
 */
BOOL TTNetworkIsCellularAndWLANDisabled(void);

/**
 *@brief 两个特殊函数，这个将有queue使用
 *       注意回调函数要线程安全处理。
 */
void TTNetworkStartNotifier(void);
void TTNetworkStopNotifier(void);

