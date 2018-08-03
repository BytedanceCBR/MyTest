//
//  TTAdCanvasProjectModel+Resource.h
//  Article
//
//  Created by carl on 2017/8/11.
//
//

#import "TTAdCanvasModel.h"
#import "TTAdCanvasDefine.h"

@interface TTAdCanvasProjectModel (Resource)

/**
 打开沉浸式 ☝️宽松条件
 @return 必选资源是否OK， 沉浸式唯一必选资源 layout布局
 */
- (BOOL)checkRequiredResource;

/**
 打开沉浸式 第二宽松条件
 CPC 默认打开限制
 @return 必选资源是否OK 标记图片是否 OK
 */
- (BOOL)checkFlagResource;

/**
 CPT 默认打开限制
 @return 必选资源OK 图片 OK
 */
- (BOOL)checkAllResource;

- (BOOL)checkResource;

@end
