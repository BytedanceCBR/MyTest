//
//  FHAnswerListTitleView.h
//  AKWDPlugin
//
//  Created by bytedance on 2020/9/16.
//

#import <UIKit/UIKit.h>
#import <WDListViewModel.h>
NS_ASSUME_NONNULL_BEGIN

@interface FHAnswerListTitleView : UIView
-(void)updateWithViewModel:(WDListViewModel *)viewModel;
@end

NS_ASSUME_NONNULL_END
