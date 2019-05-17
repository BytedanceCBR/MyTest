//
//  TTFollowingMergeCell.h
//  Article
//
//  Created by lizhuoli on 17/1/8.
//
//

#import "TTSocialBaseCell.h"
#import "TTNewFollowingResponseModel.h"

@interface TTFollowingMergeCell : TTSocialBaseCell

@property (nonatomic, copy) NSString *tipsCount;
@property (nonatomic, assign) BOOL tips;

- (void)reloadWithFollowingModel:(TTFollowingMergeResponseModel *)model;

@end
