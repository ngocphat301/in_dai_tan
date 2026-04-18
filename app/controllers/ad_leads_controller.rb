# frozen_string_literal: true

# Form popup quảng cáo (scope :ad_lead) — lưu vào quote_requests với request_type ads.
class AdLeadsController < ApplicationController
  ADS_DEFAULT_NAME = "Khách — popup quảng cáo"
  ADS_DEFAULT_BODY = "Đăng ký nhận tư vấn từ popup quảng cáo trên website."

  def create
    @quote_request = QuoteRequest.new(
      request_type: :from_ads_popup,
      phone: ad_lead_params[:phone].to_s.strip,
      customer_name: ADS_DEFAULT_NAME,
      body: ADS_DEFAULT_BODY
    )
    if @quote_request.save
      render json: { ok: true }, status: :created
    else
      render json: { errors: @quote_request.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def ad_lead_params
    params.require(:ad_lead).permit(:phone)
  end
end
