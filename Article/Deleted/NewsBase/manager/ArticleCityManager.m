//
//  ArticleCityManager.m
//  Article
//
//  Created by Kimimaro on 13-6-13.
//
//

#import "ArticleCityManager.h"
#import "ArticleURLSetting.h"
#import "TTNetworkManager.h"
#define kArticleCitySavedCitiesUserDefaultKey @"kArticleCitySavedCitiesUserDefaultKey"
#define kCityAPINameKey @"name"
#define kCityAPICitiesKey @"cities"

#define RequestCitiesTimeInterval (3*24*60*60)


@interface ArticleCityManager ()
@property (nonatomic, retain, readwrite) NSArray *groupedCities;
@property (nonatomic, retain) NSDate *lastRequestDate;
@end


@implementation ArticleCityManager

- (void)dealloc
{
}

static ArticleCityManager *_sharedManager = nil;
+ (ArticleCityManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

+ (id)alloc
{
    NSAssert(_sharedManager == nil, @"Attempt to alloc second instance for a singleton.");
    return [super alloc];
}

#pragma mark - user defaults

+ (NSArray *)savedCities
{
    NSArray *cities = [[NSUserDefaults standardUserDefaults] objectForKey:kArticleCitySavedCitiesUserDefaultKey];
    if (!cities) {
        return @[@{@"A": @[@"安庆", @"安阳", @"鞍山", @"安康"]},
                 @{@"B": @[@"北京", @"滨州", @"蚌埠", @"包头", @"宝鸡", @"保定"]},
                 @{@"C": @[@"重庆", @"成都", @"长春", @"长沙", @"常州", @"常德", @"滁州", @"郴州", @"承德"]},
                 @{@"D": @[@"大连", @"东莞", @"德州", @"大同", @"达州"]},
                 @{@"F": @[@"福州"]},
                 @{@"G": @[@"广州", @"贵阳", @"桂林", @"赣州", @"广元", @"广安"]},
                 @{@"H": @[@"合肥", @"杭州", @"哈尔滨", @"海口", @"淮北", @"惠州", @"邯郸", @"呼和浩特"]},
                 @{@"J": @[@"济南", @"九江", @"吉林", @"嘉兴", @"济宁", @"金华", @"焦作", @"酒泉"]},
                 @{@"K": @[@"昆明", @"开封"]},
                 @{@"L": @[@"兰州", @"娄底", @"泸州", @"洛阳", @"聊城", @"连云港", @"临沂", @"六安", @"柳州", @"廊坊", @"淄博"]},
                 @{@"M": @[@"绵阳", @"眉山", @"马鞍山"]},
                 @{@"N": @[@"南京", @"宁波", @"南昌", @"南宁", @"宁德", @"南通", @"南阳"]},
                 @{@"P": @[@"平顶山", @"莆田", @"盘锦"]},
                 @{@"Q": @[@"青岛", @"泉州", @"齐齐哈尔", @"衢州"]},
                 @{@"S": @[@"深圳", @"上海", @"沈阳", @"石家庄", @"苏州", @"绍兴", @"十堰", @"宿迁", @"三亚", @"商洛", @"邵阳", @"宿州", @"绥化", @"遂宁"]},
                 @{@"T": @[@"太原", @"台州", @"唐山"]},
                 @{@"W": @[@"武汉", @"无锡", @"乌鲁木齐", @"潍坊", @"威海", @"温州", @"芜湖"]},
                 @{@"X": @[@"西安", @"厦门", @"湘潭", @"西宁", @"邢台", @"咸阳", @"信阳"]},
                 @{@"Y": @[@"烟台", @"雅安", @"宜昌", @"宜宾", @"岳阳", @"银川", @"永州", @"盐城", @"榆林"]},
                 @{@"Z": @[@"郑州", @"株洲", @"中山", @"扬州", @"珠海", @"枣庄", @"镇江", @"张家口", @"漳州", @"湛江", @"资阳", @"遵义", @"周口"]},
                 ];
    }
    else {
        return cities;
    }
}

+ (void)setSavedCities:(NSArray *)cities
{
    [[NSUserDefaults standardUserDefaults] setObject:cities forKey:kArticleCitySavedCitiesUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - setter&getter

- (NSArray *)groupedCities
{
    if (!_groupedCities) {
        [self updateCities];
        self.groupedCities = [ArticleCityManager savedCities];
    }
    
    if (_lastRequestDate) {
        NSDate *intervalDate = [NSDate dateWithTimeInterval:RequestCitiesTimeInterval sinceDate:_lastRequestDate];
        if ([intervalDate earlierDate:[NSDate date]] == intervalDate) {
            [self updateCities];
        }
    }
    
    return _groupedCities;
}

#pragma mark - load cities

- (void)updateCities
{
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting cityURLString] params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (!error) {
            NSArray *resultCities = [jsonObj objectForKey:@"data"];
            self.groupedCities = [self handleResultCities:resultCities];
            [ArticleCityManager setSavedCities:_groupedCities];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(cityManager:updateFinishedResult:error:)]) {
            [_delegate cityManager:self updateFinishedResult:jsonObj error:error];
        }
    }];
    
    self.lastRequestDate = [NSDate date];
}

#pragma mark - handle data

- (NSArray *)citiesOfName:(NSString *)name inResultCities:(NSArray *)resultCities
{
    __block NSArray *ret = nil;
    [resultCities enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSString *objName = [obj objectForKey:kCityAPINameKey];
        if ([objName isEqualToString:name]) {
            ret = [obj objectForKey:kCityAPICitiesKey];
            *stop = YES;
        }
    }];
    return ret;
}

- (NSArray *)handleResultCities:(NSArray *)resultCities
{
    NSMutableArray *cityNames = [NSMutableArray arrayWithCapacity:30];
    NSMutableArray *citiesForName = [NSMutableArray arrayWithCapacity:30];
    
    [resultCities enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        [cityNames addObject:[obj objectForKey:@"name"]];
    }];
    
    [cityNames sortUsingComparator:^NSComparisonResult(NSString *aName, NSString *anotherName) {
        return [aName compare:anotherName];
    }];
    
    [cityNames enumerateObjectsUsingBlock:^(NSString *nameKey, NSUInteger idx, BOOL *stop) {
        NSDictionary *cityDict = @{nameKey : [self citiesOfName:nameKey inResultCities:resultCities]};
        [citiesForName addObject:cityDict];
    }];
    
    return [citiesForName copy];
}

@end
