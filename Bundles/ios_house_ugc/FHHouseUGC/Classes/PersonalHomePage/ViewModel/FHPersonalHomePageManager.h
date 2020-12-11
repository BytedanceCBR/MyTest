//
//  FHPersonalHomePageManager.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FHPersonalHomePageViewController;
@class FHPersonalHomePageFeedViewController;
@class FHPersonalHomePageFeedListViewController;
@class FHPersonalHomePageProfileInfoModel;
@class FHPersonalHomePageTabListModel;

@interface FHPersonalHomePageManager : NSObject
@property(nonatomic,assign) BOOL userInfoChange;
@property(nonatomic,assign) NSInteger currentIndex;
@property(nonatomic,copy) NSString *userId;
@property(nonatomic,strong) NSDictionary *tracerDict;
@property(nonatomic,assign) CGFloat safeArea;
@property(nonatomic,strong) NSMutableArray<NSNumber *> *feedErrorArray;
@property(nonatomic,weak) FHPersonalHomePageViewController *viewController;
@property(nonatomic,weak) FHPersonalHomePageFeedViewController *feedViewController;
@property(nonatomic,strong) NSMutableArray<FHPersonalHomePageFeedListViewController *> *feedListVCArray;
-(void)scrollsToTop;
-(void)scrollViewScroll:(UIScrollView *)scrollView;
-(void)tableViewScroll:(UIScrollView *)scrollView;
- (void)updateProfileInfoWithMdoel:(FHPersonalHomePageProfileInfoModel *)profileInfoModel tabListWithMdoel:(FHPersonalHomePageTabListModel *)tabListModel;
- (void)updateProfileInfoWithMdoel:(FHPersonalHomePageProfileInfoModel *)profileInfoModel;
- (void)initTracerDictWithParams:(NSDictionary *)params;
-(void)collectionViewBeginScroll:(UIScrollView *)scrollView;
-(void)collectionViewDidScroll:(UIScrollView *)scrollView;

@end

NS_ASSUME_NONNULL_END
