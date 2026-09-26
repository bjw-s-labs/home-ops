function envoy_on_request(request_handle)
  local user_agent = request_handle:headers():get("user-agent") or ""
  local blocked_patterns = {
    "Meta-ExternalAgent",
    "meta-webindexer",
    "GPTBot",
    "CCBot",
    "Google-Extended",
    "Bytespider",
    "Amazonbot",
    "Applebot-Extended"
  }

  for _, pattern in ipairs(blocked_patterns) do
    if string.find(user_agent, pattern, 1, true) then
      request_handle:respond({[":status"] = "200"}, "")
      return
    end
  end
end
