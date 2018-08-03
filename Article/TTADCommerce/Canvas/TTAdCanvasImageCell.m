//
//  TTAdCanvasImageView.m
//  Article
//
//  Created by yin on 2017/3/28.
//
//

#import "TTAdCanvasImageCell.h"
#import "UIImage+MultiFormat.h"
#import "TTImageView.h"
#import "SSSimpleCache.h"
#import "TTAdCanvasManager.h"
#import "TTAdCommonUtil.h"

@interface TTAdCanvasImageCell ()

@property(nonatomic, strong)TTImageView *picView;
@property(nonatomic, strong)TTAdCanvasLayoutModel* model;

@end

@implementation TTAdCanvasImageCell

- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super initWithWidth:width];
    if (self) {
       [self setSubViews];
    }
    return self;
}


- (void)setSubViews
{
    self.picView = [[TTImageView alloc] init];
    self.picView.enableNightCover = NO;
    [self addSubview:self.picView];
}

- (void)refreshWithModel:(TTAdCanvasLayoutModel *)model
{
    [super refreshWithModel:model];
    self.model = model;
    TTImageInfosModel* imageModel = [[TTImageInfosModel alloc] initWithURL:model.data.imgsrc];
    if ([[SSSimpleCache sharedCache] isImageInfosModelCacheExist:imageModel]) {
        self.picView.imageView.image = [UIImage sd_imageWithData:[[SSSimpleCache sharedCache]dataForImageInfosModel:imageModel]];
    }
    else{
        if ([model.data.imgsrc hasPrefix:@"http://"]) {
            [self.picView setImageWithURLString:model.data.imgsrc];
        } else {
            [self.picView setImage:[UIImage imageNamed:model.data.imgsrc]];
        }
    }
}


- (void)canvasCell:(TTAdCanvasBaseCell *)cell showStatus:(TTAdCanvasItemShowStatus)showStatus itemIndex:(NSInteger)itemIndex
{
    switch (showStatus) {
        case TTAdCanvasItemShowStatus_WillDisplay:
        {
            [self trackShow:itemIndex];
        }
            break;
            
        default:
            break;
    }
}

- (void)trackShow:(NSInteger)indexPath
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    NSMutableDictionary* extra_data = [NSMutableDictionary dictionary];
    [extra_data setValue:@(indexPath) forKey:@"material_pos"];
    [extra_data setValue:@2 forKey:@"material_type"];
    [dict setValue:extra_data.format2JSONString forKey:@"ad_extra_data"];
    [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"impression_pic" dict:dict];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.picView.frame = self.bounds;
}

+ (CGFloat)heightForModel:(TTAdCanvasLayoutModel *)model inWidth:(CGFloat)constraintWidth
{
    return [super heightForModel:model inWidth:constraintWidth];
}

- (void)dealloc
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
