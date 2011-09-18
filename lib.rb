def require_api_key
  halt 401 unless params[:api_key] == Settings['api_key']
end

def require_fresh_user
  halt 403 if Settings
end

def custom_error e
  {:error => e}.to_json
end