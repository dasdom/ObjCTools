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
    
    XCTAssertEqualObjects(lines[1], @"#import \"Foobar.h\"");
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
    NSMutableArray *lines = [NSMutableArray new];
    [lines addObject:@"Foo"];
    [lines addObject:@"Bar"];
    
    [SourceEditorMethods dublicateLine:@"Foo" lineNumber:0 inLines:lines replaceStrings:false];
    
    XCTAssertEqualObjects(lines[1], @"Foo");
}

- (void)test_dublicateLine_2 {
    NSMutableArray *lines = [NSMutableArray new];
    [lines addObject:@"NSString *string = [NSString stringWithString:@\"foo\"];"];
    [lines addObject:@"Bar"];
    
    [SourceEditorMethods dublicateLine:lines.firstObject lineNumber:0 inLines:lines replaceStrings:false];
    
    XCTAssertEqualObjects(lines[1], @"NSString *string = [NSString stringWithString:@\"foo\"];");
}

- (void)test_dublicateLineAndReplaceString_objc {
    NSMutableArray *lines = [NSMutableArray new];
    [lines addObject:@"NSString *string = @\"foo\";"];
    [lines addObject:@"Bar"];
    
    [SourceEditorMethods dublicateLine:lines.firstObject lineNumber:0 inLines:lines replaceStrings:true];
    
    XCTAssertEqualObjects(lines[1], @"NSString *string = @\"<#string#>\";");
}

- (void)test_dublicateLineAndReplaceString_swift {
    NSMutableArray *lines = [NSMutableArray new];
    [lines addObject:@"let string = \"foo\""];
    [lines addObject:@"Bar"];
    
    [SourceEditorMethods dublicateLine:lines.firstObject lineNumber:0 inLines:lines replaceStrings:true];
    
    XCTAssertEqualObjects(lines[1], @"let string = \"<#string#>\"");
}

- (void)test_sortImportsAndRemoveDoublicates_objc_1 {
    NSMutableArray *lines = [NSMutableArray new];
    [lines addObject:@"#import \"Foo.h\""];
    [lines addObject:@"#import \"Foo.h\""];
    [lines addObject:@"#import \"Foo.h\""];
    [lines addObject:@"#import \"Bar.h\""];

    [SourceEditorMethods sortImportsAndRemoveDublicatesInLines:lines];
    
    XCTAssertEqual([lines count], 2);
    XCTAssertEqualObjects(lines[0] , @"#import \"Bar.h\"");
    XCTAssertEqualObjects(lines[1], @"#import \"Foo.h\"");
}

- (void)test_sortImportsAndRemoveDoublicates_objc_2 {
    NSMutableArray *lines = [NSMutableArray new];
    [lines addObject:@"#import \"Bar.h\""];
    [lines addObject:@"#import \"Foo.h\""];
    
    [SourceEditorMethods sortImportsAndRemoveDublicatesInLines:lines];
    
    XCTAssertEqual([lines count], 2);
    XCTAssertEqualObjects(lines[0] , @"#import \"Bar.h\"");
    XCTAssertEqualObjects(lines[1], @"#import \"Foo.h\"");
}

- (void)test_sortImportsAndRemoveDoublicates_swift {
    NSMutableArray *lines = [NSMutableArray new];
    [lines addObject:@"import Foo"];
    [lines addObject:@"import Foo"];
    [lines addObject:@"import Foo"];
    [lines addObject:@"import Bar"];
    
    [SourceEditorMethods sortImportsAndRemoveDublicatesInLines:lines];
    
    XCTAssertEqual([lines count], 2);
    XCTAssertEqualObjects(lines[0] , @"import Bar");
    XCTAssertEqualObjects(lines[1], @"import Foo");
}

- (void)test_hexToUIColor_objc {
    NSMutableArray *lines = [NSMutableArray new];
    [lines addObject:@"// #FFa004ce"];
    
    [SourceEditorMethods hexToUIColorFromSelectedString:@"#FFa004ce" lineNumber:0 inLines:lines indentation:@"  " contentUTI:@".objective-c-source"];
    
    XCTAssertEqualObjects(lines[1], @"  UIColor *<#name#> = [UIColor colorWithRed:1.000 green:0.627 blue:0.016 alpha:0.808];");
}

- (void)test_hexToUIColor_swift {
    NSMutableArray *lines = [NSMutableArray new];
    [lines addObject:@"// #FFa004ce"];
    
    [SourceEditorMethods hexToUIColorFromSelectedString:@"#FFa004ce" lineNumber:0 inLines:lines indentation:@"  " contentUTI:@".swift-source"];
    
    XCTAssertEqualObjects(lines[1], @"  let <#name#> = UIColor(red: 1.000, green: 0.627, blue: 0.016, alpha: 0.808)");
}

@end
