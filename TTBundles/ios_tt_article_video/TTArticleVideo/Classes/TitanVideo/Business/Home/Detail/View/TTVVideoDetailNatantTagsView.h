//
//  TTVVideoDetailNatantTagsView.h
//  Article
//
//  Created by pei yun on 2017/5/26.
//
//

#import <TTThemed/SSThemed.h>
#import <TTVideoService/VideoInformation.pbobjc.h>

typedef NS_ENUM(NSInteger, TTVideoDetailSearchTagPosition) {
    TTVideoDetailSearchTagPositionUnknown = 0,
    TTVideoDetailSearchTagPositionTop,
    TTVideoDetailSearchTagPositionBelowRelatedVideo,
    TTVideoDetailSearchTagPositionAboveComment,
};

@protocol TTVVideoDetailNatantTagsViewDataProtocol <NSObject>

@property(nonatomic, strong, readonly) TTVVideoDetailTags *videoDetailTags;

@end

@interface TTVVideoDetailNatantTagsView : SSThemedView

@property (nonatomic, strong) id<TTVVideoDetailNatantTagsViewDataProtocol> viewModel;
@property (nonatomic, assign) TTVideoDetailSearchTagPosition tagPosition;

@end
