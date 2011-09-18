class Pathname
  attr_accessor :filesystem
end

class Filesystem
  attr_reader :path, :base_path
    
  def initialize(path = '')
    @path = Pathname.new(path) if path.instance_of?(String)
    @path ||= path
    
    @base_path = Pathname.new(Settings['directory'])
  end
  
  # Sets the relative path to look at: filesystem.subdir('TV/Show').each
  def subdir(dir)
    dir = Pathname.new(dir) if dir.instance_of? String
    dir = Pathname.new('.') if dir.to_s =~ /\.\./ or dir.to_s =~ /^\//
    dir = Pathname.new('.') if any_symlinks_in dir
    newdir = @path + dir
    Filesystem.new newdir
  end
  
  def each
    path.children
    .reject{|f| f.basename.to_s =~ /(tmp)|(private)|(incomplete)|(^\..*$)/}
    .sort{|a, b| b.mtime <=> a.mtime}.each do |f|
      f = link_with_self(f)     
      yield f if block_given?
    end
  end
  
  def all(recursive=false)
    each.map do |f|
      hash = {
        :basename => f.basename.to_s,
        :hash => Digest::MD5.hexdigest(f.basename.to_s),
        :mtime => f.mtime,
        :size => f.size,
        :is_directory => f.directory?
      }
      
      hash[:children] = Filesystem.new(f).all(true) if f.directory? and recursive
      hash
    end
  end
  
  def to_zip    
    # Download to
    target = @base_path+'tmp'+"#{@path.basename}.tar"
    command = "cd #{@path.parent} && tar -cf #{target.to_s.shellescape} #{@path.basename.to_s.shellescape}"
    `#{command}`
    # Check that it was created
    return nil unless target.file?

    {
      :basename => target.basename,
      :path => target.relative_path_from(@base_path).dirname.to_s,
      :size => target.size,
      :mtime => target.mtime
    }
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