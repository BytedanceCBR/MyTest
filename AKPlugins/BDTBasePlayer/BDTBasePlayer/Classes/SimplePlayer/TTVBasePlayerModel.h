//
//  TTVBasePlayerModel.h
//  Article
//
//  Created by panxiang on 2017/9/20.
//
//

#import "TTVPlayerModel.h"

@interface TTVBasePlayerModel : TTVPlayerModel

/**
 打开 进入后台暂停,进入全台播放管理 ,默认关闭
 */
@property (nonatomic, assign) BOOL enableBackgroundManager;
@end
