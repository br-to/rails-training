class MyJob < ApplicationJob
  queue_as :default

  def perform(title)
    puts "#{title}をする"
    raise "テスト用エラー" if title == "失敗テスト"
  end
end
