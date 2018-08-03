//
//  TTDetailNatantRelateVideoView.m
//  Article
//
//  Created by Ray on 16/4/11.
//
//

#import "TTDetailNatantRelateVideoView.h"
#import "TTImageView.h"
#import "TTRoute.h"
#import "ArticleInfoManager.h"
#import "TTDetailModel.h"
#import "Article.h"
 
#import "TTStringHelper.h"

#define kLeftPadding 15
#define kRightPadding 15
#define kImgTopPadding 0
#define kImgBottomPadding 15
#define kBottomMarginHeight 15
#define kImgTopCoverViewHeight 40


@interface TTDetailNatantRelateVideoView()
@property(nonatomic, retain)NSDictionary * infoDict;
@property(nonatomic, retain)TTImageInfosModel * imgModel;
@property(nonatomic, retain)TTImageView * imgView;
@property(nonatomic, retain)UIButton * actionButton;
@property(nonatomic, retain)UILabel * titleLabel;
@property(nonatomic, retain)ArticleInfoManager * infoManager;
@property(nonatomic, retain)CAGradientLayer * imgTopCoverLayer;
@end

@implementation TTDetailNatantRelateVideoView

- (void)dealloc
{
    self.imgTopCoverLayer = nil;
}

- (id)initWithWidth:(CGFloat)width
{
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
    }
    return self;
}

- (void)actionButtonClicked {
    NSLocalizedString(@"detail", @"click_large_video");
    NSString * outerSchema = [_infoDict objectForKey:@"outer_schema"];
    if ([[UIApplication sharedApplication] canOpenURL:[TTStringHelper URLWithURLString:outerSchema]]) {
        [[UIApplication sharedApplication] openURL:[TTStringHelper URLWithURLString:outerSchema]];
        wrapperTrackEvent(@"detail", @"enter_youku");
        return;
    }
    NSString * openURL = [_infoDict objectForKey:@"open_page_url"];
    if ([[TTRoute sharedRoute] canOpenURL:[TTStringHelper URLWithURLString:openURL]]) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openURL]];
        
        return;
    }
    
    NSString * groupID = [_infoDict objectForKey:@"group_id"];
    NSString *itemID = [_infoDict objectForKey:@"item_id"];
    NSObject *aggrType = [_infoDict objectForKey:@"aggr_type"];
    if ([groupID longLongValue] > 0) {
        NSMutableString *URLString = [NSMutableString stringWithFormat:@"sslocal://detail?groupid=%@", groupID];
        if (itemID) {
            [URLString appendFormat:@"&itemid=%@", itemID];
            if (aggrType) {
                [URLString appendFormat:@"&aggrtype=%@", aggrType];
            }
        }
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:URLString]];
    }
}

- (void)refreshActionButtonImg{
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    _imgView.backgroundColor = [UIColor colorWithDayColorName:@"ebebeb" nightColorName:@"303030"];
    [self refreshActionButtonImg];
    _titleLabel.textColor = [UIColor colorWithDayColorName:@"fafafa" nightColorName:@"fafafa"];
}

- (void)refreshWithWidth:(CGFloat)width
{
    [super refreshWithWidth:width];
    [self refreshUI];
}

- (void)refreshUI
{
    _imgView.frame = [self frameForImgView];
}

- (NSString *)eventLabel{
    return @"ad_video_show";
}

-(void)trackEventIfNeeded{
    [self sendShowTrackIfNeededForGroup:self.infoManager.detailModel.article.groupModel.groupID withLabel:self.eventLabel];
}


- (CGRect)frameForImgView{
    CGFloat imgHeight = [TTDetailNatantRelateVideoView imgHeightForTTImageInfosModel:_imgModel viewWidth:self.width];
    return CGRectMake(kLeftPadding, kImgTopPadding, self.width - kLeftPadding - kRightPadding, imgHeight);
}

+ (float)imgHeightForTTImageInfosModel:(nullable TTImageInfosModel *)model viewWidth:(float)viewWidth
{
    CGFloat height = 0;
    if (model.width == 0) {
        return 0;
    }
    CGFloat imgShowWidth = viewWidth - kLeftPadding - kRightPadding;
    height = (model.height * imgShowWidth) / model.width;
    return height;
}

+ (float)heightForTTImageInfosModel:(nullable TTImageInfosModel *)model viewWidth:(float)viewWidth
{
    
    CGFloat height = 0;
    CGFloat imgHeight = [self imgHeightForTTImageInfosModel:model viewWidth:viewWidth];
    if (imgHeight == 0) {
        return 0;
    }
    height += imgHeight;
    height += kImgTopPadding;
    height += kImgBottomPadding;
    return height;
}

@end
