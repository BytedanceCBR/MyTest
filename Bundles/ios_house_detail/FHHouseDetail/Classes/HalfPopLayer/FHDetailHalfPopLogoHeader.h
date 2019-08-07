//
//  FHDetailHalfPopLogoHeader.h
//  DemoFunTwo
//
//  Created by 春晖 on 2019/5/20.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FHDetailHalfPopType) {
    FHDetailHalfPopTypeCenter,
    FHDetailHalfPopTypeLeft,
};
// 显示 弹窗类型头部信息
@interface FHDetailHalfPopLogoHeader : UIView

- (instancetype)initWithHalfPopType:(FHDetailHalfPopType)halfPopType;
- (void)updateWithTitle:(NSString *)title tip:(NSString *)tip imgUrl:(NSString *)imgUrl;
- (void)updateWithTitle:(NSString *)title tip:(NSString *)tip;
@end

NS_ASSUME_NONNULL_END
