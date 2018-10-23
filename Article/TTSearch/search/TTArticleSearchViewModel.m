//
//  TTArticleSearchViewModel.m
//  Article
//
//  Created by yangning on 2017/4/18.
//
//

#import "TTArticleSearchViewModel.h"
#import "TTArticleSearchManager.h"
#import "TTArticleSearchHistoryView.h"

const NSInteger TTArticleSearchCellItemCountPerRow  = 2;
const NSInteger TTArticleSearchInboxCellItemCountPerRow  = 3;

static const NSInteger TTArticleSearchViewInboxSection     = 0;
static const NSInteger TTArticleSearchViewHistorySection   = 1;
static const NSInteger TTArticleSearchViewRecommendSection = 2;

static const NSInteger kMaxPartialHistoryShownCount = 4;
static const NSInteger kMaxAllHistoryShownCount     = 20;

@interface TTArticleSearchHeaderCellViewModel ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *titleIcon;
@property (nonatomic, copy) NSString *actionText;
@property (nonatomic, copy) NSString *actionIcon;
@property (nonatomic, copy) void(^titleBlock)();
@property (nonatomic, copy) void(^actionBlock)();
@property (nonatomic, getter=isClosing) BOOL closing;

@end

@implementation TTArticleSearchHeaderCellViewModel
@end

//////////////////////////////////////////////////////////////////////////////////////

@interface TTArticleSearchCellItemViewModel ()

@property (nonatomic, copy) NSString *text;
@property (nonatomic, getter=isEditing) BOOL editing;
@property (nonatomic, copy) void(^actionBlock)(BOOL isEditing);

@end

@implementation TTArticleSearchCellItemViewModel
@end

//////////////////////////////////////////////////////////////////////////////////////

@interface TTArticleSearchViewModel ()

@property (nonatomic) TTArticleSearchManager *manager;

@property (nonatomic, copy) NSArray<TTArticleSearchKeyword *> *inboxKeywords;
@property (nonatomic, copy) NSArray<TTArticleSearchKeyword *> *historyKeywords;
@property (nonatomic, copy) NSArray<TTArticleSearchKeyword *> *recommendKeywords;

@property (nonatomic) BOOL allHistoryShowing;
@property (nonatomic) BOOL recommendHidden;
@property (nonatomic) BOOL historyEditing;

@end

@implementation TTArticleSearchViewModel

- (instancetype)initWithManager:(TTArticleSearchManager *)manager
                  inboxKeywords:(NSArray<TTArticleSearchKeyword *> *)inboxKeywords
                historyKeywords:(NSArray<TTArticleSearchKeyword *> *)historyKeywords
              recommendKeywords:(NSArray<TTArticleSearchKeyword *> *)recommendKeywords
{
    if (self = [super init]) {
        _manager = manager;
        _recommendHidden = [TTArticleSearchManager recommendHidden];
        _allHistoryShowing = [TTArticleSearchManager recommendHiddenIndeed];
        [self updateWithInboxKeywords:inboxKeywords historyKeywords:historyKeywords recommendKeywords:recommendKeywords];
    }
    return self;
}

- (void)updateWithInboxKeywords:(NSArray<TTArticleSearchKeyword *> *)inboxKeywords
                historyKeywords:(NSArray<TTArticleSearchKeyword *> *)historyKeywords
              recommendKeywords:(NSArray<TTArticleSearchKeyword *> *)recommendKeywords
{
    NSRange rangge = NSMakeRange(0, MIN(kMaxAllHistoryShownCount, historyKeywords.count));
    self.historyKeywords = [historyKeywords subarrayWithRange:rangge];
    self.recommendKeywords = [recommendKeywords copy];
    self.inboxKeywords = inboxKeywords;
    if ([self.view conformsToProtocol:@protocol(TTArticleSearchManagerDelegate)]) {
        [self.view articleSearchViewModelDidUpate:self];
    }
}

- (NSInteger)numberOfSections
{
    return 3;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    if (TTArticleSearchViewInboxSection == section) {
        NSInteger inboxKeywordsCount = self.inboxKeywords.count;
        if (0 == inboxKeywordsCount || self.recommendHidden) {
            return 0;
        } else {
            return 1 + ((self.historyKeywords.count > 0 || ![self hasNoRecommend]) ? 1 : 0);//inbox + footer
        }
    } else if (TTArticleSearchViewHistorySection == section) {
        NSInteger historyKeywordsCount = self.historyKeywords.count;
        
        if (0 == historyKeywordsCount) {
            return 0;
        } else {
            NSInteger historyShownCount = (self.historyEditing || self.allHistoryShowing) ? historyKeywordsCount : MIN(historyKeywordsCount, kMaxPartialHistoryShownCount);
            NSInteger rowCount = (historyShownCount + 1) / TTArticleSearchCellItemCountPerRow + 1;
            if (![self hasNoRecommend]) {
                rowCount++;
            }
            return rowCount;
        }
    } else if (TTArticleSearchViewRecommendSection == section) {
        NSInteger recommendKeywordsCount = self.recommendKeywords.count;
        if (0 == recommendKeywordsCount) {
            return 0;
        } else {
            NSInteger recommendShownCount = self.recommendHidden ? 0 : recommendKeywordsCount;
            return (recommendShownCount + 1) / TTArticleSearchCellItemCountPerRow + 1;
        }
    }
    NSAssert(0, @"section index error");
    return 0;
}

- (BOOL)isInboxCellAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == TTArticleSearchViewInboxSection;
}

- (BOOL)isHeaderCellAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == 0 && indexPath.section != TTArticleSearchViewInboxSection;
}

- (BOOL)isFooterCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == TTArticleSearchViewInboxSection) {
        if (![self hasNoInbox]) {
            if (indexPath.row > 0 && indexPath.row == [self numberOfRowsInSection:indexPath.section] - 1) {
                return YES;
            }
        }
    } else if (indexPath.section == TTArticleSearchViewHistorySection) {
        if (![self hasNoRecommend]) {
            if (indexPath.row == [self numberOfRowsInSection:indexPath.section] - 1) {
                return YES;
            }
        }
    }
    return NO;
}

- (TTArticleSearchHeaderCellViewModel *)headerCellViewModelInSection:(NSInteger)section
{
    if (TTArticleSearchViewInboxSection == section) {
        return nil;
    } else if (TTArticleSearchViewHistorySection == section) {
        TTArticleSearchHeaderCellViewModel *headerCellViewModel = [[TTArticleSearchHeaderCellViewModel alloc] init];
        headerCellViewModel.title = @"历史记录";
        if (self.historyEditing || self.historyKeywords.count <= kMaxPartialHistoryShownCount) {
            headerCellViewModel.titleIcon = nil;
        } else {
            if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
                headerCellViewModel.titleIcon = self.allHistoryShowing ? @"arrow_up_night_16" : @"arrow_down_night_16";
            } else {
                headerCellViewModel.titleIcon = self.allHistoryShowing ? @"arrow_up_16" : @"arrow_down_16";
            }
        }
        headerCellViewModel.closing = NO;
        headerCellViewModel.actionText = self.historyEditing ? @"完成" : nil;
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
            headerCellViewModel.actionIcon = self.historyEditing ? nil : @"search_delete_night";
        } else {
            headerCellViewModel.actionIcon = self.historyEditing ? nil : @"search_delete";
        }
        WeakSelf;
        headerCellViewModel.titleBlock = ^{
            StrongSelf;
            self.allHistoryShowing = !self.allHistoryShowing;
            if ([self.view conformsToProtocol:@protocol(TTArticleSearchManagerDelegate)]) {
                [self.view articleSearchViewModelDidUpate:self];
            }
            [self eventTrack:@"click_all"];
        };
        headerCellViewModel.actionBlock = ^{
            StrongSelf;
            self.historyEditing = !self.historyEditing;
            if ([self.view conformsToProtocol:@protocol(TTArticleSearchManagerDelegate)]) {
                [self.view articleSearchViewModelDidUpate:self];
            }
        };
        return headerCellViewModel;
    } else {
        TTArticleSearchHeaderCellViewModel *headerCellViewModel = [[TTArticleSearchHeaderCellViewModel alloc] init];
        headerCellViewModel.title = self.recommendHidden ? @"查看全部推荐词" : @"猜你想搜的";
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
            headerCellViewModel.titleIcon = self.recommendHidden ? @"search_recommend_show_night" : nil;
            headerCellViewModel.actionIcon = self.recommendHidden ? nil : @"search_recommend_hide_night";
        } else {
            headerCellViewModel.titleIcon = self.recommendHidden ? @"search_recommend_show" : nil;
            headerCellViewModel.actionIcon = self.recommendHidden ? nil : @"search_recommend_hide";
        }
        headerCellViewModel.actionText = nil;
        headerCellViewModel.closing = self.recommendHidden;
        WeakSelf;
        if (self.recommendHidden) {
            headerCellViewModel.titleBlock = ^{
                StrongSelf;
                self.recommendHidden = NO;
                if ([self.view conformsToProtocol:@protocol(TTArticleSearchManagerDelegate)]) {
                    [self.view articleSearchViewModelDidUpate:self];
                }
                [TTArticleSearchManager setRecommendHidden:self.recommendHidden];
                [self eventTrack:@"click_recommend"];
            };
            headerCellViewModel.actionBlock = nil;
        } else {
            headerCellViewModel.titleBlock = nil;
            headerCellViewModel.actionBlock = ^{
                StrongSelf;
                self.recommendHidden = YES;
                if ([self.view conformsToProtocol:@protocol(TTArticleSearchManagerDelegate)]) {
                    [self.view articleSearchViewModelDidUpate:self];
                }
                [TTArticleSearchManager setRecommendHidden:self.recommendHidden];
                [self eventTrack:@"hide_recommend"];
            };
        }
        
        return headerCellViewModel;
    }
    NSAssert(0, @"section index error");
    return nil;
}

- (TTArticleSearchCellItemViewModel *)itemViewModelAtIndexPath:(NSIndexPath *)indexPath
                                                      subIndex:(NSInteger)subIndex
                                                        offset:(NSInteger)offset
                                                      rowCount:(NSInteger)rowCount
{
    if ([self isHeaderCellAtIndexPath:indexPath]) {
        NSAssert(0, @"indexPath error");
        return nil;
    }
    
    if ([self isFooterCellAtIndexPath:indexPath]) {
        NSAssert(0, @"indexPath error");
        return nil;
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row - offset; //offset=1
    
    if (section > [self numberOfSections]) {
        NSAssert(0, @"section index error");
        return nil;
    }
    
    NSArray *keywords = nil;
    if (TTArticleSearchViewHistorySection == section) {
        keywords = self.historyKeywords;
    } else if (TTArticleSearchViewRecommendSection == section) {
        keywords = self.recommendKeywords;
    } else if (TTArticleSearchViewInboxSection == section) {
        keywords = self.inboxKeywords;
    } else {
        NSAssert(0, @"section index error");
        return nil;
    }
    
    NSInteger keywordsCount = keywords.count;
    
    if (0 == keywordsCount) {
        return nil;
    }
    
    NSInteger itemIndexInAll = row * rowCount + subIndex;
    if (itemIndexInAll >= keywordsCount) {
        return nil;
    } else {
        TTArticleSearchCellItemViewModel *itemViewModel = [[TTArticleSearchCellItemViewModel alloc] init];
        TTArticleSearchKeyword *searchKeyword = keywords[itemIndexInAll];
        itemViewModel.text = searchKeyword.keyword;
        WeakSelf;
        itemViewModel.actionBlock = ^(BOOL isEditing) {
            StrongSelf;
            if (isEditing) {
                if (self.historyKeywords.count == 1) {
                    self.historyEditing = NO;
                }
                [self.manager removeKeyword:searchKeyword.keyword];
                [self eventTrack:@"delete_history"];
            } else {
                if (section == TTArticleSearchViewHistorySection) {
                    [self eventTrack:@"history_search"];
                } else if (section == TTArticleSearchViewRecommendSection) {
                    [self eventTrack:@"recommend_search"];
                } else if (section == TTArticleSearchViewInboxSection) {
                    [self eventTrackLog3:@{@"name":@"tuijianci", @"click":@"top3"}];
                }
                if (self.view.selectedHandler) {
                    self.view.selectedHandler(searchKeyword);
                }
            }
        };
        if (section == TTArticleSearchViewHistorySection) {
            itemViewModel.editing = self.historyEditing;
        } else {
            itemViewModel.editing = NO;
        }
        return itemViewModel;
    }
    
    NSAssert(0, @"section index error");
    return 0;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    
    if ([self isHeaderCellAtIndexPath:indexPath]) {
        if (TTArticleSearchViewHistorySection == section) {
            return [TTDeviceUIUtils tt_newPadding:43.0];
        } else if (TTArticleSearchViewRecommendSection == section) {
            return self.recommendHidden ? [TTDeviceUIUtils tt_newPadding:60.0] : [TTDeviceUIUtils tt_newPadding:43.0];
        } else {
            return 0.0;
        }
    } else if ([self isFooterCellAtIndexPath:indexPath]) {
        return [TTDeviceUIUtils tt_newPadding:6.0];
    } else {
        return [TTDeviceUIUtils tt_newPadding:42.0];
    }
}

- (BOOL)hasNoRecommend
{
    return self.recommendKeywords.count == 0;
}

- (BOOL)hasNoInbox
{
    return self.inboxKeywords.count == 0;
}

- (void)eventTrack:(NSString *)label
{
    NSString *eventTag = [self.view eventTrackTag];
    if (isEmptyString(eventTag) || isEmptyString(label)) {
        return;
    }
    wrapperTrackEvent(eventTag, label);
}

- (void)eventTrackLog3:(NSDictionary *)params {
    NSString *eventTag = [self.view eventTrackTag];
    if (isEmptyString(eventTag)) {
        return;
    }
    [TTTrackerWrapper eventV3:eventTag params:params];
}

@end

