//
//  FHHomeMainTableViewDataSource.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/22.
//

#import "JSONModel.h"
#import <JSONModel.h>
#import "FHHomeSectionHeader.h"
#import "FHHouseType.h"

static const NSUInteger kFHHomeListHeaderBaseViewSection = 0;
static const NSUInteger kFHHomeListHouseTypeBannerViewSection = 1;
static const NSUInteger kFHHomeListHouseBaseViewSection = 2;

static const NSUInteger kFHHomeHeaderViewSectionHeight = 45;

NS_ASSUME_NONNULL_BEGIN

@interface FHHomeMainTableViewDataSource : NSObject
@property(nonatomic,strong) NSArray <JSONModel *>*modelsArray;
@property (nonatomic, strong) FHHomeSectionHeader *categoryView;
@property (nonatomic, assign) BOOL showPlaceHolder;
@property (nonatomic, assign) BOOL showNoDataErrorView;
@property (nonatomic, assign) BOOL showRequestErrorView;
@property (nonatomic, assign) BOOL showOpDataListEntrance;
@property (nonatomic, assign) FHHouseType currentHouseType;
@property (nonatomic, strong) NSString * originSearchId;
@property (nonatomic,assign) BOOL isHasFindHouseCategory;
@property(nonatomic,copy) void (^requestErrorRetry)(void);

- (NSString *)pageTypeString;

- (void)resetTraceCahce;

@end

NS_ASSUME_NONNULL_END
