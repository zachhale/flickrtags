module FlickrTags
  include Radiant::Taggable
  
  def get_flickr_iframe(user, param_name, param_val, attr_type, width, height)
    value_url = "&offsite=true&lang=en-us&page_show_url=%2Fphotos%2F#{user}%2F#{attr_type}%2F#{param_val}%2Fshow%2F&page_show_back_url=%2Fphotos%2F#{user}%2F#{attr_type}%2F#{param_val}%2F&#{param_name}=#{param_val}&jump_to="
<<EOS
  <object width="#{width}" height="#{height}"> <param name="flashvars" value="#{value_url}"></param> <param name="movie" value="http://www.flickr.com/apps/slideshow/show.swf?v=63961"></param> <param name="allowFullScreen" value="true"></param><embed type="application/x-shockwave-flash" src="http://www.flickr.com/apps/slideshow/show.swf?v=63961" allowFullScreen="true" flashvars="#{value_url}" width="#{width}" height="#{height}"></embed></object>
EOS
  end

  tag "flickr" do |tag|
    tag.expand
  end
  
  tag "flickr:slideshow" do |tag|
    attr = tag.attr.symbolize_keys
    
    if (attr[:user])
      user = attr[:user].strip
    else
      raise StandardError.new("Please provide a Flickr user name in the flickr:slideshow tag's `user` attribute")
    end
    
    if (attr[:size])
      case attr[:size].strip
      when 'small'
        width,height = 400,300
      when 'medium'
        width,height = 500,375
      when 'large'
        width,height = 700,525
      when 'super-sized'
        width,height = 800,600
      end
    elsif (attr[:width]) and (attr[:size])
      width,height = attr[:width].strip, attr[:height].strip
    else
      width,height = 500,375
    end   
    
    if attr[:set]
      get_flickr_iframe user, 'set_id', attr[:set].strip, 'sets', width, height
    elsif attr[:tags]
      get_flickr_iframe user, 'tags', attr[:tags].strip, 'tags', width, height
    else
      raise StandardError.new("Please provide a Flickr set ID in the flickr:slideshow tag's `set` attribute or a comma-separated list of Flickr tags in the `tags` attribute")
    end 
  end
  
  tag 'flickr:user' do |tag|

    tag.expand
  end

  tag 'flickr:user:photos' do |tag|
    tag.expand
  end

  tag 'flickr:user:photos:each' do |tag|

    attr = tag.attr.symbolize_keys

    options = {}

    [:limit, :offset].each do |symbol|
      if number = attr[symbol]
        if number =~ /^\d{1,4}$/
          options[symbol] = number.to_i
        else
          raise TagError.new("`#{symbol}' attribute of `each' tag must be a positive number between 1 and 4 digits")
        end
      end
    end    

    tag.attr['user'] ||= 'username'


    flickr = Flickr.new    
    user = flickr.users(tag.attr['user'])

    tag.locals.photos = user.photos(options[:limit], options[:offset])    

    result = ''

    tag.locals.photos.each do |photo|
      tag.locals.photo = photo
      result << tag.expand
    end

    result

  end

  tag 'flickr:user:photos:each:photo' do |tag|
    tag.expand
  end

  tag 'flickr:user:photos:each:photo:src' do |tag|
    tag.attr['size'] ||= 'Medium'    
    tag.locals.photo.source(tag.attr['size'])
  end

  tag 'flickr:user:photos:each:photo:description' do |tag|
    tag.locals.photo.description
  end

  tag 'flickr:user:photos:each:photo:title' do |tag|
    tag.locals.photo.title
  end  




  # Photoset tags

  tag "flickr:sets" do |tag|
     tag.expand
   end

   tag "flickr:sets:each" do |tag|

     tag.attr['user'] ||= 'username'

     flickr = Flickr.new    
     user = flickr.users(tag.attr['user'])

     tag.locals.sets = user.photosets    

     result = ''

     tag.locals.sets.each do |set|
       tag.locals.set = set
       result << tag.expand
     end

     result

  end

  tag "flickr:set" do |tag|
    tag.expand
  end

  tag "flickr:set:title" do |tag|
    tag.locals.set.title
  end

  tag 'flickr:set:link' do |tag|
    tag.locals.set.url.to_s
  end

  tag 'flickr:set:photos' do |tag|
    tag.expand
  end

  tag 'flickr:set:photos:each' do |tag|

  end  
  
end
