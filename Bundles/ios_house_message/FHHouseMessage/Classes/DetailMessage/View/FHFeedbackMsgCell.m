//
//  FHFeedbackMsgCell.m
//  FHHouseMessage
//
//  Created by bytedance on 2020/10/13.
//

#import "FHFeedbackMsgCell.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import <ByteDanceKit/ByteDanceKit.h>
#import <FHHouseBase/UIImage+FIconFont.h>

@interface FHFeedbackMsgActionView : UIControl

@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, copy) void (^pushActionBlock)(void);
@end

@implementation FHFeedbackMsgActionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.arrowImageView = [[UIImageView alloc] init];
        self.arrowImageView.image = [UIImage imageNamed:@"arrowicon-msseage"];
        [self addSubview:self.arrowImageView];
        [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self).offset(-15);
            make.centerY.mas_equalTo(self);
            make.width.mas_equalTo(18);
            make.height.mas_equalTo(18);
        }];

        self.topLine = [[UIView alloc] init];
        self.topLine.backgroundColor = [UIColor themeGray6];
        [self addSubview:self.topLine];
        [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
            make.height.mas_equalTo([UIDevice btd_onePixel]);
        }];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textColor = [UIColor themeGray1];
        self.titleLabel.font = [UIFont themeFontRegular:14];
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self);
            make.left.mas_equalTo(20);
        }];
        
        __weak typeof(self) weakSelf = self;
        [self btd_addActionBlock:^(__kindof UIControl * _Nonnull sender) {
            if (weakSelf.pushActionBlock) {
                weakSelf.pushActionBlock();
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

@end

@implementation FHFeedbackMsgCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundView.backgroundColor = [UIColor themeGray7];
        self.contentView.backgroundColor = [UIColor themeGray7];
        self.backgroundColor = [UIColor themeGray7];
        
        UIImage *cornerImage = [UIImage fh_roundRectMaskImageWithCornerRadius:10 color:[UIColor themeGray7] size:CGSizeMake(50, 50)];
        self.bgImageView = [[UIImageView alloc] initWithImage:[cornerImage resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)]];
        self.bgImageView.backgroundColor = [UIColor whiteColor];
        self.bgImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:self.bgImageView];
        [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 15, 0, 15));
        }];
        
        self.contentLabel = [[UILabel alloc] init];
        self.contentLabel.numberOfLines = 0;
        [self.bgImageView addSubview:self.contentLabel];
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.height.mas_equalTo(0);
        }];
        
        self.buttonStackView = [[UIStackView alloc] init];
        self.buttonStackView.axis = UILayoutConstraintAxisVertical;
        [self.bgImageView addSubview:self.buttonStackView];
        [self.buttonStackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.top.mas_equalTo(self.contentLabel.mas_bottom).mas_offset(10);
            make.height.mas_equalTo(0);
        }];
        
    }
    return self;
}

- (NSMutableArray *)buttonViews {
    if (!_buttonViews) {
        _buttonViews = [NSMutableArray array];
    }
    return _buttonViews;
}

- (void)updateWithModel:(FHHouseMsgDataItemsModel *)model {
    __weak typeof(self) weakSelf = self;
    [self.buttonStackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(model.buttonList.count * 44);
    }];
    CGFloat contentHeight = 0;
    if (model.content.length) {
        NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:model.content attributes:@{NSFontAttributeName : [UIFont themeFontRegular:14], NSForegroundColorAttributeName: [UIColor themeGray1]}];
        if (model.contentStyleList.count) {
            for (FHMsgDataItemReportContentStyleModel *styleModel in model.contentStyleList) {
                if (styleModel.start >= 0 && styleModel.start + styleModel.length < content.length) {
                    [content addAttributes:@{NSFontAttributeName: [UIFont themeFontSemibold:14], NSForegroundColorAttributeName : [UIColor colorWithHexString:styleModel.fontColor]} range:NSMakeRange(styleModel.start, styleModel.length)];
                }
            }
        }
        contentHeight = [content btd_heightWithWidth:UIScreen.mainScreen.bounds.size.width - 20 * 2 - 15 * 2];
        self.contentLabel.attributedText = content.copy;
    } else {
        self.contentLabel.attributedText = nil;
    }
    [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(contentHeight);
    }];
    
    [self.buttonViews addObjectsFromArray:self.buttonStackView.subviews];
    [self.buttonStackView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (FHMsgDataItemsReportButtonListModel *buttonListModel in model.buttonList) {
        FHFeedbackMsgActionView *buttonView = self.buttonViews.firstObject;
        if (buttonView) {
            [self.buttonViews removeObject:buttonView];
        } else {
            buttonView = [[FHFeedbackMsgActionView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width - 15 * 2, 44)];
            [buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(self.buttonStackView.mas_width);
                make.height.mas_equalTo(44);
            }];
        }
        buttonView.titleLabel.text = buttonListModel.name;
        [buttonView setPushActionBlock:^{
            if (buttonListModel.openUrl.length && weakSelf.pushURLBlock) {
                weakSelf.pushURLBlock(buttonListModel.openUrl);
            }
        }];
        [self.buttonStackView addArrangedSubview:buttonView];
    }
}
@end
