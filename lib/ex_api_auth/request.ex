defmodule ExApiAuth.Request do
  defstruct method:       "GET",
            content_type: nil,
            content_md5:  nil,
            uri:          nil,
            date:         :httpd_util.rfc1123_date
end
