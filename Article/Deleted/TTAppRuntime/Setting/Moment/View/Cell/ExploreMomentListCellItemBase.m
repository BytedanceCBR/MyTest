//
//  ExploreMomentListCellItemBase.m
//  Article
//
//  Created by Zhang Leonardo on 15-1-14.
//
//

#import "ExploreMomentListCellItemBase.h"
#import "ArticleMomentListViewBase.h"


@interface ExploreMomentListCellItemBase()

@property(nonatomic, strong, readwrite)ArticleMomentModel * momentModel;

@end

@implementation ExploreMomentListCellItemBase

- (id)initWithWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo
{
    self = [super initWithFrame:CGRectMake(0, 0, cellWidth, 0)];
    if (self) {
        self.cellWidth = cellWidth;
        _userInfo = uInfo;
        _sourceType = [[uInfo objectForKey:kMomentListCellItemBaseUserInfoSourceTypeKey] intValue];
        _isDetailView = [[uInfo objectForKey:kMomentListCellItemBaseIsDetailViewTypeKey] boolValue];
    }
    return self;
}

- (void)setCellWidth:(CGFloat)cellWidth
{
    _cellWidth = cellWidth;
    CGRect frame = self.frame;
    frame.size.width = cellWidth;
    self.frame = frame;
    if (_momentModel) {
        self.height = [self heightForMomentModel:_momentModel cellWidth:CGRectGetWidth(self.frame)];
    }
}

- (void)refreshForMomentModel:(ArticleMomentModel *)model
{
    self.momentModel = model;
    self.height = [self heightForMomentModel:model cellWidth:CGRectGetWidth(self.frame)];
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

- (CGFloat)heightForMomentModel:(ArticleMomentModel *)model cellWidth:(CGFloat)cellWidth
{
    //subview need implements
    return 0;
}


+ (CGFloat)heightForMomentModel:(ArticleMomentModel *)model cellWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo
{
    //subview need implements
    return 0;
}

+ (BOOL)needShowForModel:(ArticleMomentModel *)model userInfo:(NSDictionary *)uInfo
{
    return NO;
}

- (BOOL)isInMomentListView {
    ArticleMomentListViewBase *listView = (ArticleMomentListViewBase *)[self ss_nextResponderWithClass:[ArticleMomentListViewBase class]];
    return listView != nil;
}

- (NSString *)listUmengEventName {
    if (self.sourceType == ArticleMomentSourceTypeMoment) {
        return @"update_tab";
    } else if (self.sourceType == ArticleMomentSourceTypeForum) {
        return @"topic_tab";
    } else if (self.sourceType == ArticleMomentSourceTypeProfile) {
        return @"profile";
    }
    return nil;
}

- (NSString *)detailUmengEventName {
    if (self.sourceType == ArticleMomentSourceTypeForum) {
        return @"topic_detail";
    }
    return @"update_detail";
}

@end
