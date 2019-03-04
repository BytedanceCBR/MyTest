//
//  FHMapNaviBarView.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/1/31.
//

#import "FHDetailMapPageNaviBarView.h"
#import "FHExtendHotAreaButton.h"
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import "TTDeviceHelper.h"
#import "FHSuggestionListNavBar.h"
#import "FHExtendHotAreaButton.h"
#import <TTDeviceHelper.h>

@interface FHDetailMapPageNaviBarView ()

@property(nonatomic,strong) FHExtendHotAreaButton *backBtn;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UIButton *rightBtn;
@property(nonatomic,strong) UIView *seperatorLine;


@end

@implementation FHDetailMapPageNaviBarView

- (instancetype)initWithBackImage:(UIImage *)image
{
    if (self = [super init]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    // backBtn
    
    CGFloat iphoneXPading = 5;
    if ([TTDeviceHelper isIPhoneXDevice]) {
        iphoneXPading = 0;
    }
    
    _backBtn = [[FHExtendHotAreaButton alloc] init];
    [_backBtn setImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
    [_backBtn setImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
    [self addSubview:_backBtn];
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(24);
        make.left.mas_equalTo(self).offset(18);
        make.bottom.mas_equalTo(self).offset(-16 + iphoneXPading);
    }];
    
    [_backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightBtn setTitle:@"导航" forState:UIControlStateNormal];
    [_rightBtn.titleLabel setFont:[UIFont themeFontRegular:16]];
    [_rightBtn setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
    [self addSubview:_rightBtn];
    [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(36);
        make.right.mas_equalTo(self).offset(-12);
        make.bottom.mas_equalTo(self).offset(-12 + iphoneXPading);
    }];
    [_rightBtn addTarget:self action:@selector(naviMapBtnClick) forControlEvents:UIControlEventTouchUpInside];

    
    _titleLabel = [UILabel new];
    _titleLabel.text = @"位置及周边";
    [self addSubview:_titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self.backBtn);
        make.height.mas_equalTo(28);
        make.width.mas_equalTo(100);
    }];
    
    
    _seperatorLine = [[UIView alloc] init];
    _seperatorLine.backgroundColor = [UIColor colorWithHexString:@"#e8eaeb"];
    [self addSubview:_seperatorLine];
    [_seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
    
    //    self.title.text = "位置及周边"
    //    re.rightBtn.setTitle("导航", for: .normal)
    //    re.rightBtn.setTitleColor(hexStringToUIColor(hex: "#299cff"), for: .normal)
    //    re.rightBtn.isSelected = false
}

- (void)backBtnClick
{
    if (self.backActionBlock) {
        self.backActionBlock();
    }
}

- (void)naviMapBtnClick
{
    if (self.naviMapActionBlock) {
        self.naviMapActionBlock();
    }
}


//lazy var backBtn: ExtendHotAreaButton = {
//    let btn = ExtendHotAreaButton()
//    return btn
//}()
//
//lazy var title: UILabel = {
//    let label = UILabel()
//    label.textAlignment = .center
//    return label
//}()
//
//lazy var rightBtn: UIButton = {
//    let re = UIButton()
//    return re
//}()
//
//lazy var seperatorLine: UIView = {
//    let re = UIView()
//    re.backgroundColor = hexStringToUIColor(hex: kFHSilver2Color)
//    return re
//}()
//
//
//init(backBtnImg: UIImage = #imageLiteral(resourceName: "icon-return")) {
//    super.init(frame: CGRect.zero)
//    backBtn.setBackgroundImage(backBtnImg, for: .normal)
//    backBtn.setBackgroundImage(#imageLiteral(resourceName: "icon-return"), for: .highlighted)
//
//    addSubview(backBtn)
//    backBtn.snp.makeConstraints { maker in
//        maker.left.equalTo(12)
//        maker.width.height.equalTo(24)
//        maker.bottom.equalTo(-10)
//    }
//
//    addSubview(rightBtn)
//    rightBtn.snp.makeConstraints { maker in
//        maker.centerY.equalTo(backBtn.snp.centerY)
//        maker.right.equalTo(-12)
//        maker.height.equalTo(24)
//    }
//
//    addSubview(title)
//    title.snp.makeConstraints { maker in
//        maker.left.greaterThanOrEqualTo(backBtn.snp.right).offset(10)
//        maker.centerY.equalTo(backBtn.snp.centerY)
//        maker.height.equalTo(28)
//        maker.centerX.equalToSuperview()
//        maker.right.lessThanOrEqualTo(rightBtn.snp.left).offset(-10).priority(.high)
//    }
//
//    addSubview(seperatorLine)
//    seperatorLine.snp.makeConstraints { maker in
//        maker.height.equalTo(0.5)
//        maker.left.right.bottom.equalToSuperview()
//    }
//}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
