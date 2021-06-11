defmodule HubIdentity.EmailTester do
  def send(%SendGrid.Email{}) do
    :ok
  end
end

# %SendGrid.Email{
#   __phoenix_layout__: nil,
#   __phoenix_view__: nil,
#   attachments: nil,
#   bcc: nil,
#   cc: nil,
#   content: [
#     %{
#       type: "text/plain",
#       value: "\n==============================\n\nHi administrator-576460752303411583@example.com,\n\nYou can reset your password by visiting the URL below:\n\n[TOKEN]dtsRdbTku-i0alFISN7tQnbqpIg41WL7JmINjkIv6Wc[TOKEN]\n\nIf you didn't request this change, please ignore this.\n\n==============================\n"
#     }
#   ],
#   custom_args: nil,
#   dynamic_template_data: nil,
#   from: %{email: "info@hubidentity.com"},
#   headers: nil,
#   personalizations: nil,
#   reply_to: nil,
#   sandbox: false,
#   send_at: nil,
#   subject: "Reset password instructions",
#   substitutions: nil,
#   template_id: nil,
#   to: [%{email: "administrator-576460752303411583@example.com"}]
# }
