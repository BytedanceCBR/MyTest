//
//  FHDetailDisclaimerCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/17.
//

#import "FHDetailDisclaimerCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "UILabel+House.h"
#import "FHDetailHeaderView.h"
#import <YYText.h>
#import <TTShareManager.h>
#import <TTPhotoScrollViewController.h>

@interface FHDetailDisclaimerCell ()

@property (nonatomic, strong)   UILabel       *ownerLabel;
@property (nonatomic, strong)   UIButton       *tapButton;
@property (nonatomic, strong)   UIButton       *contactIcon;
@property (nonatomic, strong)   YYLabel       *disclaimerContent;
@property (nonatomic, assign)   CGFloat       lineHeight;

@property (nonatomic, strong)   NSMutableArray       *headerImages;

@end

@implementation FHDetailDisclaimerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailDisclaimerModel class]]) {
        return;
    }
    self.currentData = data;
    //
    
    FHDetailDisclaimerModel *model = (FHDetailDisclaimerModel *)data;
    if (model.disclaimer && model.disclaimer.text.length > 0) {
        NSString *text = model.disclaimer.text;
        NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text];
        NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontRegular:12],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#a1aab3"]};
        [attrText addAttributes:attr range:NSMakeRange(0, attrText.length)];
        [model.disclaimer.richText enumerateObjectsUsingBlock:^(FHDisclaimerModelDisclaimerRichTextModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = [self rangeOfArray:obj.highlightRange originalLength:text.length];
            UIColor *color = [UIColor colorWithHexString:@"#299cff"];
            __weak typeof(FHDisclaimerModelDisclaimerRichTextModel *) wObj = obj;
            [attrText yy_setTextHighlightRange:range color:color backgroundColor:nil userInfo:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                if (wObj.linkUrl.length > 0) {
                    NSURL *url = [NSURL URLWithString:wObj.linkUrl];
                    [[TTRoute sharedRoute] openURLByPushViewController:url];
                }
            } longPressAction:nil];
        }];
        self.disclaimerContent.attributedText = attrText;
        [self remakeConstraints];
    }
    if (model.contact) {
        if (model.contact.realtorName.length > 0 || model.contact.agencyName.length > 0) {
            [self displayOwnerLabel];
            NSString *realtorName = model.contact.realtorName;
            NSString *agencyName = model.contact.agencyName;
            NSString *tempName = @"";
            if (realtorName.length > 0) {
                tempName = realtorName;
                if (agencyName.length > 0) {
                    tempName = [NSString stringWithFormat:@"%@ | %@",tempName,agencyName];
                }
            } else if (agencyName.length > 0) {
                tempName = agencyName;
            }
            self.ownerLabel.text = [NSString stringWithFormat:@"房源维护方：%@",tempName];
            NSMutableArray *headerImages = [NSMutableArray new];
            if (model.contact.businessLicense.length > 0) {
                FHDetailHouseDataItemsHouseImageModel *imageModel = [[FHDetailHouseDataItemsHouseImageModel alloc] init];
                imageModel.url = model.contact.businessLicense;
                // add by zyk 需要修改 name信息
                //                imageModel.name = @"营业执照"；
                [headerImages addObject:imageModel];
            }
            if (model.contact.certificate.length > 0) {
                FHDetailHouseDataItemsHouseImageModel *imageModel = [[FHDetailHouseDataItemsHouseImageModel alloc] init];
                imageModel.url = model.contact.certificate;
//                imageModel.name = @"从业人员信息卡"；
                [headerImages addObject:imageModel];
            }
            if (headerImages.count > 0) {
                self.headerImages = headerImages;
                self.contactIcon.hidden = NO;
                [self.contactIcon mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_lessThanOrEqualTo(-20);
                }];
            } else {
                self.contactIcon.hidden = YES;
                [self.contactIcon mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_lessThanOrEqualTo(10);
                }];
            }
        } else {
            [self hiddenOwnerLabel];
        }
    } else {
        [self hiddenOwnerLabel];
    }
    [self layoutIfNeeded];
}

- (NSRange)rangeOfArray:(NSArray *)range originalLength:(NSInteger)originalLength {
    if (![range isKindOfClass:[NSArray class]]) {
        return NSMakeRange(0, 0);
    }
    if (range.count == 2) {
        NSInteger arr1 = [range[0] integerValue];
        NSInteger arr2 = [range[1] integerValue];
        if (originalLength > arr1 && originalLength > arr2 && arr2 > arr1) {
            return NSMakeRange(arr1, arr2 - arr1);
        } else {
            return NSMakeRange(0, 0 );
        }
    }
    return NSMakeRange(0, 0 );
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _lineHeight = 0;
    self.contentView.backgroundColor = [UIColor colorWithHexString:@"#f2f4f5"];
    
    _ownerLabel = [UILabel createLabel:@"" textColor:@"#3d6e99" fontSize:14];
    [self.contentView addSubview:_ownerLabel];
    
    _tapButton = [[UIButton alloc] init];
    [self.contentView addSubview:_tapButton];
    
    _contactIcon = [[UIButton alloc] init];
    [_contactIcon setImage:[UIImage imageNamed:@"contact"] forState:UIControlStateNormal];
    [self.contentView addSubview:_contactIcon];
    
    _disclaimerContent = [[YYLabel alloc] init];
    _disclaimerContent.numberOfLines = 0;
    _disclaimerContent.textColor = [UIColor colorWithHexString:@"#a1aab3"];
    _disclaimerContent.font = [UIFont themeFontRegular:12];
    _disclaimerContent.backgroundColor = [UIColor colorWithHexString:@"#f4f5f6"];
    [self.contentView addSubview:_disclaimerContent];
    
    [self.ownerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(14);
        make.height.mas_equalTo(20);
        make.right.mas_equalTo(self.contactIcon.mas_left).offset(-10);
    }];
    
    [self.contactIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_lessThanOrEqualTo(-20);
        make.centerY.mas_equalTo(self.ownerLabel);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(13);
    }];
    
    self.contactIcon.userInteractionEnabled = NO;
    
    [self.tapButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(self.ownerLabel);
        make.bottom.mas_equalTo(self.contactIcon);
        make.right.mas_equalTo(self.contactIcon).offset(10);
    }];
    
    [self.disclaimerContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(self.ownerLabel.mas_bottom).offset(3);
        make.bottom.mas_equalTo(-14);
    }];
    
    [self.tapButton addTarget:self action:@selector(openPhoto:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)openPhoto:(UIButton *)button {
    [self showImages:self.headerImages currentIndex:0];
}

-(void)showImages:(NSArray<FHDetailPhotoHeaderModelProtocol>*)images currentIndex:(NSInteger)index
{
    if (images.count == 0) {
        return;
    }
    
    TTPhotoScrollViewController *vc = [[TTPhotoScrollViewController alloc] init];
    vc.dragToCloseDisabled = YES;
    vc.mode = PhotosScrollViewSupportBrowse;
    vc.startWithIndex = index;
    
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:images.count];
    for(id<FHDetailPhotoHeaderModelProtocol> imgModel in images)
    {
        NSMutableDictionary *dict = [[imgModel toDictionary] mutableCopy];
        //change url_list from string array to dict array
        NSMutableArray *dictUrlList = [[NSMutableArray alloc] initWithCapacity:imgModel.urlList.count];
        for (NSString * url in imgModel.urlList) {
            if ([url isKindOfClass:[NSString class]]) {
                [dictUrlList addObject:@{@"url":url}];
            }else{
                [dictUrlList addObject:url];
            }
        }
        // 兼容租房逻辑
        if (dictUrlList.count == 0) {
            NSString *url = dict[@"url"];
            if (url.length > 0) {
                [dictUrlList addObject:@{@"url":url}];
            }
        }
        dict[@"url_list"] = dictUrlList;
        
        TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:dict];
        model.imageType = TTImageTypeLarge;
        if (model) {
            [models addObject:model];
        }
    }
    vc.imageInfosModels = models;
    
    UIImage *placeholder = [UIImage imageNamed:@"default_image"];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGRect frame = [self convertRect:self.bounds toView:window];
    NSMutableArray *frames = [[NSMutableArray alloc] initWithCapacity:index+1];
    NSMutableArray *placeholders = [[NSMutableArray alloc] initWithCapacity:images.count];
    for (NSInteger i = 0 ; i < index ; i++) {
        [frames addObject:[NSNull null]];
    }
    for (NSInteger i = 0 ; i < images.count; i++) {
        [placeholders addObject:placeholder];
    }
    
    NSValue *frameValue = [NSValue valueWithCGRect:frame];
    [frames addObject:frameValue];
    vc.placeholderSourceViewFrames = frames;
    vc.placeholders = placeholders;
    [vc presentPhotoScrollView];
}

- (void)hiddenOwnerLabel {
    self.ownerLabel.hidden = YES;
    self.contactIcon.hidden = YES;
    [self.disclaimerContent mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(14);
        make.height.mas_equalTo(self.lineHeight);
        make.bottom.mas_equalTo(-14);
    }];
}

- (void)displayOwnerLabel {
    self.ownerLabel.hidden = NO;
    self.contactIcon.hidden = NO;
    [self.disclaimerContent mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(self.ownerLabel.mas_bottom).offset(3);
        make.height.mas_equalTo(self.lineHeight);
        make.bottom.mas_equalTo(-14);
    }];
}

- (void)remakeConstraints {
    
    if ([self.disclaimerContent.attributedText length] > 0) {
        CGSize size = CGSizeMake(UIScreen.mainScreen.bounds.size.width - 40, MAXFLOAT);
        YYTextLayout *tagLayout = [YYTextLayout layoutWithContainerSize:size text:self.disclaimerContent.attributedText];
        if (tagLayout) {
            self.lineHeight = tagLayout.textBoundingSize.height;
        } else {
            self.lineHeight = 0;
        }
        [self.disclaimerContent mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.top.mas_equalTo(self.ownerLabel.mas_bottom).offset(3);
            make.bottom.mas_equalTo(-14);
            make.height.mas_equalTo(self.lineHeight);
        }];
        [self.contentView setNeedsLayout];
    }
}

@end

// FHDetailDisclaimerModel
@implementation FHDetailDisclaimerModel


@end
