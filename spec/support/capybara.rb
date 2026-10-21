# frozen_string_literal: true

# CI（GitHub Actions）上系统测试偶发性时序失败的稳定化修复。
# 本地跑得快，默认 2 秒内登录跳转能完成；CI 环境较慢，超过 2 秒就会偶发超时。
# 把默认等待时间放大到 5 秒，给慢环境留足页面跳转时间（对测试结果无副作用）。
Capybara.default_max_wait_time = 5 if defined?(Capybara)
