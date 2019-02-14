//
//  FHHouseFindViewModel.h
//  FHHouseFind
//
//  Created by 春晖 on 2019/2/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class HMSegmentedControl;
@class FHHouseFindSearchBar;
@interface FHHouseFindViewModel : NSObject

@property(nonatomic , strong) FHHouseFindSearchBar *searchBar;
@property(nonatomic , strong) UIView *splitLine;
@property(nonatomic , copy)   void (^noDataBlock)();

-(instancetype)initWithCollectionView:(UICollectionView *)collectionView segmentControl:(HMSegmentedControl *)segmentControl;

-(void)showSearchHouse;//点击搜索进入列表页

-(void)showSugPage;//点击搜索框进入sug页面

-(void)setupHouseContent;

-(void)viewWillAppear;

-(void)viewWillDisappear;


@end

NS_ASSUME_NONNULL_END
