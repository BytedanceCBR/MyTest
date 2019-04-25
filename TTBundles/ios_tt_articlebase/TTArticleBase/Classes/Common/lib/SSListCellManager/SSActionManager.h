//
//  SSActionManager.h
//  Article
//
//  Created by Zhang Leonardo on 14-2-10.
//
//

#import <Foundation/Foundation.h>
#import "SSTipModel.h"

@class UINavigationController;

@interface SSActionManager : NSObject

+ (SSActionManager *)sharedManager;

// 基本的点击动作接口，同时用于 信息流广告 和 无更新提示
- (void)openDownloadURL:(NSString *)downloadURL appleID:(NSString *)appleID appName:(NSString *)appName;
- (void)openDownloadURL:(NSString *)downloadURL appleID:(NSString *)appleID;
/// 以下几个方法添加ADID是为了统计广告落地页面时间长短
- (void)openAppURL:(NSString *)appURL tabURL:(NSString *)tabURL adID:(NSString *)adID logExtra:(NSString *)logExtra;
- (void)openWebURL:(NSString *)webURL appName:(NSString *)appName adID:(NSString *)adID logExtra:(NSString *)logExtra;
- (void)openWebURL:(NSString *)webURL appName:(NSString *)appNamem adID:(NSString *)adID logExtra:(NSString *)logExtra inNavigationController:(UINavigationController *)navigationController;
/*
 *  downloadURL iTunes 地址
 *  appleID     APPLE ID
 *  localURL    越狱市场直接下载连接
 *  如果没有越狱，则打开应用内下载， 如果越狱， 则直接下载
 */
- (void)openDownloadURL:(NSString *)downloadURL appleID:(NSString *)appleID localDownloadURL:(NSString *)localURL;

- (BOOL)actionForModel:(SSTipModel *)model;

@end
