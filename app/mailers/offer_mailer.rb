

class OfferMailer < ApplicationMailer
  def send_offer(offer)
    @offer = offer
    @order = offer.order
    @company = @order.company

    to_email = offer.sent_to_email.presence || @company.offers_email
    raise 'Missing offers_email for company' if to_email.blank?

    # attachment (pdf)
    attachments["ponuda-#{offer.number}.pdf"] = offer.pdf.download if offer.pdf.attached?

    mail(
      to: to_email,
      subject: "Ponuda #{offer.number} (narudžba ##{@order.id})"
    )
  end
end
