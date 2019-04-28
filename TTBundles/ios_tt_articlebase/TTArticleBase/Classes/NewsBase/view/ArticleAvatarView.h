//
//  ArticleAvatarView.h
//  Article
//
//  Created by Zhang Leonardo on 13-1-22.
//
//

#import "SSAvatarView+VerifyIcon.h"

@interface ArticleAvatarView : SSAvatarView

@property(nonatomic, assign)BOOL alwaysShow; //default is no. If is no , whether show image will decide by [NewsUserSettingManager imageSettingType]

@end
