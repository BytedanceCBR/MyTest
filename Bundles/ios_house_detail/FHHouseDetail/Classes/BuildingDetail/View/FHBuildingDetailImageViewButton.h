//
//  FHBuildingDetailImageViewButton.h
//  AKCommentPlugin
//
//  Created by luowentao on 2020/7/28.
//

#import <UIKit/UIKit.h>
#import "FHBuildingDetailModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHBuildingDetailImageViewButton : UIView

@property (nonatomic, copy) FHBuildingIndexDidSelect buttonIndexDidSelect;
- (void)updateWithData:(id)data;

- (void)buttonMoveWithSize:(CGSize)newSize;

- (CGPoint)getButtonPosition;

@property (nonatomic, assign) BOOL isSelected;
@end

NS_ASSUME_NONNULL_END
