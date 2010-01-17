class OrderMailer < ActionMailer::Base

  def thankyou(order, bcc = true)
    from $STORE_PREFS['purchase_receipt_sender_email']

    recipients order.email
    bcc $STORE_PREFS['purchase_receipt_bcc_email'] if bcc == true

    subject "Purchase Receipt for Order ##{order.id}"
    subject subject + ' *' if not order.comment.blank?

    content_type "multipart/alternative"

    part :content_type => "text/plain",
         :body => render_message("thankyou_plain", :order => order)

    part :content_type => "text/html",
    	 :transfer_encoding => 'base64',
    	 :body => render_message("thankyou_html", :order => order)
  end
  
  def error_notice(order)
    from $STORE_PREFS['purchase_receipt_sender_email']
    recipients $STORE_PREFS['sales_email']
    subject "Error notice for Order #{order.id}"
    body 'order' => order
  end

  def lost_license_sent(order)
    recipients $STORE_PREFS['lost_license_sent_notification_recipient_email']
    from $STORE_PREFS['lost_license_sent_notification_sender_email']
    subject 'Lost License Sent'
    body 'order' => order
  end

end
