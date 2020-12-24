//
//  FHHouseListRecommendTipCell.m
//  FHHouseList
//
//  Created by 张静 on 2019/11/12.
//

#import "FHHouseListRecommendTipCell.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import <FHHouseBase/FHSearchHouseModel.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import "NSAttributedString+YYText.h"
#import "YYLabel.h"
#import "TTroute.h"
#import <ByteDanceKit/ByteDanceKit.h>

@interface FHHouseListRecommendTipCell ()

@property (nonatomic, strong) YYLabel *noDataTipLabel;
@property (nonatomic, strong) UIView *leftLine;
@property (nonatomic, strong) UIView *rightLine;

@end

@implementation FHHouseListRecommendTipCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.noDataTipLabel = [[YYLabel alloc] init];
        [self.contentView addSubview:self.noDataTipLabel];
        [self.contentView addSubview:self.leftLine];
        [self.contentView addSubview:self.rightLine];
        [self.contentView addSubview:self.errorView];
//        [self initConstraints];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[FHSearchGuessYouWantTipsModel class]]) {
        FHSearchGuessYouWantTipsModel *model = (FHSearchGuessYouWantTipsModel *)data;
        if(model.content){
            model.text = model.content;
        }
        NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:model.text];
        NSDictionary *commonTextStyle = @{ NSFontAttributeName:[UIFont themeFontRegular:14],NSForegroundColorAttributeName:[UIColor themeGray3]};
        [attrText addAttributes:commonTextStyle range:NSMakeRange(0, attrText.length)];
        [attrText yy_setAlignment:NSTextAlignmentCenter range:NSMakeRange(0, attrText.length)];
        if(model.content){
            NSRange tapRange = [attrText.string rangeOfString:model.emphasisContent];
            __weak typeof(self) wself = self;
            [attrText yy_setTextHighlightRange:tapRange color:[UIColor colorWithHexStr:@"#fe5500"] backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                __strong typeof(wself) self = wself;
                if(self.channelSwitchBlock){
                    self.channelSwitchBlock();
                }
            }];
        }
        self.noDataTipLabel.attributedText = attrText;
        [self.noDataTipLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView);
            make.bottom.mas_equalTo(-15);
            make.height.mas_equalTo(20);
            make.width.mas_equalTo([model.text btd_widthWithFont:[UIFont themeFontRegular:14] height:20]);
        }];
        [self initConstraints];
    }
}

+ (CGFloat)heightForData:(id)data
{
    return 50;
}

+ (CGFloat)heightForData:(id)data withIsFirst:(BOOL)isFirst {
    if (isFirst) {
        return 55;
    }
    return 50;
}

- (void)initConstraints {
    [self.leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.noDataTipLabel);
        make.left.mas_equalTo(15);
        make.height.mas_equalTo(1);
        make.right.mas_equalTo(self.noDataTipLabel.mas_left).offset(-10);
    }];
    [self.rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.noDataTipLabel);
        make.left.mas_equalTo(self.noDataTipLabel.mas_right).offset(10);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(1);
    }];
    [self.errorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(60);
        make.bottom.left.right.mas_equalTo(self.contentView);
    }];
    self.errorView.backgroundColor = [UIColor clearColor];
    self.errorView.hidden = YES;
}

- (void)showErrorView{
    [self.errorView showEmptyWithType:FHEmptyMaskViewTypeNoDataForCondition];
}

- (UIView *)leftLine
{
    if (!_leftLine) {
        _leftLine = [[UIView alloc]init];
        _leftLine.backgroundColor = [UIColor themeGray6];
    }
    return _leftLine;
}

- (UIView *)rightLine
{
    if (!_rightLine) {
        _rightLine = [[UIView alloc]init];
        _rightLine.backgroundColor = [UIColor themeGray6];
    }
    return _rightLine;
}

- (FHErrorView *)errorView
{
    if(!_errorView){
        _errorView = [[FHErrorView alloc ] init];
    }
    return  _errorView;
}
@end
