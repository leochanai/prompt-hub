import SwiftUI
import AppKit

struct ImageCompareSlider: View {
  var left: NSImage
  var right: NSImage
  @Binding var ratio: CGFloat

  var body: some View {
    GeometryReader { geo in
      ZStack(alignment: .leading) {
        Image(nsImage: right)
          .resizable()
          .scaledToFit()
          .frame(width: geo.size.width, height: geo.size.height)

        Image(nsImage: left)
          .resizable()
          .scaledToFit()
          .frame(width: geo.size.width, height: geo.size.height)
          .mask(
            Rectangle()
              .frame(width: max(0, min(geo.size.width, ratio * geo.size.width)))
          )

        // Divider + handle
        Rectangle()
          .fill(Color.white.opacity(0.8))
          .frame(width: 2)
          .shadow(radius: 1)
          .offset(x: max(0, min(geo.size.width, ratio * geo.size.width)) - 1)

        Circle()
          .fill(Color.white)
          .frame(width: 18, height: 18)
          .shadow(radius: 2)
          .overlay(Circle().stroke(AppTheme.cardBorder))
          .offset(x: max(0, min(geo.size.width - 18, ratio * geo.size.width - 9)))
          .gesture(
            DragGesture(minimumDistance: 0)
              .onChanged { value in
                let x = max(0, min(geo.size.width, value.location.x))
                ratio = x / geo.size.width
              }
          )
      }
      .contentShape(Rectangle())
      .gesture(
        DragGesture(minimumDistance: 0)
          .onChanged { value in
            let x = max(0, min(geo.size.width, value.location.x))
            ratio = x / geo.size.width
          }
      )
    }
  }
}
