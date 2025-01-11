import SwiftUI

struct MetadataRow: View {
    let data: MetadataRowData

    var body: some View {
        VStack(alignment: .leading) {
            Text(data.title)
                .font(.headline)
            Text(data.subtitle)
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
        }
    }
}
