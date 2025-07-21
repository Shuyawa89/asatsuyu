import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("朝露 (Asatsuyu)")
                .font(.title)
                .fontWeight(.medium)

            Text("ポモドーロタイマー + メモ")
                .foregroundColor(.secondary)

            Spacer()

            Text("開発中...")
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 320, height: 400)
    }
}

#Preview {
    ContentView()
}
