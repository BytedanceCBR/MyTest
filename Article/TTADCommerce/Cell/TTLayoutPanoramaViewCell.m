//
//  TTLayoutPanoramaViewCellView.m
//  Article
//
//  Created by rongyingjie on 2017/8/6.
//
//

#import "TTLayoutPanoramaViewCell.h"
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

@interface TTLayoutPanoramaViewCell ()

@property (nonatomic, strong) TTLayoutPanoramaCellView *loopPicCellView;

@end

@implementation TTLayoutPanoramaViewCell

+ (Class)cellViewClass
{
    return [TTLayoutPanoramaCellView class];
}

-(void)willDisplay{
    [(TTLayoutPanoramaCellView *)self.cellView willDisplay];
}


- (void)didEndDisplaying {
    [(TTLayoutPanoramaCellView *)self.cellView didEndDisplaying];
}

- (void)resumeDisplay {
    [(TTLayoutPanoramaCellView *)self.cellView resumeDisplay];
}

@end

@implementation TTLayoutPanoramaCellView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        TTArticlePanoramaView *panoramaView = [TTArticlePanoramaView new];
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
//    return [self.panoramaView animationFromView].image;
//}

-(void)willDisplay
{
    if (!self.panoramaView.motionView.tableView) {
        self.panoramaView.motionView.tableView = self.tableView;
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
