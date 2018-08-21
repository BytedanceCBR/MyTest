//
//  TTArticlePanorama3DViewCell.m
//  Article
//
//  Created by rongyingjie on 2017/11/1.
//

#import "TTLayoutPanorama3DViewCell.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTArticleCellHelper.h"
#import "TTArticleCellConst.h"
#import "TTDeviceHelper.h"
#import "ExploreCellHelper.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreArticleCellView.h"
#import "TTLayOutPlainLargePicCellModel.h"
#import "TTLayOutUnifyADLargePicCellModel.h"
//#import "TTLayOutUFLargePicCellModel.h"

@interface TTLayoutPanorama3DViewCell ()

@property (nonatomic, strong) TTLayoutPanorama3DCellView *loopPicCellView;

@end

@implementation TTLayoutPanorama3DViewCell

+ (Class)cellViewClass
{
    return [TTLayoutPanorama3DCellView class];
}

-(void)willDisplay{
    [(TTLayoutPanorama3DCellView *)self.cellView willDisplay];
}


- (void)didEndDisplaying {
    [(TTLayoutPanorama3DCellView *)self.cellView didEndDisplaying];
}

- (void)resumeDisplay {
    [(TTLayoutPanorama3DCellView *)self.cellView resumeDisplay];
}

@end

@implementation TTLayoutPanorama3DCellView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        TTArticlePanorama3DView *panoramaView = [TTArticlePanorama3DView new];
        [self addSubview:panoramaView];
        self.panoramaView = panoramaView;
    }
    return self;
}

- (void)refreshUI
{
    [super refreshUI];
    
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.panoramaView.hidden = cellLayOut.motionViewHidden;
    if (!self.panoramaView.hidden) {
        self.panoramaView.frame = cellLayOut.motionViewFrame;
        self.panoramaView.userInteractionEnabled = cellLayOut.picViewUserInteractionEnabled;
        [self.panoramaView updatePics:self.orderedData];
    }
    
    if (![self.orderedData preCellHasBottomPadding] && [self.orderedData hasTopPadding]) {
        CGRect bounds = self.bounds;
        bounds.origin.y = - kUFSeprateViewHeight();
        self.bounds = bounds;
        self.topRect.bottom = 0;
        self.topRect.width = self.width;
        self.topRect.hidden = NO;
    } else {
        CGRect bounds = self.bounds;
        bounds.origin.y = 0;
        self.bounds = bounds;
        self.topRect.hidden = YES;
    }
    
    if (![self.orderedData nextCellHasTopPadding] && [self.orderedData hasTopPadding]) {
        self.bottomRect.bottom = self.height + self.bounds.origin.y;
        self.bottomRect.width = self.width;
        self.bottomRect.hidden = NO;
    }
    else{
        self.bottomRect.hidden = YES;
    }
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
    BOOL isExpand = orderedData.cellLayOut.isExpand;
    if ([orderedData article]) {
        if (!orderedData.cellLayOut || orderedData.cellLayOut.needUpdateAllFrame){
            orderedData.cellLayOut = [[TTLayOutPlainPanoramaCellModel alloc] init];
            orderedData.layoutUIType = TTLayOutCellUITypePlainCellLargePicS0;
        }
    }
    
    TTLayOutCellBaseModel *cellLayOut = orderedData.cellLayOut;
    orderedData.cellLayOut.isExpand = isExpand;
    if ([cellLayOut needUpdateHeightCacheForWidth:width]) {
        [cellLayOut updateFrameForData:orderedData cellWidth:width listType:listType];
    }
    
    CGFloat height = cellLayOut.cellCacheHeight;
    if (height > 0) {
        if ([orderedData hasTopPadding]) {
            if ([orderedData nextCellHasTopPadding]){
                height -= kUFSeprateViewHeight();
            }
            if ([orderedData preCellHasBottomPadding]) {
                height -= kUFSeprateViewHeight();
            }
            if (height > 0) {
                return height;
            }
        }
        else{
            return height;
        }
    }
    return 0;
}

- (ExploreCellStyle)cellStyle {
    if ([self.orderedData isUnifyADCell]){
        return ExploreCellStyleUnknown;
    }
    return ExploreCellStyleArticle;
}

- (ExploreCellSubStyle)cellSubStyle {
    if ([self.orderedData isUnifyADCell]){
        return ExploreCellSubStyleUnknown;
    }
    return ExploreCellSubStyleLargePic;
}

//- (UIView *)animationFromView
//{
//    return self.panoramaView;
//}
//
//- (UIImage *)animationFromImage
//{
//    return self.panoramaView.panoramaView.snapshot;
//}

-(void)willDisplay
{
    if (!self.panoramaView.panoramaView.tableView) {
        self.panoramaView.panoramaView.tableView = self.tableView;
    }
    [self.panoramaView willDisplay];
}

- (void)didEndDisplaying
{
    [self.panoramaView didEndDisplaying];
}

- (void)resumeDisplay
{
    [self.panoramaView resumeDisplay];
}

@end
