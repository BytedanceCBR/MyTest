//  ExploreDownloadButton.m
//  Article
//
//  Created by SunJiangting on 14-9-19.
//
//

#import "ExploreActionButton.h"

#import "Article+TTADComputedProperties.h"
#import "Article.h"
#import "ExploreMovieView.h"
#import "ExploreOrderedData+TTAd.h"
#import "SSADActionManager.h"
#import "SSActionManager.h"
#import "TTAdAction.h"
#import "TTAdCallManager.h"
#import "TTAdCanvasManager.h"
#import "TTAdDetailActionModel.h"
#import "TTAdFeedModel.h"
#import "TTAdManager.h"
#import "TTAdMonitorManager.h"
#import "TTAppLinkManager.h"
#import "TTRoute.h"

@interface ExploreActionButton ()

@end

@implementation ExploreActionButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColorThemeKey = kColorBackground4;
        self.titleColorThemeKey = kColorText6;
        self.borderColorThemeKey = kColorText6;
        
        self.titleLabel.font = [UIFont systemFontOfSize:12.];
        self.layer.cornerRadius = 6;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1;

        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
    }
    return self;
}

- (void)setIconImageNamed:(NSString *)imageName {
    if (imageName) {
        self.imageName = imageName;
        self.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    } else {
        self.imageName = nil;
        [self setImage:nil forState:UIControlStateNormal];
        self.titleEdgeInsets = UIEdgeInsetsZero;
    }
}

- (void)setActionModel:(ExploreOrderedData *)actionModel {
    if (_actionModel != actionModel) {
        _actionModel = actionModel;
        self.adModel =  actionModel.adModel;
    }
}

- (void)setAdModel:(id<TTAdFeedModel>)adModel {
    if (_adModel != adModel) {
        _adModel = adModel;
        NSString *title = [adModel actionButtonTitle];
        [self setTitle:title forState:UIControlStateNormal];
    }
}

- (void)actionButtonClicked:(id)sender showAlert:(BOOL)showAlert
{
    [self actionButtonClicked:self context:nil];
}

- (void)actionButtonClicked:(id)sender context:(NSDictionary *)context
{
    [ExploreMovieView stopAllExploreMovieView];
    
    if (self.adModel) {
        if (self.adModel.adType == ExploreActionTypeApp) {
            [[SSADActionManager sharedManager] handleAppAdModel:self.adModel orderedData:self.actionModel needAlert:NO];
        }
        else if (self.adModel.adType == ExploreActionTypeAction || self.adModel.adType == ExploreActionTypeLocationAction) {
                NSString *phoneNumber = self.adModel.phoneNumber;
                if (phoneNumber.length > 0) {
                    TTAdCallModel* callModel = [[TTAdCallModel alloc] initWithPhoneNumber:phoneNumber];
                    [TTAdAction handleCallActionModel:callModel];
                    
                } else {
                    [TTAdMonitorManager trackService:@"ad_actionButton_phone" status:0 extra:self.adModel.mointerInfo];
                }
        }
        else if (self.adModel.adType == ExploreActionTypeForm || self.adModel.adType == ExploreActionTypeLocationForm) {
            //form表单和lbs_form地理表单全量迁移到cell中不放在button里处理
        }
        else if (self.adModel.adType == ExploreActionTypeCounsel || self.adModel.adType == ExploreActionTypeLocationcounsel) {
            if (isEmptyString(self.adModel.form_url)) {
                [TTAdMonitorManager trackService:@"ad_actionButton_counsel" status:1 extra:self.adModel.mointerInfo];
                return;
            }
            UINavigationController *tController = [TTUIResponderHelper topNavigationControllerFor:nil];
            
            [[SSActionManager sharedManager] openWebURL:self.adModel.form_url appName:@" " adID:self.adModel.ad_id logExtra:self.adModel.log_extra inNavigationController:tController];
        }
        else if (self.adModel.adType == ExploreActionTypeDiscount) {
            
            TTAdDetailActionModel *actionModel = [TTAdDetailActionModel new];
            actionModel.ad_id = self.adModel.ad_id;
            actionModel.log_extra = self.adModel.log_extra;
            actionModel.web_url = self.actionModel.raw_ad.webURL;
            actionModel.open_url = self.actionModel.raw_ad.button_open_url;
            actionModel.web_title = self.adModel.webTitle;
            [TTAdAction handleDetailActionModel:actionModel sourceTag:@"embeded_ad"];
            
        }
        else if (self.adModel.adType == ExploreActionTypeCoupon) {
            // 同form表单 在cell view中处理
        }
        else {
            //先尝试是否有openUrl用SDK打开淘宝、京东等三方应用
            NSMutableDictionary *applinkParams = [NSMutableDictionary dictionary];
            [applinkParams setValue:self.adModel.log_extra forKey:@"log_extra"];
            BOOL isVideo = self.actionModel.article.hasVideo.integerValue;
            BOOL canOpen = NO;
            if (isVideo &&
                [self.adModel.type isEqualToString:@"web"] &&
                [self.actionModel.raw_ad.style isEqualToString:@"canvas"]) {
                UITableViewCell *cellView = context[@"source_cellview"];
                canOpen = [[TTAdManager sharedManager] canvas_showCanvasView:self.actionModel cell:cellView];
                if (canOpen) {
                    return;
                }
            }
            
            if (isVideo && [self.actionModel.ad_id longLongValue] > 0 && !isEmptyString(self.actionModel.openURL)) {
                canOpen = [TTAppLinkManager dealWithWebURL:self.actionModel.article.articleURLString openURL:self.actionModel.openURL sourceTag:@"embeded_ad" value:[self.actionModel.adID stringValue] extraDic:applinkParams];
                if (canOpen) {
                    //针对广告并且能够通过sdk打开的情况
                    return;
                } else {
                    //比如未安装三方SDK,再尝试打开头条页面
                    UINavigationController *tController = [TTUIResponderHelper topNavigationControllerFor:nil];
                    [[SSActionManager sharedManager] openWebURL:self.adModel.webURL appName:self.adModel.webTitle adID:self.adModel.ad_id logExtra:self.adModel.log_extra inNavigationController:tController];
                    wrapperTrackEventWithCustomKeys(@"embeded_ad", @"open_url_h5", self.adModel.ad_id, nil, applinkParams);
                    return;
                }
            }
            //再尝试打开头条页面
            UINavigationController *tController = [TTUIResponderHelper topNavigationControllerFor:nil];
            [[SSActionManager sharedManager] openWebURL:self.adModel.webURL appName:self.adModel.webTitle adID:self.adModel.ad_id logExtra:self.adModel.log_extra inNavigationController:tController];
            if (isEmptyString(self.adModel.webURL)) {
                [TTAdMonitorManager trackService:@"ad_actionButton_others" status:0 extra:self.adModel.mointerInfo];
            }
        }
    }
}

- (void)refreshCreativeIcon {
    if ([self.adModel showActionButtonIcon]) {
        ExploreActionType actionType = self.adModel.adType;
        if (actionType == ExploreActionTypeApp) {
            [self setIconImageNamed:@"download_ad_feed"];
        } else if (actionType == ExploreActionTypeAction || actionType == ExploreActionTypeLocationAction) {
            [self setIconImageNamed:@"cellphone_ad_feed"];
        } else if (actionType == ExploreActionTypeCounsel || actionType == ExploreActionTypeLocationcounsel) {
            [self setIconImageNamed:@"counsel_ad_feed"];
        } else if (actionType == ExploreActionTypeDiscount || actionType == ExploreActionTypeCoupon) {
            [self setIconImageNamed:@"discount_ad_feed"];
        } else {
            [self setIconImageNamed:nil];
        }
    } else {
        [self setIconImageNamed:nil];
    }
}

- (void)refreshForceCreativeIcon {
    ExploreActionType type = self.adModel.adType;
    if (type == ExploreActionTypeApp) {
        [self setIconImageNameForVideoAdCell:@"download_ad_feed"];
    } else if (type == ExploreActionTypeAction) {
        [self setIconImageNameForVideoAdCell:@"cellphone_ad_feed"];
    } else {
        [self setIconImageNameForVideoAdCell:@"view detail_ad_feed"];
    }
}

- (void)setIconImageNameForVideoAdCell:(NSString *)imageName {
    if (imageName) {
        self.imageName = imageName;
        self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    } else {
        self.imageName = nil;
        [self setImage:nil forState:UIControlStateNormal];
        self.titleEdgeInsets = UIEdgeInsetsZero;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = event.allTouches.anyObject;
    CGPoint point =  [touch locationInView:touch.view];
    TTTouchContext *context = [TTTouchContext new];
    context.targetView = self;
    context.touchPoint = point;
    self.lastTouchContext = context;
    [super touchesEnded:touches withEvent:event];
}

@end
