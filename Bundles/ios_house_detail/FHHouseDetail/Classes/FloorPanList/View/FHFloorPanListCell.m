//
//  FHFloorPanListCell.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/13.
//

#import "FHFloorPanListCell.h"
#import "FHDetailNewModel.h"
#import "FHDetailTagBackgroundView.h"
#import "FHCommonDefines.h"
#import <BDWebImage/BDWebImage.h>
#import <lottie-ios/Lottie/LOTAnimationView.h>

@interface FHFloorPanListCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *roomSpaceLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) FHDetailTagBackgroundView        *tagBacView;
@property (nonatomic, strong) UIButton *mapMaskBtn;
@property (nonatomic, strong) UIView *statusBGView;
@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIView *cellBackView;
@property (nonatomic, strong) LOTAnimationView *vrLoadingView;
@property (nonatomic, strong) UIView *vrBackView;

@end

@implementation FHFloorPanListCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.cellBackView];
        
        _topLine = [[UIView alloc] init];
        [self.contentView addSubview:_topLine];
        _topLine.backgroundColor =  RGB(0xe7, 0xe7, 0xe7);
        [self.topLine mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.mas_equalTo(34);
            make.right.mas_equalTo(-34);
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(0.5);
        }];
        
        _iconView = [UIImageView new];
        _iconView.image = [UIImage imageNamed:@"default_image"];
        _iconView.layer.borderColor = RGB(0xed, 0xed, 0xed).CGColor;
        _iconView.layer.borderWidth = 1;
        _iconView.layer.cornerRadius = 8;
        _iconView.layer.masksToBounds = YES;
        [self.contentView addSubview:_iconView];
        [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(31);
            make.top.mas_equalTo(20);
            make.bottom.mas_equalTo(-20);
            make.width.mas_equalTo(66);
            make.height.mas_equalTo(66);
        }];
        
        _vrBackView = [[UIView alloc] init];
        _vrBackView.layer.cornerRadius = 9;
        _vrBackView.layer.masksToBounds = YES;
        _vrBackView.backgroundColor = RGBA(0, 0, 0, 0.4);
        _vrBackView.hidden = YES;
        [self.contentView addSubview:_vrBackView];
        [self.vrBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.iconView.mas_left).offset(6);
            make.bottom.mas_equalTo(self.iconView.mas_bottom).offset(-6);
            make.width.height.mas_equalTo(18);
        }];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"VRImageLoading" ofType:@"json"];
        _vrLoadingView = [LOTAnimationView animationWithFilePath:path];
        _vrLoadingView.loopAnimation = YES;
        _vrLoadingView.hidden = YES;
        [self.contentView addSubview:_vrLoadingView];
        [self.vrLoadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.iconView.mas_left).offset(8);
            make.bottom.mas_equalTo(self.iconView.mas_bottom).offset(-8);
            make.height.width.mas_equalTo(14);
        }];
        
        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont themeFontSemibold:16];
        _nameLabel.textColor = RGB(0x4a, 0x4a, 0x4a);
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        [_nameLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_iconView.mas_right).offset(13);
            make.top.mas_equalTo(20);
            make.height.mas_equalTo(19);
        }];
        
        _priceLabel = [UILabel new];
        _priceLabel.font = [UIFont themeFontSemibold:16];
        _priceLabel.textColor = [UIColor themeOrange1];
        _priceLabel.textAlignment = NSTextAlignmentRight;
        [_priceLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:_priceLabel];
        [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-31);
            make.centerY.mas_equalTo(self.nameLabel.mas_centerY);
            make.height.mas_equalTo(19);
            make.left.mas_equalTo(self.nameLabel.mas_right);
        }];

        _roomSpaceLabel = [UILabel new];
        _roomSpaceLabel.font = [UIFont themeFontRegular:12];
        _roomSpaceLabel.textColor = [UIColor themeGray3];
        _roomSpaceLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_roomSpaceLabel];
        [_roomSpaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_nameLabel.mas_left);
            make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(8);
            make.right.mas_equalTo(-15);
            make.height.mas_equalTo(14);
        }];
        
        _tagBacView = [[FHDetailTagBackgroundView alloc] initWithLabelHeight:16.0 withCornerRadius:2.0];
        [_tagBacView setMarginWithTagMargin:4.0 withInsideMargin:4.0];
        _tagBacView.textFont = [UIFont themeFontMedium:10.0];
        [self.contentView addSubview:_tagBacView];
        [_tagBacView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_iconView.mas_right).offset(13);
            make.right.mas_equalTo(-31);
            make.height.mas_equalTo(16);
            make.bottom.mas_equalTo(_iconView);
        }];
        
        [self.cellBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
            make.top.bottom.mas_equalTo(0);
        }];
    }
    return self;
}

- (UIView *)cellBackView
{
    if (!_cellBackView) {
        UIView *cellBackView = [[UIView alloc] init];
        cellBackView.backgroundColor = [UIColor whiteColor];
         cellBackView.hidden = YES;
        _cellBackView = cellBackView;
    }
    return _cellBackView;
}

-(CAShapeLayer *)maskLayer:(UIRectCorner)rectCorner
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-30, 106) byRoundingCorners:rectCorner cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-30, 106);
    maskLayer.path = maskPath.CGPath;
    return maskLayer;
}

- (void)refreshWithData:(bool)isFirst andLast:(BOOL)isLast
{
    self.cellBackView.hidden = NO;
    if (isFirst && isLast) {
        self.cellBackView.layer.mask = [self maskLayer:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight];
    } else if (isFirst) {
        self.cellBackView.layer.mask = [self maskLayer:UIRectCornerTopLeft | UIRectCornerTopRight];
    } else if (isLast) {
         self.cellBackView.layer.mask = [self maskLayer:UIRectCornerBottomLeft | UIRectCornerBottomRight];
    } else {
        self.cellBackView.layer.mask = nil;
    }
    if (isFirst) {
        self.topLine.hidden = YES;
    } else {
        self.topLine.hidden = NO;
    }
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[FHDetailNewDataFloorpanListListModel class]]) {
        [self.tagBacView removeAllTag];
        FHDetailNewDataFloorpanListListModel *model = (FHDetailNewDataFloorpanListListModel*)data;
        self.nameLabel.text = model.title;
        if ([model.squaremeter isKindOfClass:[NSString class]]) {
            if (model.squaremeter.length > 0) {
                NSString *roomSpace = [NSString stringWithFormat:@"建面 %@",model.squaremeter];
                if (model.facingDirection.length > 0) {
                    self.roomSpaceLabel.text = [NSString stringWithFormat:@"%@ | %@", roomSpace, model.facingDirection];
                } else {
                    self.roomSpaceLabel.text = roomSpace;
                }
            } else if (model.facingDirection.length > 0) {
                self.roomSpaceLabel.text = model.facingDirection;
            } else {
                self.roomSpaceLabel.text = @"";
            }
        }else
        {
            self.roomSpaceLabel.text = @"";
        }
        NSString *pricing = model.pricing;
        self.priceLabel.text = pricing;
        if (model.displayPrice.length > 0) {
            NSString *displayPrice = model.displayPrice;
            self.priceLabel.text = displayPrice;
//            NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:self.priceLabel.text];
//            NSRange range = [displayPrice rangeOfString:pricing];
//
//            if (range.location != NSNotFound) {
//                [noteStr addAttribute:NSFontAttributeName value:[UIFont themeFontSemibold:16] range:range];
//            }
//            self.priceLabel.attributedText = noteStr;
        }
    
        if ([model.images.firstObject isKindOfClass:[FHImageModel class]]) {
            FHImageModel *imageModel = (FHImageModel *)model.images.firstObject;
            if (imageModel.url) {
                NSURL *urlImage = [NSURL URLWithString:imageModel.url];
                WeakSelf;
                [[BDWebImageManager sharedManager] requestImage:urlImage options:BDImageRequestHighPriority complete:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
                    StrongSelf;
                    if (!error && image) {
                        self.iconView.image = image;
                        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
                    }
                }];
            }
        }
        if (model.tags.count) {
            self.tagBacView.hidden = NO;
            [self.tagBacView refreshWithTags:model.tags withNum:model.tags.count withMaxLen:SCREEN_WIDTH - 31 - 66 - 13 - 31];
            [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(20);
            }];
        } else {
            self.tagBacView.hidden = YES;
            [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(20 + 12);
            }];
        }
        if (model.vrInfo.hasVr) {
            self.vrBackView.hidden = NO;
            self.vrLoadingView.hidden = NO;
            [self.vrLoadingView play];
        } else {
            self.vrBackView.hidden = YES;
            self.vrLoadingView.hidden = YES;
        }

    }
    [self layoutIfNeeded];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
