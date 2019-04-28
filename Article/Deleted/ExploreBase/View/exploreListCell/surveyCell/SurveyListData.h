//
//  SurveyListData.h
//  Article
//
//  Created by chenren on 9/05/17.
//
//

#import "ExploreOriginalData.h"
#import "Article.h"

@interface SurveyListData : ExploreOriginalData

@property (nullable, nonatomic, copy) NSString *title;  //主标题
@property (nullable, nonatomic, strong) NSMutableArray *selectionInfos; //选项信息

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL fixed;
@property (nonatomic, assign) BOOL hideNextTime;
@property (nullable, nonatomic, strong) id evaluateID;
@property (nonatomic, assign) CGFloat height;

@end

@interface SurveySelectionInfo : NSObject

@property (nonatomic, assign) NSInteger infoID;
@property (nullable, nonatomic, copy) NSString *label;

@end
