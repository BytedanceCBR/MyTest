//
//  TTMagicSwitchTableViewCell.h
//  Article
//
//  Created by 延晋 张 on 16/5/30.
//
//

#import <UIKit/UIKit.h>

@interface TTMagicSwitchTableViewCell : UITableViewCell

@property (nonatomic, copy) void(^valueChangedAction)(BOOL newValue);
@property (nonatomic, assign) BOOL on;

@end
