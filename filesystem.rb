class Pathname
  attr_accessor :filesystem
end

class Filesystem
  attr_reader :path, :user, :relative_path, :user_path
    
  def initialize(path = '')
    path = Pathname.new(path) if path.instance_of?(String)
    
    #@download_url = Setting.find_by_key('download_url').value
    @user_path = Pathname.new(user.profile.download_folder)
    @relative_path = Pathname.new(path)
    @path = link_with_self(@user_path + @relative_path)
  end
  
  # Sets the relative path to look at: user.filesystem.subdir('AutoTV/Show').each
  def subdir(dir)
    dir = Pathname.new(dir) if dir.instance_of? String
    dir = Pathname.new('.') if dir.to_s =~ /\.\./
    dir = Pathname.new('.') if any_symlinks_in dir
    newdir = @relative_path + dir
    Filesystem.new @user, newdir.to_s
  end
  
  def each
    path.children
    .reject{|f| f.basename.to_s =~ /(tmp)|(private)|(incomplete)|(^\..*$)/}
    .sort{|a, b| b.mtime <=> a.mtime}.each do |f|
      f = link_with_self(f)     
      yield f if block_given?
    end
  end
  def all; each end
    
  def recent(limit=9)
    each[0..limit-1]
  end
  
  def glob
    escpath = (@path + Pathname.new('**/*')).to_s.gsub(/(\[|\]|\{|\}|\(|\)|\?|\.)/){ "\\"+$1 }
    Pathname.glob(escpath).map{|f| f = link_with_self(f)}.sort!{ |a,b| a.basename.to_s.downcase <=> b.basename.to_s.downcase }
  end
  
  def to_zip current_user
    # Don't let the user zip the home dir
    return nil if @path == Pathname.new(@user_path)
    
    # Current user's path
    mypath = current_user.profile.download_folder
    # Download to
    target = Pathname.new(mypath)+'tmp'+"#{@path.basename}.tar"
    command = "cd #{@path.parent} && tar -cf #{target.to_s.shellescape} #{@path.basename.to_s.shellescape}"
    `#{command}`
    # Check that it was created
    return nil unless target.file?
    
    zipfile = Pathname.new("tmp/#{target.basename.to_s}")
    zipfile.filesystem = current_user.filesystem
    zipfile
  end
    
  private
  # Checks for symlinks in the path but not the basepath
  def any_symlinks_in(dir)
    dir.ascend do |p|
      return true if (@path + p).symlink?
    end
    false
  end
  
  def process_path(path)
    path ||= ''
    #Strip parent dirs for security
    path = path.gsub('..', '')
  end
  
  def link_with_self(path)
    path = Pathname.new(path) if path.instance_of? String
    path.filesystem = self
    path
  end
end