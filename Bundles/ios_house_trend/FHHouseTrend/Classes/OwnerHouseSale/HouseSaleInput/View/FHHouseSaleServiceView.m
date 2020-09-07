//
//  FHHouseSaleServiceView.m
//  FHHouseTrend
//
//  Created by 谢思铭 on 2020/9/6.
//

#import "FHHouseSaleServiceView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <Masonry.h>
#import "UIViewAdditions.h"
#import "UIDevice+BTDAdditions.h"

@interface FHHouseSaleServiceView ()

@property(nonatomic, strong) UILabel *titleLabel;

@end

@implementation FHHouseSaleServiceView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self){
        self.backgroundColor = [UIColor whiteColor];
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.titleLabel = [self LabelWithFont:[UIFont themeFontSemibold:18] textColor:[UIColor themeGray1]];
    _titleLabel.text = @"四大服务优势";
    _titleLabel.frame = CGRectMake(15, 12, self.width - 30, 25);
    [self addSubview:_titleLabel];
    
    NSArray *textArray = @[@"海量买家",@"专业顾问",@"品质服务",@"隐私保护"];
    NSArray *descArray = @[@"专业平台，海量购房用户，让卖房更轻松",
                           @"专业顾问为您提供1对1专享服务",
                           @"品牌公司海量覆盖，更多选择，更好的卖房体验",
                           @"真实号码不泄露，放心提交免打扰"];
    
    CGFloat width = ceil((self.width - 45)/2);
    CGFloat height = ceil(width * 145/150);
    CGFloat top = self.titleLabel.bottom + 8;
    CGFloat left = 15;
    
    for (NSInteger i = 0; i < 4; i++) {
        NSInteger row = i%2;
        NSInteger col = i/2;
//        house_sale_service_0
        NSString *imageName = [NSString stringWithFormat:@"house_sale_service_%li",(long)i];
        UIView *serviceView = [self serviceItemViewWithFrame:CGRectMake(left + row * (width + 15), top + col * (height + 15), width, height) title:textArray[i] desc:descArray[i] imageName:imageName];
        [self addSubview:serviceView];
    }
}

- (void)initConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(12);
        make.left.mas_equalTo(self).offset(15);
        make.right.mas_equalTo(self).offset(-15);
        make.height.mas_equalTo(25);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

+ (CGFloat)viewHeight:(CGFloat)width {
    CGFloat height = ceil((width - 45)/2 * 145/150) * 2 + 45 + 15 + 18;
    return height;
}

- (UIView *)serviceItemViewWithFrame:(CGRect)frame title:(NSString *)title desc:(NSString *)desc imageName:(NSString *)imageName {
    UIImageView *view = [[UIImageView alloc] initWithFrame:frame];
    view.image = [UIImage imageNamed:imageName];
    
    UIImageView *bottomBgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    bottomBgView.image = [UIImage imageNamed:@"house_sale_service_bg"];
    [view addSubview:bottomBgView];
    
    [bottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(view);
        make.height.mas_equalTo(91);
    }];
    
    UILabel *titleLabel = [self LabelWithFont:[UIFont themeFontSemibold:16] textColor:[UIColor whiteColor]];
    titleLabel.text = title;
    [view addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(view).offset(10);
        make.right.mas_equalTo(view).offset(-10);
        make.bottom.mas_equalTo(view).offset(-48);
        make.height.mas_equalTo(22);
    }];
    
    CGFloat fontSize = 12;
    if([UIDevice btd_is480Screen] || [UIDevice btd_is568Screen]){
        fontSize = 10;
    }
    
    UILabel *descLabel = [self LabelWithFont:[UIFont themeFontRegular:fontSize] textColor:[UIColor whiteColor]];
    descLabel.numberOfLines = 2;
    descLabel.text = desc;
    [view addSubview:descLabel];
    
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(view).offset(10);
        make.right.mas_equalTo(view).offset(-5);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(4);
        make.height.mas_equalTo(34);
    }];
    
    return view;
}

@end
