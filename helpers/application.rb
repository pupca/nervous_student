helpers do
  def link_to(url,text=url,opts={})
    attributes = ""
    opts.each { |key,value| attributes << key.to_s << "=\"" << value << "\" "}
    "<a href=\"#{url}\" #{attributes}>#{text}</a>"
  end

  def boolean_badge(status)
    return "<span class='label label-#{status ? "success" : "important"}'>#{status ? "Ano" : "Ne"}</span>"
  end
end