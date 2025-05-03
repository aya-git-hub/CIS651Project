import SwiftUI

struct DraggableChatButton: View {
    private let bottomOffset: CGFloat = 80
    private let buttonSize: CGFloat = 60
    private let minYLimit: CGFloat = 30   // Set upper bound
    private let maxYLimit: CGFloat = 540  // Set lower bound

    @State private var position: CGPoint = .init(x: 363, y: 540)
    @GestureState private var dragOffset: CGSize = .zero

    var action: () -> Void

    private var screenSize: CGSize {
        UIScreen.main.bounds.size
    }

    var body: some View {
        ZStack {
            Image(systemName: "message.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
                .shadow(radius: 3)
        }
        .frame(width: buttonSize, height: buttonSize)
        .contentShape(Rectangle())
        .position(position == .zero ? CGPoint(x: screenSize.width - buttonSize / 2, y: min(maxYLimit, screenSize.height - bottomOffset - buttonSize / 2)) : position)
        .offset(dragOffset)
        .onAppear {
            if position == .zero {
                position = CGPoint(x: screenSize.width - buttonSize / 2, y: min(maxYLimit, screenSize.height - bottomOffset - buttonSize / 2))
            }
        }
        .highPriorityGesture(
            LongPressGesture(minimumDuration: 0.2)
                .sequenced(before: DragGesture())
                .updating($dragOffset) { value, state, _ in
                    if case .second(true, let drag?) = value {
                        state = drag.translation
                        // Print coordinates during dragging
                        let half = buttonSize / 2
                        let currentX = position.x + drag.translation.width
                        let currentY = position.y + drag.translation.height
                        let limitedX = min(max(half, currentX), screenSize.width - half)
                        let limitedY = min(max(half, currentY), screenSize.height - half)
                        //print("Dragging coordinates: (\(limitedX), \(limitedY))")
                    }
                }
                .onEnded { value in
                    switch value {
                    case .second(true, let drag?):
                        let half = buttonSize / 2
                        var newX = position.x + drag.translation.width
                        var newY = position.y + drag.translation.height
                        newX = min(max(half, newX), screenSize.width - half)
                        newY = min(max(half, newY), screenSize.height - half)

                        if newY >= maxYLimit {
                            // Exceeded lower bound, snap to left/right, y fixed at maxYLimit
                            let leftDist = abs(newX - half)
                            let rightDist = abs(newX - (screenSize.width - half))
                            if leftDist < rightDist {
                                newX = half
                            } else {
                                newX = screenSize.width - half
                            }
                            newY = maxYLimit
                        } else if newY <= minYLimit {
                            // Exceeded upper bound, snap to left/right, y fixed at minYLimit
                            let leftDist = abs(newX - half)
                            let rightDist = abs(newX - (screenSize.width - half))
                            if leftDist < rightDist {
                                newX = half
                            } else {
                                newX = screenSize.width - half
                            }
                            newY = minYLimit
                        } else {
                            // Calculate distance to four edges
                            let leftDist = newX - half
                            let rightDist = screenSize.width - (newX + half)
                            let topDist = newY - half
                            let bottomDist = screenSize.height - (newY + half)

                            let minDist = min(leftDist, rightDist, topDist, bottomDist)
                            if minDist == leftDist {
                                newX = half
                            } else if minDist == rightDist {
                                newX = screenSize.width - half
                            } else if minDist == topDist {
                                newY = half
                            } else if minDist == bottomDist {
                                newY = screenSize.height - half
                            }
                        }

                        position = CGPoint(x: newX, y: newY)
                        print("Snapped coordinates: (\(newX), \(newY))")
                    default:
                        break
                    }
                }
        )
        .onTapGesture {
            action()
        }
        .animation(.spring(), value: position)
    }
}
