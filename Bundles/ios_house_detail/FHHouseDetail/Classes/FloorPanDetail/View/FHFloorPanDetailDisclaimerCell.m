//
//  FHFloorPanDetailDisclaimerCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/4/12.
//

#import "FHFloorPanDetailDisclaimerCell.h"
#import "YYText.h"
#import "UILabel+House.h"
#import "FHCommonDefines.h"
#import "TTPhotoScrollViewController.h"

@interface FHFloorPanDetailDisclaimerCell ()

@property (nonatomic, strong)   UILabel       *ownerLabel;
@property (nonatomic, strong)   UIButton       *tapButton;
@property (nonatomic, strong)   UIButton       *contactIcon;
@property (nonatomic, strong)   YYLabel       *disclaimerContent;
@property (nonatomic, assign)   CGFloat       lineHeight;

@property (nonatomic, strong)   NSMutableArray       *headerImages;
@property (nonatomic, strong)   NSMutableArray       *imageTitles;


@end

@implementation FHFloorPanDetailDisclaimerCell



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
//    self.contentView.backgroundColor = [UIColor colorWithHexStr:@"#FFFEFE"];
    
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
    _disclaimerContent.preferredMaxLayoutWidth = SCREEN_WIDTH-30;

    [self.contentView addSubview:_disclaimerContent];
    
    [self.ownerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(14);
        make.right.mas_equalTo(self.contactIcon.mas_left).offset(-6);
    }];
    
    [self.contactIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_lessThanOrEqualTo(-15);
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
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.ownerLabel.mas_bottom).offset(10);
//        make.bottom.mas_equalTo(-40);
    }];
    
}

@end
