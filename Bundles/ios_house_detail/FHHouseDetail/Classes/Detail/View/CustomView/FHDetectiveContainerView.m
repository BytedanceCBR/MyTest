//
//  FHDetectiveContainerView.m
//  FHHouseDetail
//
//  Created by 张静 on 2019/7/2.
//

#import "FHDetectiveContainerView.h"
#import "FHDetailHalfPopFooter.h"

@interface FHDetectiveContainerView ()

@property(nonatomic , strong) UIView *contentView;
@property(nonatomic , strong) FHDetailHalfPopFooter *footer;

@end

@implementation FHDetectiveContainerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    
}

- (void)updateWithDetectiveList:(NSArray *)detectiveList
{
    
}

@end
