//
//  FHAnswerDetailTitleView.h
//  AKWDPlugin
//
//  Created by bytedance on 2020/9/15.
//

#import <UIKit/UIKit.h>
#import "WDDetailModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHAnswerDetailTitleView : UIView
@property(nonatomic,assign) CGSize size;
@property(nonatomic,assign) BOOL isShow;
-(void)updateWithDetailModel:(WDDetailModel *)detailModel;
-(void)viewShouldShow:(BOOL)show;
@end

NS_ASSUME_NONNULL_END
