//
//  ContentView.swift
//  StatusBar
//
//  Created by Anders Östlin on 2020-10-13.
//

import ComposableArchitecture
import SwiftUI


//MARK: Model

enum Something: Int, CaseIterable, Identifiable {
    var id: Int {
        return rawValue
    }
    
    case foo = 0
    case bar
    case baz
    
    var localizedName: String {
        switch self {
        case .foo:
            return "Foo"
        case .bar:
            return "Boo"
        case .baz:
            return "Baz"
        }
    }
}

struct AppState: Equatable {
    var someState: Something = .foo
}

extension AppState {
    var activeColorScheme: ColorScheme {
        get { (someState == .foo || someState == .bar) ? .dark : .light }
    }
}

//MARK: Update

enum AppAction: Equatable {
    case somethingChanged(Something)
}

struct AppEnvironment {}

let appRecucer = Reducer<AppState, AppAction, AppEnvironment> { state, action, _ in
    switch action {
    
    case let .somethingChanged(something):
        state.someState = something
        return .none
    }
}

//MARK: View

struct ContentView: View {
    let store: Store<AppState, AppAction>
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                Text("Select something").font(.title)
                Picker(
                    selection: viewStore.binding(
                        get: { $0.someState.rawValue },
                        send: { AppAction.somethingChanged(Something(rawValue: $0)!)
                        }
                    ),
                    label: Text("Something")) {
                        ForEach(Something.allCases) {
                            Text($0.localizedName)
                        }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .background(Color(.secondarySystemBackground))
            .preferredColorScheme(viewStore.activeColorScheme)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: .init(initialState: AppState(), reducer: appRecucer, environment: AppEnvironment()))
    }
}
