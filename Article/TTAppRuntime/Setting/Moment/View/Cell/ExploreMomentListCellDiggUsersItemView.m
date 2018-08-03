//
//  ExploreMomentListCellDiggUsersItemView.m
//  Article
//
//  Created by Zhang Leonardo on 15-1-16.
//
//

#import "ExploreMomentListCellDiggUsersItemView.h"
#import "SSAttributeLabel.h"
#import "SSUserModel.h"
#import "NewsUserSettingManager.h"
#import "ArticleMomentHelper.h"
#import <TTAccountBusiness.h>

#import "ExploreMomentDefine.h"
#import "ExploreMomentListCellCommentListItemView.h"
#import "UIImage+TTThemeExtension.h"

#import "TTStringHelper.h"
#import "TTTabBarProvider.h"

#define kBgViewLeftPadding      kMomentCellItemViewLeftPadding
#define kBgViewRightPadding     kMomentCellItemViewRightPadding

#define kLabelTopPadding    8
#define kLabelBottomPadding 10
#define kLabelBottomPaddingWithoutComments 10
#define kLabelLeftPadding   9
#define kLabelRightPadding  9

#define kDefaultDiggLimit   15

#define kStartPaddingStr @"     "


@interface ExploreMomentListCellDiggUsersItemView()<SSAttributeLabelModelDelegate>
@property(nonatomic, retain)UIView * bgView;
@property(nonatomic, retain)SSAttributeLabel * attributeLabel;
@property(nonatomic, retain)UIImageView * digIconView;
@property(nonatomic, retain)NSString * umengEventName;
@end

@implementation ExploreMomentListCellDiggUsersItemView

- (void)dealloc
{
    _attributeLabel.delegate = nil;
}

- (id)initWithWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo
{
    self = [super initWithWidth:cellWidth userInfo:uInfo];
    if (self) {
        self.umengEventName = @"update_tab";
        
        self.bgView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_bgView];
        
        self.attributeLabel = [[SSAttributeLabel alloc] initWithFrame:CGRectZero];
        _attributeLabel.delegate = self;
        _attributeLabel.userInteractionEnabled = YES;
        _attributeLabel.numberOfLines = 3;
        _attributeLabel.backgroundColor = [UIColor clearColor];
        _attributeLabel.ssDataDetectorTypes = UIDataDetectorTypeNone;
        UIFont *font = [UIFont systemFontOfSize:[NewsUserSettingManager settedMomentDiggCommentFontSize]];
        _attributeLabel.font = font;
        [self addSubview:_attributeLabel];
        
        self.digIconView = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:@"goodbule_details_dynamic"]];
        [_attributeLabel addSubview:_digIconView];
        _digIconView.centerY = font.lineHeight / 2;
        
        self.backgroundColor = [UIColor clearColor];
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    _attributeLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    _attributeLabel.selectTextForegroundColorName = kColorText300;
    _digIconView.image = [UIImage themedImageNamed:@"goodbule_details_dynamic"];
    [self refreshAttributeModel];
    
    _bgView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
}

- (void)refreshAttributeModel
{
    NSMutableArray * attributeModels = [NSMutableArray arrayWithCapacity:10];
    NSInteger index = [kStartPaddingStr length];
    
    if (![ExploreMomentListCellDiggUsersItemView isZeroLimitStyle:self.momentModel]) {
        for (int i = 0; i < MIN([self.momentModel.diggUsers count], [ExploreMomentListCellDiggUsersItemView diggLimitForModel:self.momentModel]); i ++) {
            SSUserModel * user  = [self.momentModel.diggUsers objectAtIndex:i];
            
            SSAttributeLabelModel * model = [[SSAttributeLabelModel alloc] init];
            model.linkURLString = [NSString stringWithFormat:@"ArticleMomentListCellNameLikeView://profile?index=%i", i];
            model.textColor = [UIColor tt_themedColorForKey:kColorText5];
            model.attributeRange = NSMakeRange(index, [user.name length]);
            index += ([user.name length] + 3);//3是逗号+2个空格
            [attributeModels addObject:model];
        }
    }
    
    [_attributeLabel refreshAttributeModels:attributeModels];
}


- (void)refreshForMomentModel:(ArticleMomentModel *)model
{
    [super refreshForMomentModel:model];
    
    _bgView.frame = CGRectMake(kBgViewLeftPadding, 0, self.width - kBgViewLeftPadding - kBgViewRightPadding, self.height);
    
    NSString * str = [ExploreMomentListCellDiggUsersItemView genContentFromMomentModel:self.momentModel];
    
    BOOL needShowComments = [ExploreMomentListCellCommentListItemView needShowForModel:model userInfo:nil];
    CGFloat bottomPadding = needShowComments ? kLabelBottomPadding : kLabelBottomPaddingWithoutComments;
    _attributeLabel.frame = CGRectMake(kMomentCellItemViewLeftPadding + kLabelLeftPadding,
                                       kLabelTopPadding,
                                       self.width - kMomentCellItemViewLeftPadding - kMomentCellItemViewRightPadding - kLabelLeftPadding - kLabelRightPadding,
                                       self.height - kLabelTopPadding - bottomPadding);
    
    [self.attributeLabel setText:str];
    
    [self refreshAttributeModel];

}

- (CGFloat)heightForMomentModel:(ArticleMomentModel *)model cellWidth:(CGFloat)cellWidth
{
    return [ExploreMomentListCellDiggUsersItemView heightForMomentModel:model cellWidth:cellWidth userInfo:self.userInfo];
}

+ (CGFloat)heightForMomentModel:(ArticleMomentModel *)model cellWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo
{
    if (![self needShowForModel:model userInfo:uInfo]) {
        return 0;
    }
    
    NSString * str = [self genContentFromMomentModel:(ArticleMomentModel *)model];
    if (isEmptyString(str)) {
        return 0;
    }
    
    BOOL needShowComments = [ExploreMomentListCellCommentListItemView needShowForModel:model userInfo:nil];
    CGFloat bottomPadding = needShowComments ? kLabelBottomPadding : kLabelBottomPaddingWithoutComments;
    
    CGFloat w = cellWidth - kMomentCellItemViewLeftPadding - kMomentCellItemViewRightPadding - kLabelLeftPadding - kLabelRightPadding;
    CGFloat h = heightOfString(str, [NewsUserSettingManager settedMomentDiggCommentFontSize], w);

    if ([TTDeviceHelper OSVersionNumber] >= 9.0) {
        h += 4;
    }
    return h + kLabelTopPadding + bottomPadding;
}

+ (BOOL)needShowForModel:(ArticleMomentModel *)model userInfo:(NSDictionary *)uInfo
{
    NSString * str = [self genContentFromMomentModel:(ArticleMomentModel *)model];
    if (isEmptyString(str)) {
        return NO;
    }
    return YES;
}
+ (NSUInteger)diggLimitForModel:(ArticleMomentModel *)model
{
    if (model.diggLimit == kMomentModelDiggUserLimitMax) {
        return kDefaultDiggLimit;//客户端默认最大值
    }
    else if (model.diggLimit == kMomentModelDiggUserLimitZero) {
        return 0;
    }
    return model.diggLimit;
}

+ (BOOL)isZeroLimitStyle:(ArticleMomentModel *)model
{
    if ([self diggLimitForModel:model] == 0 && model.diggsCount > 0) {
        return YES;
    }
    return NO;
}

+ (NSString *)genContentFromMomentModel:(ArticleMomentModel *)model
{
    if ([self isZeroLimitStyle:model]) {
        return nil;
    }
    else if ([model.diggUsers count] == 0) {
        return nil;
    }
    
    NSMutableString * str = [NSMutableString stringWithCapacity:10];
    [str appendString:kStartPaddingStr];
    NSInteger count = MIN([self diggLimitForModel:model], [model.diggUsers count]);
    for (int i = 0; i < count; i ++) {
        NSString *name = [((SSUserModel *)[model.diggUsers objectAtIndex:i]) name];
        if (!isEmptyString(name)) [str appendString:name];
        if (i != count - 1) {
            [str appendString:@",  "];
        }
    }
    
    return str;
}

#pragma mark -- SSAttributeLabelModelDelegate

- (void)attributeLabel:(SSAttributeLabel *)label didClickLink:(NSString *)linkURLString
{
    if (isEmptyString(linkURLString)) {
        return;
    }
    
    NSURL * url = [TTStringHelper URLWithURLString:linkURLString];
    NSDictionary *parameters = [TTStringHelper parametersOfURLString:url.query];
    if([parameters count] > 0)
    {
        int index = [[parameters objectForKey:@"index"] intValue];
        if (index < [self.momentModel.diggUsers count]) {
            SSUserModel * model = [self.momentModel.diggUsers objectAtIndex:index];
            [ArticleMomentHelper openMomentProfileView:model navigationController:[TTUIResponderHelper topNavigationControllerFor: self] from:kFromFeedDigg];
            
            if ([TTTabBarProvider isWeitoutiaoOnTabBar] && self.sourceType == ArticleMomentSourceTypeMoment) {
                NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
                [extra setValue:self.momentModel.ID forKey:@"item_id"];
                [extra setValue:self.momentModel.group.ID forKey:@"value"];
                [TTTrackerWrapper event:@"micronews_tab" label:@"digger_avatar" value:nil extValue:nil extValue2:nil dict:[extra copy]];
            }
            else {
                if (![TTAccountManager isLogin]) {
                    wrapperTrackEvent(_umengEventName, @"logoff_click_digger");
                }
                else {
                    wrapperTrackEvent(_umengEventName, @"click_digger");
                }
            }
        }
    }
}

@end
