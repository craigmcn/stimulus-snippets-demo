import { Controller } from "@hotwired/stimulus"

// Demo-only helper: renders what a form would actually submit, so
// responsive-disable's effect (a hidden field dropping out of the request)
// is visible without needing a real server round-trip.
export default class extends Controller {
  static targets = ["output"]

  show(event) {
    event.preventDefault()

    const pairs = Array.from(new FormData(event.target).entries()).map(
      ([key, value]) => `${key}=${value}`
    )

    this.outputTarget.textContent = pairs.length
      ? pairs.join("\n")
      : "(nothing submitted)"
  }
}
