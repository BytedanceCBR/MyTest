//
//  FHRNBaseViewController.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/3/25.
//

#import "FHBaseViewController.h"
#import "TTRNKit.h"
#import "TTRNKitViewWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHRNBaseViewController : FHBaseViewController

- (instancetype)initWithParams:(NSDictionary *)params viewWrapper:(TTRNKitViewWrapper *)viewWrapper;

@end

NS_ASSUME_NONNULL_END
