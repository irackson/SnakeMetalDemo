import Cocoa
import Metal
import MetalKit

let shaderSource = """
#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float2 position [[attribute(0)]];
    float4 color    [[attribute(1)]];
};

struct Varying {
    float4 position [[position]];
    float4 color;
};

vertex Varying vertex_main(
    const device VertexIn* verts [[buffer(0)]],
    uint vid [[vertex_id]]
) {
    Varying out;
    out.position = float4(verts[vid].position, 0, 1);
    out.color    = verts[vid].color;
    return out;
}

fragment float4 fragment_main(Varying in [[stage_in]]) {
    return in.color;
}
"""

class GameView: MTKView, MTKViewDelegate {
    struct Vertex { var position: SIMD2<Float>; var color: SIMD4<Float> }
    let gridSize = 20
    var snake = [(10,10),(9,10),(8,10)]
    var dir = (dx: 1, dy: 0)
    var food = (15,15)
    var lastUpdate = CACurrentMediaTime()
    var pipeline: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!

    override init(frame frameRect: NSRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device ?? MTLCreateSystemDefaultDevice())
        colorPixelFormat = .bgra8Unorm
        delegate = self
        preferredFramesPerSecond = 60

        commandQueue = self.device!.makeCommandQueue()
        let lib = try! self.device!.makeLibrary(source: shaderSource, options: nil)
        let vfn = lib.makeFunction(name: "vertex_main")!
        let ffn = lib.makeFunction(name: "fragment_main")!
        let pd = MTLRenderPipelineDescriptor()
        pd.vertexFunction = vfn
        pd.fragmentFunction = ffn
        pd.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipeline = try! self.device!.makeRenderPipelineState(descriptor: pd)

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { e in
            switch e.keyCode {
            case 123: self.dir = (-1, 0)
            case 124: self.dir = ( 1, 0)
            case 125: self.dir = ( 0,-1)
            case 126: self.dir = ( 0, 1)
            default: break
            }
            return e
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }

    func draw(in view: MTKView) {
        let now = CACurrentMediaTime()
        if now - lastUpdate > 0.15 {
            lastUpdate = now
            var head = snake[0]
            head = ((head.0 + dir.dx + gridSize) % gridSize,
                    (head.1 + dir.dy + gridSize) % gridSize)
            snake.insert(head, at: 0)
            if head == food {
                food = (Int.random(in: 0..<gridSize), Int.random(in: 0..<gridSize))
            } else {
                snake.removeLast()
            }
        }

        guard let pass = currentRenderPassDescriptor,
              let drawable = currentDrawable else { return }
        let buf = commandQueue.makeCommandBuffer()!
        let enc = buf.makeRenderCommandEncoder(descriptor: pass)!
        enc.setRenderPipelineState(pipeline)

        var verts = [Vertex]()
        func addRect(x: Int, y: Int, color: SIMD4<Float>) {
            let s  = 2.0 / Float(gridSize)
            let fx = Float(x) * s - 1 + s/2
            let fy = Float(y) * s - 1 + s/2
            let hs = s/2
            let pts = [
                SIMD2<Float>(fx-hs, fy-hs), SIMD2<Float>(fx+hs, fy-hs), SIMD2<Float>(fx-hs, fy+hs),
                SIMD2<Float>(fx+hs, fy-hs), SIMD2<Float>(fx+hs, fy+hs), SIMD2<Float>(fx-hs, fy+hs),
            ]
            for p in pts { verts.append(Vertex(position: p, color: color)) }
        }

        snake.forEach { addRect(x: $0.0, y: $0.1, color: SIMD4<Float>(0,1,0,1)) }
        addRect(x: food.0, y: food.1, color: SIMD4<Float>(1,0,0,1))

        enc.setVertexBytes(verts, length: MemoryLayout<Vertex>.stride * verts.count, index: 0)
        enc.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: verts.count)
        enc.endEncoding()

        buf.present(drawable)
        buf.commit()
    }
}

let app    = NSApplication.shared
app.setActivationPolicy(.regular)
let window = NSWindow(
    contentRect: NSMakeRect(0, 0, 640, 640),
    styleMask: [.titled, .closable, .resizable],
    backing: .buffered, defer: false
)
window.title = "Snake Metal Demo"
let view = GameView(frame: window.contentView!.bounds,
                    device: MTLCreateSystemDefaultDevice())
view.autoresizingMask = [.width, .height]
window.contentView = view
window.makeKeyAndOrderFront(nil)
app.activate(ignoringOtherApps: true)
app.run()
