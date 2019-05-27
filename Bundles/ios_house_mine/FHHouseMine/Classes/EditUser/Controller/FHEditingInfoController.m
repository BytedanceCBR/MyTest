//
//  FHEditingInfoController.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/5/22.
//

#import "FHEditingInfoController.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "FHEditingInfoViewModel.h"
#import "FHEditableUserInfo.h"

@interface FHEditingInfoController ()

@property(nonatomic, strong) UITextField *textField;
@property(nonatomic, strong) UIView *bgView;
@property(nonatomic, assign) FHEditingInfoType type;
@property(nonatomic, strong) FHEditingInfoViewModel *viewModel;
@property(nonatomic, strong) FHEditableUserInfo *userInfo;
@property(nonatomic, strong) UIButton *saveBtn;

@end

@implementation FHEditingInfoController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        _type = [paramObj.allParams[@"type"] integerValue];
        _userInfo = paramObj.allParams[@"user_info"];
        
        NSHashTable<FHEditingInfoControllerDelegate> *delegate = paramObj.allParams[@"delegate"];
        self.delegate = delegate.anyObject;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initNavbar];
    [self initView];
    [self initConstraints];
    [self initViewModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view addObserver:self forKeyPath:@"userInteractionEnabled" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view removeObserver:self forKeyPath:@"userInteractionEnabled"];
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    
    self.saveBtn = [[UIButton alloc] init];
    [_saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [_saveBtn setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
    _saveBtn.titleLabel.font = [UIFont themeFontRegular:16];
    [_saveBtn addTarget:self action:@selector(saveInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavBarView addRightViews:@[_saveBtn] viewsWidth:@[@32] viewsHeight:@[@22] viewsRightOffset:@[@20]];
}

- (void)initView {
    self.view.backgroundColor = [UIColor themeGray7];
    
    self.bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_bgView];
    
    self.textField = [[UITextField alloc] init];
    _textField.font = [UIFont themeFontRegular:16];
    _textField.textColor = [UIColor themeGray1];
    _textField.tintColor = [UIColor themeRed3];
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.bgView addSubview:_textField];
    
    if(self.type == FHEditingInfoTypeUserName){
        _textField.text = _userInfo.name;
    }else if(self.type == FHEditingInfoTypeUserDesc){
        _textField.text = _userInfo.userDescription;
    }
    
}

- (void)initConstraints {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.mas_topLayoutGuide).offset(44);
        } else {
            make.top.mas_equalTo(64);
        }
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(60);
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView).offset(20);
        make.right.equalTo(self.bgView).offset(-20);
        make.top.bottom.equalTo(self.bgView);
    }];
}

- (void)initViewModel {
    self.viewModel = [[FHEditingInfoViewModel alloc] initWithTextField:self.textField controller:self];
    _viewModel.userInfo = self.userInfo;
    _viewModel.type = self.type;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"userInteractionEnabled"]) {
        if([change[@"new"] boolValue]){
            [self.view endEditing:YES];
        }
    }
}

- (void)saveInfo {
    [self.viewModel save];
}

@end
