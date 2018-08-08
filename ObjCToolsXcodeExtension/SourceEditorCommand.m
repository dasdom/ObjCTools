//  Created by dasdom on 28.07.18.
//  Copyright © 2018 dasdom. All rights reserved.
//

#import "SourceEditorCommand.h"

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler {
    
//    NSLog(@"id: %@", invocation.commandIdentifier);
    XCSourceTextBuffer *buffer = invocation.buffer;
    
    NSMutableArray<XCSourceTextRange *> *selections = buffer.selections;
    XCSourceTextRange *firstSelection = selections.firstObject;
    
    NSInteger lineNumber = firstSelection.start.line;
    NSString *line = buffer.lines[lineNumber];
    
    NSError *error = nil;
//    NSLog(@"contentUTI: %@", invocation.buffer.contentUTI);
    if ([invocation.commandIdentifier isEqualToString:@"de.dasdom.ObjCTools.ObjCToolsXcodeExtension.ImportHeader"]) {
        if ([invocation.buffer.contentUTI isEqualToString:@"public.objective-c-source"]) {
            [self addImportStatementFromSelection:firstSelection inLine:line toLines:buffer.lines];
        } else {
            error = [NSError errorWithDomain:@"WrongLanguage" code:1001 userInfo:@{NSLocalizedDescriptionKey: @"This functionality only supports Objctive-C."}];
        }
    } else if ([invocation.commandIdentifier isEqualToString:@"de.dasdom.ObjCTools.ObjCToolsXcodeExtension.DublicateLineAndReplaceStrings"] ||
               [invocation.commandIdentifier isEqualToString:@"de.dasdom.ObjCTools.ObjCToolsXcodeExtension.DublicateLine"]) {
        
        if ([invocation.commandIdentifier isEqualToString:@"de.dasdom.ObjCTools.ObjCToolsXcodeExtension.DublicateLineAndReplaceStrings"]) {
            
            if ([invocation.buffer.contentUTI isEqualToString:@"public.objective-c-source"]) {
                
                line = [line stringByReplacingOccurrencesOfString:@"@\"" withString:@"<#"];
                line = [line stringByReplacingOccurrencesOfString:@"\"" withString:@"#>\""];
                line = [line stringByReplacingOccurrencesOfString:@"<#" withString:@"@\"<#"];
            }
        }
        
        //        if ([line containsString:@"="]) {
        //            NSArray *components = [line componentsSeparatedByString:@"="];
        //            NSString *firstComponent = components.firstObject;
        //            NSRange range =
        //        }
        [buffer.lines insertObject:line atIndex:lineNumber+1];
        
    } else if ([invocation.commandIdentifier isEqualToString:@"de.dasdom.ObjCTools.ObjCToolsXcodeExtension.SortImportsAndRemoveDuplicates"]) {
        
        __block NSInteger firstImport = 0;
        __block NSMutableSet<NSString *> *allImportsSet = [[NSMutableSet alloc] init];
        [buffer.lines enumerateObjectsWithOptions:0 usingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj containsString:@"import "]) {
                [allImportsSet addObject:obj];
                if (firstImport < 1) {
                    firstImport = idx;
                }
            }
        }];
        
        for (NSString *import in allImportsSet) {
            [buffer.lines removeObject:import];
        }
        
        NSArray<NSString *> *allImports = [[allImportsSet allObjects] sortedArrayUsingSelector:@selector(compare:)];
        
        [buffer.lines insertObjects:allImports atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(firstImport, [allImports count])]];
    } else if ([invocation.commandIdentifier isEqualToString:@"de.dasdom.ObjCTools.ObjCToolsXcodeExtension.HexToUIColor"]) {
        
        NSString *string = [line substringWithRange:NSMakeRange(firstSelection.start.column, firstSelection.end.column-firstSelection.start.column)];
        
        NSScanner *scanner = [NSScanner scannerWithString:string];
        scanner.charactersToBeSkipped = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        
        unsigned value;
        [scanner scanHexInt:&value];
        
        CGFloat r = 0;
        CGFloat g = 0;
        CGFloat b = 0;
        CGFloat a = 0;
        if (string.length > 7) {
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
        NSMutableString *indentation = [[NSMutableString alloc] initWithString:@""];
        for (int i = 0; i<buffer.indentationWidth; i++) {
            [indentation appendString:@" "];
        }
        if (buffer.usesTabsForIndentation) {
            NSMutableString *spacesToReplace = [[NSMutableString alloc] initWithString:@""];
            for (int i = 0; i<buffer.tabWidth; i++) {
                [spacesToReplace appendString:@" "];
            }
            [indentation replaceOccurrencesOfString:spacesToReplace withString:@"\t" options:0 range:NSMakeRange(0, indentation.length)];
        }
        
        NSString *nextLine = @"";
        if ([invocation.buffer.contentUTI isEqualToString:@"public.objective-c-source"]) {
            nextLine = [NSString stringWithFormat:@"%@UIColor *<#name#> = [UIColor colorWithRed:%f green:%f blue:%f alpha:%f];", indentation, r, g, b, a];
        } else if ([invocation.buffer.contentUTI isEqualToString:@"public.swift-source"]) {
            nextLine = [NSString stringWithFormat:@"%@let <#name#> = UIColor(red: %f, green: %f, blue: %f, alpha: %f)", indentation, r, g, b, a];
        } else {
            error = [NSError errorWithDomain:@"WrongLanguage" code:1001 userInfo:@{NSLocalizedDescriptionKey: @"This functionality only supports Objctive-C or Swift."}];
        }
        [buffer.lines insertObject:nextLine atIndex:lineNumber+1];
        
    } else if ([invocation.commandIdentifier isEqualToString:@"de.dasdom.ObjCTools.ObjCToolsXcodeExtension.IgnoreCompilerWarnings"]) {
    
        [buffer.lines insertObject:[NSString stringWithFormat:@"#pragma clang diagnostic pop"] atIndex:lineNumber+1];
        [buffer.lines insertObject:[NSString stringWithFormat:@"#pragma clang diagnostic push\n#pragma clang diagnostic ignored \"-Wgnu\""] atIndex:lineNumber];
    }
    
    completionHandler(error);
}

- (void)addImportStatementFromSelection:(XCSourceTextRange *)selection inLine:(NSString *)line toLines:(NSMutableArray<NSString *> *)lines {
    NSString *classToImport = [line substringWithRange:NSMakeRange(selection.start.column, selection.end.column-selection.start.column)];
    
    __block NSInteger lastImport = 0;
    __block NSMutableArray<NSString *> *allImports = [[NSMutableArray alloc] init];
    [lines enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj containsString:@"#import"]) {
            [allImports addObject:obj];
            if (lastImport < 1) {
                lastImport = idx;
            }
        }
    }];
    
    if (classToImport.length > 0) {
        NSString *importLine = [NSString stringWithFormat:@"#import \"%@.h\"", classToImport];
        
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
    }
}

@end
