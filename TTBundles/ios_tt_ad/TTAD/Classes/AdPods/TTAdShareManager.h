//
//  TTAdShareManager.h
//  Article
//
//  Created by yin on 2016/11/11.
//
//

#import <Foundation/Foundation.h>
#import "TTAdShareBoardModel.h"
#import "TTAdShareBoardView.h"
#import "TTAdSingletonManager.h"

@interface TTAdShareManager : NSObject<TTAdSingletonProtocol>

Singleton_Interface(TTAdShareManager)

- (void)requestShareAdData;

+ (void)saveShareBoardModel:(TTAdShareBoardModel*)model;

+ (void)clearShareCache;

+ (TTAdShareBoardModel*)getShareBoardModel;

+ (TTAdShareBoardView*)createShareViewFrame:(CGRect)frame;

+ (void)closeShareAd:(BOOL)close;

- (void)showInAdPage:(NSString*)adId groupId:(NSString*)groupId;

- (void)hideInPage;

+ (void)realTimeRemoveAd:(NSArray*)adIds;

+ (void)predownloadImage:(TTAdShareBoardItemModel*)model;

//不关注predownload字段,直接下载
+ (void)downloadImage:(TTAdShareBoardItemModel*)model;

@end

