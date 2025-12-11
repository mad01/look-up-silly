import SwiftUI
import SpriteKit
import UIKit

// MARK: - Physics Categories

private enum GravityPhysicsCategory {
  static let player: UInt32 = 1 << 0
  static let orb: UInt32 = 1 << 1
  static let floor: UInt32 = 1 << 2
}

// MARK: - Challenge Wrapper

@MainActor
final class GravityGameChallenge: Challenge, ObservableObject {
  let type = ChallengeType.gravityDrop
  @Published var isCompleted = false
  var isTestMode = false
  
  func view(onComplete: @escaping () -> Void, appSettings: AppSettings) -> AnyView {
    AnyView(
      GravityGameView(
        challenge: self,
        onComplete: onComplete,
        appSettings: appSettings
      )
    )
  }
}

// MARK: - SpriteKit Scene

@MainActor
private final class NeonGravityScene: SKScene, @preconcurrency SKPhysicsContactDelegate {
  private enum OrbType: String {
    case good
    case bad
  }
  
  var scoreDidChange: ((Int) -> Void)?
  
  private var playerNode = SKShapeNode()
  private var floorNode = SKNode()
  private var currentScore = 0 {
    didSet { scoreDidChange?(currentScore) }
  }
  private var extraSpawnProbability: Double = 0
  
  private let baseSpawnInterval: TimeInterval = 0.9
  private var currentSpawnInterval: TimeInterval = 0.9
  private let minimumSpawnInterval: TimeInterval = 0.18
  private let spawnActionKey = "neon.spawn"
  private let feedback = UIImpactFeedbackGenerator(style: .medium)
  
  override init(size: CGSize) {
    super.init(size: size)
    scaleMode = .resizeFill
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMove(to view: SKView) {
    backgroundColor = .black
    physicsWorld.gravity = CGVector(dx: 0, dy: -7.0)
    physicsWorld.contactDelegate = self
    
    setupFloor()
    setupPlayer()
    startSpawning()
  }
  
  // MARK: - Public API
  
  func reset(for size: CGSize) {
    self.size = size
    removeAction(forKey: spawnActionKey)
    removeAllOrbs()
    setupFloor()
    setupPlayer()
    currentScore = 0
    isPaused = false
    startSpawning()
  }
  
  func resizeScene(to size: CGSize) {
    self.size = size
    updateFloorFrame()
    clampPlayerPosition()
  }
  
  func pauseGame() {
    isPaused = true
    removeAction(forKey: spawnActionKey)
  }
  
  func resumeGame() {
    isPaused = false
    startSpawning()
  }
  
  func updateDifficulty(progress: Double) {
    let adjusted = max(
      minimumSpawnInterval,
      baseSpawnInterval * (1 - (0.65 * progress))
    )
    
    guard abs(adjusted - currentSpawnInterval) > 0.02 else { return }
    currentSpawnInterval = adjusted
    extraSpawnProbability = min(0.8, progress * 0.8) // towards 80% chance to spawn an extra orb
    startSpawning()
  }
  
  // MARK: - Setup
  
  private func setupFloor() {
    floorNode.removeFromParent()
    
    floorNode = SKNode()
    floorNode.position = CGPoint(x: 0, y: 4)
    let edge = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: 0), to: CGPoint(x: size.width, y: 0))
    edge.categoryBitMask = GravityPhysicsCategory.floor
    edge.contactTestBitMask = GravityPhysicsCategory.orb
    edge.collisionBitMask = GravityPhysicsCategory.orb
    edge.isDynamic = false
    floorNode.physicsBody = edge
    
    addChild(floorNode)
  }
  
  private func setupPlayer() {
    playerNode.removeFromParent()
    
    let width = max(120, size.width * 0.25)
    let height: CGFloat = 26
    let paddleSize = CGSize(width: width, height: height)
    
    let paddle = SKShapeNode(rectOf: paddleSize, cornerRadius: 14)
    paddle.strokeColor = UIColor.systemCyan
    paddle.lineWidth = 3
    paddle.glowWidth = 12
    paddle.fillColor = UIColor.systemCyan.withAlphaComponent(0.15)
    paddle.position = CGPoint(x: size.width / 2, y: paddleSize.height * 3.5 + 20)
    
    let body = SKPhysicsBody(rectangleOf: paddleSize)
    body.isDynamic = false
    body.affectedByGravity = false
    body.categoryBitMask = GravityPhysicsCategory.player
    body.contactTestBitMask = GravityPhysicsCategory.orb
    body.collisionBitMask = GravityPhysicsCategory.orb
    body.friction = 0
    body.restitution = 0
    paddle.physicsBody = body
    
    playerNode = paddle
    addChild(paddle)
  }
  
  // MARK: - Spawn Logic
  
  private func startSpawning() {
    removeAction(forKey: spawnActionKey)
    scheduleNextSpawn()
  }

  private func scheduleNextSpawn() {
    let minWait = max(0.08, currentSpawnInterval * 0.55)
    let maxWait = currentSpawnInterval * 1.45
    let jittered = Double.random(in: minWait...maxWait)

    let wait = SKAction.wait(forDuration: jittered)
    let spawn = SKAction.run { [weak self] in
      self?.spawnOrb()
      self?.scheduleNextSpawn()
    }
    let sequence = SKAction.sequence([wait, spawn])
    run(sequence, withKey: spawnActionKey)
  }
  
  private func spawnOrb() {
    guard size.width > 0 else { return }
    
    let isGood = Bool(probability: 0.72)
    let type: OrbType = isGood ? .good : .bad
    
    // Random size between current range and up to ~2x
    let radius: CGFloat
    if Bool(probability: 0.5) {
      radius = CGFloat.random(in: 14...22)
    } else {
      radius = CGFloat.random(in: 22...44)
    }
    let color: UIColor = isGood ? .systemGreen : .systemRed
    let shapeChoice = Int.random(in: 0...2)
    let (orb, body): (SKShapeNode, SKPhysicsBody) = {
      switch shapeChoice {
      case 0:
        let node = SKShapeNode(circleOfRadius: radius)
        node.glowWidth = 10
        let physics = SKPhysicsBody(circleOfRadius: radius)
        return (node, physics)
      case 1:
        let size = CGSize(width: radius * 2.1, height: radius * 1.4)
        let node = SKShapeNode(rectOf: size, cornerRadius: 8)
        node.glowWidth = 10
        let physics = SKPhysicsBody(rectangleOf: size)
        return (node, physics)
      default:
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: radius * 1.3))
        path.addLine(to: CGPoint(x: -radius, y: -radius * 0.8))
        path.addLine(to: CGPoint(x: radius, y: -radius * 0.8))
        path.closeSubpath()
        let node = SKShapeNode(path: path)
        node.glowWidth = 10
        let physics = SKPhysicsBody(polygonFrom: path)
        return (node, physics)
      }
    }()
    
    orb.name = "orb"
    orb.userData = ["type": type.rawValue] as NSMutableDictionary
    orb.strokeColor = color
    orb.fillColor = color.withAlphaComponent(0.28)
    
    let x = CGFloat.random(in: radius...(size.width - radius))
    let y = size.height + radius + 40
    orb.position = CGPoint(x: x, y: y)
    
    body.mass = 0.08
    body.restitution = 0.9
    body.friction = 0.05
    body.linearDamping = 0.1
    body.angularDamping = 0.12
    body.categoryBitMask = GravityPhysicsCategory.orb
    body.contactTestBitMask = GravityPhysicsCategory.player | GravityPhysicsCategory.floor
    body.collisionBitMask = GravityPhysicsCategory.player | GravityPhysicsCategory.floor
    body.usesPreciseCollisionDetection = true
    orb.physicsBody = body
    
    body.applyAngularImpulse(CGFloat.random(in: -0.05...0.05))
    
    addChild(orb)

    // Occasional extra orb at higher difficulty, with a slight random delay to avoid grouping
    if Bool(probability: extraSpawnProbability) {
      let extraDelay = Double.random(in: 0.08...0.35)
      let wait = SKAction.wait(forDuration: extraDelay)
      let spawnExtra = SKAction.run { [weak self] in
        self?.spawnOrb()
      }
      run(SKAction.sequence([wait, spawnExtra]))
    }
  }
  
  // MARK: - Touch Handling
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let location = touch.location(in: self)
    movePlayer(to: location.x)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    touchesMoved(touches, with: event)
  }
  
  private func movePlayer(to x: CGFloat) {
    let clamped = clampX(x)
    playerNode.position.x = clamped
  }
  
  private func clampX(_ x: CGFloat) -> CGFloat {
    let halfWidth = playerNode.frame.width / 2
    return max(halfWidth, min(size.width - halfWidth, x))
  }
  
  // MARK: - Contacts
  
  func didBegin(_ contact: SKPhysicsContact) {
    let categories = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    
    if categories == (GravityPhysicsCategory.player | GravityPhysicsCategory.orb) {
      let orbBody = contact.bodyA.categoryBitMask == GravityPhysicsCategory.orb ? contact.bodyA : contact.bodyB
      handleCatch(for: orbBody)
    } else if categories == (GravityPhysicsCategory.floor | GravityPhysicsCategory.orb) {
      let orbBody = contact.bodyA.categoryBitMask == GravityPhysicsCategory.orb ? contact.bodyA : contact.bodyB
      orbBody.node?.removeFromParent()
    }
  }
  
  private func handleCatch(for orbBody: SKPhysicsBody) {
    guard let node = orbBody.node else { return }
    let typeRaw = node.userData?["type"] as? String
    let type = OrbType(rawValue: typeRaw ?? OrbType.bad.rawValue) ?? .bad
    
    if type == .good {
      currentScore += 1
    } else {
      currentScore -= 5
    }
    
    playHaptic(for: type)
    createExplosion(at: node.position, color: type == .good ? .systemGreen : .systemRed)
    node.removeFromParent()
  }
  
  // MARK: - Helpers
  
  private func playHaptic(for type: OrbType) {
    DispatchQueue.main.async { [feedback] in
      feedback.prepare()
      feedback.impactOccurred(intensity: type == .good ? 0.9 : 0.5)
    }
  }
  
  private func removeAllOrbs() {
    children.filter { $0.name == "orb" }.forEach { $0.removeFromParent() }
  }
  
  private func createExplosion(at point: CGPoint, color: UIColor) {
    let count = 8
    for _ in 0..<count {
      let spark = SKShapeNode(circleOfRadius: 3)
      spark.fillColor = color
      spark.strokeColor = color
      spark.position = point
      spark.glowWidth = 8
      
      let body = SKPhysicsBody(circleOfRadius: 3)
      body.affectedByGravity = false
      spark.physicsBody = body
      
      addChild(spark)
      
      let dx = CGFloat.random(in: -120...120)
      let dy = CGFloat.random(in: 80...180)
      let move = SKAction.moveBy(x: dx, y: dy, duration: 0.35)
      move.timingMode = .easeOut
      let fade = SKAction.fadeOut(withDuration: 0.3)
      let group = SKAction.group([move, fade])
      spark.run(.sequence([group, .removeFromParent()]))
    }
  }
  
  private func updateFloorFrame() {
    if floorNode.physicsBody != nil {
      let newEdge = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: 0), to: CGPoint(x: size.width, y: 0))
      newEdge.categoryBitMask = GravityPhysicsCategory.floor
      newEdge.contactTestBitMask = GravityPhysicsCategory.orb
      newEdge.collisionBitMask = GravityPhysicsCategory.orb
      newEdge.isDynamic = false
      floorNode.physicsBody = newEdge
    }
  }
  
  private func clampPlayerPosition() {
    playerNode.position.x = clampX(playerNode.position.x)
  }
}

// MARK: - SwiftUI Wrapper View

private struct GravityGameView: View {
  @Environment(\.themeColors) private var colors
  @Environment(\.dismiss) private var dismiss
  @Environment(\.challengeCancelAction) private var challengeCancelAction
  @ObservedObject var challenge: GravityGameChallenge
  let onComplete: () -> Void
  let appSettings: AppSettings
  
  @State private var scene = NeonGravityScene(size: .zero)
  @State private var score = 0
  @State private var timeRemaining = 90
  @State private var isGameOver = false
  @State private var hasStarted = false
  @State private var elapsedTime: TimeInterval = 0
  @State private var hasRecordedStart = false
  @State private var outcome: ChallengeOutcome = .pending
  @State private var highScore = 0
  private let targetScore = 70
  
  private let gameDuration: Int = 90
  private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
  var skipDelayRemaining: Int {
    guard !challenge.isTestMode else { return 0 }
    let remaining = Int(ceil(max(0, TimeInterval(appSettings.challengeCancelDelaySeconds) - elapsedTime)))
    return max(0, remaining)
  }
  
  var canSkip: Bool {
    skipDelayRemaining == 0
  }
  
  var skipButtonTitle: String {
    if canSkip {
      return NSLocalizedString("challenge.skip.button_ready", comment: "")
    } else {
      return String(
        format: NSLocalizedString("challenge.skip.button_countdown", comment: ""),
        skipDelayRemaining
      )
    }
  }
  
  var body: some View {
    GeometryReader { proxy in
      ZStack(alignment: .top) {
        SpriteView(scene: scene, options: [.allowsTransparency])
          .ignoresSafeArea()
          .onAppear {
            configureScene(with: proxy.size)
          }
          .onChange(of: proxy.size) { _, newSize in
            scene.resizeScene(to: newSize)
          }
        
        VStack(spacing: 14) {
          controlBar
            .padding(.horizontal, 20)
            .padding(.top, 16)
          
          hud
            .padding(.horizontal, 20)
          
          Spacer()
        }
        
        if !hasStarted || isGameOver {
          overlay
        }
      }
      .onReceive(timer) { _ in
        guard hasStarted, !isGameOver else { return }
        elapsedTime += 1
        if timeRemaining > 0 {
          timeRemaining -= 1
          let progress = 1 - (Double(timeRemaining) / Double(gameDuration))
          scene.updateDifficulty(progress: progress)
        }
        
        if timeRemaining <= 0 {
          handleGameOver()
        }
      }
      .onChange(of: challenge.isCompleted) { _, completed in
        if completed {
          outcome = .continued
          ChallengeStatsManager.shared.recordChallengeCompleted(
            type: .gravityDrop,
            isTestMode: challenge.isTestMode
          )
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onComplete()
          }
        }
      }
      .onDisappear {
        if outcome == .pending {
          ChallengeStatsManager.shared.recordChallengeCancelled(
            type: .gravityDrop,
            isTestMode: challenge.isTestMode
          )
        }
      }
    }
    .interactiveDismissDisabled(!canSkip)
    .presentationDetents([.large])
    .presentationDragIndicator(.hidden)
    .background(colors.background.ignoresSafeArea())
  }
  
  private var controlBar: some View {
    HStack(spacing: 10) {
      if !challenge.isTestMode {
        Button(action: {
          skipChallenge()
        }) {
          HStack(spacing: 6) {
            Image(systemName: "xmark.circle.fill")
              .font(.system(size: 20, weight: .semibold))
            Text(skipButtonTitle)
              .font(.footnote.weight(.semibold))
          }
          .foregroundColor(canSkip ? colors.textSecondary : colors.textDisabled)
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .background(
            Capsule()
              .fill(colors.surface.opacity(0.8))
              .overlay(
                Capsule()
                  .stroke(colors.divider, lineWidth: 1)
              )
          )
        }
        .disabled(!canSkip)
      }
      
      Spacer()
      
      Button {
        cancelChallenge()
      } label: {
        Image(systemName: "xmark")
          .font(.system(size: 16, weight: .bold))
          .foregroundColor(colors.textSecondary)
          .padding(10)
          .background(colors.surface.opacity(0.7), in: Circle())
      }
      .accessibilityLabel(Text(NSLocalizedString("challenge.cancel", comment: "")))
    }
  }
  
  private var hud: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(NSLocalizedString("challenge.gravitydrop.score", comment: ""))
          .font(.caption)
          .foregroundColor(colors.textSecondary)
        Text("\(score)")
          .font(.system(size: 34, weight: .bold, design: .monospaced))
          .foregroundColor(colors.gravityDrop)
        Text(String(format: NSLocalizedString("challenge.gravitydrop.goal", comment: ""), targetScore))
          .font(.caption)
          .foregroundColor(colors.textSecondary)
        if challenge.isTestMode {
          Text(String(format: NSLocalizedString("challenge.gravitydrop.high_score", comment: ""), highScore))
            .font(.caption)
            .foregroundColor(colors.textSecondary)
        }
      }
      
      Spacer()
      
      VStack(alignment: .trailing, spacing: 4) {
        Text(NSLocalizedString("challenge.gravitydrop.timer", comment: ""))
          .font(.caption)
          .foregroundColor(colors.textSecondary)
        Text("\(timeRemaining)s")
          .font(.system(size: 32, weight: .bold, design: .monospaced))
          .foregroundColor(colors.textPrimary)
      }
    }
  }
  
  private var overlay: some View {
    let isStart = !hasStarted && !isGameOver
    return ZStack {
      Color.black.opacity(0.65).ignoresSafeArea()
      
      VStack(spacing: 16) {
        Text(
          isStart
          ? NSLocalizedString("challenge.gravitydrop.title", comment: "")
          : (score >= targetScore
             ? NSLocalizedString("challenge.gravitydrop.win", comment: "")
             : NSLocalizedString("challenge.gravitydrop.game_over", comment: ""))
        )
        .font(.system(size: 28, weight: .bold, design: .rounded))
        .foregroundColor(colors.textPrimary)
        
        if isStart {
          Text(String(format: NSLocalizedString("challenge.gravitydrop.need_points", comment: ""), targetScore))
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(colors.textSecondary)
            .multilineTextAlignment(.center)
        } else {
          Text(String(format: NSLocalizedString("challenge.gravitydrop.final_score", comment: ""), score))
            .font(.system(size: 18, weight: .semibold, design: .monospaced))
            .foregroundColor(colors.textSecondary)
        }
        
        Button {
          if isStart {
            startGame()
          } else {
            restartGame()
          }
        } label: {
          Text(
            isStart
            ? NSLocalizedString("challenge.gravitydrop.start", comment: "")
            : NSLocalizedString("challenge.gravitydrop.play_again", comment: "")
          )
          .font(.headline)
          .foregroundColor(colors.textOnAccent)
          .frame(maxWidth: .infinity)
          .padding()
          .background(colors.gravityDrop)
          .cornerRadius(14)
        }
        .padding(.horizontal, 24)
      }
      .padding()
      .background(colors.surface.opacity(0.9))
      .cornerRadius(16)
      .padding(.horizontal, 24)
    }
  }
  
  // MARK: - Game Flow
  
  private func configureScene(with size: CGSize) {
    scene.scaleMode = .resizeFill
    scene.reset(for: size)
    scene.pauseGame()
    scene.scoreDidChange = { newScore in
      score = newScore
      if challenge.isTestMode {
        if newScore > highScore {
          highScore = newScore
        }
      }
      if newScore >= targetScore && !challenge.isTestMode {
        handleWin()
      }
    }
    score = 0
    timeRemaining = gameDuration
    isGameOver = false
    hasStarted = false
    outcome = .pending
    elapsedTime = 0
    challenge.isCompleted = false
    recordStartIfNeeded()
  }
  
  private func handleGameOver() {
    guard !isGameOver else { return }
    isGameOver = true
    hasStarted = false
    scene.pauseGame()
  }
  
  private func restartGame() {
    startGame()
  }
  
  private func startGame() {
    scene.reset(for: scene.size)
    score = 0
    timeRemaining = gameDuration
    isGameOver = false
    hasStarted = true
    outcome = .pending
    elapsedTime = 0
    challenge.isCompleted = false
  }

  private func handleWin() {
    guard !challenge.isCompleted else { return }
    guard !challenge.isTestMode else { return }
    isGameOver = true
    hasStarted = false
    scene.pauseGame()
    challenge.isCompleted = true
  }
  
  private func recordStartIfNeeded() {
    guard !hasRecordedStart else { return }
    hasRecordedStart = true
    ChallengeStatsManager.shared.recordChallengeTriggered(
      type: .gravityDrop,
      isTestMode: challenge.isTestMode
    )
  }
  
  private func skipChallenge() {
    guard canSkip else { return }
    outcome = .continued
    ChallengeStatsManager.shared.recordChallengeContinued(
      type: .gravityDrop,
      isTestMode: challenge.isTestMode
    )
    if let cancelAction = challengeCancelAction {
      cancelAction()
    }
    dismiss()
  }
  
  private func cancelChallenge() {
    outcome = .cancelled
    ChallengeStatsManager.shared.recordChallengeCancelled(
      type: .gravityDrop,
      isTestMode: challenge.isTestMode
    )
    dismiss()
  }
}

private enum ChallengeOutcome {
  case pending
  case continued
  case cancelled
}

private extension Bool {
  init(probability: Double) {
    self = Double.random(in: 0...1) < probability
  }
}
