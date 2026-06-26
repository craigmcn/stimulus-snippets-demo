import { Controller } from "@hotwired/stimulus"

// Demo-only stand-in for ActiveStorage's direct upload JS. This app has no
// database (--skip-active-record), so there's no real ActiveStorage to
// upload to — this dispatches the same `direct-upload:*` custom events on
// the file input, on a fake timer, so direct-upload-progress's rendering
// can be exercised without a backend.
export default class extends Controller {
  static targets = ["input"]

  start() {
    for (const file of this.inputTarget.files) {
      this._simulate(file)
    }
    this.inputTarget.value = ""
  }

  _simulate(file) {
    const id = crypto.randomUUID()
    const shouldFail = /fail/i.test(file.name)
    let progress = 0

    this.inputTarget.dispatchEvent(
      new CustomEvent("direct-upload:initialize", { detail: { id, file } })
    )

    const tick = () => {
      progress += 10 + Math.random() * 20

      if (progress < 100) {
        this.inputTarget.dispatchEvent(
          new CustomEvent("direct-upload:progress", { detail: { id, progress: Math.min(progress, 99) } })
        )
        setTimeout(tick, 250)
        return
      }

      if (shouldFail) {
        this.inputTarget.dispatchEvent(
          new CustomEvent("direct-upload:error", { detail: { id, error: "Simulated upload failure" } })
        )
      } else {
        this.inputTarget.dispatchEvent(new CustomEvent("direct-upload:end", { detail: { id } }))
      }
    }

    setTimeout(tick, 250)
  }
}
