//
//  TTVideoRecommendView.m
//  Article
//
//  Created by 刘廷勇 on 16/4/27.
//
//

#import "TTVideoRecommendView.h"
#import "TTTAttributedLabel.h"
#import "NSStringAdditions.h"

#import "SSUserSettingManager.h"
#import "TTVideoCommon.h"
#import "TTRoute.h"
#import "TTDeviceHelper.h"
#import "TTStringHelper.h"
#import "ExploreMomentDefine.h"
static NSString * const trailingString = @" 推荐";
static NSString * const etcString = @"、...";
static CGFloat const trailingInset = 10.0f;

@interface TTVideoRecommendView () <TTTAttributedLabelDelegate>

@property (nonatomic, strong) SSThemedView *seperator;
@property (nonatomic, strong) TTTAttributedLabel *label;
@property (nonatomic, strong) SSThemedLabel *trailingLabel;

@end

@implementation TTVideoRecommendView

- (void)dealloc
{
    _label.delegate = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self buildView];
        [self setupConstraints];
        [self themeChanged:nil];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    CGFloat lastWidth = self.frame.size.width;
    [super setFrame:frame];
    if (frame.size.width != lastWidth) {
        [self constrainMaxModelCount];
    }
}

- (void)buildView
{
    [self addSubview:self.seperator];
    [self addSubview:self.label];
    [self addSubview:self.trailingLabel];
}

- (void)setupConstraints
{
    [self.seperator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(10);
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(trailingInset);
        make.width.mas_equalTo([TTDeviceHelper ssOnePixel]);
    }];
    
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.seperator).offset(trailingInset);
    }];
    
    [self.label setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.trailingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.label);
        make.left.equalTo(self.label.mas_right);
        make.right.lessThanOrEqualTo(self);
    }];
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    self.label.textColor = SSGetThemedColorWithKey(kColorText3);
    [self updateLinkAttributes];
}

- (void)reloadWithTruncate:(BOOL)truncate
{
    NSString *text = @"";
    NSInteger i = 0;
    for (TTVideoRecommendModel *model in self.viewModel) {
        if (i == 0) {
            text = model.userName;
        } else {
            text = [text stringByAppendingFormat:@"、%@", model.userName];
        }
        i++;
    }
    if (truncate) {
        //如果被截取，最后用...省略
        text = [text stringByAppendingString:etcString];
    }
    self.label.text = text;
    
//    [self addLink];
}

- (void)addLink
{
    if (self.viewModel.count == 1) {
        //如果只有一条，有可能名字过长被截断，导致range找不到，单独处理
        TTVideoRecommendModel *model = self.viewModel[0];
        [self.label addLinkToPhoneNumber:model.mediaID withRange:NSMakeRange(0, [self.label.text length])];
    } else {
        for (TTVideoRecommendModel *model in self.viewModel) {
            NSRange range = [self.label.text rangeOfString:model.userName];
            if (range.location != NSNotFound) {
                [self.label addLinkToPhoneNumber:model.mediaID withRange:range];
            }
        }
    }
}

- (void)updateLinkAttributes
{
    NSMutableDictionary *linkAttributes = [NSMutableDictionary dictionary];
    [linkAttributes setValue:@(NO) forKey:(NSString *)kCTUnderlineStyleAttributeName];
    [linkAttributes setValue:(__bridge id)SSGetThemedColorWithKey(kColorText3).CGColor forKey:(NSString *)kCTForegroundColorAttributeName];
    self.label.linkAttributes = linkAttributes;
    self.label.activeLinkAttributes = linkAttributes;
}

- (void)constrainMaxModelCount
{
    CGFloat trailingWidth = self.trailingLabel.width;
    CGFloat maxWidth = self.width - trailingWidth - trailingInset * 2;//最大可显示宽度
    
    NSInteger count = 0;
    for (TTVideoRecommendModel *model in self.viewModel) {
        CGFloat nameWidth = [self stringWidth:model.userName withString:@"、"];
        if (nameWidth <= maxWidth) {
            count++;
            maxWidth -= nameWidth;
        } else {
            if (self.viewModel.lastObject == model) {
                //最后一条不需要...
                nameWidth = [self stringWidth:model.userName withString:nil];
            } else {
                nameWidth = [self stringWidth:model.userName withString:etcString];
            }
            if (nameWidth <= maxWidth) {
                count++;
            }
            break;
        }
    }
    if (count == 0 && self.viewModel.count > 0) {
        //第一条过长，被截断的情况
        count = 1;
    }
    
    if (count < self.viewModel.count) {
        NSMutableArray *newModelArray = [NSMutableArray arrayWithArray:self.viewModel];
        [newModelArray removeObjectsInRange:NSMakeRange(count, self.viewModel.count - count)];
        self.viewModel = newModelArray;
    }
}

- (CGFloat)stringWidth:(NSString *)name withString:(NSString *)string
{
    if (string) {
        return [[name stringByAppendingString:string] sizeWithFontCompatible:self.label.font].width;
    } else {
        return [name sizeWithFontCompatible:self.label.font].width;
    }
}

#pragma mark -
#pragma mark delegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber
{
    NSString *openPGCURL = [TTVideoCommon PGCOpenURLWithMediaID:phoneNumber
                                                      enterType:kPGCProfileEnterSourceVideoArticleTopAuthor];
    [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openPGCURL]];
}

#pragma mark -
#pragma mark setter and getter

- (void)setViewModel:(NSArray<TTVideoRecommendModel *> *)viewModel
{
    if (_viewModel != viewModel) {
        BOOL truncate = viewModel.count < _viewModel.count;
        _viewModel = viewModel;
        if (viewModel.count > 0) {
            [self reloadWithTruncate:truncate];
        }
    }
}

- (SSThemedView *)seperator
{
    if (!_seperator) {
        _seperator = [[SSThemedView alloc] init];
        _seperator.backgroundColorThemeKey = kColorLine9;
    }
    return _seperator;
}

- (TTTAttributedLabel *)label
{
    if (!_label) {
        _label = [[TTTAttributedLabel alloc] init];
        _label.font = [UIFont systemFontOfSize:[SSUserSettingManager detailVideoContentFontSize]];
        _label.lineBreakMode = NSLineBreakByTruncatingTail;
        _label.numberOfLines = 1;
        _label.delegate = self;
        _label.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    }
    return _label;
}

- (SSThemedLabel *)trailingLabel
{
    if (!_trailingLabel) {
        _trailingLabel = [[SSThemedLabel alloc] init];
        _trailingLabel.font = self.label.font;
        _trailingLabel.text = trailingString;
        _trailingLabel.textColorThemeKey = kColorText3;
        [_trailingLabel sizeToFit];
    }
    return _trailingLabel;
}

@end
