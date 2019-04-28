//
//  TTCertificationEditView.m
//  Article
//
//  Created by wangdi on 2017/5/16.
//
//

#import "TTCertificationEditView.h"
#import "NSString+TTLength.h"

@implementation TTCertificationEditModel

- (instancetype)init
{
    if(self = [super init]) {
        self.maxLimitLength = NSUIntegerMax;
    }
    return self;
}

- (void)setContent:(NSString *)content
{
    _content = [content copy];
    if(self.type == TTCertificationEditModelTypeOccupational) {
        content = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    if(isEmptyString(content)) {
        _isCompleted = NO;
        self.currentErrorTip = self.lenIsNullTip;
        return;
    } else {
        _isCompleted = YES;
    }
    
    if(self.type == TTCertificationEditModelTypeIdNumber) {
        NSString *regex = @"^[a-zA-Z0-9]*$";
        BOOL isMatch = [self matchWithText:self.content regex:regex];
        if(!isMatch) {
            self.currentErrorTip = self.patternTip;
            _isCompleted = NO;
            return;
        }
        NSUInteger length = [content tt_lengthOfBytes];
        if(length != self.minLimitLength && length != self.maxLimitLength) {
            _isCompleted = NO;
            self.currentErrorTip = self.lenShortTip;
            return;
        }
        
        BOOL isMatch2 = [self matchWithText:self.content regex:self.regex];
        if(!isMatch2) {
            self.currentErrorTip = @"请输入真实身份证号码";
            _isCompleted = isMatch2;
        }
        
    } else {
        NSString *pattern = self.regex;
        if(!pattern) return;
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
        BOOL isMatch = [pred evaluateWithObject:content];
        if(!isMatch) {
            self.currentErrorTip = self.patternTip;
            _isCompleted = isMatch;
            return;
        }
        NSUInteger length = [content tt_lengthOfBytes];
        if(length < self.minLimitLength) {
            _isCompleted = NO;
            self.currentErrorTip = self.lenShortTip;
        }
    }
}

- (BOOL)matchWithText:(NSString *)text regex:(NSString *)regex
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:text];
    return isMatch;
}

@end

@interface TTCertificationEditItemView ()<UITextFieldDelegate>

@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedTextField *textField;
@property (nonatomic, strong) SSThemedImageView *arrowView;
@property (nonatomic, strong) SSThemedButton *errorTipView;
@property (nonatomic, copy) void (^updateHeightBlock)();
@property (nonatomic, copy) void (^textChangeBlock)(TTCertificationEditModel *changeModel);

@end

@implementation TTCertificationEditItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.backgroundColorThemeKey = kColorBackground4;
        [self setupSubview];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextChange:) name:UITextFieldTextDidChangeNotification object:self.textField];
    }
    return self;
}

- (void)setupSubview
{
    SSThemedLabel *titleLabel = [[SSThemedLabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16]];
    titleLabel.textColorThemeKey = kColorText1;
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    SSThemedTextField *textField = [[SSThemedTextField alloc] init];
    textField.delegate = self;
    textField.returnKeyType = UIReturnKeyDone;
    textField.placeholderColorThemeKey = kColorText3;
    textField.textColorThemeKey = kColorText1;
    textField.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16]];
    [self addSubview:textField];
    self.textField = textField;
    
    SSThemedButton *errorTipView = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    errorTipView.hidden = YES;
    errorTipView.userInteractionEnabled = NO;
    errorTipView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    errorTipView.imageName = @"Information_error_icon";
    errorTipView.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    errorTipView.titleColorThemeKey = kColorText4;
    errorTipView.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12]];
    [self addSubview:errorTipView];
    self.errorTipView = errorTipView;
    
    SSThemedImageView *arrowView = [[SSThemedImageView alloc] init];
    arrowView.imageName = @"setting_arrow";
    arrowView.hidden = YES;
    [self addSubview:arrowView];
    self.arrowView = arrowView;

}

- (void)setEditModel:(TTCertificationEditModel *)editModel
{
    _editModel = editModel;
    self.titleLabel.text = editModel.title;
    self.textField.placeholder = editModel.placeholder;
    self.textField.text = editModel.content;
    self.textField.userInteractionEnabled = editModel.arrowBlock ? NO : YES;
    self.arrowView.hidden = editModel.arrowBlock ? NO : YES;
    if(editModel.arrowBlock) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
        [self addGestureRecognizer:tap];
    }
}

- (void)tapClick
{
    if(self.editModel.arrowBlock) {
        self.editModel.arrowBlock();
    }
}

- (void)textFieldTextChange:(NSNotification *)note
{
    if(note.object != self.textField) return;
    if ([self.textField.text tt_lengthOfBytes] > self.editModel.maxLimitLength && self.textField.markedTextRange == nil) {
        NSUInteger limitedLength = [self.textField.text limitedLengthOfMaxCount:self.editModel.maxLimitLength];
        self.textField.text = [self.textField.text substringToIndex:MIN(limitedLength, self.textField.text.length - 1)];
    }
    self.editModel.content = self.textField.text;
    if(self.textChangeBlock) {
        self.textChangeBlock(self.editModel);
    }
}

#pragma mark - textField 代理
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(!self.editModel.isCompleted) {
        if(self.updateHeightBlock) {
            self.editModel.height = kItemViewErrorHeight;
            self.errorTipView.hidden = NO;
            [self.errorTipView setTitle:self.editModel.currentErrorTip forState:UIControlStateNormal];
            self.updateHeightBlock();
        }
    } else {
        if(self.updateHeightBlock) {
            self.editModel.height = kItemViewNormalHeight;
            self.errorTipView.hidden = YES;
            self.updateHeightBlock();
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger changedLength = [textField.text tt_lengthOfBytes] - range.length + [string tt_lengthOfBytes];
    if(changedLength > self.editModel.maxLimitLength) {
        self.editModel.height = kItemViewErrorHeight;
        self.errorTipView.hidden = NO;
        [self.errorTipView setTitle:self.editModel.maxLengthTip forState:UIControlStateNormal];
        self.updateHeightBlock();
    } else {
        if(self.updateHeightBlock) {
            self.editModel.height = kItemViewNormalHeight;
            self.errorTipView.hidden = YES;
            self.updateHeightBlock();
        }

    }
    
    return changedLength <= self.editModel.maxLimitLength || [string length] == 0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize titleLabelSize = [self.titleLabel.text boundingRectWithSize:CGSizeMake(self.width, [TTDeviceUIUtils tt_newPadding:22.5]) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.titleLabel.font} context:nil].size;
    self.titleLabel.top = [TTDeviceUIUtils tt_newPadding:12];
    self.titleLabel.left = [TTDeviceUIUtils tt_newPadding:15];
    self.titleLabel.size = CGSizeMake(titleLabelSize.width, [TTDeviceUIUtils tt_newPadding:22.5]);
    
    self.errorTipView.top = self.titleLabel.bottom + [TTDeviceUIUtils tt_newPadding:7];
    self.errorTipView.left = self.titleLabel.left;
    self.errorTipView.height = [TTDeviceUIUtils tt_newPadding:16.5];
    self.errorTipView.width = self.width - self.errorTipView.left;
    
    self.arrowView.width = [TTDeviceUIUtils tt_newPadding:9];
    self.arrowView.height = [TTDeviceUIUtils tt_newPadding:14];
    self.arrowView.left = self.width - self.arrowView.width- [TTDeviceUIUtils tt_newPadding:15];
    self.arrowView.top = (self.height - self.arrowView.height) * 0.5;
    
    self.textField.left = self.titleLabel.right + [TTDeviceUIUtils tt_newPadding:23];
    if(self.editModel.arrowBlock) {
        self.textField.width = self.arrowView.left - [TTDeviceUIUtils tt_newPadding:5] - self.textField.left;
    } else {
        self.textField.width = self.width - self.textField.left - [TTDeviceUIUtils tt_newPadding:15];
    }
    self.textField.height = [TTDeviceUIUtils tt_newPadding:22.5];
    self.textField.top =  [TTDeviceUIUtils tt_newPadding:12];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@interface TTCertificationEditView ()

@property (nonatomic, assign) NSInteger changeIndex;
@property (nonatomic, strong) NSMutableArray *itemViewArray;

@end

@implementation TTCertificationEditView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.backgroundColorThemeKey = kColorBackground4;
    }
    return self;
}

- (NSMutableArray *)itemViewArray
{
    if(!_itemViewArray) {
        _itemViewArray = [NSMutableArray array];
    }
    return _itemViewArray;
}

- (void)setEditModels:(NSArray<TTCertificationEditModel *> *)editModels
{
    _editModels = editModels;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.itemViewArray = nil;
    for(int i = 0; i < editModels.count;i++) {
        TTCertificationEditModel *editModel = editModels[i];
        TTCertificationEditItemView *itemView = [[TTCertificationEditItemView alloc] init];
        __weak typeof(self) weakSelf = self;
        itemView.updateHeightBlock = ^() {
            [weakSelf setNeedsLayout];
        };
        itemView.textChangeBlock = ^(TTCertificationEditModel *changeModel){
            if(weakSelf.textChangeBlock) {
                weakSelf.textChangeBlock(changeModel);
            }
        };
        itemView.editModel = editModel;
        [self addSubview:itemView];
        [self.itemViewArray addObject:itemView];
    }
    
    [self setNeedsLayout];
}

- (void)updateEidtModel:(TTCertificationEditModel *)editModel
{
    for(int i = 0;i < self.itemViewArray.count;i++) {
        TTCertificationEditItemView *itemView = self.itemViewArray[i];
        if(editModel.type == itemView.editModel.type) {
            itemView.textField.text = editModel.content;
            [itemView textFieldDidEndEditing:itemView.textField];
            break;
        }
    }
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    TTCertificationEditItemView *lastItemView = nil;
    NSInteger count = self.itemViewArray.count;
    for(int i = 0; i < count;i++) {
        TTCertificationEditItemView *itemView = self.itemViewArray[i];
        TTCertificationEditModel *itemModel = self.editModels[i];
        itemView.left = 0;
        itemView.height = itemModel.height;
        itemView.width = self.width;
        itemView.top = lastItemView.bottom;
        lastItemView = itemView;
    }
    self.height = lastItemView.bottom;
    
    if(self.heightChangeBlock) {
        self.heightChangeBlock();
    }
}

@end

@interface TTCertificationEditViewMetaDataManager ()

@property (nonatomic, strong) NSMutableDictionary *modelsQueue;

@end

@implementation TTCertificationEditViewMetaDataManager

static id _instance;

- (NSMutableDictionary *)modelsQueue
{
    if(!_modelsQueue) {
        _modelsQueue = [NSMutableDictionary dictionary];
        TTCertificationEditModel *realNameModel = [[TTCertificationEditModel alloc] init];
        realNameModel.title = @"真实姓名";
        realNameModel.placeholder = @"请输入真实姓名";
        realNameModel.regex = @"^[\u4e00-\u9fa5a-zA-Z]*$";
        realNameModel.lenShortTip = @"最少2个(含)汉字或4个英文字母";
        realNameModel.lenIsNullTip = @"真实姓名不能为空";
        realNameModel.patternTip = @"仅支持汉字和英文字母";
        realNameModel.maxLengthTip = @"最多10个汉字或20个英文字母";
        realNameModel.currentErrorTip = realNameModel.lenIsNullTip;
        realNameModel.maxLimitLength = 20;
        realNameModel.minLimitLength = 4;
        realNameModel.type = TTCertificationEditModelTypeRealName;
        realNameModel.height = kItemViewNormalHeight;
        
        [_modelsQueue setObject:realNameModel forKey:@(realNameModel.type)];
        
        TTCertificationEditModel *idNameModel = [[TTCertificationEditModel alloc] init];
        idNameModel.maxLimitLength = 18;
        idNameModel.minLimitLength = 15;
        idNameModel.title = @"身份证号";
        idNameModel.placeholder = @"请输入真实身份证号码";
        idNameModel.lenIsNullTip = @"身份证号不能为空";
        idNameModel.lenShortTip = @"仅支持15位或18位身份证号码";
        idNameModel.patternTip = @"仅支持数字和英文字母";
        idNameModel.maxLengthTip = @"最长18个数字或字母";
        idNameModel.currentErrorTip = idNameModel.lenIsNullTip;
        idNameModel.regex = @"(^[0-9]{15}$)|([0-9]{17}([0-9]|X|x)$)";
        idNameModel.height = kItemViewNormalHeight;
        idNameModel.type = TTCertificationEditModelTypeIdNumber;
        
        [_modelsQueue setObject:idNameModel forKey:@(idNameModel.type)];
        
        TTCertificationEditModel *industryModel = [[TTCertificationEditModel alloc] init];
        industryModel.title = @"所在行业";
        industryModel.placeholder = @"请选择所在行业";
        industryModel.lenIsNullTip = @"请选择所在行业";
        industryModel.type = TTCertificationEditModelTypeIndustry;
        industryModel.height = kItemViewNormalHeight;
        
        [_modelsQueue setObject:industryModel forKey:@(industryModel.type)];
        
        
        TTCertificationEditModel *unitModel = [[TTCertificationEditModel alloc] init];
        unitModel.title = @"单位/组织";
        unitModel.maxLengthTip = @"最长20个汉字或40个英文字母";
        unitModel.placeholder = @"请输入真实的公司或组织名";
        unitModel.regex = @"^[\u4e00-\u9fa5a-zA-Z0-9]*$";
        unitModel.lenShortTip = @"最短2个汉字或4个英文字母";
        unitModel.patternTip = @"仅支持汉字、英文、数字";
        unitModel.lenIsNullTip = @"单位/组织不能为空";
        unitModel.currentErrorTip = unitModel.lenIsNullTip;
        unitModel.maxLimitLength = 40;
        unitModel.minLimitLength = 4;
        unitModel.type = TTCertificationEditModelTypeUnit;
        unitModel.height = kItemViewNormalHeight;
        [_modelsQueue setObject:unitModel forKey:@(unitModel.type)];
        
        TTCertificationEditModel *occupationalModel = [[TTCertificationEditModel alloc] init];
        occupationalModel.title = @"职位/称号";
        occupationalModel.placeholder = @"请输入真实的职位或称号";
        occupationalModel.regex = @"^[\u4e00-\u9fa5a-zA-Z0-9，,《》、 ]*$";
        occupationalModel.lenShortTip = @"最短2个汉字或4个英文字母";
        occupationalModel.lenIsNullTip = @"职位/称号不能为空";
        occupationalModel.patternTip = @"仅支持汉字、英文、逗号、书名号、空格、顿号";
        occupationalModel.maxLengthTip = @"最长15个汉字或30个英文字母";
        occupationalModel.currentErrorTip = occupationalModel.lenIsNullTip;
        occupationalModel.maxLimitLength = 30;
        occupationalModel.minLimitLength = 4;
        occupationalModel.type = TTCertificationEditModelTypeOccupational;
        occupationalModel.height = kItemViewNormalHeight;
        [_modelsQueue setObject:occupationalModel forKey:@(occupationalModel.type)];
        
        TTCertificationEditModel *supplementModel = [[TTCertificationEditModel alloc] init];
        supplementModel.title = @"补充信息";
        supplementModel.placeholder = @"请输入更多信息以提高认证成功率，限制50字以内\n例如：前xx公司负责人；曾获xxx奖项；著有《xxx》等";
        supplementModel.type = TTCertificationEditModelTypeSupplement;
        [_modelsQueue setObject:supplementModel forKey:@(supplementModel.type)];
    }
    return _modelsQueue;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (void)updateModelContent:(NSString *)content type:(TTCertificationEditModelType)type
{
    TTCertificationEditModel *editModel = self.modelsQueue[@(type)];
    editModel.content = content;
}

- (TTCertificationEditModel *)editModelWithType:(TTCertificationEditModelType)type
{
    return self.modelsQueue[@(type)];
}

- (void)clearAllData
{
    self.modelsQueue = nil;
}

- (void)updateModelHeight
{
    [self.modelsQueue enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key,  TTCertificationEditModel *obj, BOOL * _Nonnull stop) {
        obj.height = kItemViewNormalHeight;
    }];
}

@end
