//
//  FHVideoErrorView.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/4/29.
//

#import <UIKit/UIKit.h>
#import "TTVPlayerCustomViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHVideoErrorView : UIView<TTVPlayerErrorViewProtocol>

@property(nonatomic, copy) NSString *imageUrl;

@property (nonatomic, strong) void(^willClickRetry)(void);

@end

NS_ASSUME_NONNULL_END
