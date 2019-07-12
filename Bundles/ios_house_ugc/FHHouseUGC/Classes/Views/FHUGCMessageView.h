//
//  FHUGCMessageView.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCMessageView : UIView

@property(nonatomic, strong) UIImageView *icon;
@property(nonatomic, strong) UILabel *messageLabel;
@property(nonatomic, copy) NSString *openUrl;

- (void)refreshWithUrl:(NSString *)url messageCount:(NSInteger)messageCount;

@end

NS_ASSUME_NONNULL_END
