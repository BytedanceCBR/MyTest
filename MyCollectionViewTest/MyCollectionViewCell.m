//
//  MyCollectionViewCell.m
//  MyCollectionViewTest
//
//  Created by bytedance on 2021/2/1.
//

#import "MyCollectionViewCell.h"
@interface MyCollectionViewCell()
@property(nonatomic,strong) UIImageView *imgView;
@end

@implementation MyCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    //self.contentView.backgroundColor = [UIColor whiteColor];
    NSLog(@"123");
    return self;
    
}
- (void) initConstraint
{
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(10, 10, 10, 10));
    }];
}
- (void)update
{
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"my1"]];
    self.imgView = imgView;
    self.imgView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.imgView];
    [self initConstraint];
}
@end
