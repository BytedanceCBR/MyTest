//
//  FHTopicTopBackView.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/8/23.
//

#import "FHTopicTopBackView.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "TTDeviceHelper.h"
#import "FHCommonDefines.h"

@interface FHTopicTopBackView()

@property (nonatomic, strong)   UIImageView        *headerImageView;

@end

@implementation FHTopicTopBackView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor whiteColor];
    // _headerImageView
    _headerImageView = [[UIImageView alloc] init];
    NSString *imageName = [NSString stringWithFormat:@"fh_ugc_community_detail_header_back0"];
    _headerImageView.image = [UIImage imageNamed:imageName];
    [self addSubview:_headerImageView];
    [_headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}



@end
