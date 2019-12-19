//
//  FHIntroduceManager.h
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/12/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHIntroduceManager : NSObject

+ (instancetype)sharedInstance;

- (void)showIntroduceView:(UIView *)keyWindow;

- (void)hideIntroduceView;

@property (nonatomic , assign, readonly) BOOL isShowing;

@end

NS_ASSUME_NONNULL_END
