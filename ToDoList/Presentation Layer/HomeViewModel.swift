//
//  HomeViewModel.swift
//  ToDoList
//
//  Created by Alikhan Khassen on 09.01.2021.
//

import UIKit

final class HomeViewModel {
    
    var didFetchToDos: () -> Void = { }
    
    private var data = [ToDo]()
    
    var dataToDisplay: [[ToDo]] {
        get {
            [data.filter { !$0.isCompleted }.sorted {$0.dueDate! < $1.dueDate!},
             data.filter {$0.isCompleted}.sorted {$0.dueDate! < $1.dueDate!}]
        }
    }
    
    let toDoService:ToDoService = ToDoServiceImplementation()
    
    func fetchToDos() {
        toDoService.fetchToDos { [weak self] toDos in
            self?.data = toDos
            self?.didFetchToDos()
        } failure: { (error) in
            print(error)
        }
    }
}
