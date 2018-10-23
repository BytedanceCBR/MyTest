//
//  TTVADInfo+ActionTitle.m
//  Article
//
//  Created by panxiang on 2017/5/7.
//
//

#import "TTVADInfo+ActionTitle.h"
#import "TTRoute.h"
#import "TTVFeedItem+Extension.h"
#import "TTVADCell+ADInfo.h"

@implementation TTVADCell (ActionTitle)

- (BOOL)isInstalledApp
{
    NSString *openUrl = [self openUrl];
    return [[UIApplication sharedApplication] canOpenURL:[TTStringHelper URLWithURLString:openUrl]] || [TTRoute conformsToRouteWithScheme:openUrl];
}

- (NSString *)actionButtonTitle {
    if (!isEmptyString([self adInfo].buttonText)) {
        return [self adInfo].buttonText;
    }
    else {
        if (self.hasApp) {
            if ([self isInstalledApp]) {
                return NSLocalizedString(@"启动", nil);
            }
            else {
                if ([TTDeviceHelper isJailBroken] && !isEmptyString(self.app.ipaURL)) {
                    return NSLocalizedString(@"越狱下载", nil);
                }
                else {
                    return NSLocalizedString(@"立即下载", nil);
                }
            }
        }
        else if (self.hasWeb){
            return NSLocalizedString(@"查看详情", nil);
        }
        else if (self.hasCounsel){
            return NSLocalizedString(@"在线咨询", @"在线咨询");
        }
        else if (self.hasPhone){
            if (self.phone.actionType == 1) {
                NSString *title = [self adInfo].buttonText;
                if (title.length == 0) {
                    title = @"拨打电话";
                }
                return title;
            }
        }
        else
        {
            return NSLocalizedString(@"查看详情", nil);
        }
    }
    return nil;
}
@end
