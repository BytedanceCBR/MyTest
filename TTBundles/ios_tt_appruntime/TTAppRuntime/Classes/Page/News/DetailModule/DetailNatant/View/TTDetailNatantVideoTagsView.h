//
//  TTDetailNatantVideoTagsView.h
//  Article
//
//  Created by xiangwu on 2016/12/6.
//
//

#import "TTDetailNatantViewBase.h"

typedef NS_ENUM(NSInteger, TTVideoDetailSearchTagPosition) {
    TTVideoDetailSearchTagPositionUnknown = 0,
    TTVideoDetailSearchTagPositionTop,
    TTVideoDetailSearchTagPositionBelowRelatedVideo,
    TTVideoDetailSearchTagPositionAboveComment,
};

@interface TTDetailNatantVideoTagsView : TTDetailNatantViewBase

@property (nonatomic, assign) TTVideoDetailSearchTagPosition tagPosition;

@end
