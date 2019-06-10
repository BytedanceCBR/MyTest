//
//  SSADActionManager.h
//  Article
//
//  Created by Zhang Leonardo on 14-2-10.
//
//

#import <Foundation/Foundation.h>
#import "TTPhotoDetailAdModel.h"

@class TTADEventTrackerEntity;
@class TTVFeedItem;
@interface TTVOpenAppParameter : NSObject
@property (nonatomic, copy) NSString *openURL;
@property (nonatomic, copy) NSString *appURL;
@property (nonatomic, copy) NSString *tabURL;
@property (nonatomic, copy) NSString *adID;
@property (nonatomic, copy) NSString *logExtra;
@property (nonatomic, copy) NSString *ipaURL;
@property (nonatomic, copy) NSString *alertText;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *displayInfo;
@property (nonatomic, copy) NSString *downloadURL;
@property (nonatomic, copy) NSString *appleid;
@property (nonatomic, strong) TTADEventTrackerEntity *trackerEntity;

+ (TTVOpenAppParameter *)parameterWithFeedItem:(TTVFeedItem *)item;
- (BOOL)isInstalledApp;
@end


@class SSADBaseModel, ExploreOrderedData, TTAdFeedModel;
@protocol TTAdAppAction;
@protocol TTAd;


@interface SSADActionManager : NSObject

+ (SSADActionManager *)sharedManager;

// 用于文章内嵌app类型广告
- (void)handleAppAdModel:(id<TTAdAppAction, TTAd>) adModel orderedData:(ExploreOrderedData *)orderedData needAlert:(BOOL)needAlert;

//feed重构
- (void)openAppWithParameter:(TTVOpenAppParameter *)parameter;
- (void)handleAppActionForADBaseModel:(SSADBaseModel *)adModel forTrackEvent:(NSString *)event needAlert:(BOOL)needAlert;

#pragma mark -- 图集广告逻辑

//图集广告下载app打开方式
- (void)handlePhotoAlbumAppActionForADModel:(TTPhotoDetailAdModel *)adModel;

//图集广告点击背景图片web打开方式
- (void)handlePhotoAlbumBackgroundWebModel:(TTPhotoDetailAdModel *)adModel WithResponder:(UIResponder*)responder;

//图集广告点击创意按钮web打开方式(容错)
- (void)handlePhotoAlbumButtondWebModel:(TTPhotoDetailAdModel *)adModel WithResponder:(UIResponder*)responder;

//图集广告电话action打开方式
- (void)handlePhotoAlbumPhoneActionModel:(TTPhotoDetailAdModel *)adModel;

@end
