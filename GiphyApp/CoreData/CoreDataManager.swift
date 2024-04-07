//
//  CoreDataManager.swift
//  GiphyApp
//
//  Created by Guy Twig on 07/04/2024.
//

import CoreData
import UIKit

class CoreDataManager {
    static let sharedInstance = CoreDataManager()
    
    private init() {}
    
    private var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    func fetchFavoriteGifs() -> [GifData] {
        let fetchRequest: NSFetchRequest<FavoriteGif> = FavoriteGif.fetchRequest()
        
        do {
            let favoriteGifs = try context.fetch(fetchRequest)
            return favoriteGifs.map { favoriteGif in
                return GifData(images: nil, id: favoriteGif.id ?? "")
            }
        } catch {
            print("Error fetching favorite gifs: \(error)")
            return []
        }
    }
    
    func addGifToFavorites(_ gifData: GifData) {
        let favoriteGif = FavoriteGif(context: context)
        favoriteGif.id = gifData.id
        do {
            try context.save()
            print("Successfully added favorite gifs.")
        } catch {
            print("Error saving favorite gif: \(error)")
        }
    }
    
    func removeGifFromFavorites(_ gifData: GifData) {
        let fetchRequest: NSFetchRequest<FavoriteGif> = FavoriteGif.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", gifData.id ?? "")
        
        do {
            let results = try context.fetch(fetchRequest)
            if let favoriteGif = results.first {
                context.delete(favoriteGif)
                try context.save()
                print("Successfully removed gif from favorite gifs.")
            }
        } catch {
            print("Error removing favorite gif: \(error)")
        }
    }
    
    func removeAllFavoriteGifs() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FavoriteGif.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            print("Successfully removed all favorite gifs.")
        } catch {
            print("Error removing all favorite gifs: \(error)")
        }
    }
}
