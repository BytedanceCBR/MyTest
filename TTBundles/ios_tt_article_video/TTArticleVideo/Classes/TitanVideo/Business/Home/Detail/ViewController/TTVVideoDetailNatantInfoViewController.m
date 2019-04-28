//
//  TTVVideoDetailNatantInfoViewController.m
//  Article
//
//  Created by lishuangyang on 2017/5/21.
//
//

#import "TTVVideoDetailNatantInfoViewController.h"
#import "TTVVideoDetailNatantInfoView.h"

@interface TTVVideoDetailNatantInfoViewController ()


@end

@implementation TTVVideoDetailNatantInfoViewController


- (instancetype)initWithWidth:(CGFloat)width andinfoModel:(TTVVideoDetailNatantInfoModel *)infoModel{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.infoView = [[TTVVideoDetailNatantInfoView alloc] initWithWidth:width andinfoModel:infoModel];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.infoView.delegate = self;
    [self.view addSubview:self.infoView];
}

#pragma mark - TTVVideoDetailNatantInfoViewDelegate

- (void)extendLinkButton:(UIButton *)button{
    if (self.showBlock) {
        self.showBlock(YES);
    }
}

- (void)reLayOutSubViews:(BOOL)animation{
    self.view.frame = _infoView.frame;
}
@end
