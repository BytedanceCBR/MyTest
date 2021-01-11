//
//  FHDetailNearbyMapItemCell.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/12.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailNearbyMapItemCell : FHDetailBaseCell

@property (nonatomic , strong) UILabel *labelLeft;
@property (nonatomic , strong) UILabel *labelRight;

- (void)updateText:(NSString *)name andDistance:(NSString *)distance;

@end

NS_ASSUME_NONNULL_END
