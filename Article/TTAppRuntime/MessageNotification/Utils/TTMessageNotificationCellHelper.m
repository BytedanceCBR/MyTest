//
//  TTMessageNotificationCellHelper.m
//  Article
//
//  Created by 邱鑫玥 on 2017/4/10.
//
//

#import "TTMessageNotificationCellHelper.h"
#import "TTMessageNotificationModel.h"
#import "TTMessageNotificationNormalCell.h"
#import "TTMessageNotificationInteractiveCell.h"
#import "TTMessageNotificationFollowCell.h"
#import "TTMessageNotificationDigCell.h"
#import "TTMessageNotificationWDInviteCell.h"
#import "TTDeviceHelper.h"
#import "TTMessageNotificationManager.h"

@implementation TTMessageNotificationCellHelper

+ (Class)cellClassForData:(TTMessageNotificationModel *)data{
    switch ([data.style integerValue]) {
        case TTMessageNotificationStyleRawText:
            return [TTMessageNotificationNormalCell class];
        case TTMessageNotificationStyleJump:
            return [TTMessageNotificationNormalCell class];
        case TTMessageNotificationStyleInteractive:
            return [TTMessageNotificationInteractiveCell class];
        case TTMessageNotificationStyleInteractiveMerge:
            return [TTMessageNotificationInteractiveCell class];
        case TTMessageNotificationStyleFollow:
            return [TTMessageNotificationFollowCell class];
        case TTMessageNotificationStyleFollowMerge:
            return [TTMessageNotificationFollowCell class];
        case TTMessageNotificationStyleDig:
            return [TTMessageNotificationDigCell class];
        case TTMessageNotificationStyleDigMerge:
            return [TTMessageNotificationDigCell class];
        case TTMessageNotificationStyleWDInvite:
            return [TTMessageNotificationWDInviteCell class];
        default:
            return nil;
    }
}

+ (void)registerAllCellClassWithTableView:(UITableView *)tableView{
    [tableView registerClass:[TTMessageNotificationNormalCell class] forCellReuseIdentifier:NSStringFromClass([TTMessageNotificationNormalCell class])];
    [tableView registerClass:[TTMessageNotificationInteractiveCell class] forCellReuseIdentifier:NSStringFromClass([TTMessageNotificationInteractiveCell class])];
    [tableView registerClass:[TTMessageNotificationFollowCell class] forCellReuseIdentifier:NSStringFromClass([TTMessageNotificationFollowCell class])];
    [tableView registerClass:[TTMessageNotificationDigCell class] forCellReuseIdentifier:NSStringFromClass([TTMessageNotificationDigCell class])];
    [tableView registerClass:[TTMessageNotificationWDInviteCell class] forCellReuseIdentifier:NSStringFromClass([TTMessageNotificationWDInviteCell class])];
}

+ (TTMessageNotificationBaseCell *)dequeueTableCellForData:(TTMessageNotificationModel *)data tableView:(UITableView *)view atIndexPath:(NSIndexPath *)indexPath{
    Class cls = [self cellClassForData:data];
    if(cls){
        return [view dequeueReusableCellWithIdentifier:NSStringFromClass(cls)];
    }
    else{
        return nil;
    }
}

+ (CGFloat)heightForData:(TTMessageNotificationModel *)data cellWidth:(CGFloat)width{
    Class cls = [self cellClassForData:data];
    if(cls){
        if ([cls isSubclassOfClass:[TTMessageNotificationBaseCell class]]) {
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
