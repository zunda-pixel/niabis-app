import SwiftUI

struct AppIcon: View {
  let bigCircleSize: CGFloat = 200
  let miniCircleSize: CGFloat = 140

  var body: some View {
    VStack(spacing: 10) {
      ZStack {
        ZStack {
          Circle()
            .frame(width: bigCircleSize + 100, height: bigCircleSize + 100)
            .foregroundStyle(.orange.opacity(0.3))
          Circle()
            .frame(width: miniCircleSize + 100, height: miniCircleSize + 100)
            .foregroundStyle(.background)
        }
        .scaleEffect(y: 0.3)
        .offset(y: 180)
        
        ZStack {
          Circle()
            .frame(width: bigCircleSize, height: bigCircleSize)
            .foregroundStyle(.orange.opacity(0.5))
          Circle()
            .frame(width: miniCircleSize, height: miniCircleSize)
            .foregroundStyle(.background)
        }
        .scaleEffect(y: 0.3)
        .offset(y: 180)

        
        Triangle()
          .frame(width: bigCircleSize, height: bigCircleSize)
          .clipShape(.circle)
          .offset(y: bigCircleSize / 2 - 5)
          .scaleEffect(x: 1.18, anchor: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
          .foregroundStyle(.orange)
        
        Circle()
          .frame(width: bigCircleSize, height: bigCircleSize)
          .foregroundStyle(.orange)
        
        Circle()
          .frame(width: miniCircleSize, height: miniCircleSize)
        
        Text("N")
          .font(.custom("Noteworthy", size: 120).bold())          .foregroundStyle(.orange)

      }
      .padding(.bottom, bigCircleSize / 2 - 5)
      .padding(.horizontal, bigCircleSize / 4)
      .padding(20)
      .foregroundStyle(.background)
    }
    .background(.background)
  }
}

#Preview {
  AppIcon()
    .padding()
    .border(.red)
}

struct Triangle: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: .init(x: rect.minX, y: rect.minY))
    
    path.addLine(to: .init(
      x: rect.midX,
      y: rect.maxY
    ))
    path.addLine(to: .init(
      x: rect.midX,
      y: rect.maxY
    ))
    
    path.addLine(to: .init(
      x: rect.maxX,
      y: rect.minY
    ))

    return path
  }
}
