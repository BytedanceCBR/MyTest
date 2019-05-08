//
//  FHDetailStarsCountView.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailStarsCountView : UIView

@property (nonatomic, strong)   UILabel       *starsName;
@property (nonatomic, strong)   UIView       *starsCountView;
@property (nonatomic, assign)   CGFloat       starsSize;

- (void)updateStarsCount:(NSInteger)scoreValue;

@end

NS_ASSUME_NONNULL_END
