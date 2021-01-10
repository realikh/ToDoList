//
//  ToDoService.swift
//  ToDoList
//
//  Created by Alikhan Khassen on 09.01.2021.
//

import UIKit

protocol ToDoService {
    func fetchToDos(success: @escaping ([ToDo]) -> Void, failure: @escaping (Error) -> Void)
    func addToDo(with title: String, detail: String, dueDate: Date, isCompleted: Bool)
    func toggleIsCompleted(toDo: ToDo)
    func updateToDo(toDo: ToDo, title: String, detail: String, dueDate: Date, isCompleted: Bool)
    func removeToDo(toDo: ToDo)
    func undoRemove()
}

final class ToDoServiceImplementation: ToDoService {
    
    var deletedToDoData: (title: String, detail: String, dueDate: Date, isCompleted: Bool)!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func fetchToDos(success: @escaping ([ToDo]) -> Void, failure: @escaping (Error) -> Void) {
        do {
            let toDos = try context.fetch(ToDo.fetchRequest())
            success(toDos as? [ToDo] ?? [])
        } catch {
            
        }
    }
    
    func addToDo(with title: String, detail: String, dueDate: Date, isCompleted: Bool) {
        let toDo = ToDo(context: context)
        toDo.title = title
        toDo.detail = detail
        toDo.dueDate = dueDate
        toDo.isCompleted = isCompleted
        save()
    }
    
    func toggleIsCompleted(toDo: ToDo) {
        toDo.isCompleted.toggle()
        save()
    }
    
    func updateToDo(toDo: ToDo, title: String, detail: String, dueDate: Date, isCompleted: Bool) {
        toDo.title = title
        toDo.detail = detail
        toDo.dueDate = dueDate
        toDo.isCompleted = isCompleted
        save()
    }

    func removeToDo(toDo: ToDo) {
        deletedToDoData = (title: toDo.title!, detail: toDo.detail!, dueDate: toDo.dueDate!, isCompleted: toDo.isCompleted)
        
        context.delete(toDo)
        
        save()
    }
    
    func undoRemove() {
        if let deletedToDoData = deletedToDoData {
            
            let addToDo = ToDo(context: context)
            addToDo.title = deletedToDoData.title
            addToDo.detail = deletedToDoData.detail
            addToDo.dueDate = deletedToDoData.dueDate
            addToDo.isCompleted = deletedToDoData.isCompleted
            
            save()
        }
    }
    
    func save() {
        do {
            try context.save()
        } catch {
            print("Error while saving")
        }
    }
}
