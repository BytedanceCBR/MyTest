//
//  FHMapNavigationBar.h
//  Article
//
//  Created by 谷春晖 on 2018/11/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger , FHMapNavigationBarRightMode) {
    
    FHMapNavigationBarRightModeNone = 0,
    FHMapNavigationBarRightModeList = 1,
    FHMapNavigationBarRightModeMap = 2
    
};

@interface FHMapNavigationBar : UIView

@property(nonatomic , copy) void (^backActionBlock)();
@property(nonatomic , copy) void (^mapActionBlock)();
@property(nonatomic , copy) void (^listActionBlock)();

-(void)setTitle:(NSString *)title;

-(void)showRightMode:(FHMapNavigationBarRightMode)mode;

@end

NS_ASSUME_NONNULL_END
