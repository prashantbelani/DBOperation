//
//  DBOperation.m
//
//


#import "DBOperation.h"
static sqlite3 *database = nil;
static int conn;
@implementation DBOperation


+(void)checkCreateDB{
    @try {
        NSString *dbPath,*databaseName;
        
        databaseName=@"Emoji_app.rdb";
        
        NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *docDir = [docPaths objectAtIndex:0];
        dbPath = [docDir stringByAppendingPathComponent:databaseName];
        BOOL success;
        NSFileManager *fm = [NSFileManager defaultManager];
        success=[fm fileExistsAtPath:dbPath];
        if(success){
            NSLog(@"Database copy successfully created !!");
            [self OpenDatabase:dbPath];
            return;
        }
        NSString *dbPathFromApp=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
        [fm copyItemAtPath:dbPathFromApp toPath:dbPath error:nil];
        [self OpenDatabase:dbPath];

    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception reason]);

    }
}

//Open database
+ (void) OpenDatabase:(NSString*)path
{
	@try
	{
		conn = sqlite3_open([path UTF8String], &database);
		if (conn == SQLITE_OK) {
			NSLog(@"Database Open Successfully.");
		}
		else
			sqlite3_close(database); //Even though the open call failed, close the database connection to release all the memory.
	}	
	@catch (NSException *e) {
		NSLog(@"%@",e); 
	}	
}

+(NSMutableArray*) selectData:(NSString *)sql
{
    @try 
    {
        if (conn == SQLITE_OK) 
        {
            sqlite3_stmt *stmt = nil;
            if(sqlite3_prepare_v2(database, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
                [NSException raise:@"DatabaseException" format:@"Error while creating statement. '%s'", sqlite3_errmsg(database)];
            }
            NSMutableArray *obj = [[NSMutableArray alloc]init];
            int numResultColumns = 0;
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                numResultColumns = sqlite3_column_count(stmt);
                //NSLog(@"numRecentColumns: %i",numResultColumns);
                //NSMutableArray *fieldNames = [[NSMutableArray alloc] initWithCapacity:0];

                @autoreleasepool {
                
                    NSMutableDictionary *tmpObj = [[NSMutableDictionary alloc]init];
                    for(int i = 0; i < numResultColumns; i++){
                        if(sqlite3_column_type(stmt, i) == SQLITE_INTEGER){
                            
                            const char *name = sqlite3_column_name(stmt, i);
                            NSString *columnName = [[NSString alloc]initWithCString:name encoding:NSUTF8StringEncoding];
                            [tmpObj setObject:[NSString stringWithFormat:@"%i",sqlite3_column_int(stmt, i)] forKey:columnName];
                            
                        } else if (sqlite3_column_type(stmt, i) == SQLITE_FLOAT) {
                            
                            const char *name = sqlite3_column_name(stmt, i);
                            NSString *columnName = [[NSString alloc]initWithCString:name encoding:NSUTF8StringEncoding];
                            //[obj setValue:sqlite3_column_double(stmt, i) forKey:columnName];
                            //[tmpObj setObject:sqlite3_column_double(stmt, i) forKey:columnName];
                            [tmpObj setObject:[NSString stringWithFormat:@"%f",sqlite3_column_double(stmt, i)] forKey:columnName];

                        } else if (sqlite3_column_type(stmt, i) == SQLITE_TEXT) {
                            const char *name = sqlite3_column_name(stmt, i);
                            NSString *tmpStr = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, i)];
                            if ( tmpStr == nil) {
                                tmpStr = @"";
                            }
                            NSString *columnName = [[NSString alloc]initWithCString:name encoding:NSUTF8StringEncoding];
                            [tmpObj setObject:tmpStr forKey:columnName];
                            
                        } else if (sqlite3_column_type(stmt, i) == SQLITE_BLOB) {
                            
                            //[NSString stringWithUTF8String:( *)sqlite3_column_blob(cmp_sqlStmt, i)];
                            //                const char *name = sqlite3_column_name(stmt, i);
                            //                NSString *columnName = [[NSString alloc]initWithCString:name encoding:NSUTF8StringEncoding];
                            //                [obj setValue: forKey:columnName]
                        }     
                        
                    }
                    [obj addObject:tmpObj];

                //    [theResult setFieldNames:fieldNames];
                
                    }
                //    NSLog(@"StrengthExercise::constructResults\n====\n %@ \n======\n", sqlite3_column_text(stmt, 1));
                //[res addObject:[self :stmt]];
                }
            return obj;
        } else
            return nil;
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception reason]);

    }
 }

+(BOOL) executeSQL:(NSString *)sqlTmp {
	@try {
        if(conn == SQLITE_OK) {
            //NSLog(@"\n\n%@",sqlTmp);       
            
            const char *sqlStmt = [sqlTmp cStringUsingEncoding:NSUTF8StringEncoding];
            sqlite3_stmt *cmp_sqlStmt1;
            int returnValue = sqlite3_prepare_v2(database, sqlStmt, -1, &cmp_sqlStmt1, NULL);
            
            returnValue == SQLITE_OK ?  NSLog(@"\n Inserted \n") :NSLog(@"\n Not Inserted \n");
            
            sqlite3_step(cmp_sqlStmt1);
            sqlite3_finalize(cmp_sqlStmt1);
            
            if (returnValue == SQLITE_OK)
            {
                return TRUE;
            }
        }
        return FALSE;

    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception reason]);

    }
}

+(int) getLastInsertId
{
    @try {
        return sqlite3_last_insert_rowid(database);

    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception reason]);

    }
}

//Save data at application closing time
+ (void) finalizeStatements 
{
    @try {
        if(database) sqlite3_close(database);

    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception reason]);

    }
}

@end
