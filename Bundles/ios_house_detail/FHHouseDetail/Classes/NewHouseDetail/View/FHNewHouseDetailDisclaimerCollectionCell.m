//
//  FHNewHouseDetailDisclaimerCollectionCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/9.
//

#import "FHNewHouseDetailDisclaimerCollectionCell.h"
#import "YYText.h"
#import "TTPhotoScrollViewController.h"
#import <ByteDanceKit/NSString+BTDAdditions.h>

@interface FHNewHouseDetailDisclaimerCollectionCell ()

@property (nonatomic, strong)   UILabel       *ownerLabel;
@property (nonatomic, strong)   UIButton       *tapButton;
@property (nonatomic, strong)   UIButton       *contactIcon;
@property (nonatomic, strong)   YYLabel       *disclaimerContent;
@property (nonatomic, strong)   NSArray       *headerImages;
@property (nonatomic, strong)   NSArray       *imageTitles;
@end

@implementation FHNewHouseDetailDisclaimerCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupUI];
    }
    return self;
}

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (![data isKindOfClass:[FHNewHouseDetailDisclaimerModel class]]) {
        return CGSizeZero;
    }
    FHNewHouseDetailDisclaimerModel *model = (FHNewHouseDetailDisclaimerModel *)data;
    CGFloat height = 0;
    if (model.disclaimer && model.disclaimer.text.length > 0) {
        height += [model.disclaimer.text btd_heightWithFont:[UIFont themeFontRegular:12] width:width];
        height += 25;
    }
    if (model.contact.realtorName.length > 0 || model.contact.agencyName.length > 0) {
        height += 14 + 2;
    }
    return CGSizeMake(width, height);
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHNewHouseDetailDisclaimerModel class]]) {
        return;
    }
    self.currentData = data;
    FHNewHouseDetailDisclaimerModel *model = (FHNewHouseDetailDisclaimerModel *)data;
    if (model.disclaimer && model.disclaimer.text.length > 0) {
        NSString *text = model.disclaimer.text;
        NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text];
        NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontRegular:12],NSForegroundColorAttributeName:[UIColor themeGray4]};
        [attrText addAttributes:attr range:NSMakeRange(0, attrText.length)];
        __weak typeof(self)wSelf = self;
        [model.disclaimer.richText enumerateObjectsUsingBlock:^(FHDisclaimerModelDisclaimerRichTextModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = [self rangeOfArray:obj.highlightRange originalLength:text.length];
            UIColor *color = [UIColor themeOrange1];
            __weak typeof(FHDisclaimerModelDisclaimerRichTextModel *) wObj = obj;
            [attrText yy_setTextHighlightRange:range color:color backgroundColor:nil userInfo:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                if (wObj.linkUrl.length > 0) {
                    if (wSelf.clickFeedback) {
                        wSelf.clickFeedback();
                    }
                    NSURL *url = [NSURL URLWithString:wObj.linkUrl];
                    [[TTRoute sharedRoute] openURLByPushViewController:url];
                }
            } longPressAction:nil];
        }];
        self.disclaimerContent.numberOfLines = 0;
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
            NSMutableArray *imageTitles = [NSMutableArray new];
            if (model.contact.businessLicense.length > 0) {
                FHImageModel *imageModel = [[FHImageModel alloc] init];
                imageModel.url = model.contact.businessLicense;
                [imageTitles addObject:@"营业执照"];
                [headerImages addObject:imageModel];
            }
            if (model.contact.certificate.length > 0) {
                FHImageModel *imageModel = [[FHImageModel alloc] init];
                imageModel.url = model.contact.certificate;
                [imageTitles addObject:@"从业人员信息卡"];
                [headerImages addObject:imageModel];
            }
            if (headerImages.count > 0) {
                self.headerImages = headerImages.copy;
                self.imageTitles = imageTitles.copy;
                self.contactIcon.hidden = NO;
                [self.contactIcon mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_lessThanOrEqualTo(-15);
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

- (void)setupUI {
    _ownerLabel = [UILabel createLabel:@"" textColor:@"" fontSize:10];
    _ownerLabel.textColor = [UIColor themeGray1];
    [self.contentView addSubview:_ownerLabel];
    
    _tapButton = [[UIButton alloc] init];
    [self.contentView addSubview:_tapButton];
    
    _contactIcon = [[UIButton alloc] init];
    [_contactIcon setImage:[UIImage imageNamed:@"contact"] forState:UIControlStateNormal];
    [self.contentView addSubview:_contactIcon];
    
    _disclaimerContent = [[YYLabel alloc] init];
    _disclaimerContent.numberOfLines = 0;
    _disclaimerContent.textColor = [UIColor themeGray4];
    _disclaimerContent.font = [UIFont themeFontRegular:12];
    _disclaimerContent.preferredMaxLayoutWidth = self.frame.size.width;

    [self.contentView addSubview:_disclaimerContent];
    
    [self.ownerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(14);
        make.right.mas_equalTo(self.contactIcon.mas_left).offset(-6);
    }];
    
    [self.contactIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_lessThanOrEqualTo(0);
        make.centerY.mas_equalTo(self.ownerLabel);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(14);
    }];
    
    self.contactIcon.userInteractionEnabled = NO;
    
    [self.tapButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(self.ownerLabel);
        make.bottom.mas_equalTo(self.contactIcon);
        make.right.mas_equalTo(self.contactIcon).offset(10);
    }];
    
    [self.disclaimerContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.ownerLabel.mas_bottom).offset(10);
    }];
    
    [self.tapButton addTarget:self action:@selector(openPhoto:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)openPhoto:(UIButton *)button {
    [self showImages:self.headerImages.copy currentIndex:0];
}

-(void)showImages:(NSArray<FHDetailPhotoHeaderModelProtocol>*)images currentIndex:(NSInteger)index
{
    if (images.count == 0) {
        return;
    }
    if (images.count != self.imageTitles.count) {
        return;
    }
    
    TTPhotoScrollViewController *vc = [[TTPhotoScrollViewController alloc] init];
    vc.dragToCloseDisabled = YES;
    vc.mode = PhotosScrollViewSupportBrowse;
    vc.startWithIndex = index;
    vc.imageTitles = self.imageTitles;
    
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
    NSMutableArray *placeholders = [[NSMutableArray alloc] initWithCapacity:images.count];
    for (NSInteger i = 0 ; i < images.count; i++) {
        [placeholders addObject:placeholder];
    }
    vc.placeholders = placeholders;
    [vc presentPhotoScrollView];
}

- (void)hiddenOwnerLabel {
    self.ownerLabel.hidden = YES;
    self.contactIcon.hidden = YES;
    [self.disclaimerContent mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.contentView);
         make.bottom.mas_equalTo(-25);
    }];
}

- (void)displayOwnerLabel {
    self.ownerLabel.hidden = NO;
    self.contactIcon.hidden = NO;
    [self.disclaimerContent mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.ownerLabel.mas_bottom).offset(2);
        make.bottom.mas_equalTo(-25);
    }];
}

- (void)remakeConstraints {
    
    if ([self.disclaimerContent.attributedText length] > 0) {
        [self.disclaimerContent mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(-25);
        }];
        [self.contentView setNeedsLayout];
    }
}
@end

@implementation FHNewHouseDetailDisclaimerModel


@end
