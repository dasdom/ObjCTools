//  Created by dasdom on 12.08.18.
//  Copyright © 2018 dasdom. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SourceEditorMethods.h"

@interface SourceEditorMethodsTests : XCTestCase

@end

@implementation SourceEditorMethodsTests

- (void)test_addImportStatementFromSelection_1 {
    NSMutableArray *lines = [NSMutableArray new];
    [lines addObject:@"#import <Foundation/Foundation.h>"];
    [lines addObject:@"@implementation Bar"];
    [lines addObject:@"@end"];

    [SourceEditorMethods addImportStatementFromSelectedString:@"Foobar" toLines:lines];
    
    NSString *lastLine = lines[1];
    XCTAssertEqualObjects(lastLine, @"#import \"Foobar.h\"");
}

- (void)test_addImportStatementFromSelection_2 {
    NSMutableArray *lines = [NSMutableArray new];
    [lines addObject:@"@interface Bar"];
    [lines addObject:@"@end"];
    
    [SourceEditorMethods addImportStatementFromSelectedString:@"Foobar" toLines:lines];
    
    XCTAssertEqualObjects(lines[0], @"#import \"Foobar.h\"");
    XCTAssertEqualObjects(lines[1], @"");
}

- (void)test_addImportStatementFromSelection_3 {
    NSMutableArray *lines = [NSMutableArray new];
    [lines addObject:@"@implementation Bar"];
    [lines addObject:@"@end"];
    
    [SourceEditorMethods addImportStatementFromSelectedString:@"Foobar" toLines:lines];
    
    XCTAssertEqualObjects(lines[0], @"#import \"Foobar.h\"");
    XCTAssertEqualObjects(lines[1], @"");
}

- (void)test_dublicateLine_1 {
    XCTFail(@"implement test");
}

@end
