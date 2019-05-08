//
//  FHRefreshCustomFooter.h
//  Article
//
//  Created by 张静 on 2018/8/30.
//

#import <MJRefresh/MJRefreshAutoFooter.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHRefreshCustomFooter : MJRefreshAutoFooter

- (void)setUpNoMoreDataText:(NSString *)text;

- (void)setUpNoMoreDataText:(NSString *)text offsetY:(CGFloat)offsetY;

@end

NS_ASSUME_NONNULL_END
