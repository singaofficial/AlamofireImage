//
//  ImageCacheTests.swift
//
//  Copyright (c) 2015 Alamofire Software Foundation (http://alamofire.org/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@testable import Alamofire
@testable import AlamofireImage
import Foundation
import XCTest

final class ImageCacheTestCase: BaseTestCase {
    var cache: AutoPurgingImageCache!

    // MARK: - Setup and Teardown

    override func setUp() {
        super.setUp()

        cache = {
            let memoryCapacity: UInt64 = 100 * 1024 * 1024 // 10 MB
            let preferredSizeAfterPurge: UInt64 = 60 * 1024 * 1024 // 4 MB

            return AutoPurgingImageCache(memoryCapacity: memoryCapacity,
                                         preferredMemoryUsageAfterPurge: preferredSizeAfterPurge)
        }()
    }

    // MARK: - Initialization Tests

    func testThatCacheCanBeInitializedAndDeinitialized() {
        // Given
        var cache: AutoPurgingImageCache? = AutoPurgingImageCache()

        // When
        cache = nil

        // Then
        XCTAssertNil(cache, "cache should be nil after deinit")
    }

    // MARK: - Add Image Tests

    func testThatItCanAddImageToCacheWithIdentifier() {
        // Given
        let image = image(forResource: "unicorn", withExtension: "png")
        let identifier = "unicorn"

        // When
        cache.add(image, withIdentifier: identifier)
        let cachedImage = cache.image(withIdentifier: identifier)

        // Then
        XCTAssertNotNil(cachedImage, "cached image should not be nil")
        XCTAssertEqual(cachedImage, image, "cached image should be equal to image")
    }

    func testThatItCanAddImageToCacheWithRequestIdentifier() {
        // Given
        let image = image(forResource: "unicorn", withExtension: "png")
        let request = Endpoint.get.urlRequest
        let identifier = "-unicorn"

        // When
        cache.add(image, for: request, withIdentifier: identifier)
        let cachedImage = cache.image(for: request, withIdentifier: identifier)

        // Then
        XCTAssertNotNil(cachedImage, "cached image should not be nil")
        XCTAssertEqual(cachedImage, image, "cached image should be equal to image")
    }

    func testThatAddingImageToCacheWithDuplicateIdentifierReplacesCachedImage() {
        // Given
        let unicornImage = image(forResource: "unicorn", withExtension: "png")
        let pirateImage = image(forResource: "pirate", withExtension: "jpg")
        let identifier = "animal"

        // When
        cache.add(unicornImage, withIdentifier: identifier)
        let cachedImage1 = cache.image(withIdentifier: identifier)

        cache.add(pirateImage, withIdentifier: identifier)
        let cachedImage2 = cache.image(withIdentifier: identifier)

        // Then
        XCTAssertNotNil(cachedImage1, "cached image 1 should not be nil")
        XCTAssertNotNil(cachedImage2, "cached image 2 should not be nil")

        XCTAssertEqual(cachedImage1, unicornImage, "cached image 1 should be equal to unicorn image")
        XCTAssertEqual(cachedImage2, pirateImage, "cached image 2 should be equal to pirate image")
        XCTAssertNotEqual(cachedImage1, cachedImage2, "cached image 1 should not be equal to cached image 2")
    }

    func testThatAddingImageToCacheWithDuplicateRequestIdentifierReplacesCachedImage() {
        // Given
        let unicornImage = image(forResource: "unicorn", withExtension: "png")
        let pirateImage = image(forResource: "pirate", withExtension: "jpg")
        let request = Endpoint.get.urlRequest
        let identifier = "animal"

        // When
        cache.add(unicornImage, for: request, withIdentifier: identifier)
        let cachedImage1 = cache.image(for: request, withIdentifier: identifier)

        cache.add(pirateImage, for: request, withIdentifier: identifier)
        let cachedImage2 = cache.image(for: request, withIdentifier: identifier)

        // Then
        XCTAssertNotNil(cachedImage1, "cached image 1 should not be nil")
        XCTAssertNotNil(cachedImage2, "cached image 2 should not be nil")

        XCTAssertEqual(cachedImage1, unicornImage, "cached image 1 should be equal to unicorn image")
        XCTAssertEqual(cachedImage2, pirateImage, "cached image 2 should be equal to pirate image")
        XCTAssertNotEqual(cachedImage1, cachedImage2, "cached image 1 should not be equal to cached image 2")
    }

    // MARK: - Remove Image Tests

    func testThatItCanRemoveImageFromCacheWithIdentifier() {
        // Given
        let image = image(forResource: "unicorn", withExtension: "png")
        let identifier = "unicorn"

        // When
        cache.add(image, withIdentifier: identifier)
        let cachedImageExists = cache.image(withIdentifier: identifier) != nil

        let removedImage = cache.removeImage(withIdentifier: identifier)
        let cachedImageExistsAfterRemoval = cache.image(withIdentifier: identifier) != nil

        // Then
        XCTAssertTrue(cachedImageExists, "cached image exists should be true")
        XCTAssertTrue(removedImage, "removed image should be true")
        XCTAssertFalse(cachedImageExistsAfterRemoval, "cached image exists after removal should be false")
    }

    func testThatItCanRemoveImageFromCacheWithRequestIdentifier() {
        // Given
        let image = image(forResource: "unicorn", withExtension: "png")
        let request = Endpoint.get.urlRequest
        let identifier = "unicorn"

        // When
        cache.add(image, for: request, withIdentifier: identifier)
        let cachedImageExists = cache.image(for: request, withIdentifier: identifier) != nil

        let removedImage = cache.removeImage(for: request, withIdentifier: identifier)
        let cachedImageExistsAfterRemoval = cache.image(for: request, withIdentifier: identifier) != nil

        // Then
        XCTAssertTrue(cachedImageExists, "cached image exists should be true")
        XCTAssertTrue(removedImage, "removed image should be true")
        XCTAssertFalse(cachedImageExistsAfterRemoval, "cached image exists after removal should be false")
    }

    func testThatItCanRemoveImagesFromCacheMatchingRequestIdentifier() {
        // Given
        let image = image(forResource: "unicorn", withExtension: "png")
        let request = Endpoint.get.urlRequest

        let identifier1 = "unicorn-100"
        let identifier2 = "unicorn-400"

        // When
        cache.add(image, for: request, withIdentifier: identifier1)
        cache.add(image, for: request, withIdentifier: identifier2)

        let cachedImageExists1 = cache.image(for: request, withIdentifier: identifier1) != nil
        let cachedImageExists2 = cache.image(for: request, withIdentifier: identifier2) != nil

        let removedImages = cache.removeImages(matching: request)
        let cachedImageExistsAfterRemoval1 = cache.image(for: request, withIdentifier: identifier1) != nil
        let cachedImageExistsAfterRemoval2 = cache.image(for: request, withIdentifier: identifier2) != nil

        // Then
        XCTAssertTrue(cachedImageExists1)
        XCTAssertTrue(cachedImageExists2)
        XCTAssertTrue(removedImages)
        XCTAssertFalse(cachedImageExistsAfterRemoval1)
        XCTAssertFalse(cachedImageExistsAfterRemoval2)
    }

    func testThatItCanRemoveAllImagesFromCache() {
        // Given
        let image = image(forResource: "unicorn", withExtension: "png")
        let identifier = "unicorn"

        // When
        cache.add(image, withIdentifier: identifier)
        let cachedImageExists = cache.image(withIdentifier: identifier) != nil

        let removedImages = cache.removeAllImages()
        let cachedImageExistsAfterRemoval = cache.image(withIdentifier: identifier) != nil

        // Then
        XCTAssertTrue(cachedImageExists, "cached image exists should be true")
        XCTAssertTrue(removedImages, "removed images should be true")
        XCTAssertFalse(cachedImageExistsAfterRemoval, "cached image exists after removal should be false")
    }

    #if os(iOS) || os(tvOS)

    func testThatItRemovesAllImagesFromCacheWhenReceivingMemoryWarningNotification() {
        // Given
        let image = image(forResource: "unicorn", withExtension: "png")
        let identifier = "unicorn"

        // When
        cache.add(image, withIdentifier: identifier)
        let cachedImageExists = cache.image(withIdentifier: identifier) != nil

        let notification = UIApplication.didReceiveMemoryWarningNotification

        NotificationCenter.default.post(name: notification, object: nil)

        let cachedImageExistsAfterNotification = cache.image(withIdentifier: identifier) != nil

        // Then
        XCTAssertTrue(cachedImageExists, "cached image exists should be true")
        XCTAssertFalse(cachedImageExistsAfterNotification, "cached image exists after notification should be false")
    }

    #endif

    // MARK: - Fetch Image Tests

    func testThatItCanFetchImageFromCacheWithIdentifier() {
        // Given
        let image = image(forResource: "unicorn", withExtension: "png")
        let identifier = "unicorn"

        // When
        let cachedImageBeforeAdd = cache.image(withIdentifier: identifier)
        cache.add(image, withIdentifier: identifier)
        let cachedImageAfterAdd = cache.image(withIdentifier: identifier)

        // Then
        XCTAssertNil(cachedImageBeforeAdd, "cached image before add should be nil")
        XCTAssertNotNil(cachedImageAfterAdd, "cached image after add should not be nil")
    }

    func testThatItCanFetchImageFromCacheWithRequestIdentifier() {
        // Given
        let image = image(forResource: "unicorn", withExtension: "png")
        let request = Endpoint.get.urlRequest
        let identifier = "unicorn"

        // When
        let cachedImageBeforeAdd = cache.image(for: request, withIdentifier: identifier)
        cache.add(image, for: request, withIdentifier: identifier)
        let cachedImageAfterAdd = cache.image(for: request, withIdentifier: identifier)

        // Then
        XCTAssertNil(cachedImageBeforeAdd, "cached image before add should be nil")
        XCTAssertNotNil(cachedImageAfterAdd, "cached image after add should not be nil")
    }

    // MARK: - Memory Usage Tests

    func testThatItIncrementsMemoryUsageWhenAddingImageToCache() {
        // Given
        let image = image(forResource: "unicorn", withExtension: "png")
        let identifier = "unicorn"

        // When
        let initialMemoryUsage = cache.memoryUsage
        cache.add(image, withIdentifier: identifier)
        let currentMemoryUsage = cache.memoryUsage

        // Then
        XCTAssertEqual(initialMemoryUsage, 0, "initial memory usage should be 0")
        XCTAssertEqual(currentMemoryUsage, 164_000, "current memory usage should be 164000")
    }

    func testThatItDecrementsMemoryUsageWhenRemovingImageFromCache() {
        // Given
        let image = image(forResource: "unicorn", withExtension: "png")
        let identifier = "unicorn"

        // When
        cache.add(image, withIdentifier: identifier)
        let initialMemoryUsage = cache.memoryUsage
        cache.removeImage(withIdentifier: identifier)
        let currentMemoryUsage = cache.memoryUsage

        // Then
        XCTAssertEqual(initialMemoryUsage, 164_000, "initial memory usage should be 164000")
        XCTAssertEqual(currentMemoryUsage, 0, "current memory usage should be 0")
    }

    func testThatItDecrementsMemoryUsageWhenRemovingAllImagesFromCache() {
        // Given
        let image = image(forResource: "unicorn", withExtension: "png")
        let identifier = "unicorn"

        // When
        cache.add(image, withIdentifier: identifier)
        let initialMemoryUsage = cache.memoryUsage
        cache.removeAllImages()
        let currentMemoryUsage = cache.memoryUsage

        // Then
        XCTAssertEqual(initialMemoryUsage, 164_000, "initial memory usage should be 164000")
        XCTAssertEqual(currentMemoryUsage, 0, "current memory usage should be 0")
    }

    // MARK: - Purging Tests

    func testThatItPurgesImagesWhenMemoryCapacityIsReached() {
        // Given
        let image = image(forResource: "unicorn", withExtension: "png")
        let identifier = "unicorn"

        var memoryUsage: [UInt64] = []

        // When
        for index in 1...640 {
            cache.add(image, withIdentifier: "\(identifier)-\(index)")
            memoryUsage.append(cache.memoryUsage)
        }

        memoryUsage = Array(memoryUsage.dropFirst(638))

        // Then
        XCTAssertEqual(memoryUsage[0], 104_796_000, "memory usage prior to purge does not match expected value")
        XCTAssertEqual(memoryUsage[1], 62_812_000, "memory usage after purge does not match expected value")
    }

    func testThatItPrioritizesImagesWithOldestLastAccessDatesDuringPurge() {
        // Given
        let image = image(forResource: "unicorn", withExtension: "png")
        let identifier = "unicorn"

        // When
        for index in 1...640 {
            cache.add(image, withIdentifier: "\(identifier)-\(index)")
        }

        // Then
        for index in 1...257 {
            let cachedImage = cache.image(withIdentifier: "\(identifier)-\(index)")
            XCTAssertNil(cachedImage, "cached image with identifier: \"\(identifier)-\(index)\" should be nil")
        }

        for index in 258...640 {
            let cachedImage = cache.image(withIdentifier: "\(identifier)-\(index)")
            XCTAssertNotNil(cachedImage, "cached image with identifier: \"\(identifier)-\(index)\" should not be nil")
        }
    }

    func testThatAccessingCachedImageUpdatesLastAccessDate() {
        // Given
        let image = image(forResource: "unicorn", withExtension: "png")
        let identifier = "unicorn"

        // When
        for index in 1...639 {
            cache.add(image, withIdentifier: "\(identifier)-\(index)")
        }

        _ = cache.image(withIdentifier: "\(identifier)-1")
        cache.add(image, withIdentifier: "\(identifier)-640")

        // Then
        let firstCachedImage = cache.image(withIdentifier: "\(identifier)-1")
        XCTAssertNotNil(firstCachedImage, "first cached image should not be nil")

        for index in 2...258 {
            let cachedImage = cache.image(withIdentifier: "\(identifier)-\(index)")
            XCTAssertNil(cachedImage, "cached image with identifier: \"\(identifier)-\(index)\" should be nil")
        }

        for index in 259...640 {
            let cachedImage = cache.image(withIdentifier: "\(identifier)-\(index)")
            XCTAssertNotNil(cachedImage, "cached image with identifier: \"\(identifier)-\(index)\" should not be nil")
        }
    }
}

final class ImageCacheThreadSafetyTests: BaseTestCase {
    func testMultipleReadsAndWrites() {
        // Given
        let cache = AutoPurgingImageCache(memoryCapacity: 1_000_000, preferredMemoryUsageAfterPurge: 100_000)
        let image = image(forResource: "unicorn", withExtension: "png")

        // When
        DispatchQueue.concurrentPerform(iterations: 100) { iteration in
            DispatchQueue.concurrentPerform(iterations: 100) { _ in
                cache.add(image, withIdentifier: "\(iteration)")
            }
            DispatchQueue.concurrentPerform(iterations: 100) { _ in
                _ = cache.image(withIdentifier: "\(iteration)")
            }
            DispatchQueue.concurrentPerform(iterations: 100) { _ in
                cache.removeImage(withIdentifier: "\(iteration)")
            }
        }

        // Then
        XCTAssertNil(cache.image(withIdentifier: "99"))
    }
}
