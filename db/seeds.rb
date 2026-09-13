# 大カテゴリのマスタデータ
categories = [
  { name: "トップス", sort_order: 1 },
  { name: "ボトムス", sort_order: 2 },
  { name: "アウター", sort_order: 3 },
  { name: "ワンピース", sort_order: 4 }
]

categories.each do |attrs|
  category = Category.find_or_initialize_by(name: attrs[:name])
  category.update!(sort_order: attrs[:sort_order])
end
