//
//  FHMessageTopView.h
//  FHHouseMessage
//
//  Created by xubinbin on 2020/7/27.
//

#import <UIKit/UIKit.h>
typedef void (^TagChangeBlock)(NSInteger tag);

NS_ASSUME_NONNULL_BEGIN

@interface FHMessageTopView : UIView

@property (nonatomic, copy) TagChangeBlock tagChangeBlock;

- (void)updateRedPointWithChat:(NSInteger)chatNumber andSystemMessage:(NSInteger)systemMessageNumber;

@end

NS_ASSUME_NONNULL_END
