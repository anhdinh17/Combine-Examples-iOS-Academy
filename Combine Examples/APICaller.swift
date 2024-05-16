//
//  APICaller.swift
//  Combine Examples
//
//  Created by Anh Dinh on 5/13/24.
//

import Foundation
import Combine

class APICaller {
    static let shared = APICaller()
    
    // Thang nay se la publisher
    // Future is like Result<>
    // in success case, return an array of String
    // else return Error
    func fetchData() -> Future<[String], Error>{
        // Syntax
        return Future { promixe in
            // Simulate networking
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                // After networking
                // Give us an array of String
                promixe(.success(["Apple", "Google", "Microsoft", "Amazon"]))
            }
        }
    }
}
