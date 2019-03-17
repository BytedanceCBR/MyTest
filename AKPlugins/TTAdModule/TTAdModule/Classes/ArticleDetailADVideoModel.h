//
//  ArticleDetailADVideoModel.h
//  Article
//
//  Created by huic on 16/5/5.
//
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@interface ArticleDetailADVideoModel : JSONModel
@property (nonatomic, copy) NSString<Optional> *coverURL;
@property (nonatomic, copy) NSString *videoID;
@property (nonatomic, assign) NSInteger videoDuration;
@property (nonatomic, assign) CGFloat  videoWidth;
@property (nonatomic, assign) CGFloat  videoHeight;
@end
