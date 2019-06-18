//
//  FHMessageNotificationCellHelper.m
//  Article
//
//  Created by 邱鑫玥 on 2017/4/10.
//
//

#import "FHMessageNotificationCellHelper.h"
#import "TTMessageNotificationModel.h"
#import "FHMessageNotificationNormalCell.h"
#import "FHMessageNotificationInteractiveCell.h"
#import "FHMessageNotificationFollowCell.h"
#import "FHMessageNotificationDigCell.h"
#import "TTDeviceHelper.h"
#import "TTMessageNotificationManager.h"
#import "TTMessageNotificationWDInviteCell.h"

@implementation FHMessageNotificationCellHelper

+ (Class)cellClassForData:(TTMessageNotificationModel *)data{
    switch ([data.style integerValue]) {
        case TTMessageNotificationStyleRawText:
            return [FHMessageNotificationNormalCell class];
        case TTMessageNotificationStyleJump:
            return [FHMessageNotificationNormalCell class];
        case TTMessageNotificationStyleInteractive:
            return [FHMessageNotificationInteractiveCell class];
        case TTMessageNotificationStyleInteractiveMerge:
            return [FHMessageNotificationInteractiveCell class];
        case TTMessageNotificationStyleFollow:
            return [FHMessageNotificationFollowCell class];
        case TTMessageNotificationStyleFollowMerge:
            return [FHMessageNotificationFollowCell class];
        case TTMessageNotificationStyleDig:
            return [FHMessageNotificationDigCell class];
        case TTMessageNotificationStyleDigMerge:
            return [FHMessageNotificationDigCell class];
        default:
            return nil;
    }
}

+ (void)registerAllCellClassWithTableView:(UITableView *)tableView{
    [tableView registerClass:[FHMessageNotificationNormalCell class] forCellReuseIdentifier:NSStringFromClass([FHMessageNotificationNormalCell class])];
    [tableView registerClass:[FHMessageNotificationInteractiveCell class] forCellReuseIdentifier:NSStringFromClass([FHMessageNotificationInteractiveCell class])];
    [tableView registerClass:[FHMessageNotificationFollowCell class] forCellReuseIdentifier:NSStringFromClass([FHMessageNotificationFollowCell class])];
    [tableView registerClass:[FHMessageNotificationDigCell class] forCellReuseIdentifier:NSStringFromClass([FHMessageNotificationDigCell class])];
}

+ (FHMessageNotificationBaseCell *)dequeueTableCellForData:(FHMessageNotificationModel *)data tableView:(UITableView *)view atIndexPath:(NSIndexPath *)indexPath{
    Class cls = [self cellClassForData:data];
    if(cls){
        return [view dequeueReusableCellWithIdentifier:NSStringFromClass(cls)];
    }
    else{
        return nil;
    }
}

+ (CGFloat)heightForData:(FHMessageNotificationModel *)data cellWidth:(CGFloat)width{
    Class cls = [self cellClassForData:data];
    if(cls){
        if ([cls isSubclassOfClass:[FHMessageNotificationBaseCell class]]) {
            return [cls heightForData:data cellWidth:width];
        }
    }
    return 44;
}

+ (CGFloat)tt_newPadding:(CGFloat)normalPadding{
    if(![TTDeviceHelper isPadDevice]){
        return ceil(normalPadding);
    }
    else{
        return ceil(normalPadding * 1.3);
    }
}

+ (CGFloat)tt_newFontSize:(CGFloat)normalSize{
    if(![TTDeviceHelper isPadDevice]){
        return ceil(normalSize);
    }
    else{
        return ceil(normalSize * 1.3);
    }
}

+ (CGSize)tt_newSize:(CGSize)normalSize{
    return CGSizeMake([self tt_newPadding:normalSize.width], [self tt_newPadding:normalSize.height]);
}

+ (NSDictionary *)listCellLogExtraForData:(TTMessageNotificationModel *)data{
    NSMutableDictionary *logExtra = [NSMutableDictionary new];
    
    if (data.actionType) {
        [logExtra setObject:data.actionType forKey:@"action_type"];
    }
    
    if ([TTMessageNotificationManager sharedManager].curListReadCursor ) {
        if ([data.cursor compare:[TTMessageNotificationManager sharedManager].curListReadCursor] == NSOrderedDescending) {
            [logExtra setObject:@(1) forKey:@"is_new"];
        } else {
            [logExtra setObject:@(0) forKey:@"is_new"];
        }
    }
    
    return [logExtra copy];
}

@end
