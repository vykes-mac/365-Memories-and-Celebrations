//
//  ModelTests.swift
//  Three65Tests
//
//  Created by Kenroy McLeish on 31/01/2026.
//

import Testing
import Foundation
import SwiftData
@testable import Three65

@Suite("Data Model Tests")
struct ModelTests {

    // MARK: - Test Helpers

    /// Type alias to avoid ambiguity with Foundation.Category
    typealias AppCategory = Three65.Category

    @MainActor
    private func createTestContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: Person.self, Moment.self, AppCategory.self, Media.self, CollageProject.self, ReminderSetting.self,
            configurations: config
        )
    }

    // MARK: - Person Tests

    @Test("Person model can be created and persisted")
    @MainActor
    func testPersonCreation() async throws {
        let container = try createTestContainer()
        let context = container.mainContext

        let person = Person(
            name: "Mom",
            relationship: "Mother",
            avatarRef: "avatar_mom",
            notes: "Always remembers birthdays"
        )

        context.insert(person)
        try context.save()

        let descriptor = FetchDescriptor<Person>()
        let fetched = try context.fetch(descriptor)

        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Mom")
        #expect(fetched.first?.relationship == "Mother")
        #expect(fetched.first?.avatarRef == "avatar_mom")
        #expect(fetched.first?.notes == "Always remembers birthdays")
    }

    // MARK: - Moment Tests

    @Test("Moment model can be created and persisted")
    @MainActor
    func testMomentCreation() async throws {
        let container = try createTestContainer()
        let context = container.mainContext

        let person = Person(name: "Dad", relationship: "Father")
        context.insert(person)

        let moment = Moment(
            person: person,
            date: Date(),
            recurring: true,
            categoryId: "birthday",
            title: "Dad's Birthday",
            notes: "He's turning 60!"
        )

        context.insert(moment)
        try context.save()

        let descriptor = FetchDescriptor<Moment>()
        let fetched = try context.fetch(descriptor)

        #expect(fetched.count == 1)
        #expect(fetched.first?.title == "Dad's Birthday")
        #expect(fetched.first?.recurring == true)
        #expect(fetched.first?.categoryId == "birthday")
        #expect(fetched.first?.person?.name == "Dad")
    }

    @Test("Person-Moment relationship works correctly")
    @MainActor
    func testPersonMomentRelationship() async throws {
        let container = try createTestContainer()
        let context = container.mainContext

        let person = Person(name: "Sister", relationship: "Sibling")
        context.insert(person)

        let birthday = Moment(
            person: person,
            date: Date(),
            recurring: true,
            categoryId: "birthday",
            title: "Sister's Birthday"
        )
        let graduation = Moment(
            person: person,
            date: Date(),
            recurring: false,
            categoryId: "milestone",
            title: "Graduation Day"
        )

        context.insert(birthday)
        context.insert(graduation)
        try context.save()

        let personDescriptor = FetchDescriptor<Person>()
        let fetchedPerson = try context.fetch(personDescriptor).first

        #expect(fetchedPerson?.moments?.count == 2)
    }

    // MARK: - Category Tests

    @Test("Category model can be created and persisted")
    @MainActor
    func testCategoryCreation() async throws {
        let container = try createTestContainer()
        let context = container.mainContext

        let category = Three65.Category(
            id: "custom",
            name: "Custom Event",
            colorToken: "categoryBirthday",
            icon: "star.fill",
            isSystem: false,
            sortOrder: 10
        )

        context.insert(category)
        try context.save()

        let descriptor = FetchDescriptor<Three65.Category>()
        let fetched = try context.fetch(descriptor)

        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Custom Event")
        #expect(fetched.first?.isSystem == false)
    }

    @Test("Default categories are correctly defined")
    func testDefaultCategories() {
        let defaults = Three65.Category.defaultCategories

        #expect(defaults.count == 5)

        let ids = defaults.map { $0.id }
        #expect(ids.contains("birthday"))
        #expect(ids.contains("anniversary"))
        #expect(ids.contains("milestone"))
        #expect(ids.contains("memorial"))
        #expect(ids.contains("justBecause"))
    }

    @Test("Category seed data can be inserted")
    @MainActor
    func testCategorySeedData() async throws {
        let container = try createTestContainer()
        let context = container.mainContext

        Three65.Category.seedDefaultCategories(in: context)
        try context.save()

        let descriptor = FetchDescriptor<Three65.Category>(
            predicate: #Predicate<Three65.Category> { $0.isSystem == true }
        )
        let fetched = try context.fetch(descriptor)

        #expect(fetched.count == 5)
    }

    // MARK: - Media Tests

    @Test("Media model can be created and persisted")
    @MainActor
    func testMediaCreation() async throws {
        let container = try createTestContainer()
        let context = container.mainContext

        let person = Person(name: "Friend", relationship: "Best Friend")
        context.insert(person)

        let media = Media(
            person: person,
            localIdentifier: "ABC123",
            type: .photo
        )

        context.insert(media)
        try context.save()

        let descriptor = FetchDescriptor<Media>()
        let fetched = try context.fetch(descriptor)

        #expect(fetched.count == 1)
        #expect(fetched.first?.localIdentifier == "ABC123")
        #expect(fetched.first?.type == .photo)
        #expect(fetched.first?.person?.name == "Friend")
    }

    @Test("Media can be attached to a moment")
    @MainActor
    func testMediaMomentRelationship() async throws {
        let container = try createTestContainer()
        let context = container.mainContext

        let person = Person(name: "Partner", relationship: "Spouse")
        context.insert(person)

        let moment = Moment(
            person: person,
            date: Date(),
            recurring: true,
            categoryId: "anniversary",
            title: "Our Anniversary"
        )
        context.insert(moment)

        let photo = Media(
            moment: moment,
            localIdentifier: "PHOTO123",
            type: .photo
        )
        let video = Media(
            moment: moment,
            localIdentifier: "VIDEO456",
            type: .video
        )

        context.insert(photo)
        context.insert(video)
        try context.save()

        let momentDescriptor = FetchDescriptor<Moment>()
        let fetchedMoment = try context.fetch(momentDescriptor).first

        #expect(fetchedMoment?.media?.count == 2)
    }

    // MARK: - CollageProject Tests

    @Test("CollageProject model can be created and persisted")
    @MainActor
    func testCollageProjectCreation() async throws {
        let container = try createTestContainer()
        let context = container.mainContext

        let project = CollageProject(
            template: .polaroid,
            assets: ["asset1", "asset2", "asset3"],
            captionDrafts: ["Happy Birthday!", "Another year older!"]
        )

        context.insert(project)
        try context.save()

        let descriptor = FetchDescriptor<CollageProject>()
        let fetched = try context.fetch(descriptor)

        #expect(fetched.count == 1)
        #expect(fetched.first?.template == .polaroid)
        #expect(fetched.first?.assets.count == 3)
        #expect(fetched.first?.captionDrafts.count == 2)
    }

    @Test("CollageProject templates have display names")
    func testCollageTemplateDisplayNames() {
        #expect(CollageTemplate.polaroid.displayName == "Polaroid")
        #expect(CollageTemplate.grid.displayName == "Grid")
        #expect(CollageTemplate.filmStrip.displayName == "Film Strip")
        #expect(CollageTemplate.thenAndNow.displayName == "Then & Now")
    }

    // MARK: - ReminderSetting Tests

    @Test("ReminderSetting model can be created and persisted")
    @MainActor
    func testReminderSettingCreation() async throws {
        let container = try createTestContainer()
        let context = container.mainContext

        let setting = ReminderSetting(
            enabled: true,
            offsets: [.sevenDays, .dayOf],
            quietHoursEnabled: true
        )
        setting.setQuietHours(startHour: 22, startMinute: 0, endHour: 8, endMinute: 0)

        context.insert(setting)
        try context.save()

        let descriptor = FetchDescriptor<ReminderSetting>()
        let fetched = try context.fetch(descriptor)

        #expect(fetched.count == 1)
        #expect(fetched.first?.enabled == true)
        #expect(fetched.first?.offsets.contains(.sevenDays) == true)
        #expect(fetched.first?.offsets.contains(.dayOf) == true)
        #expect(fetched.first?.offsets.contains(.oneDay) == false)
        #expect(fetched.first?.quietHoursEnabled == true)
    }

    @Test("ReminderOffset has correct day values")
    func testReminderOffsetDays() {
        #expect(ReminderOffset.sevenDays.days == 7)
        #expect(ReminderOffset.oneDay.days == 1)
        #expect(ReminderOffset.dayOf.days == 0)
    }

    @Test("Default reminder settings are correct")
    func testDefaultReminderSettings() {
        let setting = ReminderSetting.createDefault()

        #expect(setting.enabled == true)
        #expect(setting.offsets.count == 3)
        #expect(setting.quietHoursEnabled == true)
        #expect(setting.quietStart?.hour == 22)
        #expect(setting.quietEnd?.hour == 8)
    }
}
