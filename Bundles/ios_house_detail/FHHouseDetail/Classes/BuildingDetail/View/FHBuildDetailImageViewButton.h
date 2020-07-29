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

- (void)updateWithData:(id)data;

- (void)buttonMoveWithHeight:(CGFloat)nowWidth withHeight:(CGFloat)nowHeight;

@property (nonatomic, assign) BOOL isSelected;
@end

NS_ASSUME_NONNULL_END
