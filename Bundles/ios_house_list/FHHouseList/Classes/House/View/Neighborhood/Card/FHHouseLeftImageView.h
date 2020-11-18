//
//  FHHouseLeftImageView.h
//  ABRInterface
//
//  Created by bytedance on 2020/11/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FHImageModel;
@interface FHHouseLeftImageView : UIImageView

@property (nonatomic, strong) FHImageModel *imageModel;

+ (instancetype)squareImageView;

@end

NS_ASSUME_NONNULL_END
