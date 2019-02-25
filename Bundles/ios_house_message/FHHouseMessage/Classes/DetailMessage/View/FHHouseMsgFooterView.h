//
//  FHHouseMsgFooterView.h
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseMsgFooterView : UIView

@property(nonatomic, strong) UILabel *contentLabel;

@property(nonatomic, copy) void(^footerViewClickedBlock)(void);

@end

NS_ASSUME_NONNULL_END
