//
//  FHUGCCellOriginItemView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/7/19.
//

#import "FHUGCCellOriginItemView.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "FHCommonApi.h"
#import "ToastManager.h"
#import "TTReachability.h"
#import "TTAccountManager.h"
#import "UIButton+TTAdditions.h"
#import "FHUserTracker.h"
#import "TTUGCAttributedLabel.h"
#import <UIImageView+BDWebImage.h>
#import "TTRoute.h"
#import "JSONAdditions.h"

@interface FHUGCCellOriginItemView ()

@property(nonatomic ,strong) UIImageView *iconView;
@property(nonatomic ,strong) TTUGCAttributedLabel *contentLabel;

@end

@implementation FHUGCCellOriginItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.backgroundColor = [UIColor themeGray7];
    self.layer.cornerRadius = 4;
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToDetail:)];
    [self addGestureRecognizer:singleTap];
    
    self.iconView = [[UIImageView alloc] init];
    _iconView.hidden = YES;
    _iconView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_iconView];
    
    self.contentLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
    _contentLabel.numberOfLines = 2;
    [self addSubview:_contentLabel];
}

- (void)initConstraints {
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(10);
        make.right.mas_equalTo(self).offset(-10);
        make.centerY.mas_equalTo(self);
    }];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(10);
        make.centerY.mas_equalTo(self);
        make.width.height.mas_equalTo(60);
    }];
}

- (void)refreshWithdata:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        self.cellModel = cellModel;
        [self.contentLabel setText:[self generateContentAttributeString]];
        if(cellModel.originItemModel.imageModel){
            [self.iconView bd_setImageWithURL:[NSURL URLWithString:cellModel.originItemModel.imageModel.url] placeholder:nil];
            _iconView.hidden = NO;
            [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self).offset(80);
            }];
        }else{
            _iconView.hidden = YES;
            [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self).offset(10);
            }];
        }
    }
}

- (NSAttributedString *)generateContentAttributeString {
    NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:@""];
    
    if([self typeAttr]){
        [desc appendAttributedString:[self typeAttr]];
    }
    if([self contentAttr]){
        [desc appendAttributedString:[self contentAttr]];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 21;
    paragraphStyle.maximumLineHeight = 21;
    paragraphStyle.lineSpacing = 2;
    
    [desc addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, desc.length)];

    return desc;
}

- (NSAttributedString *)typeAttr {
    NSString *type = self.cellModel.originItemModel.type;
    if (type.length < 1) {
        return nil;
    }
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:type];
    [attri addAttribute:NSForegroundColorAttributeName value:[UIColor themeGray1] range:NSMakeRange(0, type.length)];
    [attri addAttribute:NSFontAttributeName value:[UIFont themeFontMedium:16] range:NSMakeRange(0, type.length)];
    return attri;
}

- (NSAttributedString *)contentAttr {
    NSString *content = self.cellModel.originItemModel.content;
    if (content.length < 1) {
        return nil;
    }
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:content];
    [attri addAttribute:NSForegroundColorAttributeName value:[UIColor themeGray2] range:NSMakeRange(0, content.length)];
    [attri addAttribute:NSFontAttributeName value:[UIFont themeFontRegular:16] range:NSMakeRange(0, content.length)];
    return attri;
}


- (void)goToDetail:(UITapGestureRecognizer *)sender {
//    NSDictionary *dic = @{
//                         @"enter_from":@"test",
//                         @"element_from":@"high_level"
//                         };
//    NSString *str = [[dic tt_JSONRepresentation] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
//    NSString *routeUrl = @"sslocal://detail?groupid=6698944131420389895&item_id=6698944131420389895&report_params=%7b%22element_from%22%3a%22high_level%22%2c%22enter_from%22%3a%22test%22%7d";
    
    NSString *routeUrl = self.cellModel.originItemModel.openUrl;
    if(routeUrl){
        NSURL *openUrl = [NSURL URLWithString:routeUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
    }
}

@end
