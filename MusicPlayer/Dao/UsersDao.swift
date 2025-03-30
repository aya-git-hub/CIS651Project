//
//  UsersDao.swift
//  Login
//
//  Created by Pengfei Liu on 3/30/25.
//

import Foundation
import CryptoKit
import SQLite3

struct User: Codable, Identifiable {
    let id: UUID
    let name: String
    let email: String
    let passwordHash: String
    let birthdayHash: String
    
    // 使用SHA256哈希密码
    static func hashPassword(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    // 格式化生日为标准字符串
    static func formatBirthday(_ birthday: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.string(from: birthday)
    }
    
    // 初始化方法
    init(name: String, email: String, password: String, birthday: Date) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.passwordHash = Self.hashPassword(password)
        
        // 先格式化生日，再进行哈希
        let formattedBirthday = Self.formatBirthday(birthday)
        self.birthdayHash = Self.hashPassword(formattedBirthday)
    }
}





class UserManager: TablesDao {
    var tableName: String = "Users" // 实现协议要求的属性
    var DB: DatabaseManager // 实现协议要求的属性
    
    let dbManager: DatabaseManager // 保留原有属性以减少对现有代码的修改
    
    
    init() {
        // 使用单例模式获取 DatabaseManager
        self.DB = DatabaseManager.getDBM()
        self.dbManager = self.DB // 保持兼容性
        
        createUserTable()
        
        
        // 验证表是否创建成功
        let tables = dbManager.listTables()
        print("数据库中的表: \(tables)")
        if tables.contains("Users") {
            print("Users表创建成功!")
        } else {
            print("Users表创建失败!")
        }
    }
    
    // 创建用户表
    func createUserTable() {
        // 首先检查表是否已存在
        let tables = dbManager.listTables()
        if tables.contains("Users") {
            print("Users表已存在")
            return
        }
        
        
        let columns: [String: String] = [
            "Id": "TEXT PRIMARY KEY",
            "Name": "TEXT",
            "Email": "TEXT UNIQUE",
            "PasswordHash": "TEXT",
            "BirthdayHash": "TEXT"
        ]
        
        dbManager.createTable(tableName: "Users", columns: columns)
    }
    
    // 插入用户
    func insertUser(_ user: User) -> Bool {
        let userData: [String: Any] = [
            "Id": user.id.uuidString,
            "Name": user.name,
            "Email": user.email,
            "PasswordHash": user.passwordHash,
            "BirthdayHash": user.birthdayHash
        ]
        
        dbManager.insertRecord(tableName: "Users", data: userData)
        copyDatabaseBack()
        return true
    }
    
    // 验证用户登录
    func validateUser(email: String, password: String) -> Bool {
        // 获取密码的哈希值
        let passwordHash = User.hashPassword(password)
        print("尝试验证用户: \(email)，密码哈希: \(passwordHash)")
        
        // 使用参数化查询而不是字符串拼接
        var results: [[String: Any]] = []
        let querySQL = "SELECT * FROM Users WHERE Email = ? AND PasswordHash = ?;"
        
        var statement: OpaquePointer? = nil
        if sqlite3_prepare_v2(dbManager.db, querySQL, -1, &statement, nil) == SQLITE_OK {
            // 绑定参数
            sqlite3_bind_text(statement, 1, (email as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (passwordHash as NSString).utf8String, -1, nil)
            
            // 执行查询
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
            let errorMsg = String(cString: sqlite3_errmsg(dbManager.db))
            print("验证用户失败: \(errorMsg)")
        }
        sqlite3_finalize(statement)
        
        print("查询结果: \(results.isEmpty ? "无匹配用户" : "找到用户")")
        return !results.isEmpty
    }
    
    
    
    // 检查邮箱是否已存在
    func isEmailExists(_ email: String) -> Bool {
        let condition = "Email = '\(email)'"
        let results = dbManager.queryRecords(tableName: "Users", condition: condition)
        
        return !results.isEmpty
    }
    
    
    // 实现协议要求的方法
    func copyDatabaseBack() {
            let fileManager = FileManager.default
            
            guard let docsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("Cannot find Documents' directory")
                return
            }
            
            // 假设数据库文件名为 "mydb.sqlite"（请根据实际情况修改）
            let sourceURL = docsDir.appendingPathComponent("TheUserDatabase.sqlite")
            
            // 目标路径，请修改为你希望保存数据库的原始位置
            let destinationPath = "/Users/pengfeiliu/Library/Developer/CoreSimulator/Devices/315AB8BF-90E6-436C-86B6-99E50B61EB05/data/Containers/Data/Application/DA2B1FD1-EFED-4956-8273-A08D8EF28959/Documents/TheUserDatabase.sqlite"
            let destinationURL = URL(fileURLWithPath: destinationPath)
            
            do {
                // 如果目标文件已存在，则先删除
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                try fileManager.copyItem(at: sourceURL, to: destinationURL)
                print("Databasement has been copied to: \(destinationURL.path)")
            } catch {
                print("Copy database failed: \(error)")
            }
        }
    
}
