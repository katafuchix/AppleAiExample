import SwiftUI
import Playgrounds

struct ContentView: View {
    var body: some View {
        VStack {
            NavigationStack {
                List {
                    Section(header: Text("Example")) {
                        Group {
                            NavigationLink("Image Generate Demo", destination: ImageGenDemoView())
                            NavigationLink("Translation Demo", destination: TranslationDemoView())
                            NavigationLink("Foundation Models Demo", destination: FoundationModelsDemoView())
                            NavigationLink("Integrated AI Demo", destination: IntegratedAIDemoView())
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

#Playground {
    _ = 1 + 2
}
