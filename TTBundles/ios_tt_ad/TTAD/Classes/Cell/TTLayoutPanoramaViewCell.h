//
//  TTLayoutPanoramaCellView.h
//  Article
//
//  Created by rongyingjie on 2017/8/6.
//
//

#import "ExploreCellBase.h"
#import "TTLayOutCellViewBase.h"
#import "TTArticlePanoramaView.h"

@interface TTLayoutPanoramaViewCell : ExploreCellBase

@end

@interface  TTLayoutPanoramaCellView: TTLayOutCellViewBase

@property (nonatomic, strong) TTArticlePanoramaView     *panoramaView;      //全景广告

-(void)willDisplay;

- (void)didEndDisplaying;

- (void)resumeDisplay;

@end
