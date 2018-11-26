//
//  FHHomeCityTrendCell.m
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import "FHHomeCityTrendCell.h"

#import "FHConfigModel.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "FHHomeTrendBubbleView.h"
#import <NSTimer+TTNoRetainRef.h>
#import <TTRoute.h>

@interface FHHomeCityTrendCell()

@property(nonatomic, strong) FHHomeTrendBubbleView *bubbleView;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) FHConfigDataCityStatsModel *model;
@property (nonatomic, assign) BOOL isShowBubble;

@end

@implementation FHHomeCityTrendCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    
    self.trendView = [[FHHomeCityTrendView alloc]initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.trendView];

    WeakSelf;
    self.trendView.clickedLeftCallback = ^(UIButton * _Nonnull btn) {
        [wself leftBtnDidClick:btn];
    };
//    self.trendView.clickedRightCallback = ^{
//        [wself rightBtnDidClickWithModel: wself.model];
//    };
    
}


-(void)leftBtnDidClick:(UIButton*)btn {

    if (!self.isShowBubble) {
        
        if (self.timer) {
            [self.timer invalidate];
        }
        self.timer = [NSTimer scheduledTimerWithTimeInterval:3.f target:self selector:@selector(timeoutTimer:) userInfo:nil repeats:NO];
        WeakSelf;
        [self.bubbleView showFromView:btn withDissmissAction:^{
            wself.isShowBubble = NO;
            [wself.timer invalidate];
            wself.timer = nil;
        }];
    }else {
        [self dimissBubbleView];
    }
    
    self.isShowBubble = !self.isShowBubble;
    
}
-(void)timeoutTimer:(NSTimer*)timer {

    [self dimissBubbleView];
}

-(void)dimissBubbleView {

    [self.bubbleView dismiss];
    self.isShowBubble = NO;
    [self.timer invalidate];
    self.timer = nil;
}

-(void)updateWithModel:(FHConfigDataCityStatsModel *)model {
    
    _model = model;
    [self.trendView updateWithModel:model];
    [self.bubbleView updateTitle:model.cityPriceHint];
    
}

-(CGSize)sizeThatFits:(CGSize)size {
    
    [super sizeThatFits:size];
    CGSize theSize = CGSizeMake(size.width, 64 + 25);

    return theSize;
}

-(void)layoutSubviews {
    
    [super layoutSubviews];
    self.trendView.size = CGSizeMake(self.contentView.bounds.size.width, 64);
    self.trendView.left = 0;
    self.trendView.top = 15;

}

-(FHHomeTrendBubbleView *)bubbleView {
    
    if (!_bubbleView) {
        
        _bubbleView = [[FHHomeTrendBubbleView alloc]init];
    }
    return _bubbleView;
}

-(void)dealloc {
    
    [_timer invalidate];
    _timer = nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
