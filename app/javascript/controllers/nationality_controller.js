import { Controller } from "@hotwired/stimulus"

// ISO country/territory codes; names come from the browser's Spanish locale data.
const regions = `AD AE AF AG AI AL AM AO AQ AR AS AT AU AW AX AZ BA BB BD BE BF BG BH BI BJ BL BM BN BO BQ BR BS BT BV BW BY BZ CA CC CD CF CG CH CI CK CL CM CN CO CR CU CV CW CX CY CZ DE DJ DK DM DO DZ EC EE EG EH ER ES ET FI FJ FK FM FO FR GA GB GD GE GF GG GH GI GL GM GN GP GQ GR GS GT GU GW GY HK HM HN HR HT HU ID IE IL IM IN IO IQ IR IS IT JE JM JO JP KE KG KH KI KM KN KP KR KW KY KZ LA LB LC LI LK LR LS LT LU LV LY MA MC MD ME MF MG MH MK ML MM MN MO MP MQ MR MS MT MU MV MW MX MY MZ NA NC NE NF NG NI NL NO NP NR NU NZ OM PA PE PF PG PH PK PL PM PN PR PS PT PW PY QA RE RO RS RU RW SA SB SC SD SE SG SH SI SJ SK SL SM SN SO SR SS ST SV SX SY SZ TC TD TF TG TH TJ TK TL TM TN TO TR TT TV TW TZ UA UG UM US UY UZ VA VC VE VG VI VN VU WF WS YE YT ZA ZM ZW`.split(" ")
const names = new Intl.DisplayNames(["es"], { type: "region" })
const countries = regions.map(code => names.of(code)).sort((a, b) => a.localeCompare(b, "es"))
const normalize = value => value.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLocaleLowerCase("es").trim()

export default class extends Controller {
  static targets = ["input", "list"]

  connect() {
    this.activeIndex = -1
  }

  search() {
    const query = normalize(this.inputTarget.value)
    this.matches = countries.filter(country => normalize(country).includes(query))
    this.activeIndex = -1
    this.inputTarget.removeAttribute("aria-activedescendant")
    this.listTarget.replaceChildren()
    this.matches.forEach((country, index) => {
      const option = document.createElement("li")
      option.id = `${this.listTarget.id}_${index}`
      option.setAttribute("role", "option")
      option.setAttribute("aria-selected", "false")
      option.textContent = country
      option.addEventListener("mousedown", event => event.preventDefault())
      option.addEventListener("click", () => this.select(index))
      this.listTarget.append(option)
    })
    if (!this.matches.length) {
      const message = document.createElement("li")
      message.className = "nationality-empty"
      message.textContent = "No se encontraron países"
      this.listTarget.append(message)
    }
    this.listTarget.hidden = false
    this.inputTarget.setAttribute("aria-expanded", "true")
    this.listTarget.scrollTop = 0
  }

  navigate(event) {
    if (event.key === "Escape") return this.close()
    if (event.key === "Enter" && !this.listTarget.hidden && this.activeIndex >= 0) {
      event.preventDefault()
      return this.select(this.activeIndex)
    }
    if (!["ArrowDown", "ArrowUp"].includes(event.key)) return
    event.preventDefault()
    if (this.listTarget.hidden) this.search()
    if (!this.matches.length) return
    const step = event.key === "ArrowDown" ? 1 : -1
    this.activeIndex = this.activeIndex < 0
      ? (step === 1 ? 0 : this.matches.length - 1)
      : (this.activeIndex + step + this.matches.length) % this.matches.length
    Array.from(this.listTarget.children).forEach((option, index) => {
      option.setAttribute("aria-selected", String(index === this.activeIndex))
    })
    const active = this.listTarget.children[this.activeIndex]
    this.inputTarget.setAttribute("aria-activedescendant", active.id)
    active.scrollIntoView({ block: "nearest" })
  }

  select(index) {
    this.inputTarget.value = this.matches[index]
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
    this.close()
  }

  blur(event) {
    if (!this.element.contains(event.relatedTarget)) this.close()
  }

  close() {
    this.listTarget.hidden = true
    this.inputTarget.setAttribute("aria-expanded", "false")
    this.inputTarget.removeAttribute("aria-activedescendant")
    this.activeIndex = -1
  }
}
