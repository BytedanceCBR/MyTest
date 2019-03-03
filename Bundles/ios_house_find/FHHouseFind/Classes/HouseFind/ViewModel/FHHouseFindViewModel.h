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
@class FHConfigDataModel;
@interface FHHouseFindViewModel : NSObject

@property(nonatomic , strong) FHHouseFindSearchBar *searchBar;
@property(nonatomic , strong) UIView *splitLine;
@property(nonatomic , strong) UIButton *searchButton;
@property(nonatomic , copy)   void (^showNoDataBlock)(BOOL noData,BOOL isAvaiable);
@property(nonatomic , copy)   void (^updateSegmentWidthBlock)();
@property (nonatomic , assign) NSTimeInterval trackStartTime;
@property (nonatomic , assign) NSTimeInterval trackStayTime;

-(instancetype)initWithCollectionView:(UICollectionView *)collectionView segmentControl:(HMSegmentedControl *)segmentControl;

-(void)showSearchHouse;//点击搜索进入列表页

-(void)showSugPage;//点击搜索框进入sug页面

-(void)setupHouseContent:(FHConfigDataModel *)configData;

-(void)viewWillAppear;

-(void)viewWillDisappear;

- (void)addStayCategoryLog;
- (void)resetStayTime;
- (void)endTrack;
- (void)startTrack;

@end

//@protocol FHHouseFindViewModelDelegate <NSObject>
//
//-(void)showNoDataView;
//
//-(void)hideNoDataView;
//
//-()
//
//@end

NS_ASSUME_NONNULL_END
