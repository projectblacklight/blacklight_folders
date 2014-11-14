module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  # Determine whether to render the bookmarks control
  def render_bookmarks_control?
    false
  end

  def bookmarks_export_url(format, params={})
    main_app.bookmarks_url(params.merge(format: format, encrypted_user_id: encrypt_user_id(current_or_guest_user.id) ))
  end

  # # This method should move to BlacklightMarc in Blacklight 6.x
  # def refworks_export_url params = {}
  #   if params.is_a? ::SolrDocument or (params.nil? and instance_variable_defined? :@document)
  #     Deprecation.warn self, "Calling #refworks_export_url without a :url is deprecated. Pass in e.g. { url: url_for_document(@document, format: :refworks_marc_txt) } instead"
  #     url = url_for_document(params || @document)
  #     params = { url: polymorphic_url(url, format: :refworks_marc_txt, only_path: false) }
  #   elsif params[:id]
  #     Deprecation.warn self, "Calling #refworks_export_url without a :url is deprecated. Pass in e.g. { url: url_for_document(@document, format: :refworks_marc_txt) } instead"
  #     params = { url: polymorphic_url(url_for_document(params), format: :refworks_marc_txt, only_path: false) }
  #   end

  #   "http://www.refworks.com/express/expressimport.asp?vendor=#{CGI.escape(params[:vendor] || application_name)}&filter=#{CGI.escape(params[:filter] || "MARC Format")}&encoding=65001" + (("&url=#{CGI.escape(params[:url])}" if params[:url]) || "")
  # end


end
