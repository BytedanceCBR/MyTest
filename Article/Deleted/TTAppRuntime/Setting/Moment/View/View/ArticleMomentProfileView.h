//
//  ArticleMomentProfileView.h
//  Article
//
//  Created by Zhang Leonardo on 14-5-26.
//
//

#import "SSViewBase.h"
#import "SSUserModel.h"
#import "ArticleMomentListViewBase.h"

@interface ArticleMomentProfileView : ArticleMomentListViewBase

// https://wiki.bytedance.com/pages/viewpage.action?pageId=15142000
@property (nonatomic, copy) NSString *from; // 用于统计来源

- (instancetype)initWithFrame:(CGRect)frame userModel:(SSUserModel *)model extraTracks:(NSDictionary *)extraTracks;
@end
