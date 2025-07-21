import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TimerView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("タイマー")
                }
                .tag(0)
            
            Text("メモ機能（開発中）")
                .frame(width: 320, height: 400)
                .tabItem {
                    Image(systemName: "note.text")
                    Text("メモ")
                }
                .tag(1)
            
            Text("設定（開発中）")
                .frame(width: 320, height: 400)
                .tabItem {
                    Image(systemName: "gear")
                    Text("設定")
                }
                .tag(2)
        }
        .frame(width: 320, height: 400)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}