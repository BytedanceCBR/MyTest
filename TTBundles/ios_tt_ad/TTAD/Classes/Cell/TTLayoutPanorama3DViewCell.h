//
//  TTArticlePanorama3DViewCell.h
//  Article
//
//  Created by rongyingjie on 2017/11/1.
//

#import "ExploreCellBase.h"
#import "TTLayOutCellViewBase.h"
#import "TTArticlePanorama3DView.h"

@interface TTLayoutPanorama3DViewCell : ExploreCellBase

@end

@interface  TTLayoutPanorama3DCellView: TTLayOutCellViewBase

@property (nonatomic, strong) TTArticlePanorama3DView  *panoramaView;      //全景广告

- (void)willDisplay;

- (void)didEndDisplaying;

- (void)resumeDisplay;

@end
