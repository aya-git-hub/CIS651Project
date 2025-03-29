import Foundation
import SQLite3

//Singleton
class DatabaseManager {
    var db: OpaquePointer?
    static var dbm: DatabaseManager? = nil
    private init() {
        self.db = openDatabase()
        print("DatabaseManager: I was instantiated.")
    }
    
    // To get manager's object
    public static func getDBM() -> DatabaseManager {
    // Make sure only one manager exists
        if dbm != nil{
            print("DatabaseManager has been instantiated already.")
            return dbm!
        }
        else{
            dbm = DatabaseManager()
            return dbm!
        }
    }
    
    // MARK: - Open Database Connection
    func openDatabase() -> OpaquePointer? {
        var db: OpaquePointer? = nil
         let fileURL = try! FileManager.default
         .url(for: .documentDirectory,
         in: .userDomainMask,
         appropriateFor: nil,
         create: false)
         .appendingPathComponent("TheUserDatabase.sqlite")
         if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
         print("Successfully connected to database: \(fileURL.path)")
         return db
         } else {
         print("Unable to open database")
         return nil
         }
        
        let docDir:String! = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        let fileName:String! = docDir + "/database/UserDatabase.sqlite"
        if sqlite3_open(fileName, &db) != SQLITE_OK {
            print("打开数据库失败")
            return db
        } else {
            print("打开数据库成功")
            return db
            
            
        }
    }
    func getMusicsName(tableName: String, condition: String? = nil) -> [String]{
        var result = self.queryRecords(tableName: "Musics",condition: "1=1")
        print(result.count)
        let musicNames = result.compactMap { $0["MusicName"] as? String }
        return musicNames
    }
    func listTables() -> [String] {
        var tables: [String] = []
        let querySQL = "SELECT name FROM sqlite_master WHERE type='table';"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                if let cString = sqlite3_column_text(statement, 0) {
                    let tableName = String(cString: cString)
                    tables.append(tableName)
                }
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(db))
            print("Failed to list tables: \(errorMsg)")
        }
        sqlite3_finalize(statement)
        return tables
    }
    
    // MARK: - Dynamically Create Table
    /// Dynamically creates a table
    /// - Parameters:
    ///   - tableName: The name of the table to create
    ///   - columns: A dictionary of columns, where the key is the column name and the value is its SQL type definition (e.g., "INTEGER PRIMARY KEY AUTOINCREMENT", "TEXT", "REAL", etc.)
    func createTable(tableName: String, columns: [String: String]) {
        // Concatenate column definitions
        let columnDefs = columns.map { "\($0.key) \($0.value)" }.joined(separator: ", ")
        let createSQL = "CREATE TABLE IF NOT EXISTS \(tableName) (\(columnDefs));"
        print("Create table SQL: \(createSQL)")
        
        var errMsg: UnsafeMutablePointer<Int8>? = nil
        if sqlite3_exec(db, createSQL, nil, nil, &errMsg) != SQLITE_OK {
            if let error = errMsg {
                let msg = String(cString: error)
                print("Table creation failed: \(msg)")
            }
        } else {
            print("Table \(tableName) created successfully")
        }
    }
    
    // MARK: - Dynamically Insert Record
    /// Dynamically constructs and executes an INSERT statement based on the provided data.
    /// - Parameters:
    ///   - tableName: The table name
    ///   - data: A dictionary where the key is the column name and the value is the value to insert
    func insertRecord(tableName: String, data: [String: Any]) {
        // 使用命名参数构造 SQL 语句，例如 "INSERT INTO tableName (col1, col2) VALUES (:col1, :col2);"
        let columns = data.keys.joined(separator: ", ")
        let placeholders = data.keys.map { ":\($0)" }.joined(separator: ", ")
        let insertSQL = "INSERT INTO \(tableName) (\(columns)) VALUES (\(placeholders));"
        print("Insert record SQL: \(insertSQL)")
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            // 遍历 data 中的每个键值对，根据键名绑定对应的值
            for (key, value) in data {
                let parameterName = ":\(key)"
                // 获取命名参数对应的位置索引
                let index = sqlite3_bind_parameter_index(statement, parameterName)
                // 如果 index 为 0，表示未找到对应的参数（通常不会发生）
                if index > 0 {
                    bind(value: value, to: statement, at: index)
                } else {
                    print("未找到参数 \(parameterName) 对应的位置")
                }
            }
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Record inserted successfully")
            } else {
                print("Failed to insert record")
            }
        } else {
            print("Failed to prepare INSERT statement")
        }
        sqlite3_finalize(statement)
    }
    
    // MARK: - Dynamically Query Records
    /// Dynamically constructs a SELECT statement based on the provided condition and returns the results.
    /// - Parameters:
    ///   - tableName: The table name
    ///   - condition: An optional condition string (e.g., "age > 20"). If nil, all records are queried.
    /// - Returns: An array of dictionaries representing the rows.
    func queryRecords(tableName: String, condition: String? = nil) -> [[String: Any]] {
        var results: [[String: Any]] = []
        var querySQL = "SELECT * FROM \(tableName)"
        if let cond = condition {
            querySQL += " WHERE \(cond)"
        }
        querySQL += ";"
        print("Query SQL: \(querySQL)")
        
        var statement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK{
            while sqlite3_step(statement) == SQLITE_ROW {
                let columnCount = sqlite3_column_count(statement)
                var row = [String: Any]()
                for i in 0..<columnCount {
                    let colName = String(cString: sqlite3_column_name(statement, i))
                    let type = sqlite3_column_type(statement, i)
                    var value: Any
                    switch type {
                    case SQLITE_INTEGER:
                        value = sqlite3_column_int(statement, i)
                    case SQLITE_FLOAT:
                        value = sqlite3_column_double(statement, i)
                    case SQLITE_TEXT:
                        value = String(cString: sqlite3_column_text(statement, i))
                    case SQLITE_NULL:
                        value = NSNull()
                    default:
                        value = ""
                    }
                    row[colName] = value
                }
                results.append(row)
            }
        } else {
            print("Failed to prepare SELECT statement")
            let errorMsg = String(cString: sqlite3_errmsg(db))
                print("Failed to prepare SELECT statement: \(errorMsg)")
        }
        sqlite3_finalize(statement)
        return results
    }
    
    // MARK: - Dynamically Update Record
    /// Dynamically constructs and executes an UPDATE statement based on the provided data and condition.
    /// - Parameters:
    ///   - tableName: The table name
    ///   - data: A dictionary where the key is the column name and the value is the new value.
    ///   - condition: The update condition (e.g., "id = 1")
    func updateRecord(tableName: String, data: [String: Any], condition: String) {
        // Build the SET clause. Sorting keys to ensure consistent binding order.
        let sortedKeys = data.keys.sorted()
        let setClause = sortedKeys.map { "\($0) = ?" }.joined(separator: ", ")
        let updateSQL = "UPDATE \(tableName) SET \(setClause) WHERE \(condition);"
        print("Update SQL: \(updateSQL)")
        
        var statement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            for (index, key) in sortedKeys.enumerated() {
                let value = data[key]
                bind(value: value, to: statement, at: Int32(index + 1))
            }
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Record updated successfully")
            } else {
                print("Failed to update record")
            }
        } else {
            print("Failed to prepare UPDATE statement")
        }
        sqlite3_finalize(statement)
    }
    
    // MARK: - Dynamically Delete Record
    /// Dynamically constructs and executes a DELETE statement based on the provided condition.
    /// - Parameters:
    ///   - tableName: The table name
    ///   - condition: The delete condition (e.g., "id = 1")
    func deleteRecord(tableName: String, condition: String) {
        let deleteSQL = "DELETE FROM \(tableName) WHERE \(condition);"
        print("Delete SQL: \(deleteSQL)")
        
        var statement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteSQL, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Record deleted successfully")
            } else {
                print("Failed to delete record")
            }
        } else {
            print("Failed to prepare DELETE statement")
        }
        sqlite3_finalize(statement)
    }
    
    // MARK: - Helper: Bind Parameters
    /// Dynamically binds parameters to a prepared SQLite statement based on their data type.
    private func bind(value: Any?, to statement: OpaquePointer?, at index: Int32) {
        if value == nil || value is NSNull {
            sqlite3_bind_null(statement, index)
        } else if let intValue = value as? Int32 {
            sqlite3_bind_int(statement, index, intValue)
        } else if let intValue = value as? Int {
            sqlite3_bind_int(statement, index, Int32(intValue))
        } else if let doubleValue = value as? Double {
            sqlite3_bind_double(statement, index, doubleValue)
        } else if let stringValue = value as? String {
            sqlite3_bind_text(statement, index, (stringValue as NSString).utf8String, -1, nil)
        } else {
            // Convert other types to a string representation
            let str = "\(value!)"
            sqlite3_bind_text(statement, index, (str as NSString).utf8String, -1, nil)
        }
    }
}
