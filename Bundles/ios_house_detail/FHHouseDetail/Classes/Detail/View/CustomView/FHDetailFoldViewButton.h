//
//  FHDetailFoldViewButton.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/14.
//

#import <UIKit/UIKit.h>
#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

// 外部布局高度58
@interface FHDetailFoldViewButton : UIButton

- (instancetype)initWithDownText:(NSString *)down upText:(NSString *)up isFold:(BOOL)isFold;
@property (nonatomic, assign)   BOOL       isFold;

@end

NS_ASSUME_NONNULL_END
