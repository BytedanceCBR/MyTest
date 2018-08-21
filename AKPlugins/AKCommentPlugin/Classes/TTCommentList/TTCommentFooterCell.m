//
//  TTCommentFoldCell.m
//  Article
//
//  Created by muhuai on 27/02/2017.
//
//

#import "TTCommentFooterCell.h"
#import "TTCommentDefines.h"
#import "TTCommentUIHelper.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/TTDeviceUIUtils.h>




NSString * const kTTCommentFooterCellReuseIdentifier = @"kTTCommentFooterCellReuseIdentifier";

@interface TTCommentFooterCell ()
@property (nonatomic, strong) SSThemedView *separatorView;
@property (nonatomic, strong) SSThemedLabel *descLabel;
@end

@implementation TTCommentFooterCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColorThemeKey = kColorBackground4;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self.contentView addSubview:({
        SSThemedView *topSeparatorView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 1.f)];
        topSeparatorView.backgroundColorThemeKey = kColorLine1;
        topSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        topSeparatorView;
    })];
    [self.contentView addSubview:self.separatorView];
    [self.contentView addSubview:self.descLabel];
    [self.contentView addSubview:({
        SSThemedButton *maskButton = [[SSThemedButton alloc] initWithFrame:self.contentView.bounds];
        maskButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [maskButton addTarget:self action:@selector(descButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        maskButton;
    })];
}

- (void)descButtonOnClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(commentFooterCell:onClickForType:)]) {
        [self.delegate commentFooterCell:self onClickForType:self.type];
    }
}

+ (CGFloat)cellHeight {
    return [TTDeviceUIUtils tt_newPadding:82.f];
}

- (void)themeChanged:(NSNotification *)notification {
    self.type = self.type;
}

- (void)setType:(TTCommentFooterCellType)type {
    _type = type;
    switch (type) {
        case TTCommentFooterCellTypeFold: {
            self.descLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]];
            self.descLabel.textColorThemeKey = kColorText1;
            [self.descLabel setAttributedText:({
                NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:@"查看折叠评论" attributes:@{NSFontAttributeName:  [UIFont systemFontOfSize:[TTCommentUIHelper tt_sizeWithFontSetting:[TTDeviceUIUtils tt_newFontSize:14.f]]], NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText1]}];
                [attrTitle appendAttributedString:({
                                NSAttributedString *attrArrow = [[NSAttributedString alloc]
                                    initWithString:[NSString stringWithFormat:@"%@", ask_arrow_right]
                                        attributes:@{
                                            NSBaselineOffsetAttributeName : @(1.5),
                                            NSFontAttributeName : [UIFont fontWithName:iconfont size:[TTCommentUIHelper tt_sizeWithFontSetting:10.f]],
                                            NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText1]
                                        }];
                                attrArrow;
                            })];
                attrTitle;
            })];
            [self.descLabel sizeToFit];
            self.descLabel.origin = CGPointMake([TTDeviceUIUtils tt_newPadding:60.f], self.separatorView.bottom + [TTDeviceUIUtils tt_newPadding:13.f]);
            self.separatorView.hidden = NO;
        }
            break;
        case TTCommentFooterCellTypeFoldLeft: {
            self.descLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]];
            self.descLabel.textColorThemeKey = kColorText1;
            [self.descLabel setAttributedText:({
                NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:@"查看折叠评论" attributes:@{NSFontAttributeName:  [UIFont systemFontOfSize:[TTCommentUIHelper tt_sizeWithFontSetting:[TTDeviceUIUtils tt_newFontSize:14.f]]], NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText1]}];
                [attrTitle appendAttributedString:({
                                NSAttributedString *attrArrow = [[NSAttributedString alloc]
                                    initWithString:[NSString stringWithFormat:@"%@", ask_arrow_right]
                                        attributes:@{
                                            NSBaselineOffsetAttributeName : @(1.5),
                                            NSFontAttributeName : [UIFont fontWithName:iconfont size:[TTCommentUIHelper tt_sizeWithFontSetting:10.f]],
                                            NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText1]
                                        }];
                                attrArrow;
                            })];
                attrTitle;
            })];
            [self.descLabel sizeToFit];
            self.descLabel.origin = CGPointMake([TTDeviceUIUtils tt_newPadding:15.f], [TTDeviceUIUtils tt_newPadding:13.f]);
            self.separatorView.hidden = YES;
        }
            break;
        case TTCommentFooterCellTypeNoMore: {
            self.descLabel.font = [UIFont systemFontOfSize:[TTCommentUIHelper tt_sizeWithFontSetting:[TTDeviceUIUtils tt_newFontSize:14.f]]];
            self.descLabel.textColorThemeKey = kColorText3;
            self.descLabel.text = @"已显示全部评论";
            [self.descLabel sizeToFit];
            self.descLabel.origin = CGPointMake([TTDeviceUIUtils tt_newPadding:60.f], self.separatorView.bottom + [TTDeviceUIUtils tt_newPadding:13.f]);
            self.separatorView.hidden = NO;
            break;
        }
        case TTCommentFooterCellTypeNone: {
            self.descLabel.text = @"";
            [self.descLabel sizeToFit];
            self.descLabel.origin = CGPointMake([TTDeviceUIUtils tt_newPadding:15.f], self.separatorView.bottom + [TTDeviceUIUtils tt_newPadding:13.f]);
        }
            break;
        default:
            break;
    }
}

- (SSThemedLabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
    }
    return _descLabel;
}

- (SSThemedView *)separatorView {
    if (!_separatorView) {
        _separatorView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _separatorView.size = CGSizeMake(self.width, [TTDeviceUIUtils tt_newPadding:22.f]);
        _separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _separatorView.backgroundColorThemeKey = kColorBackground4;
    }
    return _separatorView;
}

@end
