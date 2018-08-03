//
//  WDListQuestionHeaderCollectionTagCell.h
//  Article
//
//  Created by 延晋 张 on 16/8/23.
//
//

#import <UIKit/UIKit.h>

@class WDListViewModel;
@class WDQuestionTagEntity;

@interface WDListQuestionHeaderCollectionTagCell : UICollectionViewCell

@property (nonatomic, strong) WDListViewModel *viewModel;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)refreshCellWithTagEntity:(WDQuestionTagEntity *)tagEntity;

+ (CGFloat)collectionCellWidthWithName:(NSString *)name;

@end
