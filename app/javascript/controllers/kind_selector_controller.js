import { Controller } from "@hotwired/stimulus"

// 洋服登録/編集フォームで、カテゴリに応じて種類の選択肢を切り替える。
export default class extends Controller {
  static targets = ["category", "kind"]

  connect() {
    this.optionsByCategory = JSON.parse(this.element.dataset.kindOptions || "{}")
    this.populate()
  }

  categoryChanged() {
    this.populate()
  }

  populate() {
    const categoryId = this.categoryTarget.value
    const currentKind = this.kindTarget.value
    const options = this.optionsByCategory[categoryId] || []

    this.kindTarget.innerHTML = ""
    options.forEach((label) => {
      const opt = document.createElement("option")
      opt.value = label
      opt.textContent = label
      this.kindTarget.appendChild(opt)
    })

    // すでに保存済みの種類を維持する（選択肢に無ければ先頭に足して保持）
    if (options.includes(currentKind)) {
      this.kindTarget.value = currentKind
    } else if (currentKind && currentKind !== "") {
      const opt = document.createElement("option")
      opt.value = currentKind
      opt.textContent = `${currentKind}（その他）`
      this.kindTarget.insertBefore(opt, this.kindTarget.firstChild)
      this.kindTarget.value = currentKind
    }
  }
}