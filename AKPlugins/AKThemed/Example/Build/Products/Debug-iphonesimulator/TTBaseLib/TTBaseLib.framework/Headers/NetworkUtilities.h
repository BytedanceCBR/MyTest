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
 * @brief 是否是通过蜂窝网链接的
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
 *@brief 两个特殊函数，这个将有queue使用
 *       注意回调函数要线程安全处理。
 */
void TTNetworkStartNotifier(void);
void TTNetworkStopNotifier(void);

