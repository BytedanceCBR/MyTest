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
#import "FHUGCCellHelper.h"

@interface FHUGCCellOriginItemView ()<TTUGCAttributedLabelDelegate>

@property(nonatomic ,strong) UIImageView *iconView;
@property(nonatomic ,strong) TTUGCAttributedLabel *contentLabel;
@property(nonatomic ,assign) BOOL isClickLink;

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
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4;
    
    //这里有个坑，加上手势会导致@不能点击
    self.userInteractionEnabled = YES;
//    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToDetail:)];
//    singleTap
//    [self addGestureRecognizer:singleTap];
    
    self.iconView = [[UIImageView alloc] init];
    _iconView.hidden = YES;
    _iconView.backgroundColor = [UIColor whiteColor];
    _iconView.contentMode = UIViewContentModeScaleAspectFill;
    _iconView.clipsToBounds = YES;
    [self addSubview:_iconView];
    
    self.contentLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
    _contentLabel.numberOfLines = 2;
    _contentLabel.layer.masksToBounds = YES;
    _contentLabel.backgroundColor = [UIColor themeGray7];
    NSDictionary *linkAttributes = @{
                                     NSForegroundColorAttributeName : [UIColor themeRed3],
                                     NSFontAttributeName : [UIFont themeFontRegular:16]
                                     };
    _contentLabel.linkAttributes = linkAttributes;
    _contentLabel.activeLinkAttributes = linkAttributes;
    _contentLabel.inactiveLinkAttributes = linkAttributes;
    _contentLabel.delegate = self;
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
        [FHUGCCellHelper setOriginRichContent:self.contentLabel model:cellModel];
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

- (void)goToDetail {
    NSString *routeUrl = self.cellModel.originItemModel.openUrl;
    if(routeUrl){
        NSURL *openUrl = [NSURL URLWithString:routeUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //这里由于单击和长按都会触发这个方法，长按可能会导致黑屏的问题，所以这个只保留单击跳转，屏蔽长按的情况
    UITouch *touch = [touches anyObject];
    BOOL hasLongPress = NO;
    
    for (UIGestureRecognizer *gesture in touch.gestureRecognizers) {
        if([gesture isKindOfClass:[UILongPressGestureRecognizer class]]){
            hasLongPress = YES;
            break;
        }
    }
    
    if(!hasLongPress){
        [self goToDetail];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch_end");
}

#pragma mark - TTUGCAttributedLabelDelegate

- (void)attributedLabel:(TTUGCAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if(self.goToLinkBlock){
        self.goToLinkBlock(self.cellModel, url);
    }
}

@end
