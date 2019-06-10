//
//  TTEditPGCProfileViewModel.h
//  Article
//
//  Created by Zuopeng Liu on 7/15/16.
//
//

#import <Foundation/Foundation.h>
#import "TTEditUserProfileViewModel.h"



/**
 *  考虑到重名信息的检查和介绍信息的不和谐内容检测问题，PGC用户信息，分两步上传
 *  1. 首先上传头像信息，返回图片URL
 *  2. 上传用户名、描述和步骤1返回头像的URL地址
 */
@interface TTEditPGCProfileViewModel : TTEditUserProfileViewModel
@end
