//
//  ExploreMomentListCellForumItemView.m
//  Article
//
//  Created by Zhang Leonardo on 15-1-14.
//
//


#import "ExploreMomentListCellForumItemView.h"
#import "SSUserSettingManager.h"
#import "ExploreMomentListCellForwardItemView.h"
#import "SSThemed.h"
#import "FRRouteHelper.h"
#import "TTRoute.h"
#import "TTNetworkUtil.h"
#import <TTBaseLib/JSONAdditions.h>
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"

#define kTopPadding     0
#define kBottomPadding  0

#define kTopMargin     5
#define kBottomMargin  5



const UIEdgeInsets ExploreMomentForumLabelInsets = {3, 8, 3, 8};


@interface ExploreMomentListCellForumItemView()

@property(nonatomic, retain)UILabel * forumLabel;
@property(nonatomic, retain)SSThemedButton * bgButton;
@property(nonatomic, assign)ExploreMomentListCellForumItemViewType itemType;

@end

@implementation ExploreMomentListCellForumItemView

- (id)initWithWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo
{
    self = [self initWithWidth:cellWidth userInfo:uInfo forumType:ExploreMomentListCellForumItemViewTypeMoment];
    if (self) {
        
    }
    return self;
}

- (id)initWithWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo forumType:(ExploreMomentListCellForumItemViewType)type
{
    self = [super initWithWidth:cellWidth userInfo:uInfo];
    if (self) {
        self.itemType = type;

        self.forumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _forumLabel.backgroundColor = [UIColor clearColor];
        _forumLabel.numberOfLines = 1;
        [self addSubview:_forumLabel];
        
        self.bgButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        [_bgButton addTarget:self action:@selector(bgButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_bgButton];
        self.bgButton.borderColorThemeKey = kColorLine7;
        self.bgButton.layer.masksToBounds = YES;
        self.bgButton.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    _forumLabel.textColor = [UIColor tt_themedColorForKey:kColorText5];
}

- (void)refreshForMomentModel:(ArticleMomentModel *)model
{
    [super refreshForMomentModel:model];
    _forumLabel.font = [UIFont systemFontOfSize:[ExploreMomentListCellForumItemView preferredForumLabelFontSizeWithType:_itemType]];
    
    CGFloat left = 0, top = 0;
    if (_itemType == ExploreMomentListCellForumItemViewTypeMoment) {
        left = kMomentCellItemViewLeftPadding;
        top = kTopMargin;
        [_forumLabel setText:model.forumName];
    }
    else {
        self.backgroundColor = [UIColor clearColor];
        left = 9;
        [_forumLabel setText:model.originItem.forumName];
    }
    
    [_forumLabel sizeToFit];
    _bgButton.frame = CGRectMake(left, kTopPadding + top, (_forumLabel.width) + ExploreMomentForumLabelInsets.left + ExploreMomentForumLabelInsets.right, (_forumLabel.height) + ExploreMomentForumLabelInsets.top + ExploreMomentForumLabelInsets.bottom);
    _forumLabel.origin = CGPointMake((_bgButton.left) + ExploreMomentForumLabelInsets.left, (_bgButton.top) + ExploreMomentForumLabelInsets.top);
    _bgButton.layer.cornerRadius = (_bgButton.height) / 2;
    
}

- (CGFloat)heightForMomentModel:(ArticleMomentModel *)model cellWidth:(CGFloat)cellWidth
{
    return [ExploreMomentListCellForumItemView heightForMomentModel:model cellWidth:cellWidth userInfo:self.userInfo forumType:_itemType];
}

- (void)bgButtonClicked
{
    ArticleMomentModel * model = nil;
    if (_itemType == ExploreMomentListCellForumItemViewTypeMoment) {
        model = self.momentModel;
    }
    else if (_itemType == ExploreMomentListCellForumItemViewTypeForward) {
        model = self.momentModel.originItem;
    }
    
    if (model.forumID == 0) {
        return;
    }
//    NSString *label;
//    if (self.isInMomentListView) {
//        if (self.sourceType == ArticleMomentSourceTypeForum) {
//            wrapperTrackEvent(@"topic_tab", @"enter_mine");
//            label = @"mine";
//        } else if (self.sourceType == ArticleMomentSourceTypeProfile) {
//            wrapperTrackEvent(@"topic_tab", @"enter_profile");
//            label = @"profile";
//        } else if (self.sourceType == ArticleMomentSourceTypeMoment){
//            wrapperTrackEvent(@"topic_tab", @"enter_update");
//            label = @"update";
//        } else {
//            wrapperTrackEvent(@"topic_tab", @"enter_other");
//            label = @"other";
//        }
//    } else {
//        if (self.sourceType == ArticleMomentSourceTypeMessage) {
//            wrapperTrackEvent(@"topic_tab", @"enter_notify");
//            label = @"notify";
//        } else {
//            wrapperTrackEvent(@"topic_tab", @"enter_post");
//            label = @"update_detail";
//        }
//    }
    if (!isEmptyString(self.momentModel.openURL)) {
        NSMutableDictionary * gdExtJson = @{}.mutableCopy;
        if (self.sourceType == ArticleMomentSourceTypeProfile) {
            [gdExtJson setValue:@"profile" forKey:@"enter_from"];
        }else {
            [gdExtJson setValue:@"click_update" forKey:@"enter_from"];
        }
        [gdExtJson setValue:self.momentModel.ID forKey:@"update_id"];
        NSString * gdExtJsonStr = [gdExtJson tt_JSONRepresentation];
        NSDictionary * params = nil;
        if (!isEmptyString(gdExtJsonStr)) {
            params = @{@"gd_ext_json":gdExtJsonStr};
        }
        NSURL * resultURL = [TTNetworkUtil URLWithURLString:[TTNetworkUtil URLString:self.momentModel.openURL appendCommonParams:params]];
        [[TTRoute sharedRoute] openURLByPushViewController:resultURL];
    }
}

+ (CGFloat)heightForMomentModel:(ArticleMomentModel *)model
                      cellWidth:(CGFloat)cellWidth
                       userInfo:(NSDictionary *)uInfo
                      forumType:(ExploreMomentListCellForumItemViewType)type
{
    if (![self needShowForModel:model userInfo:uInfo forumType:type]) {
        return 0;
    }
    CGFloat height =  [UIFont systemFontOfSize:[ExploreMomentListCellForumItemView preferredForumLabelFontSizeWithType:type]].lineHeight;
    height = ceil(height + kTopPadding + kBottomPadding + ExploreMomentForumLabelInsets.top + ExploreMomentForumLabelInsets.bottom);
    if (type == ExploreMomentListCellForumItemViewTypeMoment) {
        height += (kBottomMargin + kTopMargin);
    }
    return height;
}

+ (CGFloat)heightForMomentModel:(ArticleMomentModel *)model
                      cellWidth:(CGFloat)cellWidth
                       userInfo:(NSDictionary *)uInfo
{
    return [self heightForMomentModel:model cellWidth:cellWidth userInfo:uInfo forumType:ExploreMomentListCellForumItemViewTypeMoment];
}

+ (BOOL)needShowForModel:(ArticleMomentModel *)model userInfo:(NSDictionary *)uInfo forumType:(ExploreMomentListCellForumItemViewType)type
{
//    ArticleMomentSourceType sourceType = [[uInfo objectForKey:kMomentListCellItemBaseUserInfoSourceTypeKey] intValue];
//    if (sourceType == ArticleMomentSourceTypeForum) {
//        return NO;
//    }
//    if (type == ExploreMomentListCellForumItemViewTypeMoment) {
//        if (!isEmptyString(model.forumName) && model.forumID != 0) {
//            return YES;
//        }
//    }
//    else if(type == ExploreMomentListCellForumItemViewTypeForward){
//        if (!isEmptyString(model.originItem.forumName) && model.originItem.forumID != 0) {
//            return YES;
//        }
//    }
    return NO;
}

+ (BOOL)needShowForModel:(ArticleMomentModel *)model userInfo:(NSDictionary *)uInfo
{
    return [self needShowForModel:model userInfo:uInfo forumType:ExploreMomentListCellForumItemViewTypeMoment];
}

+ (NSUInteger)preferredForumLabelFontSizeWithType:(ExploreMomentListCellForumItemViewType)type {

    if (type == ExploreMomentListCellForumItemViewTypeForward) {
        return [ExploreMomentListCellForwardItemView preferredTitleSize];
    }
    return [self forumLabelFontSize];
}

+ (NSUInteger)forumLabelFontSize
{
    int size = 16;
    TTUserSettingsFontSize type = [TTUserSettingsManager settingFontSize];
    switch (type) {
        case TTFontSizeSettingTypeMin:
            size = 14;
            break;
        case TTFontSizeSettingTypeBig:
            size = 18;
            break;
        case TTFontSizeSettingTypeLarge:
            size = 20;
            break;
        default:
            break;
    }
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        size += 1;
    }
    return size;
}


@end
