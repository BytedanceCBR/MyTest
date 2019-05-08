//
//  FHHouseBaseTests.m
//  FHHouseBaseTests
//
//  Created by leo on 2018/11/16.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <FHHouseBase/FHHouseBase.h>
#import <RXCollections/RXCollection.h>
@interface FHHouseBaseTests : XCTestCase

@end

@implementation FHHouseBaseTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testParseSearchConfig {
    NSDictionary* dict = [self readLocalFileWithName:@"search_config"];
    NSArray* areaConfig = [self selectCourtAreaFilter:dict];
    XCTAssertNotNil(areaConfig);
    [self measureBlock:^{

        NSMutableArray* result = [[NSMutableArray alloc] init];
        [areaConfig enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [result addObject:[FHFilterNodeModelConverter convertDictToModel:obj]];
        }];
        XCTAssertEqual(2, [result count]);
        FHFilterNodeModel* model = (FHFilterNodeModel*)result[0];
        XCTAssertNotNil(model.label);
        XCTAssertTrue([@"区域" isEqualToString:model.label]);
        XCTAssertTrue(model.isSupportMulti);
        XCTAssertNotNil(model.key);
        XCTAssertNotNil(model.children);
        FHFilterNodeModel* areaCollection = model.children[1];
        XCTAssertNotNil(areaCollection.label);
        XCTAssertTrue([@"宝安" isEqualToString:areaCollection.label]);
        XCTAssertTrue(areaCollection.isSupportMulti);
        XCTAssertNotNil(areaCollection.key);
        XCTAssertNotNil(areaCollection.value);
        XCTAssertEqual(0, areaCollection.isEmpty);
        XCTAssertEqual(0, areaCollection.isNoLimit);
        XCTAssertNotNil(areaCollection.children);

        FHFilterNodeModel* district = areaCollection.children[1];
        XCTAssertNotNil(district.label);
        XCTAssertTrue([@"宝安中心区" isEqualToString:district.label]);
        XCTAssertTrue(district.isSupportMulti);
        XCTAssertNotNil(district.key);
        XCTAssertNotNil(district.value);
        XCTAssertEqual(0, district.isEmpty);
        XCTAssertEqual(0, district.isNoLimit);
        XCTAssertEqual(0, [district.children count]);
    }];


}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

-(NSDictionary*)readLocalFileWithName:(NSString *)name {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:name ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

-(NSArray*)selectCourtAreaFilter:(NSDictionary*)dict {
    NSArray* configs = [dict valueForKeyPath:@"data.court_filter"];
    return configs[0][@"options"];
}

@end
