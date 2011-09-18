def require_api_key
  halt 401 unless params[:api_key] == Settings['api_key']
end

def require_fresh_user
  halt 403 if Settings
end

def forward_error e
  {:exception => e, :message => e.backtrace.join("\n")}.to_json
end