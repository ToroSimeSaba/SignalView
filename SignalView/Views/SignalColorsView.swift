import SwiftUI
import AVFoundation

struct SignalColorsView: View {
    @Binding var signalColors: [(label: String, color: String)]
    let speak: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(signalColors.indices, id: \.self) {  i in
                let color = signalColors[i].color
                Text("信号機：\(color)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(color == "赤" ? .red : .blue)
                    .background(Color.white)
                    .padding(.bottom, 20)
                    .onTapGesture {
                        speak("信号機は、 \(color)　です")
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 20)
    }
}

