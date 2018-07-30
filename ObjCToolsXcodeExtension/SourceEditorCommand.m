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
    } else if ([invocation.commandIdentifier isEqualToString:@"de.dasdom.ObjCTools.ObjCToolsXcodeExtension.DoublicateLineAndReplaceStrings"]) {
        
        if ([invocation.buffer.contentUTI isEqualToString:@"public.objective-c-source"]) {
            
            line = [line stringByReplacingOccurrencesOfString:@"@\"" withString:@"<#"];
            line = [line stringByReplacingOccurrencesOfString:@"\"" withString:@"#>\""];
            line = [line stringByReplacingOccurrencesOfString:@"<#" withString:@"@\"<#"];
            
            //        if ([line containsString:@"="]) {
            //            NSArray *components = [line componentsSeparatedByString:@"="];
            //            NSString *firstComponent = components.firstObject;
            //            NSRange range =
            //        }
            [buffer.lines insertObject:line atIndex:lineNumber+1];
        } else {
            error = [NSError errorWithDomain:@"WrongLanguage" code:1001 userInfo:@{NSLocalizedDescriptionKey: @"This functionality only supports Objctive-C."}];
        }
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
