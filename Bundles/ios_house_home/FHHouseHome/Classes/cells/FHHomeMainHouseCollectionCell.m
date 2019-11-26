//
//  FHHomeMainHouseCollectionCell.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/11/22.
//

#import "FHHomeMainHouseCollectionCell.h"
#import "FHHomeViewController.h"

@implementation FHHomeMainHouseCollectionCell
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        self.contentView.backgroundColor = [UIColor clearColor];
        FHHomeViewController *homeViewVC = [[FHHomeViewController alloc] init];
        self.contentVC = homeViewVC;
        [self.contentView addSubview:homeViewVC.view];
    }
    
    return self;
}
@end
