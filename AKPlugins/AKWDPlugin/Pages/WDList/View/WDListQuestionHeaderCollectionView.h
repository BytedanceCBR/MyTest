//
//  WDListQuestionHeaderCollectionView.h
//  Article
//
//  Created by 延晋 张 on 16/8/23.
//
//

#import <UIKit/UIKit.h>

@class WDListViewModel;

@interface WDListQuestionHeaderCollectionView : UICollectionView

- (instancetype)initWithViewModel:(WDListViewModel *)viewModel
                            frame:(CGRect)frame;

- (CGFloat)viewHeight;

@end
