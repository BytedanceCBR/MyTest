//
//  TSVRecUserCardCollectionViewCellViewModel.h
//  Article
//
//  Created by 王双华 on 2017/9/27.
//

#import <Foundation/Foundation.h>
#import "TSVRecUserCardModel.h"
#import "TSVRecUserSinglePersonCollectionViewCellViewModel.h"

@class ExploreOrderedData;

@interface TSVRecUserCardCollectionViewCellViewModel : NSObject

@property (nonatomic, copy, readonly) NSString *categoryName;
@property (nonatomic, copy, readonly) NSString *cardID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong, readonly) ExploreOrderedData *cellData;

- (instancetype)initWithOrderedData:(ExploreOrderedData *)data;

- (NSInteger)numberOfSinglePersonCollectionViewCellViewModel;
- (TSVRecUserSinglePersonCollectionViewCellViewModel *)singlePersonCollectionViewCellViewModelAtIndex:(NSInteger)index;
- (void)didSelectSinglePersonCollectionViewCellAtIndex:(NSInteger)index;
- (void)willDisplaySinglePersonCollectionViewCellAtIndex:(NSInteger)index;

///卡片内cell上点击关注
- (void)handleSinglePersonCollectionViewCellFollowBtnTapAtIndex:(NSInteger)index;
///卡片dislike
- (void)handleCardCollectionViewCellDislike;

@end
