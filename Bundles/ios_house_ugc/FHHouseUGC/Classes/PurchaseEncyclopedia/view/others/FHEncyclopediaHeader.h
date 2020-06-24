//
//  FHEncyclopediaHeader.h
//  Pods
//
//  Created by liuyu on 2020/5/13.
//

#import <UIKit/UIKit.h>
#import "EncyclopediaModel.h"
NS_ASSUME_NONNULL_BEGIN
@protocol FHEncyclopediaHeaderDelegate <NSObject>

@optional
//头部选择事件
- (void)selectSegmentWithData:(id)param;

@end
@interface FHEncyclopediaHeader : UIView
@property (weak, nonatomic) id <FHEncyclopediaHeaderDelegate>delegate;
- (void)updateModel:(EncyclopediaConfigDataModel *)model;
@end

NS_ASSUME_NONNULL_END
