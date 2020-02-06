//
//  TTWrongWordsReportModel.h
//  TTUIWidget
//
//  Created by chenbb6 on 2019/10/14.
//

#import <TTReporter/TTReportManager.h>

/* 设置反馈错别字上传、埋点所需要的字段 */
@interface TTWrongWordsReportModel : NSObject

/// 用户反馈正确词
@property(nonatomic, copy) NSString *repoRightWords;

/// 错别字及上下文
@property(nonatomic ,copy) NSArray *wrongWordsSelectedArray;

/// 举报信息Model
@property (nonatomic, strong, nullable) TTReportContentModel *contentModel;

/// Context上下文
@property (nonatomic, copy) NSString *enterFrom;
@property (nonatomic, copy) NSString *categoryId;

// 内容类型
@property (nonatomic, copy, nullable) NSString *contentType;

/// 默认为空
@property (nonatomic, copy) NSString *extra;

@end
