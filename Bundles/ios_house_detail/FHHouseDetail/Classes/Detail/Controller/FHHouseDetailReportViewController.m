//
//  FHHouseDetailReportViewController.m
//  FHHouseDetail
//
//  Created by wangzhizhou on 2020/10/10.
//

#import "FHHouseDetailReportViewController.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <ByteDanceKit/ByteDanceKit.h>
#import <ios_house_im/FHIMSafeAreasGuide.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <objc/runtime.h>
#import <FHHouseBase/FHCommonDefines.h>
#import <TTAccountSDK/TTAccountUserEntity.h>
#import <TTAccountSDK/TTAccount.h>
#import "FHMainApi.h"
#import <ios_house_im/UIView+Utils.h>
#import "UIImage+FIconFont.h"
#import "ToastManager.h"
#import "TTReachability.h"
#import "FHEnvContext.h"
#import "FHGeneralBizConfig.h"
#import "UIViewController+HUD.h"
#import "FHHouseDetailReportAddtionViewController.h"
#import "FHIMConfigManager.h"
#import "FHUserTracker.h"

typedef NS_ENUM(NSUInteger, FHHouseDetailReportItemType) {
    FHHouseDetailReportItemType_Type,
    FHHouseDetailReportItemType_Phone,
    FHHouseDetailReportItemType_Extra,
};

#define kFHHouseDetailReportPhoneNumberStatusNotification @"kFHHouseDetailReportPhoneNumberStatusNotification"

#define FHHouseDetailReportItemPhoneNumberDigitCount 11

@interface FHHouseDetailReportOption: NSObject
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) BOOL isSelected;

+ (instancetype)optionWithContent:(NSString *)content;
@end

@implementation FHHouseDetailReportOption
+ (instancetype)optionWithContent:(NSString *)content {
    FHHouseDetailReportOption *option = [FHHouseDetailReportOption new];
    option.content = content;
    return option;
}
@end

@interface FHHouseDetailReportItem : NSObject
@property (nonatomic, assign) FHHouseDetailReportItemType type;
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, strong) NSArray<FHHouseDetailReportOption *> *options;
@property (nonatomic, strong) FHHouseDetailReportOption *selectedOption;
@property (nonatomic, copy)   NSString *phoneNumber;
@property (nonatomic, copy)   NSString * extraContent;
@property (nonatomic, assign) CGFloat  height;
@property (nonatomic, assign) BOOL isValid;
@end

@implementation FHHouseDetailReportItem
@end

@interface FHHouseDetailReportOptionView : UIView
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) UIImageView *selectedIconImageView;
@property (nonatomic, strong) UILabel *contentLabel;
@end
@implementation FHHouseDetailReportOptionView
-(UIImageView *)selectedIconImageView {
    if(!_selectedIconImageView) {
        _selectedIconImageView = [UIImageView new];
        _selectedIconImageView.userInteractionEnabled = NO;
    }
    return _selectedIconImageView;
}
- (UILabel *)contentLabel {
    if(!_contentLabel) {
        _contentLabel = [UILabel new];
        _contentLabel.textColor = [UIColor themeGray1];
        _contentLabel.font = [UIFont themeFontRegular:14];
        _contentLabel.numberOfLines = 2;
    }
    return _contentLabel;
}
- (instancetype)init {
    if(self = [super init]) {
        [self addSubview:self.selectedIconImageView];
        [self addSubview:self.contentLabel];
        
        [self.selectedIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(15);
            make.width.height.mas_equalTo(16);
        }];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self.selectedIconImageView.mas_right).offset(10);
            make.top.bottom.equalTo(self);
            make.right.equalTo(self).offset(-15);
        }];
        
        self.isSelected = NO;
        
    }
    return self;
}
- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    
    if(isSelected) {
        self.selectedIconImageView.image = [UIImage imageNamed:@"detail_report_option_selected"];
    } else {
        self.selectedIconImageView.image = [UIImage imageNamed:@"detail_report_option_unselected"];
    }
}

@end

@interface FHHouseDetailReportBaseCell : UITableViewCell
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView  *contentArea;
@property (nonatomic, strong) FHHouseDetailReportItem *item;
@property (nonatomic, strong) NSIndexPath *indexPath;
@end

@implementation FHHouseDetailReportBaseCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.container];
        [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(10);
            make.left.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView).offset(-15);
            make.bottom.equalTo(self.contentView);
        }];
        
        [self.container addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.container).offset(20);
            make.left.equalTo(self.container).offset(15);
            make.right.equalTo(self.container).offset(-15);
        }];
        
        [self.container addSubview:self.contentArea];
        [self.contentArea mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
            make.left.right.equalTo(self.titleLabel);
            make.bottom.equalTo(self.container).offset(-20);
        }];
    }
    return self;
}
- (UIView *)container {
    if(!_container) {
        _container = [UIView new];
        _container.layer.cornerRadius = 10;
        _container.layer.masksToBounds = YES;
        _container.backgroundColor = [UIColor themeWhite];
    }
    return _container;
}
- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont themeFontMedium:16];
        _titleLabel.textColor = [UIColor themeGray1];
    }
    return _titleLabel;
}

-(UIView *)contentArea {
    if(!_contentArea) {
        _contentArea = [UIView new];
    }
    return _contentArea;
}

- (void)setItem:(FHHouseDetailReportItem *)item {
    if(_item != item) {
        _item = item;
        self.titleLabel.text = item.title;
        
        if(item.type == FHHouseDetailReportItemType_Phone) {
            [self showMustRequiredTitle:YES text:@"（必填）"];
        } else if(item.type == FHHouseDetailReportItemType_Type) {
            [self showMustRequiredTitle:YES text:@"（必选）"];
        }
    }
}

- (void)showMustRequiredTitle:(BOOL)isRequired text:(NSString *)showText {
    NSString *requiredText = showText;
    if(isRequired) {
        if(![self.titleLabel.text containsString:requiredText]) {
            NSAttributedString *requiredAttributeText = [[NSAttributedString alloc] initWithString:requiredText attributes:@{
                NSForegroundColorAttributeName: [UIColor themeGray3],
                NSFontAttributeName: self.titleLabel.font
            }];
            NSMutableAttributedString *titleAttributeText = [[NSMutableAttributedString alloc] initWithString:self.titleLabel.text attributes:@{
                NSForegroundColorAttributeName: self.titleLabel.textColor,
                NSFontAttributeName: self.titleLabel.font
            }];
            [titleAttributeText appendAttributedString:requiredAttributeText];
            self.titleLabel.attributedText = titleAttributeText;
        }
    } else {
        if([self.titleLabel.text containsString:requiredText]) {
            NSString *title = [self.titleLabel.text stringByReplacingOccurrencesOfString:requiredText withString:@""];
            NSMutableAttributedString *titleAttributeText = [[NSMutableAttributedString alloc] initWithString:title attributes:@{
                NSForegroundColorAttributeName: self.titleLabel.textColor,
                NSFontAttributeName: self.titleLabel.font
            }];
            self.titleLabel.attributedText = titleAttributeText;
        }
    }
}
@end

@interface FHHouseDetailReportTypeCell: FHHouseDetailReportBaseCell
@property (nonatomic, strong) NSArray<FHHouseDetailReportOptionView *> *optionViews;
@end

@implementation FHHouseDetailReportTypeCell
- (void)setItem:(FHHouseDetailReportItem *)item {
    [super setItem:item];
    
    // 布局
    [self layoutOptions];
}
- (void)removeAllViews {
    [self.contentArea btd_removeAllSubviews];
    self.optionViews = nil;
}
- (void)layoutOptions {
    [self removeAllViews];
    
    [self.contentArea mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.container);
    }];
    
    __block UIView *lastOptionView = nil;
    @weakify(self);
    self.optionViews = [self.item.options btd_map:^id _Nullable(FHHouseDetailReportOption * _Nonnull option) {
        @strongify(self);
        FHHouseDetailReportOptionView *optionView = [[FHHouseDetailReportOptionView alloc] init];
        optionView.contentLabel.text = option.content;
        optionView.isSelected = option.isSelected;
        
        [self.contentArea addSubview:optionView];
        
        [optionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentArea);
            if(lastOptionView == nil) {
                make.top.equalTo(self.contentArea);
            } else {
                make.top.equalTo(lastOptionView.mas_bottom);
            }
            make.height.mas_equalTo(40);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectOption:)];
        [optionView addGestureRecognizer:tap];
        
        lastOptionView = optionView;
        
        return optionView;
    }];
}

-(void)selectOption:(UITapGestureRecognizer *)tap {
    @weakify(self);
    self.item.selectedOption = nil;
    self.item.isValid = NO;
    [self.optionViews enumerateObjectsUsingBlock:^(FHHouseDetailReportOptionView * _Nonnull optionView, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        optionView.isSelected = (optionView == tap.view);
        self.item.options[idx].isSelected = optionView.isSelected;
        if(self.item.options[idx].isSelected) {
            self.item.selectedOption = self.item.options[idx];
            self.item.isValid = YES;
        }
    }];
}
@end

@implementation FHHouseDetailReportPhoneNumberInvalidTextField
- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.size.width - 94, (bounds.size.height - 40) /2.0, 94, 40);
}
@end

@interface FHHouseDetailReportPhoneNumberCell: FHHouseDetailReportBaseCell<UITextFieldDelegate>
@property (nonatomic, strong) FHHouseDetailReportPhoneNumberInvalidTextField *phoneTextField;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UILabel *textViewRightLabel;
@end

@implementation FHHouseDetailReportPhoneNumberCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentArea addSubview:self.phoneTextField];
        [self.contentArea addSubview:self.hintLabel];
        
        [self.phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentArea).offset(10);
            make.left.right.equalTo(self.contentArea);
            make.height.mas_offset(40);
        }];
        
        [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.contentArea);
            make.top.equalTo(self.phoneTextField.mas_bottom).offset(10);
            make.height.mas_equalTo([self.hintLabel.text btd_sizeWithFont:self.hintLabel.font width:SCREEN_WIDTH - 60].height);
        }];
        
        @weakify(self);
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kFHHouseDetailReportPhoneNumberStatusNotification object:nil] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
            @strongify(self);
            [self updatePhoneNumberHint:@"手机号格式错误" isShow:YES];
        }];
    }
    return self;
}

- (UILabel *)textViewRightLabel {
    if(!_textViewRightLabel) {
        _textViewRightLabel = [UILabel new];
        _textViewRightLabel.font = [UIFont themeFontLight:12];
        _textViewRightLabel.textColor = [UIColor redColor];
        _textViewRightLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _textViewRightLabel;
}
- (void)updatePhoneNumberHint:(NSString *)hint isShow:(BOOL)show {
    self.textViewRightLabel.text = show ? hint : @"";
    self.phoneTextField.textColor = show ? self.textViewRightLabel.textColor : [UIColor themeGray1];
}

- (FHHouseDetailReportPhoneNumberInvalidTextField *)phoneTextField {
    if(!_phoneTextField) {
        _phoneTextField = [FHHouseDetailReportPhoneNumberInvalidTextField new];
        _phoneTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"手机号" attributes:@{
            NSForegroundColorAttributeName: [UIColor themeGray4],
            NSFontAttributeName: [UIFont themeFontRegular:12],
        }];
        _phoneTextField.textColor = [UIColor themeGray1];
        _phoneTextField.font = [UIFont themeFontRegular:14];
        _phoneTextField.backgroundColor = [UIColor themeGray7];
        _phoneTextField.layer.cornerRadius = 4;
        _phoneTextField.layer.masksToBounds = YES;
        _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
        _phoneTextField.leftViewMode = UITextFieldViewModeAlways;
        _phoneTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
        _phoneTextField.delegate = self;
        _phoneTextField.rightView = self.textViewRightLabel;
        _phoneTextField.rightViewMode = UITextFieldViewModeAlways;
        
        NSUInteger validPhoneNumberDigitCount = FHHouseDetailReportItemPhoneNumberDigitCount;
        @weakify(self);
        [[[_phoneTextField.rac_textSignal deliverOnMainThread] distinctUntilChanged] subscribeNext:^(NSString * _Nullable x) {
            @strongify(self);
            [self updatePhoneNumberHint:nil isShow:NO];
            if(x.length > validPhoneNumberDigitCount) {
                x = [x substringWithRange:NSMakeRange(0, validPhoneNumberDigitCount)];
                self.phoneTextField.text = x;
            }
            if(![x containsString:@"*"]) {
                self.item.phoneNumber = x;
            }
            self.item.isValid = (self.item.phoneNumber.length == validPhoneNumberDigitCount);
        }];
    }
    return _phoneTextField;
}

- (UILabel *)hintLabel {
    if(!_hintLabel) {
        _hintLabel = [UILabel new];
        _hintLabel.font = [UIFont themeFontRegular:12];
        _hintLabel.textColor = [UIColor themeGray4];
        _hintLabel.text = @"工作人员将联系您确认房源情况，请保持手机畅通～";
        _hintLabel.numberOfLines = 0;
    }
    return _hintLabel;
}

- (void)setItem:(FHHouseDetailReportItem *)item {
    [super setItem: item];
    
    self.phoneTextField.text = [self maskPhoneNumber];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.phoneTextField.text = self.item.phoneNumber;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *replacedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return ![string isEqualToString:@"\n"] && replacedString.length <= FHHouseDetailReportItemPhoneNumberDigitCount;
}

- (NSString *)maskPhoneNumber {
    NSString *ret;
    if(self.item && self.item.phoneNumber.length == 11) {
        self.item.isValid = YES;
        ret = [self.item.phoneNumber stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    }
    return ret;
}
@end

@interface FHHouseDetailReportExtraCell: FHHouseDetailReportBaseCell
@property (nonatomic, strong) UITextView *textView;
@end

@implementation FHHouseDetailReportExtraCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentArea addSubview:self.textView];
        
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentArea);
        }];
    }
    return self;
}

- (UITextView *)textView {
    if(!_textView) {
        _textView = [UITextView new];
        _textView.btd_attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请详细描述您遇到的问题，以便我们更好地帮您解决～" attributes:@{
            NSForegroundColorAttributeName: [UIColor themeGray4],
            NSFontAttributeName: [UIFont themeFontRegular:12],
        }];
        _textView.btd_placeholderBackgroundColor = [UIColor clearColor];
        _textView.textColor = [UIColor themeGray1];
        _textView.textAlignment = NSTextAlignmentLeft;
        _textView.font = [UIFont themeFontRegular:12];
        _textView.backgroundColor = [UIColor themeGray7];
        _textView.layer.cornerRadius = 4;
        _textView.layer.masksToBounds = YES;
        _textView.textContainerInset = UIEdgeInsetsMake(10, 5, 10, 5);
        _textView.showsVerticalScrollIndicator = YES;
        _textView.showsHorizontalScrollIndicator = NO;
        
        @weakify(self);
        [[[_textView.rac_textSignal throttle:0.3] deliverOnMainThread] subscribeNext:^(NSString * _Nullable x) {
            @strongify(self);
            self.item.extraContent = x;
            self.item.isValid = self.item.extraContent.length > 0;
        }];
    }
    return _textView; }

@end

@interface FHHouseDetailReportViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<FHHouseDetailReportItem *> *items;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UIView *submitView;
@property (nonatomic, copy) NSString *houseId;
@property (nonatomic, copy) NSString *houseUrl;
@property (nonatomic, copy) NSString *houseType;

@property (nonatomic, strong) FHHouseDetailReportTypeCell *problemTypeCell;
@property (nonatomic, strong) FHHouseDetailReportPhoneNumberCell *phoneCell;
@property (nonatomic, strong) FHHouseDetailReportExtraCell *extraCell;
@end

@implementation FHHouseDetailReportViewController

- (UIView *)submitView {
    if(!_submitView) {
        _submitView = [UIView new];
        _submitView.backgroundColor = [UIColor themeWhite];
    }
    return _submitView;
}

- (UIButton *)submitButton {
    if(!_submitButton) {
        _submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _submitButton.layer.cornerRadius = 22;
        _submitButton.layer.masksToBounds = YES;
        [_submitButton setTitle:@"提交" forState:UIControlStateNormal];
        _submitButton.titleLabel.font = [UIFont themeFontSemibold:16];
        _submitButton.backgroundColor = [UIColor colorWithHexStr:@"FF9629"];
        [self updateSubmitButtonStatus:NO];
        
        @weakify(self);
        [[[[_submitButton rac_signalForControlEvents:UIControlEventTouchUpInside] deliverOnMainThread] throttle:0.3] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self submitAction];
        }];
    }
    return _submitButton;
}

- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        
        [_tableView registerClass:FHHouseDetailReportTypeCell.class forCellReuseIdentifier:NSStringFromClass(FHHouseDetailReportTypeCell.class)];
        [_tableView registerClass:FHHouseDetailReportPhoneNumberCell.class forCellReuseIdentifier:NSStringFromClass(FHHouseDetailReportPhoneNumberCell.class)];
        [_tableView registerClass:FHHouseDetailReportExtraCell.class forCellReuseIdentifier:NSStringFromClass(FHHouseDetailReportExtraCell.class)];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.allowsSelection = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _tableView.backgroundColor = [UIColor themeGray7];
        _tableView.bounces = NO;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [_tableView addGestureRecognizer:tap];
        
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    }
    return _tableView;
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    [self.view endEditing:YES];
}

- (NSArray<FHHouseDetailReportItem *> *)items {
    if(!_items) {
        
        FHHouseDetailReportItem *typeItem = [[FHHouseDetailReportItem alloc] init];
        typeItem.type = FHHouseDetailReportItemType_Type;
        typeItem.title = @"请选择您遇到的问题类型";
        typeItem.options = [@[
            @"房源不存在",
            @"房源不在此小区",
            @"房源价格造假",
            @"房源图片与实际情况不符",
            @"我是房源所有人，我要投诉（不想卖房或房源已卖）",
        ] btd_map:^id _Nullable(NSString *  _Nonnull content) {
            return [FHHouseDetailReportOption optionWithContent:content];
        }];
        typeItem.height = 280;
        
        FHHouseDetailReportItem *phoneItem = [[FHHouseDetailReportItem alloc] init];
        phoneItem.type = FHHouseDetailReportItemType_Phone;
        phoneItem.title = @"请输入手机号";
        phoneItem.phoneNumber = [self phoneNumber];
        phoneItem.height = UITableViewAutomaticDimension;
        
        FHHouseDetailReportItem *extraItem = [[FHHouseDetailReportItem alloc] init];
        extraItem.type = FHHouseDetailReportItemType_Extra;
        extraItem.title = @"其它";
        extraItem.height = 162;
                
        _items = @[
            typeItem,
            phoneItem,
            extraItem,
        ];
        
        @weakify(self);
        [[[RACSignal combineLatest:@[RACObserve(typeItem, isValid), RACObserve(phoneItem, isValid)]] deliverOnMainThread] subscribeNext:^(RACTuple * _Nullable x) {
            @strongify(self);
            
            RACTupleUnpack(NSNumber *typeValid, NSNumber *phoneValid) = x;
            BOOL isEnableSubmit = typeValid.boolValue && phoneValid.boolValue;
            [self updateSubmitButtonStatus:isEnableSubmit];
        }];
    }
    return _items;
}

- (NSString *)phoneNumber {
    YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
    NSString *phoneNumber = (NSString *)[sendPhoneNumberCache objectForKey:kFHPhoneNumberCacheKey];
    return phoneNumber;
}
- (void)savePhoneNumber:(NSString *)phoneNumber {
    YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
    [sendPhoneNumberCache setObject:phoneNumber forKey:kFHPhoneNumberCacheKey];
}
- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if(self = [super initWithRouteParamObj:paramObj]) {
        self.houseId = [paramObj.allParams tta_stringForKey:@"house_id"];
        self.houseType = [paramObj.allParams tta_stringForKey:@"house_type"];
        self.houseUrl = [paramObj.allParams tta_stringForKey:@"house_url"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor themeWhite];
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"房源问题反馈";
    
    self.problemTypeCell = [[FHHouseDetailReportTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    self.phoneCell = [[FHHouseDetailReportPhoneNumberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    self.extraCell = [[FHHouseDetailReportExtraCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    [self.view addSubview:self.tableView];
    
    [self.submitView addSubview:self.submitButton];
    [self.submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.submitView).offset(20);
        make.right.equalTo(self.submitView).offset(-20);
        make.bottom.equalTo(self.submitView).offset(-10);
        make.top.equalTo(self.submitView).offset(10);
    }];
    
    [self.view addSubview:self.submitView];
    [self.submitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.tableView.mas_bottom);
        make.height.mas_equalTo(64);
        make.bottom.equalTo(self.view).offset(-FHIMAreaInsetsBottom());
    }];
        
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.customNavBarView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.submitView.mas_top);
    }];
    [self.tableView reloadData];
    
    @weakify(self);
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillChangeFrameNotification object:nil] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable notification) {
        @strongify(self);
    
        CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat keyboardOriginY = rect.origin.y;
        CGFloat keyboardHeight = rect.size.height;
        BOOL isShow = keyboardOriginY < SCREEN_HEIGHT;
        CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:duration animations:^{
            [self.submitView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.view).offset(-(isShow ? keyboardHeight : FHIMAreaInsetsBottom() ));
            }];
            
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        }];
        
        if(isShow) {
            if(self.phoneCell.phoneTextField.isFirstResponder) {
                [self.tableView scrollToRowAtIndexPath:self.phoneCell.indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            } else if(self.extraCell.isFirstResponder) {
                [self.tableView scrollToRowAtIndexPath:self.extraCell.indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            } else {
                [self.tableView btd_scrollToBottom];
            }
        }
    }];
    
    [self adddGoDetail];
}

- (void)adddGoDetail {
    NSMutableDictionary *reportParams = [NSMutableDictionary dictionary];
    reportParams[UT_ORIGIN_FROM] = self.tracerDict[UT_ORIGIN_FROM]?:UT_BE_NULL;
    reportParams[UT_ENTER_FROM] = self.tracerDict[UT_ENTER_FROM]?:UT_BE_NULL;
    reportParams[UT_PAGE_TYPE] = [self pageType];
    reportParams[@"event_tracking_id"] = @"115886";
    TRACK_EVENT(UT_GO_DETAIL, reportParams);
}

- (NSString *)pageType {
    return @"feedback_detail";
}

- (void)updateSubmitButtonStatus:(BOOL)isEnable {
    self.submitButton.enabled = isEnable;
    self.submitButton.alpha = isEnable ? 1 : 0.4;
}

- (void)submitAction {
    // 点击埋点
    NSMutableDictionary *reportParams = [NSMutableDictionary dictionary];
    reportParams[UT_ORIGIN_FROM] = self.tracerDict[UT_ORIGIN_FROM]?:UT_BE_NULL;
    reportParams[UT_ENTER_FROM] = self.tracerDict[UT_ENTER_FROM]?:UT_BE_NULL;
    reportParams[UT_PAGE_TYPE] = [self pageType];
    reportParams[@"group_id"] = self.houseId?:UT_BE_NULL;
    reportParams[@"event_tracking_id"] = @"113945";
    TRACK_EVENT(@"feedback_confirm", reportParams);
    // ---
    
    // 提交动作
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    params[@"house_url"]= self.houseUrl;
    params[@"house_id"] = self.houseId;
    params[@"house_type"] = @(self.houseType.integerValue);
    

    __block BOOL isValidPhoneNumber = YES;
    [self.items enumerateObjectsUsingBlock:^(FHHouseDetailReportItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        switch (item.type) {
            case FHHouseDetailReportItemType_Type:
            {
                params[@"problem"] = item.selectedOption.content;
            }
                break;
            case FHHouseDetailReportItemType_Phone:
            {
                if(item.phoneNumber.length > 0) {
                    isValidPhoneNumber = [item.phoneNumber validateContactNumber];
                }
                if(isValidPhoneNumber) {
                    params[@"phone"] = item.phoneNumber;
                }
            }
                break;
            case FHHouseDetailReportItemType_Extra:
            {
                params[@"other_problem"] = item.extraContent;
            }
                break;
            default:
                break;
        }
    }];
    
    if(!isValidPhoneNumber) {
        [self updateSubmitButtonStatus:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFHHouseDetailReportPhoneNumberStatusNotification object:nil];
        return;
    }
    
    if(![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络不给力，请重试"];
        return;
    }
    
    @weakify(self);
    [self showLoadingAlert:@"正在提交"];
    [FHMainApi requestHouseFeedbackReport:params completion:^(NSError * _Nonnull error, id  _Nonnull jsonObj) {
        @strongify(self);
        [self dismissLoadingAlert];
        if(error) {
            [[ToastManager manager] showToast:@"网络错误，请稍后重试"];
            return;
        }
        
        if(jsonObj && [jsonObj[@"status"] longValue] == 0) {
            [self savePhoneNumber:params[@"phone"]];
            [self goBack];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showHintView];
            });
        }
        else {
            [[ToastManager manager] showToast:@"网络错误，请稍后重试"];
        }
    }];
}

- (void)showHintView {

    // 创建弹窗
    CGFloat duration = 0.25f;
    UIView *hintView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    hintView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    void(^dismissHintViewBlock)(NSString *) = ^(NSString *from) {
        // 点击埋点
        NSMutableDictionary *reportParams = [NSMutableDictionary dictionary];
        reportParams[UT_PAGE_TYPE] = self.tracerDict[UT_ENTER_FROM];
        reportParams[@"popup_name"] = @"submit_success";
        reportParams[@"click_position"] = from;
        reportParams[@"event_tracking_id"] = @"113175";
        TRACK_EVENT(@"popup_click", reportParams);
        // ---
        [UIView animateWithDuration:duration animations:^{
            hintView.alpha = 0;
        } completion:^(BOOL finished) {
            [hintView removeFromSuperview];
        }];
    };
    
    UIView *contentView = [UIView new];
    contentView.backgroundColor = [UIColor themeWhite];
    contentView.layer.cornerRadius = 10;
    contentView.layer.masksToBounds = YES;
    [hintView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(hintView);
        make.width.mas_equalTo(279);
        make.height.mas_equalTo(269);
    }];
    UITapGestureRecognizer *fakeTap = [UITapGestureRecognizer new];
    [contentView addGestureRecognizer:fakeTap];
    
    // 背景图片
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_house_report_bg_pop"]];
    [contentView addSubview:backgroundImageView];
    [backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(contentView);
    }];
    // 关闭按钮点击消失
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:ICON_FONT_IMG(24, @"\U0000E673", [UIColor themeGray5]) forState:UIControlStateNormal];
    [[[closeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] deliverOnMainThread] subscribeNext:^(__kindof UIControl * _Nullable x) {
        dismissHintViewBlock(@"know");
    }];
    [contentView addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.top.equalTo(contentView).offset(5);
        make.right.equalTo(contentView).offset(-15);
    }];
    // 标题
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"房源举报";
    titleLabel.font = [UIFont themeFontMedium:24];
    titleLabel.textColor = [UIColor themeGray1];
    [contentView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView).offset(20);
        make.top.equalTo(contentView).offset(60);
        make.right.equalTo(contentView).offset(-20);
        make.height.mas_offset(33);
    }];
    // 副标题
    UILabel *subtitleLabel = [UILabel new];
    subtitleLabel.text = @"提交成功！您可以在“消息-通知”中查看反馈进度。";
    subtitleLabel.textColor = [UIColor themeGray1];
    subtitleLabel.numberOfLines = 0;
    subtitleLabel.font = [UIFont themeFontMedium:14];
    [contentView addSubview:subtitleLabel];
    [subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(titleLabel);
        make.top.equalTo(titleLabel.mas_bottom).offset(16);
    }];
    // 知道了按钮
    UIButton *knownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [knownBtn setTitle:@"知道了" forState:UIControlStateNormal];
    knownBtn.titleLabel.textColor = [UIColor themeWhite];
    knownBtn.titleLabel.font = [UIFont themeFontRegular:16];
    knownBtn.layer.cornerRadius = 20;
    knownBtn.layer.masksToBounds = YES;
    knownBtn.backgroundColor = [UIColor themeOrange4];
    [contentView addSubview:knownBtn];
    [knownBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(titleLabel);
        make.bottom.equalTo(contentView).offset(-50);
        make.height.mas_equalTo(40);
    }];
    [[[knownBtn rac_signalForControlEvents:UIControlEventTouchUpInside] deliverOnMainThread] subscribeNext:^(__kindof UIControl * _Nullable x) {
        dismissHintViewBlock(@"know");
    }];
    
    // 显示弹窗
    hintView.alpha = 0;
    UIWindow *keyWindow = [UIView keyWindow];
    [keyWindow addSubview:hintView];
    [UIView animateWithDuration:duration animations:^{
        hintView.alpha = 1;
    } completion:^(BOOL finished) {
        // 展现埋点
        NSMutableDictionary *reportParams = [NSMutableDictionary dictionary];
        reportParams[UT_PAGE_TYPE] = self.tracerDict[UT_ENTER_FROM];
        reportParams[@"popup_name"] = @"submit_success";
        reportParams[@"event_tracking_id"] = @"113174";
        TRACK_EVENT(@"popup_show", reportParams);
        // ---
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma  mark - UITableViewDelegate


#pragma  mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FHHouseDetailReportItem *item = self.items[indexPath.row];
    
    FHHouseDetailReportBaseCell *cell = nil;
    switch (item.type) {
        case FHHouseDetailReportItemType_Type:
        {
            cell = self.problemTypeCell;
        }
            break;
        case FHHouseDetailReportItemType_Phone:
        {
            cell = self.phoneCell;
        }
            break;
        case FHHouseDetailReportItemType_Extra:
        {
            cell = self.extraCell;
        }
            break;
        default:
            cell = [FHHouseDetailReportBaseCell new];
            break;
    }
    cell.item = item;
    cell.indexPath = indexPath;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FHHouseDetailReportItem *item = self.items[indexPath.row];
    return item.height;
}
@end

@implementation NSString(validateContactNumber)
- (BOOL)validateContactNumber {
    
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,175,176,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|7[56]|8[56])\\d{8}$";
    
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,177,180,189
     22         */
    NSString * CT = @"^1((33|53|77|8[09])[0-9]|349)\\d{7}$";
    
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    NSPredicate *regextestPHS = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    
    if(([regextestmobile evaluateWithObject:self] == YES)
       || ([regextestcm evaluateWithObject:self] == YES)
       || ([regextestct evaluateWithObject:self] == YES)
       || ([regextestcu evaluateWithObject:self] == YES)
       || ([regextestPHS evaluateWithObject:self] == YES)){
        return YES;
    }else{
        return NO;
    }
}
@end
