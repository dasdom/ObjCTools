//  Created by dasdom on 11.08.18.
//  Copyright © 2018 dasdom. All rights reserved.
//

#import "SourceEditorMethods.h"

@implementation SourceEditorMethods

+ (void)addImportStatementFromSelectedString:(NSString *)selectedString toLines:(NSMutableArray<NSString *> *)lines {
    
    __block NSInteger lastImport = -1;
    __block NSMutableArray<NSString *> *allImports = [[NSMutableArray alloc] init];
    [lines enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj containsString:@"#import"]) {
            [allImports addObject:obj];
            if (lastImport < 1) {
                lastImport = idx;
            }
        }
    }];
    
//    if (lastImport == 0) {
//        [lines ]
//    }
//
    
    __block BOOL addEmptyLine = false;
    if (lastImport < 0) {
        [lines enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj containsString:@"@interface"]) {
                lastImport = idx - 1;
                addEmptyLine = true;
                *stop = true;
            }
        }];
    }
    
    if (lastImport < 0) {
        [lines enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj containsString:@"@implementation"]) {
                lastImport = idx - 1;
                addEmptyLine = true;
                *stop = true;
            }
        }];
    }
    
    if (selectedString.length > 0) {
        NSString *importLine = [NSString stringWithFormat:@"#import \"%@.h\"", selectedString];
        
        BOOL alreadyAdded = false;
        for (NSString *import in allImports) {
            if ([import containsString:importLine]) {
                alreadyAdded = true;
                break;
            }
        }
        
        if (!alreadyAdded) {
            [lines insertObject:importLine atIndex:lastImport+1];
        }
        if (addEmptyLine) {
            [lines insertObject:@"" atIndex:lastImport+2];
        }
    }
}

+ (void)dublicateLine:(NSString *)line lineNumber:(NSInteger)lineNumber inLines:(NSMutableArray<NSString *> *)lines replaceStrings:(BOOL)replaceStrings {
    
    if (replaceStrings) {
        
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\".*\"" options:NSRegularExpressionCaseInsensitive error:&error];
        
        NSRange range = NSMakeRange(NSNotFound, 0);
//        do {
            range = [regex rangeOfFirstMatchInString:line options:0 range:NSMakeRange(0, line.length)];
            if (range.location != NSNotFound) {
                line = [line stringByReplacingCharactersInRange:range withString:@"__ddh_replace_this_ddh__"];
            }
//        } while (range.location != NSNotFound);
        
        line = [line stringByReplacingOccurrencesOfString:@"__ddh_replace_this_ddh__" withString:@"\"<#string#>\""];
    }

    [lines insertObject:line atIndex:lineNumber+1];
}

+ (void)sortImportsAndRemoveDublicatesInLines:(NSMutableArray<NSString *> *)lines {
    __block NSInteger firstImport = -1;
    __block NSMutableSet<NSString *> *allImportsSet = [[NSMutableSet alloc] init];
    [lines enumerateObjectsWithOptions:0 usingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj containsString:@"import "]) {
            [allImportsSet addObject:obj];
            if (firstImport < 0) {
                firstImport = idx;
            }
        }
    }];
    
    for (NSString *import in allImportsSet) {
        [lines removeObject:import];
    }
    
    NSArray<NSString *> *allImports = [[allImportsSet allObjects] sortedArrayUsingSelector:@selector(compare:)];
    
    [lines insertObjects:allImports atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(firstImport, [allImports count])]];
}

+ (void)hexToUIColorFromSelectedString:(NSString *)selectedString lineNumber:(NSInteger)lineNumber inLines:(NSMutableArray<NSString *> *)lines indentation:(NSString *)indentation contentUTI:(NSString *)contentUTI {
    
    NSScanner *scanner = [NSScanner scannerWithString:selectedString];
    scanner.charactersToBeSkipped = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    
    unsigned value;
    [scanner scanHexInt:&value];
    
    CGFloat r = 0;
    CGFloat g = 0;
    CGFloat b = 0;
    CGFloat a = 0;
    if (selectedString.length > 7) {
        r = ((value & 0xFF000000) >> 24) / 255.0f;
        g = ((value & 0xFF0000) >> 16) / 255.0f;
        b = ((value & 0xFF00) >> 8) / 255.0f;
        a = ((value & 0xFF)) / 255.0f;
    } else {
        r = ((value & 0xFF0000) >> 16) / 255.0f;
        g = ((value & 0xFF00) >> 8) / 255.0f;
        b = ((value & 0xFF)) / 255.0f;
        a = 1.0;
    }
    
    BOOL isObjC = [contentUTI containsString:@".objective-c-source"];
    BOOL isSwift = [contentUTI containsString:@".swift-source"];
    
    NSString *nextLine = @"";
    if (isObjC) {
        nextLine = [NSString stringWithFormat:@"%@UIColor *<#name#> = [UIColor colorWithRed:%.3f green:%.3f blue:%.3f alpha:%.3f];", indentation, r, g, b, a];
    } else if (isSwift) {
        nextLine = [NSString stringWithFormat:@"%@let <#name#> = UIColor(red: %.3f, green: %.3f, blue: %.3f, alpha: %.3f)", indentation, r, g, b, a];
    }
    [lines insertObject:nextLine atIndex:lineNumber+1];
}

+ (NSString *)declarationForStrings:(NSArray<NSString *> *)selectedLines {

    NSMutableArray<NSString *> *declarationLines = [[NSMutableArray alloc] init];
    
    [selectedLines enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *string = nil;
        if ([obj hasPrefix:@"- ("] || [obj hasPrefix:@"-("] || [obj hasPrefix:@"+ ("] || [obj hasPrefix:@"+("]) {
            string = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([string hasSuffix:@"{"]) {
                string = [string stringByReplacingCharactersInRange:NSMakeRange(string.length-1, 1) withString:@""];
                string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            [declarationLines addObject:string];
        }
    }];

    NSString *result = [declarationLines componentsJoinedByString:@";\n"];
    
    return [result stringByAppendingString:@";"];
}

@end
