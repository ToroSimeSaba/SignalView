import SwiftUI

struct ZoomedImagesView: View {
    var zoomedImages: [UIImage]

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 8) {
                    ForEach(zoomedImages.indices, id: \.self) { i in
                        Image(uiImage: zoomedImages[i])
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(90))
                            .border(Color.white, width: 2)
                            .background(Color.black)
                    }
                }
                .padding()
            }
        }
    }
}
