//
//  TTIMSystemMessageCell.h
//  EyeU
//
//  Created by matrixzk on 10/31/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTIMMessage;

@interface TTIMSystemMessageCell : UITableViewCell
- (void)setupCellWithMessage:(TTIMMessage *)message;
+ (NSString *)TTIMSystemMsgCellReuseIdentifier;
@end
