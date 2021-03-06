import Foundation
import ReadingList_Foundation
import WhatsNewKit

struct ChangeListProvider {
    let generalImprovements = WhatsNew.Item(
        title: "Improvements and Fixes",
        subtitle: "Various improvements and fixes",
        image: UIImage(largeSystemImageNamed: "bolt.fill")
    )

    let changeLog = [
        Version(major: 1, minor: 13, patch: 0): [
            WhatsNew.Item(
                title: "Bulk Scan",
                subtitle: "Scan multiple barcodes in one session",
                image: UIImage(largeSystemImageNamed: "barcode")
            ),
            WhatsNew.Item(
                title: "Import from GoodReads",
                subtitle: "CSV Import can now be performed from a GoodReads file",
                image: UIImage(largeSystemImageNamed: "arrow.up.doc.fill")
            )
        ]
    ]

    func thisVersionChangeList() -> UIViewController? {
        let thisVersion = BuildInfo.thisBuild.version
        let itemsToPresent = changeLog[thisVersion] ?? changeLog.filter {
            // Get the versions which match this major and minor version...
            ($0.key.major, $0.key.minor) == (thisVersion.major, thisVersion.minor)
        }.max {
            // ...and find the largest patch-number version of that (if any)
            $0.key < $1.key
        }?.value

        if var itemsToPresent = itemsToPresent {
            itemsToPresent.append(generalImprovements)
            return whatsNewViewController(for: itemsToPresent)
        } else {
            return nil
        }
    }

    func changeListController(after version: Version) -> UIViewController? {
        // We add features without changing the version number on TestFlight, which would make these change list screens
        // possibly confusing and out-of-date. TestFlight users will see a change log when they upgrade anyway.
        guard BuildInfo.thisBuild.type != .testFlight else { return nil }

        var items = changeLog.filter { $0.key > version }.map(\.value).reduce([], +)
        if items.isEmpty { return nil }
        items.append(generalImprovements)
        return whatsNewViewController(for: Array(items))
    }

    private func whatsNewViewController(for items: [WhatsNew.Item]) -> WhatsNewViewController {
        let coloredTitlePortion = "Reading List"
        let title = "What's New in \(coloredTitlePortion)"
        let whatsNew = WhatsNew(title: title, items: items)

        var configuration = WhatsNewViewController.Configuration()
        configuration.itemsView.imageSize = .fixed(height: 40)
        if #available(iOS 13.0, *) { } else {
            if GeneralSettings.theme.isDark {
                configuration.apply(theme: .darkBlue)
            }
        }
        if let startIndex = title.startIndex(ofFirstSubstring: coloredTitlePortion) {
            configuration.titleView.secondaryColor = .init(startIndex: startIndex, length: coloredTitlePortion.count, color: .systemBlue)
        } else {
            assertionFailure("Could not find title substring")
        }

        return WhatsNewViewController(whatsNew: whatsNew, configuration: configuration)
    }
}
