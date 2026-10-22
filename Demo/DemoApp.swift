import SwiftUI
import OperationOwnership
import OperationOwnershipUI

/// The app owns its scenario catalogue. The library ships three presets; the
/// fourth — search-as-you-type — is a product decision about *this* app's
/// network lane and its "latest query wins" sharing rule, so it is declared
/// here, with the library's core types, and handed to the library's view.
enum DemoScenarios {
    static let network = Lane("network")

    static let searchAsYouType = LabScenario(
        id: "search-as-you-type",
        title: "Search as you type",
        summary: "Four keystrokes, one tick apart, each querying the same results list for 3 ticks at 10 tokens/tick. Owned work declares .replace: only the latest query should finish.",
        endTick: 10,
        lanes: [network: LaneLimits(maxConcurrent: 4, maxQueued: 8)],
        steps: [
            .init(0, .open("session", .session, parent: nil)),
            .init(0, .open("browse", .flow, parent: "session")),
            .init(0, .open("search-field", .view, parent: "browse")),
        ] + ["s", "sw", "swi", "swif"].enumerated().map { index, query in
            LabScenario.TimedStep(index, .request(LabRequest(
                owner: "search-field", intent: "Query \"\(query)\"", resource: "search-results",
                lane: network, ownedLifetime: .owner, ownedSharing: .replace,
                durationTicks: 3, costPerTick: 10)))
        })

    static let all: [LabScenario] = LabScenario.presets + [searchAsYouType]
}

@main
struct OperationOwnershipDemoApp: App {
    var body: some Scene {
        WindowGroup {
            OwnershipLabView(scenarios: DemoScenarios.all, initialScenarioID: LabScenario.navigateAway.id)
        }
    }
}
