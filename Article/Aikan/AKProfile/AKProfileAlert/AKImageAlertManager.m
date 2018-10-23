//
//  AKImageAlertManager.m
//  Article
//
//  Created by chenjiesheng on 2018/3/8.
//

#import "ArticleURLSetting.h"
#import "AKImageAlertManager.h"
#import "AKTaskSettingHelper.h"
#import "TTInterfaceTipManager.h"
#import <TTRoute.h>
#import <TTNetworkManager.h>
#import <BDWebImageManager.h>
@interface AKImageAlertManager ()

@property (nonatomic, strong)AKImageAlertModel          *curAlertModel;

@end

@implementation AKImageAlertManager

static AKImageAlertManager *shareInstance = nil;
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[AKImageAlertManager alloc] init];
    });
    return shareInstance;
}

+ (void)checkProfileImageAlertShowIfNeed
{
    if (![AKTaskSettingHelper shareInstance].akBenefitEnable) {
        return;
    }
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting AKFetchAlertInfo] params:@{@"key" : @"my_tab"} method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (!error && [jsonObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)jsonObj;
            NSDictionary *data = [dict tt_dictionaryValueForKey:@"data"];
            NSInteger errNO = [dict tt_integerValueForKey:@"err_no"];
            if ([data isKindOfClass:[NSDictionary class]] && errNO == 0) {
                BOOL show = [data tt_boolValueForKey:@"pop_up"];
                NSDictionary *imageData = [data tt_dictionaryValueForKey:@"image_data"];
                NSString *imageURL = [imageData tt_stringValueForKey:@"url"];
                NSString *postURL = [data tt_stringValueForKey:@"pop_up_post_url"];
                NSString *openURL = [data tt_stringValueForKey:@"redirect_url"];
                if (show && !isEmptyString(imageURL) && !isEmptyString(postURL)) {
                    AKImageAlertModel *model = [[AKImageAlertModel alloc] init];
                    model.imageURL = imageURL;
                    model.imageViewClickBlock = ^{
                        NSURL *url = [NSURL URLWithString:openURL];
                        if ([[TTRoute sharedRoute] canOpenURL:url]) {
                            [[TTRoute sharedRoute] openURLByPushViewController:url];
                        }
                        [[TTNetworkManager shareInstance] requestForJSONWithURL:postURL params:nil method:@"POST" needCommonParams:YES callback:nil];
                    };
                    model.closeButtonClickBlock = ^{
                        [[TTNetworkManager shareInstance] requestForJSONWithURL:postURL params:nil method:@"POST" needCommonParams:YES callback:nil];
                    };
                    [self appendImageAlertWithModel:model];
                    [AKImageAlertManager shareInstance].curAlertModel = model;
                }
            }
        }
    }];
}

+ (void)appendImageAlertWithModel:(AKImageAlertModel *)model
{
    [[BDWebImageManager sharedManager] requestImage:[NSURL URLWithString:model.imageURL] options:BDImageRequestHighPriority complete:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
        if (!error && image) {
            model.image = image;
            if ([AKImageAlertManager shareInstance].curAlertModel == model) {
                [TTInterfaceTipManager appendTipWithModel:model];
            }
        }
    }];
}
@end
