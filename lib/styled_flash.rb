module StyledFlash
  def input_message(key=:flash)
    return "" if flash(key).empty?
    flash(key).collect do |kind, message| 
      erb :'components/message', locals: {message: message, kind: kind}
    end.join
  end
end
