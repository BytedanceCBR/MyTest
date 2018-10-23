//
//  AWEVideoDetailDefine.h
//  HTSVideoPlay
//
//  Created by carl on 2017/12/15.
//

#import <Foundation/Foundation.h>

@class TTShortVideoModel;

@protocol AWEVideoDetailTopViewDelegate <NSObject>
@optional
- (void)topView:(UIViewController *)viewController didClickCloseWithModel:(TTShortVideoModel *)model;
- (void)topView:(UIViewController *)viewController didClickReportWithModel:(TTShortVideoModel *)model;
@end
