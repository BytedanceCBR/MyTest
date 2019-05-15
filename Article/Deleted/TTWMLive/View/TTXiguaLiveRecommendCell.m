//
//  TTXiguaLiveRecommendCell.m
//  Article
//
//  Created by lipeilun on 2017/12/5.
//

#import "TTXiguaLiveRecommendCell.h"
#import "TTXiguaLiveRecommendCollectionView.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTXiguaLiveRecommendUser.h"
#import "ExploreArticleCellViewConsts.h"

@implementation TTXiguaLiveRecommendCell

+ (Class)cellViewClass {
    return [TTXiguaLiveRecommendCellView class];
}

- (void)willDisplay {
    [self.cellView willAppear];
}

- (void)didEndDisplaying {
    [self.cellView didDisappear];
}

- (void)willAppear {
    [self.cellView willAppear];
}

- (void)cellInListWillDisappear:(CellInListDisappearContextType)context {
    [self.cellView didDisappear];
}

@end

@interface TTXiguaLiveRecommendCellView() <TTXiguaLiveRecommendTrackDelegate>
@property (nonatomic, strong) TTXiguaLiveRecommendCollectionView *collectionView;
@property (nonatomic, strong) SSThemedView *bottomLineView;
@property (nonatomic, strong) TTXiguaLiveRecommendUser *xiguaModel;
@end

@implementation TTXiguaLiveRecommendCellView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.bottomLineView];
    }
    return self;
}

+ (CGFloat)heightForData:(ExploreOrderedData *)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)cellType {
    ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
    if (!orderedData.xiguaLiveRecommendUser) {
        return 0;
    }
    
    return [TTXiguaLiveRecommendCollectionView heightWithLayoutType:[TTXiguaLiveRecommendCellView typeByReplacedSingleNoPic:orderedData]];
}

+ (TTXiguaLiveRecommendUserCellType)typeByReplacedSingleNoPic:(ExploreOrderedData *)orderedData {
    TTXiguaLiveRecommendUserCellType newType = [orderedData.cellCtrls tt_integerValueForKey:@"cell_layout_style"];
    if (newType == TTXiguaLiveRecommendUserCellTypeNoPic && [orderedData.xiguaLiveRecommendUser modelArray].count == 1) {
        //无背景图且只有一个的视为另一个单独的类型
        newType = TTXiguaLiveRecommendUserCellTypeNoPicSingle;
    }
    return newType;
}

- (void)willAppear {
    [self.collectionView willDisplay];
}

- (void)didDisappear {
    [self.collectionView didEndDisplaying];
}

- (void)refreshWithData:(id)data {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        self.orderedData = nil;
        return;
    }
    
    if ([self.orderedData.originalData isKindOfClass:[TTXiguaLiveRecommendUser class]]) {
        self.xiguaModel = (TTXiguaLiveRecommendUser *)self.orderedData.originalData;
    } else {
        self.xiguaModel = nil;
        return;
    }
    
    TTXiguaLiveRecommendUserCellType newType = [TTXiguaLiveRecommendCellView typeByReplacedSingleNoPic:self.orderedData];
    if (newType != self.collectionView.cellType) {
        [self.collectionView removeFromSuperview];
        self.collectionView = [TTXiguaLiveRecommendCollectionView collectionViewWithLayoutType:newType];
        self.collectionView.trackDelegate = self;
        [self insertSubview:self.collectionView belowSubview:self.bottomLineView];
    }
    
    self.collectionView.cellDatas = [self.xiguaModel modelArray];
}

- (void)refreshUI {
    if (!CGSizeEqualToSize(self.bounds.size, self.collectionView.size) && self.collectionView.cellType == TTXiguaLiveRecommendUserCellTypeNoPicSingle) {
        self.collectionView.frame = self.bounds;
        [self.collectionView reloadData];
    } else {
        self.collectionView.frame = self.bounds;
    }
    
    self.bottomLineView.frame = CGRectMake(kCellLeftPadding, self.height - [TTDeviceHelper ssOnePixel], self.width - kCellLeftPadding - kCellRightPadding, [TTDeviceHelper ssOnePixel]);
    if ([(ExploreOrderedData *)self.orderedData nextCellHasTopPadding] || self.hideBottomLine) {
        self.bottomLineView.hidden = YES;
    } else {
        self.bottomLineView.hidden = NO;
    }
}

- (id)cellData {
    return self.orderedData;
}

- (SSThemedView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[SSThemedView alloc] init];
        _bottomLineView.backgroundColorThemeKey = kColorLine1;
    }
    return _bottomLineView;
}

#pragma mark - TTXiguaLiveRecommendTrackDelegate

- (NSString *)xiguaLiveImpressionCellId {
    return self.orderedData.uniqueID;
}

- (NSString *)xiguaLiveImpressionCategoryName {
    return self.orderedData.categoryID;
}

- (NSDictionary *)trackShareParamDict {
    NSMutableDictionary *shareDict = [NSMutableDictionary dictionary];
    [shareDict setValue:self.orderedData.categoryID forKey:@"category_name"];
    [shareDict setValue:@"list" forKey:@"position"];
    [shareDict setValue:@"main_tab" forKey:@"list_entrance"];
    [shareDict setValue:self.orderedData.logPb forKey:@"log_pb"];
    [shareDict setValue:@"from_others" forKey:@"follow_type"];
    return shareDict;
}

- (NSDictionary *)trackFollowParamDict {
    NSMutableDictionary *followDict = [NSMutableDictionary dictionary];
    [followDict setValue:self.orderedData.categoryID forKey:@"category_name"];
    [followDict setValue:@"list" forKey:@"position"];
    [followDict setValue:@"main_tab" forKey:@"list_entrance"];
    [followDict setValue:self.orderedData.logPb forKey:@"log_pb"];
    [followDict setValue:@"from_others" forKey:@"follow_type"];
    return followDict;
}

-  (NSDictionary *)trackExtraParamDict{
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    [extraDic setValue:self.orderedData.categoryID forKey:@"category_name"];
    [extraDic setValue:self.orderedData.logPb forKey:@"log_pb"];
    return extraDic;
}

@end
























