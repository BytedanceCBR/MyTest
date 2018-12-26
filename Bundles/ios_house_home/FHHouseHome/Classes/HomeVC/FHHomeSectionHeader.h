//
//  FHHomeSectionHeader.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHomeSectionHeader : UIView

- (void)updateSegementedTitles:(NSArray <NSString *> *)titles;

- (void)updateSegementedTitles:(NSArray <NSString *> *)titles andSelectIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
