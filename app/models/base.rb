class Base < ApplicationRecord
  validates :base_number, presence: true, length: { maximum: 10 }, numericality: { greater_than: 0 }, uniqueness: true 
 #numericalityは、整数であるかどうかや、指定値以上(以下・未満・等しい)かどうかなどを検証#greater_than: 0は１以上、uniquenessは、重複を禁止
                                                
  validates :base_name, presence: true, length: { maximum: 30 }
end
