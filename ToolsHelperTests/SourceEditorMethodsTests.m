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

- (void)test_addClassDeclaration_1 {
    NSMutableArray *lines = [NSMutableArray new];
    [lines addObject:@"#import <Foundation/Foundation.h>"];
    [lines addObject:@"@implementation Bar"];
    [lines addObject:@"@end"];
    
    [SourceEditorMethods addClassDeclarationFromSelectedString:@"Foobar" toLines:lines];
    
    XCTAssertEqualObjects(lines[1], @"");
    XCTAssertEqualObjects(lines[2], @"@class Foobar;");
}

- (void)test_addClassDeclaration_2 {
    NSMutableArray *lines = [NSMutableArray new];
    [lines addObject:@"#import <Foundation/Foundation.h>"];
    [lines addObject:@"@class Bar;"];
    [lines addObject:@"@implementation Bar"];
    [lines addObject:@"@end"];
    
    [SourceEditorMethods addClassDeclarationFromSelectedString:@"Foobar" toLines:lines];
    
    XCTAssertEqualObjects(lines[1], @"@class Bar;");
    XCTAssertEqualObjects(lines[2], @"@class Foobar;");
}

- (void)test_addClassDeclaration_3 {
    NSMutableArray *lines = [NSMutableArray new];
    [lines addObject:@"@implementation Bar"];
    [lines addObject:@"@end"];
    
    [SourceEditorMethods addClassDeclarationFromSelectedString:@"Foobar" toLines:lines];
    
    XCTAssertEqualObjects(lines[0], @"@class Foobar;");
    XCTAssertEqualObjects(lines[1], @"");
}

- (void)test_addClassDeclaration_4 {
    NSMutableArray *lines = [NSMutableArray new];
    [lines addObject:@"@interface Bar"];
    [lines addObject:@"@end"];
    
    [SourceEditorMethods addClassDeclarationFromSelectedString:@"Foobar" toLines:lines];
    
    XCTAssertEqualObjects(lines[0], @"@class Foobar;");
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

- (void)test_declarationForString_simple {
    
    NSString *result = [SourceEditorMethods declarationForStrings:@[@"- (void)foo {"]];
    
    XCTAssertEqualObjects(result, @"- (void)foo;");
}

- (void)test_declarationForString_twoMethods {
    NSArray<NSString *> *input = @[@"- (void)foo {\n", @"    return;\n", @"}\n", @"-(NSInteger)bar {\n"];
    
    NSString *result = [SourceEditorMethods declarationForStrings:input];
    
    XCTAssertEqualObjects(result, @"- (void)foo;\n-(NSInteger)bar;");
}

- (void)test_declarationForString_multiline {
    NSArray<NSString *> *input = @[@"- (NSString *)foo:(NSInteger)foo\n", @"bar:(NSData *)bar {\n"];
    
    NSString *result = [SourceEditorMethods declarationForStrings:input];

    XCTAssertEqualObjects(result, @"- (NSString *)foo:(NSInteger)foo\nbar:(NSData *)bar;");
}

- (void)test_declarationForString_multiline_2 {
    NSArray *input = @[@"- (NSString *)foo:(NSInteger)foo\n",
                       @"              bar:(NSData *)bar\n",
                       @"              ber:(NSData *)ber\n",
                       @"              bur:(NSData *)bur {\n",
                       @"    return @\"Blablub\";\n",
                       @"}\n"];
    
    NSString *result = [SourceEditorMethods declarationForStrings:input];
    
    XCTAssertEqualObjects(result, @"- (NSString *)foo:(NSInteger)foo\n              bar:(NSData *)bar\n              ber:(NSData *)ber\n              bur:(NSData *)bur;");
}

- (void)test_alignEquals2Lines {
    NSArray<NSString *> *input =
    @[
      @"window.maxSize = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX);",
      @"window.contentViewController = contentViewController;",
      ];
    
    NSArray<NSString *> *result = [SourceEditorMethods alignEquals:input];
    
    NSArray<NSString *> *expectedResult =
    @[
      @"window.maxSize               = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX);",
      @"window.contentViewController = contentViewController;",
      ];
    XCTAssertEqualObjects(result, expectedResult);
}

- (void)test_alignEquals2Lines_2 {
    NSArray<NSString *> *input =
    @[
      @"window.maxSize                   = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX);",
      @"window.contentViewController     = contentViewController;",
      ];
    
    NSArray<NSString *> *result = [SourceEditorMethods alignEquals:input];
    
    NSArray<NSString *> *expectedResult =
    @[
      @"window.maxSize               = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX);",
      @"window.contentViewController = contentViewController;",
      ];
    XCTAssertEqualObjects(result, expectedResult);
}

- (void)test_alignEquals5Lines {
    NSArray<NSString *> *input =
    @[
      @"window.maxSize = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX);",
      @"window.contentViewController = contentViewController;",
      @"window.delegate = contentViewController;",
      @"window.titleVisibility = NSWindowTitleHidden;",
      @"window.tabbingMode = NSWindowTabbingModeDisallowed;",
      ];
    
    NSArray<NSString *> *result = [SourceEditorMethods alignEquals:input];
    
    NSArray<NSString *> *expectedResult =
    @[
      @"window.maxSize               = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX);",
      @"window.contentViewController = contentViewController;",
      @"window.delegate              = contentViewController;",
      @"window.titleVisibility       = NSWindowTitleHidden;",
      @"window.tabbingMode           = NSWindowTabbingModeDisallowed;",
      ];
    XCTAssertEqualObjects(result, expectedResult);
}

- (void)test_alignEqualsWithInterceptedLine {
    NSArray<NSString *> *input =
    @[
      @"window.maxSize = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX);",
      @"window.contentViewController = contentViewController;",
      @"[foo bar];",
      @"window.titleVisibility = NSWindowTitleHidden;",
      @"window.tabbingMode = NSWindowTabbingModeDisallowed;",
      ];
    
    NSArray<NSString *> *result = [SourceEditorMethods alignEquals:input];
    
    NSArray<NSString *> *expectedResult =
    @[
      @"window.maxSize               = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX);",
      @"window.contentViewController = contentViewController;",
      @"[foo bar];",
      @"window.titleVisibility       = NSWindowTitleHidden;",
      @"window.tabbingMode           = NSWindowTabbingModeDisallowed;",
      ];
    XCTAssertEqualObjects(result, expectedResult);
}

- (void)test_alignEquals_ignoresComments {
  NSArray<NSString *> *input =
  @[
    @"// foo    = bar",
    @"window.maxSize = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX);",
    @"window.contentViewController = contentViewController;",
    ];
  
  NSArray<NSString *> *result = [SourceEditorMethods alignEquals:input];
  
  NSArray<NSString *> *expectedResult =
  @[
    @"// foo    = bar",
    @"window.maxSize               = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX);",
    @"window.contentViewController = contentViewController;",
    ];
  XCTAssertEqualObjects(result, expectedResult);
}

- (void)test_alignEquals_ignoresMultilineComments {
    NSArray<NSString *> *input =
    @[
      @" foo    = bar",
      @" bla    = blub */",
      @"window.maxSize = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX);",
      @"window.contentViewController = contentViewController;",
      ];
    
    NSArray<NSString *> *result = [SourceEditorMethods alignEquals:input];
    
    NSArray<NSString *> *expectedResult =
    @[
      @" foo    = bar",
      @" bla    = blub */",
      @"window.maxSize               = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX);",
      @"window.contentViewController = contentViewController;",
      ];
    XCTAssertEqualObjects(result, expectedResult);
}

- (void)test_alignEquals_ignoresMultilineComments_2 {
    NSArray<NSString *> *input =
    @[
      @"window.tabbingMode = NSWindowTabbingModeDisallowed;",
      @" /** bla bla blubb",
      @" foo    = bar",
      @" bla    = blub",
      @" */",
      @"window.maxSize = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX);",
      @"window.contentViewController = contentViewController;",
      ];
    
    NSArray<NSString *> *result = [SourceEditorMethods alignEquals:input];
    
    NSArray<NSString *> *expectedResult =
    @[
      @"window.tabbingMode           = NSWindowTabbingModeDisallowed;",
      @" /** bla bla blubb",
      @" foo    = bar",
      @" bla    = blub",
      @" */",
      @"window.maxSize               = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX);",
      @"window.contentViewController = contentViewController;",
      ];
    XCTAssertEqualObjects(result, expectedResult);
}

- (void)test_sortSelectedLines_alreadySorted {
    NSArray<NSString *> *input =
    @[
      @"a",
      @"b"
      ];
    
    NSArray<NSString *> *result = [SourceEditorMethods sortSelectedLines:input];
    
    NSArray<NSString *> *expectedResult =
    @[
      @"a",
      @"b"
      ];
    XCTAssertEqualObjects(result, expectedResult);
}

- (void)test_sortSelectedLines {
    NSArray<NSString *> *input =
    @[
      @"a",
      @"c",
      @"b"
      ];
    
    NSArray<NSString *> *result = [SourceEditorMethods sortSelectedLines:input];
    
    NSArray<NSString *> *expectedResult =
    @[
      @"a",
      @"b",
      @"c"
      ];
    XCTAssertEqualObjects(result, expectedResult);
}

- (void)test_protocolFromSelectedMethods_objC {
    NSArray<NSString *> *input =
    @[
      @"+ (void)foo {\n",
      @"    return;\n",
      @"}\n",
      @"-(NSInteger)bar {\n"
      ];
    
    NSString *result = [SourceEditorMethods protocolFromMethodsInLines:input indentation:@"  " contentUTI:@".objective-c-source"];
    
    NSString *expectedResult = @"@protocol <#Protocol Name#> <NSObject>\n+ (void)foo;\n-(NSInteger)bar;\n@end\n";
    XCTAssertEqualObjects(result, expectedResult);
}

- (void)test_protocolFromSelectedMethods_objC_2 {
    NSArray *input = @[@"- (NSString *)foo:(NSInteger)foo\n",
                       @"              bar:(NSData *)bar\n",
                       @"              ber:(NSData *)ber\n",
                       @"              bur:(NSData *)bur {\n",
                       @"    return @\"Blablub\";\n",
                       @"}\n"];
    
    NSString *result = [SourceEditorMethods protocolFromMethodsInLines:input indentation:@"  " contentUTI:@".objective-c-source"];
    
    NSString *expectedResult = @"@protocol <#Protocol Name#> <NSObject>\n- (NSString *)foo:(NSInteger)foo\n              bar:(NSData *)bar\n              ber:(NSData *)ber\n              bur:(NSData *)bur;\n@end\n";
    XCTAssertEqualObjects(result, expectedResult);
}

- (void)test_protocolFromSelectedMethods_swift {
    NSArray<NSString *> *input =
    @[
      @"    func foo() {\n",
      @"        return\n",
      @"    }\n",
      @"\n",
      @"    func bar(foobar: String) {\n",
      ];
    
    NSString *result = [SourceEditorMethods protocolFromMethodsInLines:input indentation:@"  " contentUTI:@".swift-source"];
    
    NSString *expectedResult = @"protocol <#Protocol Name#> {\nfunc foo()\nfunc bar(foobar: String)\n}\n";
    XCTAssertEqualObjects(result, expectedResult);
}

- (void)test_objCTestTemplateFromMethodInLine_objC {
    NSArray *input = @[@"- (UIViewController *)foo:(NSString *)foo bar:(NSInteger)42 {"];
    
    NSString *result = [SourceEditorMethods objCTestTemplateFromMethodInLines:input indentation:@"  "];
    
    NSString *expectedResult = @"- (void)test_<#test method name#> {\n  // Arrange\n\n\n  // Act\n  UIViewController *<#result#> = [self.sut foo:<#param#> bar:<#param#>];\n\n  // Assert\n\n}";
    XCTAssertEqualObjects(result, expectedResult);
}

- (void)test_objCTestTemplateFromMethodInLine_objC_2 {
    NSArray *input = @[@"- (NSInteger)foo:(NSString *)foo bar:(NSInteger)42 {"];
    
    NSString *result = [SourceEditorMethods objCTestTemplateFromMethodInLines:input indentation:@"  "];
    
    NSString *expectedResult = @"- (void)test_<#test method name#> {\n  // Arrange\n\n\n  // Act\n  NSInteger <#result#> = [self.sut foo:<#param#> bar:<#param#>];\n\n  // Assert\n\n}";
    XCTAssertEqualObjects(result, expectedResult);
}

- (void)test_objCTestTemplateFromMethodInLine_objC_3 {
    NSArray *input = @[@"- (NSString *)blabla {"];
    
    NSString *result = [SourceEditorMethods objCTestTemplateFromMethodInLines:input indentation:@"  "];
    
    NSString *expectedResult = @"- (void)test_<#test method name#> {\n  // Arrange\n\n\n  // Act\n  NSString *<#result#> = [self.sut blabla];\n\n  // Assert\n\n}";
    XCTAssertEqualObjects(result, expectedResult);
}

- (void)test_objCTestTemplateFromMethodInLine_objC_4 {
    NSArray *input = @[@"- (NSString *)foo:(NSInteger)foo\n",
                       @"              bar:(NSData *)bar {\n",
                       @"    return @\"Blablub\";\n",
                       @"}\n"];
    
    NSString *result = [SourceEditorMethods objCTestTemplateFromMethodInLines:input indentation:@"  "];
    
    NSString *expectedResult = @"- (void)test_<#test method name#> {\n  // Arrange\n\n\n  // Act\n  NSString *<#result#> = [self.sut foo:<#param#> bar:<#param#>];\n\n  // Assert\n\n}";
    XCTAssertEqualObjects(result, expectedResult);
}

- (void)test_objCTestTemplateFromMethodInLine_objC_5 {
    NSArray *input = @[@"- (NSString *)foo:(NSInteger)foo\n",
                       @"              bar:(NSData *)bar\n",
                       @"              ber:(NSData *)ber\n",
                       @"              bur:(NSData *)bur {\n",
                       @"    return @\"Blablub\";\n",
                       @"}\n"];
    
    NSString *result = [SourceEditorMethods objCTestTemplateFromMethodInLines:input indentation:@"  "];
    
    NSString *expectedResult = @"- (void)test_<#test method name#> {\n  // Arrange\n\n\n  // Act\n  NSString *<#result#> = [self.sut foo:<#param#> bar:<#param#> ber:<#param#> bur:<#param#>];\n\n  // Assert\n\n}";
    XCTAssertEqualObjects(result, expectedResult);
}

@end
