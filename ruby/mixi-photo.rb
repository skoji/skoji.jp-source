# mixi-photo v0.0.4 (2007/12/08 2:30)
# mixi photo upload library
#
# (C) Satoshi Kojima 2007
# http://www.skoji.jp/blog/

require 'digest/sha1'
require 'Base64'
require 'net/http'
require 'uri'
require 'time'
require 'rexml/document'


class MixiPhoto
  attr_accessor :albums

  def initialize(username, password)
    @wsseHeaderFunc = Proc.new  {
      nonce=Array.new(10){rand(256)}.pack('C*')
      timenow=Time.now.iso8601
      digest = Base64.encode64(Digest::SHA1.digest(nonce+timenow+password)).strip
      {
        'X-WSSE' =>
        "UsernameToken Username=\"#{username}\", PasswordDigest=\"#{digest}\", Nonce=\"#{Base64.encode64(nonce).strip}\", Created=\"#{timenow}\""
      }
    }
    connect
  end

  # mode="public", "protected" or "friends". when mode=protected, parameter key is required.
  def createAlbum(albumName, description, mode="public", key="")
    http = Net::HTTP.new(@photo_uri.host)

    response = http.post(@photo_uri.path, self.albumRequestXml(albumName, description, mode, key), @wsseHeaderFunc.call.update({'Content-Type' => 'text/xml'}))
    raise "#{response.body}" unless response.is_a?(Net::HTTPCreated)
    return MixiPhotoAlbum.new(albumName, URI.parse(response["location"]), @wsseHeaderFunc)
  end

  
  def connect
    server = 'photo.mixi.jp'
    path = '/atom/r=4/'
    http = Net::HTTP.new(server)
    response = http.get(path, @wsseHeaderFunc.call)
    raise "#{response.body}" unless response.is_a?(Net::HTTPSuccess)
    # get album data
    @albums = []
    doc = REXML::Document.new response.body
    doc.elements.each('/service/workspace/collection') {
      |e|
      accept = e.elements['accept'].nil? ? "" : e.elements['accept'].text
      if accept == 'image/jpeg'
        @albums << MixiPhotoAlbum.new(e.elements["atom:title"].text,URI.parse(e.attributes["href"]), @wsseHeaderFunc)
      else
        @photo_uri = URI.parse(e.attributes["href"])
      end
    }
  end

  def albumRequestXml(albumName, description, mode, key)

    if (mode=="protected")
      keytag="<permit:token>#{key}</permit:token>"
    else
      keytag = ""
    end
      
    return %Q(<?xml version="1.0" encoding="utf-8"?>
<entry xmlns="http://www.w3.org/2005/Atom" xmlns:app="http://purl.org/atom/app#" xmlns:permit="http://mixi.jp/atom/ns#permit">
  <title>#{albumName}</title>
  <author><name /></author>
  <content />
  <summary>#{description}</summary>
  <updated>#{Time.now.iso8601}</updated>
  <app:control>
  <permit:access>#{mode}</permit:access> #{keytag}
  </app:control>
</entry>)
  end

  protected :connect, :albumRequestXml
end  

class MixiPhotoAlbum
  attr_accessor :title

  def initialize(title, uri, wsseHeaderFunc)
    @title = title
    @uri = uri
    @wsseHeaderFunc = wsseHeaderFunc
  end

  def uploadPhoto(photoPath)
    mimetype = 'image/jpeg'
    http = Net::HTTP.new(@uri.host)
    response = http.post(@uri.path, open(photoPath, "rb").read, @wsseHeaderFunc.call().update({'Content-Type' => mimetype}))
    raise "#{response.body}" unless response.is_a?(Net::HTTPCreated)
    return response.body
  end

end


