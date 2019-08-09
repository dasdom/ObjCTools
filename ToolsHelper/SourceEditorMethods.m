//  Created by dasdom on 11.08.18.
//  Copyright © 2018 dasdom. All rights reserved.
//

#import "SourceEditorMethods.h"
#import "NSString+RangeOfRegex.h"

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

+ (void)addClassDeclarationFromSelectedString:(NSString *)selectedString toLines:(NSMutableArray<NSString *> *)lines {
    
    __block NSInteger lastClassDeclaration = -1;
    __block NSMutableArray<NSString *> *allClassDeclarations = [[NSMutableArray alloc] init];
    [lines enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj containsString:@"@class"]) {
            [allClassDeclarations addObject:obj];
            if (lastClassDeclaration < 0) {
                lastClassDeclaration = idx;
            }
        }
    }];
    
    if (lastClassDeclaration < 0) {
        [lines enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj containsString:@"#import"]) {
                if (lastClassDeclaration < 1) {
                    lastClassDeclaration = idx;
                }
            }
        }];
    }
    
    __block BOOL addEmptyLineBefore = true;
    __block BOOL addEmptyLineAfter = false;
    if (lastClassDeclaration < 0) {
        [lines enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj containsString:@"@interface"]) {
                lastClassDeclaration = idx - 1;
                addEmptyLineBefore = false;
                addEmptyLineAfter = true;
                *stop = true;
            }
        }];
    }
    
    if (lastClassDeclaration < 0) {
        [lines enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj containsString:@"@implementation"]) {
                lastClassDeclaration = idx - 1;
                addEmptyLineBefore = false;
                addEmptyLineAfter = true;
                *stop = true;
            }
        }];
    }
    
    if (selectedString.length > 0) {
        NSString *classDeclarationLine = [NSString stringWithFormat:@"@class %@;", selectedString];
        
        BOOL alreadyAdded = false;
        for (NSString *classDeclaration in allClassDeclarations) {
            if ([classDeclaration containsString:classDeclarationLine]) {
                alreadyAdded = true;
                break;
            }
        }
        
        if (!alreadyAdded) {
            NSInteger index = lastClassDeclaration+1;
            if ([allClassDeclarations count] < 1 && addEmptyLineBefore) {
                [lines insertObject:@"" atIndex:index];
                index += 1;
            }
            [lines insertObject:classDeclarationLine atIndex:index];
            index += 1;
            if (addEmptyLineAfter) {
                [lines insertObject:@"" atIndex:index];
            }
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
    
    NSString *input = [selectedLines componentsJoinedByString:@""];
    NSArray<NSString *> *declarationLines = [self declarationLinesFromString:input];
    
    NSString *result = [declarationLines componentsJoinedByString:@";\n"];
    
    return [result stringByAppendingString:@";"];
}

+ (NSArray<NSString *> *)alignEquals:(NSArray<NSString *> *)selectedLines {
    
    // regex: @" += +"
    
    NSMutableArray *lineArrays = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *normalized = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *originalLines = [[NSMutableArray alloc] init];
    __block BOOL endedInComment = NO;
    
    [selectedLines enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSRange equalRange = [obj rangeOfFirstMatchForRegex:@" += +"];
        NSRange commentRange = [obj rangeOfFirstMatchForRegex:@"/{2,}.+ += +"];
        
        [originalLines addObject:obj];
        
        NSRange multilineCommentStartRange = [obj rangeOfString:@"/*"];
        NSRange multilineCommentEndRange = [obj rangeOfString:@"*/"];
        if (multilineCommentEndRange.location != NSNotFound) {
            [lineArrays addObject:@{@"type": @"comment", @"lines": [originalLines copy]}];
            [originalLines removeAllObjects];
            [normalized removeAllObjects];
            endedInComment = NO;
        } else if (multilineCommentStartRange.location != NSNotFound) {
            [lineArrays addObject:@{@"type": @"normalized", @"lines": [normalized copy]}];
            [originalLines removeAllObjects];
            [originalLines addObject:obj];
            [normalized removeAllObjects];
            endedInComment = YES;
        } else {
            
            if (equalRange.location != NSNotFound && commentRange.location == NSNotFound) {
                obj = [obj stringByReplacingCharactersInRange:equalRange withString:@" = "];
            }
            [normalized addObject:obj];
        }
    }];
    
    if (endedInComment) {
        [lineArrays addObject:@{@"type": @"comment", @"lines": [originalLines copy]}];
    } else {
        [lineArrays addObject:@{@"type": @"normalized", @"lines": [normalized copy]}];
    }
    
    __block NSInteger maxEqualPosition = 0;
    
    [lineArrays enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger dictidx, BOOL * _Nonnull dictstop) {
        if ([dict[@"type"] isEqualToString:@"normalized"]) {
            NSArray *temp = dict[@"lines"];
            [temp enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSRange commentRange = [obj rangeOfFirstMatchForRegex:@"/{2,}.+ += +"];
                
                NSRange rangeOfEqual = [obj rangeOfString:@"="];
                if (rangeOfEqual.location != NSNotFound && maxEqualPosition < rangeOfEqual.location && commentRange.location == NSNotFound) {
                    
                    maxEqualPosition = rangeOfEqual.location;
                }
            }];
        }
    }];
    
    NSMutableArray<NSString *> *output = [[NSMutableArray alloc] init];
    
    [lineArrays enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger dictidx, BOOL * _Nonnull dictstop) {
        
        if ([dict[@"type"] isEqualToString:@"normalized"]) {
            
            NSArray *temp = dict[@"lines"];
            
            [temp enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSRange commentRange = [obj rangeOfFirstMatchForRegex:@"/{2,}.+ += +"];
                
                if (commentRange.location == NSNotFound) {
                    
                    NSRange rangeOfEqual = [obj rangeOfString:@"="];
                    NSInteger additionalSpaces = maxEqualPosition - rangeOfEqual.location;
                    NSMutableString *spaces = [[NSMutableString alloc] initWithString:@""];
                    for (int i = 0; i<additionalSpaces; i++) {
                        [spaces appendString:@" "];
                    }
                    NSString *stringToReplace = [NSString stringWithFormat:@"%@=", spaces];
                    
                    NSString *changedString = [obj stringByReplacingOccurrencesOfString:@"=" withString:stringToReplace];
                    [output addObject:changedString];
                } else {
                    [output addObject:obj];
                }
                
                
                
            }];
        } else {
            NSArray *temp = dict[@"lines"];
            [output addObjectsFromArray:temp];
        }
    }];
    
    return output;
}

+ (NSArray<NSString *> *)sortSelectedLines:(NSArray<NSString *> *)selectedLines {
    return [selectedLines sortedArrayUsingSelector:@selector(compare:)];
}

+ (NSString *)protocolFromMethodsInLines:(NSArray<NSString *> *)selectedLines indentation:(NSString *)indentation contentUTI:(NSString *)contentUTI {
    
    BOOL isObjC = [contentUTI containsString:@".objective-c-source"];
    BOOL isSwift = [contentUTI containsString:@".swift-source"];
    
    NSString *input = [selectedLines componentsJoinedByString:@""];
    NSArray<NSString *> *declarationLines = [self declarationLinesFromString:input];
    
    NSString *joiningString = @"";
    if (isObjC) {
        joiningString = @";\n";
    } else if (isSwift) {
        joiningString = @"\n";
    }
    
    NSString *result = [declarationLines componentsJoinedByString:joiningString];
    
    NSString *protocolString = @"";
    if (isObjC) {
        protocolString = [NSString stringWithFormat:@"@protocol <#Protocol Name#> <NSObject>\n%@;\n@end\n", result];
    } else if (isSwift) {
        protocolString = [NSString stringWithFormat:@"protocol <#Protocol Name#> {\n%@\n}\n", result];
    }
    
    return protocolString;
}

+ (NSString *)objCTestTemplateFromMethodInLines:(NSArray<NSString *> *)selectedLines indentation:(NSString *)indentation {
    
    NSString *input = [selectedLines componentsJoinedByString:@""];
    NSArray<NSString *> *declarationLines = [self declarationLinesFromString:input];
    
    NSString *firstSelectedMethodDeclaration = declarationLines.firstObject;
    
    NSArray *parameterNames = [self methodParameterNamesFromString:firstSelectedMethodDeclaration];
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\w+ ?\\*? ?" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSMutableString *resultString = [[NSMutableString alloc] init];
    [resultString appendString:@"- (void)test_<#test method name#> {\n"];
    [resultString appendFormat:@"%@// Arrange\n\n\n%@// Act\n", indentation, indentation];
    NSRange typeRange = [regex rangeOfFirstMatchInString:firstSelectedMethodDeclaration options:0 range:NSMakeRange(0, firstSelectedMethodDeclaration.length)];
    
    NSString *typeString = [firstSelectedMethodDeclaration substringWithRange:typeRange];
    NSString *lastCharacter = [typeString substringFromIndex:typeString.length-1];
    if (![lastCharacter isEqualToString:@"*"]) {
        typeString = [typeString stringByAppendingString:@" "];
    }
    [resultString appendFormat:@"%@%@<#result#> = [self.sut ", indentation, typeString];
    [resultString appendString:[parameterNames componentsJoinedByString:@" "]];
    [resultString appendString:@"];\n\n  // Assert\n\n}"];
    return [resultString copy];
}

#pragma mark - Helpers
+ (NSArray<NSString *> *)declarationLinesFromString:(NSString *)input {
    
    NSMutableArray<NSString *> *declarationLines = [[NSMutableArray alloc] init];
    NSError *error = nil;
    //    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[-+(func)].+\\n?.+\\n?.+\\n?.+\\n?\\{" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[-+(func)]([^}]+\\n?)\\{" options:NSRegularExpressionCaseInsensitive error:&error];
    
    [regex enumerateMatchesInString:input options:0 range:NSMakeRange(0, input.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        
        NSString *string = [input substringWithRange:result.range];
        if ([string hasSuffix:@"{"]) {
            string = [string substringToIndex:string.length-1];
            string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        [declarationLines addObject:string];
    }];
    
    return [declarationLines copy];
}

+ (NSArray<NSString *> *)methodParameterNamesFromString:(NSString *)input {
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\w+:" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSMutableArray *parameterNames = [[NSMutableArray alloc] init];
    [regex enumerateMatchesInString:input options:0 range:NSMakeRange(0, input.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        
        NSString *name = [input substringWithRange:result.range];
        name = [name stringByAppendingString:@"<#param#>"];
        [parameterNames addObject:name];
    }];
    
    if ([parameterNames count] < 1) {
        regex = [NSRegularExpression regularExpressionWithPattern:@"\\w+ ?$" options:NSRegularExpressionCaseInsensitive error:&error];
        NSRange range = NSMakeRange(NSNotFound, 0);
        range = [regex rangeOfFirstMatchInString:input options:0 range:NSMakeRange(0, input.length)];
        if (range.location != NSNotFound) {
            NSString *name = [input substringWithRange:range];
            name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [parameterNames addObject:name];
        }
    }
    
    return [parameterNames copy];
}

@end
