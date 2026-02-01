//
//  PhotoAssetLoader.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import Photos
import UIKit

/// Helper for loading Photos assets by local identifier.
enum PhotoAssetLoader {
    static func loadImage(localIdentifier: String, targetSize: CGSize) async -> UIImage? {
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        guard let asset = fetchResult.firstObject else { return nil }

        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.deliveryMode = .opportunistic
            options.resizeMode = .fast

            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }

    static func loadImages(localIdentifiers: [String], targetSize: CGSize) async -> [UIImage?] {
        var results: [UIImage?] = []
        results.reserveCapacity(localIdentifiers.count)

        for identifier in localIdentifiers {
            let image = await loadImage(localIdentifier: identifier, targetSize: targetSize)
            results.append(image)
        }

        return results
    }
}
