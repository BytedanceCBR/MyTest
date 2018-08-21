//
//  TTDetailNatantVideoInfoView.h
//  Article
//
//  Created by Ray on 16/4/14.
//
//

#import "TTDetailNatantViewBase.h"
#define kVerticalEdgeMargin             (([TTDeviceHelper isPadDevice]) ? 20 : 15)
#define kTitleLabelLineHeight           [SSUserSettingManager detailVideoTitleLineHeight]
#define kContentLabelLineHeight         [SSUserSettingManager detailVideoContentLineHeight]
#define kDetailButtonLeftSpace          5.f
#define kDetailButtonRightPadding       (([TTDeviceHelper isPadDevice]) ? 20 : 3)
#define kTitleLabelBottomSpace          (([TTDeviceHelper isPadDevice]) ? 22 : 4)
#define kContentLabelBottomSpace        (([TTDeviceHelper isPadDevice]) ? 30 : 15)
#define kWatchCountLabelBottomSpace     -2.f
#define kWatchCountContentLabelSpace    (([TTDeviceHelper isPadDevice]) ? 20 : 15)
#define kTitleLabelMaxLines             1
#define kContentLabelMaxLines           0
#define kDigBurrySpaceScreenWidthAspect 0.2f
#define kVideoDetailItemCommonEdgeMargin (([TTDeviceHelper isPadDevice]) ? 20 : 15)
@class Article;
@protocol TTDetailNatantVideoInfoViewDelegate
- (void)extendLinkButton:(UIButton *)button clickedWithArticle:(Article *)article;
@optional
- (Article *)ttv_getSourceArticle;
- (void)shareButton: (UIButton *)button clickedWithArticle:(Article *)article;
- (void)directShareActionClickedWithActivityType:(NSString *)activityType;
@end

@interface TTDetailNatantVideoInfoView : TTDetailNatantViewBase

@property (nonatomic, assign) BOOL intensifyAuthor;
@property (nonatomic, assign) BOOL isShowShare;
@property (nonatomic ,weak)NSObject <TTDetailNatantVideoInfoViewDelegate> *delegate;
- (void)showBottomLine;

@end
