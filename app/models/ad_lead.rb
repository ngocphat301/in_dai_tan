# frozen_string_literal: true

class AdLead < ApplicationRecord
  validates :phone, presence: true, length: { maximum: 32 }
  validate :phone_must_be_plausible

  private

  def phone_must_be_plausible
    return if phone.blank?

    digits = phone.gsub(/\D/, "")
    return if digits.length >= 9 && digits.length <= 11

    errors.add(:phone, "vui lòng nhập số điện thoại hợp lệ (9–11 chữ số)")
  end
end
