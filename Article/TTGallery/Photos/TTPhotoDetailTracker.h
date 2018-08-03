//
//  TTPhotoDetailTracker.h
//  Article
//
//  Created by Chen Hong on 16/4/22.
//
//

#import <Foundation/Foundation.h>
#import "SSWebViewContainer.h"

@class TTDetailModel;
@class TTDetailWebviewContainer;

@interface TTPhotoDetailTracker : NSObject

@property(nonatomic, strong) TTDetailModel *detailModel;
@property(nonatomic, strong) TTDetailWebviewContainer *detailWebView;

@property(nonatomic, strong) NSDate *startLoadDate;
@property(nonatomic, strong) NSMutableArray *jumpLinks;
@property(nonatomic, assign) BOOL userHasClickLink;

//广告落地页的跳转次数统计
@property(nonatomic, assign) NSInteger jumpCount;
@property(nonatomic, assign) NSInteger clickLinkCount;

- (instancetype)initWithDetailModel:(TTDetailModel *)detailModel
                      detailWebView:(TTDetailWebviewContainer *)detailWebView;

- (void)tt_resetStartLoadDate;

- (void)tt_sendStartLoadDateTrackIfNeeded;

- (void)tt_sendJumpLinksTrackWithKey:(NSString *)webViewTrackKey;

- (void)tt_sendStatStayEventTrack:(SSWebViewStayStat)stat error:(NSError *)error;

- (void)tt_sendJumpToAppStoreTrackWithReuqestURLStr:(NSString *)requestURLStr
                                        inWhiteList:(BOOL)inWhiteList;

- (void)tt_sendJumpEventTrack;

- (void)tt_sendReadTrackWithPCT:(CGFloat)pct
                      pageCount:(NSInteger)pageCount;

- (void)tt_sendStartLoadNativeContentForWebTimeoffTrack;

- (void)tt_sendStayTimeImpresssion;

- (void)tt_sendDetailTrackEventWithTag:(NSString *)tag label:(NSString *)label extra:(NSDictionary *)extra;

- (void)tt_sendDetailLoadTimeOffLeave;

- (void)tt_sendDetailDeallocTrack:(BOOL)fromBackButton;

- (void)tt_trackGalleryWithTag:(NSString *)tag
                         label:(NSString *)label
                  appendExtkey:(NSString *)key
                appendExtValue:(NSNumber *)extValue;

- (void)tt_trackTitleBarAdWithTag:(NSString *)tag
                            label:(NSString *)label
                            value:(NSString *)value
                         extraDic:(NSDictionary *)dic;

@end
