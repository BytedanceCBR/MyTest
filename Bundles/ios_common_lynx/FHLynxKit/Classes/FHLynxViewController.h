//
//  FHLynxViewController.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/5/11.
//

#import "FHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
@class LynxView;

@interface FHLynxViewController : FHBaseViewController

@property(nonatomic, strong) LynxView* lynxView;

- (void)updateStatusPage:(NSNumber *)status;
//子类复写，追加的参数
- (NSMutableDictionary *)getAddtionParams;

@end

NS_ASSUME_NONNULL_END
