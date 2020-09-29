//
//  FHAppUpdateView.h
//  FHHouseHome
//
//  Created by bytedance on 2020/9/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHAppUpdateView : UIView

@property (nonatomic, copy) void (^updateBlock)(void);
@property (nonatomic, copy) void (^closeBlock)(void);

- (void)updateInfoWithVersion:(NSString *)version content:(NSString *)content forceUpdate:(BOOL )forceUpdate;

- (void)show;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
