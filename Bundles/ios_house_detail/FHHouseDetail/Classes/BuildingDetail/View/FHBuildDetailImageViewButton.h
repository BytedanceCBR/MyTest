//
//  FHBuildDetailImageViewButton.h
//  AKCommentPlugin
//
//  Created by luowentao on 2020/7/28.
//

#import <UIKit/UIKit.h>
#import "FHBuildingDetailModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHBuildDetailImageViewButton : UIView

@property (nonatomic, copy) FHBuildingIndexDidSelect buttonIndexDidSelect;
@property (nonatomic, copy) void (^indexDidSelect)(CGPoint p);
- (void)updateWithData:(id)data;

- (void)buttonMoveWithSize:(CGSize)newSize;

@property (nonatomic, assign) BOOL isSelected;
@end

NS_ASSUME_NONNULL_END
