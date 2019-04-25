//
//  ArticleMomentListCellNameLikeView.m
//  Article
//
//  Created by Zhang Leonardo on 14-5-22.
//
//

#import "ArticleMomentListCellNameLikeView.h"
#import "SSAttributeLabel.h"
#import "SSUserModel.h"
#import "ArticleMomentHelper.h"
#import <TTAccountBusiness.h>
#import "TTDeviceHelper.h"
#import "TTStringHelper.h"
#import "TTLabelTextHelper.h"


#define kLabelFontSize 13
#define kLeftMargin 8
#define kRightMargin 8
#define kTopMargin 6
#define kBottomMargin 5

#define kDefaultDiggLimit 15

#define kStartPaddingStr @""


@interface ArticleMomentListCellNameLikeView()<SSAttributeLabelModelDelegate>
@property(nonatomic, retain)SSAttributeLabel * attributeLabel;
@property(nonatomic, retain)ArticleMomentModel * momentModel;
@property(nonatomic, retain)UIView * separaterLineView;
@end

@implementation ArticleMomentListCellNameLikeView

- (void)dealloc
{
    self.umengEventName = nil;
    self.delegte = nil;
    self.separaterLineView = nil;
    self.momentModel = nil;
    _attributeLabel.delegate = nil;
    self.attributeLabel = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.umengEventName = @"update_tab";
        self.attributeLabel = [[SSAttributeLabel alloc] initWithFrame:CGRectZero];
        _attributeLabel.delegate = self;
        _attributeLabel.userInteractionEnabled = YES;
        _attributeLabel.numberOfLines = 3;
        _attributeLabel.backgroundColor = [UIColor clearColor];
        _attributeLabel.ssDataDetectorTypes = UIDataDetectorTypeNone;
        _attributeLabel.font = [UIFont systemFontOfSize:kLabelFontSize];
        [self addSubview:_attributeLabel];
        self.separaterLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, [TTDeviceHelper ssOnePixel])];
        _separaterLineView.hidden = YES;
        [self addSubview:_separaterLineView];
        
        self.backgroundColor = [UIColor clearColor];
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    _attributeLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    _attributeLabel.selectTextForegroundColorName = kColorText300;
    _separaterLineView.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"dddddd" nightColorName:@"464646"]];
    [self refreshAttributeModel];
}


- (void)showBottomLine:(BOOL)show
{
    _separaterLineView.hidden = !show;
}

- (void)refreshAttributeModel
{
    NSMutableArray * attributeModels = [NSMutableArray arrayWithCapacity:10];
    NSInteger index = [kStartPaddingStr length];
    
    if (![ArticleMomentListCellNameLikeView isZeroLimitStyle:_momentModel]) {
        for (int i = 0; i < MIN([_momentModel.diggUsers count], [ArticleMomentListCellNameLikeView diggLimitForModel:_momentModel]); i ++) {
            SSUserModel * user  = [_momentModel.diggUsers objectAtIndex:i];
            
            SSAttributeLabelModel * model = [[SSAttributeLabelModel alloc] init];
            model.linkURLString = [NSString stringWithFormat:@"ArticleMomentListCellNameLikeView://profile?index=%i", i];
            model.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"3c6598" nightColorName:@"67778b"]];
            model.attributeRange = NSMakeRange(index, [user.name length]);
            index += ([user.name length] + 3);//3是逗号+2个空格
            [attributeModels addObject:model];
        }
    }
    
    [_attributeLabel refreshAttributeModels:attributeModels];
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
        [str appendString:[((SSUserModel *)[model.diggUsers objectAtIndex:i]) name]];
        if (i != count - 1) {
            [str appendString:@",  "];
        }
    }
    if (model.diggsCount > count) {
        [str appendString:NSLocalizedString(@"  等人赞过", nil)];
    }
    else {
        [str appendString:NSLocalizedString(@"  赞过", nil)];
    }
    return str;
}

+ (CGFloat)heightForMomentModel:(ArticleMomentModel *)model viewWidth:(CGFloat)width
{
    NSString * str = [self genContentFromMomentModel:(ArticleMomentModel *)model];
    if (isEmptyString(str)) {
        return 0;
    }
    return [TTLabelTextHelper heightOfText:str fontSize:kLabelFontSize forWidth:width - kLeftMargin - kRightMargin] + kTopMargin + kBottomMargin;
}

#pragma mark -- SSAttributeLabelModelDelegate

- (void)attributeLabel:(SSAttributeLabel *)label didClickLink:(NSString *)linkURLString
{
    if (isEmptyString(linkURLString)) {
        return;
    }
    NSURL * url = [TTStringHelper URLWithURLString:linkURLString];
    NSDictionary *parameters = [TTStringHelper parametersOfURLString:url.query];
    if ([[url host] isEqualToString:@"moment_detail"]) {
        if (_delegte && [_delegte respondsToSelector:@selector(momentNameLikeViewClickedShowAllDiggerView:)]) {
            [_delegte momentNameLikeViewClickedShowAllDiggerView:self];
        }
    }
    else {
        if([parameters count] > 0)
        {
            int index = [[parameters objectForKey:@"index"] intValue];
            if (index < [_momentModel.diggUsers count]) {
                SSUserModel * model = [_momentModel.diggUsers objectAtIndex:index];
                [ArticleMomentHelper openMomentProfileView:model navigationController:[TTUIResponderHelper topNavigationControllerFor: self] from:kFromFeedDigg];
                
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
