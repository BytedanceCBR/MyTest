//
//  FHShareCommonInfoManager.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/11/8.
//

#import "FHShareCommonInfoManager.h"
#import <TTIndicatorView.h>

@implementation FHShareCommonInfoManager

-(void)activityHasSharedWith:(id<BDUGActivityProtocol>)activity error:(NSError *)error desc:(NSString *)desc {
    NSString *imageName = error ? @"close_popup_textpage.png" : @"doneicon_popup_textpage.png";
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:desc indicatorImage:[UIImage imageNamed:imageName] autoDismiss:YES dismissHandler:nil];
}

@end
