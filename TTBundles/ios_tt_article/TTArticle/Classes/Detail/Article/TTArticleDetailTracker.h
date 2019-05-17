//
//  TTArticleDetailTracker.h
//  Article
//
//  Created by muhuai on 2017/7/30.
//
//

#import <Foundation/Foundation.h>
#import "TTDetailModel.h"
#import "SSWebViewContainer.h"
#import <AKWebViewBundlePlugin/TTDetailWebviewContainer.h>

@interface TTArticleDetailTracker : NSObject

@property(nonatomic, strong) TTDetailModel *detailModel;
@property(nonatomic, strong) TTDetailWebviewContainer *detailWebView;

@property(nonatomic, strong) NSDate *startLoadDate;
@property(nonatomic, strong) NSMutableArray *jumpLinks;
@property(nonatomic, assign) BOOL userHasClickLink;
//广告落地页的跳转次数统计
@property(nonatomic, assign) NSInteger jumpCount;
@property(nonatomic, assign) NSInteger clickLinkCount;
@property(nonatomic, copy)   NSString *loadState;

- (instancetype)initWithDetailModel:(TTDetailModel *)detailModel
                      detailWebView:(TTDetailWebviewContainer *)detailWebView;

- (void)tt_resetStartLoadDate;

- (void)tt_sendStartLoadDateTrackIfNeeded;

- (void)tt_sendJumpLinksTrackWithKey:(NSString *)webViewTrackKey;

- (void)tt_sendStatStayEventTrack:(SSWebViewStayStat)stat error:(NSError *)error;

- (void)tt_sendDomCompleteEventTrack;

- (void)tt_sendLandingPageEventTrack;

- (NSDictionary *)detailTrackerCommonParams;

- (void)tt_sendStartLoadNativeContentForWebTimeoffTrack;

- (void)tt_sendStayTimeImpresssion;

- (void)tt_sendReadTrackWithPCT:(CGFloat)pct
                      pageCount:(NSInteger)pageCount;

- (void)tt_sendJumpOutAppEventTrack;

- (void)tt_sendJumpEventTrack;

- (void)tt_sendJumpToAppStoreTrackWithReuqestURLStr:(NSString *)requestURLStr
                                        inWhiteList:(BOOL)inWhiteList;
@end
