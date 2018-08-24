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

+ (void)dublicateLine:(NSString *)line lineNumber:(NSInteger)lineNumber inLines:(NSMutableArray<NSString *> *)lines replaceObjCStrings:(BOOL)replaceObjCStrings {
    
    if (replaceObjCStrings) {
        
        line = [line stringByReplacingOccurrencesOfString:@"@\"" withString:@"<#"];
        line = [line stringByReplacingOccurrencesOfString:@"\"" withString:@"#>\""];
        line = [line stringByReplacingOccurrencesOfString:@"<#" withString:@"@\"<#"];
    }

    [lines insertObject:line atIndex:lineNumber+1];
}

+ (void)sortImportsAndRemoveDublicatesInLines:(NSMutableArray<NSString *> *)lines {
    __block NSInteger firstImport = 0;
    __block NSMutableSet<NSString *> *allImportsSet = [[NSMutableSet alloc] init];
    [lines enumerateObjectsWithOptions:0 usingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj containsString:@"import "]) {
            [allImportsSet addObject:obj];
            if (firstImport < 1) {
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
        nextLine = [NSString stringWithFormat:@"%@UIColor *<#name#> = [UIColor colorWithRed:%f green:%f blue:%f alpha:%f];", indentation, r, g, b, a];
    } else if (isSwift) {
        nextLine = [NSString stringWithFormat:@"%@let <#name#> = UIColor(red: %f, green: %f, blue: %f, alpha: %f)", indentation, r, g, b, a];
    }
    [lines insertObject:nextLine atIndex:lineNumber+1];
}

+ (void)ignoreCompilerWarningsAtLineNumber:(NSInteger)lineNumber inLines:(NSMutableArray<NSString *> *)lines {
    
    [lines insertObject:[NSString stringWithFormat:@"#pragma clang diagnostic pop"] atIndex:lineNumber+1];
    [lines insertObject:[NSString stringWithFormat:@"#pragma clang diagnostic push\n#pragma clang diagnostic ignored \"-Wgnu\""] atIndex:lineNumber];
}

@end
