import SwiftUI

struct ThumbnailView: View {
    let pdfData: Data

    var body: some View {
        if let image = UIImage(data: pdfData) {
            return AnyView(
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            )
        } else {
            return AnyView(
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .foregroundColor(.gray)
            )
        }
    }
}

